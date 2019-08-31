package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Encargo;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Plano;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroEncargo
 */
public class CadastroEncargo extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Session session;
	private Transaction transaction;
	private Query query;
	private Encargo encargo;
	private Filter filter;
	private PrintWriter out;
	private boolean isFilter;
	private int limit, offSet, gridLines;
	private List<Encargo> encargoList;
	private DataGrid dataGrid;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CadastroEncargo() {
        super();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		if (request.getParameter("from").equals("1")) {
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(addRecord(request));
			out.close();
			return;
		} else if (request.getParameter("from").equals("2")) {
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(deleteEncargo(request));
			out.close();
			return;
		}
		request.setCharacterEncoding("ISO-8859-1");
		response.setContentType("text/html");
		out= response.getWriter();
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
		encargoList = (List<Encargo>) query.list();
		if (encargoList.size() == 0) {
			out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td></tr>");
			transaction.commit();
			session.close();
			out.close();
			return;
		}
		dataGrid = new DataGrid(null);
		for(Encargo	enc: encargoList) {							
			dataGrid.setId(String.valueOf(enc.getCodigo()));
			dataGrid.addData("codigo" + enc.getCodigo(), String.valueOf(enc.getCodigo()), false);
			dataGrid.addData("descricao" + enc.getCodigo(), enc.getDescricao(), false);
			dataGrid.addData("percentual" + enc.getCodigo(), String.valueOf(enc.getPercentual()), false);
			dataGrid.addRow();
		}
		transaction.commit();
		session.close();
		out.print(dataGrid.getBody(gridLines));
		out.close();
	}
	
	private String addRecord(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			if (request.getParameter("codigo").equals("")) {
				encargo = new Encargo();				
			} else {
				encargo = (Encargo) session.get(Encargo.class, Long.valueOf(request.getParameter("codigo")));
			}
			encargo.setDescricao(request.getParameter("descricao"));
			encargo.setPercentual(Double.parseDouble(request.getParameter("percentual")));
			
			session.saveOrUpdate(encargo);
			
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível salvar o encargo devido a um erro interno!";
		}
		
		return "Encargo salvo com sucesso!";
	}
	
	private String deleteEncargo(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			encargo = (Encargo) session.get(Encargo.class, Long.valueOf(request.getParameter("codigo")));
			query = session.createQuery("from ItensFolha as i where i.encargo = :encargo");
			query.setEntity("encargo", encargo);
			if (query.list().size() > 0) {
				transaction.rollback();
				session.close();
				return "Não é possivel excluir encargos que já possuem registros em folhas de pagamento";				
			}
			session.delete(encargo);
			
			session.flush();
			transaction.commit();			
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível excluir o encargo devido a um erro interno!";
		}		
		return "Encargo excluído com sucesso!";
	}
	
	private void mountFilter(HttpServletRequest request) {
		filter = new Filter("from Encargo as e where (1 = 1)");
		
		if (!request.getParameter("codigo").equals("")) {
			filter.addFilter("e.codigo = :codigo", Long.class, "codigo",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("codigo"))));
		}		
		if (!request.getParameter("descricao").equals("")) {
			filter.addFilter("e.descricao LIKE :descricao", String.class, "descricao", 
					"%" + Util.encodeString(request.getParameter("descricao"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("percentual").equals("")) {
			filter.addFilter("e.percentual = :percentual", Double.class, 
					"percentual", Double.parseDouble(( request.getParameter("percentual"))));
		}
		filter.setOrder("e.codigo");
	}
}
