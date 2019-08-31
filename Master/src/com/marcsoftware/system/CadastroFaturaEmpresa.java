package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.ContratoEmpresa;
import com.marcsoftware.database.Empresa;
import com.marcsoftware.database.FaturaEmpresa;
import com.marcsoftware.database.FaturaEmpresaId;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.LancamentoFaturaEmp;
import com.marcsoftware.database.Mensalidade;
import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroFaturaEmpresa
 */
public class CadastroFaturaEmpresa extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private FaturaEmpresa fatura;
	private LancamentoFaturaEmp faturaEmp;
	private FaturaEmpresaId faturaEmpresaId;
	private Empresa empresa;
	private List<Lancamento> lancamentoList;
	private List<Usuario> usuario;
	private List<LancamentoFaturaEmp> faturaList;
	private List<ParcelaOrcamento> parcelaList;
	private Lancamento lancamento;
	private TipoConta conta;
	private Session session;
	private Transaction transaction;
	private Query query, queryList;
	private double sumMensalidade, sumOrcamento, cliente, totalProfissional, operacional;
	private Date dataInicial, dataFinal;	
	private int dia, mes, ano;
	private PrintWriter out;
	private Filter filter;
	private boolean isFilter;
	private int limit, offSet, gridLines;
	
        
    public CadastroFaturaEmpresa() {
        super();
        // TODO Auto-generated constructor stub
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		switch (Integer.parseInt(request.getParameter("from"))) {
		//geração de faturas
		case 0:
			request.setCharacterEncoding("ISO-8859-1");				
			response.setContentType("text/plain");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			out.print(faturaGenerate(request));
			break;

		//pagamento de faturas
		case 1:
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			out = response.getWriter();
			out.print((pagFatura(request))? "0" : "1");			
			break;
			
		case 2:
			out = response.getWriter();
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			session= HibernateUtil.getSession();
			transaction= session.beginTransaction();
			try {
				isFilter= request.getParameter("isFilter") == "1";
				mountFilter(request);
				limit= Integer.parseInt(request.getParameter("limit"));
				offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
				queryList = filter.mountQuery(query, session);
				parcelaList = (List<ParcelaOrcamento>) queryList.list();
				gridLines= parcelaList.size();			
				if (parcelaList.size() == 0) {
					out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td><td></td></tr>");
					transaction.commit();
					session.close();
					out.close();
					return;
				}
				totalProfissional = 0;
				for (int i = 0; i < parcelaList.size(); i++) {
					query = session.getNamedQuery("operacionalOrcamento");
					query.setLong("orcamento", parcelaList.get(i).getId().getOrcamento().getCodigo());
					query.setLong("unidade", parcelaList.get(i).getId().getLancamento().getUnidade().getCodigo());
					operacional = Double.parseDouble(query.uniqueResult().toString());
					
					query = session.getNamedQuery("clienteOrcamento");
					query.setLong("orcamento", parcelaList.get(i).getId().getOrcamento().getCodigo());
					query.setLong("unidade", parcelaList.get(i).getId().getLancamento().getUnidade().getCodigo());
					cliente = Double.parseDouble(query.uniqueResult().toString());
					
					totalProfissional += Util.getOperacional(
							operacional, cliente, parcelaList.get(i).getId().getLancamento().getValor());
				}			
				queryList.setFirstResult(offSet);
				queryList.setMaxResults(limit);
				parcelaList = (List<ParcelaOrcamento>) queryList.list();
				DataGrid dataGrid= new DataGrid(null);
				dataGrid.addColum("5", "CTR");
				dataGrid.addColum("50", "Cliente");
				dataGrid.addColum("5", Util.encodeString("orç.", "UTF8", "ISO-8859-1"));
				dataGrid.addColum("5", "Guia");
				dataGrid.addColum("5", Util.encodeString("Emissão", "UTF8", "ISO-8859-1"));
				dataGrid.addColum("10", "vencimento");
				dataGrid.addColum("5", "Prof.");
				dataGrid.addColum("10", "valor");
				dataGrid.addColum("5", "Ck");
				for (ParcelaOrcamento parcela : parcelaList) {
					dataGrid.setId(String.valueOf(parcela.getId().getLancamento().getCodigo()));
					if (parcela.getId().getOrcamento().getDependente() == null) {
						dataGrid.addData(parcela.getId().getOrcamento().getUsuario().getReferencia() +	"-0");
						dataGrid.addData(Util.encodeString(
								parcela.getId().getOrcamento().getUsuario().getNome(),
								"UTF8", "ISO-8859-1"));
					} else {
						dataGrid.addData(parcela.getId().getOrcamento().getUsuario().getReferencia() + 
								"-" + parcela.getId().getOrcamento().getDependente().getReferencia());
						dataGrid.addData(Util.encodeString(
								parcela.getId().getOrcamento().getDependente().getNome(), 
								"UTF8", "ISO-8859-1"));
					}
					dataGrid.addData(String.valueOf(parcela.getId().getOrcamento().getCodigo()));
					dataGrid.addData(String.valueOf(parcela.getId().getLancamento().getCodigo()));
					dataGrid.addData((parcela.getId().getLancamento().getEmissao() == null) ? "" :
						Util.parseDate(parcela.getId().getLancamento().getEmissao() , "dd/MM/yyyy"));
					
					if (Util.getDayDate(parcela.getId().getLancamento().getDataQuitacao()) > 25) {
						if (Util.getMonthDate(parcela.getId().getLancamento().getDataQuitacao()) == 12) {
							dataGrid.addData("25/01/" + (Util.getYearDate(parcela.getId().getLancamento().getDataQuitacao()) + 1));
						} else {
							dataGrid.addData("25/" + (Util.getMonthDate(parcela.getId().getLancamento().getDataQuitacao()) + 1) +
									"/" + Util.getYearDate(parcela.getId().getLancamento().getDataQuitacao()));
						}
					} else {
						dataGrid.addData("25/" + Util.getMonthDate(parcela.getId().getLancamento().getDataQuitacao())+
								"/" + Util.getYearDate(parcela.getId().getLancamento().getDataQuitacao()));
					}
					dataGrid.addData(String.valueOf(parcela.getId().getOrcamento().getPessoa().getCodigo()));
					dataGrid.addData(Util.formatCurrency(Util.getOperacional(
							operacional, cliente, parcela.getId().getLancamento().getValor())));														
					dataGrid.addCheck();
					dataGrid.addRow();
				}
				dataGrid.addTotalizador(
						Util.encodeString("Débito de Profissionais e Clínicas", "UTF8", "ISO-8859-1"), 
						Util.formatCurrency(totalProfissional), false);
				dataGrid.makeTotalizador();
				out.print(dataGrid.getTable(gridLines));
				transaction.commit();
				session.close();				
			} catch (Exception e) {
				e.printStackTrace();
				transaction.rollback();
				session.close();
			}
			break;
			
		case 3:
			out = response.getWriter();
			response.setContentType("text/plain");
			response.setCharacterEncoding("ISO-8859-1");
			
			out.print(excluiFatura(request));
			
			out.close();
			break;
		}
		out.close();
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
	}
	
	private String faturaGenerate(HttpServletRequest request) {		
		dataInicial = (request.getParameter("dataBase").trim().equals(""))?
			new Date() : Util.parseDate(request.getParameter("dataBase"));
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			query = session.createQuery("from Empresa as e where e.codigo = :codigo");
			query.setLong("codigo", Long.valueOf(request.getParameter("empresa")));
			empresa= (Empresa) query.uniqueResult();			
			dia = Integer.parseInt(empresa.getVencimento());
			mes = Util.getMonthDate(dataInicial);
			ano = Util.getYearDate(dataInicial);		
			sumMensalidade = 0;
			sumOrcamento = 0;
			dia = Integer.parseInt(empresa.getVencimento());
			if (mes == 1) {				
				dataInicial = Util.parseDate(dia + "/12/" + (ano - 1));
				dataFinal = Util.parseDate(dia + "/" + mes + "/" + ano);				
			} else {
				dataInicial = Util.parseDate(dia + "/" + (mes - 1) + "/" + ano);
				dataFinal = Util.parseDate(dia + "/" + mes + "/" + ano);
			}
			query = session.createQuery("from FaturaEmpresa as f where f.empresa.codigo = :codigo and f.dataInicio = :dataInicial and f.dataFim = :dataFinal");
			query.setLong("codigo", empresa.getCodigo());
			query.setDate("dataInicial", dataInicial);
			query.setDate("dataFinal", dataFinal);
			
			if (query.list().size() > 0) {
				transaction.commit();
				session.close();
				return "../error_page.jsp?errorMsg=Já existe uma fatura para esta data!" + 
					"&lk=application/empresa.jsp";
			}
			
			fatura = new FaturaEmpresa();
			fatura.setDataInicio(dataInicial);
			fatura.setDataFim(dataFinal);
			fatura.setEmpresa(empresa);
			session.save(fatura);
			
			query = session.getNamedQuery("usuarioContrato");
			query.setEntity("empresa", empresa);
			usuario = (List<Usuario>) query.list();
			
			for (Usuario user : usuario) {
				query = session.getNamedQuery("lancamentoMensalidade");
				query.setEntity("usuario", user);
				query.setDate("dataInicio", dataInicial);
				query.setDate("dataFim", dataFinal);
				lancamentoList = (List<Lancamento>) query.list();
				for (Lancamento lanc : lancamentoList) {
					sumMensalidade++;
					faturaEmpresaId = new FaturaEmpresaId();
					faturaEmpresaId.setFaturaEmpresa(fatura);
					faturaEmpresaId.setLancamento(lanc);
					faturaEmp = new LancamentoFaturaEmp();
					faturaEmp.setId(faturaEmpresaId);
					session.save(faturaEmp);
				}
				
				query = session.getNamedQuery("lancamentoOrc");
				query.setEntity("usuario", user);
				query.setDate("dataInicio", dataInicial);
				query.setDate("dataFim", dataFinal);
				lancamentoList = (List<Lancamento>) query.list();
				for (Lancamento lanc : lancamentoList) {
					sumOrcamento++;
					faturaEmpresaId = new FaturaEmpresaId();
					faturaEmpresaId.setFaturaEmpresa(fatura);
					faturaEmpresaId.setLancamento(lanc);
					faturaEmp = new LancamentoFaturaEmp();
					faturaEmp.setId(faturaEmpresaId);
					session.save(faturaEmp);
				}
			}
			if ((sumMensalidade == 0) && (sumOrcamento == 0)) {
				transaction.rollback();
				session.close();
				return "../error_page.jsp?errorMsg=Naõ existem lançamentos para esta database!" +
					"&lk=application/empresa.jsp";
			} else {
				session.flush();
				transaction.commit();
				session.close();
			}
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "../error_page.jsp?errorMsg=Ocorreu um erro durante a " +
					"geração da fatura!&lk=application/empresa.jsp";
		}
		return "0";
	}
	
	private boolean pagFatura(HttpServletRequest request) {
		double valorPago = 0;
		double debitoAnterior = 0;
		Date now = new Date();
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			query = session.createQuery("from LancamentoFaturaEmp as l where l.id.faturaEmpresa.codigo = :fatura");
			query.setLong("fatura", Long.valueOf(request.getParameter("faturaId")));
			faturaList = (List<LancamentoFaturaEmp>) query.list();
			
			for (LancamentoFaturaEmp fat : faturaList) {
				if (request.getParameter("juros").trim().equals("s")
						&& fat.getId().getLancamento().getVencimento().before(now)) {
					debitoAnterior+= (Util.calculaAtraso(fat.getId().getLancamento().getValor(), 
							fat.getId().getLancamento().getTaxa(), fat.getId().getLancamento().getVencimento()) - 
							fat.getId().getLancamento().getValor());
				}
				valorPago = fat.getId().getLancamento().getValor();
				if (request.getParameter("automatico").trim().equals("s")) {
					fat.getId().getLancamento().setDataQuitacao(Util.parseDate(request.getParameter("dtPagamento")));
					fat.getId().getLancamento().setRecebimento("automático");
				} else {
					fat.getId().getLancamento().setDataQuitacao(now);
					fat.getId().getLancamento().setRecebimento(request.getSession().getAttribute("username").toString());
				}
				fat.getId().getLancamento().setValorPago(valorPago);
				fat.getId().getLancamento().setStatus("q");
				fat.getId().getLancamento().setValorPago(valorPago);
				session.update(fat.getId().getLancamento());
			}
			
			if (request.getParameter("juros").trim().equals("s")
					&& debitoAnterior > 0) {
				conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("68"));
				lancamento = new Lancamento();
				lancamento.setConta(conta);
				lancamento.setDocumento("fatura: " + request.getParameter("faturaId") +
						" empresa: " + faturaList.get(0).getId().getFaturaEmpresa().getEmpresa().getCodigo());
				lancamento.setEmissao(now);
				now = Util.addMonths(now, 1);
				lancamento.setJuros(0);
				lancamento.setMulta(0);
				lancamento.setStatus("a");
				lancamento.setTaxa(0);
				lancamento.setTipo("c");
				lancamento.setUnidade(faturaList.get(0).getId().getFaturaEmpresa().getEmpresa().getUnidade());
				lancamento.setValor(debitoAnterior);
				lancamento.setVencimento(now);
				session.save(lancamento);
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
	
	private String excluiFatura(HttpServletRequest request) {
		String result = "";
		session = HibernateUtil.getSession();
		try {
			transaction = session.beginTransaction();
			fatura = (FaturaEmpresa) session.load(FaturaEmpresa.class, Long.valueOf(request.getParameter("codigo")));
			query = session.createQuery("from LancamentoFaturaEmp l where l.id.faturaEmpresa = :empresa");
			query.setEntity("empresa", fatura);
			
			faturaList = (List<LancamentoFaturaEmp>) query.list();
			if (faturaList.size() > 0 && (
					faturaList.get(0).getId().getLancamento().getStatus().equals("a") ||
					faturaList.get(0).getId().getLancamento().getStatus().equals("c") ||
					faturaList.get(0).getId().getLancamento().getStatus().equals("e"))) {
				for (LancamentoFaturaEmp fat : faturaList) {
					session.delete(fat);
				}
				
				session.delete(fatura);
				
				transaction.commit();
				
				result = "o";
			} else {
				transaction.rollback();
				result = "z";
			}
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			result = "e";
		}
		return result;
	}
	
	private void mountFilter(HttpServletRequest request) {
		filter = new Filter("from ParcelaOrcamento as p " + 
			"where p.id.lancamento.status = 'f' " +
			"and p.id.lancamento.tipo = 'c' ");	
		
		if (!request.getParameter("ref").equals("")) {
			filter.addFilter("p.id.orcamento.usuario.contrato.codigo = :usuario", Long.class, "usuario",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("ref"))));
		}
		if (!request.getParameter("titular").equals("")) {
			filter.addFilter("p.id.orcamento.usuario.nome LIKE :nome", String.class, "nome", 
					"%" + Util.encodeString(request.getParameter("titular"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("titular").equals("")) {
			filter.addFilter("p.id.orcamento.usuario.nome LIKE :nome", String.class, "nome", 
					"%" + Util.encodeString(request.getParameter("titular"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("dependente").equals("")) {
			filter.addFilter("p.id.orcamento.dependente.nome LIKE :dependente", String.class, "dependente", 
					"%" + Util.encodeString(request.getParameter("dependente"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}	
		if (!request.getParameter("orcamento").equals("")) {
			filter.addFilter("p.id.orcamento.codigo = :orcamento",
					Long.class, "orcamento", Util.removeZeroLeft(request.getParameter("orcamento")));
		}
		if (!request.getParameter("profissional").equals("")) {
			filter.addFilter("p.id.orcamento.pessoa.codigo = :profissional", Long.class, "profissional",
					Long.valueOf(request.getParameter("profissional")));
		}
		if (!request.getParameter("profissional").equals("")) {
			filter.addFilter("p.id.orcamento.pessoa.codigo = :profissional", Long.class, "profissional",
					Long.valueOf(request.getParameter("profissional")));
		}
		if (!request.getParameter("empresaIdIn").equals("")) {
			filter.addFilter("p.id.orcamento.pessoa.codigo = :empresaId", Long.class, "empresaId",
					Long.valueOf(request.getParameter("empresaIdIn")));
		}
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("p.id.orcamento.usuario.unidade.codigo = :unidade", Long.class, "unidade",
					Long.valueOf(request.getParameter("unidadeId")));
		}
		filter.setOrder("p.id.lancamento.dataQuitacao");
	}
}