<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@page import="com.marcsoftware.database.Conta"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.database.FaturaEmpresa"%>
<%@page import="com.marcsoftware.database.Conta"%>
<%@page import="org.hibernate.Query"%>

<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.LancamentoFaturaEmp"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="java.util.Date"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	
	<jsp:useBean id="fatura" class="com.marcsoftware.database.FaturaEmpresa"></jsp:useBean>

	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	fatura = (FaturaEmpresa) sess.get(FaturaEmpresa.class, Long.valueOf(request.getParameter("id")));
	Query query = sess.createQuery("select i.descricao from Informacao as i where i.principal = 's' and i.pessoa.codigo = :empresa");
	query.setLong("empresa", fatura.getEmpresa().getCodigo());
	String foneEmpresa = (String) query.uniqueResult();
	query = sess.createQuery("select i.descricao from Informacao as i where i.principal = 's' and i.pessoa.codigo = :unidade");
	query.setLong("unidade", fatura.getEmpresa().getUnidade().getCodigo());
	String foneUnidade = (String) query.uniqueResult();
	 query = sess.createQuery("from Conta as c where c.pessoa = :unidade");
	query.setEntity("unidade", fatura.getEmpresa().getUnidade());
	List<Conta> contas = (List<Conta>) query.list(); 
	
	List<LancamentoFaturaEmp> itens;	
	double vlrTotal;
	boolean isOpen = false;
	Date now = new Date();
	String recebimento = "";
	Date dtPagamento = null;
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />

	<title>Master Cadastro Fatura Empresa</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/comum/cadastro_fatura_empresa.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	
	</head>
<body>
	<div id="boletoWindow" title="Impressão de Faturas e Boletos" style="display: none;">
		<form id="formPagamento" onsubmit="return false;">
			<label for="conta">Conta</label>
			<select id="conta" name="conta" style="width: 100%">
				<% for (Conta conta: contas) {
					out.println("<option value=\"" + conta.getCodigo() + "\">" + 
						conta.getBanco().getDescricao() + " - " + conta.getNumero() + "</option>");
				} %>
			</select><br /><br />
			<label for="getBoleto">Cobrar Boleto</label>
			<select id="getBoleto" name="getBoleto">
				<option value="s">Sim</option>
				<option value="n">Não</option>
			</select><br /><br />
			<label for="dtVencimento">Vencimento para o Agrupamento</label>
			<input type="text" name="dtVencimento" id="dtVencimento" class="textDialog ui-widget-content ui-corner-all" value="<%= Util.parseDate(fatura.getVencimento() , "dd/MM/yyyy")%>" onkeydown="mask(this, dateType)" />
		</form>
	</div>
	<div id="pagWindow" class="removeBorda" title="Pagamento de Fatura" style="display: none;">
		<form id="formPagamento" onsubmit="return false;">
			<fieldset>
				<label for="cupom">Imprimir Cupom</label>
				<div id="paramBoxRd" class="checkRadio ui-corner-all">
					<label class="labelCheck" >Sim</label>
					<input type="radio" id="cupom" name="cupom" value="s"/>
					<label class="labelCheck" >Não</label>
					<input type="radio" id="cupom" name="cupom" value="n" checked="checked" />
				</div>
				<label for="money">Dinheiro</label>
				<input type="text" name="money" id="money" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, decimalNumber)" value="0.00" />
				<label for="dtPagamento">Vencimento</label>
				<input type="text" name="dtPagamento" id="dtPagamento" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, typeDate)" value="<%= Util.getToday() %>" />
				<label for="lancJuros">Lançar Juros</label>
				<div id="paramBoxRd" class="checkRadio ui-corner-all">
					<label class="labelCheck" >Sim</label>
					<input type="radio" id="lancJuros" name="lancJuros" value="s"/>
					<label class="labelCheck" >Não</label>
					<input type="radio" id="lancJuros" name="lancJuros" value="n" checked="checked" />
				</div>
				<label for="tpPagamento">Pagamento</label><br/>
				<select id="tpPagamento" style="width: 100%">
					<option value="n">Manual</option>
					<option value="s">Automático</option>
				</select>
			</fieldset>
		</form>
	</div>
	<div id="faturaWindow" class="removeBorda" title="Impressão de Cupom" style="display: none;">
		<form id="formFatura" onsubmit="return false;">
			<fieldset>
				<p>Digite o valor em dinheiro pago pelo cliente.</p>
				<label for="moneyCupon">Dinheiro</label>
				<input type="text" name="moneyCupon" id="moneyCupon" class="textDialog ui-widget-content ui-corner-all" value="0.00" onkeydown="mask(this, decimalNumber)" />
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="clienteJ"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="clienteJ"/>
		</jsp:include>
		<div id="formStyle">
			<form id="parc" method="get">
				<input type="hidden" name="codJuridico" id="codJuridico" value="<%= fatura.getEmpresa().getCodigo()%>"/>
				<div>
					<input id="faturaId" name="faturaId"  type="hidden" value="<%= fatura.getCodigo() %>"/>
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Fatura"/>			
					</jsp:include>					
					<div id="abaMenu">
						<div class="aba2">
							<a href="cadastro_cliente_juridico.jsp?state=1&id=<%= fatura.getEmpresa().getCodigo() %>">Cadastro</a>
						</div>						
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="#">Anexo</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="cliente_fisico.jsp?&id=<%= fatura.getEmpresa().getCodigo() %>">Funcionários</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="fatura_empresa.jsp?&id=<%= fatura.getEmpresa().getCodigo() %>">Histórico de Faturas</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>						
						<div class="sectedAba2">
							<label>Cadastro de Fatura</label>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>						
						<div class="aba2">
							<a href="bordero_empresa.jsp?&id=<%= fatura.getEmpresa().getCodigo() %>">Borderô</a>
						</div>						
					</div>
					<div class="topContent">
						<div id="fatura" class="textBox" style="width: 55px;">
							<label>Fatura</label><br/>
							<input id="faturaIn" name="faturaIn" type="text" style="width: 55px;" value="<%=fatura.getCodigo()%>" readonly="readonly" />
						</div>
						<div id="refUnidade" class="textBox" style="width: 85px;">
							<label>Cod. Unidade</label><br/>
							<input id="refUnidadeIn" name="refUnidadeIn" type="text" style="width: 85px;" value="<%=fatura.getEmpresa().getUnidade().getReferencia()%>" readonly="readonly" />
						</div>
						<div id="unidade" class="textBox" style="width: 255px;">
							<label>Unidade</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" style="width: 255px;" value="<%=Util.initCap(fatura.getEmpresa().getUnidade().getFantasia())%>" readonly="readonly" />
						</div>
						<div id="telUnidade" class="textBox" style="width: 200px;">
							<label>Contato Unidade</label><br/>
							<input id="telUnidadeIn" name="telUnidadeIn" type="text" style="width: 200px;" value="<%= foneUnidade %>" readonly="readonly" />
						</div>
						<div id="fantasia" class="textBox" style="width: 240px;">
							<label>Empresa</label><br/>
							<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 240px;" value="<%=Util.initCap(fatura.getEmpresa().getFantasia())%>" readonly="readonly" />
						</div>
						<div id="cnpj" class="textBox" style="width: 120px;">
							<label>CNPJ</label><br/>
							<input id="cnpjIn" name="cnpjIn" type="text" style="width: 120px;" value="<%=Util.mountCnpj(fatura.getEmpresa().getCnpj())%>" readonly="readonly" />
						</div>
						<div id="contato" class="textBox" style="width: 250px;">
							<label>Contato</label><br/>
							<input id="contatoIn" name="contatoIn" type="text" style="width: 250px;" value="<%=Util.initCap(fatura.getEmpresa().getContato())%>" readonly="readonly" />
						</div>
						<div id="informacao" class="textBox" style="width: 310px;">
							<label>Contato Empresa</label><br/>
							<input id="informacaoIn" name="informacaoIn" type="text" style="width: 310px;" value="<%= foneEmpresa %>" readonly="readonly" />
						</div>
						<div id="vencimento" class="textBox" style="width: 90px;">
							<label>Vencimento</label><br/>
							<input id="vencimentoIn" name="vencimentoIn" type="text" style="width: 90px;" value="<%=Util.parseDate(fatura.getVencimento() , "dd/MM/yyyy")%>" readonly="readonly" />
						</div>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%query = sess.createQuery("from LancamentoFaturaEmp as l where l.id.faturaEmpresa = :fatura");
						query.setEntity("fatura", fatura);
						itens = (List<LancamentoFaturaEmp>) query.list();
						int gridLines = itens.size();
						DataGrid dataGrid = new DataGrid("#");
						dataGrid.addColum("10", "Lanç.");
						dataGrid.addColum("30", "Documento");
						dataGrid.addColum("30", "Descricao");
						dataGrid.addColum("10", "Emissão");
						dataGrid.addColum("10", "Vencimento");
						dataGrid.addColum("10", "valor");
						vlrTotal = 0;						
						for(LancamentoFaturaEmp lanc: itens) {
							dataGrid.setId(String.valueOf(lanc.getId().getLancamento().getCodigo()));							
							dataGrid.addData("cod_lanc", String.valueOf(lanc.getId().getLancamento().getCodigo()));
							dataGrid.addData((lanc.getId().getLancamento().getDocumento() == null) ? "" :
								lanc.getId().getLancamento().getDocumento());
							dataGrid.addData(lanc.getId().getLancamento().getConta().getDescricao());
							dataGrid.addData(Util.parseDate(lanc.getId().getLancamento().getEmissao(), "dd/MM/yyyy"));
							dataGrid.addData(Util.parseDate(lanc.getId().getLancamento().getVencimento(), "dd/MM/yyyy"));
							dataGrid.addData(Util.formatCurrency(lanc.getId().getLancamento().getValor()));
							/*dataGrid.addData(Util.formatCurrency(
									Util.calculaAtraso(lanc.getId().getLancamento().getValor(),
									lanc.getId().getLancamento().getTaxa(), lanc.getId().getFaturaEmpresa().getVencimento())));*/
							vlrTotal += lanc.getId().getLancamento().getValor();							
							if (! isOpen) {
								if (lanc.getId().getLancamento().getStatus().trim().equals("a")) {
									isOpen = true;									
								}
								if (recebimento.equals("")) {
									recebimento = lanc.getId().getLancamento().getRecebimento();
								}
								if(dtPagamento == null) {
									dtPagamento = lanc.getId().getLancamento().getDataQuitacao();
								}
							}
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));
						%>
					</div>
					<div class="totalizadorRight">
						<label id="labelTotal" class="titleCounter" >Total a Pagar:</label>
						<label id="total" name="total" style="margin-right: 80px"><%=Util.formatCurrency(vlrTotal) %></label>
					</div>
					<div class="buttonContent">
						<div class="formGreenButton">
							<input  class="greenButtonStyle" type="button" value="Excluir" onclick="excluiFatura(<%= fatura.getEmpresa().getCodigo() %>, <%= fatura.getCodigo() %>)" />
						</div>
						<div id="btGere" class="formGreenButton">
							<input id="gradorPdf" name="gradorPdf" class="greenButtonStyle" type="button" value="Imprimir" onclick="pdfGenerate()" />
						</div>
						<div id="btGere" class="formGreenButton">
							<input id="gradorBoleto" name="gradorBoleto" class="greenButtonStyle" type="button" value="Gerar Boleto" onclick="emitBoleto()" />
						</div>
						<%if (isOpen) {%>							
							<%if (session.getAttribute("caixaOpen").toString().trim().equals("t")) {%>
								<div id="btGere" class="formGreenButton">
									<input  class="greenButtonStyle" type="button" value="Emit. Cupom" onclick="getErro('0')" />
								</div>
								<div id="btGere" class="formGreenButton">
									<input id="pagBt" name="pagBt" class="greenButtonStyle" type="button" value="Pagar" onclick="pagueFaura()" />
								</div>
							<%} else {%>
								<div id="btGere" class="formGreenButton">
									<input  class="greenButtonStyle" type="button" value="Emit. Cupom" onclick="noAccess()" />
								</div>
								<div id="btGere" class="formGreenButton">
									<input id="pagBt" name="pagBt" class="greenButtonStyle" type="button" value="Pagar" onclick="noAccess()" />
								</div>
							<%}
						} else {
							if (Util.removeDays(now, 1).after(dtPagamento)  && 
									!(session.getAttribute("perfil").toString().equals("a")
											|| session.getAttribute("perfil").toString().equals("d")
											|| session.getAttribute("perfil").toString().equals("f"))) {%>
								<div id="btGere" class="formGreenButton">
									<input  class="greenButtonStyle" type="button" value="Emit. Cupom" onclick="getErro('2')" />
								</div>
							<%} else if (!session.getAttribute("username").toString().equals(recebimento)
									&& !(session.getAttribute("perfil").toString().equals("a")
											|| session.getAttribute("perfil").toString().equals("d")
											|| session.getAttribute("perfil").toString().equals("f"))) {%>
								<div id="btGere" class="formGreenButton">
									<input  class="greenButtonStyle" type="button" value="Emit. Cupom" onclick="getErro('1')" />
								</div>
							<%} else {%>
								<div id="btGere" class="formGreenButton">
									<input  class="greenButtonStyle" type="button" value="Emit. Cupom" onclick="emitCupom()" />
								</div>
							<%}
						}%>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>