package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Especialidade;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Servico;
import com.marcsoftware.database.Tabela;
import com.marcsoftware.database.TabelaId;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class for Servlet: CadastroServico
 *
 */
public class CadastroServico extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
	static final long serialVersionUID = 1L;
	private Servico servico;
	private Tabela tabela;
	private TabelaId idTable;
	private Especialidade especialidade;
	private Unidade unidade;
	private boolean isFilter;
	private int limit, offSet, gridLines;
	private List<Servico> servicoList;
	private DataGrid dataGrid;
	private Filter filter;
	private PrintWriter out;
	private Session session;
	private Transaction transaction;
	private Query query;
	    
	public CadastroServico() {
		super();
	}	
		
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("ISO-8859-1");				
		response.setContentType("text/html");
		response.setCharacterEncoding("ISO-8859-1");
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
		servicoList = (List<Servico>) query.list();
		if (servicoList.size() == 0) {
			out.print("0");
			transaction.commit();
			session.close();
			out.close();
			return;
		}
		dataGrid = new DataGrid("cadastro_servico.jsp");
		for(Servico serv: servicoList) {
			dataGrid.setId(String.valueOf(serv.getCodigo()));
			dataGrid.addData(serv.getReferencia());
			if (serv.getEspecialidade().getSetor().equals("o")) {
				dataGrid.addData("Odontológico");								
			} else if (serv.getEspecialidade().getSetor().equals("m")){
				dataGrid.addData("Médico");
			} else if (serv.getEspecialidade().getSetor().equals("l")){
				dataGrid.addData("Laboratorial");
			} else {
				dataGrid.addData("Hospitalar");
			}
			dataGrid.addData(Util.initCap(serv.getEspecialidade().getDescricao()));
			dataGrid.addData(Util.initCap(serv.getDescricao()));
			dataGrid.addRow();
		}
		transaction.commit();
		out.print(dataGrid.getBody(gridLines));
		session.close();
		out.close();		
	}	
		
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			if (addRecord(request))  {
				response.sendRedirect("application/servico.jsp");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
				"&lk=application/cliente_fisico.jsp");
			}			
		} catch (Exception e) {			
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
			"&lk=application/cliente_fisico.jsp");
		}
	}
	
	private boolean addRecord(HttpServletRequest request) {
		boolean isEdition= ((request.getParameter("codServico") != "") && 
				(request.getParameter("codServico") != ""));
		session= HibernateUtil.getSession();		
		transaction= session.beginTransaction();		
		try {
			query = session.createQuery("from Especialidade as e where e.codigo = :codigo");
			query.setLong("codigo", Long.valueOf(request.getParameter("especialidadeIn")));
			especialidade= (Especialidade) query.uniqueResult();
			if (isEdition) {
				servico = (Servico) session.get(Servico.class, Long.valueOf(request.getParameter("codServico")));
			} else {
				servico= new Servico();
			}
			servico.setEspecialidade(especialidade);
			servico.setReferencia(request.getParameter("codigoIn"));
			servico.setDescricao(request.getParameter("descricaoIn").toLowerCase());
			session.saveOrUpdate(servico);
			
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return false;
		}		
		return true;
	}
	
	private void mountFilter(HttpServletRequest request) {
		filter = new Filter("from Servico as s");
		if (!request.getParameter("referenciaIn").equals("")) {
			filter.addFilter("s.referencia = :referencia",
					String.class, "referencia", request.getParameter("referenciaIn"));
		}
		if (!request.getParameter("setorIn").equals("")) {
			filter.addFilter("s.especialidade.setor = :setor",
					String.class, "setor", request.getParameter("setorIn"));
		}
		if (!request.getParameter("especialidadeIn").equals("")) {
			filter.addFilter("s.especialidade.descricao = :especialidade",
					String.class, "especialidade", request.getParameter("especialidadeIn"));
		}
		if (!request.getParameter("descricaoIn").equals("")) {
			filter.addFilter("s.descricao LIKE :descricao", String.class, "descricao", 
					"%" + Util.encodeString(request.getParameter("descricaoIn"), "ISO-8859-1", 
							"UTF8").toLowerCase()  + "%");
		}
		filter.setOrder("s.ref");
	}
}