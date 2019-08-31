package com.marcsoftware.gateway;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Empresa;
import com.marcsoftware.database.FaturaEmpresa;
import com.marcsoftware.database.FaturaEmpresaId;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.LancamentoFaturaEmp;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class BorderoEmpresaAdapter extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Session session;
	private Transaction transaction;
	private Query query;
    private FaturaEmpresa faturaEmpresa;
    private Empresa empresa;
    private FaturaEmpresaId id;
    private LancamentoFaturaEmp itemFatura;
    private List<LancamentoFaturaEmp> faturaList;
    private Lancamento lancamento;
    private String msg;
    private ArrayList<Long> pipe;    
    
    private PrintWriter out;
	
    public BorderoEmpresaAdapter() {
        super();
        
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/plain");
		response.setCharacterEncoding("ISO-8859-1");
		out = response.getWriter();
		if (request.getParameter("from").equals("0")) {
			if (!addRecord(request)) {
				out.print("0" + "@" + msg);
			} else {
				out.print("1" + "@" + faturaEmpresa.getCodigo());
			}
		}
		out.close();
	}
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)	throws ServletException, IOException {
		try {
			if (addRecord(request))  {
				response.sendRedirect("application/fatura_empresa.jsp?id=" +
						+ faturaEmpresa.getEmpresa().getCodigo());
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
				"&lk=application/cliente_fisico.jsp");
			}			
		} catch (Exception e) {			
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
			"&lk=application/cliente_fisico.jsp");
		}
		
	}
	
	private boolean addRecord(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			boolean haveItens = false;
			empresa = (Empresa) session.get(Empresa.class, Long.valueOf(request.getParameter("empresaId")));
			int mes = Integer.parseInt(request.getParameter("mesBase"));
			int ano = Integer.parseInt(request.getParameter("anoBase"));			
			Date dataInicial = Util.parseDate("1/" + mes + "/" + ano);
			Date dataFinal;			
			if (mes == 12) {
				dataFinal = Util.parseDate("2/1/" + (ano + 1));				
			} else {
				dataFinal = Util.parseDate("2/" + (mes + 1) + "/" + ano);
			}
			query = session.createQuery("from FaturaEmpresa as f where f.dataInicio = :dataInicial and f.dataFim = :dataFinal and f.empresa = :empresa ");
			query.setDate("dataInicial", dataInicial);
			query.setDate("dataFinal", dataFinal);
			query.setEntity("empresa", empresa);
			
			if (query.list().size() > 0) {
				transaction.rollback();
				session.close();
				msg = "Já existe uma fatura para esta data base!";
				return false;
			}
			faturaEmpresa = new FaturaEmpresa();
			faturaEmpresa.setDataFim(dataFinal);
			faturaEmpresa.setDataInicio(dataInicial);
			faturaEmpresa.setEmpresa(empresa);
			faturaEmpresa.setVencimento(Util.parseDate(request.getParameter("vencimento")));
			session.save(faturaEmpresa);
			
			pipe = Util.unmountPipeline(request.getParameter("lancamentos"));
			for (Long pp : pipe) {
				if (!haveItens) {
					haveItens = true;
				}
				lancamento = (Lancamento) session.get(Lancamento.class, pp);
				
				id = new FaturaEmpresaId();
				id.setFaturaEmpresa(faturaEmpresa);
				id.setLancamento(lancamento);
				
				itemFatura = new LancamentoFaturaEmp();
				itemFatura.setId(id);
				session.save(itemFatura);
			}
			if (!haveItens) {
				transaction.rollback();
				session.close();
				msg = "Não existem lançamentos para esta database!";
					
				return false;
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return false;
		}
		return true;
	}

	
	private boolean pagFatura(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			faturaEmpresa = (FaturaEmpresa) session.get(FaturaEmpresa.class, 
					Long.valueOf(request.getParameter("faturaIn")));
			
			query = session.createQuery("from LancamentoFaturaEmp as l where l.id.faturaEmpresa = :fatura");
			query.setEntity("fatura", faturaEmpresa);
			faturaList = (List<LancamentoFaturaEmp>) query.list();
			for (LancamentoFaturaEmp iten : faturaList) {
				iten.getId().getLancamento().setStatus("q");
				iten.getId().getLancamento().setValorPago(0);
				//aqui não tem escape, faça o calculo dos atrasados
				session.update(iten.getId().getLancamento());
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return false;
		}
		return true;
	}
}
