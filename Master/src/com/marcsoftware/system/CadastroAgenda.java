package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
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
import com.marcsoftware.database.Agenda;
import com.marcsoftware.database.Profissional;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

/**
 * Servlet implementation class CadastroCatalogo
 */
public class CadastroAgenda extends HttpServlet {
	private static final long serialVersionUID = 1L;       
    
    public CadastroAgenda() {
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
			break;
			
		case 3:
			response.setContentType("text/x-json");
			out.print(loadEvento(request));
			break;
		}
		
		out.close();
	}
	
	private JSONArray loadAgenda(HttpServletRequest request) {
		JSONArray calendario = new JSONArray();
		JSONObject evt = null; 
		String data= "";
		List<Agenda> eventos = null;
		GregorianCalendar calendar = new GregorianCalendar();
		Session session = HibernateUtil.getSession();
		Query query;
		try {
			Profissional profissional = (Profissional) session.load(Profissional.class, Long.valueOf(request.getParameter("id")));
			query = session.createQuery("from Agenda as a where a.profissional= :profissional");
			query.setEntity("profissional", profissional);
			eventos = (List<Agenda>) query.list();
			for (Agenda evento : eventos) {
				calendar.setTime(evento.getInicio());
				data = calendar.getTime().toGMTString();
				evt = new JSONObject();
				evt.put("id", evento.getCodigo());
				evt.put("title", evento.getNomeTitulo());
				evt.put("start", data);
				calendar.setTime(evento.getFim());
				data = calendar.getTime().toGMTString();
				evt.put("end", data);
				evt.put("allDay", false);				
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
		boolean isEdition = Long.valueOf(request.getParameter("codigo")) > 0; 
		Agenda agenda;
		String horas = "";
		GregorianCalendar datas = new GregorianCalendar();
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Profissional profissional;
		try {
			if (isEdition) {
				agenda = (Agenda) session.load(Agenda.class, Long.valueOf(request.getParameter("codigo")));
			} else {
				agenda = new Agenda();
			}
			if (!isEdition) {
				profissional = (Profissional) session.load(Profissional.class, Long.valueOf(request.getParameter("id")));
				agenda.setProfissional(profissional);
			}
			
			horas = request.getParameter("horaInicio").replace(":", "@");				
			datas.set(Util.getYearDate(request.getParameter("inicio")), 
					Util.getMonthDate(request.getParameter("inicio")) - 1, 
					Util.getDayDate(request.getParameter("inicio")), 
					Integer.parseInt(Util.getPart(horas, 1)), 
					Integer.parseInt(Util.getPart(horas, 2)));
			agenda.setInicio(datas.getTime());
			
			if (isEdition && request.getParameter("fim").equals("")) {
				datas.setTime(agenda.getFim());
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
			if (request.getParameter("mudaObs").equals("s")) {
				agenda.setObservacao(request.getParameter("obs"));
			}
			if (!isEdition) {
				agenda.setNomeTitulo(request.getParameter("descricao"));
			}
						
			session.saveOrUpdate(agenda);
			
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
		String horas = "";
		GregorianCalendar datas = new GregorianCalendar();
		try {
			Agenda evento = (Agenda) session.load(Agenda.class, Long.valueOf(request.getParameter("id")));
			horas = request.getParameter("horaInicio").replace(":", "@");				
			datas.set(Util.getYearDate(request.getParameter("inicio")), 
					Util.getMonthDate(request.getParameter("inicio")) - 1, 
					Util.getDayDate(request.getParameter("inicio")), 
					Integer.parseInt(Util.getPart(horas, 1)), 
					Integer.parseInt(Util.getPart(horas, 2)));
			evento.setInicio(datas.getTime());
			
			horas = request.getParameter("horaFim").replace(":", "@");
			datas.set(Util.getYearDate(request.getParameter("fim")), 
					Util.getMonthDate(request.getParameter("fim")) - 1, 
					Util.getDayDate(request.getParameter("fim")), 
					Integer.parseInt(Util.getPart(horas, 1)), 
					Integer.parseInt(Util.getPart(horas, 2)));
			evento.setFim(datas.getTime());
			
			evento.setNomeTitulo(request.getParameter("descricao"));
			evento.setObservacao(request.getParameter("obs"));
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
	
	private JSONObject loadEvento(HttpServletRequest request) {
		JSONObject evento = new JSONObject();
		Session session = HibernateUtil.getSession();
		try {
			Agenda agenda = (Agenda) session.load(Agenda.class, Long.valueOf(request.getParameter("id")));
			evento.put("id", agenda.getCodigo());
			evento.put("title", agenda.getNomeTitulo());
			evento.put("start", Util.parseDate(agenda.getInicio(), "dd/MM/yyyy"));
			evento.put("horaStart", Util.getSimpleTime(agenda.getInicio()));
			evento.put("end", Util.parseDate(agenda.getFim(), "dd/MM/yyyy"));
			evento.put("horaEnd", Util.getSimpleTime(agenda.getFim()));
			evento.put("obs", agenda.getObservacao());
			
		} catch (Exception e) {
			e.printStackTrace();			
		} finally {
			session.close();
		}
		return evento;
	}

}

