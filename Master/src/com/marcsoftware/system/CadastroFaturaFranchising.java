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

import com.marcsoftware.database.FaturaFranchising;
import com.marcsoftware.database.ItensFaturaFranchising;
import com.marcsoftware.database.ItensFaturaFranchisingId;
import com.marcsoftware.database.ItensTabelaFranchising;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroFaturaFranchising
 */
public class CadastroFaturaFranchising extends HttpServlet {
	private static final long serialVersionUID = 1L;       
    
    public CadastroFaturaFranchising() {
        super();
        // TODO Auto-generated constructor stub
    }
    
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PrintWriter out = response.getWriter();
		switch (Integer.parseInt(request.getParameter("from"))) {
			case 0:
				response.setContentType("text/plain");
				out.print(addRecord(request));
				break;
			
			case 1:
				response.setContentType("text/plain");
				out.print(editObs(request));				
				break;
				
			case 2:
				response.setContentType("text/plain");
				out.print(addItenFatura(request));				
				break;
		}
		out.close();
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
	}
	
	private String addRecord(HttpServletRequest request) {
		String result = "../error_page.jsp?errorMsg=Fatura gerada com sucesso!&lk=application/unidade.jsp";
		Date today = new Date();
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		try {		
			Unidade unidade = (Unidade) session.load(Unidade.class, Long.valueOf(request.getParameter("unidadeId")));
			
			Query query = session.createQuery("from FaturaFranchising as f " +
					" where f.unidade = :unidade " +
					" and f.status = 'a'");
			query.setEntity("unidade", unidade);
			if (query.list().size() > 0) {
				result = "../error_page.jsp?errorMsg=Já existe uma fatura em aberto para esta Unidade!&lk=application/unidade.jsp";
				transaction.rollback();
			} else {
				query = session.createQuery("from ItensTabelaFranchising as i " +
						" where i.tabela = :tabela " +
				" and i.tipoCobranca = 'f'");
				query.setEntity("tabela", unidade.getTabelaFranchising());			
				
				List<ItensTabelaFranchising> itensTabela = (List<ItensTabelaFranchising>) query.list();		
				
				FaturaFranchising fatura = new FaturaFranchising();
				fatura.setDataInicio(today);
				fatura.setUnidade(unidade);
				fatura.setStatus("a");
				
				session.save(fatura);		
				Lancamento lancamento = null;
				ItensFaturaFranchising itenFatura = null;
				ItensFaturaFranchisingId id = null;
				for (ItensTabelaFranchising iten : itensTabela) {
					lancamento = new Lancamento();
					
					lancamento.setConta(iten.getTipoConta());
					lancamento.setDocumento("franch.: " + fatura.getCodigo());
					lancamento.setEmissao(today);
					lancamento.setStatus("a");
					lancamento.setTaxa(0);			
					lancamento.setTipo("c");
					lancamento.setUnidade(unidade);
					lancamento.setValor(iten.getValor());
					
					session.save(lancamento);
					
					itenFatura  = new ItensFaturaFranchising();
					id = new ItensFaturaFranchisingId();
					id.setFatura(fatura);
					id.setLancamento(lancamento);
					
					itenFatura.setId(id);					
					session.save(itenFatura);
				}
				
				session.flush();
				transaction.commit();
			}
			
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			result = "../error_page.jsp?errorMsg=Não foi possível gerar a fatura devido a um erro interno!&lk=application/unidade.jsp";
		} finally {
			session.close();
		}
		return result;
	}
	
	private String editObs(HttpServletRequest request) {
		String result = "0";
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		try {
			FaturaFranchising fatura = (FaturaFranchising) session.load(FaturaFranchising.class, 
					Long.valueOf(request.getParameter("faturaId")));
			fatura.setObs(request.getParameter("obs"));
			session.update(fatura);
			
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			result = "-1";
			transaction.rollback();
		} finally {
			session.close();
		}
		
		return result;
	}
	
	private String addItenFatura(HttpServletRequest request) {
		String result = "?errorMsg=Íten inserido com sucesso!&lk=application/unidade.jsp?id=" + 
			request.getParameter("faturaId");
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Date today = new Date();
		double valor = 0;
		double horaInicio = 0;
		double horaFinal = 0;		
		int aux = 0;
		try {
			ItensTabelaFranchising itenTabela = (ItensTabelaFranchising) session.load(ItensTabelaFranchising.class,
					Long.valueOf(request.getParameter("tabelaId")));
			Unidade unidade = (Unidade) session.load(Unidade.class, Long.valueOf(request.getParameter("unidadeId")));
			FaturaFranchising fatura = (FaturaFranchising) session.load(FaturaFranchising.class, Long.valueOf(request.getParameter("faturaId")));		
			
			Lancamento lancamento = new Lancamento();
			lancamento.setConta(itenTabela.getTipoConta());
			lancamento.setEmissao(today);
			lancamento.setStatus("a");
			lancamento.setTipo("c");
			lancamento.setUnidade(unidade);			
			
			switch (itenTabela.getTipoCobranca().charAt(0)) {
			case 'f':
				lancamento.setValor(itenTabela.getValor());
				lancamento.setDocumento("franch.: " + fatura.getCodigo());
				break;

			case 'q':
				valor = itenTabela.getValor() * Integer.parseInt(request.getParameter("qtde"));
				lancamento.setValor(valor);
				lancamento.setDocumento("franch.: " + fatura.getCodigo() +
						" - qtde: " + request.getParameter("qtde"));
				break;
				
			case 'h':
				horaInicio = Double.parseDouble(request.getParameter("inicio").substring(0, 2));
				valor = Double.parseDouble(request.getParameter("inicio").substring(3,5)) / 60;				
				horaInicio+= valor;
				
				horaFinal = Double.parseDouble(request.getParameter("fim").substring(0, 2));
				valor = Double.parseDouble(request.getParameter("fim").substring(3,5)) / 60;
				horaFinal+= valor;				
				
				valor = horaFinal - horaInicio;				
				lancamento.setValor(valor * itenTabela.getValor());
				
				aux = (int) valor;
				valor-= aux;  
				valor*= 60;
				
				lancamento.setDocumento("franch.: " + fatura.getCodigo() + " - tempo: " +
						Util.zeroToLeft(aux, 2) + ":" + ((int) valor));
			}
			
			session.save(lancamento);
			
			ItensFaturaFranchising  itenFatura = new ItensFaturaFranchising();
			ItensFaturaFranchisingId id = new ItensFaturaFranchisingId();
			id.setFatura(fatura);
			id.setLancamento(lancamento);			
			itenFatura.setId(id);
			
			session.save(itenFatura);
			
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			result = "?errorMsg=Não foi possível inserir o íten devido a um erro interno!&lk=application/unidade.jsp?id=" + 
				request.getParameter("faturaId");
		} finally {
			session.close();
		}
		return "../error_page.jsp" +  result;
	}

}
