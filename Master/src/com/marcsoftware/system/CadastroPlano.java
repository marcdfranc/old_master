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

import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Plano;
import com.marcsoftware.database.PlanoServico;
import com.marcsoftware.database.PlanoServicoId;
import com.marcsoftware.database.Servico;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroPlano
 */
public class CadastroPlano extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Session session;
	private Transaction transaction;
	private Query query;
	private Plano plano;
	private List<Plano> planoList;
	private PlanoServico planoServico;
	private PlanoServicoId id;
	private Unidade unidade;
	private Filter filter;
	private boolean isFilter;
	private int limit, offSet, gridLines;
	private PrintWriter out;
	private DataGrid dataGrid;
	private Servico servico;
	private List<String> pipeline;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CadastroPlano() {
        super();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
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
			out.print(Util.encodeString(deletePlano(request), "UTF8", "ISO-8859-1"));
			out.close();
			return;
		} else if (request.getParameter("from").equals("3")) {
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(Util.encodeString(getServico(request), "UTF8", "ISO-8859-1"));
			out.close();
			return;
		} else if (request.getParameter("from").equals("4")) {
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(Util.encodeString(addPlanoConfig(request), "UTF8", "ISO-8859-1"));
			out.close();
			return;
		} else if (request.getParameter("from").equals("5")) {
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(Util.encodeString(editPlanoConfig(request), "UTF8", "ISO-8859-1"));
			out.close();
			return;
		}
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
		planoList = (List<Plano>) query.list();
		if (planoList.size() == 0) {
			out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td></tr>");
			transaction.commit();
			session.close();
			out.close();
			return;
		}
		dataGrid= new DataGrid(null);
		for(Plano plano: planoList) {							
			dataGrid.setId(String.valueOf(plano.getCodigo()));
			dataGrid.addData("codigo" + plano.getCodigo(), 
					String.valueOf(plano.getCodigo()), false);
			dataGrid.addData("descricao" + plano.getCodigo(), plano.getDescricao(), false);
			dataGrid.addData("cadastro" + plano.getCodigo(), Util.parseDate(
					plano.getCadastro(), "dd/MM/yyyy"), false);
			if(plano.getTipo().trim().equals("i")) {
				dataGrid.addData("tipo" + plano.getCodigo(), "Ilimitado", false);
			} else {
				dataGrid.addData("tipo" + plano.getCodigo(), "Limitado", false);
			}
			dataGrid.addData("unidade" + plano.getCodigo(), 
					plano.getUnidade().getReferencia(), false);
			dataGrid.addRow();
		}
		transaction.commit();
		session.close();
		out.print(dataGrid.getBody(gridLines));
		out.close();
	}
	
	private String addRecord(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			unidade = (Unidade) session.get(Unidade.class, 
					Long.valueOf(request.getParameter("unidadeId")));
			if (request.getParameter("codigo").trim().equals("")) {
				plano = new Plano();
			} else {
				plano = (Plano) session.get(Plano.class, 
						Long.valueOf(request.getParameter("codigo")));
			}
			plano.setCadastro(Util.parseDate(request.getParameter("cadastro")));
			plano.setDescricao(request.getParameter("descricao").toLowerCase());
			plano.setTipo(request.getParameter("tipo").toLowerCase());
			plano.setUnidade(unidade);
			session.saveOrUpdate(plano);
			
			session.flush();
			transaction.commit();
			session.close();			
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível salvar o plano devido a um erro interno!";
		}		
		return "Plano salvo com sucesso!";
	}
	
	private String deletePlano(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			plano = (Plano) session.get(Plano.class, 
					Long.valueOf(request.getParameter("codigo")));
			query = session.createQuery("from Usuario as u where u.plano = :plano");
			query.setEntity("plano", plano);
			if (query.list().size() > 0) {
				transaction.rollback();
				session.close();
				return "Para exclusão é necessário que não haja clientes vinculados a ele!";
			} else {
				session.delete(plano);
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível excluir o plano devido a um erro interno!";
		}
		return "Plano excluído com sucesso!";
	}
	
	private void mountFilter(HttpServletRequest request) {
		filter = new Filter("from Plano as p where (1 = 1)");
		
		if (!request.getParameter("codigo").equals("")) {
			filter.addFilter("p.codigo = :codigo", Long.class, "codigo",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("codigo"))));
		}
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("p.unidade.codigo = :unidade", Long.class, "unidade",
					Long.valueOf(request.getParameter("unidadeId")));
		}		
		if (!request.getParameter("descricao").equals("")) {
			filter.addFilter("p.descricao LIKE :descricao", String.class, "descricao", 
					"%" + Util.encodeString(request.getParameter("descricao"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("cadastro").equals("")) {
			filter.addFilter("p.cadastro = :cadastro", java.util.Date.class, 
					"cadastro", Util.parseDate(request.getParameter("cadastro")));
		}		
		if (!request.getParameter("tipo").equals("")) {
			filter.addFilter("p.tipo = :tipo", String.class, "tipo", 
					Util.encodeString(request.getParameter("tipo"), "ISO-8859-1", "UTF-8").toLowerCase());
		}		
		filter.setOrder("p.codigo");
	}
	
	private String getServico(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		String values = "";
		try {
			query = session.createQuery("from Servico as s where s.referencia = :referencia " +
					"and s.especialidade.setor = :setor");
			query.setString("referencia", request.getParameter("referencia"));
			query.setString("setor", request.getParameter("setor"));
			servico = (Servico) query.uniqueResult();
			
			values = servico.getDescricao() + "@" + servico.getEspecialidade().getDescricao();
			transaction.commit();
			session.close();			
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "";
		}
		return values;
	}
	
	private String addPlanoConfig(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			plano = (Plano) session.get(Plano.class, Long.valueOf(request.getParameter("codigo")));
			pipeline = Util.unmountRealPipe(request.getParameter("pipe"));
			for (String pipe : pipeline) {
				query = session.createQuery("from Servico as s where s.referencia = :referencia");
				query.setString("referencia", Util.getPart(pipe, 1));
				servico = (Servico) query.uniqueResult();
				
				id = new PlanoServicoId();
				id.setPlano(plano);
				id.setServico(servico);
				
				planoServico = new PlanoServico();
				planoServico.setId(id);
				planoServico.setQtde(Integer.parseInt(Util.getPart(pipe, 2)));
				
				session.save(planoServico);
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "A Configuração não pode ser salva devido a um erro interno!";
		}
		return "Edição realizada com sucesso!";
	}
	
	private String editPlanoConfig(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			 pipeline = Util.unmountRealPipe(request.getParameter("delPipe"));
			 plano = (Plano) session.get(Plano.class, Long.valueOf(request.getParameter("codigo")));
			 for (String pipe : pipeline) {
				query = session.createQuery("from Servico as s where s.referencia = :referencia");
				query.setString("referencia", pipe);				
				servico = (Servico) query.uniqueResult();
				
				query = session.createQuery("from PlanoServico as p where p.id.plano = :plano " +
						" and p.id.servico = :servico");
				query.setEntity("plano", plano);
				query.setEntity("servico", servico);				
				planoServico = (PlanoServico) query.uniqueResult();
				session.delete(planoServico);
			}
			 
			pipeline = Util.unmountRealPipe(request.getParameter("pipe"));
			
			 for (String pipe : pipeline) {
				query = session.createQuery("from Servico as s where s.referencia = :referencia");
				query.setString("referencia", Util.getPart(pipe, 1));				
				servico = (Servico) query.uniqueResult();
					
				 query = session.createQuery("from PlanoServico as p where p.id.plano = :plano " +
					" and p.id.servico = :servico");
				 query.setEntity("plano", plano);
				 query.setEntity("servico", servico);
				 if (query.list().size() == 1) {
					planoServico = (PlanoServico) query.uniqueResult();
				 } else {
					id = new PlanoServicoId();
					id.setPlano(plano);
					id.setServico(servico);
					
					planoServico = new PlanoServico();
					planoServico.setId(id);
				 }				 
				 planoServico.setQtde(Integer.parseInt(Util.getPart(pipe, 2)));
				 
				 session.saveOrUpdate(planoServico);
			 }
			 session.flush();
			 transaction.commit();
			 session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "A Configuração não pode ser salva devido a um erro interno!";
		}
		return "Configuração salva com sucesso";
	}
}
