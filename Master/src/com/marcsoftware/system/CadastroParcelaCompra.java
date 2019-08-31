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

import com.marcsoftware.database.Compra;
import com.marcsoftware.database.Conciliacao;
import com.marcsoftware.database.FormaPagamento;
import com.marcsoftware.database.ItensConciliacao;
import com.marcsoftware.database.ItensConciliacaoId;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.ParcelaCompra;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroParcelaCompra
 */
public class CadastroParcelaCompra extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private ArrayList<Long> pipe;
	private Lancamento lancamento;
    private Session session;
    private Transaction transaction;
    private Query query;
    private FormaPagamento pagamento;
    private Conciliacao conciliacao;
    private ItensConciliacao itensConciliacao;
    private ItensConciliacaoId id;
    private PrintWriter out;
    private TipoConta conta;
    private ParcelaCompra parcelaCompra;
    private List<ItensConciliacao> itConcilioList;
    private Compra compra;
    
    public CadastroParcelaCompra() {
        super();
        
    }

	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		if (request.getParameter("from").equals("0")) {
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(Util.encodeString(pagamentoParcela(request), "UTF8", "ISO-8859-1"));
			out.close();
			return;
		} else if (request.getParameter("from").equals("1")) {
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(Util.encodeString(estorne(request), "UTF8", "ISO-8859-1"));
			out.close();
			return;
		} else if (request.getParameter("from").equals("2")) {
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(Util.encodeString(cancelParcela(request), "UTF8", "ISO-8859-1"));
			out.close();
			return;
		} else if (request.getParameter("from").equals("3")) {
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(Util.encodeString(editObs(request), "UTF8", "ISO-8859-1"));
			out.close();
			return;
		}
	}
	
	private String pagamentoParcela(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			pipe= Util.unmountPipeline(request.getParameter("pipe"));
			pagamento = (FormaPagamento) session.get(FormaPagamento.class, 
					Long.valueOf(Util.getPart(request.getParameter("formaPagamento"), 1)));
			Date now = new Date();
			if (pagamento.getConcilia().equals("s")) {
				conciliacao = new Conciliacao();
				conciliacao.setEmissao(Util.parseDate(request.getParameter("emissao")));
				conciliacao.setFormaPagamento(pagamento);
				conciliacao.setNumero(Util.encodeString(request.getParameter("numeroConcilio"), "ISO-8859-1", "UTF-8"));
				conciliacao.setVencimento(Util.parseDate(request.getParameter("vencimentoConcilia")));
				conciliacao.setStatus("a");
				session.save(conciliacao);
			}
			for (Long pp : pipe) {
				lancamento = (Lancamento) session.get(Lancamento.class, pp);
				if (lancamento.getStatus().equals("q")) {
					transaction.rollback();
					session.close();
					return "Não foi possível executar o pagamento devido a haver parcelas já pagas selecionadas!";
				}
				lancamento.setValorPago(Double.parseDouble(request.getParameter("vlrPago")));
				lancamento.setRecebimento((String) request.getSession().getAttribute("username"));
				lancamento.setDataQuitacao(now);
				lancamento.setStatus("q");
				
				session.update(lancamento);
				
				if (pagamento.getConcilia().equals("s")) {
					id = new ItensConciliacaoId();
					id.setConciliacao(conciliacao);
					id.setLancamento(lancamento);
					
					itensConciliacao = new ItensConciliacao();
					itensConciliacao.setId(id);
					itensConciliacao.setDocDigital("n");
					session.save(itensConciliacao);
				}
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível executar o pagamento devido a um erro interno!";
		}
		return "Parcelas Pagas com sucesso!";
	}
	
	private String estorne(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			Date now = new Date();
			pipe= Util.unmountPipeline(request.getParameter("pipe"));
			conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("48"));			
			for (Long pp : pipe) {
				query = session.createQuery("from ParcelaCompra as p where p.id.lancamento.codigo = :lancamento");
				query.setLong("lancamento", pp);
				parcelaCompra = (ParcelaCompra) query.uniqueResult();
				
				if (parcelaCompra.getId().getLancamento().getStatus().equals("a")
						|| parcelaCompra.getId().getLancamento().getStatus().equals("e")) {
					transaction.rollback();
					session.close();
					return "Não foi possível o estorno devido a existir parcelas ainda não pagas selecionadas";
				}
				
				lancamento = new Lancamento();
				lancamento.setConta(conta);
				lancamento.setDataQuitacao(now);
				lancamento.setDocumento("Pedido: " + 
						parcelaCompra.getId().getCompra().getCodigo() +
						" Parcela: " + parcelaCompra.getId().getLancamento().getCodigo());
				lancamento.setEmissao(parcelaCompra.getId().getLancamento().getEmissao());
				lancamento.setJuros(parcelaCompra.getId().getLancamento().getJuros());
				lancamento.setMulta(parcelaCompra.getId().getLancamento().getMulta());
				lancamento.setRecebimento(parcelaCompra.getId().getLancamento().getRecebimento());
				lancamento.setStatus("q");
				lancamento.setTaxa(parcelaCompra.getId().getLancamento().getTaxa());
				lancamento.setTipo("d");
				lancamento.setUnidade(parcelaCompra.getId().getLancamento().getUnidade());
				lancamento.setValor(parcelaCompra.getId().getLancamento().getValorPago());
				lancamento.setValorPago(parcelaCompra.getId().getLancamento().getValorPago());
				lancamento.setVencimento(parcelaCompra.getId().getLancamento().getVencimento());
				session.save(lancamento);
				
				lancamento = new Lancamento();
				lancamento.setConta(conta);
				lancamento.setDataQuitacao(now);
				lancamento.setDocumento("compra: " + 
						parcelaCompra.getId().getCompra().getCodigo() +
						" parcela: " + parcelaCompra.getId().getLancamento().getCodigo());
				lancamento.setEmissao(now);
				lancamento.setJuros(parcelaCompra.getId().getLancamento().getJuros());
				lancamento.setMulta(parcelaCompra.getId().getLancamento().getMulta());
				lancamento.setRecebimento(request.getSession().getAttribute("username").toString());
				lancamento.setStatus("q");
				lancamento.setTaxa(parcelaCompra.getId().getLancamento().getTaxa());
				lancamento.setTipo("c");
				lancamento.setUnidade(parcelaCompra.getId().getLancamento().getUnidade());
				lancamento.setValor(parcelaCompra.getId().getLancamento().getValorPago());
				lancamento.setValorPago(parcelaCompra.getId().getLancamento().getValorPago());
				lancamento.setVencimento(now);
				session.save(lancamento);
				
				query = session.createQuery("from ItensConciliacao as i where i.id.lancamento = :lancamento");
				query.setEntity("lancamento", parcelaCompra.getId().getLancamento());
				if (query.list().size() > 0) {
					itensConciliacao = (ItensConciliacao) query.uniqueResult();
					query = session.createQuery("from ItensConciliacao as i where i.id.conciliacao = :conciliacao");
					query.setEntity("conciliacao", itensConciliacao.getId().getConciliacao());
					if (query.list().size() == 1) {
						conciliacao = itensConciliacao.getId().getConciliacao();
						
						session.delete(itensConciliacao);
						session.delete(conciliacao);
					} else {
						session.delete(itensConciliacao);
					}
				}
				parcelaCompra.getId().getLancamento().setStatus("e");
				parcelaCompra.getId().getLancamento().setDataQuitacao(null);
				parcelaCompra.getId().getLancamento().setRecebimento(request.getSession().getAttribute("username").toString());
				parcelaCompra.getId().getLancamento().setValorPago(0);
				
				
				session.update(parcelaCompra.getId().getLancamento());
			}
			
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível o estorno devido a um ero interno!";
		}
		
		return "Estorno realizado com sucesso!";
	}
	
	private String cancelParcela(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			pipe= Util.unmountPipeline(request.getParameter("pipe"));
			for (Long pp : pipe) {
				lancamento = (Lancamento) session.get(Lancamento.class, pp); 
				if (lancamento.getStatus().equals("q")) {
					transaction.rollback();
					session.close();
					return "Não foi possível cancelar as parcelas por haverem parcelas pagas selecionadas!";
				}
				lancamento.setStatus("c");
				lancamento.setRecebimento(request.getSession().getAttribute("username").toString());
			}
			session.flush();
			transaction.commit();
			session.close();			
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível cancelar as parcelas devido a um erro interno!";
		}		
		return "Parcelas canceladas com sucesso!";
	}
	
	private String editObs(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			compra = (Compra) session.get(Compra.class, Long.valueOf(request.getParameter("compra")));
			compra.setObservacao(request.getParameter("obs"));
			session.update(compra);
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			return "1";
		}
		return "0";
	}
}
