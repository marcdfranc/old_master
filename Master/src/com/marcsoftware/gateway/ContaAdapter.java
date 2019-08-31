package com.marcsoftware.gateway;

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

import com.marcsoftware.database.Conciliacao;
import com.marcsoftware.database.CreditoPessoa;
import com.marcsoftware.database.CreditoPessoaId;
import com.marcsoftware.database.FormaPagamento;
import com.marcsoftware.database.ItensConciliacao;
import com.marcsoftware.database.ItensConciliacaoId;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Orcamento;
import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.database.ParcelaOrcamentoId;
import com.marcsoftware.database.Pessoa;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

public class ContaAdapter extends HttpServlet{
	private static final long serialVersionUID = 1L;
	private int option, mes, ano, qtde;
	private double vlrParcela, vlrOrcamento, taxa, montante, troco;
	private Date emissao, vencimento;
	private String data, recebimento, strCompare;	
	private PrintWriter out;
	private TipoConta conta;
	private List<ParcelaOrcamento> parcelaList;
	private List<Long> pipe;
	private ParcelaOrcamento parcela;
	private ParcelaOrcamentoId id;
	private CreditoPessoa credPessoa;
	private CreditoPessoaId credPessoaId;
	private Pessoa pessoa;
	private Unidade unidade;
	private FormaPagamento pagamento;
	private Conciliacao conciliacao;
	private ItensConciliacao itens;
	private ItensConciliacaoId conciliacaoId;
	private Orcamento orcamento;
	private DataGrid dataGrid;
	private Lancamento lancamento, lancamentoAux;
	private Usuario usuario;
	private Session session;
	private Transaction transaction;
	private Query query;	
	
	public ContaAdapter() {
		super();
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			if (request.getParameter("from").equals("5")) {
				response.setContentType("text/html");
				response.setCharacterEncoding("ISO-8859-1");
				out = response.getWriter();
				out.print(excluir(request));
				out.close();
			} else if (updateRecord(request)) {			
				response.setContentType("text/html");
				response.setCharacterEncoding("ISO-8859-1");
				out = response.getWriter();
				transaction = session.beginTransaction();
				request.setCharacterEncoding("ISO-8859-1");				
				query = session.getNamedQuery("parcelamentoByCode");
				query.setLong("codigo", Long.valueOf(request.getParameter("orcamento")));
				parcelaList= (List<ParcelaOrcamento>) query.list();
				vencimento = new Date();
				dataGrid= new DataGrid(null);
				int gridLines= parcelaList.size();								
				for(int i=0; i < parcelaList.size(); i++) {
					dataGrid.setId(
							String.valueOf(parcelaList.get(i).getId().getLancamento().getCodigo()));
						
					dataGrid.addData(String.valueOf(parcelaList.get(i).getId().getLancamento().getCodigo()));
					
					dataGrid.addData(parcelaList.get(i).getId().getLancamento().getConta().getDescricao());
					
					dataGrid.addData(Util.parseDate(
							parcelaList.get(i).getId().getLancamento().getVencimento(), "dd/MM/yyyy"));
					
					dataGrid.addData(String.valueOf(i + 1) + " de " + 
						String.valueOf(parcelaList.size()));
					
					dataGrid.addData((parcelaList.get(i).getId().getLancamento().getDataQuitacao()== null)?
							"" : Util.parseDate(
									parcelaList.get(i).getId().getLancamento().getDataQuitacao(), "dd/MM/yyyy"));
					
					dataGrid.addData((parcelaList.get(i).getId().getLancamento().getRecebimento() == null)?
							"" : parcelaList.get(i).getId().getLancamento().getRecebimento());
					
					dataGrid.addData(Util.formatCurrency(parcelaList.get(i).getId().getLancamento().getValor()));
					dataGrid.addData(String.valueOf(parcelaList.get(i).getId().getLancamento().getTaxa()));
					
					if (parcelaList.get(i).getId().getLancamento().getStatus().trim().equals("q")|| 
							parcelaList.get(i).getId().getLancamento().getStatus().trim().equals("f")) {
						dataGrid.addData(
								Util.formatCurrency(parcelaList.get(i).getId().getLancamento().getValorPago()));
					} else {
						dataGrid.addData(Util.formatCurrency(String.valueOf(
								Util.calculaAtraso(parcelaList.get(i).getId().getLancamento().getValor(), 
										parcelaList.get(i).getId().getLancamento().getTaxa(),
										parcelaList.get(i).getId().getLancamento().getMulta(),
										parcelaList.get(i).getId().getLancamento().getVencimento()))));									
					}
					
					dataGrid.addImg(Util.getIcon(parcelaList.get(i).getId().getLancamento().getVencimento(),
							parcelaList.get(i).getId().getLancamento().getStatus()));
					dataGrid.addCheck();
					dataGrid.addRow();
				}
				out.print(dataGrid.getBody(gridLines));
				transaction.commit();
				session.close();
				out.close();
			} else {
				out.print("0");
				transaction.rollback();
				session.close();
				out.close();
			}			
		} catch (Exception e) {
			out.print("0");
			e.printStackTrace();
			transaction.rollback();
			session.close();
			out.close();
		}		
	}
	
	private boolean updateRecord(HttpServletRequest request) {
		int quitadas = 0;
		int pagas = 0;		
		session= HibernateUtil.getSession();
		transaction= session.beginTransaction();
		option = Integer.parseInt(request.getParameter("from"));
		double newValue= 0;
		Conciliacao conciliacao= null;
		try {
			switch (option) {
			//estorno de parcela
			case 0:
				Date now = new Date();
				Date quitacao;
				pipe = Util.unmountPipeline(request.getParameter("pipe"));
				conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("48"));
				ItensConciliacao itenConciliacao = null;
				for (Long pp : pipe) {
					query = session.createQuery("from ParcelaOrcamento as p where p.id.lancamento.codigo = :codigo");
					query.setLong("codigo", pp);					
					parcela= (ParcelaOrcamento) query.uniqueResult();	
					
					
					vlrParcela = parcela.getId().getLancamento().getValorPago();
					quitacao = parcela.getId().getLancamento().getDataQuitacao();
					recebimento = parcela.getId().getLancamento().getRecebimento();
					strCompare = parcela.getId().getLancamento().getStatus();
					data = String.valueOf(parcela.getId().getLancamento().getCodigo());
					unidade = parcela.getId().getLancamento().getUnidade();
					parcela.getId().getLancamento().setDataQuitacao(now);
					parcela.getId().getLancamento().setValorPago(0);
					parcela.getId().getLancamento().setStatus("e");
					parcela.getId().getLancamento().setRecebimento((String) request.getSession().getAttribute("username"));
					query = session.createQuery("from ItensConciliacao as i where i.id.lancamento = :lancamento");
					query.setEntity("lancamento", parcela.getId().getLancamento());
					if (query.list().size() == 1) {
						itenConciliacao = (ItensConciliacao) query.uniqueResult();						
						conciliacao = itenConciliacao.getId().getConciliacao();
						query = session.createQuery("from ItensConciliacao as i where i.id.conciliacao = :conciliacao");
						query.setEntity("conciliacao", conciliacao);
						session.delete(itenConciliacao);
						if (query.list().size() == 0) {
							session.delete(conciliacao);
						}
					}
					
					if (strCompare.trim().equals("q")
							|| strCompare.trim().equals("f")) {						
						lancamento = new Lancamento();
						lancamento.setConta(conta);
						lancamento.setDataQuitacao(now);
						lancamento.setDocumento("orç.: " + 
								parcela.getId().getOrcamento().getCodigo() +
								" guia: " + parcela.getId().getLancamento().getCodigo());
						lancamento.setEmissao(now);
						lancamento.setJuros(0);
						lancamento.setMulta(0);
						lancamento.setRecebimento(request.getSession().getAttribute("username").toString());
						lancamento.setStatus("q");
						lancamento.setTaxa(0);
						lancamento.setTipo("d");
						lancamento.setUnidade(parcela.getId().getLancamento().getUnidade());
						lancamento.setValor(parcela.getId().getLancamento().getValor());
						lancamento.setValorPago(vlrParcela);
						lancamento.setVencimento(now);
						session.save(lancamento);
						
						lancamento = new Lancamento();
						lancamento.setConta(conta);
						lancamento.setDataQuitacao(quitacao);
						lancamento.setDocumento("orç.: " + 
								parcela.getId().getOrcamento().getCodigo() +
								" guia: " + parcela.getId().getLancamento().getCodigo());
						lancamento.setEmissao(now);
						lancamento.setJuros(0);
						lancamento.setMulta(0);
						lancamento.setRecebimento(recebimento);
						lancamento.setStatus("q");
						lancamento.setTaxa(0);
						lancamento.setTipo("c");
						lancamento.setUnidade(parcela.getId().getLancamento().getUnidade());
						lancamento.setValor(parcela.getId().getLancamento().getValor());
						lancamento.setValorPago(vlrParcela);
						lancamento.setVencimento(parcela.getId().getLancamento().getVencimento());
						session.save(lancamento);
						
						if (strCompare.trim().equals("q")) {													
							pessoa = parcela.getId().getOrcamento().getPessoa();
							vlrParcela = parcela.getId().getLancamento().getValor();
							
							vencimento = new Date();
							
							lancamento = new Lancamento();
							//lancamento.setDescricao("Débito Profissional");
							lancamento.setDocumento("Estorno parc.: " + data);
							lancamento.setEmissao(vencimento);
							lancamento.setStatus("a");
							lancamento.setTaxa(0);
							lancamento.setTipo("c");
							lancamento.setUnidade(unidade);
							lancamento.setValor(vlrParcela);
							lancamento.setConta(conta);
							if (Util.getMonthDate(vencimento) == 12) {
								lancamento.setVencimento(Util.parseDate("25/01/" + (Util.getYearDate(vencimento) + 1)));							
							} else if (Util.getDayDate(vencimento) > 25) {
								lancamento.setVencimento(Util.parseDate("25/" + 
										(Util.getMonthDate(vencimento) + 1) +
										"/" + Util.getYearDate(vencimento)));
							} else {
								lancamento.setVencimento(Util.parseDate("25/" + 
										Util.getMonthDate(vencimento) + "/" + 
										Util.getYearDate(vencimento)));
							}
							session.save(lancamento);
							
							credPessoaId = new CreditoPessoaId();
							credPessoaId.setLancamento(lancamento);
							credPessoaId.setPessoa(pessoa);
							
							credPessoa = new CreditoPessoa();
							credPessoa.setId(credPessoaId);
							session.save(credPessoa);
						}
					}
					session.update(parcela.getId().getLancamento());
				}
				break;
			
			//pagamento de parcela
			case 1:
				query = session.getNamedQuery("parcelaQuitada");
				query.setLong("orcamento", Long.valueOf(request.getParameter("orcamento")));
				quitadas = Integer.valueOf(query.uniqueResult().toString());
				qtde = Integer.parseInt(request.getParameter("qtde"));
				pagas = 0;
				troco = Double.parseDouble(request.getParameter("troco"));
				pagamento = (FormaPagamento) session.get(FormaPagamento.class, 
						Long.valueOf(Util.getPart(request.getParameter("formaPag"), 1)));
				now = new Date();
				
				if (pagamento.getConcilia().equals("s")) {
					conciliacao = new Conciliacao();
					conciliacao.setEmissao(Util.parseDate(request.getParameter("emissao")));
					conciliacao.setFormaPagamento(pagamento);
					conciliacao.setNumero(request.getParameter("numeroConcilio"));
					conciliacao.setVencimento(Util.parseDate(request.getParameter("vencimentoConcilia")));
					conciliacao.setStatus("a");
					session.save(conciliacao);
					if (troco > 0) {
						conta = (TipoConta) session.get(TipoConta.class, new Long(70));
						unidade = (Unidade) session.get(Unidade.class, Long.valueOf(request.getSession().getAttribute("unidade").toString()));
						lancamento = new Lancamento();
						lancamento.setConta(conta);
						lancamento.setEmissao(now);
						lancamento.setDataQuitacao(now);						
						lancamento.setJuros(0);
						lancamento.setMulta(0);
						lancamento.setRecebimento((String) request.getSession().getAttribute("username"));
						lancamento.setDocumento("Conciliação: " + conciliacao.getCodigo());
						lancamento.setStatus("q");
						lancamento.setTaxa(0);
						lancamento.setTipo("d");
						lancamento.setUnidade(unidade);
						lancamento.setValor(troco);
						lancamento.setValorPago(troco);
						lancamento.setVencimento(now);
						session.save(lancamento);
						
						conta = (TipoConta) session.get(TipoConta.class, new Long(71));						
						lancamento = new Lancamento();
						lancamento.setConta(conta);
						lancamento.setEmissao(now);
						lancamento.setDataQuitacao(now);
						lancamento.setJuros(0);
						lancamento.setMulta(0);
						lancamento.setRecebimento((String) request.getSession().getAttribute("username"));
						lancamento.setDocumento("Conciliação: " + conciliacao.getCodigo());
						lancamento.setStatus("q");
						lancamento.setTaxa(0);
						lancamento.setTipo("c");
						lancamento.setUnidade(unidade);
						lancamento.setValor(troco);
						lancamento.setValorPago(troco);
						lancamento.setVencimento(now);
						session.save(lancamento);
						
						itens = new ItensConciliacao();
						conciliacaoId = new ItensConciliacaoId();
						conciliacaoId.setConciliacao(conciliacao);
						conciliacaoId.setLancamento(lancamento);
						itens.setId(conciliacaoId);
						itens.setDocDigital("n");
						session.save(itens);
					}
				}
				pipe = Util.unmountPipeline(request.getParameter("pipe"));
				for (Long pp : pipe) {					
					lancamento= (Lancamento) session.get(Lancamento.class, pp);	
					
					if ((!lancamento.getStatus().trim().equals("f")) && 
							(!lancamento.getStatus().trim().equals("q"))) {
						if (pagamento.getConcilia().equals("s")) {
							newValue= Double.parseDouble(request.getParameter("totalPagar")) / pipe.size();
						} else {
							newValue= (request.getParameter("juros").trim().equals("n")) ?
									lancamento.getValor() : Util.calculaAtraso(
											lancamento.getValor(), lancamento.getTaxa(), 
											lancamento.getMulta(),
											lancamento.getVencimento());
							
						}
						if (request.getParameter("cobBoleto").equals("s")) {
							newValue += 2;
						}
							
						vencimento = lancamento.getVencimento();
						unidade = lancamento.getUnidade();
						emissao = new Date();
						lancamento.setDataQuitacao(emissao);
						lancamento.setEmissao(emissao);
						lancamento.setValorPago(newValue);
						lancamento.setRecebimento((String) request.getSession().getAttribute("username"));
						lancamento.setStatus("f");
						lancamento.setDocumento("orç.: " + request.getParameter("orcamento") + 
								" guia: " + lancamento.getCodigo());
						session.update(lancamento);
						pagas++;
						if (pagamento.getConcilia().equals("s")) {
							itens = new ItensConciliacao();
							conciliacaoId = new ItensConciliacaoId();
							conciliacaoId.setConciliacao(conciliacao);
							conciliacaoId.setLancamento(lancamento);
							itens.setId(conciliacaoId);
							session.save(itens);
						}
					}
				}
				pagas+= quitadas;
				if (pagas == qtde) {
					orcamento = (Orcamento) session.get(Orcamento.class, Long.valueOf(request.getParameter("orcamento")));
					orcamento.setStatus("q");
					session.update(orcamento);
				}
				break;
				
			//reparcelamento
			case 2:
				query= session.createQuery("from ParcelaOrcamento as p where p.id.orcamento.codigo = :codigo");
				query.setLong("codigo", Long.valueOf(request.getParameter("orcamento")));
				parcelaList= (List<ParcelaOrcamento>) query.list();
				montante = 0;
				for (ParcelaOrcamento parc : parcelaList) {
					if (parc.getId().getLancamento().getStatus().trim().equals("q")) {
						montante+= parc.getId().getLancamento().getValorPago();
					}
					
				}
				
				while (parcelaList.get(0) != null) {
					session.delete(parcelaList.get(0).getId().getLancamento());
					session.delete(parcelaList.get(0));
				}
				
				query = session.createQuery("from Unidade as u where u.codigo = :codigo");
				query.setLong("codigo", Long.valueOf(request.getParameter("unidadeId")));			
				unidade= (Unidade) query.uniqueResult();				
				
				query = session.createQuery("from Orcamento as o where o.codigo= :codigo");
				query.setLong("codigo", Long.valueOf(request.getParameter("orcamento")));
				orcamento = (Orcamento) query.uniqueResult();
				if (request.getParameter("obs").trim().isEmpty()) {
					orcamento.setObservacao(Util.encodeString(request.getParameter("obs"), "ISO-8859-1","UTF8"));
				}
				session.update(orcamento);
				
				mes= Util.getMonthDate(request.getParameter("cadastro"));
				ano= Util.getYearDate(request.getParameter("cadastro"));
				qtde = Integer.parseInt(request.getParameter("parcela"));
				vlrOrcamento= Double.parseDouble(request.getParameter("valor"));
				taxa = Double.parseDouble(request.getParameter("taxa"));
				vlrParcela = (vlrOrcamento * Math.pow((1 + taxa/100), qtde))/qtde;
				conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("62"));
				
				for (int i = 0; i < qtde; i++) {
					data= request.getParameter("vencimento") + "/" + 
						Util.zeroToLeft(String.valueOf(mes), 2) + "/" + String.valueOf(ano);
					lancamento = new Lancamento();
					//lancamento.setDescricao("tratamento");
					lancamento.setTipo("c");
					lancamento.setTaxa(taxa);
					lancamento.setUnidade(unidade);
					lancamento.setValor(vlrParcela);
					lancamento.setConta(conta);
					if (i == 0) {						
						lancamento.setVencimento(Util.parseDate(request.getParameter("now")));
						lancamento.setDataQuitacao(Util.parseDate(request.getParameter("now")));
						lancamento.setStatus("q");
					} else {
						lancamento.setStatus("a");
						lancamento.setVencimento(Util.parseDate(data));
					}				
					session.save(lancamento);
					
					id = new ParcelaOrcamentoId();
					id.setLancamento(lancamento);				
					id.setOrcamento(orcamento);
					
					parcela = new ParcelaOrcamento();
					parcela.setId(id);
					parcela.setBeneficiario("c");
					session.save(parcela);
					
					if (mes >= 12) {
						mes = 1;
						ano++;
					} else {
						mes++;
					}
				}				
				break;
				
			//cancelamento de parcela
			case 3:
				pipe = Util.unmountPipeline(request.getParameter("pipe"));
				conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("48"));
				for (Long pp : pipe) {
					query = session.createQuery("from Lancamento as l where l.codigo = :codigo");
					query.setLong("codigo", pp);
					lancamento = (Lancamento) query.uniqueResult();
					data = String.valueOf(lancamento.getCodigo());
					unidade = lancamento.getUnidade();
					strCompare = lancamento.getStatus();
					lancamento.setStatus("c");
					lancamento.setRecebimento((String) request.getParameter("username"));
					session.update(lancamento);
					if (strCompare.trim().equals("q")) {
						query = session.getNamedQuery("lancamentoDebito");
						query.setString("parcela", "%.: " + data);
						parcela = (ParcelaOrcamento) query.uniqueResult();
						pessoa = parcela.getId().getOrcamento().getPessoa();
						vlrParcela = parcela.getId().getLancamento().getValor();
						parcela.getId().getLancamento().setStatus("c");
						session.update(parcela.getId().getLancamento());
						
						vencimento = new Date();						
						
						lancamento = new Lancamento();
						//lancamento.setDescricao("Débito Profissional");
						lancamento.setDocumento("Estorno parc.: " + data);
						lancamento.setEmissao(vencimento);
						lancamento.setStatus("a");
						lancamento.setTaxa(0);
						lancamento.setTipo("c");
						lancamento.setUnidade(unidade);
						lancamento.setValor(vlrParcela);
						lancamento.setConta(conta);
						if (Util.getMonthDate(vencimento) == 12) {
							lancamento.setVencimento(Util.parseDate("25/01/" + (Util.getYearDate(vencimento) + 1)));							
						} else if (Util.getDayDate(vencimento) > 25) {
							lancamento.setVencimento(Util.parseDate("25/" + 
									(Util.getMonthDate(vencimento) + 1) +
									"/" + Util.getYearDate(vencimento)));
						} else {
							lancamento.setVencimento(Util.parseDate("25/" + 
									Util.getMonthDate(vencimento) + "/" + 
									Util.getYearDate(vencimento)));
						}
						session.save(lancamento);
						
						credPessoaId = new CreditoPessoaId();
						credPessoaId.setLancamento(lancamento);
						credPessoaId.setPessoa(pessoa);
						
						credPessoa = new CreditoPessoa();
						credPessoa.setId(credPessoaId);
						session.save(credPessoa);						
					}
				}
				break;
				
			//Restituição de parcela
			case 4:
				pipe = Util.unmountPipeline(request.getParameter("pipe"));
				conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("48"));
				for (Long pp : pipe) {
					query = session.createQuery("from Lancamento as l where l.codigo = :codigo");
					query.setLong("codigo", pp);
					lancamento = (Lancamento) query.uniqueResult();
					data = String.valueOf(lancamento.getCodigo());
					unidade = lancamento.getUnidade();
					strCompare = lancamento.getStatus();
					lancamento.setStatus("a");
					lancamento.setRecebimento((String) request.getSession().getAttribute("username"));
					session.update(lancamento);
					vencimento = new Date();
					if (strCompare == "q") {
						query = session.getNamedQuery("lancamentoDebito");
						query.setString("parcela", "%.: " + data);
						parcela = (ParcelaOrcamento) query.uniqueResult();
						pessoa = parcela.getId().getOrcamento().getPessoa();
						vlrParcela = parcela.getId().getLancamento().getValor();
						parcela.getId().getLancamento().setStatus("c");
						session.update(parcela.getId().getLancamento());						
						
						lancamento = new Lancamento();
						//lancamento.setDescricao("Débito Profissional");
						lancamento.setDocumento("Estorno parc.: " + data);
						lancamento.setEmissao(vencimento);
						lancamento.setStatus("a");
						lancamento.setTaxa(0);
						lancamento.setTipo("c");
						lancamento.setUnidade(unidade);
						lancamento.setValor(vlrParcela);
						lancamento.setConta(conta);
						if (Util.getMonthDate(vencimento) == 12) {
							lancamento.setVencimento(Util.parseDate("25/01/" + (Util.getYearDate(vencimento) + 1)));							
						} else if (Util.getDayDate(vencimento) > 25) {
							lancamento.setVencimento(Util.parseDate("25/" + 
									(Util.getMonthDate(vencimento) + 1) +
									"/" + Util.getYearDate(vencimento)));
						} else {
							lancamento.setVencimento(Util.parseDate("25/" + 
									Util.getMonthDate(vencimento) + "/" + 
									Util.getYearDate(vencimento)));
						}
						session.save(lancamento);
						
						credPessoaId = new CreditoPessoaId();
						credPessoaId.setLancamento(lancamento);
						credPessoaId.setPessoa(pessoa);
						
						credPessoa = new CreditoPessoa();
						credPessoa.setId(credPessoaId);
						session.save(credPessoa);
					}
					
					if ((montante > 0) && ((strCompare == "f") || (strCompare == "q"))) {
						lancamento = new Lancamento();
						//lancamento.setDescricao("Crédito Cliente");
						lancamento.setDocumento("Restituição parc.: " + data);
						lancamento.setEmissao(vencimento);
						lancamento.setTaxa(0);
						lancamento.setUnidade(unidade);
						lancamento.setValor(montante);
						lancamento.setTipo("d");
						lancamento.setConta(conta);
						if (request.getParameter("pagar").trim().equals("s")) {
							lancamento.setStatus("q");
							lancamento.setValorPago(montante);
						} else {
							lancamento.setStatus("a");
						}
						if (Util.getMonthDate(vencimento) == 12) {
							lancamento.setVencimento(Util.parseDate("25/01/" + (Util.getYearDate(vencimento) + 1)));							
						} else if (Util.getDayDate(vencimento) > 25) {
							lancamento.setVencimento(Util.parseDate("25/" + 
									(Util.getMonthDate(vencimento) + 1) +
									"/" + Util.getYearDate(vencimento)));
						} else {
							lancamento.setVencimento(Util.parseDate("25/" + 
									Util.getMonthDate(vencimento) + "/" + 
									Util.getYearDate(vencimento)));
						}
						lancamento.setRecebimento((String) request.getSession().getAttribute("username"));
						session.save(lancamento);
						
						query = session.createQuery("from Usuario as u where u.codigo = :usuario");
						query.setLong("usuario", Long.valueOf(request.getParameter("codUser")));
						usuario = (Usuario) query.uniqueResult();
						
						credPessoaId = new CreditoPessoaId();
						credPessoaId.setLancamento(lancamento);
						credPessoaId.setPessoa(usuario);
						
						credPessoa = new CreditoPessoa();
						credPessoa.setId(credPessoaId);
						
						session.save(credPessoa);
					}
				}
				break;
			}
			session.flush();
			transaction.commit();			
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return false;
		}		
		return true;
	}
	
	private String excluir(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		String result = "";
		boolean isOk = true;
		try {
			query = session.createQuery("from ParcelaOrcamento as p where p.id.orcamento.codigo = :orcamento");
			query.setLong("orcamento", Long.valueOf(request.getParameter("orcamento")));
			parcelaList = (List<ParcelaOrcamento>) query.list();
			for (ParcelaOrcamento parc : parcelaList) {
				if (parc.getId().getLancamento().getStatus().equals("q")
						|| parc.getId().getLancamento().getStatus().equals("f")) {
					isOk = false;
					result = "1@Não é possível a exclusão de parcelas pagas!";
					break;
				} else if (isOk){
					lancamento = parc.getId().getLancamento();
					session.delete(parc);
					session.delete(lancamento);
				} 
			}
			if (isOk) {
				session.flush();
				transaction.commit();
				result = "0@Parcelas excluídas com sucesso!";
			} else {
				transaction.rollback();
			}
		} catch (Exception e) {
			e.printStackTrace();
			result = "1@Não foi possível excluir as parcelas devido um erro interno!";
		} finally {
			session.close();
		}
		return result;
	}
}
