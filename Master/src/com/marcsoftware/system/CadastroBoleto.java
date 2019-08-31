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

import com.marcsoftware.database.Boleto;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.ItensBoleto;
import com.marcsoftware.database.ItensBoletoId;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Mensalidade;
import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.database.Pessoa;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroBoleto
 */
public class CadastroBoleto extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Filter filter;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CadastroBoleto() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String aux = "";
		PrintWriter out;
		String getBoleto =  String.valueOf(request.getParameter("getBoleto")).trim(); 
		switch (Integer.parseInt(request.getParameter("from"))) {
		case 0:
			response.setContentType("text/html");
			out= response.getWriter();
			Session session = HibernateUtil.getSession();
			Query query = null;
			try {
				boolean isFilter= request.getParameter("isFilter") == "1";
				mountFilter(request);			
				int limit= Integer.parseInt(request.getParameter("limit"));
				int offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
				query = filter.mountQuery(query, session);
				int gridLines= query.list().size();
				query.setFirstResult(offSet);
				query.setMaxResults(limit);		
				List<Boleto> usuarioList= (List<Boleto>) query.list();
				if (usuarioList.size() == 0) {
					out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td><td></td></tr>");				
					session.close();
					out.close();
					return;
				}
				DataGrid dataGrid= new DataGrid(null);
				for (Boleto boleto: usuarioList) {
					dataGrid.setId(String.valueOf(boleto.getCodigo()));
					dataGrid.addData(String.valueOf(boleto.getCodigo()));
					dataGrid.addData(Util.parseDate(boleto.getEmissao(), "dd/MM/yyyy"));
					dataGrid.addData(Util.parseDate(boleto.getVencimento(), "dd/MM/yyyy"));
					dataGrid.addData(Util.formatCurrency(boleto.getValor()));
					dataGrid.addImg(Util.getIcon(boleto.getVencimento(), boleto.getStatus()));
					dataGrid.addCheck(true);
					dataGrid.addRow();
				}
				session.close();
				out.print(dataGrid.getBody(gridLines));
				out.close();
				
			} catch (Exception e) {
				e.printStackTrace();
				out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td><td></td></tr>");				
				session.close();
			}
			break;
			
		case 1:
			aux = addRecord(request);
			if (Util.getPipeById(aux, 0).trim().equals("0")) {
				switch (Integer.parseInt(request.getParameter("tipo"))) {
					case 0:
						if (getBoleto.equals("s")) {
							response.sendRedirect("GeradorRelatorio?rel=135&parametros=12@" +
									Util.getPipeById(aux, 1) + "|460@" + request.getParameter("conta"));
						} else {
							response.sendRedirect("GeradorRelatorio?rel=203&parametros=464@" +
									Util.getPipeById(aux, 1) + "|465@" + request.getParameter("conta"));
						}
						break;
						
					case 1:
						if (getBoleto.equals("s")) {
							response.sendRedirect("GeradorRelatorio?rel=136&parametros=13@"+
									Util.getPipeById(aux, 1) + "|458@" + request.getParameter("conta"));
						} else {
							response.sendRedirect("GeradorRelatorio?rel=204&parametros=466@"+
									Util.getPipeById(aux, 1) + "|467@" + request.getParameter("conta"));
						}
						break;
						
					case 2:
						if (getBoleto.equals("s")) {
							response.sendRedirect("GeradorRelatorio?rel=134&parametros=11@" +
									Util.getPipeById(aux, 1) + "|459@" + request.getParameter("conta"));
						} else {
							response.sendRedirect("GeradorRelatorio?rel=205&parametros=462@" +
									Util.getPipeById(aux, 1) + "|463@" + request.getParameter("conta"));
						}
						break;
						
					case 3:
						if (getBoleto.equals("s")) {
							response.sendRedirect("GeradorRelatorio?rel=135&parametros=12@" +
									Util.getPipeById(aux, 1) + "|460@" + request.getParameter("conta"));
						} else {
							response.sendRedirect("GeradorRelatorio?rel=203&parametros=464@" +
									Util.getPipeById(aux, 1) + "|465@" + request.getParameter("conta"));
						}
						break;
						
					case 4:
						if (getBoleto.equals("s")) {
							response.sendRedirect("GeradorRelatorio?rel=136&parametros=13@"+
									Util.getPipeById(aux, 1)+ "|458@" + request.getParameter("conta"));
						} else {
							response.sendRedirect("GeradorRelatorio?rel=204&parametros=466@"+
									Util.getPipeById(aux, 1)+ "|467@" + request.getParameter("conta"));
						}
						break;
						
					case 5:
						if (getBoleto.equals("s")) {
							response.sendRedirect("GeradorRelatorio?rel=134&parametros=11@" +
									Util.getPipeById(aux, 1)+ "|459@" + request.getParameter("conta"));
						} else {
							response.sendRedirect("GeradorRelatorio?rel=205&parametros=462@" +
									Util.getPipeById(aux, 1)+ "|463@" + request.getParameter("conta"));
						}
						break;
						
					case 6:						
						response.sendRedirect("GeradorRelatorio?rel=208&parametros=478@" +
								Util.getPipeById(aux, 1)+ "|460@" + request.getParameter("conta"));
						break;
						
					default:
						response.sendRedirect("error_page.jsp?errorMsg=Não foi possível gerar o boleto devido a um erro interno!&lk=application/splash_ok.jsp");
					break;
				}
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.getPipeById(aux, 1) + "&lk=application/splash_ok.jsp");
			}
			return;
			
		case 2:
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(excluir(request));
			break;
		
		case 3:
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(cancelar(request));
			break;
			
		case 4:
			response.setContentType("text/plain");
			out = response.getWriter();
			String result = baixa(
					Util.unmountPipeline(request.getParameter("pipe")), 
					(String) request.getSession().getAttribute("username"),
					Long.valueOf(request.getSession().getAttribute("unidade").toString()));				
			out.print(Util.getPart(result , 2)) ;
			break;
		
		case 5:
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(baixarMultiplos(request));
			break;
		}
	}
	
	private String addRecord(HttpServletRequest request) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Date now = new Date();
		Boleto boleto;
		Pessoa pessoa;
		ItensBoletoId id;
		ItensBoleto itensBoleto;
		Lancamento lancamento;
		ArrayList<Long> lanc;
		String result = "";
		try {
			pessoa = (Pessoa) session.load(Pessoa.class, Long.valueOf(request.getParameter("pessoa")));
			if (request.getParameter("tipo").equals("3")
				|| request.getParameter("tipo").equals("4")
				|| request.getParameter("tipo").equals("5")) {
				String pipe = "";
				lanc = Util.unmountPipeline(request.getParameter("pipe"));
				for (Long codigo : lanc) {
					lancamento = (Lancamento) session.load(Lancamento.class, codigo);
					if (lancamento.getStatus().equals("q")
							|| lancamento.getStatus().equals("f")
							|| lancamento.getStatus().equals("c")) {
						transaction.rollback();
						session.close();
						if (lancamento.getStatus().equals("c")) {
							return "1@Não é possível gerar boletos para lançamentos cancelados!";
						} else {
							return "1@Não é possível gerar boletos para lançamentos quitados!";
						}
					}
					boleto = new Boleto();
					boleto.setEmissao(now);
					boleto.setPessoa(pessoa);
					boleto.setStatus("a");
					if (request.getParameter("maisJuros").equals("s")) {
						boleto.setValor(Util.calculaAtraso(lancamento.getValor(), 
								lancamento.getTaxa(), lancamento.getMulta(),
								lancamento.getVencimento()));						
					} else {
						boleto.setValor(lancamento.getValor());
					}
					
					boleto.setVencimento(lancamento.getVencimento());
					
					session.save(boleto);
					
					
					pipe+= (pipe.isEmpty())? boleto.getCodigo() 
							: "," + boleto.getCodigo();
					
					id = new ItensBoletoId();
					id.setBoleto(boleto);
					id.setLancamento(lancamento);
					
					itensBoleto = new ItensBoleto();
					itensBoleto.setId(id);
					itensBoleto.setValorResidente(Util.calculaAtraso(lancamento.getValor(), 
							lancamento.getTaxa(), lancamento.getMulta(),
							lancamento.getVencimento()));
					
					session.save(itensBoleto);
				}
				session.flush();
				transaction.commit();
				session.close();
				result = "0@" + pipe;				
				return result;
			} else {
				boleto = new Boleto();
				boleto.setPessoa(pessoa);
				boleto.setEmissao(now);
				boleto.setStatus("a");
				boleto.setValor(Double.parseDouble(request.getParameter("valor")));
				boleto.setVencimento(Util.parseDate(request.getParameter("vencimento")));
				session.save(boleto);
				
				lanc = Util.unmountPipeline(request.getParameter("pipe"));
				for (Long codigo : lanc) {
					lancamento = (Lancamento) session.get(Lancamento.class, codigo);
					if (lancamento.getStatus().equals("q")
							|| lancamento.getStatus().equals("f")
							|| lancamento.getStatus().equals("c")) {
						transaction.rollback();
						session.close();
						if (lancamento.getStatus().equals("c")) {
							return "1@Não é possível gerar boletos para lançamentos cancelados!";
						} else {
							return "1@Não é possível gerar boletos para lançamentos quitados!";
						}
					}
					id = new ItensBoletoId();
					id.setBoleto(boleto);
					id.setLancamento(lancamento);
					itensBoleto = new ItensBoleto();
					itensBoleto.setId(id);
					itensBoleto.setValorResidente(Util.calculaAtraso(lancamento.getValor(), 
							lancamento.getTaxa(), lancamento.getMulta(), 
							lancamento.getVencimento()));
					session.save(itensBoleto);
				}
				session.flush();
				transaction.commit();
				session.close();
				result = "0@" + boleto.getCodigo();				
			}			
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();			
			result = "1@Não foi possível gerar o boleto devido a um erro interno!";
			//result = "1@" + e.getMessage();
		}
		return result;
	}
	
	private void mountFilter(HttpServletRequest request) {
		filter = new Filter("from Boleto as b where 1 = 1");
		
		if (!request.getParameter("codigo").equals("")) {
			filter.addFilter("b.codigo = :codigo", Long.class, "codigo",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("codigo"))));
		}		
		if (!request.getParameter("codUser").equals("")) {
			filter.addFilter("b.pessoa.codigo = :pessoa", Long.class, "pessoa",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("codUser"))));
		}
		if ((!request.getParameter("EmissaoInicio").equals(""))
				&& (!request.getParameter("EmissaoFim").equals(""))) {
			filter.addFilter("b.emissao between :EmissaoInicio", java.util.Date.class, 
					"EmissaoInicio", Util.parseDate(request.getParameter("EmissaoInicio")));
			
			filter.addFilter(" :EmissaoFim", java.util.Date.class, 
					"EmissaoFim", Util.parseDate(request.getParameter("EmissaoFim")));			
		}
		if ((!request.getParameter("vencimentoInicio").equals(""))
				&& (!request.getParameter("vencimentoFim").equals(""))) {
			filter.addFilter("b.vencimento between :vencimentoInicio", java.util.Date.class, 
					"vencimentoInicio", Util.parseDate(request.getParameter("vencimentoInicio")));
			
			filter.addFilter(" :vencimentoFim", java.util.Date.class, 
					"vencimentoFim", Util.parseDate(request.getParameter("vencimentoFim")));			
		}
		filter.setOrder("b.codigo");
	}
	
	private String excluir(HttpServletRequest request) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		List<Long> pipe = Util.unmountPipeline(request.getParameter("pipe"));
		Boleto boleto;
		List<ItensBoleto> itens;
		Query query;
		try {
			for (Long codigo : pipe) {
				boleto = (Boleto) session.load(Boleto.class, codigo);
				if (boleto.getStatus().equals("q")) {
					transaction.rollback();
					session.close();
					return "Não é possível a exclusão de boletos pagos!";
				} else {
					query = session.createQuery("from ItensBoleto as i where i.id.boleto = :boleto");
					query.setEntity("boleto", boleto);
					itens = (List<ItensBoleto>) query.list();
					for (ItensBoleto iten : itens) {
						session.delete(iten);
					}
					session.delete(boleto);
				}
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível excluir os registros devido a um erro interno!";
		}
		return "Registros excluidos com sucesso!";
	}
	
	private String cancelar(HttpServletRequest request) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		List<Long> pipe = Util.unmountPipeline(request.getParameter("pipe"));
		Boleto boleto;
		try {
			for (Long codigo : pipe) {
				boleto = (Boleto) session.load(Boleto.class, codigo);
				if (boleto.getStatus().equals("q")) {
					transaction.rollback();
					session.close();
					return "Não é possível o cancelamento de boletos pagos!";
				}
				boleto.setStatus("c");
				session.update(boleto);
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Os registros não puderam ser cancelados devido a um erro interno!"; 
		}
		return "Registros cancelados com sucesso!";
	}
	
	private String baixa(ArrayList<Long> pipeList, String username, Long unidadeId) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		List<Long> pipe = pipeList;
		Boleto boleto;
		List<ItensBoleto> itens;
		ParcelaOrcamento parcelaOrcamento;
		Mensalidade mensalidade;
		Query query;
		Date now = new Date();
		Lancamento lancamento;
		TipoConta conta;
		Long unidadeBoleto;
		try {
			for (Long codigo : pipe) {
				boleto = (Boleto) session.load(Boleto.class, codigo);
				if (boleto.getStatus().equals("q")) {
					transaction.rollback();
					session.close();
					return "1@Não é possível dar baixa em boletos já pagos!";
				}
				if (boleto.getStatus().equals("c")) {
					transaction.rollback();
					session.close();
					return "1@Não é possível dar baixa em boletos cancelados!";
				}
				query = session.createQuery("from ItensBoleto as i where i.id.boleto = :boleto");
				query.setEntity("boleto", boleto);
				itens = (List<ItensBoleto>) query.list();
				for (ItensBoleto iten : itens) {
					unidadeBoleto = iten.getId().getLancamento().getUnidade().getCodigo();
					
					if (iten.getId().getLancamento().getStatus().equals("q")
							|| iten.getId().getLancamento().getStatus().equals("f")) {
						transaction.rollback();
						session.close();
						return "1@Não foi possível dar baixa pois o boleto n° " + 
							boleto.getCodigo() + " possui lançamentos pagos!";
					}
					if (iten.getId().getLancamento().getStatus().equals("c")) {
						transaction.rollback();
						session.close();
						return "1@Não foi possível dar baixa pois o boleto n° " + 
							boleto.getCodigo() + " possui lançamentos cancelados!";
					}
					if (!unidadeBoleto.equals(unidadeId)) {
						transaction.rollback();
						session.close();
						return "1@O boleto n° " + boleto.getCodigo() + " não foi encontrado!";
					}
					if (iten.getId().getLancamento().getConta().getCodigo() == 62) {
						query = session.createQuery("from ParcelaOrcamento as p where p.id.lancamento = :lancamento");
						query.setEntity("lancamento", iten.getId().getLancamento());
						parcelaOrcamento = (ParcelaOrcamento) query.uniqueResult();						
						iten.getId().getLancamento().setStatus("f");
						iten.getId().getLancamento().setEmissao(now);
						iten.getId().getLancamento().setDocumento("orç.: " + 
								parcelaOrcamento.getId().getOrcamento().getCodigo() + 
								" guia: " + parcelaOrcamento.getId().getLancamento().getCodigo());
					} else {
						query = session.createQuery("from Mensalidade as m where m.lancamento = :lancamento");
						query.setEntity("lancamento", iten.getId().getLancamento());
						mensalidade = (Mensalidade) query.uniqueResult();
						iten.getId().getLancamento().setStatus("q");
						iten.getId().getLancamento().setDocumento("ctr: " + 
								mensalidade.getUsuario().getContrato().getCodigo() +
								" mens: " + mensalidade.getCodigo());
					}
					iten.getId().getLancamento().setRecebimento("automático");
					iten.getId().getLancamento().setDataQuitacao(now);
					iten.getId().getLancamento().setValorPago(iten.getValorResidente());
					session.update(iten.getId().getLancamento());
					
					conta = (TipoConta) session.load(TipoConta.class, Long.valueOf("71"));					
					lancamento = new Lancamento();
					lancamento.setConta(conta);
					lancamento.setDataQuitacao(now);
					lancamento.setDocumento("Boleto: " + iten.getId().getBoleto().getCodigo());
					lancamento.setEmissao(now);
					lancamento.setJuros(0);
					lancamento.setMulta(0);
					lancamento.setRecebimento(username);
					lancamento.setStatus("q");
					lancamento.setTaxa(0);
					lancamento.setTipo("c");
					lancamento.setUnidade(iten.getId().getLancamento().getUnidade());
					lancamento.setValor(0);
					lancamento.setValorPago(0);
					lancamento.setVencimento(now);
					
					session.save(lancamento);
				}
				boleto.setStatus("q");
				session.update(boleto);				
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "1@Não foi possível dar baixa nos boletos devido a um erro interno!";
		}
		return "0@Boletos baixados com sucesso!";
	}
	
	private String baixarMultiplos(HttpServletRequest request) {
		ArrayList<Long> pipeBoleto = (request.getParameter("pipeBoleto").trim().equals(""))? null :
			Util.unmountPipeline(request.getParameter("pipeBoleto"));
		ArrayList<Long> pipeLancamento = (request.getParameter("pipeLancamento").trim().equals(""))? 
				new ArrayList<Long>(): Util.unmountPipeline(request.getParameter("pipeLancamento"));
		String result = (String) request.getSession().getAttribute("username");
		String username = result;
		double valor = 0;
		Long unidadeId = Long.valueOf(request.getSession().getAttribute("unidade").toString()); 
		result = (pipeBoleto == null)? "0@sem boletos" : baixa(pipeBoleto, result, unidadeId);
		if (Util.getPart(result, 1).trim().equals("1")) {
			return Util.getPart(result, 2);
		}		
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		Lancamento lancamento, baixaCaixa;
		ParcelaOrcamento parcelaOrcamento;
		Mensalidade mensalidade;
		Date now = new Date();
		TipoConta conta;
		try {
			for (Long codigo : pipeLancamento) {
				lancamento = (Lancamento) session.load(Lancamento.class, codigo);
				if (lancamento.getStatus().equals("q")
						|| lancamento.getStatus().equals("f")
						|| lancamento.getStatus().equals("c")) {
					transaction.rollback();
					session.close();
					if (lancamento.getStatus().equals("c")) {
						return "Não foi possível dar baixa pois O lançamento nº " + 
							lancamento.getCodigo() + " está cancelado!";
					} else {
						return "Não foi possível dar baixa pois O lançamento nº " + 
							lancamento.getCodigo() + " já está quitado!";
					}
				}
				if (!unidadeId.equals(lancamento.getUnidade().getCodigo())) {
					transaction.rollback();
					session.close();
					return "1@O Lançamento n° " + lancamento.getCodigo() + " não foi encontrado!";
				}
				if (lancamento.getConta().getCodigo() == 62) {
					query = session.createQuery("from ParcelaOrcamento as p where p.id.lancamento = :lancamento");
					query.setEntity("lancamento", lancamento);
					parcelaOrcamento = (ParcelaOrcamento) query.uniqueResult();
					lancamento.setStatus("f");
					lancamento.setEmissao(now);
					lancamento.setDocumento("orç.: " + 
							parcelaOrcamento.getId().getOrcamento().getCodigo() + 
							" guia: " + parcelaOrcamento.getId().getLancamento().getCodigo());
				} else {
					query = session.createQuery("from Mensalidade as m where m.lancamento = :lancamento");
					query.setEntity("lancamento", lancamento);
					mensalidade = (Mensalidade) query.uniqueResult();
					lancamento.setStatus("q");
					lancamento.setDocumento("ctr: " + 
							mensalidade.getUsuario().getContrato().getCodigo() +
							" mens: " + mensalidade.getCodigo());
				}
				valor = lancamento.getValor();
				lancamento.setRecebimento("automático");
				//lancamento.setRecebimento((String) request.getSession().getAttribute("username"));
				lancamento.setDataQuitacao(now);
				lancamento.setValorPago(valor);
				session.update(lancamento);
				
				conta = (TipoConta) session.load(TipoConta.class, Long.valueOf("69"));					
				baixaCaixa = new Lancamento();
				baixaCaixa.setConta(conta);
				baixaCaixa.setDataQuitacao(now);
				baixaCaixa.setDocumento("Lanç.: " + lancamento.getCodigo());
				baixaCaixa.setEmissao(now);
				baixaCaixa.setJuros(0);
				baixaCaixa.setMulta(0);
				baixaCaixa.setRecebimento(username);
				baixaCaixa.setStatus("q");
				baixaCaixa.setTaxa(0);
				baixaCaixa.setTipo("c");
				baixaCaixa.setUnidade(lancamento.getUnidade());
				baixaCaixa.setValor(0);
				baixaCaixa.setValorPago(0);
				baixaCaixa.setVencimento(now);
				
				session.save(baixaCaixa);

			}			
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível dar baixa todos boletos devido a um erro interno!";
		}
		return "Boletos baixados com sucesso!";
	}

}
