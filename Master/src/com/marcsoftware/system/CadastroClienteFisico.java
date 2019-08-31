	package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.BoletoMensalidade;
import com.marcsoftware.database.Contrato;
import com.marcsoftware.database.ContratoEmpresa;
import com.marcsoftware.database.ContratoEmpresaId;
import com.marcsoftware.database.Dependente;
import com.marcsoftware.database.Empresa;
import com.marcsoftware.database.Endereco;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.FormaPagamento;
import com.marcsoftware.database.Funcionario;
import com.marcsoftware.database.Informacao;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.Mensalidade;
import com.marcsoftware.database.Plano;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class for Servlet: CadastroClienteFisico
 *
 */
 public class CadastroClienteFisico extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
   static final long serialVersionUID = 1L;
    
	public CadastroClienteFisico() {
		super();		
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {				
		PrintWriter out;
		
		switch (request.getParameter("from").charAt(0)) {
		case '0':
			response.setContentType("text/plain");
			out= response.getWriter();
			out.print(validCTR(request));
			out.close();
			break;
			
		case '1':
			response.setContentType("text/html");
			out= response.getWriter();
			Session session= HibernateUtil.getSession();
			try {
				boolean isFilter= request.getParameter("isFilter") == "1";
				Filter filter = null;
				if (request.getParameter("diasCarteira").equals("0")) {
					filter = mountFilter(request);
				} else {
					filter = mountFilterCarteira(request);
				}
				int limit= Integer.parseInt(request.getParameter("limit"));
				int offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
				Query query = null;
				query = filter.mountQuery(query, session);
				int gridLines= query.list().size();
				query.setFirstResult(offSet);
				query.setMaxResults(limit);
				List<Usuario> usuarioList= (List<Usuario>) query.list();
				if (usuarioList.size() == 0) {
					out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td><td></td></tr>");
					session.close();
					out.close();
					return;
				} else {
					DataGrid dataGrid= new DataGrid(null);
					for (Usuario us: usuarioList) {
						query = session.getNamedQuery("informacaoPrincipal");
						query.setEntity("pessoa", us);
						query.setFirstResult(0);
						query.setMaxResults(1);
						Informacao informacao= (Informacao) query.uniqueResult();
						dataGrid.setId(String.valueOf(us.getCodigo()));
						dataGrid.addData(Util.zeroToLeft(us.getContrato().getCtr(), 4));
						dataGrid.addData(Util.initCap(
								Util.encodeString(us.getNome(), "UTF8", "ISO-8859-1")));
						dataGrid.addData(Util.mountCpf(us.getCpf()));
						dataGrid.addData(Util.parseDate(us.getCadastro(), "dd/MM/yyyy"));
						dataGrid.addData((informacao== null)? "" : informacao.getDescricao());
						
						query = session.getNamedQuery("parcelaByUsuario");
						query.setLong("usuario", us.getCodigo());
						
						dataGrid.addImg((query.list().size() == 0)? "../image/ok_icon.png" : 
							Util.getIcon(query.list(), "orcamento"));
						
						/*query = session.getNamedQuery("countMensalAtrasoOf");
				query.setLong("codigo", us.getCodigo());
				dataGrid.addData(query.uniqueResult().toString());*/
						
						query = session.getNamedQuery("mensalidadeByUsuario");
						query.setLong("usuario", us.getCodigo());
						dataGrid.addImg(Util.getIcon(query.list(), "mensalidade"));
						
						dataGrid.addRow();
					}					
					out.print(dataGrid.getBody(gridLines));
				}
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				session.close();
				out.close();
			}
			break;

		case '2':
			response.setContentType("text/plain");
			out= response.getWriter();
			out.print(getCampos(request));
			out.close();
			break;
			
		case '3':
			response.setContentType("text/plain");
			out= response.getWriter();
			out.print(delUser(request));
			out.close();
			break;
		}
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			if (addRecord(request))  {
				response.sendRedirect("application/cliente_fisico.jsp");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
				"&lk=application/cliente_fisico.jsp");
			}			
		} catch (SQLException e) {			
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
			"&lk=application/cliente_fisico.jsp");
		}
	}
	
	private boolean addRecord(HttpServletRequest request) throws SQLException {		
		boolean isEdition= (request.getParameter("codUser") != "");		
		Session session= HibernateUtil.getSession();
		Transaction transaction= session.beginTransaction();
		try {
			TipoConta adesao = (TipoConta) session.get(TipoConta.class, Long.valueOf("63"));
			TipoConta mensal = (TipoConta) session.get(TipoConta.class, Long.valueOf("61"));
			Unidade unidade= (Unidade) session.load(Unidade.class, 
					Long.valueOf(Util.getPart(request.getParameter("unidadeId"), 2)));
			Plano plano = (Plano) session.load(Plano.class, 
					Long.valueOf(request.getParameter("planoIn")));			
			FormaPagamento pagamento= (FormaPagamento) session.load(FormaPagamento.class, 
					Long.valueOf(request.getParameter("formaPagamento")));
			Query query = session.createQuery("from Contrato as c where " +
					" c.ctr = :ctr" +
					" and c.unidade = :unidade");
			query.setLong("ctr", Long.valueOf(Util.removeZeroLeft(request.getParameter("codigoIn"))));
			query.setEntity("unidade", unidade);
			Contrato contrato = (Contrato) query.uniqueResult();
			query = session.createQuery("from Login as l where l.username = :login");
			query.setString("login", request.getSession().getAttribute("username").toString());
			Login cadastrador = (Login) query.uniqueResult();			
			
			Usuario usuario = null;
			FormaPagamento oldPagamento = null;
			Empresa empresa = null;
			if (!request.getParameter("idEmpresa").equals("")) {
				empresa= (Empresa) session.load(Empresa.class, 
						Long.valueOf(Util.getPart(request.getParameter("idEmpresa"), 1)));
			}			
			if (isEdition) {				
				usuario = (Usuario) session.load(Usuario.class, 
						Long.valueOf(request.getParameter("codUser")));
				oldPagamento = usuario.getPagamento();
			} else {
				usuario = new Usuario();
				usuario.setCarteirinha(0);
			}
			usuario.setUnidade(unidade);			
			usuario.setContrato(contrato);
			usuario.setCadastro(Util.parseDate(request.getParameter("cadastroIn")));
			usuario.setPlano(plano);
			usuario.setAtivo(request.getParameter("ativoChecked"));
			usuario.setReferencia(request.getParameter("codigoIn"));
			usuario.setNome(request.getParameter("nomeIn").toLowerCase());
			usuario.setSexo(request.getParameter("sexo"));
			usuario.setCpf(Util.unMountDocument(request.getParameter("cpfIn")));
			usuario.setRg(request.getParameter("rgIn"));
			usuario.setNascimento(Util.parseDate(request.getParameter("nascimentoIn")));
			usuario.setEstadoCivil(request.getParameter("estadoCivilIn"));
			usuario.setProfissao(request.getParameter("profissaoIn").toLowerCase());
			usuario.setNacionalidade(request.getParameter("nacionalidadeIn").toLowerCase());
			usuario.setNaturalidade(request.getParameter("naturalidadeIn").toLowerCase());
			usuario.setNaturalidadeUf(request.getParameter("naturalUfIn"));
			usuario.setPai(request.getParameter("paiIn").toLowerCase());
			usuario.setMae(request.getParameter("maeIn").toLowerCase());
			usuario.setVencimento((empresa == null)? request.getParameter("vencimento") :
				empresa.getVencimento());
			usuario.setRenovacao(Util.parseDate(request.getParameter("renovacaoIn")));
			usuario.setDeleted("n");
			usuario.setPagamento(pagamento);
			usuario.setStatus("n");			
			usuario.setQtdeParcela(Integer.parseInt(request.getParameter("pagamentos")));
			usuario.setCarteirinha(Integer.parseInt(request.getParameter("carteirinhaIn")));
			usuario.setCadastrador(cadastrador);
			usuario.setIsAdm("n");
			usuario.setCcobUndConsumidora(request.getParameter("ccobUndConsumidoraIn").isEmpty()? null : request.getParameter("ccobUndConsumidoraIn"));
			usuario.setCcobConcessionaria(request.getParameter("ccobConcessionariaIn").isEmpty()? null : request.getParameter("ccobConcessionariaIn"));
			usuario.setCcobTitular(request.getParameter("ccobTitularIn").isEmpty()? null : request.getParameter("ccobTitularIn"));
			usuario.setCcobDtLeitura(request.getParameter("ccobDtLeituraIn").isEmpty()? null : Util.parseDate(request.getParameter("ccobDtLeituraIn"))); 
			usuario.setCcobDtVencimento(request.getParameter("ccobDtVencimentoIn").isEmpty()? null : Util.parseDate(request.getParameter("ccobDtVencimentoIn"))); 
			usuario.setCcobLogradouro(request.getParameter("ccobLogradouroIn").isEmpty()? null : Long.valueOf(request.getParameter("ccobLogradouroIn")));
			usuario.setCcobStatus(request.getParameter("ccobStatusIn"));
			usuario.setCcobValor(Double.parseDouble(request.getParameter("parcelaIn")));
			usuario.setCcobTipo(request.getParameter("ccobTipoIn").isEmpty()? null : request.getParameter("ccobTipoIn"));
			usuario.setCcobDocumento(request.getParameter("ccobDocumentoIn").isEmpty()? null : request.getParameter("ccobDocumentoIn"));
			usuario.setCcobDocEstadual(request.getParameter("ccobDocEstadualIn").isEmpty()? null : request.getParameter("ccobDocEstadualIn"));
			usuario.setCcobAdesao(Double.parseDouble(request.getParameter("adesaoIn")));
			usuario.setCcobCobrar(request.getParameter("ccobCobrarIn").isEmpty()? null : request.getParameter("ccobCobrarIn"));
		
			if (!isEdition) {
				usuario.setDocDigital("n");
			}
			int parcelas= usuario.getQtdeParcela();
			
			session.saveOrUpdate(usuario);
			
			ContratoEmpresa contratoEmpresa = null;
			ContratoEmpresaId empresaId = null;
			if (!request.getParameter("idEmpresa").equals("")) {
				contratoEmpresa = new ContratoEmpresa();
				empresaId= new ContratoEmpresaId();
				empresaId.setEmpresa(empresa);
				empresaId.setUsuario(usuario);
				contratoEmpresa.setId(empresaId);
				session.saveOrUpdate(contratoEmpresa);
			}
			
			Endereco endereco = null;			
			if (isEdition) {
				endereco = (Endereco) session.load(Endereco.class, 
						Long.valueOf(request.getParameter("codAddress")));
			} else {
				endereco = new Endereco();				
			}
			endereco.setPessoa(usuario);
			endereco.setCep(Util.unMountDocument(request.getParameter("cepIn")));
			endereco.setUf(request.getParameter("ufIn"));
			endereco.setCidade(request.getParameter("cidadeIn").toLowerCase());
			endereco.setRuaAv(request.getParameter("ruaIn").toLowerCase());
			endereco.setNumero(request.getParameter("numeroIn").toLowerCase());
			endereco.setBairro(request.getParameter("bairroIn").toLowerCase());
			endereco.setComplemento(request.getParameter("complementoIn").toLowerCase());
			session.saveOrUpdate(endereco);
			
			int count= 0;
			Dependente dependente = null;
			while (request.getParameter("rowNome" + String.valueOf(count)) != null) {
				dependente = new Dependente();
				if (!request.getParameter("ckdelDependente" + String.valueOf(count)).equals("-1")) {
					dependente.setCodigo(
							Long.valueOf(request.getParameter("ckdelDependente" + String.valueOf(count))));					
				}
				dependente.setUsuario(usuario);
				dependente.setNome(request.getParameter("rowNome" + String.valueOf(count)).toLowerCase());
				dependente.setParentesco(request.getParameter("rowParentesco" + String.valueOf(count)).toLowerCase());
				dependente.setCpf((request.getParameter("rowCpf" + String.valueOf(count)).isEmpty())? null: 
					Util.unMountDocument(request.getParameter("rowCpf" + String.valueOf(count))));
				dependente.setFone((request.getParameter("rowFone" + String.valueOf(count)).isEmpty()) ? null:
					request.getParameter("rowFone" + String.valueOf(count)));
				dependente.setNascimento((request.getParameter("rowNascimento" + String.valueOf(count)).isEmpty())?
						null : Util.parseDate(request.getParameter("rowNascimento" + String.valueOf(count))));
				dependente.setReferencia(request.getParameter("rowRef" + String.valueOf(count++)));
				session.saveOrUpdate(dependente);
			}
			
			count= 0;
			while (request.getParameter("delDependente" + String.valueOf(count)) != null) {
				query= session.createQuery("from Dependente as d where d.codigo = :codigo");
				query.setLong("codigo", 
						Long.valueOf(request.getParameter("delDependente" + String.valueOf(count++))));
				dependente= (Dependente) query.uniqueResult();
				session.delete(dependente);
			}
			
			count= 0;
			Informacao informacao = null;
			while (request.getParameter("rowType" + String.valueOf(count)) != null) {
				informacao= new Informacao();
				if (!request.getParameter("ckdelContact" + String.valueOf(count)).equals("-1")) {
					informacao.setCodigo(Long.valueOf(request.getParameter("ckdelContact" + String.valueOf(count))));
				}
				informacao.setPessoa(usuario);
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
				query= session.createQuery("from Informacao as i where i.codigo = :codigo");
				query.setLong("codigo", key);
				informacao= (Informacao) query.uniqueResult();					
				session.delete(informacao);
			}
			
			BoletoMensalidade boleto = null;
			if (!isEdition) {
				int mes= Util.getMonthDate(request.getParameter("cadastroIn"));
				int year= Util.getYearDate(request.getParameter("cadastroIn"));
				String data= (empresa == null)? request.getParameter("vencimento") +  "/" + String.valueOf(mes) +
					"/" + String.valueOf(year) : empresa.getVencimento() +  "/" + String.valueOf(mes) + "/" + 
					String.valueOf(year);
				Date nextDate = Util.parseDate(data);
				Lancamento lancamento = null;
				Mensalidade mensalidade = null;
				for (int i = 0; i <= parcelas; i++) {
					lancamento = new Lancamento();					
					lancamento.setStatus("a");
					lancamento.setTipo("c");
					lancamento.setTaxa(1);
					lancamento.setMulta(2);
					lancamento.setUnidade(usuario.getUnidade());
					lancamento.setEmissao(Util.parseDate(request.getParameter("cadastroIn")));
					if (i == 0) {
						//lancamento.setDescricao("adesão");
						lancamento.setValor(Double.parseDouble(request.getParameter("adesaoIn")));
						lancamento.setVencimento(Util.parseDate(request.getParameter("cadastroIn")));
						lancamento.setConta(adesao);
						
						if (usuario.getPagamento().getCodigo() == new Long(1)
							&& contratoEmpresa == null) {
							boleto = new BoletoMensalidade();
							boleto.setData(Util.parseDate(request.getParameter("cadastroIn")));
							boleto.setUsuario(usuario);
							session.save(boleto);
						}						
					} else {
						//lancamento.setDescricao("mensalidade");
						lancamento.setValor(Double.parseDouble(request.getParameter("parcelaIn")));
						lancamento.setVencimento(nextDate);
						lancamento.setConta(mensal);
					}					
					session.save(lancamento);						
					
					mensalidade= new Mensalidade();
					mensalidade.setLancamento(lancamento);
					mensalidade.setUsuario(usuario);
					mensalidade.setVigencia(Long.valueOf("1"));
					session.save(mensalidade);
					
					nextDate = Util.addMonths(nextDate, 1);
				}			
			} else if (contratoEmpresa == null) {
				query = session.createQuery("from BoletoMensalidade as b where b.usuario.codigo = :usuario");
				query.setLong("usuario", usuario.getCodigo());
				if (query.list().size() == 0 && usuario.getPagamento().getCodigo() == new Long(1)) {
					boleto = new BoletoMensalidade();
					boleto.setData(Util.parseDate(request.getParameter("cadastroIn")));
					boleto.setUsuario(usuario);
					session.save(boleto);
				}		
				if (oldPagamento.getCodigo() != Long.valueOf(request.getParameter("formaPagamento"))
						&& oldPagamento.getCodigo() == new Long(1)
						&& query.list().size() > 0) {
					boleto = (BoletoMensalidade) query.uniqueResult();
					session.delete(boleto);
				}
			}
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
			return false;
		} finally {
			session.close();
		}
		return true;
	}
	
	private Filter mountFilter(HttpServletRequest request) {
		Filter filter = null;
		if (!request.getParameter("empresaId").equals("")) {
			filter = new Filter("from  Usuario as u where u in " +
					"(select c.id.usuario from ContratoEmpresa as c " +
					"where c.id.empresa.codigo = " + request.getParameter("empresaId") + ")");
		} else {			
			filter = new Filter("from Usuario as u where u.deleted = \'n\'");
		}
		
		if (!request.getParameter("codUser").equals("")) {
			filter.addFilter("u.codigo = :usuario", Long.class, "usuario",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("codUser"))));
		}
		if (!request.getParameter("referenciaIn").equals("")) {
			filter.addFilter("u.contrato.ctr = :referencia",
					Long.class, "referencia", Integer.parseInt(Util.removeZeroLeft(request.getParameter("referenciaIn"))));
		}
		if (!request.getParameter("nomeIn").equals("")) {
			filter.addFilter("u.nome LIKE :nome", String.class, "nome", 
					"%" + Util.encodeString(request.getParameter("nomeIn"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("cpfIn").equals("")) {
			filter.addFilter("u.cpf = :cpf", String.class, "cpf", 
				 	Util.unMountDocument(request.getParameter("cpfIn")));
		}
		if (!request.getParameter("ucIn").equals("")) {
			filter.addFilter("u.ccobUndConsumidora = :ccobUndConsumidora", String.class, "ccobUndConsumidora", 
				 	request.getParameter("ucIn"));
		}
		if (!request.getParameter("nascimentoIn").equals("")) {
			filter.addFilter("u.nascimento = :nascimento", java.util.Date.class, 
					"nascimento", Util.parseDate(request.getParameter("nascimentoIn")));
		}		
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("u.unidade.codigo = :unidade", Long.class, "unidade",
					Integer.parseInt(request.getParameter("unidadeId")));
		}
		if (!request.getParameter("plano").equals("")) {
			filter.addFilter("u.plano.codigo = :plano", Long.class, "plano", 
					Integer.parseInt(request.getParameter("plano")));
		}
		if (!request.getParameter("ativoChecked").equals("")) {
			filter.addFilter("u.ativo = :ativo", String.class, "ativo",
					request.getParameter("ativoChecked"));
		}
		
		if (Util.getPart(request.getParameter("order"), 1).trim().equals("CTR")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("u.contrato.ctr ");				
			} else {
				filter.setOrder("u.contrato.ctr desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Nome")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("u.nome");				
			} else {
				filter.setOrder("u.nome desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Cadastro")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("u.cadastro");
			} else {
				filter.setOrder("u.nascimento desc");
			}
		}
		return filter;
	}
	
	private Filter mountFilterCarteira(HttpServletRequest request) {
		Date now = new Date();
		Filter filter = null;
		if (request.getParameter("diasCarteira") != "30") {
			now = Util.removeDays(now,  (Integer.parseInt(request.getParameter("diasCarteira")) - 30));
		}
		Date inicio = Util.removeDays(now, 30);		
		filter = new Filter("select m.usuario from Mensalidade as m " + 
			" where m.lancamento.status in ('a', 'l') ");
		
		if (request.getParameter("diasCarteira").equals("150")) {
			filter.addFilter("m.lancamento.vencimento < :inicio", java.util.Date.class, 
					"inicio", now);			
		} else {			
			filter.addFilter("m.lancamento.vencimento between :inicio", java.util.Date.class, 
					"inicio", inicio);
			filter.addFilter(" :fim", java.util.Date.class, 
					"fim", now);
			filter.addFilter("m.usuario not in(select e.usuario " + 
					"from Mensalidade as e where e.lancamento.vencimento > :limitador) ", java.util.Date.class, 
					"limitador", now);
		}
		
		if (!request.getParameter("codUser").equals("")) {
			filter.addFilter("m.usuario.codigo = :usuario", Long.class, "usuario",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("codUser"))));
		}
		if (!request.getParameter("referenciaIn").equals("")) {
			filter.addFilter("m.usuario.contrato.codigo = :referencia",
					Long.class, "referencia", Util.removeZeroLeft(request.getParameter("referenciaIn")));
		}
		if (!request.getParameter("nomeIn").equals("")) {
			filter.addFilter("m.usuario.nome LIKE :nome", String.class, "nome", 
					"%" + Util.encodeString(request.getParameter("nomeIn"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("cpfIn").equals("")) {
			filter.addFilter("m.usuario.cpf = :cpf", String.class, "cpf", 
					Util.unMountDocument(request.getParameter("cpfIn")));
		}
		if (!request.getParameter("nascimentoIn").equals("")) {
			filter.addFilter("m.usuario.nascimento = :nascimento", java.util.Date.class, 
					"nascimento", Util.parseDate(request.getParameter("nascimentoIn")));
		}		
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("m.usuario.unidade.codigo = :unidade", Long.class, "unidade",
					Integer.parseInt(request.getParameter("unidadeId")));
		}
		if (!request.getParameter("plano").equals("")) {
			filter.addFilter("m.usuario.plano.codigo = :plano", Long.class, "plano", 
					Integer.parseInt(request.getParameter("plano")));
		}
		if (!request.getParameter("ativoChecked").equals("")) {
			filter.addFilter("m.usuario.ativo = :ativo", String.class, "ativo",
					request.getParameter("ativoChecked"));
		}
		
		if (Util.getPart(request.getParameter("order"), 1).trim().equals("CTR")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("m.usuario.contrato.codigo ");
			} else {
				filter.setOrder("m.usuario.contrato.codigo desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Nome")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("m.usuario.nome");				
			} else {
				filter.setOrder("m.usuario.nome desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Nascimento")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("m.usuario.nascimento");
			} else {
				filter.setOrder("m.usuario.nascimento desc");
			}
		}
		return filter;
	}
	
	private String validCTR(HttpServletRequest request) {
		Session session = HibernateUtil.getSession();
		String result = "1";
		try {
			if (request.getParameter("unidade") == "" 
				|| request.getParameter("ctr") == "") {
				result = "0";
			} else {
				Unidade unidade = (Unidade) session.load(Unidade.class, 
						Long.valueOf(Util.getPart(request.getParameter("unidade"), 2)));
				if (unidade == null) {
					result = "0";
				} else {
					Query query = session.createQuery("from Contrato as c where c.ctr = :ctr " +
							" and c not in(select u.contrato from Usuario as u " +
							" where u.unidade = :undUsuario) " +
					" and c.unidade = :unidade");
					query.setLong("ctr", Long.valueOf(request.getParameter("ctr")));
					query.setEntity("undUsuario", unidade);
					query.setEntity("unidade", unidade);
					if (query.list().size() == 1) {
						result = "0";				
					}					
				}
			}
		} catch (Exception e) {
			e.printStackTrace();			
			result = "1";
		} finally {
			session.close();
		}
		return result;
	}
	
	private String getCampos(HttpServletRequest request) {
		Session session = HibernateUtil.getSession();
		Funcionario funcionario = null;
		String aux = "";
		try {
			Long idVendedor = null;			
			if (!request.getParameter("idVendedor").trim().equals("")) {
				idVendedor = Long.valueOf(request.getParameter("idVendedor"));
				if (idVendedor != null) {
					funcionario = (Funcionario) session.get(Funcionario.class, idVendedor);
					aux+= funcionario.getUnidade().getCodigo() + "@" + Util.initCap(funcionario.getNome());
				}
			}
		} catch (Exception e) {
			e.printStackTrace();	
		} finally {
			session.close();
		}
		return aux;
	}
	
	
	private String delUser(HttpServletRequest request) {
		String result = "";
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		boolean isOk = true;
		try {
			Usuario usuario = (Usuario) session.get(Usuario.class, Long.valueOf(request.getParameter("codigo")));
			Query query = session.createQuery("from Dependente as d where d.usuario = :usuario");
			query.setEntity("usuario", usuario);
			if (query.list().size() > 0) {
				result = "Não foi possível a exclusão por haver dependentes vinculados ao cliente.";
				isOk = false;
			}
			query = session.createQuery("from Mensalidade as m where m.usuario = :usuario");
			query.setEntity("usuario", usuario);
			if (query.list().size() > 0) {
				result = "Não foi possível a exclusão por haver mensalidades vinculados ao cliente.";
				isOk = false;
			}
			query = session.createQuery("from Orcamento as o where o.usuario = :usuario");
			query.setEntity("usuario", usuario);
			if (query.list().size() > 0) {
				result = "Não foi possível a exclusão por haver orçamentos vinculados ao cliente.";
				isOk = false;
			}
			if (isOk) {
				query = session.createQuery("from Endereco as e where e.pessoa = :usuario");
				query.setEntity("usuario", usuario);
				List<Endereco> enderecoList = (List<Endereco>) query.list();
				for (Endereco end : enderecoList) {
					session.delete(end);
				}
				query = session.createQuery("from Informacao as i where i.pessoa = :usuario");
				query.setEntity("usuario", usuario);
				List<Informacao> infoList = (List<Informacao>) query.list();
				for (Informacao info : infoList) {
					session.delete(info);
				}
				session.delete(usuario);
				session.flush();
				result = "Cliente excluído com sucesso!";
			}			
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			result = "Não foi possível a exclusão devido a um erro interno.";
		} finally {
			session.close();
		}
		return result;
	}
}
 
/*
600
 if (idVendedor != null) {
	funcionario = (Funcionario) session.get(Funcionario.class, idVendedor);
	if (funcionario != null && funcionario.getUnidade() != null && funcionario.getNome() != null) {
		aux+= funcionario.getUnidade().getCodigo() + "@" + Util.initCap(funcionario.getNome());
	}
}

*/
 