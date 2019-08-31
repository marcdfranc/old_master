package com.marcsoftware.client;

import java.io.IOException;
import java.io.PrintWriter;


import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;

import com.marcsoftware.database.Dependente;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class LoginCliente
 */
public class LoginCliente extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Usuario usuario;
	private Dependente dependente;
	private Query query;
	private Session session;
	private PrintWriter out;
	
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public LoginCliente() {
        super();
        
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String aux = "";
		String strCompare = "";
		response.setContentType("text/plain");
		out= response.getWriter();
		try {
			session = HibernateUtil.getSession();
			query = session.createQuery("from Usuario as u where u.cpf = :cpf");
			query.setString("cpf", Util.unMountDocument(request.getParameter("senha")));
			strCompare = Util.removeZeroLeft(request.getParameter("username"));
			if (query.list().size() == 0) {
				query = session.createQuery("from Dependente as d where d.cpf = :cpf");
				query.setString("cpf", Util.unMountDocument(request.getParameter("senha")));
				if (query.list().size() == 0) {
					out.print("n");
					out.close();
					session.close();
					return;
				} else if (query.list().size() > 1) {
					out.print("m");
					out.close();
					session.close();
					return;
				} else {
					dependente = (Dependente) query.uniqueResult();
					aux+= dependente.getUsuario().getContrato().getCodigo() + "-" +
						dependente.getReferencia() + "/" + 
						dependente.getUsuario().getUnidade().getReferencia();
					if (aux.equals(strCompare)) {
						aux+= "@" + dependente.getNome() + "@d@" + 
							dependente.getUsuario().getUnidade().getCodigo() + "@" +
							dependente.getCpf() + "@" + dependente.getCodigo();
						out.print(aux);
					} else {
						out.print("n");
						out.close();
						session.close();
						return;
					}
				}
			} else if (query.list().size() > 1) {
				out.print("m");
				out.close();
				session.close();
				return;
			} else {
				usuario = (Usuario) query.uniqueResult();				
				aux+= usuario.getContrato().getCodigo() + "-0/" + 
					usuario.getUnidade().getReferencia();
				if (aux.equals(strCompare)) {
					aux+= "@" + usuario.getNome() + "@t@" +
						usuario.getUnidade().getCodigo() + "@" + usuario.getCpf() + 
						"@" + usuario.getCodigo();
					out.print(aux);
				} else {
					out.print("n");
					out.close();
					session.close();
					return;
				}
			}
			out.close();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			session.close();
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
	}

}
