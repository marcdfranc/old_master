package com.marcsoftware.gateway;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
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
import com.marcsoftware.database.Pessoa;
import com.marcsoftware.database.Profissional;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CartaoAdapter
 */
public class CartaoAdapter extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    
    public CartaoAdapter() {
        super();
    }

	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setCharacterEncoding("ISO-8859-1");
		response.setContentType("text/plain");
		PrintWriter out = response.getWriter();
		switch (Integer.parseInt(request.getParameter("from"))) {
		case 0:
			out.print(gerarCartao(request));
			break;

		case 1:
			out.print(getLogins(request));
			break;
			
		case 2:
			out.print(blockCartao(request));			
			break;
			
		case 3:
			out.print(liberarAcesso(request));
			break;
			
		case 4:
			out.print(delCartao(request));
			break;
		}
		out.close();
	}
	
	private String getLogins(HttpServletRequest request) {		
		String aux = "";
		boolean isFirst = true;
		Session session = HibernateUtil.getSession();
		try {
			Query query = null;
			if (request.getParameter("tipo").equals("f")) {
				query = session.createQuery("from Funcionario as f where " +
					"f.login.username <> null and f.unidade.codigo = :unidade");
				query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
				List<Funcionario> funcionarioList = (List<Funcionario>) query.list();
				for (Funcionario func : funcionarioList) {
					if (func.getLogin() != null) {
						if (isFirst) {
							isFirst = false;
							aux+= func.getLogin().getUsername();
						} else {
							aux+= "|" + func.getLogin().getUsername();
						}
					}
				}
			} else	if (request.getParameter("tipo").equals("u")) {
				query = session.createQuery("from Pessoa as p " +
						" where p.login.username <> null " +
						" and p.unidade.codigo = null");
				List<Pessoa> pessoaList = (List<Pessoa>) query.list();
				for (Pessoa pessoa : pessoaList) {
					if (pessoa.getLogin() != null) {
						if (isFirst) {
							isFirst = false;
							aux+= pessoa.getLogin().getUsername();
						} else {
							aux+= "|" + pessoa.getLogin().getUsername();
						}
					}
				}
			} else {				
				query = session.createQuery("from Profissional as p where " +
					"p.login.username <> null and p.unidade.codigo = :unidade");
				query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
				List<Profissional> profissionalList = (List<Profissional>) query.list();
				for (Profissional prof : profissionalList) {
					if (prof.getLogin() != null) {
						if (isFirst) {
							isFirst = false;
							aux+= prof.getLogin().getUsername();
						} else {
							aux+= "|" + prof.getLogin().getUsername();
						}
					}
				}
			}
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			session.close();			
			return "1@Erro";
		}			 
		return aux;		
	}
	
	private String gerarCartao(HttpServletRequest request) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query = null;
		Login login = null;
		CartaoAcesso acesso = null;
		Random random = null;
		try {
			ArrayList<String> pipe = Util.unmountPipelineStr(request.getParameter("pipe"));
			for (String pp : pipe) {
				query = session.createQuery("from Login as l where l.username = :login");
				query.setString("login", pp);
				login = (Login) query.uniqueResult();
				query = session.createQuery("from CartaoAcesso as c where c.login = :login");
				query.setEntity("login", login);
				if (query.list().size() > 0) {
					transaction.rollback();
					session.close();
					return "Não é possível a geração de cartões devido a haver Logins com cartões ja gerados!";
				}
				random = new Random();
				
				for (int i = 0; i < 50; i++) {
					acesso = new CartaoAcesso();
					acesso.setIndex(i + 1);
					acesso.setLogin(login);
					acesso.setNumero(random.nextInt(99999));
					acesso.setStatus("a");
					
					session.save(acesso);
				}
			}
			session.flush();
			transaction.commit();
			session.close();			
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível gerar os cartões devido a um erro interno!";
		}		
		return "Cartão gerado com sucesso";
	}
	
	private String blockCartao(HttpServletRequest request) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query = null;
		Login login;
		List<CartaoAcesso> cartaoList;
		try {
			ArrayList<String> pipe = Util.unmountPipelineStr(request.getParameter("pipe"));
			for (String pp : pipe) {
				query = session.createQuery("from Login as l where l.username = :login");
				query.setString("login", pp);
				login = (Login) query.uniqueResult();			
				login.setTries(4);
				session.update(login);			
				
				query = session.createQuery("from CartaoAcesso as c where c.login = :login");
				query.setEntity("login", login);
				cartaoList = (List<CartaoAcesso>) query.list();
				if (cartaoList.size() > 0) {
					for (CartaoAcesso cartao : cartaoList) {
						cartao.setStatus("f");
						session.update(cartao);
					}					
				} else {
					transaction.rollback();
					session.close();
					return "Não é possível bloquear acessos para usuarios sem cartão de acesso!";
				}
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível bloquear os cartões devido a um erro interno!";
		}
		return "Cartões bloqueados com sucesso!";
	}
	
	private String liberarAcesso(HttpServletRequest request) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query = null;
		Login login = null;
		List<CartaoAcesso> cartaoList;
		try {
			ArrayList<String> pipe = Util.unmountPipelineStr(request.getParameter("pipe"));
			for (String pp : pipe) {
				query = session.createQuery("from Login as l where l.username = :login");
				query.setString("login", pp);				
				login = (Login) query.uniqueResult();
				login.setTries(0);
				
				session.update(login);			
				
				query = session.createQuery("from CartaoAcesso as c where c.login = :login");
				query.setEntity("login", login);
				cartaoList = (List<CartaoAcesso>) query.list();
				if (cartaoList.size() > 0) {
					for (CartaoAcesso cartao : cartaoList) {
						cartao.setStatus("a");
						session.update(cartao);
					}					
				} else {
					transaction.rollback();
					session.close();
					return "Não é possível liberar acessos para usuarios sem cartão de acesso!";
				}
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível liberar os cartões devido a um erro interno!";
		}
		return "Cartões liberados com sucesso!";
	}
	
	private String delCartao(HttpServletRequest request) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query = null;
		Login login = null;
		List<CartaoAcesso> cartaoList;
		try {
			ArrayList<String> pipe = Util.unmountPipelineStr(request.getParameter("pipe"));
			for (String pp : pipe) {
				query = session.createQuery("from Login as l where l.username = :login");
				query.setString("login", pp);				
				login = (Login) query.uniqueResult();
				
				query = session.createQuery("from CartaoAcesso as c where c.login = :login");
				query.setEntity("login", login);
				
				cartaoList = (List<CartaoAcesso>) query.list();
				if (cartaoList.size() > 0) {
					for (CartaoAcesso cartao : cartaoList) {				
						session.delete(cartao);
					}					
				} else {
					transaction.rollback();
					session.close();
					return "Não é possível deletar cartões de usuarios sem cartão de acesso!";
				}				
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível deletar os cartões devido a um erro interno!";
		}
		return "Cartões deletados com sucesso!";
	}
}
