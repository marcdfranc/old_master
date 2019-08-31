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

import com.marcsoftware.database.Banco;
import com.marcsoftware.database.Ramo;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroRamo
 */
public class CadastroRamo extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Ramo ramo;
	private String errorMessage;
    private int limit, offset, gridLines;
    private PrintWriter out;
    private List<Ramo> ramoList;
    private DataGrid dataGrid;
    private Session session;
    private Transaction transaction;
    private Query query;
    private boolean isEdition, isDel;
    
    public CadastroRamo() {
        super();       
    }

	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		isDel = false;
		isEdition = false;
		out= response.getWriter();
		response.setContentType("text/html");
		response.setCharacterEncoding("ISO-8859-1");
		if (request.getParameter("isEdit").trim().equals("t")) {
			isEdition= true;
		} else if (request.getParameter("isEdit").trim().equals("d")){
			isDel = true;
		}
		session= HibernateUtil.getSession();
		if (!request.getParameter("isEdit").trim().equals("n")) {
			if (!addRecord(request)) {
				out.print("<tr><td><p>" + Util.encodeString(Util.ERRO_INSERT, "UTF8", "ISO-8859-1") +
				"</p></td></tr>");
				out.close();
				return;
			}
		}
		transaction = session.beginTransaction();
		limit= Integer.parseInt(request.getParameter("limit"));
		offset= Integer.parseInt(request.getParameter("offset"));
		query= session.createQuery("from Ramo as r order by r.codigo");			
		gridLines= query.list().size();
		query.setFirstResult(offset);
		query.setMaxResults(limit);
		ramoList = (List<Ramo>) query.list();
		if (ramoList.size() == 0) {
			out.print("<tr><td></td><td><p>" + Util.encodeString(
					Util.SEM_REGISTRO, "UTF8", "ISO-8859-1") + "</p></td></tr>");
			out.close();
			return;
		}
		dataGrid= new DataGrid(null);
		for (Ramo rm : ramoList) {
			dataGrid.setId(String.valueOf(rm.getCodigo()));
			dataGrid.addData(String.valueOf(rm.getCodigo()));
			dataGrid.addData(Util.initCap(rm.getDescricao()));
			dataGrid.addRow();
		}
		out.print(Util.encodeString(dataGrid.getBody(gridLines), "UTF8",  "ISO-8859-1"));
		transaction.commit();
		session.close();			
		out.close();
	}

	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
	}
	
	private boolean addRecord(HttpServletRequest request) {
		try {
			transaction = session.beginTransaction();
			if (isDel) {
				query = session.createQuery("from Ramo as r where r.codigo = :codigo");
				query.setLong("codigo", Long.valueOf(request.getParameter("id")));
				ramo = (Ramo) query.uniqueResult();
				session.delete(ramo);
			} else {
				String descricao= Util.encodeString(request.getParameter("descricaoIn"), "ISO-8859-1", "UTF8");
				if (!descricao.trim().equals("")) {
					ramo = new Ramo();
					if (isEdition) {
						ramo.setCodigo(Long.valueOf(request.getParameter("id")));
					}
					ramo.setDescricao(descricao.toLowerCase());
					session.saveOrUpdate(ramo);					
				}
			}
			transaction.commit();
		} catch (Exception e) {			
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return false;
		}
		return true;
	}
}
