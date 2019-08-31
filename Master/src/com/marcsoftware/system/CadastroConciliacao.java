package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
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

import com.marcsoftware.database.Conciliacao;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.ItensConciliacao;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroConciliacao
 */
public class CadastroConciliacao extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private PrintWriter out;
	private Session session;
	private Query query;
	private Transaction transaction;
	private ArrayList<Long> pipe;
	private Conciliacao conciliacao;
	private Filter filter;
	private boolean isFilter;
	private int limit, offSet, gridLines;
    private List<Conciliacao> conciliacaoList;
    private List<ItensConciliacao> itConcilio;
	private String valor;	
	
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CadastroConciliacao() {
        super();        
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		Date now = new Date();
		if (request.getParameter("from").trim().equals("1")) {
			try {
				response.setContentType("text/plain");
				response.setCharacterEncoding("ISO-8859-1");
				out = response.getWriter();
				if (updateRecord(request))  {
					out.print("1");
				} else {
					out.print("0");
				}
			} catch (Exception e) {			
				e.printStackTrace();
				out.print("0");
			}
		} else {
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			session= HibernateUtil.getSession();
			transaction= session.beginTransaction();
			isFilter= request.getParameter("isFilter") == "1";
			mountFilter(request);
			DataGrid dataGrid = new DataGrid("cadastro_conciliacao.jsp");
			dataGrid.addColum("10", "Código");
			dataGrid.addColum("32", "Título");
			dataGrid.addColum("10", "Emissão");
			dataGrid.addColum("18", "Vencimento");
			dataGrid.addColum("10", "tp.");
			dataGrid.addColum("15", "Valor");
			dataGrid.addColum("3", "St.");
			dataGrid.addColum("2", "Ck");
			limit= Integer.parseInt(request.getParameter("limit"));
			offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
			query = filter.mountQuery(query, session);
			gridLines= query.list().size();
			query.setFirstResult(offSet);
			query.setMaxResults(limit);		
			conciliacaoList = (List<Conciliacao>) query.list();
			if (conciliacaoList.size() == 0) {
				dataGrid.setHref("");
				dataGrid.addData("");
				dataGrid.addData("Nenhum Registro Encontrado!");
				dataGrid.addRow();				
				out.print(dataGrid.getTable(1));
				transaction.commit();
				session.close();
				out.close();
				return;
			}
			
			for(Conciliacao conciliacao: conciliacaoList) {
				query = session .getNamedQuery("totalConcilio");
				query.setLong("conciliacao", conciliacao.getCodigo());
				valor = Util.formatCurrency(query.uniqueResult().toString());
				query = session.createQuery("from ItensConciliacao as i where i.id.conciliacao = :conciliacao");
				query.setEntity("conciliacao", conciliacao);
				itConcilio = (List<ItensConciliacao>) query.list();
				dataGrid.setId(String.valueOf(conciliacao.getCodigo()));
				dataGrid.addData(String.valueOf(conciliacao.getCodigo()));
				dataGrid.addData(conciliacao.getNumero());
				dataGrid.addData(Util.parseDate(conciliacao.getEmissao(), "dd/MM/yyyy"));
				dataGrid.addData(Util.parseDate(conciliacao.getVencimento(), "dd/MM/yyyy"));
				dataGrid.addImg((itConcilio.get(0).getId().getLancamento().getTipo() == "c")
						? "../image/credito.gif" : "../image/debito.gif");
				dataGrid.addData("valTot", valor);											
				if (conciliacao.getVencimento().before(now)
						&& conciliacao.getStatus().equals("a")) {
					dataGrid.addImg("../image/atraso.png");
				} else {
					dataGrid.addImg("../image/ok_icon.png");
				}
				dataGrid.addCheck(true);
				dataGrid.addRow();
			}
			dataGrid.addTotalizadorRight("Total", "0.00", "totalSoma");
			dataGrid.makeTotalizadorRight();
			out.print(dataGrid.getTable(gridLines));
		}
		out.close();
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
	}
	
	private boolean updateRecord(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			pipe = Util.unmountPipeline(request.getParameter("pipe"));
			for (Long pp : pipe) {
				conciliacao = (Conciliacao) session.get(Conciliacao.class, pp);
				conciliacao.setStatus("q");
				session.update(conciliacao);
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
	
	private void mountFilter(HttpServletRequest request) {
		filter = new Filter("select distinct i.id.conciliacao from ItensConciliacao as i " +
				" where (1 = 1) ");
		
		if (!request.getParameter("codigoIn").equals("")) {
			filter.addFilter("i.id.conciliacao.codigo = :codigo", Long.class, "codigo",
					Long.valueOf(request.getParameter("codigoIn")));
		}
		if (!request.getParameter("numeroIn").equals("")) {
			filter.addFilter("i.id.conciliacao.numero = :numero", String.class, "numero", 
					Util.encodeString(request.getParameter("numeroIn"), "ISO-8859-1", "UTF-8"));
		}		
		if (!request.getParameter("tipoPagamento").equals("")) {
			filter.addFilter("i.id.lancamento.tipo = :tipo", String.class, "tipo", 
					Util.encodeString(request.getParameter("tipoPagamento"), "ISO-8859-1", "UTF-8"));
		}
		if (!request.getParameter("inicioIn").equals("")) {
			filter.addFilter("i.id.conciliacao.emissao between :inicio", java.util.Date.class, 
					"inicio", Util.parseDate(request.getParameter("inicioIn")));
			filter.addFilter(" :fim", java.util.Date.class, 
					"fim", Util.parseDate(request.getParameter("fimIn")));
		}
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("i.id.lancamento.unidade = :unidade", Long.class, "unidade",
					Long.valueOf(request.getParameter("unidadeId")));
		}
		if (!request.getParameter("status").equals("")) {
			filter.addFilter("i.id.conciliacao.status = :status", String.class, "status", 
					Util.encodeString(request.getParameter("status"), "ISO-8859-1", "UTF-8"));
		}
		filter.setOrder("i.id.conciliacao.status, i.id.conciliacao.vencimento");
	}
	
	

}
