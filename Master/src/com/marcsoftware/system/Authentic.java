package com.marcsoftware.system;


import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.List;



import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.AcessoNotificacao;
import com.marcsoftware.database.Caixa;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.Notificacao;
import com.marcsoftware.database.Pessoa;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.ControleErro;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


/**
 * Servlet implementation class for Servlet: Authentic
 *
 */
 public class Authentic extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
   static final long serialVersionUID = 102831973239L;
   private Login login;
   private Pessoa pessoa;
   private Caixa caixa;
   private Date now;
   private String path, username, perfil;
   
   private List<Login> list;   
   private Transaction transaction;
   private Query query;
   private PrintWriter out;
       
	public Authentic() {
		super();
		path= new String();
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		now = new Date();
		
		String logotipo = "../report/logo/logo798.png";
		Unidade unidadeAux;
		Session session= HibernateUtil.getSession();		
		transaction= session.beginTransaction();
		query= session.createQuery("from Login as l " +
				"where l.username= :username and l.senha= :senha");
		query.setString("username", request.getParameter("username"));		
		query.setString("senha", request.getParameter("password"));
		List<Notificacao> notificacaoList;
		list= (List<Login>) query.list();
		if (list.size() == 1) {
			login = (Login) query.uniqueResult();
			if (login.getTries() > 3) {
				transaction.commit();
				session.close();
				response.sendRedirect("error_page.jsp?errorMsg=\'Este usuario foi bloqueado por tentativas excessivas de acesso através do IP \'" + request.getRemoteAddr() + "\' o qual já se encontra em análise. Procure o administrador do sistema caso tenha esquecido a senha evitando assim investigações desnecessárias.'");
				return;
			}			
			query = session.createQuery("from CartaoAcesso as c where c.login = :login and c.status = 'a'");
			query.setEntity("login", login);
			if (query.list().size() == 0) {
				login.setTries(login.getTries() + 1);
				session.update(login);
				
				session.flush();
				transaction.commit();
				session.close();
				response.sendRedirect("error_page.jsp?errorMsg=\'Usuário não autorizado! Consulte o admisnistrador do sistema para liberação.'");
				return;
			}	
			
			username = list.get(0).getUsername();
			perfil = list.get(0).getPerfil().trim();
			if (perfil.equals("d")) {
				path= "application/unidade.jsp";
				request.getSession().setAttribute("numCartao", 2807);			
				request.getSession().setAttribute("indexCartao", 1);
				request.getSession().setAttribute("acessoId", -1);
			} else {
				path= "login.jsp";				 
			}			
			request.getSession().setAttribute("username", username);
			request.getSession().setAttribute("perfil", perfil);
			query = session.createQuery("select a.id.notificacao from AcessoNotificacao as a " +
					" where a.id.login.username = :username and a.id.notificacao.status = 'a' " +
					" and a.visualizada = 'n'");
			query.setString("username", username);
			notificacaoList = (List<Notificacao>) query.list();
			request.getSession().setAttribute("notificacaoList", notificacaoList);
			request.getSession().setAttribute("saIsOpen", "n");
			query = session.createQuery("from Unidade as u where u.administrador.login.username = :username");
			query.setString("username", username);
			ArrayList<Unidade> unidades = new ArrayList<Unidade>();
			if (query.list().size() == 1) {
				unidadeAux = (Unidade) query.uniqueResult(); 
				request.getSession().setAttribute("unidade", 
						unidadeAux.getCodigo());
				unidades.add(unidadeAux);
				
				request.getSession().setAttribute("unidades", unidades);
				
				request.getSession().setAttribute("caixaOpen", "f");
				if (unidadeAux.getLogo() != null && !unidadeAux.getLogo().isEmpty()) {
					logotipo = unidadeAux.getLogo();
				}
			} else if (query.list().size() > 1){
				unidades = (ArrayList<Unidade>) query.list();
				request.getSession().setAttribute("unidades", unidades);
				request.getSession().setAttribute("unidade", -1);
				request.getSession().setAttribute("caixaOpen", "f");
			} else if (perfil.trim().equals("a")  || perfil.trim().equals("d")){
				request.getSession().setAttribute("unidades", unidades);
				request.getSession().setAttribute("unidade", 0);
				request.getSession().setAttribute("caixaOpen", "f");
			} else {
				request.getSession().setAttribute("unidades", unidades);
				query = session.createQuery("from Pessoa as p where p.login.username = :username");
				query.setString("username", username);
				pessoa  = (Pessoa) query.uniqueResult();
				request.getSession().setAttribute("unidade", pessoa.getUnidade().getCodigo());
				if (pessoa.getUnidade().getLogo() != null && !pessoa.getUnidade().getLogo().isEmpty()) {
					logotipo = pessoa.getUnidade().getLogo();
				}
				query = session.createQuery("from Caixa as c where c.login = :login " +
						"and c.status = 'a'");
				query.setEntity("login", login);								
				if (query.list().size() > 0) {
					caixa = (Caixa) query.uniqueResult();
					if (Math.abs(Util.diferencaDias(now, Util.getZeroDate(caixa.getInicio()))) > 0) {
						request.getSession().setAttribute("caixaOpen", "f");
					} else {
						request.getSession().setAttribute("caixaOpen", "t");
					}
				} else if (query.list().size() == 0){
					request.getSession().setAttribute("caixaOpen", "f");
				} else {
					request.getSession().setAttribute("caixaOpen", "t");
				}
			}			
		} else {
			path= "error_page.jsp?errorMsg=\'" + Util.SENHA_INVALIDA + "\'";
		}
		request.getSession().setAttribute("logo", logotipo);		
		ControleErro erro = new ControleErro();
		transaction.commit();
		session.close();		
		request.getSession().setAttribute("hb", session);
		request.getSession().setAttribute("erro", erro);
		response.sendRedirect(path);
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String nomeHeader = "";
		String headerValue = "";
		request.setCharacterEncoding("ISO-8859-1");
		response.setContentType("text/plain");		
		out = response.getWriter();		
		out.println("IP: " + request.getRemoteAddr());
		out.println("HOST: " + request.getRemoteHost());
		out.println("PORTA: " + request.getRemotePort());
		out.println();
		Enumeration headers = request.getHeaderNames();
		while (headers.hasMoreElements()) {
			nomeHeader = (String) headers.nextElement();
			headerValue = request.getHeader(nomeHeader);
			out.println("HEADER: [" + nomeHeader + " = " + headerValue + "]");
		}
		out.close();
		return;
	}
		
}