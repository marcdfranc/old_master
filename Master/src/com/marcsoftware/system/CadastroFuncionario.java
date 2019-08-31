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
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Funcionario;
import com.marcsoftware.database.Informacao;
import com.marcsoftware.database.Posicao;
import com.marcsoftware.database.Unidade;

import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


/**
 * Servlet implementation class for Servlet: CadastroFuncionario
 *
 */
 public class CadastroFuncionario extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
   static final long serialVersionUID = 1L;   
   private boolean isFilter;
   private Funcionario funcionario;
   private Unidade unidade; 
   private Banco banco;
   private List<Funcionario> funcionarioList;
   private Filter filter;
   private PrintWriter out;
   private DataGrid dataGrid;
   private Endereco endereco;   
   private Conta conta;   
   private Informacao informacao;
   private Posicao posicao;
   private int count, limit, offSet, gridLines;
   private Transaction transaction;
   
	public CadastroFuncionario() {
		super();		
		count=0;		
	}
	
	@Override
	// metodo de controle da grid
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {						
		response.setContentType("text/html");
		response.setCharacterEncoding("ISO-8859-1");
		out= response.getWriter();
		Session session= HibernateUtil.getSession();
		transaction= session.beginTransaction();
		isFilter= request.getParameter("isFilter") == "1";
		mountFilter(request);
		limit= Integer.parseInt(request.getParameter("limit"));
		offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
	 	Query query= null;
	 	query = filter.mountQuery(query, session);
		gridLines= query.list().size();
		query.setFirstResult(offSet);
		query.setMaxResults(limit);
		funcionarioList= (List<Funcionario>) query.list();
		if (funcionarioList.size() == 0) {
			out.print("<tr><td></td><td><p>" + Util.SEM_REGISTRO + "</p></td><td></td><td></td><td></td><td></td></tr>");
			out.close();
			transaction.commit();
			session.close();
		}
		dataGrid = new DataGrid(null);
		for(Funcionario func: funcionarioList) {
			query = session.getNamedQuery("informacaoPrincipal").setEntity("pessoa", func);
			query.setFirstResult(0);
			query.setMaxResults(1);
			informacao = (Informacao) query.uniqueResult();
			dataGrid.setId(String.valueOf(func.getCodigo()));
			dataGrid.addData(String.valueOf(func.getCodigo()));
			dataGrid.addData(func.getNome());
			dataGrid.addData(func.getPosicao().getDescricao());
			dataGrid.addData(Util.mountCpf(func.getCpf()));
			dataGrid.addData((informacao == null)? "" : informacao.getDescricao());			
			dataGrid.addRow();
		}
		transaction.commit();
		out.print(dataGrid.getBody(gridLines));
		out.close();
	}
	
	private void mountFilter(HttpServletRequest request) {
		filter= new Filter("from Funcionario as f where f.deleted = \'n\'");		
		
		if (!request.getParameter("referenciaIn").equals("")) {
			filter.addFilter("f.codigo = :referencia",
					Long.class, "referencia", Long.valueOf(request.getParameter("referenciaIn")));
		}
		if (!request.getParameter("nomeIn").equals("")) {
			filter.addFilter("f.nome LIKE :nome", String.class, "nome", 
					"%" + request.getParameter("nomeIn").toLowerCase() + "%");
		}
		if (!request.getParameter("cpfIn").equals("")) {
			filter.addFilter("f.cpf = :cpf", String.class, "cpf", 
				 	Util.unMountDocument(request.getParameter("cpfIn")));
		}
		if (!request.getParameter("nascimentoIn").equals("")) {
			filter.addFilter("f.nascimento = :nascimento", java.util.Date.class, 
					"nascimento", Util.parseDate(request.getParameter("nascimentoIn")));
		}
		if (!request.getParameter("ativoChecked").equals("")) {
			filter.addFilter("f.ativo = :ativo", String.class, "ativo",
					request.getParameter("ativoChecked"));
		}
		if (!request.getParameter("cargoId").equals("")) {
			filter.addFilter("f.posicao.codigo = :posicao", Long.class, "posicao",
					Integer.parseInt(request.getParameter("cargoId")));
		}
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("f.unidade.codigo = :unidade", Long.class, "unidade",
					Integer.parseInt(Util.getPart(request.getParameter("unidadeId"), 2)));
		}
		filter.setOrder("f.nome");
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			if (addRecord(request))  {
				response.sendRedirect("application/funcionario.jsp");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
				"&lk=application/funcionario.jsp");
			}			
		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
			"&lk=application/funcionario.jsp");
		}
	}
	
	public boolean addRecord(HttpServletRequest request) {
		boolean isEdition= (request.getParameter("codFuncionario") != "");
		Session session= HibernateUtil.getSession();
		transaction= session.beginTransaction();
		try {
			Query query = session.createQuery("from Unidade as u where u.codigo = :codigo");
			query.setLong("codigo", Long.valueOf(Util.getPart(request.getParameter("unidadeId"), 2)));
			unidade= (Unidade) query.uniqueResult();
			query = session.getNamedQuery("oneInfo").setLong("codigo", 
					Long.valueOf(request.getParameter("cargoId")));
			posicao= (Posicao) query.uniqueResult();
			
			if (isEdition) {
				funcionario = (Funcionario) session.load(Funcionario.class, Long.valueOf(request.getParameter("codFuncionario")));				
			} else {
				funcionario = new Funcionario();
			}			
			funcionario.setUnidade(unidade);
			funcionario.setPosicao(posicao);
			funcionario.setReferencia("-");
			funcionario.setAtivo(request.getParameter("ativoChecked"));
			funcionario.setNome(request.getParameter("nomeIn").toLowerCase());
			funcionario.setSexo(request.getParameter("sexo").toLowerCase());
			funcionario.setCpf(Util.unMountDocument(request.getParameter("cpfIn")));
			funcionario.setRg(request.getParameter("rgIn"));
			funcionario.setNascimento(Util.parseDate(request.getParameter("nascimentoIn")));
			funcionario.setCtps(request.getParameter("ctpsIn"));
			funcionario.setPis(request.getParameter("pisIn"));
			funcionario.setCnh(request.getParameter("cnhIn"));
			funcionario.setEstadoCivil(request.getParameter("estadoCivilIn").toLowerCase());
			funcionario.setNacionalidade(request.getParameter("nacionalidadeIn").toLowerCase());
			funcionario.setNaturalidade(request.getParameter("naturalidadeIn").toLowerCase());
			funcionario.setNaturalidadeUf(request.getParameter("naturalUfIn").toLowerCase());
			funcionario.setSalario(Double.parseDouble(request.getParameter("salarioIn")));
			funcionario.setComissao(Double.parseDouble(request.getParameter("comissaoIn")));
			funcionario.setMeta(Integer.parseInt(request.getParameter("metaIn")));
			funcionario.setBonus(Double.parseDouble(request.getParameter("bonusIn")));
			funcionario.setVencimento(request.getParameter("vencimento"));
			funcionario.setCadastro(Util.parseDate(request.getParameter("cadastroIn")));
			funcionario.setDeleted("n");
			funcionario.setIsAdm("n");
			funcionario.setCcobVendedor(request.getParameter("ccobVendedorIn"));
			session.saveOrUpdate(funcionario);			
			
			endereco= new Endereco();
			if (isEdition) {
				endereco.setCodigo(Long.valueOf(request.getParameter("codAddress")));
			}
			endereco.setPessoa(funcionario);
			endereco.setCep(Util.unMountDocument(request.getParameter("cepIn")));
			endereco.setRuaAv(request.getParameter("ruaIn"));			
			endereco.setNumero(request.getParameter("numeroIn"));
			endereco.setComplemento(request.getParameter("complementoIn"));
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
				conta.setPessoa(funcionario);
				conta.setBanco(banco);
				conta.setAgencia(
						(request.getParameter("rowAgency" + String.valueOf(count))== "")?
								null : request.getParameter("rowAgency" + String.valueOf(count)));
				conta.setNumero(request.getParameter("rowCont" + String.valueOf(count)));
				conta.setTitular(request.getParameter("rowPrincipal" + String.valueOf(count++)).toLowerCase());
				session.saveOrUpdate(conta);					
			}
			
			count= 0;	
			while (request.getParameter("delBank" + String.valueOf(count)) != null) {
				query= session.createQuery("from Conta as c where c.codigo = :codigo");
				query.setLong("codigo", Long.valueOf(request.getParameter("delBank" + String.valueOf(count++))));
				conta= (Conta) query.uniqueResult();
				session.delete(conta);
			}
			
			while (request.getParameter("rowType" + String.valueOf(count)) != null) {
				informacao= new Informacao();
				if (!request.getParameter("ckdelContact" + String.valueOf(count)).equals("-1")) {
					informacao.setCodigo(Long.valueOf(request.getParameter("ckdelContact" + String.valueOf(count))));
				}
				informacao.setPessoa(funcionario);
				informacao.setTipo(request.getParameter("rowType" + String.valueOf(count)));
				informacao.setDescricao(request.getParameter("rowDescript" + String.valueOf(count)));
				informacao.setPrincipal((
						request.getParameter("rowMain" + String.valueOf(count++)).toLowerCase().trim().equals("sim"))?
								"s": "n");
				session.saveOrUpdate(informacao);
			}
			
			count= 0;	
			while (request.getParameter("delContact" + String.valueOf(count)) != null) {
				query= session.createQuery("from Informacao as i where i.codigo = :codigo");
				query.setLong("codigo", Long.valueOf(request.getParameter("delContact" + String.valueOf(count++))));
				informacao= (Informacao) query.uniqueResult();					
				session.delete(informacao);
			}
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
}