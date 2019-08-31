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
import com.marcsoftware.database.Endereco;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Informacao;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.PrestadorServico;
import com.marcsoftware.database.Ramo;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

public class CadastroPrestadorServico extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Session session;
	private Transaction transaction;
	private Query query;
    private Unidade unidade;
    private PrestadorServico prestador;
    private List<PrestadorServico> prestadorList;
    private Ramo ramo;
    private Endereco endereco;
    private Conta conta;
    private Banco banco;
    private Informacao informacao;
    private Login login;
    private Filter filter;
    private PrintWriter out;
    private boolean isFilter;
    private int limit, offSet, gridLines;
    private DataGrid dataGrid;
    
    public CadastroPrestadorServico() {
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
		prestadorList = (List<PrestadorServico>) query.list();
		if (prestadorList.size() == 0) {
			out.print("0");
			transaction.commit();
			session.close();
			out.close();
			return;
		}
		dataGrid= new DataGrid("cadastro_prestador_servico.jsp");
		for (PrestadorServico prest: prestadorList) {
			query = session.getNamedQuery("informacaoPrincipal");
			query.setEntity("pessoa", prest);
			query.setFirstResult(0);
			query.setMaxResults(1);
			informacao = (Informacao) query.uniqueResult();
			dataGrid.setId(String.valueOf(prest.getCodigo()));
			dataGrid.addData(String.valueOf(prest.getCodigo()));
			dataGrid.addData(Util.initCap(prest.getNome()));
			
			dataGrid.addData(Util.mountCpf(prest.getCpf()));
			dataGrid.addData(Util.initCap(prest.getRamo().getDescricao()));
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
				response.sendRedirect("application/prestador_servico.jsp");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + "&lk=" +
					"application/prestador_servico.jsp");
			}			
		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + "&lk=" +
				"application/prestador_servico.jsp");
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
				prestador = (PrestadorServico) session.get(PrestadorServico.class, Long.valueOf(request.getParameter("codigoIn")));
			} else {
				prestador = new PrestadorServico();			
			}
			prestador.setAtivo(request.getParameter("ativoChecked"));
			prestador.setCadastrador(login);
			prestador.setCadastro(Util.parseDate(request.getParameter("cadastroIn")));
			prestador.setCpf(Util.unMountDocument(request.getParameter("cpfIn")));
			prestador.setDeleted("n");
			prestador.setEstadoCivil(request.getParameter("estadoCivilIn"));
			prestador.setNacionalidade(request.getParameter("nacionalidadeIn").toLowerCase());
			prestador.setNascimento(Util.parseDate(request.getParameter("nascimentoIn")));
			prestador.setNaturalidade(request.getParameter("naturalidadeIn").toLowerCase());
			prestador.setNaturalidadeUf(request.getParameter("naturalUfIn"));			
			prestador.setNome(request.getParameter("nomeIn"));
			prestador.setRamo(ramo);
			prestador.setReferencia("00");
			prestador.setRg(request.getParameter("rgIn"));
			prestador.setSexo(request.getParameter("sexo"));
			prestador.setUnidade(unidade);
			prestador.setVencimento(request.getParameter("vencimento"));
			
			session.saveOrUpdate(prestador);
			
			if (isEdition) {
				query = session.createQuery("from Endereco as e where e.pessoa = :pessoa");
				query.setEntity("pessoa", prestador);
				endereco = (Endereco) query.uniqueResult();				
			} else {
				endereco = new Endereco();
			}
			endereco.setBairro(request.getParameter("bairroIn").toLowerCase());
			endereco.setCep(Util.unMountDocument(request.getParameter("cepIn")));
			endereco.setCidade(request.getParameter("cidadeIn").toLowerCase());
			endereco.setComplemento(request.getParameter("complementoIn"));
			endereco.setNumero(request.getParameter("numeroIn"));
			endereco.setPessoa(prestador);
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
				conta.setPessoa(prestador);
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
				informacao.setPessoa(prestador);
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
		}
		return true;
	}
	
	private void mountFilter(HttpServletRequest request) {
		filter = new Filter("from PrestadorServico as p where p.deleted = \'n\'");		
		
		if (!request.getParameter("referenciaIn").equals("")) {
			filter.addFilter("p.codigo = :referencia",
					Long.class, "referencia", Long.valueOf(request.getParameter("referenciaIn")));
		}
		if (!request.getParameter("nomeIn").equals("")) {
			filter.addFilter("p.nome LIKE :nome", String.class, "nome", 
					"%" + request.getParameter("nomeIn").toLowerCase() + "%");
		}
		if (!request.getParameter("cpfIn").equals("")) {
			filter.addFilter("p.cpf = :cpf", String.class, "cpf", 
					Util.unMountDocument(request.getParameter("cpfIn")));
		}
		if (!request.getParameter("ramoIn").equals("")) {
			filter.addFilter("p.ramo.codigo = :ramo", Long.class, "ramo",
					Long.valueOf(request.getParameter("ramoIn")));
		}
		if (!request.getParameter("ativoChecked").equals("")) {
			filter.addFilter("p.ativo = :ativo", String.class, "ativo", 
					request.getParameter("ativoChecked"));
		}
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("p.unidade.codigo = :unidade", Long.class, "unidade",
					Integer.parseInt(Util.getPart(request.getParameter("unidadeId"), 2)));
		}
		
		if (Util.getPart(request.getParameter("order"), 1).trim().equals("Ref.")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("p.codigo");
			} else {
				filter.setOrder("p.codigo desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Nome")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("p.nome");				
			} else {
				filter.setOrder("p.nome desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Ramo")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("p.ramo.descricao");
			} else {
				filter.setOrder("p.ramo.descricao desc");
			}
		}
	}
}
