package com.marcsoftware.utilities;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Parametro;

import net.sf.jasperreports.engine.JRException;

/**
 * Servlet implementation class TesteJasper
 */
public class TesteJasper extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private PrintWriter out;
	private byte[] reportStream;
	private RelatorioAdmin manager;
	private Parametro parametro;
	private Session session;
	private Transaction transaction;
	private Query query;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public TesteJasper() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		//manager = new RelatorioAdmin(this.getServletContext().getRealPath("/report"),Long.valueOf("31"), false);
		try {
			//manager.setParametro("BAIRRO", "%santa%");
			reportStream = manager.getOutput();
		} catch (SQLException e) {
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print("erro");
			out.close();
			e.printStackTrace();
			return;
		} catch (JRException e) {
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print("erro");
			out.close();
			e.printStackTrace();
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

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
	}

}
