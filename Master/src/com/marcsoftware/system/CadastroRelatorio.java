package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Relatorio;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroRelatorio
 */
public class CadastroRelatorio extends HttpServlet {
	private static final long serialVersionUID = 1L;
    private Session session;
    private Transaction transaction;
    private Query query;
    private Relatorio relatorio;
    private List<Relatorio> relatorioList;
    private PrintWriter out;
    private boolean isFilter;
    private int limit, offSet, gridLines;
    private Filter filter;
    private DataGrid dataGrid;
	
    public CadastroRelatorio() {
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
		relatorioList = (List<Relatorio>) query.list();
		if (relatorioList.size() == 0) {
			out.print("0");
			transaction.commit();
			session.close();
			out.close();
			return;
		}
		dataGrid = new DataGrid(null);
		for (Relatorio rel : relatorioList) {
			dataGrid.setId(String.valueOf(rel.getCodigo()));
			dataGrid.addData(String.valueOf(rel.getCodigo()));
			dataGrid.addData(Util.encodeString(rel.getNome(),"UTF8", "ISO-8859-1"));
			dataGrid.addData(rel.getTela());
			if (rel.getTipo().trim().equals("b")) {
				dataGrid.addData("Birt Report");
			} else {
				dataGrid.addData("Jasper Report");
			}						
			if (rel.getTipo().trim().equals("s")) {
				dataGrid.addData("Sim");								
			} else {
				dataGrid.addData(Util.encodeString("Não", "UTF8", "ISO-8859-1"));
			}						
			dataGrid.addRow();
		}
		transaction.commit();
		out.print(dataGrid.getBody(gridLines));
		out.close();
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		//try {
			if (addRecord(request))  {
				response.sendRedirect("application/relatorio_adm.jsp");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
				"&lk=application/relatorio_adm.jsp");
			}
		/*} catch (SQLException e) {			
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
			"&lk=application/cliente_fisico.jsp");
		}*/
	}
	
	private void mountFilter(HttpServletRequest request) {
		filter = new Filter("from Relatorio as r");
		
		if (!request.getParameter("codigoIn").equals("")) {
			filter.addFilter("r.codigo = :relatorio", Long.class, "relatorio",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("codigoIn"))));
		}
		if (!request.getParameter("nomeIn").equals("")) {
			filter.addFilter("r.nome LIKE :nome", String.class, "nome", 
					"%" + request.getParameter("nomeIn") + "%");
		}
		if (!request.getParameter("telaIn").equals("")) {
			filter.addFilter("r.tela LIKE :tela", String.class, "tela", 
					"%" + request.getParameter("telaIn") + "%");
		}
		if (!request.getParameter("tipoIn").equals("")) {
			filter.addFilter("r.tipo = :tipo", String.class, "tipo", 
					request.getParameter("tipoIn"));
		}
		if (!request.getParameter("dinamicoIn").equals("")) {
			filter.addFilter("r.dinamico = :dinamico", String.class, "dinamico", 
					request.getParameter("dinamicoIn"));
		}
		filter.setOrder("r.codigo");
	}
	
	private boolean addRecord(HttpServletRequest request) {
		boolean isEdition= (request.getParameter("codRel") != "");		
		session= HibernateUtil.getSession();
		transaction= session.beginTransaction();
		try {
			relatorio = new Relatorio();
			if (isEdition) {
				relatorio.setCodigo(Long.valueOf(request.getParameter("codRel")));
			}
			relatorio.setComando(request.getParameter("comandoIn"));
			relatorio.setOrdem(request.getParameter("ordemIn"));
			relatorio.setDescricao(request.getParameter("descricaoIn"));
			if (request.getParameter("dinamicoIn").trim().equals("") 
					&& (!request.getParameter("birtView").trim().equals(""))) {
				relatorio.setDinamico(request.getParameter("birtView"));
			} else if ((!request.getParameter("dinamicoIn").trim().equals(""))
					&& request.getParameter("birtView").trim().equals("")) {
				relatorio.setDinamico(request.getParameter("dinamicoIn"));				
			} else {
				relatorio.setDinamico(null);
			}
			relatorio.setNome(request.getParameter("nomeIn").toLowerCase());
			relatorio.setPath(request.getParameter("pathIn"));
			relatorio.setTela(request.getParameter("telaIn"));
			relatorio.setTipo(request.getParameter("tipoIn"));
			relatorio.setHeightFiltro(Integer.parseInt(request.getParameter("heightIn")));
			relatorio.setWidthFiltro(Integer.parseInt(request.getParameter("widthIn")));
			session.saveOrUpdate(relatorio);			
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

}
