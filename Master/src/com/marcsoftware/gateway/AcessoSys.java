package com.marcsoftware.gateway;

import java.io.IOException;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Acesso;
import com.marcsoftware.database.CartaoAcesso;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class AcessoSys
 */
public class AcessoSys extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private CartaoAcesso cartao;
	private Login login;
	private Acesso acesso;
	private List<Acesso> acessoList;
	private Unidade unidade;
	private Session session;
	private Transaction transaction;
	private Query query;
    
    public AcessoSys() {
        super();
        
    }
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		Date now = new Date();
		query = session.createQuery("from Login as l where l.username = :username");
		query.setString("username", request.getSession().getAttribute("username").toString());
		login = (Login) query.uniqueResult();
		
		query = session.createQuery("from CartaoAcesso as c " +
				" where c.numero = :numero " +
				" and c.index = :index " +
				" and c.status = 'a'");
		if (request.getParameter("password").trim().equals("") 
				|| request.getParameter("numeroAcesso").trim().equals("")) {
			login.setTries(login.getTries() + 1);
			session.update(login);
			
			session.flush();
			
			transaction.commit();
			session.close();
			response.sendRedirect("error_page.jsp?errorMsg=\'" + Util.SENHA_INVALIDA + "\'");
			return;
		}
		query.setInteger("numero", Integer.parseInt(Util.removeZeroLeft(request.getParameter("password"))));
		query.setInteger("index", Integer.parseInt(request.getParameter("numeroAcesso")));
		if (query.list().size() == 0) {
			login.setTries(login.getTries() + 1);
			session.update(login);
			
			session.flush();
			
			transaction.commit();
			session.close();
			response.sendRedirect("error_page.jsp?errorMsg=\'" + Util.SENHA_INVALIDA + "\'");
			return;
		} else {
			cartao = (CartaoAcesso) query.uniqueResult();
			if (cartao.getLogin().getTries() > 3) {
				transaction.commit();
				session.close();
				response.sendRedirect("error_page.jsp?errorMsg=\'Usuário não autorizado! Consulte o admisnistrador do sistema para liberação.'&lk='Termination'");
				return;
			}			
			cartao.getLogin().setTries(0);
			session.update(cartao.getLogin());
			
			cartao.setStatus("f");
			
			session.update(cartao);
			
			query = session.createQuery("from Acesso as a where a.saida is null and a.login = :login");
			query.setEntity("login", login);			
			acessoList = (List<Acesso>) query.list();
			for (Acesso acc : acessoList) {
				acc.setSaida(now);
				session.update(acc);
			}
			
			
			
			unidade = (Unidade) session.get(Unidade.class, 
					Long.valueOf(
							request.getSession().getAttribute("unidade").toString()));
			
			
			acesso = new Acesso();
			acesso.setEntrada(now);
			acesso.setIp(request.getRemoteAddr());
			acesso.setLogin(cartao.getLogin());
			acesso.setUnidade(unidade);
			
			session.save(acesso);
			
			request.getSession().setAttribute("acessoId", String.valueOf(acesso.getCodigo()));
			
			session.flush();
			request.getSession().setAttribute("numCartao", cartao.getNumero());			
			request.getSession().setAttribute("indexCartao", cartao.getIndex());
			transaction.commit();
			session.close();
			response.sendRedirect("application/forum.jsp");
		}	
	}

}
