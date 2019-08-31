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
import com.marcsoftware.database.Fisica;
import com.marcsoftware.database.Funcionario;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class RHAnexo
 */
public class RHAnexo extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private PrintWriter out;
	private Session session;
	private Transaction transaction;
	private Query query;
	private Funcionario funcionario;
	private CartaoAcesso acesso;
	private List<CartaoAcesso> cartaoList;
	private Login login;
	private Random random;
    
    public RHAnexo() {
        super();
        // TODO Auto-generated constructor stub
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
			funcionario = (Funcionario) session.get(Funcionario.class, Long.valueOf(request.getParameter("idRh")));
			if (funcionario.getLogin() == null) {
				login = new Login();
				if (Boolean.parseBoolean(request.getParameter("isAdm")) && request.getParameter("idUnidade") != null && !request.getParameter("idUnidade").isEmpty())  {
					login.setPerfil("f");
				} else {
					login.setPerfil("r");					
				}
				login.setPorta("");
				login.setSenha(request.getParameter("senha"));
				login.setTries(0);
				login.setUsername(request.getParameter("login"));				
				funcionario.setLogin(login);
				session.save(login);				
				session.update(funcionario);
				
				if (Boolean.parseBoolean(request.getParameter("isAdm")) && request.getParameter("idUnidade") != null && !request.getParameter("idUnidade").isEmpty())  {
					Unidade unidade = (Unidade) session.get(Unidade.class, Long.valueOf(request.getParameter("idUnidade")));
					
					unidade.setAdministrador(funcionario);
					
					session.update(unidade);
				}
			} else {
				funcionario.getLogin().setUsername(request.getParameter("login"));
				funcionario.getLogin().setSenha(request.getParameter("senha"));				
				session.update(funcionario.getLogin());
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
		String tipo = (request.getParameter("tipo").equals("f"))? " funcionários " : " administrador ";
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();		
		try {
			Fisica fisica = (Fisica) session.get(Fisica.class, Long.valueOf(request.getParameter("idRh")));
			if (fisica.getLogin() == null) {
				transaction.rollback();
				session.close();
				return "Não é possível a geração de cartão para" + tipo + "sem Login!";
			}
			query = session.createQuery("from CartaoAcesso as c where c.login = :login");
			query.setEntity("login", fisica.getLogin());
			if (query.list().size() > 0) {
				transaction.rollback();
				session.close();
				return "Não é possível a geração do cartão devido a ja haver um cartão gerado!";
			}
			random = new Random();
			
			for (int i = 0; i < 50; i++) {
				acesso = new CartaoAcesso();
				acesso.setIndex(i + 1);
				acesso.setLogin(fisica.getLogin());
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
		String tipo = (request.getParameter("tipo").equals("f"))? " funcionário " : " administrador ";
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			query = session.createQuery("select f.login from Fisica as f where f.codigo = :fisica");
			query.setLong("fisica", Long.valueOf(request.getParameter("idRh")));
			if (query.list().size() == 0) {
				transaction.rollback();
				session.close();
				return "Este" + tipo + "não possui login para ser bloqueado!"; 
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
		String tipo = (request.getParameter("tipo").equals("f"))? " funcionário " : " administrador ";
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			query = session.createQuery("select f.login from Fisica as f where f.codigo = :fisica");
			query.setLong("fisica", Long.valueOf(request.getParameter("idRh")));
			if (query.list().size() == 0) {
				transaction.rollback();
				session.close();
				return "Este"+ tipo + "não possui login para ser liberado!"; 
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
			query = session.createQuery("select f.login from Funcionario as f where f.codigo = :funcionario");
			query.setLong("funcionario", Long.valueOf(request.getParameter("idRh")));
			if (query.list().size() == 0) {
				transaction.rollback();
				session.close();
				return "Este funcionário não possui login para ser configurada uma impressora!"; 
			}
			login = (Login) query.uniqueResult();
			login.setPorta(request.getParameter("porta"));
			if (!request.getParameter("colunas").isEmpty()) {
				login.setColunas(Integer.parseInt(request.getParameter("colunas")));
			}
			login.setHeaderCupom(Util.encodeString(request.getParameter("headerCupom"), "ISO-8859-1","UTF8"));
			login.setSubHeader(Util.encodeString(request.getParameter("subHeader"), "ISO-8859-1","UTF8"));
			login.setFooterCupom(Util.encodeString(request.getParameter("footerCupom"), "ISO-8859-1","UTF8"));
			login.setSubFooter(Util.encodeString(request.getParameter("subFooter"), "ISO-8859-1","UTF8"));
			session.update(login);
			
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível alterar as configurações devido a um erro interno!";
		}
		return "Configurações alteradas com sucesso!";
	}
	
	private String delCartao(HttpServletRequest request) {
		String tipo = (request.getParameter("tipo").equals("f"))? " funcionário " : " administrador ";
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			query = session.createQuery("select f.login from Fisica as f where f.codigo = :fisica");
			query.setLong("Fisica", Long.valueOf(request.getParameter("idRh")));
			if (query.list().size() == 0) {
				transaction.rollback();
				session.close();
				return "Este" + tipo + "não possui login!"; 
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
			funcionario = (Funcionario) session.get(Funcionario.class, Long.valueOf(request.getParameter("idRh")));
			funcionario.setObservacao(Util.encodeString(request.getParameter("obs"), "ISO-8859-1", "UTF8"));			
			session.update(funcionario);			
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível salvar a observação devido a um erro interno!";
		}
		return "Observação salva com sucesso!";
	}
}
