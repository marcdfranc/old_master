package com.marcsoftware.gateway;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Contrato;
import com.marcsoftware.database.FaturaVendedor;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.ItensVendedor;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class FaturaVendedorAdapter
 */
public class FaturaVendedorAdapter extends HttpServlet {
	private static final long serialVersionUID = 1L;
    private Session session;
    private Transaction transaction;
    private Query query;
    private PrintWriter out;
    private Filter filter;
    private FaturaVendedor fatura;
    private List<FaturaVendedor> faturaList;
    private List<ItensVendedor> itens;
    private Lancamento lancamento;
    private TipoConta conta;
    private Contrato contrato;
    private DataGrid dataGrid;
    private boolean isFilter;
    private int limit, offSet, gridLines;
    private Date now;
    
    public FaturaVendedorAdapter() {
        super();
    }

	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		if (request.getParameter("from").trim().equals("1")) {
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(estorneFatura(request));
			out.close();
			return;
		} else {
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			out = response.getWriter();
			session= HibernateUtil.getSession();
			transaction= session.beginTransaction();
			try {
				isFilter= request.getParameter("isFilter") == "1";
				mountFilter(request);
				limit= Integer.parseInt(request.getParameter("limit"));
				offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
				query = filter.mountQuery(query, session);
				gridLines = query.list().size();
				query.setFirstResult(offSet);
				query.setMaxResults(limit);
				faturaList = (List<FaturaVendedor>) query.list();
				if (faturaList.size() == 0) {
					out.print("<tr><td></td><td></td><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td></tr>");
					transaction.commit();
					session.close();
					out.close();
					return;
				}
				dataGrid= new DataGrid(null);
				for(FaturaVendedor fatura: faturaList) {
					query = session.createQuery("from ItensVendedor as i where i.id.faturaVendedor = :fatura " +
							"order by i.id.faturaVendedor.fim");
					query.setEntity("fatura", fatura);
					itens = (List<ItensVendedor>) query.list();
					query = session.getNamedQuery("totalVenda");
					query.setLong("fatura", fatura.getCodigo());
					dataGrid.setId(String.valueOf(fatura.getCodigo()));
					dataGrid.addData(String.valueOf(fatura.getCodigo()));
					dataGrid.addData(Util.parseDate(fatura.getInicio(), "dd/MM/yyyy"));
					dataGrid.addData(Util.parseDate(fatura.getFim(), "dd/MM/yyyy"));
					dataGrid.addData(Util.initCap(itens.get(0).getId().getContrato().getFuncionario().getNome()));
					dataGrid.addData(Util.parseDate(fatura.getCadastro(), "dd/MM/yyyy"));
					dataGrid.addData(Util.formatCurrency(query.uniqueResult().toString()));
					if (itens.get(0).getId().getContrato().getStatus().equals("a")) {
						dataGrid.addImg("../image/atraso.png");
					} else {
						dataGrid.addImg("../image/ok_icon.png");
					}
					dataGrid.addRow();
				}
				transaction.commit();
				session.close();
				out.print(dataGrid.getBody(gridLines));
				out.close();
			} catch (Exception e) {
				e.printStackTrace();
				transaction.rollback();
				session.close();
				out.print("<tr><td></td><td></td><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td></tr>");
				out.close();
			}
		}
	}
	
	private void mountFilter(HttpServletRequest request) {
		filter = new Filter("select distinct i.id.faturaVendedor " +
				" from ItensVendedor as i where (1 = 1)");		
		if (!request.getParameter("funcionario").equals("")) {
			filter.addFilter("i.id.contrato.funcionario.codigo = :funcionario", 
				Long.class, "funcionario",
				Long.valueOf(Util.removeZeroLeft(request.getParameter("funcionario"))));
		}
		if (!request.getParameter("inicio").equals("")) {
			filter.addFilter("i.id.faturaVendedor.cadastro between  :inicio", java.util.Date.class, 
					"inicio", Util.parseDate(request.getParameter("inicio")));
			filter.addFilter(" :fim", java.util.Date.class,
					"fim", Util.addDays(request.getParameter("fim"), 1));			
		}
		
		filter.setOrder("i.id.faturaVendedor.cadastro desc");
	}
	
	private String estorneFatura(HttpServletRequest request) {
		boolean isFirst = true;
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("48"));
			now = new Date();
			query = session.createQuery("from ItensVendedor as i " +
					"where i.id.faturaVendedor.codigo = :fatura");
			query.setLong("fatura", Long.valueOf(request.getParameter("fatura")));
			itens = (List<ItensVendedor>) query.list();			
			for (ItensVendedor iten : itens) {
				contrato = iten.getId().getContrato();
				if (contrato.getStatus().equals("a") && isFirst) {
					transaction.rollback();
					session.close();
					return "Não é possível estornar uma fatura aberta!";
				}
				isFirst = false;				
				lancamento = new Lancamento();
				lancamento.setConta(conta);
				lancamento.setDataQuitacao(iten.getId().getContrato().getLancamento().getDataQuitacao());
				lancamento.setDocumento("Fatura: " + iten.getId().getFaturaVendedor().getCodigo() +
						" rh: " + iten.getId().getContrato().getFuncionario().getCodigo());
				lancamento.setEmissao(iten.getId().getContrato().getLancamento().getEmissao());
				lancamento.setJuros(iten.getId().getContrato().getLancamento().getJuros());
				lancamento.setMulta(iten.getId().getContrato().getLancamento().getMulta());
				lancamento.setRecebimento(iten.getId().getContrato().getLancamento().getRecebimento());
				lancamento.setStatus("q");
				lancamento.setTaxa(iten.getId().getContrato().getLancamento().getTaxa());
				lancamento.setTipo(iten.getId().getContrato().getLancamento().getTipo());
				lancamento.setUnidade(iten.getId().getContrato().getLancamento().getUnidade());
				lancamento.setValor(iten.getId().getContrato().getLancamento().getValor());
				lancamento.setValorPago(iten.getId().getContrato().getLancamento().getValorPago());
				lancamento.setVencimento(iten.getId().getContrato().getLancamento().getVencimento());
				
				session.save(lancamento);
				
				lancamento = new Lancamento();
				lancamento.setConta(conta);
				lancamento.setDataQuitacao(now);
				lancamento.setDocumento("Fatura: " + iten.getId().getFaturaVendedor().getCodigo() +
						" rh: " + iten.getId().getContrato().getFuncionario().getCodigo());
				lancamento.setEmissao(now);
				lancamento.setJuros(iten.getId().getContrato().getLancamento().getJuros());
				lancamento.setMulta(iten.getId().getContrato().getLancamento().getMulta());
				lancamento.setRecebimento(request.getSession().getAttribute("username").toString());
				lancamento.setStatus("q");
				lancamento.setTaxa(iten.getId().getContrato().getLancamento().getTaxa());
				lancamento.setTipo("c");
				lancamento.setUnidade(iten.getId().getContrato().getLancamento().getUnidade());
				lancamento.setValor(iten.getId().getContrato().getLancamento().getValor());
				lancamento.setValorPago(iten.getId().getContrato().getLancamento().getValorPago());
				lancamento.setVencimento(now);
				
				session.save(lancamento);
				
				lancamento = contrato.getLancamento();
				lancamento.setValorPago(0);
				lancamento.setStatus("a");
				lancamento.setRecebimento(null);
				lancamento.setDataQuitacao(null);
				
				session.update(lancamento);
				
				contrato.setStatus("a");
				session.update(contrato);
			}
			
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possíevel realizar o estorno devido a um erro interno!";
		}
		return "Estorno Realizado com sucesso!";
	}
}
