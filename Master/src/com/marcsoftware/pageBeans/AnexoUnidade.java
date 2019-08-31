package com.marcsoftware.pageBeans;

import javax.servlet.http.HttpServletRequest;

import org.hibernate.Query;
import org.hibernate.Session;

import com.marcsoftware.utilities.Util;
import com.marcsoftware.database.Fisica;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.HibernateUtil;

public class AnexoUnidade {
	private boolean haveAccess, liberacao;
	private Unidade unidade;
	private Session session;
	private Query query;
	private Login login;
	private Fisica adm;
	
	public AnexoUnidade(Long id, Long idAcessante, HttpServletRequest request) {
		try {
			session = HibernateUtil.getSession();
			Util.historico(session, idAcessante, request);
			try {
				haveAccess = false;
				liberacao = false;
				unidade = (Unidade) session.get(Unidade.class, id);
				adm = (Fisica) session.get(Fisica.class, unidade.getAdministrador().getCodigo());
				query = session.createQuery("from Login as l where l = :login");
				query.setEntity("login", adm.getLogin());
				login = (Login) query.uniqueResult();
				if (adm == null) {
					haveAccess = false;
				} else {
					query = session.createQuery("from CartaoAcesso as c where c.login = :login");
					query.setEntity("login", login);
					haveAccess = query.list().size() > 0;
				}
				if (haveAccess) {
					query = session.createQuery("from CartaoAcesso as c where c.login = :login and c.status = 'a'");
					query.setEntity("login", login);
					liberacao = query.list().size() > 0;
				}
				
			} catch (Exception e) {
				e.printStackTrace();
				session.close();
			} finally {
				if (session.isOpen()) {
					session.close();
				}
			}
		} catch (Exception e) {
			e.printStackTrace();			
		}
	}

	public Unidade getUnidade() {
		return unidade;
	}

	public Login getLogin() {
		return login;
	}

	public Fisica getAdm() {
		return adm;
	}

	public boolean isHaveAccess() {
		return haveAccess;
	}

	public boolean isLiberacao() {
		return liberacao;
	}	
}
