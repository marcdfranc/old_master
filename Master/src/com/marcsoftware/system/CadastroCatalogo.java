package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
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

import com.marcsoftware.database.Catalogo;
import com.marcsoftware.database.EnderecoCatalogo;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Grupo;
import com.marcsoftware.database.InformacaoCatalogo;
import com.marcsoftware.database.ItensGrupo;
import com.marcsoftware.database.ItensGrupoId;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.TrabalhoContato;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroCatalogo
 */
public class CadastroCatalogo extends HttpServlet {
	private static final long serialVersionUID = 1L;
    
    public CadastroCatalogo() {
        super();
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PrintWriter out;
		switch (Integer.parseInt(request.getParameter("from"))) {
		case 0:
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			out = response.getWriter();
			boolean isFilter= request.getParameter("isFilter") == "1";
			int limit= Integer.parseInt(request.getParameter("limit"));
			int offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
			Query query = null;
			Session session = HibernateUtil.getSession();
			try {
				Filter filter = mountFilter(request);
				query = filter.mountQuery(query, session);
				int gridLines= query.list().size();
				query.setFirstResult(offSet);
				query.setMaxResults(limit);				
				List<ItensGrupo> itensList = (List<ItensGrupo>) query.list();
				if (itensList.size() == 0) {
					out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td><td></td><td></td></tr>");
					session.close();
					return;
				}
				InformacaoCatalogo informacaoCatalogo = null;
				DataGrid dataGrid = new DataGrid(null);
				for(ItensGrupo iten: itensList) {
					dataGrid.setId(String.valueOf(iten.getId().getCatalogo().getCodigo()));
					dataGrid.addData(Util.initCap(iten.getId().getCatalogo().getNome()));
					query = session.createQuery("from InformacaoCatalogo as i where i.catalogo = :catalogo and i.principal = 's'");
					query.setEntity("catalogo", iten.getId().getCatalogo());
					if (query.list().size() > 0) {
						informacaoCatalogo = (InformacaoCatalogo) query.list().get(0);
						dataGrid.addData(informacaoCatalogo.getTipo());
						dataGrid.addData(informacaoCatalogo.getDescricao());
					} else {
						dataGrid.addData("--------");
						dataGrid.addData("--------");
					}
					dataGrid.addRow();
				}
				out.print(dataGrid.getBody(gridLines));				
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				out.close();
				session.close();
			}
			break;

		case 1:
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(addRecord(request));
			out.close();
			break;
			
		case 2:
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(addGrupo(request));
			out.close();
			break;
			
		case 3:
			response.setContentType("text/x-json");
			out = response.getWriter();
			out.print(getContato(request));
			out.close();
			break;
			
		case 4:
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(deleteContato(request));
			out.close();
			break;
			
		case 5:
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(saveBlocoNotas(request));
			out.close();
			break;
		}
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.sendRedirect(addRecord(request));
	}
	
	private Filter mountFilter(HttpServletRequest request) {		
		Filter filter = new Filter("from ItensGrupo as i where (1 = 1)");
		
		filter.addFilter("i.id.grupo.login.username = :login",
				String.class, "login", request.getSession().getAttribute("username").toString());
		
		if (!request.getParameter("grupo").equals("")) {
			filter.addFilter("i.id.grupo.codigo = :grupo",
					Long.class , "grupo",Long.valueOf(request.getParameter("grupo")));			
		}		
		if (!request.getParameter("nome").equals("")) {
			filter.addFilter("i.id.catalogo.nome like :nome",
					String.class, "nome", "%" + 
					Util.encodeString(request.getParameter("nome"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");			
		}
		if (!request.getParameter("aniverssario").equals("")) {
			filter.addFilter("month(i.id.catalogo.aniverssario) = :aniverssario",
					Long.class, "aniverssario", Long.valueOf(request.getParameter("aniverssario")));
		}
		
		filter.setOrder("i.id.grupo.codigo, i.id.catalogo.nome");
		
		return filter;
	}
	
	private String addRecord(HttpServletRequest request) {
		String result = "?errorMsg=Contato cadastrado com sucesso!&lk=application/catalogo.jsp";
		boolean isEdition = !request.getParameter("catalogoId").equals("-1");
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		try {
			TrabalhoContato trabalho = null;
			EnderecoCatalogo endereco = null;
			Login usuario = null;
			Grupo grupo;
			ItensGrupo itensGrupo;
			ItensGrupoId id;
			Catalogo contato = null;
			InformacaoCatalogo informacao = null;			
			List<InformacaoCatalogo> informacoes = null;
			if (isEdition) {
				contato = (Catalogo) session.load(Catalogo.class, Long.valueOf(request.getParameter("catalogoId")));
				query = session.createQuery("from InformacaoCatalogo as i where i.catalogo = :catalogo");
				query.setEntity("catalogo", contato);
				informacoes = (List<InformacaoCatalogo>) query.list();
			} else {
				contato = new Catalogo();
			}
			if (!request.getParameter("empresaIn").equals("")) {
				if (isEdition && contato.getTrabalho() != null) {
					trabalho = contato.getTrabalho();
				} else {
					trabalho = new TrabalhoContato();
				}
				if (!request.getParameter("enderecoIn").equals("")) {
					if (isEdition && contato.getTrabalho() != null && trabalho.getEndereco() != null) {
						endereco = trabalho.getEndereco();
					} else {
						endereco = new EnderecoCatalogo();
					}
					endereco.setBairro(request.getParameter("bairroEmpIn").toLowerCase());
					endereco.setCep(Util.unMountDocument(request.getParameter("cepEmpIn")));
					endereco.setCidade(request.getParameter("cidadeEmpIn").toLowerCase());
					endereco.setComplemento(request.getParameter("complementoEmpIn"));
					endereco.setEndereco(request.getParameter("enderecoIn").toLowerCase());
					endereco.setUf(request.getParameter("ufEmpIn").toLowerCase());
					
					session.saveOrUpdate(endereco);
					
					trabalho.setEndereco(endereco);
				}
				
				trabalho.setCargo(request.getParameter("cargoIn"));
				trabalho.setEmpresa(request.getParameter("empresaIn"));
				trabalho.setFone(request.getParameter("telefoneEmpIn"));
				trabalho.setSetor(request.getParameter("setorIn"));
				trabalho.setWebsite(request.getParameter("siteIn"));
				
				session.saveOrUpdate(trabalho);
				
				contato.setTrabalho(trabalho);
			}
			if (!request.getParameter("ruaIn").equals("")) {
				if (isEdition && contato.getEndereco() != null) {
					endereco = contato.getEndereco();
				} else {
					endereco = new EnderecoCatalogo();
				}
				endereco.setBairro(request.getParameter("bairroIn").toLowerCase());
				endereco.setCep(Util.unMountDocument(request.getParameter("cepIn")));
				endereco.setCidade(request.getParameter("cidadeIn").toLowerCase());
				endereco.setUf(request.getParameter("ufIn").toLowerCase());
				endereco.setComplemento(request.getParameter("complementoIn"));
				endereco.setEndereco(request.getParameter("ruaIn").toLowerCase());
				
				session.saveOrUpdate(endereco);
				
				contato.setEndereco(endereco);
			}
			
			
			if (!request.getParameter("usuarioIn").equals("")) {
				query = session.createQuery("from Login as l where l.username = :usuario");				
				query.setString("usuario", request.getParameter("usuarioIn"));
				usuario = (Login) query.uniqueResult();
				
				contato.setLogin(usuario);
			}			
			
			if (!request.getParameter("nascimentoIn").equals("")) {
				contato.setAniverssario(Util.parseDate(request.getParameter("nascimentoIn")));
			}
			contato.setApelido(request.getParameter("apelidoIn"));
			contato.setNome(request.getParameter("nomeIn").toLowerCase());
			
			session.saveOrUpdate(contato);
			
			grupo = (Grupo) session.load(Grupo.class, Long.valueOf(request.getParameter("grupoIdIn")));
			
			if (isEdition) {
				query = session.createQuery("from ItensGrupo AS i where i.id.catalogo.codigo = :catalogo");
				query.setLong("catalogo", contato.getCodigo());
				itensGrupo = (ItensGrupo) query.uniqueResult();
				
				if (!itensGrupo.getId().getGrupo().equals(grupo)) {
					session.delete(itensGrupo);
				}
			} else {
				id = new ItensGrupoId();
				itensGrupo = new ItensGrupo();
				
				id.setCatalogo(contato);
				id.setGrupo(grupo);
				
				itensGrupo.setId(id);
				
				session.save(itensGrupo);
			}
			
			if (isEdition) {
				for (InformacaoCatalogo info : informacoes) {
					session.delete(info);
				}
			}
			
			int index = 0;
			while (request.getParameter("rowTipo" + index) != null) {
				informacao = new InformacaoCatalogo();
				informacao.setCatalogo(contato);
				informacao.setTipo(request.getParameter("rowTipo" + index));					
				informacao.setDescricao(request.getParameter("rowDescricao" + index));
				informacao.setPrincipal(request.getParameter("rowPrincipal" + (index++)));				
				session.save(informacao);
			}
						
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			result = "?errorMsg=Não foi possível cadastrar o contato devido a um erro interno!&lk=application/catalogo.jsp";
		} finally {
			session.close();
		}
		return "error_page.jsp" + result;	
	}
	
	private String addGrupo(HttpServletRequest request) {
		String result = "../error_page.jsp?errorMsg=Grupo salvo com sucesso!&lk=application/catalogo.jsp";
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Grupo grupo = null;
		try {
			boolean isEdition = !request.getParameter("grupoId").equals("e");
			Login login = (Login) session.load(Login.class, request.getSession().getAttribute("username").toString());
			if (isEdition) {
				grupo = (Grupo) session.load(Grupo.class, Long.valueOf(request.getParameter("grupoId")));
			} else {
				grupo = new Grupo();
			}
			grupo.setDescricao(request.getParameter("descricao"));
			grupo.setLogin(login);
			session.saveOrUpdate(grupo);
			
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			result = "../error_page.jsp?errorMsg=Não foi possível salvar o grupo devido a um erro interno!&lk=application/catalogo.jsp";
			transaction.rollback();
		} finally {
			session.close();
		}
		return result;
	}
	
	private JSONObject getContato(HttpServletRequest request) {
		JSONObject xml = new JSONObject();
		JSONObject infoObj = null;
		JSONArray info = new JSONArray();
		Session session = HibernateUtil.getSession();
		List<InformacaoCatalogo> infoList = null;
		try {
			Catalogo contato = (Catalogo) session.load(Catalogo.class, Long.valueOf(request.getParameter("contatoId")));
			Query query = session.createQuery("from InformacaoCatalogo as i where i.catalogo = :catalogo");
			query.setEntity("catalogo", contato);
			infoList = (List<InformacaoCatalogo>) query.list();
			xml.put("id", contato.getCodigo());
			xml.put("nome", contato.getNome());
			xml.put("apelido", (contato.getApelido() == null)? "" : contato.getApelido());
			xml.put("usuario", (contato.getLogin() == null)? "" : contato.getLogin().getUsername());
			xml.put("aniverssario", (contato.getAniverssario() == null)? "" : 
				Util.parseDate(contato.getAniverssario(), "dd/MM"));
			xml.put("cep", (contato.getEndereco() == null || contato.getEndereco().getCep() == null)? "" : 
				Util.mountCep(contato.getEndereco().getCep()));
			xml.put("endereco", (contato.getEndereco() == null || contato.getEndereco().getEndereco() == null)? 
					"" : contato.getEndereco().getEndereco());
			xml.put("complemento", (contato.getEndereco() == null 
					|| contato.getEndereco().getComplemento() == null)? "" : 
						contato.getEndereco().getComplemento());
			xml.put("bairro", (contato.getEndereco() == null || contato.getEndereco().getBairro() == null)? "" : 
				contato.getEndereco().getBairro());			
			xml.put("cidade", (contato.getEndereco() == null || contato.getEndereco().getCidade() == null)? "" : 
				contato.getEndereco().getCidade() + " - " + contato.getEndereco().getUf().toUpperCase());
			xml.put("empresa", (contato.getTrabalho() == null)? "" : contato.getTrabalho().getEmpresa());
			xml.put("cargo", (contato.getTrabalho() == null || contato.getTrabalho().getCargo() == null)? "" : 
				contato.getTrabalho().getCargo());
			xml.put("setor", (contato.getTrabalho() == null || contato.getTrabalho().getSetor() == null)? "" : 
				contato.getTrabalho().getSetor());
			xml.put("cep_empresa", (contato.getTrabalho() == null 
					|| contato.getTrabalho().getEndereco() == null 
					|| contato.getTrabalho().getEndereco().getCep() == null)? "" : 
						Util.mountCep(contato.getTrabalho().getEndereco().getCep()));
			xml.put("endereco_empresa", (contato.getTrabalho() == null 
					|| contato.getTrabalho().getEndereco() == null 
					|| contato.getTrabalho().getEndereco().getEndereco() == null)? "" :
						contato.getTrabalho().getEndereco().getEndereco());
			xml.put("complemento_empresa", (contato.getTrabalho() == null 
					|| contato.getTrabalho().getEndereco() == null 
					|| contato.getTrabalho().getEndereco().getComplemento() == null)? "" :
						contato.getTrabalho().getEndereco().getComplemento());
			xml.put("bairro_empresa", (contato.getTrabalho() == null 
					|| contato.getTrabalho().getEndereco() == null 
					|| contato.getTrabalho().getEndereco().getBairro() == null)? "" :
						contato.getTrabalho().getEndereco().getBairro());
			xml.put("cidade_empresa", (contato.getTrabalho() == null 
					|| contato.getTrabalho().getEndereco() == null 
					|| contato.getTrabalho().getEndereco().getCidade() == null)? "" :
						contato.getTrabalho().getEndereco().getCidade() + " - " + 
						contato.getTrabalho().getEndereco().getUf());
			xml.put("site", (contato.getTrabalho() == null || contato.getTrabalho().getWebsite() == null)? "" :
				contato.getTrabalho().getWebsite());
			xml.put("fone", (contato.getTrabalho() == null || contato.getTrabalho().getFone() == null)? "" :
				contato.getTrabalho().getFone());
			
			for (InformacaoCatalogo infoCatalogo : infoList) {
				infoObj = new JSONObject();
				infoObj.put("tipo", infoCatalogo.getTipo());
				infoObj.put("descricao", infoCatalogo.getDescricao());
				
				info.add(infoObj);				
			}
			xml.put("informacoes", info);
			
		} catch (Exception e) {
			e.printStackTrace();
			xml = null;
		} finally {
			session.close();
		}
		
		return xml;
	}
	
	private String deleteContato(HttpServletRequest request) {
		String result = "?errorMsg=Contato excluído com sucesso!&lk=application/catalogo.jsp";
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		try {
			Catalogo contato = (Catalogo) session.load(Catalogo.class, Long.valueOf(request.getParameter("contatoId")));
			Query query = session.createQuery("from InformacaoCatalogo as i where i.catalogo = :catalogo");
			query.setEntity("catalogo", contato);
			List<InformacaoCatalogo> infoList = (List<InformacaoCatalogo>) query.list();
			for (InformacaoCatalogo info : infoList) {
				session.delete(info);
			}
			session.delete(contato.getEndereco());
			session.delete(contato.getTrabalho().getEndereco());
			session.delete(contato.getTrabalho());
			session.delete(contato);
			
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			result = "?errorMsg=Não foi possível excluir o contato devido a um erro interno!&lk=application/catalogo.jsp";
			transaction.rollback();
		} finally {
			session.close();
		}
		return "../error_page.jsp" + result;
	}
	
	private String saveBlocoNotas(HttpServletRequest request) {
		String result = "Anotações salvas com sucesso!";
		Login login = null;
		Query query = null;
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		try {
			query = session.createQuery("from Login as l where l.username = :usuario");
			query.setString("usuario", request.getSession().getAttribute("username").toString());
			login = (Login) query.uniqueResult();
			if (login == null) {
				result = "As anotações não puderam ser salvas por um erro interno!";
				transaction.rollback();
			} else {				
				login.setBlocoNotas(Util.encodeString(request.getParameter("blcNota"), 
						"ISO-8859-1","UTF8"));
				session.update(login);
				transaction.commit();
			}
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			result = "As anotações não puderam ser salvas por um erro interno!";
		} finally {
			session.close();
		}
		return result;
	}
}
