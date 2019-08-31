package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
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
import com.marcsoftware.database.Fisica;
import com.marcsoftware.database.FormaPagamento;
import com.marcsoftware.database.Informacao;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.TabelaFranchising;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.BDImgAdmin;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class for Servlet: CadastroUnidade
 * 
 * @author: Marcelo de Oliveira Francisco
 * @web.servlet name=CadastroUnidade
 * @cliente: Josias
 * @empresa: Master Odontologia & Saude
 */
public class CadastroUnidade extends javax.servlet.http.HttpServlet implements
		javax.servlet.Servlet {
	static final long serialVersionUID = 1L;

	// private boolean[] isEdit= {false, false, false, false, false, false,
	// false, false};

	public CadastroUnidade() {
		super();
		/*
		 * errorMessage= ""; count=0;
		 */
	}

	@Override
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/html");
		response.setCharacterEncoding("ISO-8859-1");
		PrintWriter out = response.getWriter();
		Query query = null;
		Session session = HibernateUtil.getSession();
		try {
			boolean isFilter = request.getParameter("isFilter") == "1";
			Filter filter = mountFilter(request);
			int limit = Integer.parseInt(request.getParameter("limit"));
			int offSet = (isFilter) ? 0 : Integer.parseInt(request
					.getParameter("offset"));
			query = filter.mountQuery(query, session);
			int gridLines = query.list().size();
			query.setFirstResult(offSet);
			query.setMaxResults(limit);
			List<Unidade> unidadeList = (List<Unidade>) query.list();
			if (unidadeList.size() == 0) {
				out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td><td></td></tr>");
				session.close();
				out.close();
				return;
			}
			DataGrid dataGrid = new DataGrid("cadastro_unidade.jsp");
			for (Unidade unit : unidadeList) {
				dataGrid.setId(String.valueOf(unit.getCodigo()));
				dataGrid.addData(unit.getReferencia());
				dataGrid.addData(unit.getRazaoSocial());
				dataGrid.addData(unit.getFantasia());
				dataGrid.addData((unit.getTipo() == "f") ? "Franquia"
						: "Unidade");
				dataGrid.addRow();
			}
			out.print(dataGrid.getBody(gridLines));
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			session.close();
			out.close();
		}
	}

	private Filter mountFilter(HttpServletRequest req) {
		String perfil = req.getSession().getAttribute("perfil").toString();
		Filter filter = null;
		if (perfil.trim().equals("a") || perfil.trim().equals("d")
				|| perfil.trim().equals("f")) {
			filter = new Filter("from Unidade as u where (1 = 1)");
		} else {
			filter = new Filter("from Unidade as u where (1 <> 1)");
		}
		if (perfil.trim().equals("f")) {
			filter.addFilter("u.administrador.login.username = :username",
					String.class, "username",
					req.getSession().getAttribute("username").toString());
		}
		if (!req.getParameter("referenciaIn").equals("")) {
			filter.addFilter("u.referencia = :referencia", String.class,
					"referencia", req.getParameter("referenciaIn"));
		}
		if (!req.getParameter("razaoSocialIn").equals("")) {
			filter.addFilter(
					"u.razaoSocial like :razao",
					String.class,
					"razao",
					"%"
							+ Util.encodeString(
									req.getParameter("razaoSocialIn"),
									"ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!req.getParameter("cidadeIn").equals("")) {
			filter.addFilter(
					"u in (select e.pessoa from Endereco as e where cidade like :cidade)",
					String.class,
					"cidade",
					"%"
							+ Util.encodeString(
									req.getParameter("razaoSocialIn"),
									"ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!req.getParameter("cnpjIn").equals("")) {
			filter.addFilter("u.cnpj = :cnpj", String.class, "cnpj",
					req.getParameter("cnpjIn"));
		}
		if (!req.getParameter("nomeIn").equals("")) {
			filter.addFilter(
					"u.administrador in (from Fisica as f where f.nome like :nome)",
					String.class,
					"nome",
					"%"
							+ Util.encodeString(req.getParameter("nomeIn"),
									"ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!req.getParameter("cpfIn").equals("")) {
			filter.addFilter(
					"u.administrador in (from Fisica as fi where fi.cpf = :cpf)",
					String.class, "cpf", req.getParameter("cpfIn"));
		}
		if (!req.getParameter("tipoIn").equals("")) {
			filter.addFilter("u.tipo = :tipo", String.class, "tipo",
					req.getParameter("tipoIn"));
		}
		if ((!req.getParameter("ativo").equals(""))
				&& (!req.getParameter("ativo").equals("t"))) {
			filter.addFilter("u.ativo = :ativo", String.class, "ativo",
					req.getParameter("ativo"));
		}
		filter.setOrder("u.razaoSocial");
		return filter;
	}

	private boolean[] clearEdits(boolean[] isEdit) {
		for (int i = 0; i < isEdit.length; i++) {
			isEdit[i] = false;
		}
		return isEdit;
	}

	@Override
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		try {
			if (addRecord(request)) {
				response.sendRedirect("application/unidade.jsp");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg="
						+ Util.ERRO_INSERT + "&lk=application/unidade.jsp");
			}
		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT
					+ "&lk=application/unidade.jsp");
		}
	}

	private boolean addRecord(HttpServletRequest request) {
		boolean isEdition = (request.getParameter("codUnit") != "");
		boolean result = true;
		int count = 0;
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		try {
			Unidade unidade = null;
			if (isEdition) {
				unidade = (Unidade) session.load(Unidade.class,
						Long.valueOf(request.getParameter("codUnit")));
			} else {
				unidade = new Unidade();
			}
			TabelaFranchising tabela = null;
			if (!request.getParameter("tabelaId").equals("")) {
				tabela = (TabelaFranchising) session.load(
						TabelaFranchising.class,
						Long.valueOf(request.getParameter("tabelaId")));
			}
			unidade.setTabelaFranchising(tabela);
			unidade.setTaxa(Double.parseDouble(request.getParameter("taxaIn")));
			unidade.setAdesao(Double.parseDouble(request
					.getParameter("adesaoIn")));
			unidade.setTabela2(Double.parseDouble(request
					.getParameter("tabela2In")));
			unidade.setReferencia(request.getParameter("codigoIn"));
			unidade.setRazaoSocial(request.getParameter("razaoSocialIn")
					.toLowerCase());
			unidade.setFantasia((request.getParameter("fantasiaIn") == "") ? null
					: request.getParameter("fantasiaIn"));
			unidade.setDescricao(request.getParameter("descricaoUndIn"));
			unidade.setCnpj(Util.unMountDocument(request.getParameter("cnpjIn")));
			unidade.setTipo(request.getParameter("tipo"));
			unidade.setAtivo(request.getParameter("ativoChecked"));
			unidade.setCadastro(Util.parseDate(request
					.getParameter("cadastroIn")));
			unidade.setVencimento(request.getParameter("vencimento"));
			unidade.setDeleted("n");
			unidade.setPercentagemMensalidade(Double.parseDouble(request
					.getParameter("mensalidadeIn")));
			unidade.setPercentagemTratamento(Double.parseDouble(request
					.getParameter("tratamentoIn")));
			unidade.setDocDigital("n");
			unidade.setSite(request.getParameter("siteIn"));
			unidade.setCcobId(request.getParameter("ccobIdIn"));
			unidade.setCcobVerssao(request.getParameter("ccobVerssaoIn")
					.isEmpty() ? null : request.getParameter("ccobVerssaoIn"));
			unidade.setCcobSequencial(request.getParameter("ccobSequencialIn") == null || request.getParameter("ccobSequencialIn").isEmpty() ? 
					Long.valueOf("1") : Long.valueOf(request.getParameter("ccobSequencialIn")
				)
			);

			session.saveOrUpdate(unidade);

			Endereco endereco = null;
			if (isEdition && request.getParameter("codMainAddress")!= null && !request.getParameter("codMainAddress").isEmpty()) {
				endereco = (Endereco) session.load(Endereco.class,
						Long.valueOf(request.getParameter("codMainAddress")));
			} else {
				endereco = new Endereco();
			}

			endereco.setCep(Util.unMountDocument(request.getParameter("cepIn")));
			endereco.setUf(request.getParameter("ufIn"));
			endereco.setCidade(request.getParameter("cidadeIn").toLowerCase());
			endereco.setRuaAv(request.getParameter("ruaIn").toLowerCase());
			endereco.setNumero((request.getParameter("numeroIn") == "") ? null
					: request.getParameter("numeroIn"));
			endereco.setBairro((request.getParameter("bairroIn") == "") ? null
					: request.getParameter("bairroIn").toLowerCase());
			endereco.setComplemento((request.getParameter("complementoIn") == "") ? null
					: request.getParameter("complementoIn"));
			endereco.setPessoa(unidade);
			session.saveOrUpdate(endereco);

			Informacao informacao = null;
			while (request.getParameter("rowType" + String.valueOf(count)) != null) {
				informacao = new Informacao();
				if (!request.getParameter(
						"ckdelContact" + String.valueOf(count)).equals("-1")) {
					informacao.setCodigo(Long.valueOf(request
							.getParameter("ckdelContact"
									+ String.valueOf(count))));
				}
				informacao.setPessoa(unidade);
				informacao.setTipo(request.getParameter("rowType"
						+ String.valueOf(count)));
				informacao.setDescricao(request.getParameter("rowDescript"
						+ String.valueOf(count)));
				informacao.setPrincipal((request
						.getParameter("rowMain" + String.valueOf(count++))
						.toLowerCase().trim().equals("sim")) ? "s" : "n");
				session.saveOrUpdate(informacao);
			}

			count = 0;
			Query query = null;
			while (request.getParameter("delContact" + String.valueOf(count)) != null) {
				query = session
						.createQuery("from Informacao as i where i.codigo = :codigo");
				query.setLong(
						"codigo",
						Long.valueOf(request.getParameter("delContact"
								+ String.valueOf(count++))));
				informacao = (Informacao) query.uniqueResult();
				session.delete(informacao);
			}

			count = 0;
			Conta conta = null;
			Banco banco = null;
			String aux = "";
			while (request.getParameter("rowBank" + String.valueOf(count)) != null) {
				conta = new Conta();
				if (!request.getParameter("ckdelBank" + String.valueOf(count))
						.equals("-1")) {
					conta.setCodigo(Long.valueOf(request
							.getParameter("ckdelBank" + String.valueOf(count))));
				}
				banco = (Banco) session.load(
						Banco.class,
						Long.valueOf(request.getParameter("rowBank"
								+ String.valueOf(count))));
				conta.setPessoa(unidade);
				conta.setBanco(banco);
				conta.setAgencia((request.getParameter("rowAgency"
						+ String.valueOf(count)) == "") ? null : request
						.getParameter("rowAgency" + String.valueOf(count)));
				conta.setNumero(request.getParameter("rowCont"
						+ String.valueOf(count)));
				conta.setTitular(request.getParameter("rowPrincipal"
						+ String.valueOf(count)));
				aux = request.getParameter("rowBoleto" + String.valueOf(count));
				aux = aux.equals("null") ? "0.00" : aux;
				conta.setVlrBoleto(Double.parseDouble(aux));
				conta.setCarteira(request.getParameter("rowCarteira"
						+ String.valueOf(count++)));
				session.saveOrUpdate(conta);
			}

			count = 0;
			while (request.getParameter("delBank" + String.valueOf(count)) != null) {
				query = session
						.createQuery("from Conta as c where c.codigo = :codigo");
				query.setLong(
						"codigo",
						Long.valueOf(request.getParameter("delBank"
								+ String.valueOf(count++))));
				conta = (Conta) query.uniqueResult();
				session.delete(conta);
			}
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
			result = false;
		} finally {
			session.close();
		}
		return result;
	}
}

/*
 * public boolean addRecord(HttpServletRequest request) { boolean isEdition=
 * (request.getParameter("codUnit") != ""); boolean isDel=
 * request.getParameter("isDel") == "1"; int count= 0; String key= ""; Session
 * session= HibernateUtil.getSession(); Transaction transaction=
 * session.beginTransaction(); try { Query query=
 * session.createQuery("from Login as l where l.username = :username"); Login
 * login = null; if (isEdition && isDel) { query.setString("username",
 * request.getParameter("loginOld")); login= (Login) query.uniqueResult();
 * //isDel= !isDel; } else if (!isDel && isEdition){ query.setString("username",
 * request.getParameter("loginIn")); login= (Login) query.uniqueResult(); } else
 * if (!isEdition && isDel){ //query.setString("username",
 * request.getParameter("codAdministradorIn")); //login= (Login)
 * query.uniqueResult(); } else { login = new Login(); }
 * 
 * if (request.getParameter("codAdministradorIn").trim().isEmpty() &&
 * (!request.getParameter
 * ("loginIn").trim().equals(request.getParameter("senhaIn")))) {
 * login.setUsername(request.getParameter("loginIn"));
 * login.setSenha(request.getParameter("senhaIn")); login.setPerfil("f");
 * session.saveOrUpdate(login); } else { if (isEdition && isDel) {
 * session.delete(login); } }
 * 
 * Fisica fisica= null; if
 * (!request.getParameter("codAdministradorIn").trim().isEmpty()) { fisica=
 * (Fisica) session.load(Fisica.class,
 * Long.valueOf(request.getParameter("codAdministradorIn"))); } else { if
 * (!isEdition) { fisica = new Fisica(); }
 * //fisica.setReferencia(request.getParameter("codFisicoIn"));
 * fisica.setReferencia("auto");
 * fisica.setNome(request.getParameter("nomeIn").toLowerCase());
 * fisica.setSexo(request.getParameter("sexo"));
 * fisica.setCpf(Util.unMountDocument(request.getParameter("cpfIn")));
 * fisica.setRg((request.getParameter("rgIn")== "")? null:
 * request.getParameter("rgIn"));
 * fisica.setNascimento(Util.parseDate(request.getParameter("nascimentoIn")));
 * fisica
 * .setNacionalidade(request.getParameter("nacionalidadeIn").toLowerCase());
 * fisica.setNaturalidade(request.getParameter("naturalidadeIn").toLowerCase());
 * fisica.setNaturalidadeUf(request.getParameter("naturalUfIn"));
 * fisica.setEstadoCivil(request.getParameter("estadoCivilIn"));
 * fisica.setAtivo(request.getParameter("ativoChecked"));
 * fisica.setDeleted("n");
 * fisica.setVencimento(request.getParameter("vencimento"));
 * fisica.setLogin(login);
 * fisica.setCadastro(Util.parseDate(request.getParameter("cadastroIn")));
 * session.saveOrUpdate(fisica);
 * 
 * 
 * Endereco enderecoFisica = null; if (isEdition) {
 * enderecoFisica.setCodigo(Long
 * .valueOf(request.getParameter("codAdmimAddress"))); }
 * enderecoFisica.setCep(Util
 * .unMountDocument(request.getParameter("cepResponsavelIn")));
 * enderecoFisica.setUf(request.getParameter("ufResponsavel"));
 * enderecoFisica.setCidade
 * (request.getParameter("cidadeResponsavelIn").toLowerCase());
 * enderecoFisica.setRuaAv
 * (request.getParameter("ruaResponsavelIn").toLowerCase());
 * enderecoFisica.setNumero( (request.getParameter("numeroResponsavelIn")== "")?
 * null : request.getParameter("numeroResponsavelIn"));
 * enderecoFisica.setBairro( (request.getParameter("bairroResponsavelIn")== "")?
 * null : request.getParameter("bairroResponsavelIn").toLowerCase());
 * enderecoFisica.setComplemento(
 * (request.getParameter("complementoResponsavelIn")== "") ? null :
 * request.getParameter("complementoResponsavelIn"));
 * enderecoFisica.setPessoa(fisica); session.saveOrUpdate(enderecoFisica); }
 * 
 * unidade= new Unidade(); if (isEdition) {
 * unidade.setCodigo(Long.valueOf(request.getParameter("codUnit"))); }
 * TabelaFranchising tabela = null; if
 * (!request.getParameter("tabelaId").equals("")) { tabela = (TabelaFranchising)
 * session.load(TabelaFranchising.class,
 * Long.valueOf(request.getParameter("tabelaId"))); }
 * unidade.setTabelaFranchising(tabela); unidade.setAdministrador(fisica);
 * unidade.setTaxa(Double.parseDouble(request.getParameter("taxaIn")));
 * unidade.setAdesao(Double.parseDouble(request.getParameter("adesaoIn")));
 * unidade.setTabela2(Double.parseDouble(request.getParameter("tabela2In")));
 * unidade.setReferencia(request.getParameter("codigoIn"));
 * unidade.setRazaoSocial(request.getParameter("razaoSocialIn").toLowerCase());
 * unidade.setFantasia((request.getParameter("fantasiaIn")== "") ? null :
 * request.getParameter("fantasiaIn"));
 * unidade.setDescricao(request.getParameter("descricaoUndIn"));
 * unidade.setCnpj(Util.unMountDocument(request.getParameter("cnpjIn")));
 * unidade.setTipo(request.getParameter("tipo"));
 * unidade.setAtivo(request.getParameter("ativoChecked"));
 * unidade.setCadastro(Util.parseDate(request.getParameter("cadastroIn")));
 * unidade.setVencimento(request.getParameter("vencimento"));
 * unidade.setDeleted("n");
 * unidade.setPercentagemMensalidade(Double.parseDouble(
 * request.getParameter("mensalidadeIn")));
 * unidade.setPercentagemTratamento(Double
 * .parseDouble(request.getParameter("tratamentoIn")));
 * unidade.setDocDigital("n"); unidade.setSite(request.getParameter("siteIn"));
 * 
 * session.saveOrUpdate(unidade);
 * 
 * endereco= new Endereco(); if (isEdition) {
 * endereco.setCodigo(Long.valueOf(request.getParameter("codMainAddress"))); }
 * endereco.setCep(Util.unMountDocument(request.getParameter("cepIn")));
 * endereco.setUf(request.getParameter("ufIn"));
 * endereco.setCidade(request.getParameter("cidadeIn").toLowerCase());
 * endereco.setRuaAv(request.getParameter("ruaIn").toLowerCase());
 * endereco.setNumero((request.getParameter("numeroIn")== "")? null :
 * request.getParameter("numeroIn"));
 * endereco.setBairro((request.getParameter("bairroIn") == "") ? null :
 * request.getParameter("bairroIn").toLowerCase());
 * endereco.setComplemento((request.getParameter("complementoIn")== "") ? null :
 * request.getParameter("complementoIn")); endereco.setPessoa(unidade);
 * session.saveOrUpdate(endereco);
 * 
 * while (request.getParameter("rowType" + String.valueOf(count)) != null) {
 * informacao= new Informacao(); if (!request.getParameter("ckdelContact" +
 * String.valueOf(count)).equals("-1")) {
 * informacao.setCodigo(Long.valueOf(request.getParameter("ckdelContact" +
 * String.valueOf(count)))); } informacao.setPessoa(unidade);
 * informacao.setTipo(request.getParameter("rowType" + String.valueOf(count)));
 * informacao.setDescricao(request.getParameter("rowDescript" +
 * String.valueOf(count))); informacao.setPrincipal((
 * request.getParameter("rowMain" +
 * String.valueOf(count++)).toLowerCase().trim().equals("sim"))? "s": "n");
 * session.saveOrUpdate(informacao); }
 * 
 * count= 0; while (request.getParameter("delContact" + String.valueOf(count))
 * != null) { query=
 * session.createQuery("from Informacao as i where i.codigo = :codigo");
 * query.setLong("codigo", Long.valueOf(request.getParameter("delContact" +
 * String.valueOf(count++)))); informacao= (Informacao) query.uniqueResult();
 * session.delete(informacao); }
 * 
 * count= 0; while (request.getParameter("rowBank" + String.valueOf(count)) !=
 * null) { conta = new Conta(); if (!request.getParameter("ckdelBank" +
 * String.valueOf(count)).equals("-1")) { conta.setCodigo(
 * Long.valueOf(request.getParameter("ckdelBank" + String.valueOf(count)))); }
 * banco= (Banco) session.load(Banco.class, Long.valueOf(
 * request.getParameter("rowBank" + String.valueOf(count))));
 * conta.setPessoa(unidade); conta.setBanco(banco); conta.setAgencia(
 * (request.getParameter("rowAgency" + String.valueOf(count))== "")? null :
 * request.getParameter("rowAgency" + String.valueOf(count)));
 * conta.setNumero(request.getParameter("rowCont" + String.valueOf(count)));
 * conta.setTitular(request.getParameter("rowPrincipal" +
 * String.valueOf(count++))); session.saveOrUpdate(conta); }
 * 
 * count= 0; while (request.getParameter("delBank" + String.valueOf(count)) !=
 * null) { query=
 * session.createQuery("from Conta as c where c.codigo = :codigo");
 * query.setLong("codigo", Long.valueOf(request.getParameter("delBank" +
 * String.valueOf(count++)))); conta= (Conta) query.uniqueResult();
 * session.delete(conta); }
 * 
 * if (isEdition &&
 * (!request.getParameter("codAdministradorIn").trim().isEmpty()) &&
 * (!request.getParameter("codAdministradorIn").trim().equals(
 * request.getParameter("codAdmin")))) { query=
 * session.createQuery("from Unidade as u where u.administrador.codigo = :codigo"
 * ); query.setLong("codigo", Long.valueOf(request.getParameter("codAdmin")));
 * if (query.list().size() <= 1) { query=
 * session.createQuery("from Fisica as f where f.codigo = :codigo");
 * query.setLong("codigo", Long.valueOf(request.getParameter("codAdmin")));
 * fisica= (Fisica) query.uniqueResult(); fisica.setAtivo("b");
 * session.update(fisica); } }
 * 
 * session.flush(); transaction.commit(); session.close(); } catch (Exception e)
 * { transaction.rollback(); session.close(); e.printStackTrace(); return false;
 * } return true; }
 */