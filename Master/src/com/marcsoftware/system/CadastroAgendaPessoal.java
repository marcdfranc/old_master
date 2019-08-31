package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;
import java.util.List;



import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.ibm.icu.util.Calendar;
import com.ibm.icu.util.GregorianCalendar;
import com.marcsoftware.database.AgendaPessoal;
import com.marcsoftware.database.Login;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

/**
 * Servlet implementation class CadastroCatalogo
 */
public class CadastroAgendaPessoal extends HttpServlet {
	private static final long serialVersionUID = 1L;       
    
    public CadastroAgendaPessoal() {
        super();        
    }

	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PrintWriter out = response.getWriter();
		switch (Integer.parseInt(request.getParameter("from"))) {
		case 0:
			response.setContentType("text/x-json");
			out.print(loadAgenda(request));
			break;

		case 1:
			response.setContentType("text/plain");
			out.print((addEvento(request))? "0" : "-1");
			break;
			
		case 2:
			response.setContentType("text/plain");
			out.print(editEvento(request));
		}
		
		out.close();
	}
	
	private JSONArray loadAgenda(HttpServletRequest request) {
		JSONArray calendario = new JSONArray();
		JSONObject evt = null; 
		String data= "";
		Login login = null;
		List<AgendaPessoal> eventos = null;
		GregorianCalendar calendar = new GregorianCalendar();
		Session session = HibernateUtil.getSession();
		Query query;
		try {
			query = session.createQuery("from Login as l where l.username = :username");
			query.setString("username", request.getSession().getAttribute("username").toString());
			login = (Login) query.uniqueResult();
			query = session.createQuery("from AgendaPessoal as a where a.login = :login");
			query.setEntity("login", login);
			eventos = (List<AgendaPessoal>) query.list();
			for (AgendaPessoal evento : eventos) {
				/*data = Util.getYearDate(evento.getInicio()) + "-";
				data += Util.zeroToLeft(Util.getMonthDate(evento.getInicio()), 2) + "-";
				data += Util.zeroToLeft(Util.getDayDate(evento.getInicio()), 2);
				//data += Util.zeroToLeft(Util.getDayDate(evento.getInicio()), 2) + " ";
				//data += Util.getTime(evento.getInicio());*/
				calendar.setTime(evento.getInicio());
				data = calendar.getTime().toGMTString();
				evt = new JSONObject();
				evt.put("id", evento.getCodigo());
				evt.put("title", evento.getTitulo());
				evt.put("start", data);
				/*data = Util.getYearDate(evento.getFim()) + "-";
				data += Util.zeroToLeft(Util.getMonthDate(evento.getFim()), 2) + "-";
				data += Util.zeroToLeft(Util.getDayDate(evento.getFim()), 2);
				//data += Util.zeroToLeft(Util.getDayDate(evento.getFim()), 2) + " ";
				//data += Util.getTime(evento.getFim());*/
				calendar.setTime(evento.getFim());
				data = calendar.getTime().toGMTString();
				evt.put("end", data);
				evt.put("allDay", evento.isAllDay());
				
				calendario.add(evt);
			}
			
		} catch (Exception e) {
			e.printStackTrace();
			calendario = new JSONArray();
		} finally {
			session.close();
		}
		return calendario;
	}
	
	private boolean addEvento(HttpServletRequest request) {
		boolean result = true;
		AgendaPessoal agenda;
		String horas = "";
		Login login = null;
		GregorianCalendar datas = new GregorianCalendar();
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Date today = new Date();
		Query query;
		try {
			query = session.createQuery("from Login as l where l.username = :username");
			query.setString("username", request.getSession().getAttribute("username").toString());
			login = (Login) query.uniqueResult();			
			agenda = new AgendaPessoal();
			agenda.setLogin(login);			
			horas = request.getParameter("horaInicio").replace(":", "@");				
			datas.set(Util.getYearDate(request.getParameter("inicio")), 
					Util.getMonthDate(request.getParameter("inicio")) - 1, 
					Util.getDayDate(request.getParameter("inicio")), 
					Integer.parseInt(Util.getPart(horas, 1)), 
					Integer.parseInt(Util.getPart(horas, 2)));
			agenda.setInicio(datas.getTime());
			
			if (request.getParameter("fim").equals("")) {
				datas.set(Util.getYearDate(today),
					Util.getMonthDate(today),
					Util.getDayDate(today), 0, 0
				);
				datas.add(Calendar.DAY_OF_MONTH, Integer.parseInt(request.getParameter("dayDelta")));
				datas.add(Calendar.MINUTE, Integer.parseInt(request.getParameter("minuteDelta")));
			} else {
				horas = request.getParameter("horaFim").replace(":", "@");
				datas.set(Util.getYearDate(request.getParameter("fim")), 
						Util.getMonthDate(request.getParameter("fim")) - 1, 
						Util.getDayDate(request.getParameter("fim")), 
						Integer.parseInt(Util.getPart(horas, 1)), 
						Integer.parseInt(Util.getPart(horas, 2)));
			}
			agenda.setFim(datas.getTime());
			agenda.setCompleto(request.getParameter("diaTodo"));
			agenda.setTitulo(request.getParameter("descricao"));						
			session.save(agenda);			
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			result = false;
		} finally {
			session.close();
		}
		return result;
	}
	
	private String editEvento(HttpServletRequest request) {
		String result= "0";
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		try {
			AgendaPessoal evento = (AgendaPessoal) session.load(AgendaPessoal.class, Long.valueOf(request.getParameter("id")));
			evento.setTitulo(request.getParameter("descricao"));
			session.update(evento);
			transaction.commit();			
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			result = "-1";
		} finally {
			session.close();
		}
		return result;
	}

}
