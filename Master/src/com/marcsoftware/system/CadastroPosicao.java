package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Especialidade;
import com.marcsoftware.database.Posicao;
import com.marcsoftware.database.Ramo;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


/**
 * Servlet implementation class for Servlet: CadastroPosicao
 *
 */
 public class CadastroPosicao extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
   static final long serialVersionUID = 1L;   
   private Posicao posicao;   
   private String errorMessage;
   private int limit, offset, gridLines;
   private PrintWriter out;
   private List<Posicao> posicaoList;
   private DataGrid dataGrid;
   private Session session;
   private Transaction transaction;
   private Query query;
   private boolean isEdition, isDel;
   
	public CadastroPosicao() {		
		super();	
	}	
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		isEdition= false;
		isDel= false;
		out= response.getWriter();
		response.setContentType("text/html");
		response.setCharacterEncoding("ISO-8859-1");
		if (request.getParameter("isEdit").trim().equals("t")) {
			isEdition= true;
		} else if (request.getParameter("isEdit").trim().equals("d")){
			isDel= true;
		}	
		session= HibernateUtil.getSession();
		if (!request.getParameter("isEdit").trim().equals("n")) {
			if (!addRecord(request)) {
				out.print("<tr><td></td><td><p>" + 
						Util.encodeString(Util.ERRO_INSERT, "UTF8", "ISO-8859-1") +
				"</p></td></tr>");
				out.close();
				return;
			}			
		}
		transaction = session.beginTransaction();		
		limit= Integer.parseInt(request.getParameter("limit"));
		offset= Integer.parseInt(request.getParameter("offset"));
		query= session.createQuery("from Posicao as p order by p.codigo");
		gridLines= query.list().size();
		query.setFirstResult(offset);
		query.setMaxResults(limit);
		posicaoList= (List<Posicao>) query.list();
		if (posicaoList.size()== 0) {
			out.print("<tr><td><p>" + Util.SEM_REGISTRO + "</p></td></tr>");
			out.close();
			return;
		}
		dataGrid= new DataGrid(null);
		for(Posicao pos: posicaoList) {
			dataGrid.setId(String.valueOf(pos.getCodigo()));
			dataGrid.addData(String.valueOf(pos.getCodigo()));
			dataGrid.addData(pos.getDescricao());
			dataGrid.addRow();
		}
		out.print(Util.encodeString(dataGrid.getBody(gridLines), "UTF8", "ISO-8859-1"));
		transaction.commit();
		session.close();			
		out.close();
	}
	
	private boolean addRecord(HttpServletRequest request) throws UnsupportedEncodingException {		
		try {
			if (isDel) {
				query = session.createQuery("from Posicao as p where p.codigo = :codigo");
				query.setLong("codigo", Long.valueOf(request.getParameter("id")));
				posicao = (Posicao) query.uniqueResult();
				session.delete(posicao);
			} else {
				String descricao= Util.encodeString(
						request.getParameter("descricaoIn"), "ISO-8859-1", "UTF8");
				posicao= new Posicao();
				if (isEdition) {
					posicao.setCodigo(Long.valueOf(request.getParameter("id")));
				}
				posicao.setDescricao(descricao.toLowerCase());
				session.saveOrUpdate(posicao);
			}
		} catch (Exception e) {
			transaction.rollback();
			session.close();
			return false;
		}
		return true;
	}
}