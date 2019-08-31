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

import com.marcsoftware.database.Banco;
import com.marcsoftware.database.Cc;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroCc
 */
public class CadastroCc extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Cc cc;
	private List<Lancamento> lancamento;
	private double saldo, creditos, debitos;
	private PrintWriter out;
	private Banco banco;
	private Unidade unidade;
	private Session session;
	private Transaction transaction;
	private Query query;	
    
    public CadastroCc() {
        super();        
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String lastId = "";
		request.setCharacterEncoding("ISO-8859-1");				
		response.setContentType("text/html");
		response.setCharacterEncoding("ISO-8859-1");
		out= response.getWriter();
		session= HibernateUtil.getSession();
		transaction= session.beginTransaction();
		creditos = debitos = 0;
		Date now, yesterday, tomorow;
		now = new Date();
		try {
			query = session.createQuery("from Unidade as u where u.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidadeId")));
			unidade = (Unidade) query.uniqueResult();
			
			query = session.createQuery("from Cc as c where c.unidade = :unidade");
			query.setEntity("unidade", unidade);
			cc = (Cc) query.uniqueResult();			
			
			if (unidade.getTipo().equals("h")) {
				query = session.getNamedQuery("contaCreditoHold");
			} else {
				query = session.getNamedQuery("contaCredito");
				query.setLong("unidade", unidade.getCodigo());
			}
			if (request.getParameter("dataInicial") == ""
				&& request.getParameter("dataFim") == "") {
				yesterday = Util.parseDate((Util.getDayDate(now) -1) +
						"/" + Util.getMonthDate(now) + "/" + Util.getYearDate(now) + " 00:00:59", "HH:mm:ss");
				
				tomorow = Util.parseDate((Util.getDayDate(now) + 1) +
						"/" + Util.getMonthDate(now) + "/" + Util.getYearDate(now) + " 00:01:00", "HH:mm:ss");
				query.setDate("dataInicio", cc.getCadastro());
				query.setDate("dataFim", yesterday);
			} else {
				query.setDate("dataInicio", cc.getCadastro());
				query.setDate("dataFim", (cc.getCadastro().after(
						Util.parseDate(request.getParameter("dataInicial"))) ? cc.getCadastro() 
								: Util.parseDate(request.getParameter("dataInicial"))));
			}
			saldo = (query.uniqueResult() != null)?
					Double.parseDouble(query.uniqueResult().toString()) : 0;
			
			saldo+= cc.getValor();
			
			if (unidade.getTipo().equals("h")) {
				query = session.getNamedQuery("contaDebitoHold");
			} else {
				query = session.getNamedQuery("contaDebito");
				query.setLong("unidade", unidade.getCodigo());
			}
			
			if (request.getParameter("dataInicial") == ""
				&& request.getParameter("dataFim") == "") {
				yesterday = Util.parseDate((Util.getDayDate(now) -1) +
						"/" + Util.getMonthDate(now) + "/" + Util.getYearDate(now) + " 00:00:59", "HH:mm:ss");
				
				tomorow = Util.parseDate((Util.getDayDate(now) + 1) +
						"/" + Util.getMonthDate(now) + "/" + Util.getYearDate(now) + " 00:01:00", "HH:mm:ss");
				
				query.setDate("dataInicio", cc.getCadastro());
				query.setDate("dataFim", yesterday);
			} else {
				query.setDate("dataInicio", cc.getCadastro());
				query.setDate("dataFim", (cc.getCadastro().after(
						Util.parseDate(request.getParameter("dataInicial"))) ? cc.getCadastro() 
								: Util.parseDate(request.getParameter("dataInicial"))));
			}
			
			saldo -= (query.uniqueResult() != null)?
					Double.parseDouble(query.uniqueResult().toString()) : 0;
			
			if (unidade.getTipo().equals("h")) {
				query = session.getNamedQuery("ccLancamentoHold");
			} else {
				query = session.getNamedQuery("ccLancamento");
				query.setEntity("unidade", unidade);
			}
			if (request.getParameter("dataInicial") == ""
				&& request.getParameter("dataFim") == "") {
				yesterday = Util.parseDate((Util.getDayDate(now) -1) +
						"/" + Util.getMonthDate(now) + "/" + Util.getYearDate(now) + " 00:00:59", "HH:mm:ss");
				
				tomorow = Util.parseDate((Util.getDayDate(now) + 1) +
						"/" + Util.getMonthDate(now) + "/" + Util.getYearDate(now) + " 00:01:00", "HH:mm:ss");
				query.setTimestamp("dataInicio", yesterday);							
				query.setTimestamp("dataFim", tomorow);
			} else {
				query.setDate("dataInicio",(cc.getCadastro().after(
						Util.parseDate(request.getParameter("dataInicial"))) ? cc.getCadastro() 
								: Util.parseDate(request.getParameter("dataInicial"))));
				query.setDate("dataFim", Util.addDays(request.getParameter("dataFim"), 1));
			}
			lancamento = (List<Lancamento>) query.list();
			if (lancamento.size() == 0) {
				out.print("<tr><td><p>Nenhum registro encontrado</p></td></tr>");
				transaction.commit();
				session.close();
				out.close();
				return;
			}
			
			String gridLines = request.getParameter("dataInicial") + "@" + 
				Util.formatCurrency(saldo) + "@" + request.getParameter("dataFim") + "@";
			//int gridLines = lancamento.size();
			DataGrid dataGrid = new DataGrid("");
			dataGrid.addColum("6", "Lanç.");
			dataGrid.addColum("24", "Documento");
			dataGrid.addColum("31", "Descrição");						
			dataGrid.addColum("10", "Emissão");
			dataGrid.addColum("10", "Data Pag.");
			dataGrid.addColum("2", "Tp");
			dataGrid.addColum("8", "valor");
			dataGrid.addColum("8", "Saldo");
			for (Lancamento lanc : lancamento) {
				lastId = String.valueOf(lanc.getCodigo());
				if (lastId.trim().equals("32939")) {
					lastId+= lastId;
				}
				dataGrid.setId(String.valueOf(lanc.getCodigo()));
				dataGrid.addData(String.valueOf(lanc.getCodigo()));
				dataGrid.addData(lanc.getDocumento());
				dataGrid.addData(Util.initCap(lanc.getConta().getDescricao()));
				dataGrid.addData((lanc.getEmissao() == null)? "" 
						: Util.parseDate(lanc.getEmissao(), "dd/MM/yyyy"));
				dataGrid.addData(Util.parseDate(lanc.getDataQuitacao(), "dd/MM/yyyy"));
				if (lanc.getTipo().trim().equals("c")) {
					saldo+= lanc.getValorPago();
					creditos+= lanc.getValorPago();
					dataGrid.addImg("../image/credito.gif");
				} else {
					saldo-= lanc.getValorPago();
					debitos+= lanc.getValorPago();
					dataGrid.addImg("../image/debito.gif");
				}							
				dataGrid.addData(Util.formatCurrency(lanc.getValorPago()));
				dataGrid.addData(Util.formatCurrency(saldo));
				dataGrid.addRow();
			}
			dataGrid.addTotalizador("Débitos", Util.formatCurrency(debitos), true);
			dataGrid.addTotalizador("Créditos", Util.formatCurrency(creditos), false);
			dataGrid.addTotalizadorRight("Saldo em " + request.getParameter("dataFim"), Util.formatCurrency(saldo));						
			dataGrid.makeTotalizador();	
			gridLines+= saldo;
			out.print(dataGrid.getTable(gridLines));
			transaction.commit();
			session.close();
			out.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			out.print("<tr><td><p>Last Id: " + lastId + "</p></td></tr>");
			//out.print("<tr><td><p>Nenhum registro encontrado</p></td></tr>");
		}
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			if (addRecord(request))  {
				response.sendRedirect("application/conta_corrente.jsp");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
				"&lk=application/lancamento.jsp");
			}			
		} catch (Exception e) {			
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
			"&lk=application/lancamento.jsp");
		}
	}
	
	private boolean addRecord(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			query = session.createQuery("from Banco as b where b.codigo = :banco");
			query.setLong("banco", Long.valueOf(request.getParameter("banco")));
			banco = (Banco) query.uniqueResult();
			
			query = session.createQuery("from Unidade as u where u.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			unidade = (Unidade) query.uniqueResult();
			
			if (request.getParameter("codigoIn") == "" 
				|| request.getParameter("codigoIn") == null) {
				cc = new Cc();
			} else {
				cc = (Cc) session.get(Cc.class, Long.valueOf(request.getParameter("codigoIn")));
			}
			cc.setAgencia(request.getParameter("agenciaIn"));
			cc.setNumero(request.getParameter("numeroIn"));
			cc.setCadastro(Util.parseDate(request.getParameter("cadastroIn")));
			cc.setUnidade(unidade);
			cc.setBanco(banco);
			cc.setValor(Double.parseDouble(request.getParameter("valorIn")));
			session.saveOrUpdate(cc);
			
			transaction.commit();
			session.close();			
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
		}
		return true;
	}
}
