package com.marcsoftware.utilities;

import java.util.Date;

import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Acesso;

/**
 * Application Lifecycle Listener implementation class UserCounter
 *
 */
public class UserCounter implements HttpSessionListener {    
    private Acesso acesso;
    private Date now;
    private static Session session;
	private static Transaction transaction;	
	
    public UserCounter() {
        
    }

	
    public void sessionCreated(HttpSessionEvent arg0) {
       
    }
	
    public void sessionDestroyed(HttpSessionEvent arg0) {
    	now = new Date();
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			if (arg0.getSession() != null 
					&& arg0.getSession().getAttribute("perfil") != null
					&& arg0.getSession().getAttribute("perfil")!= "") {
				if (!arg0.getSession().getAttribute("perfil").equals("d")) {
					acesso = (Acesso) session.get(Acesso.class, Long.valueOf(arg0.getSession().getAttribute("acessoId").toString()));
					acesso.setSaida(now);
					session.update(acesso);
					session.flush();
					transaction.commit();
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
		} finally {
			session.close();
		}
    }
    
    
    public static int getUserOnline() {
    	int counter = 0;
    	session = HibernateUtil.getSession();
    	transaction = session.beginTransaction();
    	Query query;
    	try {
			query = session.createSQLQuery("SELECT COUNT(*) FROM acesso WHERE saida ISNULL");
			counter = Integer.parseInt(query.uniqueResult().toString());
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();			
		} finally {
			session.close();
		}    	
    	return counter;
	}    
}
