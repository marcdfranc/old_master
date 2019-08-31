package com.marcsoftware.gateway;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Random;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.CartaoAcesso;
import com.marcsoftware.database.Funcionario;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.Profissional;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class ProfissionalAnexo
 */
public class ProfissionalAnexo extends HttpServlet {
	private static final long serialVersionUID = 1L;
    private PrintWriter out;
    private Session session;
    private Transaction transaction;
    private Query query;
    private Profissional profissional;
    private CartaoAcesso acesso;
    private List<CartaoAcesso> cartaoList;
    private Login login;
    private Random random;
    
    public ProfissionalAnexo() {
        super();
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("ISO-8859-1");
		response.setContentType("text/plain");
		out = response.getWriter();
		switch (Integer.parseInt(request.getParameter("from"))) {
		case 0:
			out.print(Util.encodeString(addLogin(request), "ISO-8859-1", "UTF8"));			
			break;

		case 1:
			out.print(Util.encodeString(gerarCartao(request), "UTF8", "ISO-8859-1"));
			break;
			
		case 2:
			out.print(Util.encodeString(blockCartao(request), "UTF8", "ISO-8859-1"));			
			break;
			
		case 3:
			out.print(Util.encodeString(liberarAcesso(request), "UTF8", "ISO-8859-1"));
			break;
			
		case 4:
			out.print(Util.encodeString(editPort(request), "UTF8", "ISO-8859-1"));
			break;
			
		case 5:
			out.print(Util.encodeString(delCartao(request), "UTF8", "ISO-8859-1"));			
			break;
			
		case 6:
			out.print(Util.encodeString(editObs(request), "UTF8", "ISO-8859-1"));
			break;
		}
		out.close();
	}
	
	private String addLogin(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			profissional = (Profissional) session.get(Profissional.class, Long.valueOf(request.getParameter("idProfissional")));
			if (profissional.getLogin() == null) {
				login = new Login();
				login.setPerfil("r");
				login.setPorta("");
				login.setSenha(request.getParameter("senha"));
				login.setTries(0);
				login.setUsername(request.getParameter("login"));				
				session.save(login);				
				profissional.setLogin(login);				
				session.update(profissional);				
			} else {
				profissional.getLogin().setUsername(request.getParameter("login"));
				profissional.getLogin().setSenha(request.getParameter("senha"));				
				session.update(profissional.getLogin());
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível salvar o login devido a um erro interno!";
		}
		return "Login salvo com sucesso";
	}
	
	private String gerarCartao(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			profissional = (Profissional) session.get(Profissional.class, Long.valueOf(request.getParameter("idProfissional")));
			if (profissional.getLogin() == null) {
				transaction.rollback();
				session.close();
				return "Não é possível a geração de cartão para profissionais sem Login!";
			}
			query = session.createQuery("from CartaoAcesso as c where c.login = :login");
			query.setEntity("login", profissional.getLogin());
			if (query.list().size() > 0) {
				transaction.rollback();
				session.close();
				return "Não é possível a geração do cartão devido a ja haver um cartão gerado!";
			}
			random = new Random();
			
			for (int i = 0; i < 50; i++) {
				acesso = new CartaoAcesso();
				acesso.setIndex(i + 1);
				acesso.setLogin(profissional.getLogin());
				acesso.setNumero(random.nextInt(99999));
				acesso.setStatus("a");
				
				session.save(acesso);
			}
			session.flush();
			transaction.commit();
			session.close();			
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível gerar o cartão devido a um erro interno!";
		}		
		return "Cartão gerado com sucesso";
	}
	
	private String blockCartao(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			query = session.createQuery("select f.login from Profissional as f where f.codigo = :profissional");
			query.setLong("profissional", Long.valueOf(request.getParameter("idProfissional")));
			if (query.list().size() == 0) {
				transaction.rollback();
				session.close();
				return "Este profissional não possui login para ser bloqueado!"; 
			}
			login = (Login) query.uniqueResult();
			login.setTries(4);
			session.update(login);			
			
			query = session.createQuery("from CartaoAcesso as c where c.login = :login");
			query.setEntity("login", login);
			cartaoList = (List<CartaoAcesso>) query.list();
			for (CartaoAcesso cartao : cartaoList) {
				cartao.setStatus("f");
				session.update(cartao);
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível bloquear o cartão devido a um erro interno!";
		}
		return "Cartão bloqueado com sucesso!";
	}
	
	private String liberarAcesso(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			query = session.createQuery("select f.login from Profissional as f where f.codigo = :profissional");
			query.setLong("profissional", Long.valueOf(request.getParameter("idProfissional")));
			if (query.list().size() == 0) {
				transaction.rollback();
				session.close();
				return "Este profissional não possui login para ser liberado!"; 
			}
			login = (Login) query.uniqueResult();
			login.setTries(0);
			session.update(login);			
			
			query = session.createQuery("from CartaoAcesso as c where c.login = :login");
			query.setEntity("login", login);
			cartaoList = (List<CartaoAcesso>) query.list();
			for (CartaoAcesso cartao : cartaoList) {
				cartao.setStatus("a");
				session.update(cartao);
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível liberar o cartão devido a um erro interno!";
		}
		return "Cartão liberado com sucesso!";
	}
	
	private String editPort(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			query = session.createQuery("select f.login from Profissional as f where f.codigo = :profissional");
			query.setLong("profissional", Long.valueOf(request.getParameter("idProfissional")));
			if (query.list().size() == 0) {
				transaction.rollback();
				session.close();
				return "Este profissional não possui login para ser configurada uma porta!"; 
			}
			login = (Login) query.uniqueResult();
			login.setPorta(request.getParameter("porta"));			
			session.update(login);
			
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível alterar a porta devido a um erro interno!";
		}
		return "Porta alterada com sucesso!";
	}
	
	private String delCartao(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			query = session.createQuery("select f.login from Profissional as f where f.codigo = :profissional");
			query.setLong("profissional", Long.valueOf(request.getParameter("idProfissional")));
			if (query.list().size() == 0) {
				transaction.rollback();
				session.close();
				return "Este profissional não possui login!"; 
			}
			login = (Login) query.uniqueResult();
			query = session.createQuery("from CartaoAcesso as c where c.login = :login");
			query.setEntity("login", login);
			cartaoList = (List<CartaoAcesso>) query.list();
			for (CartaoAcesso cartao : cartaoList) {				
				session.delete(cartao);
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível deletar o cartão devido a um erro interno!";
		}
		return "Cartão deletado com sucesso!";
	}
	
	private String editObs(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			profissional = (Profissional) session.get(Profissional.class, Long.valueOf(request.getParameter("idProfissional")));
			profissional.setObservacao(Util.encodeString(request.getParameter("obs"), "ISO-8859-1", "UTF8"));			
			session.update(profissional);			
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Ocorreu um erro durante o processo de salvamento da observação!";
		}
		return "Observação salva com sucesso!";
	}
}
