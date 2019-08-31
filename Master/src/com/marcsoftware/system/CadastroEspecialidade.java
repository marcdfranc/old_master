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

import com.marcsoftware.database.Especialidade;
import com.marcsoftware.database.Ramo;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class for Servlet: CadastroEspecialidade
 *
 */
public class CadastroEspecialidade extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
	static final long serialVersionUID = 1L;
	private PrintWriter out; 
	
	public CadastroEspecialidade() {
		super();
	}
		
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		boolean isDel = false; 
		boolean isEdition = false;		
		out= response.getWriter();
		response.setContentType("text/html");
		response.setCharacterEncoding("ISO-8859-1");		
		if (request.getParameter("isEdit").trim().equals("t")) {
			isEdition= true;
		} else if (request.getParameter("isEdit").trim().equals("d")){
			isDel = true;
		}
		if (!request.getParameter("isEdit").trim().equals("n")) {
			if (!addRecord(request, isDel, isEdition)) {
				out.print("<tr><td><p>" + Util.encodeString(Util.ERRO_INSERT, "UTF8", "ISO-8859-1") + 
				"</p></td></tr>");
				out.close();
				return;
			}			
		}
		Session session= HibernateUtil.getSession();
		try {
			Transaction transaction = session.beginTransaction();		
			int limit= Integer.parseInt(request.getParameter("limit"));
			int offset= Integer.parseInt(request.getParameter("offset"));
			Query query= session.createQuery("from Especialidade as e order by e.setor, e.codigo");		
			int gridLines= query.list().size();
			query.setFirstResult(offset);
			query.setMaxResults(limit);		
			List<Especialidade> listEspecialidade = (List<Especialidade>) query.list();
			if (listEspecialidade.size()== 0) {
				out.print("<tr><td><p>" + Util.encodeString(Util.SEM_REGISTRO, "UTF8", "ISO-8859-1") + 
				"</p></td></tr>");
				out.close();
				return;
			}
			DataGrid dataGrid= new DataGrid(null);
			for (Especialidade esp : listEspecialidade) {
				dataGrid.setId(String.valueOf(esp.getCodigo()));
				dataGrid.addData(String.valueOf(esp.getCodigo()));
				dataGrid.addData((esp.getSetor().trim().equals("m"))? "Médico" : "Odontológico");
				dataGrid.addData(Util.initCap(esp.getDescricao()));
				dataGrid.addRow();
			}
			out.print(Util.encodeString(dataGrid.getBody(gridLines), "UTF8",  "ISO-8859-1"));
			transaction.commit();			
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			session.close();			
			out.close();			
		}
	}
		
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		//
	}
	
	private boolean addRecord(HttpServletRequest request, boolean isDel, boolean isEdition) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		try {
			Query query;
			Especialidade especialidade = null;
			if (isDel) {
				query = session.createQuery("from Especialidade as e where e.codigo = :codigo");
				query.setLong("codigo", Long.valueOf(request.getParameter("id")));
				especialidade = (Especialidade) query.uniqueResult();
				session.delete(especialidade);
			} else {
				String descricao= Util.encodeString(request.getParameter("descricaoIn"), "ISO-8859-1", "UTF8");
				if (isEdition) {
					especialidade = (Especialidade) session.load(Especialidade.class, Long.valueOf(request.getParameter("id")));
				} else {
					especialidade= new Especialidade();
				}
				especialidade.setSetor(request.getParameter("setorIn"));
				especialidade.setDescricao(descricao);
				session.saveOrUpdate(especialidade);
			}
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
		} finally {
			session.close();
		}
		return true;
	}
}