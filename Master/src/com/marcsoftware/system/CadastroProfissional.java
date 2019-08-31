package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Banco;
import com.marcsoftware.database.Conta;
import com.marcsoftware.database.Endereco;
import com.marcsoftware.database.Especialidade;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Informacao;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.Profissional;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.BDImgAdmin;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class for Servlet: CadastroProfissional
 *
 */
public class CadastroProfissional extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
	static final long serialVersionUID = 1L;
	private int limit, offSet, gridLines, parcelas, mes, year;   	
   	private boolean isFilter;
   	private Profissional profissional;
   	private Unidade unidade;
   	private Especialidade especialidade;
   	private Endereco endereco;
   	private Informacao informacao;   	
   	private Conta conta;
   	private Banco banco;
   	private Login login;
   	private Filter filter;
   	private List<Profissional> profissionalList;
   	private PrintWriter out;
   	private DataGrid dataGrid;
   	private Session session;
   	private Transaction transaction;
   	private Query query;
   	private int count;
	    
	public CadastroProfissional() {
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
		profissionalList= (List<Profissional>) query.list();
		if (profissionalList.size() == 0) {
			out.print("<tr><td></td><td><p>" + Util.SEM_REGISTRO + "</p></td><td></td><td></td><td></td><td></td></tr>");
			out.close();
			transaction.commit();
			session.close();
		}
		DataGrid dataGrid = new DataGrid(null);	
		for(Profissional prof: profissionalList) {
			query = session.getNamedQuery("informacaoPrincipal");
			query.setEntity("pessoa", prof);
			query.setFirstResult(0);
			query.setMaxResults(1);
			informacao= (Informacao) query.uniqueResult();
			dataGrid.setId(String.valueOf(prof.getCodigo()));
			dataGrid.addData(String.valueOf(prof.getCodigo()));
			dataGrid.addData(Util.initCap(prof.getNome()));
			dataGrid.addData(Util.mountCpf(prof.getCpf()));
			dataGrid.addData(prof.getConselho());
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
				response.sendRedirect("application/profissionais.jsp");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
				"&lk=application/profissionais.jsp");
			}
		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
			"&lk=application/profissionais.jsp");
		}
	}
	
	private boolean addRecord(HttpServletRequest request) {
		boolean isEdition= request.getParameter("isEdition").trim().equals("t");
		session= HibernateUtil.getSession();		
		transaction= session.beginTransaction();
		try {
			unidade = (Unidade) session.get(Unidade.class, Long.valueOf(Util.getPart(request.getParameter("unidadeId"), 2)));			
			especialidade = (Especialidade) session.get(Especialidade.class, Long.valueOf(request.getParameter("especialidadeIn")));
			if (isEdition) {
				profissional = (Profissional) session.get(Profissional.class, Long.valueOf(request.getParameter("codProfissional")));
			} else {
				profissional = new Profissional();
			}
			profissional.setUnidade(unidade);
			profissional.setEspecialidade(especialidade);
			profissional.setConselho(request.getParameter("conselhoIn"));
			profissional.setCadastro(Util.parseDate(request.getParameter("cadastroIn")));			
			profissional.setVencimento(request.getParameter("vencimento"));
			profissional.setAtivo(request.getParameter("ativoChecked"));
			profissional.setReferencia("0000");
			profissional.setNome(request.getParameter("nomeIn").toLowerCase());
			profissional.setSexo(request.getParameter("sexo"));
			profissional.setCpf(Util.unMountDocument(request.getParameter("cpfIn")));
			profissional.setRg(request.getParameter("rgIn"));
			profissional.setNascimento(Util.parseDate(request.getParameter("nascimentoIn")));
			profissional.setEstadoCivil(request.getParameter("estadoCivilIn"));			
			profissional.setNacionalidade(request.getParameter("nacionalidadeIn").toLowerCase());
			profissional.setNaturalidade(request.getParameter("naturalidadeIn").toLowerCase());
			profissional.setNaturalidadeUf(request.getParameter("naturalUfIn"));
			profissional.setDeleted("n");
			profissional.setLogin(login);
			profissional.setIsAdm("f");
			session.saveOrUpdate(profissional);
			
			if (isEdition) {
				endereco = (Endereco) session.get(Endereco.class, Long.valueOf(request.getParameter("codAddress")));
			} else {
				endereco = new Endereco();
			}
			endereco.setPessoa(profissional);
			endereco.setCep(Util.unMountDocument(request.getParameter("cepIn")));
			endereco.setRuaAv(request.getParameter("ruaIn").toLowerCase());
			endereco.setNumero(request.getParameter("numeroIn").toLowerCase());
			endereco.setComplemento(request.getParameter("complementoIn").toLowerCase());
			endereco.setBairro(request.getParameter("bairroIn").toLowerCase());
			endereco.setCidade(request.getParameter("cidadeIn").toLowerCase());
			endereco.setUf(request.getParameter("ufIn"));
			session.saveOrUpdate(endereco);
			
			count= 0;
			while (request.getParameter("rowBank" + String.valueOf(count)) != null) {				 
				conta = new Conta();
				if (!request.getParameter("ckdelBank" + String.valueOf(count)).equals("-1")) {
					conta.setCodigo(Long.valueOf(request.getParameter("ckdelBank" + String.valueOf(count))));
				}
				banco= (Banco) session.load(Banco.class, Long.valueOf(
						request.getParameter("rowBank" + String.valueOf(count))));
				conta.setPessoa(profissional);
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
			
			count= 0;
			while (request.getParameter("rowType" + String.valueOf(count)) != null) {
				informacao= new Informacao();
				if (!request.getParameter("ckdelContact" + String.valueOf(count)).equals("-1")) {
					informacao.setCodigo(Long.valueOf(request.getParameter("ckdelContact" + String.valueOf(count))));
				}
				informacao.setPessoa(profissional);
				informacao.setTipo(request.getParameter("rowType" + String.valueOf(count)));
				informacao.setPrincipal((request.getParameter("rowMain" + String.valueOf(count)).trim().toLowerCase().equals("sim"))?
						"s" : "n");
				informacao.setDescricao(request.getParameter("rowDescript" + String.valueOf(count++)));
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
			transaction.rollback();
			session.close();
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
	private void mountFilter(HttpServletRequest request) {		
		filter= new Filter("from Profissional as p");
		if (!request.getParameter("referenciaIn").equals("")) {
			filter.addFilter("p.referencia = :referencia",
					String.class, "referencia", request.getParameter("referenciaIn"));
		}
		if (!request.getParameter("nomeIn").equals("")) {
			filter.addFilter("p.nome LIKE :nome", String.class, "nome", 
					"%" + Util.encodeString(request.getParameter("nomeIn"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("cpfIn").equals("")) {
			filter.addFilter("p.cpf = :cpf", String.class, "cpf", 
				 	Util.unMountDocument(request.getParameter("cpfIn")));
		}
		if (!request.getParameter("conselhoIn").equals("")) {
			filter.addFilter("p.conselho = :conselho", String.class, "conselho", 
				 	request.getParameter("conselhoIn"));
		}
		if (!request.getParameter("setorIn").equals("")) {
			filter.addFilter("p.especialidade.setor = :setor", String.class, "setor", 
				 	request.getParameter("setorIn"));
		}
		if (!request.getParameter("especialidadeIn").equals("")) {
			filter.addFilter("p.especialidade = :especialidade", String.class, 
					"especialidade", request.getParameter("especialidadeIn"));
		}
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("p.unidade.codigo = :unidade", Long.class, "unidade",
					Integer.parseInt(Util.getPart(request.getParameter("unidadeId"), 2)));
		}
		if (!request.getParameter("ativoChecked").equals("")) {
			filter.addFilter("p.ativo = :ativo", String.class, "ativo",
					request.getParameter("ativoChecked"));
		}
		filter.setOrder("p.nome");
	}
}