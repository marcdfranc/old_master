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

import com.marcsoftware.database.Acesso;
import com.marcsoftware.database.Filter;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroAcesso
 */
public class CadastroAcesso extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Filter filter;
	private Session session;
	private Transaction transaction;
	private Query query;
	private boolean isFilter;
	private int limit, offSet, gridLines;
	private List<Acesso> acessoList;
	private PrintWriter out;
	private DataGrid dataGrid;
    
    public CadastroAcesso() {
        super();
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		if (request.getParameter("from").equals("1")) {
			response.setContentType("text/plain");		
			out= response.getWriter();
			out.print(disconect(request));
			out.close();
			return;
		} else {
			request.setCharacterEncoding("ISO-8859-1");				
			response.setContentType("text/html");
			out= response.getWriter();
		}
		session= HibernateUtil.getSession();		
		isFilter= request.getParameter("isFilter") == "1";
		mountFilter(request);			
		limit= Integer.parseInt(request.getParameter("limit"));
		offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
		query = filter.mountQuery(query, session);
		gridLines= query.list().size();
		query.setFirstResult(offSet);
		query.setMaxResults(limit);
		acessoList= (List<Acesso>) query.list();
		if (acessoList.size() == 0) {
			out.print("<tr><td><p>" + Util.SEM_REGISTRO + "</p></td><td>" + 
					"<td></td><td></td><td></td></td>");
			session.close();
			out.close();
			return;
		}
		dataGrid= new DataGrid("historico_navegacao.jsp");
		for(Acesso acesso: acessoList) {
			dataGrid.setId(String.valueOf(acesso.getCodigo()));
			dataGrid.addData(acesso.getLogin().getUsername());
			dataGrid.addData((acesso.getUnidade() == null)? "Várias" :
				acesso.getUnidade().getReferencia());
			dataGrid.addData(Util.parseDate(acesso.getEntrada(), "dd/MM/yyyy"));
			dataGrid.addData(Util.getTime(acesso.getEntrada()));
			if (request.getParameter("logados").equals("sys")) {
				if (acesso.getSaida() == null) {
					dataGrid.addData("-------");
					dataGrid.addData("-------");
				} else {
					dataGrid.addData(Util.parseDate(acesso.getSaida(), "dd/MM/yyyy"));
					dataGrid.addData(Util.getTime(acesso.getSaida()));
				}
			}
			dataGrid.addData(acesso.getIp());
			if (!request.getParameter("logados").equals("sys")) {
				dataGrid.addCheck(true);
			}
			dataGrid.addRow();
		}
		out.print(dataGrid.getBody(gridLines));
		session.close();
		out.close();
	}
	
	private void mountFilter(HttpServletRequest request) {
		if (request.getParameter("logados").equals("sys")) {
			filter = new Filter("from Acesso as a where (1=1) ");
		} else {
			filter = new Filter("from Acesso as a where a.saida is null ");
		}
		
		if (request.getSession().getAttribute("perfil").equals("f")) {
			filter.addFilter("a.unidade in(" +
				"from Unidade as u where u.administrador.login.username = :login)", 
					String.class, "login",
					request.getSession().getAttribute("username").toString());
		}					
		
		if ((!request.getParameter("inicio").equals(""))
				&& (!request.getParameter("fim").equals(""))) {
			filter.addFilter("a.entrada between :inicio", java.util.Date.class, 
					"inicio", Util.parseDate(request.getParameter("inicio")));			
			filter.addFilter(" :fim", java.util.Date.class, 
					"fim", Util.parseDate(request.getParameter("fim")));			
		} 
		if (!request.getParameter("usuario").equals("")) {
			filter.addFilter("a.login.username = :usuario", String.class, "usuario",
					request.getParameter("usuario"));
		}
		if (!request.getParameter("ipAcesso").equals("")) {
			filter.addFilter("a.ip = :ip", String.class, "ip",
					request.getParameter("ipAcesso"));
		}
		
		filter.setOrder("a.saida desc");
	}
	
	private String disconect(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		String sql = "from Acesso as a where a.codigo in(";
		Date now = new Date();
		try {
			sql+= request.getParameter("pipe") + ")";
			query = session.createQuery(sql);
			acessoList = (List<Acesso>) query.list();
			for (Acesso acesso : acessoList) {
				acesso.setSaida(now);
				session.update(acesso);				
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível desconectar o(s) usuários devido a um erro interno!";
		}
		return "usuários desconectados com sucesso"; 
	}
}
