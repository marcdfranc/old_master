package com.marcsoftware.gateway;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;



/**
 * Servlet implementation class for Servlet: BancoGet
 *
 */
 public class ContaReceber extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
	 static final long serialVersionUID = 1L;
	 private List<Lancamento> lancamento;
	 private int limit, offSet, gridLines;
	 private boolean isFilter;
	 private Filter filter;
	 private DataGrid dataGrid;
	 private PrintWriter out;
	 private Session session;
	 private Transaction transaction;
	 private Query query;
	 
	public ContaReceber() {
		super();
	}
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
		lancamento= (List<Lancamento>) query.list();
		if (lancamento.size() == 0) {
			out.print("0");
			transaction.commit();
			session.close();
			out.close();
			return;
		}
		dataGrid= new DataGrid("#");
		for (Lancamento lc: lancamento) {
			dataGrid.setId(String.valueOf(lc.getCodigo()));
			dataGrid.addData(String.valueOf(lc.getCodigo()));
			dataGrid.addData((lc.getDocumento() == null)? "": lc.getDocumento());
			dataGrid.addData(Util.encodeString(lc.getConta().getDescricao(), 
					"UTF8", "ISO-8859-1"));
			dataGrid.addData(lc.getUnidade().getReferencia());
			dataGrid.addData((lc.getTipo().trim().equals("c"))? 
					Util.encodeString("Crédito", "UTF8", "ISO-8859-1") :
						Util.encodeString("Débito", "UTF8", "ISO-8859-1"));			
			switch (lc.getStatus().charAt(0)) {
				case 'a':
					dataGrid.addData("aberto");
					break;
				
				case 'q':
					dataGrid.addData("quitado");
					break;
					
				case 'v':
					dataGrid.addData("Atrasado");
					break;
					
				default:
					dataGrid.addData("");
				break;
			}
			dataGrid.addData(Util.parseDate(lc.getVencimento(), "dd/MM/yyyy"));
			dataGrid.addData(Util.formatCurrency(String.valueOf(lc.getValor())));
			dataGrid.addRow();
		}
		transaction.commit();
		out.print(dataGrid.getBody(gridLines));
		out.close();
	}
	
	private void mountFilter(HttpServletRequest request) {
		if (request.getParameter("from").trim().equals("0")) {
			filter = new Filter("from Lancamento as l where l.tipo = 'c' " +
				" and l.status = 'a'");
		} else {
			filter = new Filter("from Lancamento as l where l.tipo = 'd' " +
				" and l.status = 'a'");	
		}
		
		if (!request.getParameter("lancamento").equals("")) {
			filter.addFilter("l.codigo = :lancamento", Long.class, "lancamento",
					Long.valueOf(request.getParameter("lancamento")));
		}
		if (!request.getParameter("documento").equals("")) {
			filter.addFilter("l.documento like :documento",
					String.class, "documento", 
					"%" + request.getParameter("documento").toLowerCase() + "%");
		}
		if (!request.getParameter("descricao").equals("")) {
			filter.addFilter("l.conta.descricao LIKE :descricao", String.class, "descricao", 
					"%" + request.getParameter("descricao").toLowerCase() + "%");
		}
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("l.unidade.codigo = :unidade", Long.class, "unidade",
					Long.valueOf((Util.getPart(request.getParameter("unidadeId"), 2))));
		}
		if (!request.getParameter("statusLancamento").equals("")) {
			filter.addFilter("l.status = :status",
					String.class, "status", request.getParameter("statusLancamento"));
		}		
		filter.setOrder("l.vencimento desc, l.conta.descricao");
	}	
}