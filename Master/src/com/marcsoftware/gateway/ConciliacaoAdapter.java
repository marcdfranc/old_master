package com.marcsoftware.gateway;

import java.io.IOException;

import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;

import com.marcsoftware.database.Filter;
import com.marcsoftware.database.ItensConciliacao;
import com.marcsoftware.database.Orcamento;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;

/**
 * Servlet implementation class ConciliacaoAdapter
 */
public class ConciliacaoAdapter extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    
    public ConciliacaoAdapter() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PrintWriter out = response.getWriter();
		response.setContentType("text/html");
		response.setCharacterEncoding("ISO-8859-1");
		boolean isFilter= request.getParameter("isFilter") == "1";
		Session session = HibernateUtil.getSession();
		Filter filter = null;
		try {
			filter = mountFilter(request);
			int limit= Integer.parseInt(request.getParameter("limit"));
			int offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
			Query query = null;
			query = filter.mountQuery(query, session);
			int gridLines= query.list().size();
			query.setFirstResult(offSet);
			query.setMaxResults(limit);
			List<ItensConciliacao> itensList = (List<ItensConciliacao>) query.list();
			if (itensList.size() == 0) {
				out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td><td></td><td></td></tr>");				
				session.close();
				out.close();
				return;
			}
			DataGrid dataGrid = new DataGrid("#");
			
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			session.close();
			out.close();
		}
	}
	
	private Filter mountFilter(HttpServletRequest request) throws Exception{
		Filter filter = new Filter("from ItensConciliacao as i where (1 = 1)");
		
		filter.addFilter("i.id.conciliacao.codigo = :codigo", Long.class, "codigo",
				Long.valueOf(request.getParameter("codigoIn")));		
		
		return filter;
	}

}
