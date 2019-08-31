package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.BorderoProfissional;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.ItensBordero;
import com.marcsoftware.database.ItensOrcamento;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Orcamento;
import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.database.ParcelaOrcamentoId;
import com.marcsoftware.database.Profissional;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroBordero
 */
public class CadastroBordero extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private int  limit, offSet, gridLines;
	private double valor;
	private boolean isFilter;
	private Date now;
	private List<ParcelaOrcamento> parcelaList;	
	private List<ItensOrcamento> itens;	
	private List<ItensBordero> itensBordero;
	private Profissional profissional;
	private TipoConta conta;
	private Lancamento lancamento;
	private DataGrid dataGrid;
	private Filter filter;		
	private PrintWriter out;
	private Session session;
	private Query query;
	private Transaction transaction;
    
    public CadastroBordero() {
        super();
    }

	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		session = HibernateUtil.getSession();				
		try {
			if (request.getParameter("from").trim().equals("1")) {
					response.setContentType("text/plain");
					response.setCharacterEncoding("ISO-8859-1");
					out = response.getWriter();
					out.print(estorneFatura(request));
					session.close();
					out.close();
					return;				
			} else if (request.getParameter("from").trim().equals("2")) {
				if (!deleteFatura(request)) {
					response.setContentType("text/html");
					response.setCharacterEncoding("ISO-8859-1");
					session.close();
					out = response.getWriter();
					out.print("<tr><td></td><td><p>" + 
							"Ocorreu um erro durante a exclusão da fatura!" + 
							"</p></td></tr>"
						);
					out.close();
					return;
				}
			}
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			out = response.getWriter();
			isFilter= request.getParameter("isFilter") == "1";
			mountFilter(request);
			transaction= session.beginTransaction();
			limit= Integer.parseInt(request.getParameter("limit"));
			offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
			query = filter.mountQuery(query, session);
			gridLines= query.list().size();
			query.setFirstResult(offSet);
			query.setMaxResults(limit);		
			parcelaList= (List<ParcelaOrcamento>) query.list();
			if (parcelaList.size() == 0) {
				out.print("<tr><td></td><td></td><td><p>" + 
						"Nenhum registro encontrado.</p></td></tr>"
					);
				transaction.commit();
				session.close();
				out.close();
				return;
			}
			dataGrid= new DataGrid("#");
			for (ParcelaOrcamento parc: parcelaList) {
				valor = 0;
				query = session.createQuery("from ItensOrcamento as i where i.id.orcamento = :orcamento");
				query.setEntity("orcamento", parc.getId().getOrcamento());
				itens = (List<ItensOrcamento>) query.list();
				for(ItensOrcamento it: itens) {
					query = session.createQuery("select operacional from Tabela as t where t.codigo = :codigo and t.aprovacao = 's'");
					query.setLong("codigo", it.getTabela().getCodigo());
					valor+= it.getQtde() * ((Double) query.uniqueResult());
				}
				valor = valor / parc.getId().getOrcamento().getParcelas();
				
				profissional = (Profissional) session.get(Profissional.class, parc.getId().getOrcamento().getPessoa().getCodigo());
				
				dataGrid.setId(String.valueOf(parc.getId().getLancamento().getCodigo()));
				dataGrid.addData(String.valueOf(parc.getId().getOrcamento().getCodigo()));
				dataGrid.addData(String.valueOf(parc.getId().getLancamento().getCodigo()));
				dataGrid.addData(Util.initCap(profissional.getNome()));
				if (parc.getId().getOrcamento().getDependente() == null) {
					dataGrid.addData(parc.getId().getOrcamento().getUsuario().getReferencia() +	"-0");
					dataGrid.addData(parc.getId().getOrcamento().getUsuario().getNome());
				} else {
					dataGrid.addData(parc.getId().getOrcamento().getUsuario().getReferencia() + 
							"-" + parc.getId().getOrcamento().getDependente().getReferencia());
					dataGrid.addData(parc.getId().getOrcamento().getDependente().getNome());
				}
				dataGrid.addData(
						Util.parseDate(parc.getId().getLancamento().getEmissao(), "dd/MM/yyyy"));
				
				if (Util.getDayDate(parc.getId().getLancamento().getEmissao()) > 25) {
					if (Util.getMonthDate(parc.getId().getLancamento().getEmissao()) == 12) {
						dataGrid.addData("25/01/" + (Util.getYearDate(parc.getId().getLancamento().getEmissao()) + 1));
					} else {
						dataGrid.addData("25/" + (Util.getMonthDate(parc.getId().getLancamento().getEmissao()) + 1) +
								"/" + Util.getYearDate(parc.getId().getLancamento().getEmissao()));
					}
				} else {
					dataGrid.addData("25/" + Util.getMonthDate(parc.getId().getLancamento().getEmissao())+
							"/" + Util.getYearDate(parc.getId().getLancamento().getEmissao()));
				}
				dataGrid.addData(Util.initCap(profissional.getNome()));
				dataGrid.addData(Util.formatCurrency(valor));														
				dataGrid.addCheck();
				dataGrid.addRow();
			}
			out.print(dataGrid.getBody(gridLines));
			transaction.commit();
			session.close();
			out.close();			
		} catch (Exception e) {
			out.print("0");
			transaction.rollback();
			session.close();		
		}
	}
	
	private String estorneFatura(HttpServletRequest request) {
		transaction = session.beginTransaction();
		try {
			query = session.getNamedQuery("operacionalQuit");
			query.setLong("bordero", Long.valueOf(request.getParameter("bordero")));
			if (Integer.parseInt(query.uniqueResult().toString()) != 0) {
				query = session.createQuery("from ItensBordero as i " +
				"where i.id.borderoProfissional.codigo = :bordero");
				query.setLong("bordero", Long.valueOf(request.getParameter("bordero")));
				itensBordero = (List<ItensBordero>) query.list();
				conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("48"));
				now = new Date();
				for (ItensBordero iten : itensBordero) {
					iten.getId().getCliente().setStatus("f");
					session.update(iten.getId().getCliente());
					
					iten.getOperacional().setConta(conta);
					iten.getOperacional().setDocumento("fatura: " + request.getParameter("bordero") + 
							" Profiss: " + iten.getId().getBorderoProfissional().getPessoa().getCodigo());
					lancamento = new Lancamento();
					lancamento.setConta(iten.getOperacional().getConta());
					lancamento.setDataQuitacao(now);
					lancamento.setDocumento(iten.getOperacional().getDocumento());
					lancamento.setEmissao(now);
					lancamento.setJuros(iten.getOperacional().getJuros());
					lancamento.setMulta(iten.getOperacional().getMulta());
					lancamento.setRecebimento(request.getSession().getAttribute("username").toString());
					lancamento.setStatus("q");
					lancamento.setTaxa(iten.getOperacional().getTaxa());
					lancamento.setTipo("c");
					lancamento.setUnidade(iten.getOperacional().getUnidade());
					lancamento.setValor(iten.getOperacional().getValor());
					lancamento.setValorPago(iten.getOperacional().getValorPago());
					lancamento.setVencimento(now);
					session.save(lancamento);
					session.update(iten.getOperacional());
				}
				session.flush();
			} else {
				transaction.commit();
				return "Não é possível estornar uma fatura em aberto!";
			}			
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
			return "Ocorreu um erro durante o estorno!";
		}
		return "Estorno realizado com sucesso!";
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		 
	}
	
	public boolean deleteFatura(HttpServletRequest request) {		
		
		return true;
	}
	
	
	private void mountFilter(HttpServletRequest request) {				
		filter = new Filter("from ParcelaOrcamento as p " + 
			"where p.id.lancamento.status = 'q' " +
			"and p.id.lancamento.tipo = 'c' ");
		if (!request.getParameter("orcamento").equals("")) {
			filter.addFilter("p.id.orcamento.codigo = :orcamento",
					Long.class, "orcamento", Long.valueOf(request.getParameter("orcamento")));
		}
		if (!request.getParameter("lancamento").equals("")) {
			filter.addFilter("p.id.lancamento.codigo = :lancamento",
					Long.class, "lancamento", Long.valueOf(request.getParameter("lancamento")));
		}
		if (!request.getParameter("ref").equals("")) {
			filter.addFilter("p.id.orcamento.usuario.referencia = :ref",
					String.class, "ref", request.getParameter("ref"));
		}
		if (!request.getParameter("setor").equals("")) {
			filter.addFilter("p.id.orcamento.pessoa.codigo in( " +
					" select r.codigo from Profissional as r " +
					" where r.especialidade.setor = :setor)",
					String.class, "setor", request.getParameter("setor"));
		}
		if (!request.getParameter("profissional").equals("")) {
			filter.addFilter("p.id.orcamento.pessoa.codigo = :profissional",
					Long.class, "profissional", Long.valueOf(request.getParameter("profissional")));
		}		
		if (!request.getParameter("unidadeIdIn").equals("")) {			
			filter.addFilter("p.id.orcamento.pessoa.unidade.codigo = :unidade", 
					Long.class , "unidade", Integer.parseInt(request.getParameter("unidadeIdIn")));
		}
		filter.setOrder("p.id.orcamento.codigo");
	}
	
	
	
	
	
	
	
	/*private boolean pagamento(HttpServletRequest request) {
		pipe= Util.unmountPipeline(request.getParameter("pipe"));
		Date now = new Date();
		transaction = session.beginTransaction();
		try {
			for (Long pipeline : pipe) {
				query = session.createQuery("from ParcelaOrcamento as p where p.id.lancamento.codigo = :codigo");				
				query.setLong("codigo", pipeline);
				parcela = (ParcelaOrcamento) query.uniqueResult();
				query = session.createQuery("from ItensOrcamento as i where i.id.orcamento = :orcamento");
				query.setEntity("orcamento", parcela.getId().getOrcamento());
				itens = (List<ItensOrcamento>) query.list();
				valor = 0;				
				for(ItensOrcamento it: itens) {
					query = session.createQuery("select operacional from Tabela as t where t.id.unidade = :unidade and t.id.servico = :servico");
					query.setEntity("unidade", parcela.getId().getLancamento().getUnidade());
					query.setEntity("servico", it.getServico());
					valor+= it.getQtde() * ((Double) query.uniqueResult());
				}
				valor = valor / parcela.getId().getOrcamento().getParcelas();
				
				if (Util.getDayDate(parcela.getId().getLancamento().getDataQuitacao()) > 25) {
					if (Util.getMonthDate(parcela.getId().getLancamento().getDataQuitacao()) == 12) {
						vencimento = "25/01/" + (Util.getYearDate(parcela.getId().getLancamento().getDataQuitacao()) + 1);
					} else {
						vencimento = "25/" + (Util.getMonthDate(parcela.getId().getLancamento().getDataQuitacao()) + 1) +
						"/" + Util.getYearDate(parcela.getId().getLancamento().getDataQuitacao());
					}
				} else {
					vencimento = "25/" + Util.getMonthDate(parcela.getId().getLancamento().getDataQuitacao())+
					"/" + Util.getYearDate(parcela.getId().getLancamento().getDataQuitacao());
				}
				
				parcela.getId().getLancamento().setStatus("q");				
				session.update(parcela.getId().getLancamento());			
				
				lancamento = new Lancamento();
				lancamento.setEmissao(parcela.getId().getLancamento().getDataQuitacao());				
				lancamento.setDataQuitacao(now);
				lancamento.setDescricao("Pagamento Dentista");
				lancamento.setDocumento("Orç.: " + 
						parcela.getId().getOrcamento().getCodigo() + " Parc.: " +
						pipeline);
				lancamento.setRecebimento(request.getSession().getAttribute("username").toString());
				lancamento.setStatus("q");
				lancamento.setTaxa(0);
				lancamento.setTipo("d");
				lancamento.setUnidade(parcela.getId().getLancamento().getUnidade());
				lancamento.setValor(valor);
				lancamento.setValorPago(valor);
				lancamento.setVencimento(Util.parseDate(vencimento));
				session.save(lancamento);
				
				idParcela = new ParcelaOrcamentoId();				
				idParcela.setLancamento(lancamento);
				idParcela.setOrcamento(parcela.getId().getOrcamento());
				
				parcela = new ParcelaOrcamento();
				parcela.setBeneficiario("p");
				parcela.setId(idParcela);
				session.save(parcela);
			}
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			return false;
		}
		return true;
	}*/
}
