package com.marcsoftware.utilities;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.ArrayList;

import javax.servlet.Servlet;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.jasperreports.engine.JRException;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Parametro;

public class GeradorRelatorio extends HttpServlet implements Servlet {	
	static final long serialVersionUID = 1L;
	private PrintWriter out;
	private byte[] reportStream;
	private RelatorioAdmin manager;
	private Parametro parametro;
	private Session session;
	private Transaction transaction;
	private Query query;
	private ArrayList<String> pipe;
	private String link;
	
	public GeradorRelatorio() {
		super();
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		link = "";
		if (!request.getParameter("parametros").trim().equals("")) {
			pipe = Util.unmountRealPipe(request.getParameter("parametros"));
		}
		manager = new RelatorioAdmin(this.getServletContext().getRealPath("/report"),
				Long.valueOf(request.getParameter("rel")),
				Long.valueOf(request.getSession().getAttribute("acessoId").toString()));
		try {
			if (!request.getParameter("parametros").trim().equals("")) {
				manager.setParametro(pipe);
			}
			if (manager.getTipo().trim().equals("j")) {
				reportStream = manager.getOutput();
			} else {
				response.sendRedirect(manager.getLink());
				return;
			}
		} catch (SQLException e) {			
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(e.getMessage());
			e.printStackTrace();
			out.close();
			return;
		} catch (JRException e) {
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(e.getMessage());
			e.printStackTrace();
			out.close();
			return;
		} catch (Exception e) {
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(e.getMessage());
			e.printStackTrace();
			out.close();
			return;
		}
		if (reportStream != null & reportStream.length > 0) {
			response.setContentType("application/pdf");		
			response.setContentLength(reportStream.length);
			ServletOutputStream output = response.getOutputStream();
			output.write(reportStream, 0, reportStream.length);
			output.flush();
			output.close();
		} else {
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print("não carregou stream");
		}
	}
}
