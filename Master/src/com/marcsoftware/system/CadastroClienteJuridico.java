package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.ConnectionFactory;
import com.marcsoftware.database.Conta;
import com.marcsoftware.database.Empresa;
import com.marcsoftware.database.Endereco;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Funcionario;
import com.marcsoftware.database.Informacao;
import com.marcsoftware.database.Ramo;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class for Servlet: CadastroClienteJuridico
 *
 */
 public class CadastroClienteJuridico extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
	static final long serialVersionUID = 1L;
	private Empresa empresa;
	private Unidade unidade;
	private Funcionario funcionario;
	private Endereco endereco;
	private Informacao informacao;
	private Ramo ramo;
	private List<Empresa> empresList;
	private Session session;
	private Transaction transaction;
	private Query query;
	private PrintWriter out;
	private DataGrid dataGrid;
	private int count, limit, offSet, gridLines;
	private boolean isFilter;
	private Filter filter;
    
	public CadastroClienteJuridico() {
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
		empresList= (List<Empresa>) query.list();
		if (empresList.size() == 0) {
			out.print("0");
			transaction.commit();
			session.close();
			out.close();
			return;
		}
		dataGrid= new DataGrid(null);
		for (Empresa emp: empresList) {
			query = session.getNamedQuery("informacaoPrincipal");
			query.setEntity("pessoa", emp);
			query.setFirstResult(0);
			query.setMaxResults(1);			
			informacao= (Informacao) query.uniqueResult();
			dataGrid.setId(String.valueOf(emp.getCodigo()));
			dataGrid.addData(String.valueOf(emp.getCodigo()));
			dataGrid.addData(Util.initCap(emp.getFantasia()));
			dataGrid.addData(Util.initCap(emp.getContato()));
			dataGrid.addData(Util.formatCurrency(emp.getSaldoAcumulado()));
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
				response.sendRedirect("application/empresa.jsp");
			} else {
				response.sendRedirect("error_page.jsp?msg=" + Util.ERRO_INSERT );
			}			
		} catch (SQLException e) {
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?msg=" + Util.ERRO_INSERT);
		}
	}
	
	private boolean addRecord(HttpServletRequest request) throws SQLException {
		boolean isEdition= (request.getParameter("codEmpresa") != "");
		session= HibernateUtil.getSession();
		transaction= session.beginTransaction();
		try {
			query = session.createQuery("from Unidade as u where u.codigo = :codigo");
			query.setLong("codigo", Long.valueOf(Util.getPart(request.getParameter("unidadeId"), 2)));
			unidade= (Unidade) query.uniqueResult();
			query = session.createQuery("from Funcionario as f where f.codigo = :codigo");
			//query.setLong("codigo", Long.valueOf(Util.getPart(request.getParameter("idVendedor"), 1)));
			//funcionario= (Funcionario) query.uniqueResult();
			query = session.createQuery("from  Ramo as r where r.codigo = :codigo");
			query.setLong("codigo", Long.valueOf(request.getParameter("ramoIn")));
			ramo = (Ramo) query.uniqueResult();
			
			empresa = new Empresa();
			if (isEdition) {
				empresa.setCodigo(Long.valueOf(request.getParameter("codEmpresa")));
			}
			empresa.setUnidade(unidade);
			//empresa.setFuncionario(funcionario);
			empresa.setRamo(ramo);
			empresa.setCadastro(Util.parseDate(request.getParameter("cadastroIn")));
			empresa.setAtivo(request.getParameter("ativoChecked"));
			empresa.setReferencia("00");
			empresa.setRazaoSocial(request.getParameter("razaoSocialIn").toLowerCase());
			empresa.setFantasia(request.getParameter("fantasiaIn").toLowerCase());
			empresa.setCnpj(Util.unMountDocument(request.getParameter("cnpjIn")));
			empresa.setContato(request.getParameter("nomeContatoIn").toLowerCase());
			empresa.setCargoContato(request.getParameter("cargoContatoIn").toLowerCase());
			empresa.setDeleted("n");
			empresa.setVencimento(request.getParameter("vencimento"));
			session.saveOrUpdate(empresa);
			
			endereco = new Endereco();
			if (isEdition) {
				endereco.setCodigo(Long.valueOf(request.getParameter("codAddress")));
			}
			endereco.setPessoa(empresa);
			endereco.setCep(Util.unMountDocument(request.getParameter("cepIn")));
			endereco.setUf(request.getParameter("ufIn"));
			endereco.setCidade(request.getParameter("cidadeIn").toLowerCase());
			endereco.setRuaAv(request.getParameter("ruaIn").toLowerCase());
			endereco.setNumero(request.getParameter("numeroIn").toLowerCase());
			endereco.setBairro(request.getParameter("bairroIn").toLowerCase());
			endereco.setComplemento(request.getParameter("complementoIn").toLowerCase());
			session.saveOrUpdate(endereco);
			
			count = 0;
			String aux = "";
			while (request.getParameter("rowType" + String.valueOf(count)) != null) {
				informacao= new Informacao();
				if (!request.getParameter("ckdelContact" + String.valueOf(count)).equals("-1")) {
					informacao.setCodigo(Long.valueOf(request.getParameter("ckdelContact" + String.valueOf(count))));					
				}
				aux = (request.getParameter("rowMain" + String.valueOf(count)).toLowerCase().trim().equals("sim"))?
						"s": "n" ;
				informacao.setPessoa(empresa);
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
		filter = new Filter("from Empresa as e where e.deleted = \'n\'");		
		
		if (!request.getParameter("referenciaIn").equals("")) {
			filter.addFilter("e.codigo= :referencia",
					Long.class, "referencia", Long.valueOf(
							request.getParameter("referenciaIn")));
		}
		if (!request.getParameter("rzSocial").equals("")) {
			filter.addFilter("e.razaoSocial LIKE :razao", String.class, "razao", 
					"%" + request.getParameter("rzSocial").toLowerCase() + "%");
		}
		if (!request.getParameter("fantasia").equals("")) {
			filter.addFilter("e.fantasia LIKE :fantasia", String.class, "fantasia", 
					"%" + request.getParameter("fantasia").toLowerCase() + "%");
		}
		if (!request.getParameter("nomeContato").equals("")) {
			filter.addFilter("e.contato LIKE :contato", String.class, "contato", 
					"%" + request.getParameter("nomeContato").toLowerCase() + "%");
		}
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("e.unidade.codigo = :unidade", Long.class, "unidade",
					Integer.parseInt(Util.getPart(request.getParameter("unidadeId"), 2)));
		}
		if (!request.getParameter("ativoChecked").equals("")) {
			filter.addFilter("e.ativo = :ativo", String.class, "ativo",
					request.getParameter("ativoChecked"));
		}
		
		if (Util.getPart(request.getParameter("order"), 1).trim().equals("Ref.")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("e.codigo");				
			} else {
				filter.setOrder("e.codigo desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Fantasia")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("e.fantasia");				
			} else {
				filter.setOrder("e.fantasia desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Ramo")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("e.ramo.descricao");				
			} else {
				filter.setOrder("e.ramo.descricao desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Contato")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("e.contato");
			} else {
				filter.setOrder("e.contato desc");
			}
		} else if (Util.getPart(Util.encodeString(request.getParameter("order"), "ISO-8859-1", "UTF8"), 1).trim().equals("Crédito")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("e.saldoAcumulado");
			} else {
				filter.setOrder("e.saldoAcumulado desc");
			}
		}
	}
}