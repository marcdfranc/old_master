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
import com.marcsoftware.database.Conta;
import com.marcsoftware.database.Empresa;
import com.marcsoftware.database.Endereco;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Fornecedor;
import com.marcsoftware.database.Informacao;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.Ramo;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroFornecedor
 */
public class CadastroFornecedor extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Session session;
	private Transaction transaction;
	private Query query;
	private Unidade unidade;
	private Ramo ramo;
	private Fornecedor fornecedor;
	private List<Fornecedor> fornecedorList;
	private Login login;
	private Endereco endereco;
	private Informacao informacao;
	private Conta conta;
	private Banco banco;
	private Filter filter;
	private PrintWriter out;
	private boolean isFilter;
	private int limit, offSet, gridLines;
	private DataGrid dataGrid;
    
    public CadastroFornecedor() {
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
		limit= Integer.parseInt(request.getParameter("limit"));
		offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));		
		query = filter.mountQuery(query, session);
		gridLines= query.list().size();
		query.setFirstResult(offSet);
		query.setMaxResults(limit);
		fornecedorList = (List<Fornecedor>) query.list();
		if (fornecedorList.size() == 0) {
			out.print("0");
			transaction.commit();
			session.close();
			out.close();
			return;
		}
		dataGrid= new DataGrid(null);
		for (Fornecedor fornec: fornecedorList) {
			query = session.getNamedQuery("informacaoPrincipal");
			query.setEntity("pessoa", fornec);
			query.setFirstResult(0);
			query.setMaxResults(1);
			informacao = (Informacao) query.uniqueResult();
			dataGrid.setId(String.valueOf(fornec.getCodigo()));
			dataGrid.addData(String.valueOf(fornec.getCodigo()));
			dataGrid.addData(Util.initCap(fornec.getFantasia()));
			dataGrid.addData(Util.initCap(fornec.getRamo().getDescricao()));
			dataGrid.addData(Util.mountCnpj(fornec.getCnpj()));
			dataGrid.addData((informacao== null)? "" : informacao.getDescricao());							
			dataGrid.addRow();
		}
		transaction.commit();
		out.print(dataGrid.getBody(gridLines));
		out.close(); 
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			if (addRecord(request))  {
				response.sendRedirect("application/fornecedor.jsp");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + "&lk=" +
					"application/fornecedor.jsp");
			}			
		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + "&lk=" +
				"application/fornecedor.jsp");
		}
	}
	
	private boolean addRecord(HttpServletRequest request) {
		boolean isEdition= (request.getParameter("codigoIn") != "");
		session= HibernateUtil.getSession();
		transaction= session.beginTransaction();
		try {
			unidade = (Unidade) session.get(Unidade.class, Long.valueOf(Util.getPart(request.getParameter("unidadeId"), 2)));
			ramo = (Ramo) session.get(Ramo.class, Long.valueOf(request.getParameter("ramoIn")));
			query = session.createQuery("from Login as l where l.username = :username");
			query.setString("username", request.getSession().getAttribute("username").toString());
			login = (Login) query.uniqueResult();
			if (isEdition) {
				fornecedor = (Fornecedor) session.get(Fornecedor.class, Long.valueOf(request.getParameter("codigoIn")));
			} else {
				fornecedor = new Fornecedor();				
			}
			fornecedor.setAtivo(request.getParameter("ativoChecked"));
			fornecedor.setCadastrador(login);
			fornecedor.setCadastro(Util.parseDate(request.getParameter("cadastroIn")));
			fornecedor.setContato(request.getParameter("nomeContatoIn").toLowerCase());
			fornecedor.setCargoContato(request.getParameter("cargoContatoIn").toLowerCase());
			fornecedor.setCnpj(Util.unMountDocument(request.getParameter("cnpjIn")));
			fornecedor.setDeleted("n");
			fornecedor.setFantasia(request.getParameter("fantasiaIn").toLowerCase());
			fornecedor.setRamo(ramo);
			fornecedor.setRazaoSocial(request.getParameter("razaoSocialIn").toLowerCase());
			fornecedor.setUnidade(unidade);
			fornecedor.setVencimento(request.getParameter("vencimento"));
			fornecedor.setReferencia("00");
			
			session.saveOrUpdate(fornecedor);
			
			if (isEdition) {
				query = session.createQuery("from Endereco as e where e.pessoa = :pessoa");
				query.setEntity("pessoa", fornecedor);
				endereco = (Endereco) query.uniqueResult();				
			} else {
				endereco = new Endereco();
			}
			endereco.setBairro(request.getParameter("bairroIn").toLowerCase());
			endereco.setCep(Util.unMountDocument(request.getParameter("cepIn")));
			endereco.setCidade(request.getParameter("cidadeIn").toLowerCase());
			endereco.setComplemento(request.getParameter("complementoIn"));
			endereco.setNumero(request.getParameter("numeroIn"));
			endereco.setPessoa(fornecedor);
			endereco.setRuaAv(request.getParameter("ruaIn").toLowerCase());
			endereco.setUf(request.getParameter("ufIn").toUpperCase());
			
			session.saveOrUpdate(endereco);
			
			int count= 0;
			while (request.getParameter("rowBank" + String.valueOf(count)) != null) {				 
				conta = new Conta();
				if (!request.getParameter("ckdelBank" + String.valueOf(count)).equals("-1")) {
					conta.setCodigo(Long.valueOf(request.getParameter("ckdelBank" + String.valueOf(count))));
				}
				banco= (Banco) session.load(Banco.class, Long.valueOf(
						request.getParameter("rowBank" + String.valueOf(count))));
				conta.setPessoa(fornecedor);
				conta.setBanco(banco);
				conta.setAgencia(
						(request.getParameter("rowAgency" + String.valueOf(count))== "")?
								null : request.getParameter("rowAgency" + String.valueOf(count)));
				conta.setNumero(request.getParameter("rowCont" + String.valueOf(count)));
				conta.setTitular(request.getParameter("rowPrincipal" + String.valueOf(count++)));
				session.saveOrUpdate(conta);
			}
			
			count= 0;	
			while (request.getParameter("delBank" + String.valueOf(count)) != null) {
				query= session.createQuery("from Conta as c where c.codigo = :codigo");
				query.setLong("codigo", Long.valueOf(request.getParameter("delBank" + String.valueOf(count++))));
				conta= (Conta) query.uniqueResult();
				session.delete(conta);
			}
			
			count = 0;
			String aux = "";
			while (request.getParameter("rowType" + String.valueOf(count)) != null) {
				informacao= new Informacao();
				if (!request.getParameter("ckdelContact" + String.valueOf(count)).equals("-1")) {
					informacao.setCodigo(Long.valueOf(request.getParameter("ckdelContact" + String.valueOf(count))));					
				}
				aux = (request.getParameter("rowMain" + String.valueOf(count)).toLowerCase().trim().equals("sim"))?
						"s": "n" ;
				informacao.setPessoa(fornecedor);
				informacao.setTipo(request.getParameter("rowType" + String.valueOf(count)));
				informacao.setDescricao(request.getParameter("rowDescript" + String.valueOf(count++)));
				informacao.setPrincipal(aux);
				
				session.saveOrUpdate(informacao);
			}
			
			count= 0;
			while (request.getParameter("delContact" + String.valueOf(count)) != null) {
				long key =  Long.valueOf(request.getParameter("delContact" + String.valueOf(count++)));
				query= session.createQuery("from Informacao as i where i.codigo = :codigo");
				query.setLong("codigo", key);
				informacao= (Informacao) query.uniqueResult();
				session.delete(informacao);
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
		filter = new Filter("from Fornecedor as f where f.deleted = \'n\'");		
		
		if (!request.getParameter("referenciaIn").equals("")) {
			filter.addFilter("f.codigo = :referencia",
					Long.class, "referencia", Long.valueOf(request.getParameter("referenciaIn")));
		}
		if (!request.getParameter("rzSocial").equals("")) {
			filter.addFilter("f.razaoSocial LIKE :razao", String.class, "razao", 
					"%" + request.getParameter("rzSocial").toLowerCase() + "%");
		}
		if (!request.getParameter("fantasia").equals("")) {
			filter.addFilter("f.fantasia LIKE :fantasia", String.class, "fantasia", 
					"%" + request.getParameter("fantasia").toLowerCase() + "%");
		}		
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("f.unidade.codigo = :unidade", Long.class, "unidade",
					Integer.parseInt(Util.getPart(request.getParameter("unidadeId"), 2)));
		}
		if (!request.getParameter("ativoChecked").equals("")) {
			filter.addFilter("e.ativo = :ativo", String.class, "ativo",
					request.getParameter("ativoChecked"));
		}
		
		if (Util.getPart(request.getParameter("order"), 1).trim().equals("ref")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("f.codigo");				
			} else {
				filter.setOrder("f.codigo desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Fantasia")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("f.fantasia");				
			} else {
				filter.setOrder("f.fantasia desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Ramo")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("f.ramo.descricao");				
			} else {
				filter.setOrder("f.ramo.descricao desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("rzSocial")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("f.razaoSocial");				
			} else {
				filter.setOrder("f.razaoSocial desc");
			}
		} 
	}

}
