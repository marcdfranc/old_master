package com.marcsoftware.system;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;


import com.marcsoftware.database.Acesso;
import com.marcsoftware.database.Login;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class Security implements Filter {
	private HttpSession session;
	private Session sess;
	private Query query;
	private Login login;	
	
	public void destroy() {
		// TODO Auto-generated method stub
		
	}
	
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {		
		boolean haveAccess = false;
		boolean isConected = true;
		Acesso acesso = null;
		Session sess = HibernateUtil.getSession();
		try {
			session= ((HttpServletRequest) request).getSession();
			
			query = sess.createQuery("from Login as l where l.username = :username");
			query.setString("username", (String)session.getAttribute("username"));						
			if (query.list().size() != 1) {
				((HttpServletResponse)response).sendRedirect("../error_page.jsp?errorMsg=\'" + 
						Util.ERRO + "\'");
			} else {				
				if (session.getAttribute("perfil").equals("d")) {
					isConected = true;
					haveAccess = true;
				} else {
					login = (Login) query.uniqueResult();
					
					query = sess.createQuery("from CartaoAcesso as c " +
							" where c.numero = :numero " +
							" and c.login = :login " +
					" and c.index = :index");
					query.setEntity("login", login);
					query.setInteger("numero", (Integer) session.getAttribute("numCartao"));
					query.setInteger("index", (Integer) session.getAttribute("indexCartao"));
					haveAccess = query.list().size() > 0;
					
					acesso = (Acesso) sess.get(Acesso.class, Long.valueOf(session.getAttribute("acessoId").toString()));
					
					isConected = acesso.getSaida() == null;					
				}
				
				if (haveAccess && isConected) {
					chain.doFilter(request, response);
				} else if (haveAccess){
					sess.close();
					((HttpServletResponse)response).sendRedirect("../error_page.jsp?errorMsg=\'" + 
							 "Sua sessão foi finalizada por outro usuário, ou você acessou o sistema de outro local." +
							 "Tente logar novamente e se o problema persistir procure " +
							 "o admninistrador do sistema. \'");
				} else {
					sess.close();
					((HttpServletResponse)response).sendRedirect("../error_page.jsp?errorMsg=\'" + 
							Util.ERRO + "\'");
				}
			}
		} catch (Exception e) {
			e.printStackTrace();			
		} finally {
			if (sess.isOpen()) {
				sess.close();
			}
		}
	}
	
	public void init(FilterConfig arg0) throws ServletException {
				
	}	
}
