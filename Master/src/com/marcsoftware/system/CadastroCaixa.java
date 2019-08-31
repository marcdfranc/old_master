package com.marcsoftware.system;

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

import com.marcsoftware.database.Caixa;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroCaixa
 */
public class CadastroCaixa extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Caixa caixa;
	private Lancamento lancamento;
	private Unidade unidade;
	private List<Caixa> caixaList;
	private Login login;
	private Date now;
	private DataGrid dataGrid;
	private PrintWriter out;
	private Session session;
	private Transaction transaction;
	private Query query;
	private Filter filter;
	private boolean isFilter;
	private int limit, offSet, gridLines; 
    private double fechamento;
	
    public CadastroCaixa() {
        super();
        // TODO Auto-generated constructor stub
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("ISO-8859-1");				
		response.setContentType("text/html");		
		out= response.getWriter();
		if (request.getParameter("from").equals("1")) {
			if (!addRecord(request)) {
				out.print("0");
				out.close();
				return;
			}
		} else if (request.getParameter("from").trim().equals("2")) {
			if (!fechaCaixa(request)) {
				out.print("0");
			} else {
				out.print("1");
			}
			out.close();
			return;
		}
		session= HibernateUtil.getSession();
		transaction= session.beginTransaction();
		isFilter= request.getParameter("isFilter") == "1";
		mountFilter(request);			
		limit= Integer.parseInt(request.getParameter("limit"));
		offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
		query = filter.mountQuery(query, session);
		gridLines= query.list().size();
		query.setFirstResult(offSet);
		query.setMaxResults(limit);		
		caixaList= (List<Caixa>) query.list();
		if (caixaList.size() == 0) {
			out.print("<tr><td></td><td><p>" + Util.SEM_REGISTRO + "</p>" +
					"<td></td><td></td><td></td><td></td><td></td><td></td><td></td>");
			transaction.commit();
			session.close();
			out.close();
			return;
		}
		dataGrid= new DataGrid("cadastro_caixa.jsp");
		for(Caixa cx: caixaList) {
			dataGrid.setId(String.valueOf(cx.getCodigo()));
			dataGrid.addData(String.valueOf(cx.getCodigo()));
			dataGrid.addData(cx.getLogin().getUsername());
			dataGrid.addData(Util.parseDate(cx.getInicio(), "dd/MM/yyyy"));							
			dataGrid.addData(Util.getTime(cx.getInicio()));
			dataGrid.addData((cx.getFim() == null) ? "" : Util.parseDate(cx.getFim(), "dd/MM/yyyy"));
			dataGrid.addData((cx.getFim() == null) ? "" : Util.getTime(cx.getFim()));
			if (cx.getStatus().trim().equals("a")) {
				dataGrid.addData("Aberto");
			} else {
				dataGrid.addData("Fechado");
			}
			dataGrid.addData(Util.formatCurrency(cx.getValorInicial()));
			dataGrid.addData(Util.formatCurrency(cx.getValorFinal()));
			dataGrid.addRow();
		}
		out.print(dataGrid.getBody(gridLines));
		transaction.commit();
		session.close();
		out.close();
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
	}
	
	private boolean addRecord(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			now = new Date();
			TipoConta conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("65"));
			query = session.createQuery("from Login as l where l.username = :username");
			query.setString("username", request.getSession().getAttribute("username").toString());
			unidade = (Unidade) session.get(Unidade.class, Long.valueOf(
					request.getSession().getAttribute("unidade").toString()));
			login = (Login) query.uniqueResult();
			caixa = new Caixa();
			caixa.setInicio(now);
			caixa.setLogin(login);
			caixa.setStatus("a");
			caixa.setValorInicial(Double.parseDouble(request.getParameter("valorInicial").replace(",", ".")));
			caixa.setUnidade(unidade);
			session.save(caixa);		
			
			lancamento = new Lancamento();			
			lancamento.setDataQuitacao(caixa.getInicio());
			//lancamento.setDescricao("abertura de caixa");
			lancamento.setDocumento("caixa: " + caixa.getCodigo() + " usuario: " + caixa.getLogin().getUsername());
			lancamento.setEmissao(now);
			lancamento.setRecebimento(caixa.getLogin().getUsername());
			lancamento.setStatus("q");
			lancamento.setTaxa(0);
			lancamento.setTipo("d");
			lancamento.setUnidade(unidade);
			lancamento.setValor(caixa.getValorInicial());
			lancamento.setValorPago(caixa.getValorInicial());
			lancamento.setVencimento(now);
			lancamento.setConta(conta);
			session.save(lancamento);
			
			request.getSession().setAttribute("caixaOpen", "t");
			
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
	
	private boolean fechaCaixa(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			now = new Date();
			TipoConta conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("66"));			
			caixa = (Caixa) session.load(Caixa.class, Long.valueOf(request.getParameter("id")));			
			unidade = (Unidade) session.load(Unidade.class, caixa.getUnidade().getCodigo());
			
			/*query = session.getNamedQuery("caixaFechamento");
			query.setTimestamp("inicio", caixa.getInicio());
			query.setTimestamp("fim", now);
			query.setString("usuario", caixa.getLogin().getUsername());
			fechamento = Double.parseDouble(query.uniqueResult().toString()) - caixa.getValorInicial();*/
			
			lancamento = new Lancamento();
			lancamento.setDataQuitacao(now);
			//lancamento.setDescricao("fechamento de caixa");
			lancamento.setDocumento("caixa: " + caixa.getCodigo() + " usuario: " + caixa.getLogin().getUsername());
			lancamento.setEmissao(now);
			lancamento.setRecebimento(caixa.getLogin().getUsername());
			lancamento.setStatus("q");
			lancamento.setTaxa(0);
			lancamento.setTipo("c");
			lancamento.setUnidade(unidade);
			lancamento.setValor(caixa.getValorInicial());
			lancamento.setValorPago(caixa.getValorInicial());
			lancamento.setVencimento(now);
			lancamento.setConta(conta);
			session.save(lancamento);
			
			double fechamento = Double.parseDouble(request.getParameter("valorFinal").replace(",", "."));
			if (request.getParameter("tpPagamento").equals("d")) {
				fechamento = fechamento *(-1);
			}
			caixa.setFim(now);
			caixa.setValorFinal(fechamento);
			caixa.setStatus("f");
			session.update(caixa);
			
			session.flush();
			request.getSession().setAttribute("caixaOpen", "f");
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
	
	
	private void mountFilter(HttpServletRequest request) {
		filter = new Filter("from Caixa as c where (1=1) ");			
		if ((!request.getSession().getAttribute("perfil").equals("f"))
				&& (!request.getSession().getAttribute("perfil").equals("a"))) {
			filter.addFilter("c.login.username = :username",
				String.class, "username", request.getSession().getAttribute("username").toString());
		} else if(!request.getParameter("usuario").equals("")) {
			filter.addFilter("c.login.username = :username",
					String.class, "username", request.getParameter("usuario"));
		}		
		if ((!request.getParameter("dataInicio").equals(""))
				&& (!request.getParameter("dataFim").equals(""))) {
			filter.addFilter("c.inicio between :inicio", java.util.Date.class, 
					"inicio", Util.parseDate(request.getParameter("dataInicio")));
			
			filter.addFilter(" :fim", java.util.Date.class, 
					"fim", Util.parseDate(request.getParameter("dataFim")));			
		}  else if (!request.getParameter("codigo").equals("")) {
			filter.addFilter("c.codigo = :codigo", Long.class, 
					"codigo", Long.valueOf(request.getParameter("codigo")));
		}
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("c.unidade.codigo = :unidade", Long.class, "unidade",
					Integer.parseInt(request.getParameter("unidadeId")));
		}
		filter.setOrder("c.status, c.inicio desc, c.login.username desc");
	}

}
