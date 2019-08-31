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

import com.marcsoftware.database.Compra;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Fornecedor;
import com.marcsoftware.database.Insumo;
import com.marcsoftware.database.ItensCompra;
import com.marcsoftware.database.ItensCompraId;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.ParcelaCompra;
import com.marcsoftware.database.ParcelaCompraId;
import com.marcsoftware.database.Pessoa;
import com.marcsoftware.database.PrestadorServico;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroPedido
 */
public class CadastroPedido extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private PrintWriter out;
	private Session session;
	private Transaction transaction;
	private Query query;
	private Filter filter;
	private boolean isFilter;
	private int limit, offSet, gridLines;
	private List<Compra> compraList;
	private List<ParcelaCompra> parcelaList;
	private Compra compra;
	private ArrayList<String> pipe;
	private ItensCompra itensCompra;
	private ItensCompraId id;
	private Fornecedor fornecedor;
	private PrestadorServico prestador;
	private Pessoa pessoa;
	private Unidade unidade;
	private Insumo insumo;
	private ParcelaCompra parcela;
	private ParcelaCompraId parcelaId;
	private Lancamento lancamento;
	private TipoConta conta;
	private DataGrid dataGrid;
	boolean isJuridica;
    
    public CadastroPedido() {
        super();
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		if (request.getParameter("from").equals("1")) {
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(Util.encodeString(addRecord(request), "UTF8", "ISO-8859-1"));
			out.close();
			return;
		} else if (request.getParameter("from").equals("2")) {
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(Util.encodeString(generateParcela(request), "UTF8", "ISO-8859-1"));
			out.close();
			return;
		}
		isJuridica = request.getParameter("origem").equals("forn");
		request.setCharacterEncoding("ISO-8859-1");
		response.setContentType("text/html");
		out= response.getWriter();
		session= HibernateUtil.getSession();
		transaction= session.beginTransaction();
		isFilter= request.getParameter("isFilter") == "1";
		mountFilter(request);
		limit= Integer.parseInt(request.getParameter("limit"));
		offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
		query = filter.mountQuery(query, session);
		gridLines= query.list().size();
		query.setFirstResult(offSet);
		query.setMaxResults(limit);	
		compraList = (List<Compra>) query.list();
		if (compraList.size() == 0) {
			out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td></tr>");
			transaction.commit();
			session.close();
			out.close();
			return;
		}
		dataGrid= new DataGrid(null);
		for(Compra comp: compraList) {							
			if (isJuridica) {
				query = session.createQuery("select f.fantasia from Fornecedor as f where f.codigo = :codigo");
			} else {
				query = session.createQuery("select p.nome from PrestadorServico as p where p.codigo = :codigo");
			}
			query.setLong("codigo", comp.getFornecedor().getCodigo());
			dataGrid.setId(String.valueOf(comp.getCodigo()));							
			dataGrid.addData(String.valueOf(comp.getCodigo()));							
			dataGrid.addData(Util.initCap(query.uniqueResult().toString()));
			
			query = session.createQuery("from ParcelaCompra as p where p.id.compra = :compra");
			query.setEntity("compra", comp);
			parcelaList = (List<ParcelaCompra>) query.list();
			if (parcelaList.size() == 0) {
				dataGrid.addData("--------");
			} else {
				dataGrid.addData(parcelaList.get(0).getId().getLancamento().getDocumento());
			}
			dataGrid.addData(Util.parseDate(comp.getCadastro(), "dd/MM/yyyy"));
			query = session.createSQLQuery("SELECT SUM(i.quantidade * i.custo) " + 
					" FROM itens_compra AS i " +
					" WHERE i.cod_compra = :compra");
			query.setLong("compra", comp.getCodigo());							
			dataGrid.addData(Util.formatCurrency(query.uniqueResult().toString()));
			
			if (parcelaList.size() == 0) {
				dataGrid.addImg("../image/em_aberto.png");
			} else {
				dataGrid.addImg(Util.getIcon(parcelaList, "compra"));
			}
			
			dataGrid.addRow();
		}
		transaction.commit();
		session.close();
		out.print(dataGrid.getBody(gridLines));
		out.close();
	}
	
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)	throws ServletException, IOException {
	
	}
	
	private String addRecord(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			boolean isEdition = !request.getParameter("codigo").equals("");
			unidade = (Unidade) session.get(Unidade.class, Long.valueOf(request.getParameter("unidade")));
			if (isEdition) {
				compra = (Compra) session.get(Compra.class, Long.valueOf(request.getParameter("codigo")));
			} else {
				compra = new Compra();
			}
			
			pessoa = (Pessoa) session.get(Pessoa.class, Long.valueOf(request.getParameter("idFornecedor")));			
			compra.setFornecedor(pessoa);
			compra.setCadastro(Util.parseDate(request.getParameter("cadastro")));
			compra.setUnidade(unidade);
			
			session.saveOrUpdate(compra);	
			
			pipe = Util.unmountRealPipe(request.getParameter("pipe"));
			
			for (String pp : pipe) {
				
				if (!isEdition) {
					insumo = (Insumo) session.get(Insumo.class, 
							Long.valueOf(Util.getPipeById(pp, 0)));				
					itensCompra = new ItensCompra();
					id = new ItensCompraId();
					id.setCompra(compra);
					id.setInsumo(insumo);
					itensCompra.setId(id);
				} else {
					itensCompra = (ItensCompra) query.uniqueResult();
				}
				itensCompra.setQuantidade(Integer.parseInt(Util.getPipeById(pp, 1)));
				itensCompra.setCusto(Double.parseDouble(Util.getPipeById(pp, 2)));
				
				session.saveOrUpdate(itensCompra);
			}
			session.flush();
			transaction.commit();
			session.close();			
		} catch (Exception e) {
			e.printStackTrace();			
			transaction.rollback();
			session.close();
			return "O Pedido não pode ser salvo devido a um erro interno!";
		}
		return "Pedido Salvo com sucesso!";
	}
	
	
	private void mountFilter(HttpServletRequest request) {		
		if (isJuridica) {
			filter = new Filter("from Compra as c where c.fornecedor in( " +
						"from Fornecedor as n)");
			
			if (!request.getParameter("fantasia").equals("")) {
				filter.addFilter("c.fornecedor.codigo in(select f.codigo from Fornecedor as f " +
						" where f.fantasia like :fantasia)", String.class, "fantasia", 
						"%" + Util.encodeString(request.getParameter("fantasia"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
			}
			if (!request.getParameter("rzSocial").equals("")) {
				filter.addFilter("c.fornecedor.codigo in(select o.codigo from Fornecedor as o " +
						" where o.razaoSocial like :rzSocial)", String.class, "rzSocial", 
						"%" + Util.encodeString(request.getParameter("rzSocial"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
			}
			if (!request.getParameter("cnpj").equals("")) {
				filter.addFilter("c.fornecedor.codigo in(select n.codigo from Fornecedor as n " +
						" where n.cnpj = :cnpj)", String.class, "cnpj",
						Util.unMountDocument(request.getParameter("cnpj")));
			}			
		} else {
			filter = new Filter("from Compra as c where c.fornecedor in( " +
						"from PrestadorServico as a)");
			
			if (!request.getParameter("nome").equals("")) {
				filter.addFilter("i.fornecedor.codigo in(select r.codigo from PrestadorServico as r " +
						" where r.nome like :nome)", String.class, "nome", 
						"%" + Util.encodeString(request.getParameter("nome"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
			}
			if (!request.getParameter("cpf").equals("")) {
				filter.addFilter("c.fornecedor.codigo in(select e.codigo from PrestadorServico as e " +
						" where e.cpf = :cpf)", String.class, "cpf",
						Util.unMountDocument(request.getParameter("cpf")));
			}
			if (!request.getParameter("nascimento").equals("")) {
				filter.addFilter("c.fornecedor.codigo in(select t.codigo from PrestadorServico as t " +
						" where t.nascimento = :nascimento)", java.util.Date.class, 
						"nascimento", Util.parseDate(request.getParameter("nascimento")));
			}
		}
		if (!request.getParameter("fornecedorId").equals("")) {
			filter.addFilter("c.fornecedor.codigo = :fornecedorId", Long.class, "fornecedorId",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("fornecedorId"))));
		}
		if (!request.getParameter("pedido").equals("")) {
			filter.addFilter("c.codigo = :pedido", Long.class, "pedido",
					Long.valueOf(request.getParameter("pedido")));
		}
		if (!request.getParameter("cadastro").equals("")) {
			filter.addFilter("u.cadastro = :cadastro", java.util.Date.class, 
					"cadastro", Util.parseDate(request.getParameter("cadastro")));
		}
		if (!request.getParameter("documento").equals("")) {
			filter.addFilter("c in(select p.id.compra from ParcelaCompra as p " +
					" where p.id.lancamento.documento = :documento)", String.class, "documento",
					Util.unMountDocument(request.getParameter("documento")));
		}
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("c.unidade.codigo = :unidadeId", Long.class, "unidadeId",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("unidadeId"))));
		}		
		filter.setOrder("c.cadastro Desc");
	}
	
	
	private String generateParcela(HttpServletRequest request) {
		int qtde = Integer.parseInt(request.getParameter("qtde"));
		double entrada = (request.getParameter("entrada").equals("0.00"))? 0 :
				Double.parseDouble(request.getParameter("entrada"));
		double vlrParcela = 0;
		if (entrada > 0) {
			vlrParcela = (Double.parseDouble(request.getParameter("vlrTotal")) - entrada) / (qtde - 1);			
		} else {
			vlrParcela = Double.parseDouble(request.getParameter("vlrTotal")) / qtde;
		}
		Date vencimento = Util.parseDate(request.getParameter("inicio"));
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			query = session.createQuery("from ParcelaCompra as p where p.id.compra.codigo = :compra");
			query.setLong("compra", Long.valueOf(request.getParameter("compra")));
			if (query.list().size() > 0) {
				transaction.rollback();
				session.close();
				return "Este pedido já foi parcelado!";
			}
			compra = (Compra) session.get(Compra.class, 
					Long.valueOf(request.getParameter("compra")));
			
			conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("7"));
			
			for (int i = 0; i < qtde; i++) {
				lancamento = new Lancamento();
				lancamento.setConta(conta);
				lancamento.setDocumento("Pedido: " + compra.getCodigo() + " " + request.getParameter("documento"));
				lancamento.setEmissao(Util.parseDate(request.getParameter("emissao")));
				lancamento.setJuros(0);
				lancamento.setMulta(0);
				lancamento.setStatus("a");
				lancamento.setTaxa(0);
				lancamento.setTipo("d");
				lancamento.setUnidade(compra.getUnidade());
				if ((i == 0) && (entrada > 0)) {
					lancamento.setValor(entrada);
				} else {
					lancamento.setValor(vlrParcela);
				}
				lancamento.setVencimento(vencimento);
			 
				session.save(lancamento);
				
				parcelaId = new ParcelaCompraId();
				parcelaId.setCompra(compra);
				parcelaId.setLancamento(lancamento);
				
				parcela = new ParcelaCompra();
				parcela.setId(parcelaId);
				
				session.save(parcela);
				vencimento = Util.addMonths(vencimento, 1);
			}
			session.flush();
			transaction.commit();
			session.close();
			
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível gerar as parcelas devido a um erro interno!";
		}
		return "Parcelas geradas com sucesso!";
	}
}
