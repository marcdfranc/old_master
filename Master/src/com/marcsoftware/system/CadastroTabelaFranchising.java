package com.marcsoftware.system;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Informacao;
import com.marcsoftware.database.ItensTabelaFranchising;
import com.marcsoftware.database.TabelaFranchising;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class CadastroTabelaFranchising extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    
    public CadastroTabelaFranchising() {
        super();
        
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			if (addRecord(request) == "0")  {
				response.sendRedirect("application/unidade.jsp");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT +
						"&lk=application/unidade.jsp");
			}
		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT);
		}
	}
	
	private String addRecord(HttpServletRequest request) {
		boolean isEdition= (request.getParameter("codigoIn") != "");
		String result = "0";
		TabelaFranchising tabela = null;
		ItensTabelaFranchising iten = null;
		List<ItensTabelaFranchising> itens = null;
		TipoConta conta = null;
		List<TipoConta> contas = null;
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		try {
			if (isEdition) {
				tabela = (TabelaFranchising) session.load(TabelaFranchising.class, Long.valueOf(request.getParameter("codigoIn")));
			} else {
 				tabela = new TabelaFranchising();
			}
			tabela.setCadastro(Util.parseDate(request.getParameter("cadastroIn")));
			tabela.setDescricao(request.getParameter("descricaoIn").toLowerCase());
			
			session.saveOrUpdate(tabela);			
						
			int count = 0;
			boolean isNew = true;
			while (request.getParameter("rowDescricao" + String.valueOf(count)) != null) {				
				if (request.getParameter("ckdelItem" + String.valueOf(count)).equals("-1")) {
					iten = new ItensTabelaFranchising();
					isNew = true;
				} else {
					iten = (ItensTabelaFranchising) session.load(ItensTabelaFranchising.class, 
							Long.valueOf(request.getParameter("ckdelItem" + String.valueOf(count))));
					isNew = false;
				}
				conta = (TipoConta) session.load(TipoConta.class, 
						Long.valueOf(request.getParameter("rowDescricao" + String.valueOf(count))));
				iten.setTabela(tabela);
				iten.setTipoConta(conta);
				iten.setValor(Double.parseDouble(request.getParameter("rowValor" + String.valueOf(count))));
				if (request.getParameter("rowCobranca" + count).equals("Fixa")) {
					iten.setTipoCobranca("f");
				} else if(request.getParameter("rowCobranca" + count).equals("Por Hora")) {
					iten.setTipoCobranca("h");
				} else {
					iten.setTipoCobranca("q");
				}
				session.saveOrUpdate(iten);
				count++;
				
			}
			count= 0;
			while (request.getParameter("delItem" + String.valueOf(count)) != null) {
				long key =  Long.valueOf(request.getParameter("delItem" + String.valueOf(count++)));
				iten = (ItensTabelaFranchising) session.load(ItensTabelaFranchising.class, key);
				session.delete(iten);
			}
			session.flush();
			transaction.commit();
			result = "0";
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			//result = "Não possivel salvar o registro devido a um erro interno!";			
			result = "1";
		} finally {
			session.close();
		}
		return result;
	}

}
