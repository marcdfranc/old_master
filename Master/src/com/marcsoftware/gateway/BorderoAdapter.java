package com.marcsoftware.gateway;

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
import com.marcsoftware.database.Conciliacao;
import com.marcsoftware.database.FormaPagamento;
import com.marcsoftware.database.ItensBordero;
import com.marcsoftware.database.ItensBorderoId;
import com.marcsoftware.database.ItensConciliacao;
import com.marcsoftware.database.ItensConciliacaoId;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.database.Pessoa;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class BorderoAdapter extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private ParcelaOrcamento parcela;
	private BorderoProfissional bordero;
	private Pessoa pessoa;
	private ItensBordero itens;
	private List<ItensBordero> itenList;
	private ItensBorderoId borderoId;
	private TipoConta conta;
	private ArrayList<Long> pipeList;
	private Lancamento lancCliente, lancProfissional;
	private double operacional, cliente;
	private PrintWriter out;
	private Session session;
	private Transaction transaction;
	private Query query;
	private String pipe;
	private ArrayList<String> pipeConocilio;
	private ItensConciliacao itenConcilio;
	private ItensConciliacaoId idItenConcilio;
	private Conciliacao conciliacao;
	private FormaPagamento pagamento;
        
    public BorderoAdapter() {
        super();
        
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		session = HibernateUtil.getSession();
		response.setContentType("text/plain");
		response.setCharacterEncoding("ISO-8859-1");
		out = response.getWriter();
		if (request.getParameter("from").equals("0")) {
			try {				
				transaction = session.beginTransaction();			
				query = session.getNamedQuery("pagProfissional");
				query.setLong("lancamento", Long.valueOf(request.getParameter("lancamento")));
				query.setLong("profissional", Long.valueOf(request.getParameter("idPessoa")));
				if (query.list().size() == 0) {
					out.print("1");					
				} else {
					parcela = (ParcelaOrcamento) query.uniqueResult();
					
					query = session.getNamedQuery("operacionalOrcamento");
					query.setLong("orcamento", parcela.getId().getOrcamento().getCodigo());
					query.setLong("unidade", parcela.getId().getLancamento().getUnidade().getCodigo());
					operacional = Double.parseDouble(query.uniqueResult().toString());
					
					query = session.getNamedQuery("clienteOrcamento");
					query.setLong("orcamento", parcela.getId().getOrcamento().getCodigo());
					query.setLong("unidade", parcela.getId().getLancamento().getUnidade().getCodigo());
					cliente = Double.parseDouble(query.uniqueResult().toString());
					
					if (parcela.getId().getOrcamento().getDependente() == null) {
						pipe = Util.zeroToLeft(
							parcela.getId().getOrcamento().getUsuario().getContrato().getCtr(), 4) + 
							"-0@" + 
							Util.initCap(parcela.getId().getOrcamento().getUsuario().getNome()) + "@"; 
					} else {
						pipe = Util.zeroToLeft(
							parcela.getId().getOrcamento().getUsuario().getContrato().getCtr(), 4)+
							"-" + parcela.getId().getOrcamento().getDependente().getReferencia() +
							"@" + 
							Util.initCap(parcela.getId().getOrcamento().getDependente().getNome()) + "@";
					}				 
					pipe+= parcela.getId().getOrcamento().getCodigo() + "@" + 
						parcela.getId().getLancamento().getCodigo() + "@" + 
						((parcela.getId().getLancamento().getEmissao() == null)
						? Util.parseDate(parcela.getId().getLancamento().getVencimento(), "dd/MM/yyyy")
						: Util.parseDate(parcela.getId().getLancamento().getEmissao(), "dd/MM/yyyy"))+ "@" +
						Util.formatCurrency(Util.getOperacional(
							operacional, cliente, parcela.getId().getLancamento().getValor()));
					out.print(pipe);
				}
				
				transaction.commit();				
			} catch (Exception e) {
				transaction.rollback();
				e.printStackTrace();
			}			
		} else if (request.getParameter("from").equals("1")) {			
			out.print(addRecord(request));
		} else if (!updateRecord(request)){
			out.print("1");
		} else {
			out.print("0");
		}
		out.close();
		session.close();
	}
	
	private String addRecord(HttpServletRequest request) {
		int mes, ano;
		String result = "0@";
		try {
			parcela = null;
			transaction = session.beginTransaction();
			pessoa = (Pessoa) session.get(Pessoa.class, 
					Long.valueOf(request.getParameter("idPessoa")));			
			
			mes = Util.getMonthDate(request.getParameter("cadastro"));
			ano = Util.getYearDate(request.getParameter("cadastro"));
			
			pagamento = (FormaPagamento) session.get(FormaPagamento.class, 
					Long.valueOf(request.getParameter("tpPagamentoIn")));
			
			bordero = new BorderoProfissional();
			bordero.setCadastro(Util.parseDate(request.getParameter("cadastro")));
			if (mes == 1) {
				bordero.setInicio(Util.parseDate("26/12/" + (ano - 1)));
			} else {
				bordero.setInicio(Util.parseDate("26/" + (mes - 1) + "/" + ano));
			}
			bordero.setFim(Util.parseDate("25/" + mes + "/" + ano));
			bordero.setPessoa(pessoa);
			bordero.setFormaPagamento(pagamento);
			bordero.setDocDigital("n");
			session.save(bordero);
			result+= bordero.getCodigo();
			conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("12"));
			
			pipeList = Util.unmountPipeline(request.getParameter("lancamentos"));
			
			for (Long pp : pipeList) {
				lancCliente = (Lancamento) session.get(Lancamento.class, pp);
				
				query = session.createQuery("from ParcelaOrcamento as p where p.id.lancamento.codigo = :lancamento and p.id.lancamento.status = 'f'");
				query.setLong("lancamento", pp);
				parcela = (ParcelaOrcamento) query.uniqueResult();
				
				lancCliente.setStatus("q");
				session.update(lancCliente);
				
				query = session.getNamedQuery("operacionalOrcamento");
				query.setLong("orcamento", parcela.getId().getOrcamento().getCodigo());
				query.setLong("unidade", parcela.getId().getLancamento().getUnidade().getCodigo());
				operacional = Double.parseDouble(query.uniqueResult().toString());
				
				query = session.getNamedQuery("clienteOrcamento");
				query.setLong("orcamento", parcela.getId().getOrcamento().getCodigo());
				query.setLong("unidade", parcela.getId().getLancamento().getUnidade().getCodigo());
				cliente = Double.parseDouble(query.uniqueResult().toString());
				
				lancProfissional = new Lancamento();
				lancProfissional.setConta(conta);
				lancProfissional.setDocumento("fatura: " + bordero.getCodigo() + " profiss: " + pessoa.getCodigo());
				lancProfissional.setEmissao(Util.parseDate(request.getParameter("cadastro")));
				lancProfissional.setJuros(0);
				lancProfissional.setMulta(0);
				lancProfissional.setRecebimento(request.getSession().getAttribute("username").toString());
				lancProfissional.setStatus("a");
				lancProfissional.setTaxa(0);
				lancProfissional.setTipo("d");
				lancProfissional.setUnidade(pessoa.getUnidade());
				lancProfissional.setValor(Util.getOperacional(
						operacional, cliente, lancCliente.getValor()));
				lancProfissional.setVencimento(Util.parseDate("28/" + mes + "/" + ano));
				session.save(lancProfissional);
				
				borderoId = new ItensBorderoId();
				borderoId.setBorderoProfissional(bordero);
				borderoId.setCliente(lancCliente);
				
				itens = new ItensBordero();
				itens.setId(borderoId);
				itens.setOperacional(lancProfissional);
				session.save(itens);
			}
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
			return "1@Não foi possível gerar a fatura devido a um erro interno!";
		}
		return result;
	}

	private boolean updateRecord(HttpServletRequest request) {
		Long idCompare = new Long(0); 
		try {
			transaction = session.beginTransaction();
			Date now = new Date();
			query = session.createQuery("from ItensBordero as i where i.id.borderoProfissional.codigo = :bordero");
			query.setLong("bordero", Long.valueOf(request.getParameter("bordero")));
			itenList = (List<ItensBordero>) query.list();
			pipeConocilio = Util.unmountRealPipe(request.getParameter("concilio"));			
			for (ItensBordero it : itenList) {
				lancProfissional = it.getOperacional();
				lancProfissional.setDataQuitacao(now);
				lancProfissional.setRecebimento(request.getSession().getAttribute("username").toString());
				lancProfissional.setValorPago(lancProfissional.getValor());
				lancProfissional.setStatus("q");
				session.update(lancProfissional);
				
				for (String pp : pipeConocilio) {
					if (Long.valueOf(Util.getPipeById(pp, 1)).equals(lancProfissional.getCodigo())) {
						if (! idCompare.equals(Long.valueOf(Util.getPipeById(pp, 0)))) {
							pagamento = (FormaPagamento) session.get(FormaPagamento.class, 
									Long.valueOf(Util.getPipeById(pp, 2)));
							
							conciliacao = new Conciliacao();
							conciliacao.setEmissao(now);
							conciliacao.setFormaPagamento(pagamento);
							conciliacao.setNumero(Util.getPipeById(pp, 3));
							conciliacao.setStatus("a");
							conciliacao.setVencimento(Util.parseDate(Util.getPipeById(pp, 4)));
							
							session.save(conciliacao);
							
							idCompare = Long.valueOf(Util.getPipeById(pp, 0));						
						}
						
						idItenConcilio = new ItensConciliacaoId();
						idItenConcilio.setConciliacao(conciliacao);
						idItenConcilio.setLancamento(lancProfissional);
						
						itenConcilio = new ItensConciliacao();
						itenConcilio.setId(idItenConcilio);
						itenConcilio.setDocDigital("n");
						
						session.save(itenConcilio);						
					}
				}				
				
			}
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
			return false;
		}
		return true;
	}
}
