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
import com.marcsoftware.database.FormaPagamento;
import com.marcsoftware.database.ItensConciliacao;
import com.marcsoftware.database.ItensConciliacaoId;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Profissional;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroLancamento
 */
public class CadastroLancamento extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Lancamento lancamento;
	private List<Lancamento> lancamentoList;
	private Unidade unidade;
	private TipoConta conta;
	private Conciliacao conciliacao;
	private FormaPagamento pagamento;
	private ItensConciliacao itenConciliacao;
	private ItensConciliacaoId itemId;
	private Date now;
	private PrintWriter out;
	private boolean isFilter;
	private int limit, offSet, gridLines;
	private Filter filter;
	private Session session;
    private Transaction transaction;
    private Query query, queryTotal;
    private double debito, credito;
    private String sqlDebito, sqlCredito;
    private ArrayList<IteracaoSoma> itens;    
    
    public CadastroLancamento() {
        super();        
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("ISO-8859-1");				
		response.setContentType("text/html");
		response.setCharacterEncoding("ISO-8859-1");		
		out= response.getWriter();
		session= HibernateUtil.getSession();
		transaction= session.beginTransaction();
		isFilter= request.getParameter("isFilter") == "1";
		mountFilter(request);
		queryTotal = session.createSQLQuery(sqlCredito);		
		for (int i = 0; i < itens.size(); i++) {
			switch (itens.get(i).getType()) {
			case 1:
				queryTotal.setString(i, itens.get(i).getValue());
				break;
				
			case 2:
				queryTotal.setLong(i, Long.valueOf(itens.get(i).getValue()));
				break;
				
			case 3:
				queryTotal.setDouble(i, Double.parseDouble(itens.get(i).getValue()));
				break;
				
			case 4:
				queryTotal.setDate(i, Util.parseDate(itens.get(i).getValue()));
				break;	
			}
		}
		
		credito = (queryTotal.uniqueResult() == null)? 0: Double.parseDouble(queryTotal.uniqueResult().toString()) ;
		
		queryTotal = session.createSQLQuery(sqlDebito);		
		for (int i = 0; i < itens.size(); i++) {
			switch (itens.get(i).getType()) {
			case 1:
				queryTotal.setString(i, itens.get(i).getValue());
				break;
				
			case 2:
				queryTotal.setLong(i, Long.valueOf(itens.get(i).getValue()));
				break;
				
			case 3:
				queryTotal.setDouble(i, Double.parseDouble(itens.get(i).getValue()));
				break;
				
			case 4:
				queryTotal.setDate(i, Util.parseDate(itens.get(i).getValue()));
				break;	
			}
		}
		
		debito = (queryTotal.uniqueResult() == null)? 0 : Double.parseDouble(queryTotal.uniqueResult().toString());		
		limit= Integer.parseInt(request.getParameter("limit"));
		offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
		query = filter.mountQuery(query, session);
		gridLines= query.list().size();
		query.setFirstResult(offSet);
		query.setMaxResults(limit);
		lancamentoList= (List<Lancamento>) query.list();
		DataGrid dataGrid = new DataGrid("cadastro_lancamento.jsp");
		dataGrid.addColum("2", "Código");						
		dataGrid.addColum("23", "Documento");
		dataGrid.addColum("49", "Descrição");
		dataGrid.addColum("6", "Vencimento");
		dataGrid.addColum("6", "Unid.");
		dataGrid.addColum("3", "tipo");
		dataGrid.addColum("9", "valor");
		dataGrid.addColum("2", "St");
		if (lancamentoList.size() == 0) {
			for (int i = 0; i < 8; i++) {
				if (i == 2) {
					dataGrid.addData(Util.SEM_REGISTRO);
				} else {
					dataGrid.addData("");					
				}
			}
			dataGrid.addRow();
			out.print(dataGrid.getTable(1));
			out.close();
			transaction.commit();
			session.close();
			out.close();
			return;
		}
		for(Lancamento lc: lancamentoList) {
			dataGrid.setId(String.valueOf(lc.getCodigo()));
			dataGrid.addData(String.valueOf(lc.getCodigo()));
			dataGrid.addData((lc.getDocumento() == null)? "--------" : lc.getDocumento());
			dataGrid.addData(Util.initCap(lc.getConta().getDescricao()));
			dataGrid.addData((lc.getVencimento() == null)? "--------" 
					: Util.parseDate(lc.getVencimento(), "dd/MM/yyyy"));
			dataGrid.addData(lc.getUnidade().getReferencia());
			if (lc.getTipo().trim().equals("c")) {								
				dataGrid.addImg("../image/credito.gif");
			} else {								
				dataGrid.addImg("../image/debito.gif");
			}					
			dataGrid.addData(Util.formatCurrency(String.valueOf(lc.getValor())));
			dataGrid.addImg((lc.getVencimento() == null)? "../image/cancelado.png" 
					: Util.getIcon(lc.getVencimento(), lc.getStatus()));
			dataGrid.addRow();
		}
		dataGrid.addTotalizador("Crédito", Util.formatCurrency(credito), true);
		dataGrid.addTotalizador("Débito", String.valueOf(debito), false);
		dataGrid.makeTotalizador();
		dataGrid.addTotalizadorRight("Total", Util.formatCurrency(credito - debito));
		dataGrid.makeTotalizadorRight();
		out.print(dataGrid.getTable(gridLines));
		transaction.commit();
		session.close();
		out.close();
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			if (addRecord(request))  {
				response.sendRedirect("error_page.jsp?errorMsg=Conta Lançada com sucesso!" + 
						"&lk=application/cadastro_lancamento.jsp");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
					"&lk=application/caixa.jsp");
			}			
		} catch (Exception e) {			
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
				"&lk=application/caixa.jsp");
		}
	}
	
	private boolean addRecord(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			query = session.createQuery("from Unidade as u where u.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidadeIdIn")));
			unidade = (Unidade) query.uniqueResult();
			
			conta = (TipoConta) session.get(TipoConta.class, Long.valueOf(request.getParameter("contaIn")));
			
			now = new Date();			
			
			lancamento = new Lancamento();
			lancamento.setDataQuitacao(now);
			lancamento.setConta(conta);
			//lancamento.setDescricao(conta.getDescricao());
			lancamento.setDocumento(request.getParameter("documentoIn"));
			lancamento.setEmissao(Util.parseDate(request.getParameter("emissaoIn")));
			lancamento.setRecebimento(request.getSession().getAttribute("username").toString());
			lancamento.setStatus("q");
			lancamento.setTipo(request.getParameter("tipoIn"));
			lancamento.setUnidade(unidade);
			lancamento.setValor(Double.parseDouble(request.getParameter("valorIn")));
			lancamento.setValorPago(Double.parseDouble(request.getParameter("valorPagoIn")));
			lancamento.setVencimento(Util.parseDate(request.getParameter("vencimentoIn")));
			//lancamento.setDescricao(request.getParameter("descricaoIn"));
			//lancamento.setTaxa(Double.parseDouble(request.getParameter("taxaIn")));
			session.save(lancamento);
			
			if (Util.getPart(request.getParameter("tipoPagamento"), 2).trim().equals("s")) {
				pagamento = (FormaPagamento) session.get(FormaPagamento.class, 
						Long.valueOf(Util.getPart(request.getParameter("tipoPagamento"), 1)));
				
				conciliacao = new Conciliacao();
				conciliacao.setEmissao(Util.parseDate(request.getParameter("emissaoIn")));
				conciliacao.setFormaPagamento(pagamento);
				conciliacao.setNumero(request.getParameter("numTitulo"));
				conciliacao.setStatus("a");
				conciliacao.setVencimento(Util.parseDate(request.getParameter("vencimentoIn")));
				session.save(conciliacao);
				
				itemId = new ItensConciliacaoId();
				itemId.setConciliacao(conciliacao);
				itemId.setLancamento(lancamento);
				
				itenConciliacao = new ItensConciliacao();
				itenConciliacao.setId(itemId);
				itenConciliacao.setDocDigital("n");
				session.save(itenConciliacao);
			}		
			
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
		sqlDebito = "SELECT SUM(l.valor) FROM lancamento AS l WHERE l.tipo = 'd' ";
		sqlCredito = "SELECT SUM(l.valor) FROM lancamento AS l WHERE l.tipo = 'c' ";
		itens = new ArrayList<IteracaoSoma>();
		now = new Date();
		if (!request.getParameter("status").equals("")) {
			if (request.getParameter("status").equals("at")) {
				filter = new Filter("from Lancamento as l where l.status = 'a' ");				
				filter.addFilter("l.vencimento < :vencimentoAt", java.util.Date.class, 
						"vencimentoAt", now);
				sqlCredito += " AND l.status = 'a' AND l.vencimento < ?";
				sqlDebito += " AND l.status = 'a' AND l.vencimento < ?";
				itens.add(new IteracaoSoma("-1", Util.parseDate(now, "dd/MM/yyyy"), 4));
			} else if (request.getParameter("status").trim().equals("q")) {
				filter = new Filter("from Lancamento as l where l.status in('q', 'f')");
				sqlCredito += " AND l.status in('q', 'f')";
				sqlDebito += " AND l.status in('q', 'f')";
			} else {
				filter= new Filter("from Lancamento as l ");				
				filter.addFilter("l.status = :status", String.class, "status", 
						request.getParameter("status"));
				sqlCredito+= " AND l.status = ? ";
				sqlDebito+= " AND l.status = ? ";
				itens.add(new IteracaoSoma("status", request.getParameter("status"), 1));
			}
		} else {
			filter= new Filter("from Lancamento as l ");
		}
		if (!request.getParameter("lancamento").equals("")) {
			filter.addFilter("l.codigo = :lancamento",
					Long.class, "lancamento", Long.valueOf(request.getParameter("lancamento")));
			sqlCredito += " AND l.codigo = ? ";
			sqlDebito += " AND l.codigo = ? ";
			itens.add(new IteracaoSoma("lancamento", request.getParameter("lancamento"), 2));
		}
		if (!request.getParameter("documentoIn").equals("")) {
			filter.addFilter("l.documento LIKE :documento",
					String.class, "documento", "%" + request.getParameter("documentoIn") + "%");
			sqlCredito += " AND l.documento LIKE '%?%' ";
			sqlDebito += " AND l.documento LIKE '%?%' ";
			itens.add(new IteracaoSoma("documentoIn", request.getParameter("documentoIn"), 1));
		}
		if (!request.getParameter("descricaoIn").equals("")) {
			filter.addFilter("l.conta.codigo = :descricao", Long.class, "descricao", 
					Long.valueOf(request.getParameter("descricaoIn")));
			sqlCredito += " AND l.cod_conta = ? ";
			sqlDebito += " AND l.cod_conta = ? ";
			itens.add(new IteracaoSoma("descricaoIn", request.getParameter("descricaoIn"), 2));
		}
		if (!request.getParameter("inicioIn").equals("")) {
			filter.addFilter("l.dataQuitacao between :inicio", java.util.Date.class, 
					"inicio", Util.parseDate(request.getParameter("inicioIn")));
			filter.addFilter(" :fim", java.util.Date.class, 
					"fim", Util.addDays(request.getParameter("fimIn"), 1));
			sqlCredito += " AND (l.data_quitacao BETWEEN ? AND ?) ";
			sqlDebito += " AND (l.data_quitacao BETWEEN ? AND ?) ";
			itens.add(new IteracaoSoma("descricaoIn", request.getParameter("inicioIn"), 4));
			itens.add(new IteracaoSoma("descricaoIn", Util.parseDate(
					Util.addDays(request.getParameter("fimIn"), 1), "dd/MM/yyyy") , 4));
		}
		if (!request.getParameter("tipoIn").equals("")) {
			filter.addFilter("l.tipo = :tipo", String.class, "tipo", 
				request.getParameter("tipoIn"));
			sqlCredito += " AND l.tipo = ? ";
			sqlDebito += " AND l.tipo = ? ";
			itens.add(new IteracaoSoma("tipoIn", request.getParameter("tipoIn"), 1));
		}
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("l.unidade.codigo = :unidade", Long.class, "unidade",
					Integer.parseInt(Util.getPart(request.getParameter("unidadeId"), 2)));
			sqlCredito += " AND l.cod_unidade = ? ";
			sqlDebito += " AND l.cod_unidade = ? ";
			itens.add(new IteracaoSoma("tipoIn", 
					Util.getPart(request.getParameter("unidadeId"), 2), 2));
		}
		filter.setOrder("l.vencimento desc");	
	}
	
	/**
	 * 1 = String
	 * 2 = Long
	 * 3 = Double
	 * 4 = Date
	 * default = Entity
	 */
	
	
	private class IteracaoSoma {
		private String field, value;
		private int type;
		
		public IteracaoSoma(String field, String value, int type) {
			this.field = field;
			this.value = value;
			this.type = type;
		}
		public String getField() {
			return this.field;
		}
		
		public String getValue() {
			return this.value;
		}
		
		public int getType() {
			return this.type;
		}
	}
}
