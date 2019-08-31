<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.database.Profissional"%>
<%@page import="com.marcsoftware.database.BorderoProfissional"%>
<%@page import="com.marcsoftware.database.ItensBordero"%>
<%@page import="com.marcsoftware.database.Orcamento"%>
<%@page import="com.marcsoftware.database.ParcelaOrcamento"%>
<%@page import="com.marcsoftware.database.ItensOrcamento"%>
<%@page import="com.marcsoftware.database.FormaPagamento"%>
<%@page import="com.marcsoftware.database.EmpresaSaude"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%! boolean isEdition= false; %>
	<% isEdition = false;
	isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}%>
		
	<jsp:useBean id="profissional" class="com.marcsoftware.database.Profissional"></jsp:useBean>
	<jsp:useBean id="empresaSaude" class="com.marcsoftware.database.EmpresaSaude"></jsp:useBean>
	
	<%Query query;
	BorderoProfissional bordero = null;
	List<ItensBordero> itens= null;
	ParcelaOrcamento parcela= null;
 	String pagamento = "";
 	boolean isProfissional = true;
 	
 	
 	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	query = sess.createQuery("from FormaPagamento as f");
	List<FormaPagamento> pagamentoList = (List<FormaPagamento>) query.list();
	boolean isQuit = false;
	boolean haveDoc = false;
	if (isEdition) {
		bordero = (BorderoProfissional) sess.get(BorderoProfissional.class, 
				Long.valueOf(request.getParameter("id")));
		
		haveDoc = bordero.haveDocDigital();
		
		query = sess.getNamedQuery("operacionalQuit");
		query.setLong("bordero", bordero.getCodigo());
		isQuit = (isEdition && Integer.parseInt(query.uniqueResult().toString()) != 0);
		query = sess.createQuery("from Profissional as p where p.codigo = :pessoa");
		query.setLong("pessoa", bordero.getPessoa().getCodigo());
		
		if (query.list().size() == 0) {
			empresaSaude = (EmpresaSaude) sess.get(EmpresaSaude.class, bordero.getPessoa().getCodigo());
			isProfissional = false;
		} else {
			profissional= (Profissional) query.uniqueResult();
		}
		
		isEdition = true;
		query = sess.createQuery("from ItensBordero as i where i.id.borderoProfissional = :bordero");
		query.setEntity("bordero", bordero);
		itens = (List<ItensBordero>) query.list();		
		
		query = sess.createQuery("from FormaPagamento as f order by f.descricao");
		List<FormaPagamento> pagList = (List<FormaPagamento>) query.list();
		
		for(FormaPagamento pag: pagList) {
			if(pagamento.equals("")) {
				if(pag.getConcilia().trim().equals("s")) {
				pagamento += pag.getCodigo() + "@" + pag.getDescricao() +
					"@" + pag.getConcilia();					
				}
			} else {
				if(pag.getConcilia().trim().equals("s")) {
				pagamento += "|" + pag.getCodigo() + "@" + pag.getDescricao() +
					"@" + pag.getConcilia();
				}
			}
		}
	} else {
		query = sess.createQuery("from Profissional as p where p.codigo = :pessoa");
		query.setLong("pessoa", Long.valueOf(request.getParameter("id")));
		if (query.list().size() == 0) {
			empresaSaude = (EmpresaSaude) sess.get(EmpresaSaude.class, Long.valueOf(request.getParameter("id")));
			isProfissional = false;
		} else {
			profissional = (Profissional) query.uniqueResult();
		}
	}
	String parametro =  (isProfissional)? "profissional" : "empSaude";
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<link type="text/css" href="../js/jquery/uploaddif/uploadify.css" rel="Stylesheet" />	
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/uploaddif/swfobject.js"></script>
	<script type="text/javascript" src="../js/jquery/uploaddif/jquery.uploadify.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/validation.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/comum/cadastro_bordero.js" ></script>
	<script type="text/javascript" src="../js/lib/pilot_grid.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>	
	
<title>Master - Gerção de Borderô</title>
</head>
<body onload="loadPage(<%= isEdition %>)">
	<div id="uploadBordero" class="removeBorda" title="Upload da Imagem da Guia" style="display: none;">
		<form id="formUpload" onsubmit="return false;" action="../GuiaUpload" method="post" enctype="multipart/form-data">
			<div class="uploadContent" id="contUpload">
				<div id="msgUpload" style="margin-bottom: 20px;">Clique abaixo para selecionar o arquivo pdf a ser enviado.</div>
				<div id="fileQueue" style="width: 200px;"></div>
				<input type="file" name="uploadify" id="uploadify" />
			</div>
			<input type="hidden" value="" id="uploadName" name="uploadName" />
		</form>
	</div>
	<div id="okWindow" class="removeBorda" title="Pagamento de Mensalidade" style="display: none">			
		<form id="formOk" onsubmit="return false;">
			<fieldset>
				<label>Fatura de repasse de valores gerada com sucesso.</label>
			</fieldset>
		</form>
	</div>
	<div id="okPagWindow" class="removeBorda" title="Pagamento de Mensalidade" style="display: none">			
		<form id="formOkPag" onsubmit="return false;">
			<fieldset>
				<label>Pagamento de fatura efetuado com sucesso.</label>
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="<%= parametro %>"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="<%= parametro %>"/>			
		</jsp:include>
		<div id="formStyle">
			<form id="parc" method="get">
				<input type="hidden" id="docDigital" name="docDigital" value="<%= (haveDoc)? "s" : "n" %>" />
				<div id="localEdTabela" name="localEdTabela"> 
					<%List<ItensOrcamento> itensOrc;
					double operacional = 0;
					double cliente = 0;					
					int qtde = 0;
					if (isEdition) {
						for(int i= 0; i < itens.size(); i++) {
							query = sess.createQuery("from ParcelaOrcamento as p where p.id.lancamento = :lancamento");
							query.setEntity("lancamento", itens.get(i).getId().getCliente());
							parcela = (ParcelaOrcamento) query.uniqueResult();							
							query = sess.createQuery("from ItensOrcamento as i where i.id.orcamento = :orcamento");
							query.setEntity("orcamento", parcela.getId().getOrcamento());
							itensOrc = (List<ItensOrcamento>) query.list();
							for(ItensOrcamento it: itensOrc) {
								query = sess.getNamedQuery("operacionalOrcamento");
								query.setLong("orcamento", parcela.getId().getOrcamento().getCodigo());
								query.setLong("unidade", parcela.getId().getLancamento().getUnidade().getCodigo());
								operacional = Double.parseDouble(query.uniqueResult().toString());
								
								query = sess.getNamedQuery("clienteOrcamento");
								query.setLong("orcamento", parcela.getId().getOrcamento().getCodigo());
								query.setLong("unidade", parcela.getId().getLancamento().getUnidade().getCodigo());
								cliente = Double.parseDouble(query.uniqueResult().toString());
							}
							out.print("<input id=\"ItBorderoId" + i + "\" name=\"ItBorderoId" +	i + 
									"\" type=\"hidden\" value=\"" + 
									itens.get(i).getOperacional().getCodigo() + "\" />");
							
							if (parcela.getId().getOrcamento().getDependente() == null) {
								out.print("<input id=\"edCtr" + i + "\" name=\"edCtr" +	i + 
										"\" type=\"hidden\" value=\"" + 
										parcela.getId().getOrcamento().getUsuario().getReferencia() + "-0\" />");								
								out.print("<input id=\"edNome" + i + "\" name=\"edNome" +	i + 
										"\" type=\"hidden\" value=\"" + 
										Util.initCap(parcela.getId().getOrcamento().getUsuario().getNome())
										+ "\" />");
							} else {
								out.print("<input id=\"edCtr" + i + "\" name=\"edCtr" +	i + 
										"\" type=\"hidden\" value=\"" + 
										parcela.getId().getOrcamento().getUsuario().getReferencia() + "-" +
										parcela.getId().getOrcamento().getDependente().getReferencia() + "\" />");								
								out.print("<input id=\"edNome" + i + "\" name=\"edNome" +	i + 
										"\" type=\"hidden\" value=\"" + 
										Util.initCap(parcela.getId().getOrcamento().getDependente().getNome())
										+ "\" />");
							}
							
							out.print("<input id=\"edOrcamento" + i + "\" name=\"edOrcamento" +	i +
									"\" type=\"hidden\" value=\"" + 
									parcela.getId().getOrcamento().getCodigo() + "\" />");
							out.print("<input id=\"edGuia" + i + "\" name=\"edGuia" +	i +
									"\" type=\"hidden\" value=\"" + itens.get(i).getId().getCliente().getCodigo() +
									"\" />");
							out.print("<input id=\"edEmissao" + i + "\" name=\"edEmissao" +	i +
									"\" type=\"hidden\" value=\"" + 
									Util.parseDate(itens.get(i).getId().getCliente().getEmissao(), "dd/MM/yyyy") +
									"\" />");							
							out.print("<input id=\"edValor" + i + "\" name=\"edValor" +	i +
									"\" type=\"hidden\" value=\"" + Util.formatCurrency(Util.getOperacional(
											operacional, cliente, parcela.getId().getLancamento().getValor())) + "\" />");
						}
					}	
					%>
				</div>
				<div>				
					<input type="hidden" id="pessoaId" name="pessoaId" value="<%= (isProfissional)? profissional.getCodigo() : empresaSaude.getCodigo() %>"/>
					<input type="hidden" id="formaPag" name="formaPag" value="<%= pagamento %>"/>
					<input type="hidden" id="idPagamento" name="idPagamento" value="<%= (isEdition)? bordero.getFormaPagamento().getCodigo(): "" %>"/>
				</div>
				<div id="localTabela"></div>
				<div id="deletedsLanc"></div>
				<div id="editedsLanc"></div>
				<!--<input type="button" value="mostra" onclick="mostra()" />-->	
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Fatura"/>			
					</jsp:include>
					<div id="abaMenu">
						<%if (isProfissional) {%>
							<div class="aba2">
								<a href="cadastro_profissional.jsp?state=1&id=<%= profissional.getCodigo()%>">Cadastro</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="anexo_profissional.jsp?id=<%= profissional.getCodigo()%>">Anexo</a>
							</div>
							
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="agenda_profissional.jsp?id=<%= profissional.getCodigo()%>">Agenda</a>
							</div>
							
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="bordero_profissional.jsp?id=<%= profissional.getCodigo()%>">Borderô</a>
							</div>							
						<%} else {%>
							<div class="aba2">
								<a href="cadastro_empresa_saude.jsp?state=1&id=<%= empresaSaude.getCodigo()%>">Cadastro</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="anexo_empresa_saude.jsp?state=1&id=<%= empresaSaude.getCodigo()%>">Anexo</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="bordero_empresa_saude.jsp?id=<%= empresaSaude.getCodigo()%>">Borderô</a>
							</div>
						<%}%>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Cadastro de Fatura</label>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<%if (isProfissional) {%>
							<div class="aba2">
								<a href="fatura_bordero_profissional.jsp?id=<%= profissional.getCodigo()%>">Histórico de Faturas</a>
							</div>
						<%} else {%>
							<div class="aba2">
								<a href="fatura_bordero_profissional.jsp?id=<%= empresaSaude.getCodigo()%>">Histórico de Faturas</a>
							</div>
						<%}%>
					</div>
					<div class="topContent">
						<%if (isProfissional) {%>
							<div class="textBox" id="unidadeRef" name="unidadeRef" style="width: 65px;">
								<label>Cód. Unid.</label><br/>
								<input id="unidadeRefIn" name="unidadeRefIn" type="text" style="width:65px" readonly="readonly" value="<%=profissional.getUnidade().getReferencia()%>"/>
							</div>
							<div id="unidade" class="textBox" style="width: 275px;" >
								<label>Unidade</label><br/>
								<input id="unidadeIn" name="unidadeIn" type="text" style="width: 275px;" value="<%= Util.initCap(profissional.getUnidade().getDescricao()) %>" readonly="readonly" />
							</div>
							<div class="textBox" id="borderoId" name="unidadeRef" style="width: 58px;">
								<label>Cód. Fat.</label><br/>
								<input id="borderoIdIn" name="borderoIdIn" type="text" style="width:58px" readonly="readonly" value="<%= (isEdition)? bordero.getCodigo() : "" %>"/>
							</div>
							<div id="tpPagamento" name="tpPagamento" class="textBox" style="width: 206px">
								<label>Forma de Pagamento</label><br/>
								<select id="tpPagamentoIn" name="tpPagamentoIn" class="required" style="width: 206px;" onblur="genericValid(this);" <%if (isEdition) out.print("disabled=\"disabled\""); %>>
	 								<% if (isEdition) { %>							
										<option selected="selected" value="<%= bordero.getFormaPagamento().getCodigo() %>" ><%=bordero.getFormaPagamento().getDescricao() %></option><%
									} else {%>
										<option value="">Selecione</option><%
									}%>
									<%for(FormaPagamento pag: pagamentoList) {
										if (isEdition) {
											if (!bordero.getFormaPagamento().equals(pag)) {
												out.print("<option value=\"" + pag.getCodigo() + "\">" + 
														pag.getDescricao() + "</option>");
											}
										} else {
											out.print("<option value=\"" + pag.getCodigo() + "\">" + 
													pag.getDescricao() + "</option>");
										}
									}
									%>
								</select>
							</div>
							<div id="referencia" class="textBox" style="width: 75px;" >
								<label>Ref. Prof.</label><br/>
								<input id="referenciaIn" name="referenciaIn" type="text" style="width: 75px;" value="<%= profissional.getCodigo() %>" readonly="readonly" />
							</div>
							<div id="profissional" class="textBox" style="width: 300px;" >
								<label>Profissional</label><br/>
								<input id="profissionalIn" name="profissionalIn" type="text" style="width: 300px;" value="<%=Util.initCap(profissional.getNome())%>" readonly="readonly" />
							</div>
							<div id="conselho" class="textBox" style="width: 150px;" >
								<label>Nro. Conselho</label><br/>
								<input id="conselhoIn" name="conselhoIn" type="text" style="width: 150px;" value="<%=profissional.getConselho().toUpperCase()%>" readonly="readonly" />
							</div>
							<div id="cadastroCalendar" class="textBox" style="width: 73px;">
								<label>Cadastro</label><br/>
								<input id="cadastroIn" name="cadastroIn" type="text" style="width: 73px;" value="<%=(bordero != null)? Util.parseDate(bordero.getCadastro(), "dd/MM/yyyy") : Util.getToday() %>"  onkeydown="mask(this, dateType);"/>
							</div>
						<%} else {%>
							<div class="textBox" id="unidadeRef" name="unidadeRef" style="width: 65px;">
								<label>Cód. Unid.</label><br/>
								<input id="unidadeRefIn" name="unidadeRefIn" type="text" style="width:65px" readonly="readonly" value="<%=empresaSaude.getUnidade().getReferencia()%>"/>
							</div>
							<div id="unidade" class="textBox" style="width: 275px;" >
								<label>Unidade</label><br/>
								<input id="unidadeIn" name="unidadeIn" type="text" style="width: 275px;" value="<%= Util.initCap(empresaSaude.getUnidade().getDescricao()) %>" readonly="readonly" />
							</div>
							<div class="textBox" id="borderoId" name="unidadeRef" style="width: 58px;">
								<label>Cód. Fat.</label><br/>
								<input id="borderoIdIn" name="borderoIdIn" type="text" style="width:58px" readonly="readonly" value="<%= (isEdition)? bordero.getCodigo() : "" %>"/>
							</div>
							<div id="tpPagamento" name="tpPagamento" class="textBox">
								<label>Forma de Pagamento</label><br/>
								<select id="tpPagamentoIn" name="tpPagamentoIn" class="required" onblur="genericValid(this);" <%if (isEdition) out.print("disabled=\"disabled\""); %>>
	 								<% if (isEdition) { %>							
										<option selected="selected" value="<%= bordero.getFormaPagamento().getCodigo() %>" ><%=bordero.getFormaPagamento().getDescricao() %></option><%
									} else {%>
										<option>Selecione</option><%
									}%>
									<%for(FormaPagamento pag: pagamentoList) {
										if (isEdition) {
											if (!bordero.getFormaPagamento().equals(pag)) {
												out.print("<option value=\"" + pag.getCodigo() + "\">" + 
														pag.getDescricao() + "</option>");
											}
										} else {
											out.print("<option value=\"" + pag.getCodigo() + "\">" + 
													pag.getDescricao() + "</option>");
										}
									}
									%>
								</select>
							</div>
							<div id="referencia" class="textBox" style="width: 75px;" >
								<label>Ref. Emp.</label><br/>
								<input id="referenciaIn" name="referenciaIn" type="text" style="width: 75px;" value="<%= empresaSaude.getCodigo() %>" readonly="readonly" />
							</div>
							<div id="empSaude" class="textBox" style="width: 300px;" >
								<label>Empresa de Saúde</label><br/>
								<input id="empSaudeIn" name="empSaudeIn" type="text" style="width: 300px;" value="<%=Util.initCap(empresaSaude.getFantasia())%>" readonly="readonly" />
							</div>
							<div id="conselho" class="textBox" style="width: 150px;" >
								<label>Nro. Conselho</label><br/>
								<input id="conselhoIn" name="conselhoIn" type="text" style="width: 150px;" value="<%=empresaSaude.getConselhoResponsavel()%>" readonly="readonly" />
							</div>
							<div id="cadastroCalendar" class="textBox" style="width: 73px;">
								<label>Cadastro</label><br/>
								<input id="cadastroIn" name="cadastroIn" type="text" style="width: 73px;" value="<%=(bordero != null)? Util.parseDate(bordero.getCadastro(), "dd/MM/yyyy") : Util.getToday() %>"  onkeydown="mask(this, dateType);"/>
							</div>
						<%}%>
					</div>
				</div>
				<div class="topButtonContent">
					<div id="btPag" class="<%=(isEdition && isQuit)? "formGreenButton" : "cpEscondeWithHeight"%>">
						<input class="greenButtonStyle" type="button" value="Imprimir" onclick="pdfGenerate()" />
					</div>
					<div class="<%=(isEdition)? "formGreenButton" : "cpEscondeWithHeight"%>">
						<input class="greenButtonStyle" type="button" value="Doc. Digital" onclick="loadDocDigital()" />
					</div>
					<div class="<%=(isEdition)? "formGreenButton" : "cpEscondeWithHeight"%>">
						<input class="greenButtonStyle" type="button" value="Upload" onclick="showUploadWd()" />
					</div>
				</div>
				<div id="mainContent">					
					<div id="itensOrcamento" class="bigBox" >
						<div class="indexTitle">
							<h4>Guias</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div class="textBox" id="guia" name="guia" style="width: 800px;">
							<label>Guia</label><br/>
							<input id="guiaIn" name="guiaIn" type="text" style="width:100px" >
						</div>
						<div id="tableLancamento" class="multGrid"></div>
					</div>
					<div class="totalizadorRight">
						<label id="labelTotal" class="titleCounter" >Total a Pagar</label>
						<label id="total" name="total" style="margin-right: 80px">: 0.00</label>
					</div>
					<div class="buttonContent">
						<%if (session.getAttribute("caixaOpen").toString().trim().equals("t")) {%>
							<div id="btSave" class="<%=(!isEdition)? "formGreenButton" : "cpEscondeWithHeight"%>">
								<input class="greenButtonStyle" type="button" value="Salvar" onclick="generate()" />
							</div>
							<div id="btPag" class="<%=(isEdition && !isQuit)? "formGreenButton" : "cpEscondeWithHeight"%>">
								<input class="greenButtonStyle" type="button" value="Pagar" onclick="pagar()" />
							</div>
						<%} else {%>
							<div id="btSave" class="<%=(!isEdition)? "formGreenButton" : "cpEscondeWithHeight"%>">
								<input class="greenButtonStyle" type="button" value="Salvar" onclick="noAccess()" />
							</div>
							<div id="btPag" class="<%=(isEdition && !isQuit)? "formGreenButton" : "cpEscondeWithHeight"%>">
								<input class="greenButtonStyle" type="button" value="Pagar" onclick="noAccess()" />
							</div>
						<%}%>						
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>