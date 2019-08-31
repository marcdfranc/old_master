package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Contrato;
import com.marcsoftware.database.FaturaVendedor;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.ItensVendedor;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroFaturaVendedor
 */
public class CadastroFaturaVendedor extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Session session;
	private Transaction transaction;
	private Query query, queryList;
	private List<ItensVendedor> itensVendedor;
	private Contrato contrato;
	private Lancamento lancamento;
	private Filter filter;
	private PrintWriter out;
	private boolean isFilter;
	private int limit, offSet, gridLines, consolidados;
	private List<Usuario> usuarioList;
	private double adesao, vlrTotal;
       
    public CadastroFaturaVendedor() {
        super();
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		out = response.getWriter();
		response.setContentType("text/html");
		response.setCharacterEncoding("ISO-8859-1");
		if (request.getParameter("from").trim().equals("0")) {
			session= HibernateUtil.getSession();
			transaction= session.beginTransaction();
			try {
				isFilter= request.getParameter("isFilter") == "1";
				mountFilter(request);
				limit= Integer.parseInt(request.getParameter("limit"));
				offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
				queryList = filter.mountQuery(query, session);
				List<Usuario> usuarioList = (List<Usuario>) queryList.list();
				gridLines = usuarioList.size();
				adesao = 0;
				vlrTotal = 0;
				consolidados = 0;
				for(Usuario usuario: usuarioList) {
					query = session.getNamedQuery("adesaoByCtr");
					query.setLong("ctr", usuario.getContrato().getCodigo());
					lancamento = (Lancamento) query.uniqueResult();
					adesao = (lancamento.equals(null))? 0 : lancamento.getValor();
					if (gridLines >= usuario.getContrato().getFuncionario().getMeta()) {
						adesao = adesao * (usuario.getContrato().getFuncionario().getBonus() / 100);
					} else {
						adesao = adesao * (usuario.getContrato().getFuncionario().getComissao() / 100);
					}							
					if (lancamento.getStatus().equals("q")) {
						vlrTotal+= adesao;
						consolidados++;
					}
				}
				queryList.setFirstResult(offSet);
				queryList.setMaxResults(limit);
				usuarioList = (List<Usuario>) queryList.list();
				DataGrid dataGrid = new DataGrid("#");
				dataGrid.addColum("5", "CTR");
				dataGrid.addColum("36", "Titular");						
				dataGrid.addColum("10", "Cadastro");
				dataGrid.addColum("36", "Funcionario");
				dataGrid.addColum("10", "valor");
				dataGrid.addColum("3", "St");
				for(Usuario usuario: usuarioList) {
					query = session.getNamedQuery("adesaoByCtr");
					query.setLong("ctr", usuario.getContrato().getCodigo());
					lancamento = (Lancamento) query.uniqueResult();
					adesao = (lancamento.equals(null))? 0 : lancamento.getValor();						
					if (gridLines >= usuario.getContrato().getFuncionario().getMeta()) {
						adesao = adesao * (usuario.getContrato().getFuncionario().getBonus() / 100);
					} else {
						adesao = adesao * (usuario.getContrato().getFuncionario().getComissao() / 100);
					}
					dataGrid.setId(String.valueOf(usuario.getContrato().getCodigo()));
					dataGrid.addData(Util.zeroToLeft(usuario.getContrato().getCodigo(), 4));
					dataGrid.addData(Util.initCap(Util.encodeString(usuario.getNome(), "UTF8", "ISO-8859-1")));
					dataGrid.addData(Util.parseDate(usuario.getCadastro(), "dd/MM/yyyy"));
					dataGrid.addData(Util.initCap(
							Util.encodeString(usuario.getContrato().getFuncionario().getNome(),
									"UTF8", "ISO-8859-1")));														
					dataGrid.addData(Util.formatCurrency(adesao));						
					dataGrid.addImg(Util.getRealIcon(lancamento.getVencimento(), lancamento.getStatus()));
					dataGrid.addRow();							
				}
				dataGrid.addTotalizador("Total", Util.formatCurrency(vlrTotal), true);
				dataGrid.addTotalizador("Consolidados", String.valueOf(consolidados), true);
				dataGrid.addTotalizador("CTR's Vendidos", String.valueOf(gridLines), false);
				dataGrid.makeTotalizador();
				out.print(dataGrid.getTable(gridLines));
				
				transaction.commit();
				session.close();
			} catch (Exception e) {
				e.printStackTrace();
				transaction.rollback();
				session.close();
				out.print("-1");				
			}
		} else if (request.getParameter("from").equals("1")) {
			out.print(deleteFatura(request));
		}
		out.close();
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			if (addRecord(request))  {
				response.sendRedirect("application/funcionario.jsp");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
				"&lk=application/funcionario.jsp");
			}			
		} catch (Exception e) {			
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
			"&lk=application/funcionario.jsp");
		}
	}
	
	private boolean addRecord(HttpServletRequest request) {
		Date now = new Date();
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			query = session.createQuery("from ItensVendedor as i where i.id.faturaVendedor.codigo = :fatura");
			query.setLong("fatura", Long.valueOf(request.getParameter("idFatura")));
			itensVendedor = (List<ItensVendedor>) query.list();
			
			for (ItensVendedor itens : itensVendedor) {
				contrato = itens.getId().getContrato();
				lancamento = contrato.getLancamento();
				lancamento.setValorPago(lancamento.getValor());
				lancamento.setStatus("q");
				lancamento.setRecebimento(request.getSession().getAttribute("username").toString());
				lancamento.setDataQuitacao(now);
				session.update(lancamento);
				
				contrato.setStatus("q");
				session.update(contrato);
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
		}
		return true;
	}
	
	private void mountFilter(HttpServletRequest request) {
		filter = new Filter("from Usuario as u " + 
				"where u.contrato not in(select i.id.contrato from ItensVendedor as i)");	
		
		if (!request.getParameter("ref").equals("")) {
			filter.addFilter("u.contrato.funcionario.codigo  = :funcId", Long.class, "funcId",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("ref"))));
		}
		if (!request.getParameter("funcionario").equals("")) {
			filter.addFilter("u.contrato.funcionario.nome LIKE :funcionario", String.class, "funcionario", 
					"%" + Util.encodeString(request.getParameter("funcionario"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("cpf").equals("")) {
			filter.addFilter("u.contrato.funcionario.cpf = :cpf", String.class, "cpf", 
					Util.unMountDocument(request.getParameter("cpf")));
		}
		if (!request.getParameter("nascimento").equals("")) {
			filter.addFilter("u.contrato.funcionario.nascimento = :nascimento", Date.class, "nascimento",
					Util.parseDate(request.getParameter("nascimento")));
		}		
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("u.contrato.funcionario.unidade.codigo = :unidade", Long.class, "unidade",
					Long.valueOf(request.getParameter("unidadeId")));
		}
		filter.setOrder("u.cadastro desc");
	}
	
	private String deleteFatura(HttpServletRequest request) {
		String result= "1";
		session = HibernateUtil.getSession();
		transaction =session.beginTransaction();
		try {
			FaturaVendedor fatura = (FaturaVendedor) session.load(FaturaVendedor.class, Long.valueOf(request.getParameter("id")));
			query = session.createQuery("from ItensVendedor as i where i.id.faturaVendedor = :fatura");
			query.setEntity("fatura", fatura);
			List<ItensVendedor> itensVendedor = (List<ItensVendedor>) query.list();
			Lancamento lancamento = null;
			for (ItensVendedor iten : itensVendedor) {
				lancamento = iten.getId().getContrato().getLancamento();
				iten.getId().getContrato().setLancamento(null);
				session.update(iten.getId().getContrato());
				session.delete(lancamento);
				session.delete(iten);				
			}
			session.delete(fatura);
			
			session.flush();
			transaction.commit();
			result = "0";
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
		} finally {
			session.close();
		}
		
		return result;
	}
}
