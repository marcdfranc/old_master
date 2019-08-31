package com.marcsoftware.gateway;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;

import com.marcsoftware.database.Boleto;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class BoletoAdapter
 */
public class BoletoAdapter extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public BoletoAdapter() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		Long codigo = Long.valueOf(request.getParameter("codigo"));
		response.setContentType("text/plain");
		PrintWriter out = response.getWriter();
		out.print(getBoleto(request));
		/*if (codigo < 1883) {
			out.print(getBoleto(request));
		} else {
			out.print(getLancamento(request));
		}*/
	}
	
	private String getBoleto(HttpServletRequest request) {
		Session session = HibernateUtil.getSession();
		Boleto boleto = (Boleto) session.load(Boleto.class, 
				Long.valueOf(request.getParameter("codigo")));	
		String result = boleto.getCodigo() + "@" + 
			Util.parseDate(boleto.getEmissao(), "dd/MM/yyyy");
		result+= "@" + Util.parseDate(boleto.getVencimento(), "dd/MM/yyyy");
		result+= "@" + Util.formatCurrency(boleto.getValor());
		session.close();
		return result;
	}
	
	private String getLancamento(HttpServletRequest request) {
		Session session = HibernateUtil.getSession();
		Lancamento lancamento = (Lancamento) session.load(Lancamento.class, 
				Long.valueOf(request.getParameter("codigo")));
		String result = lancamento.getCodigo() + "@" + 
			Util.parseDate(lancamento.getEmissao(), "dd/MM/yyyy");
		result+= "@" + Util.parseDate(lancamento.getVencimento(), "dd/MM/yyyy");
		result+= "@" + Util.formatCurrency(lancamento.getValor());
		session.close();
		return result;
	}

}
