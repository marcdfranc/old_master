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
import com.marcsoftware.database.Informacao;
import com.marcsoftware.database.InformacaoCatalogo;
import com.marcsoftware.database.ItensGrupo;
import com.marcsoftware.database.ItensGrupoId;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.TrabalhoContato;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroGrupo
 */
public class CadastroGrupo extends HttpServlet {
	private static final long serialVersionUID = 1L;       
    
    public CadastroGrupo() {
        super();
    }
    
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PrintWriter out = response.getWriter();
		switch (Integer.parseInt(request.getParameter("from"))) {
		case 0:
			response.setContentType("text/plain");
			out.print(addRecord(request));			
			break;
			
		case 1:
			response.setContentType("text/plain");
			out.print(addContato(request));
			break;
			
		case 2:
			response.setContentType("text/x-json");
			out.print(processaInfoVazia(request));
			break;
			
		case 3:
			response.setContentType("text/x-json");
			processaInfo(request);
			out.print(getGrid(request));
			break;
			
		case 4:
			response.setContentType("text/x-json");
			removeInfo(request);
			out.print(getGrid(request));
			break;

		default:
			response.setContentType("text/x-json");
			out.print(getGrid(request));
			break;
		}
		out.close();
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/x-json");
		PrintWriter out = response.getWriter();
		out.print(getGrid(request));
	}
	
	private String addRecord(HttpServletRequest request) {
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
	
	private JSONObject getGrid(HttpServletRequest request) {
		JSONObject grid = new JSONObject();
		JSONArray linhas = new JSONArray();
		JSONArray cells = null;
		JSONObject informacao = null;
		int gridLines = 0;
		List<InformacaoCatalogo> infoList = null;
		Filter filter = mountFilter(request);
		Session session = HibernateUtil.getSession();
		Query query = null;
		try {
			filter.setOrder(request.getParameter("sortname") + " " + request.getParameter("sortorder"));
			query = filter.mountQuery(query, session);
			
			gridLines= query.list().size();
			infoList = (List<InformacaoCatalogo>) query.list();
			
			grid.put("page", 0);
			grid.put("total", gridLines);		
			
			for (InformacaoCatalogo info : infoList) {
				informacao = new JSONObject();
				cells = new JSONArray();
				cells.add(info.getTipo());
				cells.add(info.getDescricao());		
				cells.add((info.getPrincipal().equals("s"))? "Sim" : "Não");
				
				informacao.put("id", info.getCodigo());
				informacao.put("cell", cells);
				
				linhas.add(informacao);
			}
			grid.put("rows", linhas);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			session.close();
		}
		
		return grid;
	}
	
/*	private JSONObject getGrid(HttpServletRequest request) {
		JSONObject result = new JSONObject();
		JSONArray linhas = new JSONArray();
		JSONArray auxArray = null;
		JSONObject aux = null;
		int gridLines = 0;
		List<Informacao> infoList = null;
		
		int paginaCorrente = Integer.parseInt(request.getParameter("page"));
		int limit = Integer.parseInt(request.getParameter("rp"));
		int offSet = (paginaCorrente - 1) * limit;
		String queryRequest = request.getParameter("query");
		String duvida = request.getParameter("qtype");
		String tt = request.getParameter("teste");
		String ordenacao = request.getParameter("sortname") + " " + request.getParameter("sortorder");
		String  sql = "from InformacaoCatalogo AS i";	
				
		sql+= "order by " + ordenacao;
		
		Session session = HibernateUtil.getSession();
		Query query= null;
		try {
			query = session.createQuery(sql);
			gridLines = query.list().size();
			query.setFirstResult(offSet);
			query.setMaxResults(limit);
			infoList = (List<Informacao>) query.list();
			
			result.put("page", paginaCorrente);
			result.put("total", gridLines);		
			
			for (Informacao info : infoList) {
				aux = new JSONObject();
				auxArray = new JSONArray();			
				auxArray.add(info.getTipo());
				auxArray.add(info.getDescricao());		
				auxArray.add((info.getPrincipal().equals("s"))? "Sim" : "Não");
				
				aux.put("id", info.getCodigo());
				aux.put("cell", auxArray);
				
				linhas.add(aux);
			}
			result.put("rows", linhas);
		} catch (Exception e) {
			e.printStackTrace();
			result = new JSONObject();			
		} finally {
			session.close();
		}
		return result;
	} */
	
	
	
	private String addContato(HttpServletRequest request) {	
		String result = "?errorMsg=Contato cadastrado com sucesso!&lk=application/catalogo.jsp";
		String realPipe = "";
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
			ArrayList<String> informacoes;
			if (isEdition) {
				contato = (Catalogo) session.load(Catalogo.class, Long.valueOf(request.getParameter("catalogoId")));
			} else {
				contato = new Catalogo();
			}
			if (!request.getParameter("empresa").equals("")) {
				if (isEdition && contato.getTrabalho() != null) {
					trabalho = contato.getTrabalho();
				} else {
					trabalho = new TrabalhoContato();
				}
				if (!request.getParameter("enderecoEmp").equals("")) {
					if (isEdition && contato.getTrabalho() != null && trabalho.getEndereco() != null) {
						endereco = trabalho.getEndereco();
					} else {
						endereco = new EnderecoCatalogo();
					}
					endereco.setBairro(request.getParameter("bairroEmp").toLowerCase());
					endereco.setCep(Util.unMountDocument(request.getParameter("cepEmp")));
					endereco.setCidade(request.getParameter("cidadeEmp").toLowerCase());
					endereco.setComplemento(request.getParameter("complementoEmp"));
					endereco.setEndereco(request.getParameter("enderecoEmp").toLowerCase());
					endereco.setUf(request.getParameter("ufEmp"));
					
					session.saveOrUpdate(endereco);
					
					trabalho.setEndereco(endereco);
				}
				
				trabalho.setCargo(request.getParameter("cargo"));
				trabalho.setEmpresa(request.getParameter("empresa"));
				trabalho.setFone(request.getParameter("foneEmp"));
				trabalho.setSetor(request.getParameter("setor"));
				trabalho.setWebsite(request.getParameter("site"));
				
				session.saveOrUpdate(trabalho);
				
				contato.setTrabalho(trabalho);
			}
			if (!request.getParameter("endereco").equals("")) {
				if (isEdition && contato.getEndereco() != null) {
					endereco = contato.getEndereco();
				} else {
					endereco = new EnderecoCatalogo();
				}
				endereco.setBairro(request.getParameter("bairro").toLowerCase());
				endereco.setCep(Util.unMountDocument(request.getParameter("cep")));
				endereco.setCidade(request.getParameter("cidade").toLowerCase());
				endereco.setUf(request.getParameter("uf"));
				endereco.setComplemento(request.getParameter("complemento"));
				endereco.setEndereco(request.getParameter("endereco").toLowerCase());
				
				session.saveOrUpdate(endereco);
				
				contato.setEndereco(endereco);
			}
			if (!request.getParameter("usuario").equals("")) {
				query = session.createQuery("from Login as l where l.usuario = :usuario");
				query.setString("usuario", request.getParameter("usuario"));
				usuario = (Login) query.uniqueResult();
				
				contato.setLogin(usuario);
			}
			if (!request.getParameter("aniverssario").equals("")) {
				contato.setAniverssario(Util.parseDate(request.getParameter("aniverssario")));
			}
			contato.setApelido(request.getParameter("apelido"));
			//contato.setPrimeiroNome(request.getParameter("primeiroNome").toLowerCase());
			//contato.setUltimoNome(request.getParameter("ultimoNome"));
			
			session.saveOrUpdate(contato);
			
			grupo = (Grupo) session.load(Grupo.class, Long.valueOf(request.getParameter("grupoContato")));
			
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
			
			
			if (!isEdition) {
				informacoes = Util.unmountRealPipe(request.getParameter("infoPipe"));
				for (String info : informacoes) {
					realPipe = info.replace(',', '|');
					informacao = new InformacaoCatalogo();
					informacao.setCatalogo(contato);
					informacao.setTipo(Util.getRealPipeById(realPipe, 1));					
					informacao.setDescricao(Util.getRealPipeById(realPipe, 2));
					informacao.setPrincipal((Util.getRealPipeById(realPipe, 3) == "Sim")? "s" : "n");
					
					session.save(informacao);
				}
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
		return "../error_page.jsp" + result;
	}
	
	private JSONObject processaInfoVazia(HttpServletRequest request) {
		JSONObject grid = new JSONObject();
		JSONArray linhas = new JSONArray();
		JSONObject informacao = new JSONObject();
		JSONArray fields = new JSONArray();
		ArrayList<String> informacoes = Util.unmountRealPipe(request.getParameter("infoPipe"));
		int id = 0;
		grid.put("page", 0);
		grid.put("total", Integer.parseInt(request.getParameter("total")));
		String realPipe = "";
		
		if (request.getParameter("idToRemove").equals("n")
				&& request.getParameter("idToEdit").equals("n")) {
			fields.add(Util.initCap(request.getParameter("tipo")));
			fields.add(request.getParameter("descricao"));
			fields.add(Util.encodeString(request.getParameter("principal"), "ISO-8859-1", "UTF8"));
			
			informacao.put("id", --id);
			informacao.put("cell", fields);
			
			linhas.add(informacao);
		}
		
		for (String info : informacoes) {
			realPipe = info.replace(',', '|');
			fields = new JSONArray();
			informacao = new JSONObject();
			if (request.getParameter("idToEdit").equals(Util.getRealPipeById(realPipe, 0))) {
				fields.add(Util.initCap(request.getParameter("tipo")));
				fields.add(request.getParameter("descricao"));
				fields.add(Util.encodeString(request.getParameter("principal"), "ISO-8859-1", "UTF8"));
				
				informacao.put("id", --id);
				informacao.put("cell", fields);
				
				linhas.add(informacao);
				
			} else if (!request.getParameter("idToRemove").equals(Util.getRealPipeById(realPipe, 0))) {
				fields.add(Util.initCap(Util.getRealPipeById(realPipe, 1)));
				fields.add(Util.getRealPipeById(realPipe, 2));
				fields.add(Util.encodeString(Util.getRealPipeById(realPipe, 3), "ISO-8859-1", "UTF8"));
				
				informacao.put("id", --id);
				informacao.put("cell", fields);
				
				linhas.add(informacao);				
			}
		}
		
		grid.put("rows", linhas);	
		
		return grid;
	}
	
	private void processaInfo(HttpServletRequest request) {
		boolean isEdition = !request.getParameter("idToEdit").equals("n");
		InformacaoCatalogo informacao = null;
		Catalogo catalogo;		
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		try {
			if (isEdition) {
				informacao = (InformacaoCatalogo) session.load(InformacaoCatalogo.class, 
						Long.valueOf(request.getParameter("idToEdit")));
			} else {
				catalogo = (Catalogo) session.load(Catalogo.class, Long.valueOf(request.getParameter("catalogoId")));
				informacao = new InformacaoCatalogo();
				informacao.setCatalogo(catalogo);
			}
			informacao.setDescricao(request.getParameter("descricao"));
			informacao.setPrincipal((request.getParameter("principal").equals("Sim"))? "s" : "n");
			informacao.setTipo(request.getParameter("tipo"));
			
			session.saveOrUpdate(informacao);
			
			session.flush();
			transaction.rollback();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
		} finally {
			session.close();
		}
	}
	
	private void removeInfo(HttpServletRequest request) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		try {
			InformacaoCatalogo informacao = (InformacaoCatalogo) session.load(InformacaoCatalogo.class, 
					Long.valueOf(request.getParameter("idToRemove")));
			session.delete(informacao);
			
			session.flush();
			transaction.rollback();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
		}  finally {
			session.close();
		}
	}
	
	private Filter mountFilter(HttpServletRequest request) {
		Filter filter = null;
		if (Integer.parseInt(request.getParameter("catalogoId")) > 0) {
			filter = new Filter("from InformacaoCatalogo as i where (1 = 1)");
			filter.addFilter("i.catalogo.codigo = :catalogo", Long.class, "catalogo",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("catalogoId"))));			
		} else {
			filter = new Filter("from InformacaoCatalogo as i where (1 <> 1)");
		}		
		return filter;
	}
}
