package com.marcsoftware.gateway;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.Servlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.BoletoMensalidade;
import com.marcsoftware.database.Conciliacao;
import com.marcsoftware.database.Dependente;
import com.marcsoftware.database.FormaPagamento;
import com.marcsoftware.database.ItensConciliacao;
import com.marcsoftware.database.ItensConciliacaoId;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Mensalidade;
import com.marcsoftware.database.Orcamento;
import com.marcsoftware.database.Pessoa;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

public class MensalidadeAdapter extends HttpServlet implements Servlet {
	static final long serialVersionUID = 1L;
	private Lancamento lancamento;
	private Pessoa pessoa;
	private Unidade unidade;
	private Mensalidade mensalidade;
	private Usuario usuario;
	private TipoConta conta;
	private List<Mensalidade> mensalidadeList;
	private ArrayList<Long> pipe;
	private FormaPagamento pagamento;
	private Conciliacao conciliacao;
	private ItensConciliacao itens;
	private ItensConciliacaoId conciliacaoId;
	private int option, mes, ano, dia, atrasadas;
	private PrintWriter out;
	private Session session;
	private Transaction transaction;
	private Query query;
	private Date now, nextDate;
	private double valor, totalAtraso, troco;
	
	public MensalidadeAdapter() {
		super();
	}
	
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		try {
			if (request.getParameter("from").trim().equals("2")) {
				response.setContentType("text/plain");
				response.setCharacterEncoding("ISO-8859-1");
				out = response.getWriter();
				out.print(editObs(request));
				out.close();
			} else if (request.getParameter("from").trim().equals("9")){
				if (updateRecord(request)) {
					session.close();					
					response.sendRedirect("GeradorRelatorio?rel=" + request.getParameter("rel") + 
							"&parametros=" + request.getParameter("param") + "@" + 
							request.getParameter("pipe").replace("@", ","));
				} else {
 					response.sendRedirect("error_page.jsp?errorMsg=Ocorreu um erro durante a renovação!" + 
						"&lk=#");
				}				
			} else if (request.getParameter("from").trim().equals("8")){
				response.setContentType("text/plain");
				response.setCharacterEncoding("ISO-8859-1");
				out = response.getWriter();
				out.print(checkMensalidade(request));
				out.close();
			} else if (request.getParameter("from").trim().equals("11")){
				response.setContentType("text/plain");
				response.setCharacterEncoding("ISO-8859-1");
				out = response.getWriter();
				out.print(editVias(request));
				out.close();
			} else {
				if (updateRecord(request)) {
					response.setContentType("text/html");
					response.setCharacterEncoding("ISO-8859-1");
					out = response.getWriter();
					transaction = session.beginTransaction();
					request.setCharacterEncoding("ISO-8859-1");
					query= session.createQuery("from Mensalidade as m where m.usuario.codigo= :codigo and m.vigencia = :vigencia order by m.lancamento.vencimento");
					query.setLong("codigo", Long.valueOf(request.getParameter("userId")));
					query.setLong("vigencia", Long.valueOf(request.getParameter("vigencia")));
					mensalidadeList = (List<Mensalidade>) query.list();
					DataGrid dataGrid= new DataGrid(null);
					int gridLines= mensalidadeList.size();
					dataGrid.addColum("10", "Descrição");
					dataGrid.addColum("10", "Vencimento");
					dataGrid.addColum("3", "Parc.");
					dataGrid.addColum("10", "Dt. Pagamento");
					dataGrid.addColum("23", "Usuário");
					dataGrid.addColum("10", "Valor");
					dataGrid.addColum("5", "Multa");
					dataGrid.addColum("5", "Taxa");
					dataGrid.addColum("10", "Receb.");
					dataGrid.addColum("5", "Status");
					dataGrid.addColum("1", "St.");
					dataGrid.addColum("5", "Ck");
					int parcelas = -1;
					totalAtraso = 0;
					atrasadas = 0;
					now = new Date();
					for(Mensalidade mes: mensalidadeList) {
						dataGrid.setId(String.valueOf(mes.getLancamento().getCodigo()));												
						parcelas++;						
						
						dataGrid.addData(Util.initCap(mes.getLancamento().getConta().getDescricao()));
						
						dataGrid.addData("vencMensGd",
								Util.parseDate(mes.getLancamento().getVencimento(),
								"dd/MM/yyyy"));
						
						dataGrid.addData(String.valueOf(parcelas));
						
						dataGrid.addData((mes.getLancamento().getDataQuitacao()== null)? "" :
							Util.parseDate(mes.getLancamento().getDataQuitacao(), "dd/MM/yyyy"));
						
						dataGrid.addData((mes.getLancamento().getRecebimento() == null) ? "" :
							mes.getLancamento().getRecebimento());
						
						dataGrid.addData("valSimplesGd", String.valueOf(Util.formatCurrency(mes.getLancamento().getValor())));
						dataGrid.addData(mes.getLancamento().getMulta() + "%");
						dataGrid.addData(mes.getLancamento().getTaxa() + "%");
						
 						if (mes.getLancamento().getStatus().trim().equals("q")) {
							dataGrid.addData("valRecebGd", Util.formatCurrency(mes.getLancamento().getValorPago()));
						} else {
							if (mes.getLancamento().getVencimento().before(now)
									&& (!mes.getLancamento().getStatus().trim().equals("c"))) {
								atrasadas++;
								totalAtraso+= Util.calculaAtraso(
										mes.getLancamento().getValor(), 
										mes.getLancamento().getTaxa(),
										mes.getLancamento().getMulta(),
										mes.getLancamento().getVencimento());
							}
							dataGrid.addData("valRecebGd",
									Util.formatCurrency(Util.calculaAtraso(
											mes.getLancamento().getValor(), 
											mes.getLancamento().getTaxa(),
											mes.getLancamento().getMulta(),
											mes.getLancamento().getVencimento()))
							);
						}
						
						dataGrid.addData(Util.getStatus(mes.getLancamento().getVencimento(),
								mes.getLancamento().getStatus()));
						
						if(mes.getLancamento().getStatus().equals("e")) {
							dataGrid.addImg("../image/estorno.png");
						} else {
							dataGrid.addImg(Util.getIcon(mes.getLancamento().getVencimento(), 
									mes.getLancamento().getStatus()));
						}
						
						dataGrid.addCheck(true);
						
						dataGrid.addRow();
					}
					dataGrid.addTotalizador("Total", Util.formatCurrency(totalAtraso), true);
					dataGrid.addTotalizador("Parcelas em Atraso", String.valueOf(atrasadas), false);
					dataGrid.makeTotalizador();
					dataGrid.addTotalizadorRight("Total a Pagar", "0.00", "totalSoma");
					dataGrid.makeTotalizadorRight();					
					out.print(dataGrid.getTable(gridLines));
					transaction.commit();
					session.close();
					out.close();
				} else {
					out.print("0");
					//transaction.rollback();
					//session.close();
					out.close();
				}
			}
		} catch (Exception e) {
			out.print("0");
			e.printStackTrace();
			transaction.rollback();
			session.close();
		}
		
		
	}
	
	private boolean updateRecord(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction= session.beginTransaction(); 
		option = Integer.parseInt(request.getParameter("from"));
		try {
			switch (option) {
			//Estorno de mensalidades
			case 0:
				now = new Date();
				pipe= Util.unmountPipeline(request.getParameter("pipe"));
				conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("48"));
				for (Long pp : pipe) {
					query = session.createQuery("from Mensalidade as m where m.lancamento.codigo = :codigo");
					query.setLong("codigo", pp);
					mensalidade = (Mensalidade) query.uniqueResult();
					if (mensalidade.getLancamento().getStatus().equals("q")) {						
						lancamento = new Lancamento();
						lancamento.setConta(conta);
						lancamento.setDataQuitacao(now);
						lancamento.setDocumento("ctr: " + 
								mensalidade.getUsuario().getContrato().getCtr() +
								" mens: " + mensalidade.getCodigo());
						lancamento.setEmissao(now);
						lancamento.setJuros(0);
						lancamento.setMulta(0);
						lancamento.setRecebimento(request.getSession().getAttribute("username").toString());
						lancamento.setStatus("q");
						lancamento.setTaxa(0);
						lancamento.setTipo("d");
						lancamento.setUnidade(mensalidade.getLancamento().getUnidade());
						lancamento.setValor(mensalidade.getLancamento().getValorPago());
						lancamento.setValorPago(mensalidade.getLancamento().getValorPago());
						lancamento.setVencimento(now);
						session.save(lancamento);
						
						lancamento = new Lancamento();
						lancamento.setConta(conta);
						lancamento.setDataQuitacao(mensalidade.getLancamento().getDataQuitacao());
						lancamento.setDocumento("ctr: " + 
								mensalidade.getUsuario().getContrato().getCtr() +
								" mens: " + mensalidade.getCodigo());
						lancamento.setEmissao(now);
						lancamento.setJuros(0);
						lancamento.setMulta(0);
						lancamento.setRecebimento(mensalidade.getLancamento().getRecebimento());
						lancamento.setStatus("q");
						lancamento.setTaxa(0);
						lancamento.setTipo("c");
						lancamento.setUnidade(mensalidade.getLancamento().getUnidade());
						lancamento.setValor(mensalidade.getLancamento().getValorPago());
						lancamento.setValorPago(mensalidade.getLancamento().getValorPago());
						lancamento.setVencimento(mensalidade.getLancamento().getVencimento());
						session.save(lancamento);
						
						mensalidade.getLancamento().setDataQuitacao(now);
						mensalidade.getLancamento().setStatus("e");
						mensalidade.getLancamento().setValorPago(0);
						session.update(mensalidade.getLancamento());
					}
				}
				break;
				
			//pagamento de parcelas
			case 1:
				pipe= Util.unmountPipeline(request.getParameter("pipe"));				
				now = new Date();
				troco = Double.parseDouble(request.getParameter("troco"));
				pagamento = (FormaPagamento) session.get(FormaPagamento.class, 
						Long.valueOf(Util.getPart(request.getParameter("formaPag"), 1)));				
				
				if (pagamento.getConcilia().equals("s")) {
					conciliacao = new Conciliacao();
					conciliacao.setEmissao(Util.parseDate(request.getParameter("emissao")));
					conciliacao.setFormaPagamento(pagamento);
					conciliacao.setNumero(Util.encodeString(request.getParameter("numeroConcilio"), "ISO-8859-1", "UTF-8"));
					conciliacao.setVencimento(Util.parseDate(request.getParameter("vencimentoConcilia")));
					conciliacao.setStatus("a");
					session.save(conciliacao);
					if (troco > 0) {
						conta = (TipoConta) session.get(TipoConta.class, new Long(69));
						unidade = (Unidade) session.get(Unidade.class, Long.valueOf(request.getSession().getAttribute("unidade").toString()));
						lancamento = new Lancamento();
						lancamento.setConta(conta);
						lancamento.setEmissao(now);
						lancamento.setDataQuitacao(now);						
						lancamento.setJuros(0);
						lancamento.setMulta(0);
						lancamento.setRecebimento((String) request.getSession().getAttribute("username"));
						lancamento.setDocumento("Conciliação: " + conciliacao.getCodigo());
						lancamento.setStatus("q");
						lancamento.setTaxa(0);
						lancamento.setTipo("d");
						lancamento.setUnidade(unidade);
						lancamento.setValor(troco);
						lancamento.setValorPago(troco);
						lancamento.setVencimento(now);
						session.save(lancamento);
						
						conta = (TipoConta) session.get(TipoConta.class, new Long(70));						
						lancamento = new Lancamento();
						lancamento.setConta(conta);
						lancamento.setEmissao(now);
						lancamento.setDataQuitacao(now);
						lancamento.setJuros(0);
						lancamento.setMulta(0);
						lancamento.setRecebimento((String) request.getSession().getAttribute("username"));
						lancamento.setDocumento("Conciliação: " + conciliacao.getCodigo());
						lancamento.setStatus("q");
						lancamento.setTaxa(0);
						lancamento.setTipo("c");
						lancamento.setUnidade(unidade);
						lancamento.setValor(troco);
						lancamento.setValorPago(troco);
						lancamento.setVencimento(now);
						session.save(lancamento);
						
						itens = new ItensConciliacao();
						conciliacaoId = new ItensConciliacaoId();
						conciliacaoId.setConciliacao(conciliacao);
						conciliacaoId.setLancamento(lancamento);
						itens.setId(conciliacaoId);
						itens.setDocDigital("n");
						session.save(itens);
					}
				}
				for (Long pp : pipe) {
					query = session.createQuery("from Mensalidade as m where m.lancamento.codigo = :codigo");
					query.setLong("codigo", pp);
					mensalidade= (Mensalidade) query.uniqueResult();
					if (!mensalidade.getLancamento().getStatus().equals("q")) {
						if (pagamento.getConcilia().equals("s")) {
							valor= Double.parseDouble(request.getParameter("totalPagar")) / pipe.size();
						} else {
							valor = (request.getParameter("juros").trim().equals("s"))?
									Util.calculaAtraso(mensalidade.getLancamento().getValor(), 
											mensalidade.getLancamento().getTaxa(), 
											mensalidade.getLancamento().getMulta(), 
											mensalidade.getLancamento().getVencimento()) 
											: mensalidade.getLancamento().getValor();
						}
						if (request.getParameter("cobBoleto").equals("s")) {
							valor+= 2;
						}
						mensalidade.getLancamento().setRecebimento((String) request.getSession().getAttribute("username"));
						mensalidade.getLancamento().setDataQuitacao(now);
						mensalidade.getLancamento().setStatus("q");
						mensalidade.getLancamento().setValorPago(valor);
						mensalidade.getLancamento().setDocumento("ctr: " + 
								mensalidade.getUsuario().getContrato().getCtr() +
								" mens: " + mensalidade.getCodigo());
						session.update(mensalidade.getLancamento());
						
						if (pagamento.getConcilia().equals("s")) {
							itens = new ItensConciliacao();
							conciliacaoId = new ItensConciliacaoId();
							conciliacaoId.setConciliacao(conciliacao);
							conciliacaoId.setLancamento(mensalidade.getLancamento());
							itens.setId(conciliacaoId);
							session.save(itens);
						}
					}					
				}
				break;
			
			//Negociação de mensalidades
			case 3:
				pipe= Util.unmountPipeline(request.getParameter("pipe"));
				
				valor = Double.parseDouble(request.getParameter("desconto"));
				for (Long pp : pipe) {
					query = session.createQuery("from Lancamento as l where l.codigo = :codigo");
					query.setLong("codigo", pp);
					lancamento= (Lancamento) query.uniqueResult();
					if (lancamento.getStatus().equals("a") || lancamento.getStatus().equals("n")) {
						lancamento.setRecebimento((String) request.getSession().getAttribute("username"));
						lancamento.setDataQuitacao(null);
						lancamento.setStatus("n");
						lancamento.setValorPago(0);
						
						if (request.getParameter("sim").trim().equals("s")) {
							valor = lancamento.getValor() - valor;
							lancamento.setValor(valor);
						} else {
							valor= Util.calculaAtraso(lancamento.getValor(), 
									lancamento.getTaxa() + 2, 
									lancamento.getVencimento()) - valor;
							lancamento.setValor(valor);
						}
						
						if (request.getParameter("vencimento").trim().equals("")) {
							now = new Date();
							lancamento.setVencimento(now);							
						} else {
							lancamento.setVencimento(
									Util.parseDate(request.getParameter("vencimento")));
						}	
						valor = Double.parseDouble(request.getParameter("desconto"));
						session.update(lancamento);
					}					
				}		
				break;
			
			//adição de mensalidades 
			case 4:
				now = new Date();
				query = session.createQuery("from Unidade as u where u.codigo = :codigo");
				query.setLong("codigo", Long.valueOf(request.getParameter("unidadeId")));
				unidade= (Unidade) query.uniqueResult();
				conta = (TipoConta) session.get(TipoConta.class, Long.valueOf(request.getParameter("tipoLancamento")));
				
				query = session.createQuery("from Usuario as u where u.codigo = :codigo");
				query.setLong("codigo", Long.valueOf(request.getParameter("userId")));
				usuario = (Usuario) query.uniqueResult();
				nextDate = Util.parseDate(request.getParameter("vencimento"));				
				for (int i = 0; i < Integer.parseInt(request.getParameter("qtde")); i++) {					
					lancamento = new Lancamento();
					//lancamento.setDescricao("mensalidade");
					lancamento.setEmissao(now);
					lancamento.setStatus("a");
					lancamento.setTaxa(Double.parseDouble(request.getParameter("taxa")));
					lancamento.setMulta(2);
					lancamento.setTipo("c");
					lancamento.setUnidade(unidade);
					lancamento.setValor(Double.parseDouble(request.getParameter("valor")));
					lancamento.setVencimento(nextDate);
					lancamento.setConta(conta);
					session.save(lancamento);
					
					mensalidade = new Mensalidade();
					mensalidade.setVigencia(Long.valueOf(request.getParameter("vigencia")));
					mensalidade.setLancamento(lancamento);
					mensalidade.setUsuario(usuario);
					session.save(mensalidade);
					nextDate = Util.addMonths(nextDate, 1);
				}
				break;
				
			//canncelamento de mensalidadas
			case 5:
				pipe = Util.unmountPipeline(request.getParameter("pipe"));
				for (Long pp : pipe) {
					query = session.createQuery("from Lancamento as l where l.codigo = :codigo");
					query.setLong("codigo", pp);
					lancamento = (Lancamento) query.uniqueResult();
					lancamento.setStatus("c");
					lancamento.setValorPago(0);
					session.update(lancamento);
				}
				break;
			
			// exclusão de mensalidade
			case 6:
				pipe = Util.unmountPipeline(request.getParameter("pipe"));
				for (Long pp : pipe) {
					query = session.createQuery("from Mensalidade as m where m.lancamento.codigo = :codigo");
					query.setLong("codigo", pp);
					mensalidade = (Mensalidade) query.uniqueResult();
					lancamento = mensalidade.getLancamento();					
					session.delete(mensalidade);
					session.delete(lancamento);
				}				
				break;
				
			case 9:
				usuario = (Usuario)
				session.get(Usuario.class, Long.valueOf(request.getParameter("usuario")));
				Date nextGeracao = new Date();
				BoletoMensalidade boleto = null;
				String sql = "from Mensalidade as m " +
						" where m.lancamento.status in ('a', 'e', 'n')" +
						"and m.lancamento.codigo not in(";
				sql += request.getParameter("pipe").replace("@", ",");
				sql += " ) and m.usuario = :usuario order by m.lancamento.vencimento";
				if (usuario.getPagamento().getCodigo() == new Long(1)) {
					query = session.createQuery(sql);
					query.setEntity("usuario", usuario);
					if (query.list().size() > 0) {
						mensalidadeList = (List<Mensalidade>) query.list();
						nextGeracao = mensalidadeList.get(0).getLancamento().getVencimento();
						
						query = session.createQuery("from BoletoMensalidade as m " +
						" where m.usuario = :usuario");
						query.setEntity("usuario", usuario);
						if (query.list().size() > 0) {
							boleto = (BoletoMensalidade) query.uniqueResult();
							boleto.setData(nextGeracao);
						} else {
							boleto = new BoletoMensalidade();
							boleto.setData(nextGeracao);
							boleto.setUsuario(usuario);
						}
						session.saveOrUpdate(boleto);
					} else {
						query = session.createQuery("from BoletoMensalidade as m " +
						" where m.usuario = :usuario");
						query.setEntity("usuario", usuario);						
						boleto = (BoletoMensalidade) query.uniqueResult();
						if (boleto != null) {
							session.delete(boleto);
						}
					}
				} else {
					transaction.rollback();
					return true;
				}
				break;				
			}			
			session.flush();
			transaction.commit();			
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			return false;
		}		
		return true;
	}
	
	private String editObs(HttpServletRequest request) {
		try {
			session = HibernateUtil.getSession();
			transaction= session.beginTransaction();
			pessoa = (Pessoa) session.load(Pessoa.class, 
					Long.valueOf(request.getParameter("usuario")));
			pessoa.setObservacao(Util.encodeString(request.getParameter("obs"), "ISO-8859-1", "UTF8"));
			session.update(pessoa);
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {			
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "0";
		}
		return pessoa.getObservacao();
	}
	
	private String checkMensalidade(HttpServletRequest request) {
		String aux = "o";
		Date now = new Date();
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			pipe = Util.unmountPipeline(request.getParameter("pipe"));
			for (Long pp : pipe) {
				query = session.createQuery("from Mensalidade as m where m.lancamento.codigo = :lancamento");
				query.setLong("lancamento", pp);				
				mensalidade = (Mensalidade) query.uniqueResult();				
				if (mensalidade.getLancamento().getStatus().trim().equals("a")) {
					aux = "r";
					break;
				} else if((!mensalidade.getLancamento().getRecebimento().trim().equals(						 
						request.getSession().getAttribute("username").toString()))
						&& (!(request.getSession().getAttribute("perfil").toString().equals("a")
								|| request.getSession().getAttribute("perfil").toString().equals("d")
								|| request.getSession().getAttribute("perfil").toString().equals("f")))) {
					aux = "u";
					break;
				} else if ((Util.diferencaDias(now, mensalidade.getLancamento().getDataQuitacao()) != 0)
						&& (!(request.getSession().getAttribute("perfil").toString().equals("a")
								|| request.getSession().getAttribute("perfil").toString().equals("d")
								|| request.getSession().getAttribute("perfil").toString().equals("f")))) {
					aux = "a";
					break;
				}
			}
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
		}
		return aux;
	}
		
	private String editVias(HttpServletRequest request) {
		String result = "";
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		Usuario usuario = null;
		Dependente dependente = null;
		try {
			if (request.getParameter("isDependente").equals("t")) {
				dependente = (Dependente) session.load(Dependente.class, Long.valueOf(request.getParameter("id")));
				dependente.setCarteirinha(Integer.parseInt(request.getParameter("vias")));
				session.update(dependente);
				result = String.valueOf(dependente.getCarteirinha());
			} else {
				usuario = (Usuario) session.load(Usuario.class, 
						Long.valueOf(request.getParameter("id")));
				usuario.setCarteirinha(Integer.parseInt(request.getParameter("vias")));			
				session.update(usuario);			
				result = String.valueOf(usuario.getCarteirinha());
			}
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();			
			result = "-1";
		} finally {
			session.close();
		}
		return result;
	}
	
}