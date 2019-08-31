package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Mensalidade;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class for Servlet: CadastroMensalidade
 *
 */
 public class CadastroMensalidade extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
   static final long serialVersionUID = 1L;
   private Mensalidade mensalidade;
   private Lancamento lancamento;
   private Usuario usuario;
   private int mes, year, parcelas;
   private Session session;
   private Transaction transaction;
   private Query query;
   private PrintWriter out;
    
	public CadastroMensalidade() {
		super();
	}   	
	
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/plain");
		response.setCharacterEncoding("ISO-8859-1");
		out= response.getWriter();
		boolean isOK= true;
		session= HibernateUtil.getSession();
		transaction= session.beginTransaction();		
		try {
			query = session.createQuery("from Usuario as u where u.codigo = :codigo");
			query.setLong("codigo", Long.valueOf(request.getParameter("usuario")));
			usuario= (Usuario) query.uniqueResult();
			Date now = new Date();
			TipoConta conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("61"));
			if (usuario.getRenovacao().before(now)) {
				out.print("-1");
				transaction.rollback();
				session.close();
				out.close();
				return;
			} else {
				parcelas = Integer.parseInt(request.getParameter("pagamentos"));				
				usuario.setQtdeParcela(parcelas);
				usuario.setRenovacao(Util.addMonths(usuario.getRenovacao(), 
						Integer.parseInt(request.getParameter("vigencia"))));
				session.update(usuario);							
				mes= Util.getMonthDate(request.getParameter("data")) + 1;
				year= Util.getYearDate(request.getParameter("data"));
				String data= "";			
				for (int i = 0; i < parcelas; i++) {
					lancamento = new Lancamento();
					//lancamento.setDescricao("mensalidade");
					lancamento.setConta(conta);
					lancamento.setStatus("a");
					lancamento.setTipo("c");
					lancamento.setTaxa(0);
					lancamento.setUnidade(usuario.getUnidade());
					lancamento.setValor(Double.parseDouble(request.getParameter("parcelaIn")));
					data= request.getParameter("vencimento") +  "/" + String.valueOf(mes) +
					"/" + String.valueOf(year);
					lancamento.setVencimento(Util.parseDate(data));
					session.save(lancamento);				
					mensalidade= new Mensalidade();
					mensalidade.setLancamento(lancamento);
					mensalidade.setUsuario(usuario);				
					session.save(mensalidade);
					if (mes == 12) {
						mes = 1;
						year++;
					} else {
						mes++;
					}				
				}
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			isOK = false;
		}
		if (isOK) {
			out.print("Renovação gerada com sucesso!");
		} else {
			out.print("-1");
		}
		out.close();
	}  	  	  	    
}