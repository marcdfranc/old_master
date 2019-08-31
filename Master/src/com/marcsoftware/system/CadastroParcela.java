package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.FormaPagamento;
import com.marcsoftware.database.ItensOrcamento;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Orcamento;
import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.database.ParcelaOrcamentoId;
import com.marcsoftware.database.PlanoServico;
import com.marcsoftware.database.Score;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;
import com.sun.corba.se.impl.oa.poa.AOMEntry;

/**
 * Servlet implementation class for Servlet: CadastroParcela
 *
 */
 public class CadastroParcela extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
   static final long serialVersionUID = 1L;
   private int qtde, mes, ano;
   private double vlrOrcamento, taxa, vlrParcela, entrada;
   private String data;
   private Date vencimento;
   private ParcelaOrcamento parcela;
   private ParcelaOrcamentoId id;
   private Lancamento lancamento;
   private Unidade unidade;   
   private Orcamento orcamento;   
   private FormaPagamento pagamento;
   private Score score;
   private PlanoServico planoServico;
   private List<ItensOrcamento> itensOrcamento;
   private List<ParcelaOrcamento> parcelaList;
   private ArrayList<Long> pipe;
   private DataGrid dataGrid;
   private Session session;
   private Transaction transaction;
   private Query query;
   private PrintWriter out;
    
	public CadastroParcela() {
		super();
	}	
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			switch (Integer.parseInt(request.getParameter("from"))) {
			case 0:
				if (addRecord(request))  {
					response.setContentType("text/html");
					response.setCharacterEncoding("ISO-8859-1");
					out = response.getWriter();
					transaction = session.beginTransaction();
					request.setCharacterEncoding("ISO-8859-1");				
					query = session.getNamedQuery("parcelamentoByCodeOrcamento");
					query.setLong("codigo", Long.valueOf(request.getParameter("orcamento")));
					parcelaList= (List<ParcelaOrcamento>) query.list();
					vencimento = new Date();
					dataGrid= new DataGrid(null);
					int gridLines= parcelaList.size();
					dataGrid.addColum("10", "Parcela");
					dataGrid.addColum("15", "Vencimento");
					dataGrid.addColum("25", "Descrição");
					dataGrid.addColum("5", "Status");
					dataGrid.addColum("15", "Dt. Pagamento");
					dataGrid.addColum("20", "Valor");
					dataGrid.addColum("10", "Valor Pago");
					for(int i=0; i < parcelaList.size(); i++) {
						dataGrid.setId(String.valueOf(
								parcelaList.get(i).getId().getLancamento().getCodigo()));
						
						dataGrid.addData(String.valueOf(i + 1) + " de " + 
								String.valueOf(parcelaList.size()));
						
						dataGrid.addData(Util.parseDate(
								parcelaList.get(i).getId().getLancamento().getVencimento(), "dd/MM/yyyy"));
						
						dataGrid.addData(Util.initCap(parcelaList.get(i).getId().getLancamento().getConta().getDescricao()));
						
						if (parcelaList.get(i).getId().getLancamento().getStatus().equals("a")) {
							dataGrid.addData("Aberto");
						} else if (parcelaList.get(i).getId().getLancamento().getStatus().equals("q")) {
							dataGrid.addData("Quitado");
						} else if (parcelaList.get(i).getId().getLancamento().getStatus().equals("c")) {
							dataGrid.addData("Cancelado");
						}
						
						dataGrid.addData((parcelaList.get(i).getId().getLancamento().getDataQuitacao()== null)?
								"" : Util.parseDate(
										parcelaList.get(i).getId().getLancamento().getDataQuitacao(), "dd/MM/yyyy"));
						
						if (parcelaList.get(i).getId().getLancamento().getStatus().trim().equals("a") &&
								parcelaList.get(i).getId().getLancamento().getVencimento().after(vencimento)) {
							dataGrid.addData(Util.formatCurrency(String.valueOf(parcelaList.get(i).getId().getLancamento().getValor())));
						} else if (parcelaList.get(i).getId().getLancamento().getStatus().trim().equals("q")) {
							dataGrid.addData(Util.formatCurrency(String.valueOf(parcelaList.get(i).getId().getLancamento().getValorPago())));
						} else {
							dataGrid.addData(Util.formatCurrency(String.valueOf(
									Util.calculaAtraso(parcelaList.get(i).getId().getLancamento().getValor(),
											parcelaList.get(i).getId().getLancamento().getTaxa(),
											parcelaList.get(i).getId().getLancamento().getVencimento()))));									
						}										
						
						dataGrid.addData(Util.formatCurrency(String.valueOf(
								parcelaList.get(i).getId().getLancamento().getValorPago())));
						dataGrid.addRow();
					}
					out.print(dataGrid.getTable(gridLines));
					transaction.commit();
					session.close();
					out.close();
				} else {
					out.print("0");			
					session.close();
					out.close();
				}
				break;
				
			case 1:
				response.setContentType("text/plain");
				response.setCharacterEncoding("ISO-8859-1");
				out = response.getWriter();
				out.print(reparcela(request));
				out.close();
				break;
				
			case 3:
				response.setContentType("text/plain");
				response.setCharacterEncoding("ISO-8859-1");
				out = response.getWriter();
				if (editObs(request)) {
					out.print("1");
					out.close();
				} else {
					out.print("0");
					out.close();
				}
				break;

			case 6:
				response.setContentType("text/plain");
				response.setCharacterEncoding("ISO-8859-1");
				out = response.getWriter();
				out.print(checkUser(request));
				//session.close();
				out.close();
				break;
			}
		} catch (Exception e) {			
			e.printStackTrace();
			out.print("0");
			transaction.rollback();
			session.close();			
			out.close();
		}
	}	
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub		
	}
	
	private boolean addRecord(HttpServletRequest request) {
		try {
			session= HibernateUtil.getSession();
			transaction = session.beginTransaction();
			TipoConta conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("62"));
			query = session.createQuery("from Unidade as u where u.codigo = :codigo");
			query.setLong("codigo", Long.valueOf(request.getParameter("unidadeId")));			
			unidade= (Unidade) query.uniqueResult();			
			
			qtde = Integer.parseInt(request.getParameter("parcela"));
			query = session.createQuery("from Orcamento as o where o.codigo= :codigo");
			query.setLong("codigo", Long.valueOf(request.getParameter("orcamento")));
			orcamento = (Orcamento) query.uniqueResult();
			orcamento.setObservacao(Util.encodeString(request.getParameter("obs"), "ISO-8859-1","UTF8"));
			orcamento.setParcelas(qtde);
			session.update(orcamento);
			
			vencimento = new Date();
			mes= Util.getMonthDate(vencimento);
			ano= Util.getYearDate(vencimento);
			vlrOrcamento= Double.parseDouble(request.getParameter("valor"));
			entrada = Double.parseDouble(request.getParameter("entrada"));			
			taxa = Double.parseDouble(request.getParameter("taxa"));
			vlrOrcamento-= entrada;
			if (entrada > 0) {
				vlrParcela = (vlrOrcamento * Math.pow((1 + taxa/100), (qtde -1)))/(qtde -1);
			} else {
				vlrParcela = (vlrOrcamento * Math.pow((1 + taxa/100), qtde))/qtde;
			}
			for (int i = 0; i < qtde; i++) {
				data = request.getParameter("vencimento") + "/" + 
					Util.zeroToLeft(String.valueOf(mes), 2) + "/" + String.valueOf(ano);
				lancamento = new Lancamento();
				//lancamento.setDescricao("tratamento");
				lancamento.setConta(conta);
				lancamento.setTipo("c");
				lancamento.setTaxa(Double.parseDouble(request.getParameter("atraso")));
				lancamento.setUnidade(unidade);
				if (i == 0) {					
					lancamento.setValor((entrada > 0)? entrada : vlrParcela);
					lancamento.setVencimento(vencimento);					
					lancamento.setEmissao(vencimento);					
					lancamento.setStatus("a");
				} else {
					lancamento.setValor(vlrParcela);
					lancamento.setStatus("a");
					lancamento.setVencimento(Util.parseDate(data));
					lancamento.setEmissao(vencimento);
					lancamento.setValorPago(0);
				}				
				session.save(lancamento);
				id = new ParcelaOrcamentoId();
				id.setLancamento(lancamento);
				id.setOrcamento(orcamento);
				
				parcela = new ParcelaOrcamento();
				parcela.setId(id);
				parcela.setBeneficiario("c");
				parcela.setSequencial(new Long(i + 1));
				session.save(parcela);
				
				if (mes >= 12) {
					mes = 1;
					ano++;
				} else {
					mes++;
				}
			}
			if (orcamento.getUsuario().getPlano().getTipo().equals("l")) {
				query = session.createQuery("from ItensOrcamento as i where i.id.orcamento = :orcamento");
				query.setEntity("orcamento", orcamento);
				itensOrcamento = (List<ItensOrcamento>) query.list();
				for (ItensOrcamento iten : itensOrcamento) {
					query = session.createQuery("from PlanoServico as p " +
							" where p.id.plano = :plano " +
							" and p.id.servico = :servico");
					query.setEntity("plano", orcamento.getUsuario().getPlano());
					query.setEntity("servico", iten.getTabela().getServico());
					if (query.list().size() > 0) {
						planoServico = (PlanoServico) query.uniqueResult();
						if (orcamento.getDependente() == null) {
							query = session.createQuery("from Score as s " + 
									" where s.validade > current_date " + 
									" and s.usuario = :usuario " + 
									" and s.servico = :servico");
						} else {
							query = session.createQuery("from Score as s " + 
									" where s.validade > current_date " + 
									" and s.usuario.codigo = :usuario " + 
									" and s.servico.codigo = :servico " +
									" and s.dependente.codigo = :dependente");
							query.setLong("dependente", orcamento.getDependente().getCodigo());
						}
						query.setLong("usuario", orcamento.getUsuario().getCodigo());
						query.setLong("servico", iten.getTabela().getServico().getCodigo());
						if (query.list().size() > 0) {
							score = (Score) query.uniqueResult();
							qtde = score.getQtde();
							if ((score.getQtde() + iten.getQtde()) <= planoServico.getQtde()) {
								score.setQtde(qtde + iten.getQtde());
							} else {
								score.setQtde(planoServico.getQtde() - qtde);
							}							
						} else {
							score = new Score();
							score.setDependente(orcamento.getDependente());
							score.setUsuario(orcamento.getUsuario());
							score.setServico(iten.getTabela().getServico());
							score.setValidade(orcamento.getUsuario().getRenovacao());
							if (iten.getQtde() <= planoServico.getQtde()) {
								score.setQtde(iten.getQtde());								
							} else {
								score.setQtde(planoServico.getQtde());
							}
						}
						session.saveOrUpdate(score);
					}
				}
			}			
			session.flush();
			transaction.commit();			
		} catch (Exception e) {			
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return false;
		}
		return true;
	}
	
	private boolean editObs(HttpServletRequest request) {
		try {
			session = HibernateUtil.getSession();
			transaction= session.beginTransaction();
			query = session.createQuery("from Orcamento as o where o.codigo = :codigo");
			query.setLong("codigo", Long.valueOf(request.getParameter("orcamento")));					
			orcamento = (Orcamento) query.uniqueResult();
			orcamento.setObservacao(Util.encodeString(request.getParameter("obs"), "ISO-8859-1", "UTF8"));
			session.update(orcamento);
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return false;
		}
		return true;
	}
	
	private String checkUser(HttpServletRequest request) {		
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		String result = "1";
		Date now = new Date();
		try {
			String user = request.getSession().getAttribute("username").toString();
			pipe = Util.unmountPipeline(request.getParameter("pipe"));			
			for (Long pp : pipe) {
				lancamento = (Lancamento) session.get(Lancamento.class, pp);
				if (lancamento.getStatus().equals("a")) {
					result = "4";
					break;
				} else if (request.getSession().getAttribute("perfil").equals("f")
						|| request.getSession().getAttribute("perfil").equals("d")
						|| request.getSession().getAttribute("perfil").equals("a")) {
					
					break;
				} else if (lancamento.getRecebimento() == null) {
					result = "2";
					break;
				} else if (!lancamento.getRecebimento().equals(user)) {
					result = "2";
					break;
				} else if (Math.abs(Util.diferencaDias(now, Util.getZeroDate(lancamento.getDataQuitacao()))) > 0) {
					result = "3";
					break;
				}
			}
			transaction.commit();
			session.close();			
		} catch (Exception e) {
			e.printStackTrace();
			result = "0";
			transaction.rollback();
			session.close();
		}
		return result;
	}
	
	private String reparcela(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		double valorAtual = 0;
		Date now = new Date();
		int sequencial = 1;
		try {			
			query = session.createQuery("from ParcelaOrcamento as p where p.id.lancamento.codigo = :lancamento");
			query.setLong("lancamento", Long.valueOf(request.getParameter("lancamento")));
			parcela = (ParcelaOrcamento) query.uniqueResult();
			query = session.createQuery("select count(p) from ParcelaOrcamento as p " +
					"where p.id.orcamento= :orcamento");
			query.setEntity("orcamento", parcela.getId().getOrcamento());
			sequencial += Integer.parseInt(query.uniqueResult().toString());
			valorAtual = parcela.getId().getLancamento().getValor();
			int parcelamento = parcela.getId().getOrcamento().getParcelas();			
			parcela.getId().getOrcamento().setParcelas(++parcelamento);
			session.update(parcela.getId().getOrcamento());
			
			lancamento = new Lancamento();
			lancamento.setConta(parcela.getId().getLancamento().getConta());
			lancamento.setDocumento("reparcelamento lanç.:" + 
					parcela.getId().getLancamento().getCodigo());
			lancamento.setEmissao(now);
			lancamento.setJuros(parcela.getId().getLancamento().getJuros());
			lancamento.setMulta(parcela.getId().getLancamento().getMulta());
			lancamento.setStatus("a");
			lancamento.setTaxa(parcela.getId().getLancamento().getTaxa());
			lancamento.setTipo(parcela.getId().getLancamento().getTipo());
			lancamento.setUnidade(parcela.getId().getLancamento().getUnidade());
			lancamento.setValor(Double.parseDouble(request.getParameter("valor")));
			lancamento.setVencimento(Util.parseDate(request.getParameter("vencimento")));
			
			session.save(lancamento);			
			parcela.getId().getLancamento().setValor(valorAtual - lancamento.getValor());			
			session.update(parcela.getId().getLancamento());
			
			id = new ParcelaOrcamentoId();
			id.setLancamento(lancamento);
			id.setOrcamento(parcela.getId().getOrcamento());
						
			parcela = new ParcelaOrcamento();
			parcela.setBeneficiario("c");
			parcela.setSequencial(new Long(sequencial));
			parcela.setId(id);
			
			session.save(parcela);
			
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "1@Não foi possível efetuar o reparcelamento devido a um erro interno!";
		}
		return "0@Reparcelamento efetuado com sucesso!"; 
	}
}