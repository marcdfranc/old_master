package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.CreditoPessoa;
import com.marcsoftware.database.CreditoPessoaId;
import com.marcsoftware.database.Dependente;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Informacao;
import com.marcsoftware.database.ItensOrcamento;
import com.marcsoftware.database.ItensOrcamentoId;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.Orcamento;
import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.database.Pessoa;
import com.marcsoftware.database.PlanoServico;
import com.marcsoftware.database.Profissional;
import com.marcsoftware.database.Score;
import com.marcsoftware.database.Servico;
import com.marcsoftware.database.Tabela;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class for Servlet: CadastroOrcamento
 *
 */
public class CadastroOrcamento extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
	static final long serialVersionUID = 1L;
    private Orcamento orcamento;
    private ItensOrcamento iten;
    private Servico servico;
    private Unidade unidade;
    private Pessoa pessoa;
    private Profissional profissional;
    private Usuario usuario;
    private Dependente dependente;
    private ItensOrcamentoId id;
    private CreditoPessoa credPessoa;
    private CreditoPessoaId idCred;
    private Lancamento lancamento;
    private Tabela tabela;
    private Score score;
    private PlanoServico planoServico;
    private List<ParcelaOrcamento> parcela;
    private List<Orcamento> orcamentoList;
    private List<ItensOrcamento> itenList;
    private int count;
    private long sequencial, unidadeId;
    private Session session;
    private Transaction transaction;
    private Query query;
    private Filter filter;
    private DataGrid dataGrid;
    private PrintWriter out;
    private boolean isFilter;
    private int limit, offSet, gridLines;
    private Date now;
    private Login login;
    private double desconto, vlrTotal;
	
	public CadastroOrcamento() {
		 super();
	}
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		unidade = null;
		request.setCharacterEncoding("ISO-8859-1");
		response.setContentType("text/html");
		response.setCharacterEncoding("ISO-8859-1");
		out= response.getWriter();
		if (request.getParameter("from").trim().equals("1")) {
			if (! estorne(request)) {
				out.print("0");
				out.close();
				return;
			}
		} else if (request.getParameter("from").trim().equals("2")) {
			if (! excluirOrcamento(request)) {
				out.print("0");
			} else {
				out.print("1");
			}
			out.close();
			return;
		}
		session= HibernateUtil.getSession();
		transaction= session.beginTransaction();
		isFilter= request.getParameter("isFilter") == "1";
		query= session.createQuery("from Unidade as u where u.codigo = :codigo");
		query.setLong("codigo", 
				(request.getParameter("unidadeIdIn").trim().isEmpty())? 0: 
					Long.valueOf(request.getParameter("unidadeIdIn")));
		unidade= (Unidade) query.uniqueResult();
		mountFilter(request);
		limit= Integer.parseInt(request.getParameter("limit"));
		offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
		query = filter.mountQuery(query, session);
		gridLines= query.list().size();
		query.setFirstResult(offSet);
		query.setMaxResults(limit);
		orcamentoList= (List<Orcamento>) query.list();
		if (orcamentoList.size() == 0) {
			out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td><td></td><td></td></tr>");
			transaction.commit();
			session.close();
			out.close();
			return;
		}
		dataGrid = new DataGrid(null);
		for(Orcamento orc: orcamentoList) {
			query= session.getNamedQuery("totalOrcamento");
			query.setLong("unidade", (request.getParameter("unidadeIdIn") == "")? 0: Long.valueOf(request.getParameter("unidadeIdIn")));
			query.setLong("orcamento", orc.getCodigo());
			vlrTotal = (query.uniqueResult() == null)? 0 : Double.parseDouble(query.uniqueResult().toString());
			//vlrTotal = Double.parseDouble(query.uniqueResult().toString());
			profissional = (Profissional) session.get(Profissional.class, orc.getPessoa().getCodigo());
			dataGrid.setId(String.valueOf(orc.getCodigo()));
			dataGrid.addData(Util.zeroToLeft(orc.getUsuario().getContrato().getCtr(), 4));							
			dataGrid.addData((orc.getDependente() == null)? 
					Util.initCap(orc.getUsuario().getNome()) :
					Util.initCap(orc.getDependente().getNome()));							
			dataGrid.addData(String.valueOf(orc.getCodigo()));
			dataGrid.addData(Util.parseDate(orc.getData(), "dd/MM/yyyy"));
			dataGrid.addData(Util.initCap(profissional.getNome()));
			dataGrid.addData(Util.formatCurrency(vlrTotal));
			query = session.getNamedQuery("parcelamentoByCodeOrcamento");
			query.setLong("codigo", orc.getCodigo());
			parcela = (List<ParcelaOrcamento>) query.list();
			
			desconto = 0;
			if (orc.getUsuario().getPlano().getTipo().equals("l")) {
				query = session.createQuery("from ItensOrcamento as i where i.id.orcamento = :orcamento");
				query.setEntity("orcamento", orc);
				itenList = (List<ItensOrcamento>) query.list();
				for (ItensOrcamento iten: itenList) {
					if (parcela.size() > 0) {
						query = session.createSQLQuery("SELECT SUM(l.valor) FROM parcela_orcamento AS p " +
								" INNER JOIN lancamento AS l ON(p.cod_lancamento = l.codigo) " +
								" WHERE p.cod_orcamento = :orcamento");
						query.setLong("orcamento", orc.getCodigo());
						desconto = Double.parseDouble(query.uniqueResult().toString());
					} else {
						query = session.createQuery("from PlanoServico as p " + 
								" where p.id.plano = :plano " +
						" and p.id.servico = :servico");
						query.setEntity("plano", orc.getUsuario().getPlano());
						query.setEntity("servico", iten.getTabela().getServico());
						if (query.list().size() > 0) {
							planoServico = (PlanoServico) query.uniqueResult();
							if (orc.getDependente() == null) {
								query = session.createQuery("from Score as s " + 
										" where s.validade > current_date " + 
										" and s.usuario = :usuario " + 
								" and s.servico = :servico");
							} else {
								query = session.createQuery("from Score as s " + 
										" where s.validade > current_date " + 
										" and s.usuario = :usuario " + 
										" and s.servico = :servico " +
								" and s.dependente = :dependente");
								query.setEntity("dependente", orc.getDependente());
							}
							query.setEntity("usuario", orc.getUsuario());
							query.setEntity("servico", iten.getTabela().getServico());
						}
						if (query.list().size() > 0) {
							score = (Score) query.uniqueResult();
							if ((planoServico.getQtde() - score.getQtde()) >= iten.getQtde()) {
								desconto += iten.getQtde() * iten.getTabela().getValorCliente();
							} else {
								desconto+= (planoServico.getQtde() - iten.getQtde()) * iten.getTabela().getValorCliente();
							}
						}
					}
				}
			}
			/*if (parcela.size() > 0 && orc.getUsuario().getPlano().getTipo().equals("l")) {
				dataGrid.addData(Util.formatCurrency(vlrTotal - desconto));
			} else if (orc.getUsuario().getPlano().getTipo().equals("l")) {
				dataGrid.addData(Util.formatCurrency(desconto));
			} else {
				dataGrid.addData("0.00");
			}*/
			dataGrid.addImg(Util.getIconMax(parcela));
			dataGrid.addRow();
		}
		transaction.commit();
		session.close();
		out.print(dataGrid.getBody(gridLines));
		out.close();		
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			if (addRecord(request))  {
				response.sendRedirect("application/orcamento.jsp?id=-1");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
				"&lk=application/orcamento.jsp?id=-1");
			}			
		} catch (Exception e) {			
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
			"&lk=application/orcamento.jsp?id=-1");
		}
	}
		
	private void mountFilter(HttpServletRequest request) {
		filter = new Filter("from Orcamento as o " +
				" where o.pessoa.codigo in(" +
				" select p.codigo from Profissional as p)");
		
		if ((!request.getParameter("codigoIn").equals("")) && (!request.getParameter("codigoIn").equals(null))) {
			filter.addFilter("o.codigo = :orc",
					Long.class, "orc", Long.valueOf(
							Util.removeZeroLeft(request.getParameter("codigoIn"))));
		}		
		if (!request.getParameter("profIdIn").equals("")) {
			filter.addFilter("o.pessoa.codigo = :profId",
					Long.class, "profId", Long.valueOf(
							request.getParameter("profIdIn")));
		}
		if (!request.getParameter("profissionalIn").equals("")) {
			filter.addFilter("o.pessoa in (from Profissional as p " +
					" where p.nome like :profissional)",
					String.class, "profissional", 
							"%" + Util.encodeString(request.getParameter("profissionalIn"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("userIdIn").equals("")) {
			filter.addFilter("o.usuario.contrato.ctr = :userId",
				Long.class , "userId", 
				Long.valueOf(Util.removeZeroLeft(request.getParameter("userIdIn"))));
		}
		if (!request.getParameter("usuarioIn").equals("")) {
			filter.addFilter("o.usuario.nome like :usuario",
					String.class, "usuario", 
							"%" + Util.encodeString(request.getParameter("usuarioIn"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("dependenteIn").equals("")) {
			filter.addFilter("o.dependente.nome like :dependente",
					String.class, "dependente", 
							"%" + Util.encodeString(request.getParameter("dependenteIn"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("unidadeIdIn").equals("")) {
			filter.addFilter("o.pessoa.unidade.codigo = :unidade", Long.class, "unidade",
					Integer.parseInt(request.getParameter("unidadeIdIn")));
		} else {
			filter.addFilter("o.pessoa.unidade.codigo = :unidade", Long.class, "unidade", 0);
		}
		
		
		if (Util.getPart(request.getParameter("order"), 1).trim().equals("CTR")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("o.usuario.contrato.ctr");				
			} else {
				filter.setOrder("o.usuario.contrato.ctr desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Cliente")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("o.usuario.nome");				
			} else {
				filter.setOrder("o.usuario.nome desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Orc.")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("o.codigo");
			} else {
				filter.setOrder("o.codigo desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Data")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("o.data");
			} else {
				filter.setOrder("o.data desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("St.")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("o.data");
			} else {
				filter.setOrder("o.data desc");
			}
		}
	}
	 
	private boolean addRecord(HttpServletRequest request) {
		boolean isEdition= (request.getParameter("codOrcamento") != "");
		session= HibernateUtil.getSession();
		transaction= session.beginTransaction();		
		try {
			if (isEdition) {
				query = session.createQuery("from ItensOrcamento as i " +
						" where i.id.orcamento.codigo = :orcamento");
				query.setLong("orcamento", Long.valueOf(request.getParameter("orcIdIn")));				
				itenList = (List<ItensOrcamento>) query.list();				
				
				for (ItensOrcamento it : itenList) {					
					query = session.createQuery("from Tabela as t " +
							" where t.unidade = :unidade " +
							" and t.servico = :servico " +
							" and t.vigencia.codigo = :vigencia");
					query.setEntity("unidade", it.getTabela().getUnidade());
					query.setEntity("servico", it.getTabela().getServico());
					query.setLong("vigencia", Long.valueOf(request.getParameter("tabelaIn")));
					tabela = (Tabela) query.uniqueResult();
					
					it.setTabela(tabela);					
					session.update(it);
				}
			} else {
				unidadeId = Long.valueOf(Util.getPart(request.getParameter("unidadeIdIn"), 2));
				unidade = (Unidade) session.load(Unidade.class, unidadeId);
				
				pessoa = (Pessoa) session.load(Pessoa.class, Long.valueOf(Util.getPart(request.getParameter("profIdIn"), 1)));
				usuario = (Usuario) session.load(Usuario.class, Long.valueOf(Util.getPart(request.getParameter("userIdIn"), 1)));
				
				
				orcamento= new Orcamento();
				query = session.createQuery("from Login as l where l.username = :username");
				query.setString("username", String.valueOf(request.getSession().getAttribute("username")));			
				login = (Login) query.uniqueResult(); 
				if (isEdition) {
					orcamento.setCodigo(Long.valueOf(request.getParameter("codOrcamento")));
				}			
				orcamento.setPessoa(pessoa);
				orcamento.setUsuario(usuario);
				orcamento.setData(Util.parseDate(request.getParameter("cadastroIn")));
				orcamento.setStatus("a");			
				if (!request.getParameter("dependenteIdIn").trim().equals("")) {
					query= session.createQuery("from Dependente as d where d.codigo = :codigo");
					query.setLong("codigo", 
							Long.valueOf(Util.getPart(request.getParameter("dependenteIdIn"), 1)));
					dependente= (Dependente) query.uniqueResult();
					orcamento.setDependente(dependente);
				}
				orcamento.setLogin(login);
				orcamento.setDocDigital("n");
				orcamento.setDocParcelaDigital("n");
				session.saveOrUpdate(orcamento);
				
				if (!isEdition) {
					count= 0;			
					while (request.getParameter("delServ" + String.valueOf(count)) != null) {
						long key =  Long.valueOf(request.getParameter("delServ" + String.valueOf(count++)));
						query= session.createQuery("from ItensOrcamento as i where i.tabela.servico.codigo = :codigo");
						query.setLong("codigo", key);
						iten = (ItensOrcamento) query.uniqueResult();					
						session.delete(iten);
					}
				}
				
				count = 0;
				sequencial= 0;
				if (!isEdition) {
					while (request.getParameter("rowCodigo" + String.valueOf(count)) != null) {					
						iten= new ItensOrcamento();
						id = new ItensOrcamentoId();
						query = session.createQuery("from Tabela as t " +
								" where t.unidade.codigo = :unidade " +
								" and t.servico.referencia = :referencia " +
								" and t.vigencia.codigo = :vigencia");
						query.setLong("unidade", Long.valueOf(Util.getPart(request.getParameter("unidadeIdIn"), 2)));							
						query.setString("referencia", request.getParameter("rowCodigo" + count));
						query.setLong("vigencia", Long.valueOf(request.getParameter("tabelaIn")));
						
						tabela= (Tabela) query.uniqueResult();
						id.setOrcamento(orcamento);
						id.setSequencial(++sequencial);
						iten.setId(id);
						iten.setQtde(Integer.parseInt(request.getParameter("rowQtde" + count++).trim()));
						iten.setTabela(tabela);
						iten.setContabil("s");
						session.save(iten);
					}
				}		

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
	
	private boolean estorne(HttpServletRequest request) {
		session= HibernateUtil.getSession();
		transaction= session.beginTransaction();
		boolean isFirst = true;
		try {
			TipoConta conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("67"));
			query = session.createQuery("from ParcelaOrcamento as p where p.id.orcamento.codigo = :codigo");
			query.setLong("codigo", Long.valueOf(request.getParameter("orcamento")));
			parcela = (List<ParcelaOrcamento>) query.list();
			for (ParcelaOrcamento parc : parcela) {
				now = new Date();
				if (parc.getId().getLancamento().getTipo().trim().equals("d")  &&
						parc.getId().getLancamento().getValorPago() > 0) {
					lancamento = new Lancamento();
					//lancamento.setDescricao("cancelamento de parcela de orçamento");
					lancamento.setConta(conta);
					lancamento.setDocumento("parc: " + 
							parc.getId().getLancamento().getCodigo() + " orç:" +
							parc.getId().getOrcamento().getCodigo());
					lancamento.setEmissao(now);
					lancamento.setStatus("a");
					lancamento.setTaxa(0);
					lancamento.setTipo("c");
					lancamento.setUnidade(parc.getId().getLancamento().getUnidade());
					lancamento.setValor(parc.getId().getLancamento().getValor());
					lancamento.setVencimento(Util.addMonths(now, 1));
					session.save(lancamento);
					
					idCred = new CreditoPessoaId();
					idCred.setLancamento(lancamento);
					idCred.setPessoa(parc.getId().getOrcamento().getPessoa());
					
					credPessoa = new CreditoPessoa();
					credPessoa.setId(idCred);					
					session.save(credPessoa);
					
					parc.getId().getLancamento().setValorPago(0);					
				}
				parc.getId().getLancamento().setStatus("c");
				session.update(parc.getId().getLancamento());
				if (isFirst) {
					parc.getId().getOrcamento().setStatus("c");
					session.update(parc.getId().getOrcamento());
					isFirst= false;
				}
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
	
	private boolean excluirOrcamento(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			query = session.createQuery("from ParcelaOrcamento as p where p.id.orcamento.codigo = :orcamento");
			query.setLong("orcamento", Long.valueOf(request.getParameter("orcamento")));
			if (query.list().size() > 0) {
				transaction.rollback();
				session.close();
				return false;
			} else {
				query = session.createQuery("from Orcamento as o where o.codigo = :orcamento");
				query.setLong("orcamento", Long.valueOf(request.getParameter("orcamento")));
				orcamento = (Orcamento) query.uniqueResult();
				query = session.createQuery("from ItensOrcamento as i where i.id.orcamento = :orcamento");
				query.setEntity("orcamento", orcamento);
				itenList = (List<ItensOrcamento>) query.list();
				for (ItensOrcamento iten : itenList) {
					session.delete(iten);
				}
				session.delete(orcamento);
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
}