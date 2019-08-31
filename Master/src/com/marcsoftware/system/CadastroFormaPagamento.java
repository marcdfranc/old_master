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
import com.marcsoftware.database.FormaPagamento;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroFormaPagamento
 */
public class CadastroFormaPagamento extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private PrintWriter out;
	private boolean isGet;
	private int limit, offset, gridLines;
	private List<FormaPagamento> formaList;
	private FormaPagamento formaPagamento;
	private DataGrid dataGrid;
	private Session session;
	private Transaction transaction;
	private Query query;
	private boolean isDel, isEdition;
    
    public CadastroFormaPagamento() {
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
		query= session.createQuery("from FormaPagamento as f order by f.codigo");			
		gridLines= query.list().size();
		query.setFirstResult(offset);
		query.setMaxResults(limit);
		formaList = (List<FormaPagamento>) query.list();
		if (formaList.size() == 0) {
			out.print("<tr><td></td><td><p>" + Util.encodeString(Util.SEM_REGISTRO, 
					"UTF8", "ISO-8859-1") + "</p></td></tr>");
			session.close();
			out.close();
			return;
		}
		dataGrid= new DataGrid(null);
		for (FormaPagamento fPag : formaList) {
			dataGrid.setId(String.valueOf(fPag.getCodigo()));
			dataGrid.addData(String.valueOf(fPag.getCodigo()));
			dataGrid.addData(Util.initCap(fPag.getDescricao()));
			dataGrid.addData((fPag.getConcilia().trim().equals("s"))? "Sim" : "Não");
			dataGrid.addRow();
		}
		out.print(Util.encodeString(dataGrid.getBody(gridLines), "UTF8",  "ISO-8859-1"));
		transaction.commit();
		session.close();			
		out.close();
	}

	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
	}
	
	private boolean addRecord(HttpServletRequest request) {
		try {
			transaction = session.beginTransaction();
			if (isDel) {
				query= session.createQuery("from FormaPagamento as f where f.codigo = :codigo");
				query.setLong("codigo", Long.valueOf(request.getParameter("id")));
				formaPagamento = (FormaPagamento) query.uniqueResult();
				session.delete(formaPagamento);
			} else {
				String descricao= Util.encodeString(request.getParameter("descricaoIn"), "ISO-8859-1", "UTF8");			
				formaPagamento = new FormaPagamento();
				if (isEdition) {
					formaPagamento.setCodigo(Long.valueOf(request.getParameter("id")));
				}				
				formaPagamento.setDescricao(descricao.toLowerCase());
				formaPagamento.setConcilia(request.getParameter("concilia"));
				session.saveOrUpdate(formaPagamento);
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
