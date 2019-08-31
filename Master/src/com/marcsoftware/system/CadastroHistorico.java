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

import com.marcsoftware.database.HistoricoNavegacao;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroHistorico
 */
public class CadastroHistorico extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CadastroHistorico() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PrintWriter out = response.getWriter();
		if (request.getParameter("from").equals("0")) {
			
		} else {
			Session session = HibernateUtil.getSession();			
			try {				
				Query query = session.createQuery("from HistoricoNavegacao as h where h.acesso.codigo = :idAcesso order by h.codigo desc"); 
				query.setLong("idAcesso", Long.valueOf(request.getParameter("idAcesso")));
				int gridLines= query.list().size();
				int limit = Integer.parseInt(request.getParameter("limit"));
				int offSet = Integer.parseInt(request.getParameter("offset")); 
				query.setFirstResult(offSet);
				query.setMaxResults(limit);
				List<HistoricoNavegacao> historicoNavegacao = (List<HistoricoNavegacao>) query.list();
				if (historicoNavegacao.size() == 0) {
					out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td><td></td><td></td></tr>");
					return;
				}
				DataGrid dataGrid = new DataGrid("");
				for (HistoricoNavegacao historico : historicoNavegacao) {
					dataGrid.setId(String.valueOf(historico.getCodigo()));
					dataGrid.addData(String.valueOf(historico.getCodigo()));
					dataGrid.addData(Util.parseDate(historico.getData(), "dd/MM/yyyy"));
					dataGrid.addData(Util.getTime(historico.getData()));
					dataGrid.addData(historico.getUrl());
					dataGrid.addRow();
				}
				out.print(dataGrid.getBody(gridLines));				
			} catch (Exception e) {
				e.printStackTrace();
				out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td><td></td><td></td></tr>");
			} finally {
				out.close();
				session.close();
			}
		}
	}

}
