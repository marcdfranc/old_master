package com.marcsoftware.gateway;

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

import com.marcsoftware.database.Dependente;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Informacao;
import com.marcsoftware.database.Orcamento;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.database.views.ViewClienteCompleto;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CobrancaAdapter
 */
public class CobrancaAdapter extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Filter filter;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CobrancaAdapter() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PrintWriter out= response.getWriter();
		switch (Integer.parseInt(request.getParameter("from"))) {
		case 0:
			request.setCharacterEncoding("ISO-8859-1");				
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			Session session= HibernateUtil.getSession();
			boolean isFilter= request.getParameter("isFilter") == "1";
			int limit= Integer.parseInt(request.getParameter("limit"));
			int offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
			Query query = null; 
			query = mountFilter(request, query, session);
			int gridLines= query.list().size();
			query.setFirstResult(offSet);
			query.setMaxResults(limit);
			List<ViewClienteCompleto> inadimplentes = (List<ViewClienteCompleto>) query.list();
			if (inadimplentes.size() == 0) {
				out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td><td></td><td></td></tr>");
				session.close();
				out.close();
				return;
			}
			Informacao informacao;
			DataGrid dataGrid = new DataGrid(null);
			for(ViewClienteCompleto db: inadimplentes) {
				query = session.getNamedQuery("informacaoPrincipal");
				query.setEntity("pessoa", db.getUsuario());
				query.setFirstResult(0);
				query.setMaxResults(1);
				informacao= (Informacao) query.uniqueResult();
				dataGrid.setId(String.valueOf(db.getUsuario().getCodigo()));
				dataGrid.addData(Util.zeroToLeft(db.getUsuario().getContrato().getCtr(), 4));
				//dataGrid.addData(String.valueOf(db.getAtrasoTratamento()));
				dataGrid.addData(Util.encodeString(Util.initCap(db.getUsuario().getNome()), 
						"UTF8", "ISO-8859-1"));
				//dataGrid.addData(Util.initCap(db.getUsuario().getNome()));
				dataGrid.addData(Util.mountCpf(db.getUsuario().getCpf()));
				dataGrid.addData(Util.parseDate(db.getUsuario().getNascimento(), "dd/MM/yyyy"));							
				dataGrid.addData((informacao== null)? "" : informacao.getDescricao());
				
				query = session.getNamedQuery("parcelaByUsuario");
				query.setLong("usuario", db.getUsuario().getCodigo());
				dataGrid.addImg((query.list().size() == 0)? "../image/ok_icon.png" :
					Util.getIcon(query.list(), "orcamento"));							
				
				query = session.getNamedQuery("mensalidadeByUsuario");
				query.setLong("usuario", db.getUsuario().getCodigo());
				dataGrid.addImg(Util.getIcon(query.list(), "mensalidade"));
				
				dataGrid.addRow();
			}
			out.print(dataGrid.getBody(gridLines));
			session.close();
			break;

		case 1:
			response.setContentType("text/xml");
			response.setHeader("Cache-Control", "no-cache");
			response.setCharacterEncoding("ISO-8859-1");
			out.write(getPainel(request));
			break;
			
		case 2:
			response.setContentType("text/plain");
			response.setHeader("Cache-Control", "no-cache");
			out.print(consultaCredito(request));
			break;			
		}
		out.close();
	}
	
	private Query mountFilter(HttpServletRequest request, Query query, Session session) {
		int inicio = 0;
		boolean setParam = false;
		if (request.getParameter("unidadeId") == "") {
			filter = new Filter("from ViewClienteCompleto as v " + 
				" where (1 <> 1)");
		} else if (request.getParameter("dias").equals("180")) {
			filter = new Filter("from ViewClienteCompleto as v " + 
						" where (v.atrasoMensalidade > 0 or v.atrasoTratamento > 0) and (v.diasMensalidade > 150 " +
						" or  v.diasTratamento > 150) ");
		} else {
			inicio = Integer.parseInt(request.getParameter("dias")) - 30;
			if (inicio == 0) {
				inicio = 1;
			}
			filter = new Filter("from ViewClienteCompleto as v " +
					" where (1 = 1) ");
					//" where (v.atrasoMensalidade > 0 or v.atrasoTratamento > 0) ");
			
			filter.addFilter("((v.diasMensalidade between :inicioMensal",
					Long.class, "inicioMensal", Long.valueOf(inicio));
			
			filter.addFilter(" :fimMensal) or (v.diasTratamento between :inicioTratamento",
					Long.class, "fimMensal", Long.valueOf(request.getParameter("dias")));
			
			filter.addFilter(" :fimTratamento))",
					Long.class, "fimTratamento", Long.valueOf(request.getParameter("dias")));
			setParam = true;
		}
		
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("v.usuario.unidade.codigo = :unidadeId",
					Long.class, "unidadeId", Long.valueOf(
							request.getParameter("unidadeId")));
		}		
		if (!request.getParameter("referenciaIn").equals("")) {
			filter.addFilter("v.usuario.contrato.codigo = :ctr",
					Long.class, "ctr", Long.valueOf(
							request.getParameter("referenciaIn")));
		}
		if (!request.getParameter("nomeIn").equals("")) {
			filter.addFilter("v.usuario.nome like :nome",
					String.class, "nome", "%" + request.getParameter("nomeIn") + "%");
		}
		if (!request.getParameter("cpfIn").equals("")) {
			filter.addFilter("v.usuario.cpf = :cpf", String.class, "cpf", 
				 	Util.unMountDocument(request.getParameter("cpfIn")));
		}
		if (!request.getParameter("nascimentoIn").equals("")) {
			filter.addFilter("v.usuario.nascimento = :nascimento", java.util.Date.class, 
					"nascimento", Util.parseDate(request.getParameter("nascimentoIn")));
		}
		if (!request.getParameter("plano").equals("")) {
			filter.addFilter("v.usuario.plano.codigo = :plano", Long.class, "plano", 
					Integer.parseInt(request.getParameter("plano")));
		}
		if (!request.getParameter("ativoChecked").equals("")) {
			filter.addFilter("v.usuario.ativo = :ativo", String.class, "ativo",
					request.getParameter("ativoChecked"));
		}
		if (!request.getParameter("telIn").equals("")) {
			filter.addFilter("v.usuario.codigo in (select i.pessoa.codigo from " +
					"Informacao as i where i.descricao = :fone", String.class, "fone",
					request.getParameter("telIn"));
		}
		filter.setOrder("v.usuario.nome ");
		query = filter.mountQuery(query, session) ;
		
		if (setParam) {
			query.setLong("inicioTratamento", Long.valueOf(inicio));
		}
		return query;
	}
	
	private String getPainel(HttpServletRequest request) {
		String xml = "<?xml version=\"1.0\" encoding=\"iso-8859-1\" ?><cobrancas>";
		Long unidadeId = Long.valueOf(request.getParameter("unidadeId"));
		int cadastrados = 0;
		int ativos = 0;
		int bloqueados = 0;
		int cancelados = 0;
		int adimplentes = 0;
		int c1 = 0;
		int c2 = 0;
		int c3 = 0;
		int c4 = 0;
		int c5 = 0;
		int cMais = 0;
		Session session = HibernateUtil.getSession();
		try {
			Query query = session.createSQLQuery("SELECT COUNT(*) FROM usuario AS u" +
					" INNER JOIN pessoa AS p USING(codigo) " +
					" WHERE p.cod_unidade = :unidadeId");
			query.setLong("unidadeId", unidadeId);
			cadastrados = Integer.parseInt(query.uniqueResult().toString());
			xml+= "<cadastrados>" + cadastrados + "</cadastrados>";			
			
			query = session.createSQLQuery("SELECT COUNT(*) FROM usuario AS u " + 
					" INNER JOIN pessoa AS p USING(codigo) " +
					" WHERE p.ativo = 'a' AND p.cod_unidade = :unidadeId");
			query.setLong("unidadeId", unidadeId);
			ativos = Integer.parseInt(query.uniqueResult().toString());
			xml+= "<ativos>" + ativos + "</ativos>";
			
			query = session.createSQLQuery("SELECT COUNT(*) FROM usuario AS u " + 
					" INNER JOIN pessoa AS p USING(codigo) " +
					" WHERE p.ativo = 'b' AND p.cod_unidade = :unidadeId");
			query.setLong("unidadeId", unidadeId);
			bloqueados = Integer.parseInt(query.uniqueResult().toString());
			xml+= "<bloqueados>" + bloqueados + "</bloqueados>";
			
			cancelados = cadastrados - (ativos + bloqueados);
			xml+= "<cancelados>" + cancelados + "</cancelados>";
			
			query = session.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " + 
					" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
					" WHERE p.ativo = 'a' AND (d.atraso BETWEEN 0 AND 30)" +
					" AND p.cod_unidade = :unidadeId");
			query.setLong("unidadeId", unidadeId);
			c1 = Integer.parseInt(query.uniqueResult().toString());
			xml+= "<carteira1>" + c1 + "</carteira1>";
			
			query = session.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " + 
					" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
					" WHERE p.ativo = 'a' AND (d.atraso BETWEEN 30 AND 60) " +
					" AND p.cod_unidade = :unidadeId");
			query.setLong("unidadeId", unidadeId);
			c2 = Integer.parseInt(query.uniqueResult().toString());
			xml+= "<carteira2>" + c2 + "</carteira2>";
			
			query = session.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " + 
					" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
					" WHERE p.ativo = 'a' AND (d.atraso BETWEEN 60 AND 90) " +
					" AND p.cod_unidade = :unidadeId");
			query.setLong("unidadeId", unidadeId);
			c3 = Integer.parseInt(query.uniqueResult().toString());
			xml+= "<carteira3>" + c3 + "</carteira3>";
			
			query = session.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " + 
					" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
					" WHERE p.ativo = 'a' AND (d.atraso BETWEEN 90 AND 120) " +
					" AND p.cod_unidade = :unidadeId");
			query.setLong("unidadeId", unidadeId);
			c4 = Integer.parseInt(query.uniqueResult().toString());
			xml+= "<carteira4>" + c4 + "</carteira4>";
			
			query = session.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " + 
					" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
					" WHERE p.ativo = 'a' AND (d.atraso BETWEEN 120 AND 150)" +
					" AND p.cod_unidade = :unidadeId");
			query.setLong("unidadeId", unidadeId);
			c5 = Integer.parseInt(query.uniqueResult().toString());
			xml+= "<carteira5>" + c5 + "</carteira5>";
			
			query = session.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " +
					" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
					" WHERE p.ativo = 'a' AND (d.atraso > 150) " +
					" AND p.cod_unidade = :unidadeId");
			query.setLong("unidadeId", unidadeId);
			cMais = Integer.parseInt(query.uniqueResult().toString());
			xml+= "<carteira6>" + cMais + "</carteira6>";
			
			adimplentes = ativos - (c1 + c2 + c3 + c4 + c5 + cMais);
			
			xml+= "<carteira0>" + cMais + "</carteira0></cobrancas>";
		} catch (Exception e) {
			e.printStackTrace();
			xml = "<?xml version=\"1.0\" encoding=\"iso-8859-1\" ?><cobrancas></cobrancas>";
		} finally {
			session.close();
		}
		return xml;
	}
	
	private String consultaCredito(HttpServletRequest request) {
		String result = "0";
		Usuario usuario = null;
		Dependente dependente = null;
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		try {
			if (request.getParameter("isDependente").equals("t")) {
				dependente = (Dependente) session.load(Dependente.class, Long.valueOf(request.getParameter("id")));
				dependente.setProtestos(Integer.parseInt(request.getParameter("protestos")));
				dependente.setSpc(Integer.parseInt(request.getParameter("spc")));
				dependente.setDevolucaoCheques(Integer.parseInt(request.getParameter("devolucao")));
				dependente.setConsultaCredito(Util.parseDate(request.getParameter("dataConsulta")));
				
				session.update(dependente);
			} else {
				usuario = (Usuario) session.load(Usuario.class, Long.valueOf(request.getParameter("id")));
				usuario.setProtestos(Integer.parseInt(request.getParameter("protestos")));
				usuario.setSpc(Integer.parseInt(request.getParameter("spc")));
				usuario.setDevolucaoCheques(Integer.parseInt(request.getParameter("devolucao")));
				usuario.setConsultaCredito(Util.parseDate(request.getParameter("dataConsulta")));
				
				session.update(usuario);				
			}
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			result = "-1";
		} finally {
			session.close();
		}
		return result;
	}

}
