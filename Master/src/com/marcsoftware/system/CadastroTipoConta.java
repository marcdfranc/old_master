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

import com.marcsoftware.database.TipoConta;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroTipoConta
 */
public class CadastroTipoConta extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private TipoConta conta;
	private List<TipoConta> contaList;
	private int limit, offSet, gridLines;
	private PrintWriter out;
	private DataGrid dataGrid;
    private Session session;
    private Transaction transaction;
    private Query query;
    private boolean isEdition, isDel;
        
    public CadastroTipoConta() {
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
		offSet = Integer.parseInt(request.getParameter("offset"));
		if (request.getSession().getAttribute("perfil").toString().equals("d")) {
			query= session.createQuery("from TipoConta as c order by c.codigo");
		} else {
			query = session.createQuery("from TipoConta as t where t.administrativo = 'n' order by t.codigo");
		}
		gridLines= query.list().size();
		query.setFirstResult(offSet);
		query.setMaxResults(limit);
		contaList = (List<TipoConta>) query.list();		
		if (contaList.size() == 0) {
			out.print("<tr><td></td><td><p>" + Util.encodeString(Util.SEM_REGISTRO, 
					"UTF8", "ISO-8859-1") + "</p></td></tr>");
			session.close();
			out.close();
			return;
		}
		dataGrid= new DataGrid(null);
		for (TipoConta ct : contaList) {
			dataGrid.setId(String.valueOf(ct.getCodigo()));
			dataGrid.addData(String.valueOf(ct.getCodigo()));
			dataGrid.addData(Util.initCap(ct.getDescricao()));
			if (request.getSession().getAttribute("perfil").toString().equals("d")) {
				dataGrid.addData((ct.getAdministrativo().equals("s"))? "Sim" : "Não");
			}
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
				query = session.createQuery("from TipoConta as t where t.codigo = :codigo");
				query.setLong("codigo", Long.valueOf(request.getParameter("id")));
				conta = (TipoConta) query.uniqueResult();
				session.delete(conta);
			} else {
				String descricao= Util.encodeString(request.getParameter("descricaoIn"), "ISO-8859-1", "UTF8");
				if (isEdition) {
					conta = (TipoConta) session.load(TipoConta.class, Long.valueOf(request.getParameter("id")));
				} else {
					conta = new TipoConta();
				}
				conta.setDescricao(descricao.toLowerCase());
				conta.setAdministrativo(request.getParameter("adm"));				
				session.saveOrUpdate(conta);
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
