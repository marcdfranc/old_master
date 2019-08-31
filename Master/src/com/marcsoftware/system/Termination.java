package com.marcsoftware.system;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Session;


/**
 * Servlet implementation class Termination
 */
public class Termination extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
    
    public Termination() {
        super();
        
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		Session session = (Session) request.getSession().getAttribute("hb");
		if (session != null) {
			if (session.isOpen()) {
				session.close();
			}
		}
		request.getSession().invalidate();
		response.sendRedirect("index.jsp");
	}

}
