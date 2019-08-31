package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Banco;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class for Servlet: CadastroBanco
 *
 */
 public class CadastroBanco extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
	 static final long serialVersionUID = 1L;   
    private Banco banco;
    private String errorMessage;
    private int limit, offset, gridLines;
    private PrintWriter out;
    private List<Banco> bancoList;
    private DataGrid dataGrid;
    private Session session;
    private Transaction transaction;
    private Query query;
    private boolean isEdition, isDel;
   
	public CadastroBanco() {
		super();
	}
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		isDel = false;
		isEdition = false;
		out= response.getWriter();		
		response.setContentType("text/html");
		response.setCharacterEncoding("ISO-8859-1");
		if (request.getParameter("isEdit").trim().equals("t")) {
			isEdition = true;
		} else if (request.getParameter("isEdit").trim().equals("d")) {
			isDel = true;
		}
		session= HibernateUtil.getSession();
		if (!request.getParameter("isEdit").trim().equals("n")) {
			if (!addRecord(request)) {
				String aux = "O arquivo não pode ser deletado por já estar vinculado a outros registros!";
				out.print("<tr><td></td><td><p>" + Util.encodeString(aux , "UTF8", "ISO-8859-1") +
				"</p></td></tr>");			
				out.close();
				return;
			}
		}
		transaction = session.beginTransaction();
		limit= Integer.parseInt(request.getParameter("limit"));
		offset= Integer.parseInt(request.getParameter("offset"));
		query= session.createQuery("from Banco as b order by b.codigo");			
		gridLines= query.list().size();
		query.setFirstResult(offset);
		query.setMaxResults(limit);
		bancoList = (List<Banco>) query.list();		
		if (bancoList.size() == 0) {
			out.print("<tr><td></td><td><p>" + Util.encodeString(Util.SEM_REGISTRO, 
					"UTF8", "ISO-8859-1") + "</p></td></tr>");
			session.close();
			out.close();
			return;
		}
		dataGrid= new DataGrid(null);
		for (Banco bnc : bancoList) {
			dataGrid.setId(String.valueOf(bnc.getCodigo()));
			dataGrid.addData(String.valueOf(bnc.getCodigo()));
			dataGrid.addData(Util.initCap(bnc.getDescricao()));
			dataGrid.addRow();
		}
		out.print(Util.encodeString(dataGrid.getBody(gridLines), "UTF8",  "ISO-8859-1"));
		transaction.commit();
		session.close();			
		out.close();
	}
	
	private boolean addRecord(HttpServletRequest request) {
		try {
			transaction = session.beginTransaction();
			if (isDel) {
				query = session.createQuery("from Banco as b where b.codigo = :codigo");
				query.setLong("codigo", Long.valueOf(request.getParameter("id")));
				banco = (Banco) query.uniqueResult();
				session.delete(banco);
			} else {
				String descricao= Util.encodeString(request.getParameter("descricaoIn"), "ISO-8859-1", "UTF8");
				banco = new Banco();
				if (isEdition) {
					banco.setCodigo(Long.valueOf(request.getParameter("id")));
				}
				banco.setDescricao(descricao.toLowerCase());
				session.saveOrUpdate(banco);
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