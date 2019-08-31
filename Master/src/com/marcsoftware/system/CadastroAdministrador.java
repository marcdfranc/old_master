package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Endereco;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Fisica;
import com.marcsoftware.database.Informacao;
import com.marcsoftware.database.ItensOrcamento;
import com.marcsoftware.database.ItensOrcamentoId;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.Tabela;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroAdministrador
 */
public class CadastroAdministrador extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CadastroAdministrador() {
        super();
        
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		Session session;
		PrintWriter out = null;
		switch (Integer.parseInt(request.getParameter("from"))) {
		case 0:
			session = HibernateUtil.getSession();
			try {
				response.setContentType("text/html");
				out= response.getWriter();
				boolean isFilter= request.getParameter("isFilter") == "1";
				Filter filter = mountFilter(request);
				int limit= Integer.parseInt(request.getParameter("limit"));
				int offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
				Query query = null;
				query = filter.mountQuery(query, session);
				int gridLines= query.list().size();
				query.setFirstResult(offSet);
				query.setMaxResults(limit);
				List<Fisica> fisicaList= (List<Fisica>) query.list();
				if (fisicaList.size() == 0) {
					out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td><td></td></tr>");
					session.close();
					return;
				} else {
					DataGrid dataGrid= new DataGrid("cadastro_administrador.jsp");
					Informacao informacao = null;
					for (Fisica fisica: fisicaList) {
						query = session.getNamedQuery("informacaoPrincipal");
						query.setEntity("pessoa", fisica);
						query.setFirstResult(0);
						query.setMaxResults(1);
						informacao = (Informacao) query.uniqueResult();
						dataGrid.setId(String.valueOf(fisica.getCodigo()));
						dataGrid.addData(String.valueOf(fisica.getCodigo()));
						dataGrid.addData(Util.initCap(fisica.getNome()));
						dataGrid.addData(Util.mountCpf(fisica.getCpf()));
						dataGrid.addData((fisica.getLogin() == null)? "" :
								fisica.getLogin().getUsername());
						dataGrid.addData((informacao== null)? "" : informacao.getDescricao());
						dataGrid.addData(Util.parseDate(fisica.getCadastro(), "dd/MM/yyyy"));
						dataGrid.addRow();
					}
					out.print(dataGrid.getBody(gridLines));
				}				
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				session.close();
			}
			break;
			
		case 1:
			response.setContentType("text/x-json");
			out = response.getWriter();
			out.print(getUnidade(request));
			break;
		}
		out.close();
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.sendRedirect("error_page.jsp?errorMsg=" + addRecord(request) +  "&lk=application/adm.jsp");
	}
	
	private Filter mountFilter(HttpServletRequest request) {
		Filter filter = null;
		filter = new Filter("from Fisica as f where f.isAdm = 't'");
		
		if (!request.getParameter("codigoIn").equals("")) {
			filter.addFilter("f.codigo = :adm", Long.class, "adm",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("codigoIn"))));
		}	
		if (!request.getParameter("nomeIn").equals("")) {
			filter.addFilter("f.nome LIKE :nome", String.class, "nome", 
					"%" + Util.encodeString(request.getParameter("nomeIn"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("cpfIn").equals("")) {
			filter.addFilter("f.cpf = :cpf", String.class, "cpf", 
				 	Util.unMountDocument(request.getParameter("cpfIn")));
		}
		filter.setOrder("f.codigo");
		return filter;
	}
	
	private String addRecord(HttpServletRequest request) {
		String result = "Administrador salvo com sucesso!";
		boolean isEdition = request.getParameter("isEdition").equals("s");
		Session session= HibernateUtil.getSession();
		Transaction transaction= session.beginTransaction();
		try {
			Query query = session.createQuery("from Login as l where l.username = :usuario");
			query.setString("usuario", request.getSession().getAttribute("username").toString());
			Login loginCadastrador = (Login) query.uniqueResult();
			Fisica fisica = null;
			if (isEdition) {
				fisica = (Fisica) session.load(Fisica.class, Long.valueOf(request.getParameter("codAdm")));				
			} else {
				fisica = new Fisica();				
			}			
			fisica.setCadastrador(loginCadastrador);
			
			if (isEdition && request.getParameter("senhaChange").equals("s")) {
				fisica.getLogin().setSenha(request.getParameter("senhaIn"));
				session.update(fisica.getLogin());
			} else if (!isEdition) {
				Login login = new Login();
				login.setUsername(request.getParameter("loginIn"));
				login.setSenha(request.getParameter("senhaIn"));			
				login.setPerfil("f");
				login.setTries(0);
				session.save(login);
				fisica.setLogin(login);
			}
			
			fisica.setAtivo("a");
			fisica.setCpf(Util.unMountDocument(request.getParameter("cpfIn")));
			fisica.setDeleted("n");
			fisica.setEstadoCivil(request.getParameter("estadoCivilIn"));
			fisica.setIsAdm("t");
			
			fisica.setNacionalidade(request.getParameter("nacionalidadeIn").toLowerCase());
			fisica.setNascimento(Util.parseDate(request.getParameter("nascimentoIn")));
			fisica.setNaturalidade(request.getParameter("naturalidadeIn").toLowerCase());
			fisica.setNaturalidadeUf(request.getParameter("naturalUfIn"));
			fisica.setNome(request.getParameter("nomeIn").toLowerCase());
			fisica.setObservacao(request.getParameter("obsIn"));
			fisica.setReferencia("000");
			fisica.setRg(request.getParameter("rgIn"));
			fisica.setSexo(request.getParameter("sexo"));
			fisica.setCadastro(Util.parseDate(request.getParameter("cadastroIn")));
			session.saveOrUpdate(fisica);			
			
			Endereco endereco = null;
			if (isEdition && !request.getParameter("endId").equals("-1")) {
				endereco = (Endereco) session.load(Endereco.class, Long.valueOf(request.getParameter("endId")));
			} else {
				endereco = new Endereco();
			}
			
			endereco.setBairro(request.getParameter("bairroIn").toLowerCase());
			endereco.setCep(Util.unMountDocument(request.getParameter("cepResponsavelIn")));
			endereco.setCidade(request.getParameter("cidadeIn").toLowerCase());
			endereco.setComplemento(request.getParameter("complementoIn"));
			endereco.setRuaAv(request.getParameter("ruaIn"));
			endereco.setUf(request.getParameter("ufResponsavel"));
			endereco.setNumero(request.getParameter("numeroIn"));
			endereco.setPessoa(fisica);
			
			session.saveOrUpdate(endereco);			
			
			int count = 0;
			Informacao informacao = null;
			while (request.getParameter("rowType" + String.valueOf(count)) != null) {
				if (!request.getParameter("ckdelContact" + String.valueOf(count)).equals("-1")) {
					informacao = (Informacao) session.load(Informacao.class, 
							Long.valueOf(request.getParameter("ckdelContact" + String.valueOf(count))));
				} else {
					informacao= new Informacao();
				}
				informacao.setPessoa(fisica);
				informacao.setTipo(request.getParameter("rowType" + String.valueOf(count)));
				informacao.setDescricao(request.getParameter("rowDescript" + String.valueOf(count)));
				informacao.setPrincipal((
						request.getParameter("rowMain" + String.valueOf(count++)).toLowerCase().trim().equals("sim"))?
								"s": "n" );
				session.saveOrUpdate(informacao);
			}
			
			count= 0;
			while (request.getParameter("delContact" + String.valueOf(count)) != null) {
				long key =  Long.valueOf(request.getParameter("delContact" + String.valueOf(count++)));
				informacao = (Informacao) session.load(Informacao.class, key);
				session.delete(informacao);				
			}
			
			
			Unidade unidade = null;
			count = 0;
			while (request.getParameter("rowUndId" + String.valueOf(count)) != null) {		
				unidade = (Unidade) session.load(Unidade.class, Long.valueOf(request.getParameter("rowUndId" + String.valueOf(count++))));
				unidade.setAdministrador(fisica);
				session.update(unidade);
			}
			
			count = 0;
			while (request.getParameter("delUnd" + String.valueOf(count)) != null) {
				long key =  Long.valueOf(request.getParameter("delUnd" + String.valueOf(count++)));
				unidade = (Unidade) session.load(Unidade.class, key);
				unidade.setAdministrador(null);
				session.update(unidade);
				
			}
			
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			result = "Não foi pssível salvar o administrador devido a um erro interno!";
		} finally {
			session.close();
		}
		return result;
	}
	
	private JSONObject getUnidade(HttpServletRequest request) {		
		JSONObject result = new JSONObject();
		Session session = HibernateUtil.getSession();
		try {			
			Unidade unidade = (Unidade) session.load(Unidade.class, Long.valueOf(request.getParameter("id")));
			Query query = session.getNamedQuery("informacaoPrincipal").setEntity("pessoa", unidade);
			Informacao informacao = (Informacao) query.uniqueResult();
			result.put("id", unidade.getCodigo());
			result.put("ref", unidade.getReferencia());
			result.put("rzSocial", Util.initCap(unidade.getRazaoSocial()));
			result.put("cidade", Util.initCap(unidade.getDescricao()));
			result.put("fone", informacao.getDescricao());
			if (unidade.getAdministrador() == null) {
				result.put("administrador", "-1");				
			} else {
				result.put("administrador", Util.initCap(unidade.getAdministrador().getNome()));
			}
		} catch (Exception e) {
			e.printStackTrace();
			result = new JSONObject();
		} finally {
			session.close();
		}
		return result;
	}
}
