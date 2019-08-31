package com.marcsoftware.gateway;

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

import com.marcsoftware.database.ItensLote;
import com.marcsoftware.database.LoteParcelaCompra;
import com.marcsoftware.database.ParcelaCompra;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class ParcelaCompraAdapter extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Session session;
	private Transaction transaction;
	private Query query;
	private LoteParcelaCompra lote;
	private ItensLote itensLote;
	private List<ParcelaCompra> parcelaCompraList;
	private PrintWriter out;
       
    
    public ParcelaCompraAdapter() {
        super();
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("ISO-8859-1");
		response.setContentType("text/plain");
		out = response.getWriter();
		out.print(Util.encodeString(generateGroup(request), "UTF8", "ISO-8859-1"));
		out.close();
	}
	
	private String generateGroup(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		Date vencimento = new Date();
		vencimento = Util.parseDate(Util.getLastDayOfMonth(vencimento) + "/" +
				Util.getMonthDate(vencimento) + "/" + Util.getYearDate(vencimento));		
		try {
			query = session.createQuery("from ParcelaCompra as p " +
					" where p.id.compra.fornecedor.codigo = :fornecedor " +
					" and p.id.lancamento.vencimento <= :vencimento " +
					" and p.id.lancamento.status = 'a'");
			query.setDate("vencimento", vencimento);
			query.setLong("fornecedor", Long.valueOf(request.getParameter("idFornecedor")));
			parcelaCompraList = (List<ParcelaCompra>) query.list();
			if (parcelaCompraList.size() == 0) {
				transaction.rollback();
				session.close();
				return "2";
			}
			lote = new LoteParcelaCompra();
			lote.setAno(request.getParameter("ano"));
			lote.setMes(Integer.parseInt(request.getParameter("mes")));
			
			session.save(lote);
			
			for (ParcelaCompra parcela : parcelaCompraList) {
				itensLote = new ItensLote();
				itensLote.setLote(lote);
				itensLote.setParcelaCompra(parcela);				
				
				session.save(itensLote);
			}
			
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "1";
		}
		return "0";
	}

}
