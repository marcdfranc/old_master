package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
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

import com.marcsoftware.database.EmpresaSaude;
import com.marcsoftware.database.Endereco;
import com.marcsoftware.database.Especialidade;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Informacao;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.Profissional;
import com.marcsoftware.database.Ramo;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroEmpresaSaude
 */
public class CadastroEmpresaSaude extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Unidade unidade;
	private Especialidade especialidade;
	private Ramo ramo;
	private Login login;
	private EmpresaSaude empresaSaude;
	private List<EmpresaSaude> empresaList;
	private Endereco endereco;
	private Conta conta;
	private Banco banco;
	private Informacao informacao;
	private Filter filter;
	private int count;	
	private Session session;
	private Transaction transaction;
	private Query query;
	private PrintWriter out;
	private boolean isFilter;
	private int limit, offSet, gridLines;
   
    public CadastroEmpresaSaude() {
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
		empresaList = (List<EmpresaSaude>) query.list();
		if (empresaList.size() == 0) {
			out.print("<tr><td></td><td><p>" + Util.SEM_REGISTRO + "</p></td><td></td><td></td><td></td><td></td></tr>");
			out.close();
			transaction.commit();
			session.close();
		}
		DataGrid dataGrid = new DataGrid(null);
		for (EmpresaSaude empresa : empresaList) {
			query = session.getNamedQuery("informacaoPrincipal");
			query.setEntity("pessoa", empresa);
			query.setFirstResult(0);
			query.setMaxResults(1);
			informacao= (Informacao) query.uniqueResult();
			dataGrid.setId(String.valueOf(empresa.getCodigo()));
			dataGrid.addData(String.valueOf(empresa.getCodigo()));
			dataGrid.addData(Util.initCap(empresa.getFantasia()));
			dataGrid.addData(Util.mountCnpj(empresa.getCnpj()));
			dataGrid.addData(Util.initCap(empresa.getContato()));			
			dataGrid.addData(informacao.getDescricao());
			dataGrid.addImg(Util.getIcon(empresa.getAtivo()));
			dataGrid.addRow();
		}
		out.print(dataGrid.getBody(gridLines));
		transaction.commit();
		out.print(dataGrid.getBody(gridLines));
		out.close();
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			if (addRecord(request))  {
				response.sendRedirect("application/empresa_saude.jsp");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
					"&lk=application/empresa_saude.jsp");
			}
		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
				"&lk=application/empresa_saude.jsp");
		}
	}
	
	private boolean addRecord(HttpServletRequest request) {
		boolean isEdition= request.getParameter("isEdition").trim().equals("t");
		session= HibernateUtil.getSession();		
		transaction= session.beginTransaction();
		try {
			unidade = (Unidade) session.get(Unidade.class, Long.valueOf(Util.getPart(request.getParameter("unidadeId"), 2)));			
			especialidade = (Especialidade) session.get(Especialidade.class, Long.valueOf(request.getParameter("especialidadeIn")));
			ramo = (Ramo) session.get(Ramo.class, Long.valueOf(request.getParameter("ramoIn")));
			query = session.createQuery("from Login as l where l.username = :username");
			query.setString("username", request.getSession().getAttribute("username").toString());
			login = (Login) query.uniqueResult();
			if (isEdition) {
				empresaSaude = (EmpresaSaude) session.get(EmpresaSaude.class, Long.valueOf(request.getParameter("codigoIn")));
			} else {
				empresaSaude = new EmpresaSaude();
			}
			empresaSaude.setAtivo(request.getParameter("ativoChecked"));
			empresaSaude.setCadastrador(login);
			empresaSaude.setCadastro(Util.parseDate(request.getParameter("cadastroIn")));
			empresaSaude.setCargoContato(request.getParameter("cargoContatoIn"));
			empresaSaude.setCnpj(Util.unMountDocument(request.getParameter("cnpjIn")));
			empresaSaude.setConselhoResponsavel(request.getParameter("conselhoIn"));
			empresaSaude.setContato(request.getParameter("nomeContatoIn").toLowerCase());
			empresaSaude.setDeleted("n");
			empresaSaude.setEspecialidade(especialidade);
			empresaSaude.setFantasia(request.getParameter("fantasiaIn").toLowerCase());
			empresaSaude.setRamo(ramo);
			empresaSaude.setRazaoSocial(request.getParameter("razaoSocialIn").toLowerCase());
			empresaSaude.setReferencia("000");
			empresaSaude.setResponsavel(request.getParameter("responsavelIn").toLowerCase());
			empresaSaude.setUnidade(unidade);
			empresaSaude.setVencimento(request.getParameter("vencimento"));
			
			session.saveOrUpdate(empresaSaude);
			
			if (isEdition) {
				endereco = (Endereco) session.get(Endereco.class, Long.valueOf(request.getParameter("codAddress")));
			} else {
				endereco = new Endereco();
			}
			endereco.setPessoa(empresaSaude);
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
				conta.setPessoa(empresaSaude);
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
				informacao.setPessoa(empresaSaude);
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
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return false; 
		}
		return true;
	}
	
	private void mountFilter(HttpServletRequest request) {
		filter= new Filter("from EmpresaSaude as e");
		if (!request.getParameter("codigoIn").equals("")) {
			filter.addFilter("e.referencia = :referencia",
					Long.class, "referencia", Long.valueOf(request.getParameter("codigoIn")));
		}
		if (!request.getParameter("razaoSocialIn").equals("")) {
			filter.addFilter("e.razaoSocial LIKE :rzSocial", String.class, "rzSocial", 
					"%" + Util.encodeString(request.getParameter("razaoSocialIn"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("fantasiaIn").equals("")) {
			filter.addFilter("e.fantasia LIKE :fantasia", String.class, "rzfantasia", 
					"%" + Util.encodeString(request.getParameter("fantasiaIn"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("reponsavelIn").equals("")) {
			filter.addFilter("e.responsavel LIKE :responsavel", String.class, "responsavel", 
					"%" + Util.encodeString(request.getParameter("reponsavelIn"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("conselhoIn").equals("")) {
			filter.addFilter("e.conselhoResponsavel = :conselho", String.class, "conselho", 
					Util.encodeString(request.getParameter("conselhoIn"), "ISO-8859-1", "UTF-8"));
		}
		if (!request.getParameter("nomeContatoIn").equals("")) {
			filter.addFilter("e.contato LIKE :contato", String.class, "contato", 
					"%" + Util.encodeString(request.getParameter("nomeContatoIn"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("setorIn").equals("")) {
			filter.addFilter("e.especialidade.setor = :setor", String.class, "setor", 
					Util.encodeString(request.getParameter("setorIn"), "ISO-8859-1", "UTF-8"));
		}
		if (!request.getParameter("especialidadeIn").equals("")) {
			filter.addFilter("e.especialidade.codigo = :especialidade",
					Long.class, "especialidade", Long.valueOf(request.getParameter("especialidadeIn")));
		}
		if (!request.getParameter("ativoChecked").equals("")) {
			filter.addFilter("e.ativo = :ativo", String.class, "ativo",
					request.getParameter("ativoChecked"));
		}
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("e.unidade.codigo = :unidade", Long.class, "unidade",
					Integer.parseInt(Util.getPart(request.getParameter("unidadeId"), 2)));
		}
		filter.setOrder("e.fantasia");
	}

}
