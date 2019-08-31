<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Fornecedor"%>
<%@page import="com.marcsoftware.database.PrestadorServico"%>
<%@page import="com.marcsoftware.database.Compra"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.ParcelaCompra"%>
<%@page import="com.marcsoftware.database.FormaPagamento"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="java.util.Date"%><html xmlns="http://www.w3.org/1999/xhtml">
	
	<%!boolean isJuridica;%>
	<% isJuridica = request.getParameter("origem").equals("forn");
	boolean haveParcela = false;	
	Fornecedor fornecedor = null;
	PrestadorServico prestadorServico = null;	
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Compra compra = (Compra) sess.get(Compra.class, Long.valueOf(request.getParameter("id")));
	Query query = sess.createQuery("select descricao from Informacao as i where i.pessoa = :pessoa and i.principal = 's'");
	if (isJuridica) {
		fornecedor = (Fornecedor) sess.get(Fornecedor.class, compra.getFornecedor().getCodigo()); 
		query.setEntity("pessoa", fornecedor);
	} else {
		prestadorServico = (PrestadorServico) sess.get(PrestadorServico.class, compra.getFornecedor().getCodigo());
		query.setEntity("pessoa", prestadorServico);
	}
	String infoFornecedor = query.uniqueResult().toString();
	query = sess.createQuery("from ParcelaCompra as p where p.id.compra = :compra");
	query.setEntity("compra", compra);
	List<ParcelaCompra> parcelaList = (List<ParcelaCompra>) query.list();
	String documento = "";
	double vlrAtraso;
	int countAtraso;
	double vlrParcelamento = 0;
	if (parcelaList.size() > 0) {
		documento = parcelaList.get(0).getId().getLancamento().getDocumento();
		for(ParcelaCompra parcela: parcelaList) {
			vlrParcelamento+= parcela.getId().getLancamento().getValor();
		}
	} else {
		query = sess.createSQLQuery("SELECT SUM(custo * quantidade) FROM itens_compra " + 
				" WHERE cod_compra = :compra");
		query.setLong("compra", compra.getCodigo());
		vlrParcelamento = Double.parseDouble(query.uniqueResult().toString());
	}
	query = sess.createQuery("from FormaPagamento as f order by f.descricao");
	List<FormaPagamento> pagamentoList = (List<FormaPagamento>) query.list();
	%>

<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Parcelamaento de Pedido</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>	
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/comum/parcela_compra.js" ></script>	
</head>
<body onload="load()">
	<div id="conciliaWindow" class="removeBorda" title="Pagamento de Mensalidade" style="display: none;">			
		<form id="formPagamento" onsubmit="return false;">
			<fieldset>
				<label for="tpPagamento">Pagamento</label><br/>
				<select id="tpPagamento" style="width: 100%" onchange="adjustPagamento(this)">
					<%if (pagamentoList.size() > 0) {
						for(FormaPagamento pagamento : pagamentoList) {
							if (pagamento.getCodigo() == new Long(2)) {%>
								<option value="<%= pagamento.getCodigo() + "@" + pagamento.getConcilia()%>" selected="selected" ><%= pagamento.getDescricao()%> </option>
							<%} else {%>
								<option value="<%= pagamento.getCodigo() + "@" + pagamento.getConcilia()%>" ><%= pagamento.getDescricao()%> </option>
							<%}%>
						<%}						
					} else {%>
						<option value="">Selecione</option>
					<%}%>
				</select><br/>
				<label for="numConcilio">Nº de controle</label>
				<input type="text" name="numConcilio" id="numConcilio" class="textDialog ui-widget-content ui-corner-all" readonly="readonly" />
				<label for="dtEmit">Emissão</label>
				<input type="text" name="dtEmit" id="dtEmit" class="textDialog ui-widget-content ui-corner-all" value="<%= Util.getToday() %>" onkeydown="mask(this, onlyDate);" />
				<label for="dtVenc">Vencimento</label>
				<input type="text" name="dtVenc" id="dtVenc" class="textDialog ui-widget-content ui-corner-all" readonly="readonly" onkeydown="mask(this, onlyDate);"/>
				<label for="vlrTotal">Valor Atual</label>
				<input type="text" name="vlrTotal" id="vlrTotal" class="textDialog ui-widget-content ui-corner-all" readonly="readonly" />
				<label for="aPagar">Valor a Pagar</label>
				<input type="text" name="aPagar" id="aPagar" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, decimalNumber);"/>
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>	
	<%if (isJuridica) {%>
		<jsp:include page="../inc/menu.jsp">
			<jsp:param name="currentPage" value="fornecedor"/>
		</jsp:include>	
	<%} else {%>
		<jsp:include page="../inc/menu.jsp">
			<jsp:param name="currentPage" value="prestador"/>
		</jsp:include>
	<%}%>	
	<div id="centerAll">
		<%if (isJuridica) {%>
			<jsp:include page="../inc/submenu.jsp">
				<jsp:param name="currentPage" value="fornecedor"/>
			</jsp:include>
		<%} else {%>
			<jsp:include page="../inc/submenu.jsp">
				<jsp:param name="currentPage" value="prestador"/>
			</jsp:include>
		<%}%>
		<div id="formStyle">
			<form id="unit" method="post" action="../CadastroPosicao">
				<input type="hidden" name="origem" id="origem" value="<%= request.getParameter("origem") %>" />
				<div id="geralDate" class="alignHeader">
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Parcelamento"/>			
					</jsp:include>
					<%if (isJuridica) {%>
						<div id="abaMenu">
							<div class="aba2">
								<a href="<%="cadastro_fornecedor.jsp?state=1&id=" + fornecedor.getCodigo() %>">Cadastro</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="bordero_fornecedor.jsp?origem=forn&idFornecedor=<%= fornecedor.getCodigo()%>">Borderô</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>							
							<div class="aba2">
								<a href="pedido.jsp?origem=forn&idFornecedor=<%= fornecedor.getCodigo()%>">Gerar Pedido</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>							
							<div class="aba2">
								<a href="compra.jsp?origem=forn&idFornecedor=<%= fornecedor.getCodigo()%>">Histórico de Pedidos</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="agrupamento.jsp?origem=forn&idFornecedor=<%= fornecedor.getCodigo()%>">Histórico de Faturas</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="pedido.jsp?origem=forn&state=1&id=<%= compra.getCodigo()%>">Pedido</a>
							</div>							
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="sectedAba2">
								<label>Parcelamento</label>
							</div>
						</div>
					<%} else {%>
						<div id="abaMenu">
							<div class="aba2">
								<a href="<%="cadastro_prestador_servico.jsp?state=1&id=" + prestadorServico.getCodigo()%>">Cadastro</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="bordero_fornecedor.jsp?origem=prest&idFornecedor=<%= prestadorServico.getCodigo()%>">Borderô</a>
							</div>
							<div class="sectedAba2">
								<label>></label>
							</div>
							<div class="aba2">
								<a href="pedido.jsp?origem=prest&idFornecedor=<%= prestadorServico.getCodigo()%>">Gerar Pedido</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>					
							<div class="aba2">
								<a href="compra.jsp?origem=prest&idFornecedor=<%= prestadorServico.getCodigo()%>">Histórico de Pedidos</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="agrupamento.jsp?origem=prest&idFornecedor=<%= prestadorServico.getCodigo()%>">Histórico de Faturas</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="pedido.jsp?origem=prest&state=1&id=<%= compra.getCodigo()%>">Pedido</a>
							</div>							
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="sectedAba2">
								<label>Parcelamento</label>
							</div>
						</div>
					<%}%>
					<%if (isJuridica) {%>
						<div class="topContent">
							<div id="idFornecedor" class="textBox" style="width: 70px;" >
								<label>Código</label><br/>
								<input id="idFornecedorIn" name="idFornecedorIn" type="text" style="width: 70px;" readonly="readonly" value="<%= fornecedor.getCodigo()%>" />
							</div>
							<div id="rzSocial" class="textBox" style="width: 260px;" >
								<label>Razão Social</label><br/>
								<input id="rzSocialIn" name="rzSocialIn" type="text" style="width: 260px;" readonly="readonly" value="<%= fornecedor.getRazaoSocial() %>" />
							</div>
							<div id="fantasia" class="textBox" style="width: 260px">
								<label>Fantasia</label><br/>					
								<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 260px" value="<%=Util.initCap(fornecedor.getFantasia())%>" readonly="readonly" />
							</div>
							<div id="cnpj" class="textBox" style="width: 130px">
								<label>Cnpj</label><br/>					
								<input id="cnpjIn" name="cnpjIn" type="text" style="width: 130px" class="required" value="<%=Util.mountCnpj(fornecedor.getCnpj())%>" readonly="readonly" />
							</div>
							<div id="infoFornecedor" class="textBox" style="width: 130px">
								<label>Contato</label><br/>					
								<input id="infoFornecedorIn" name="infoFornecedorIn" type="text" style="width: 130px" class="required" value="<%=infoFornecedor%>" readonly="readonly" />
							</div>
							<div id="ramo" class="textBox" style="width: 330px">
								<label>Ramo</label><br/>					
								<input id="ramoIn" name="ramoIn" type="text" style="width: 330px" value="<%=Util.initCap(fornecedor.getRamo().getDescricao())%>" readonly="readonly" />
							</div>
							<div id="nomeContato" class="textBox" style="width: 245px;">
								<label>Nome do Contato</label><br/>					
								<input id="nomeContatoIn" name="nomeContatoIn" type="text" style="width: 245px" value="<%=Util.initCap(fornecedor.getContato())%>" readonly="readonly" />
							</div>
							<div id="cargoContato" class="textBox" style="width: 265px">
								<label>Cargo do Contato</label><br/>					
								<input id="cargoContatoIn" name="cargoContatoIn" type="text" style="width: 265px" value="<%= fornecedor.getCargoContato()%>" readonly="readonly" />
							</div>
						</div>
					<%} else {%>
						<div class="topContent">
							<div id="codigo" class="textBox" style="width: 80px;">
								<label>Código</label><br/>
								<input id="idFornecedorIn" name="idFornecedorIn" type="text" style="width: 80px;" value="<%= prestadorServico.getCodigo() %>" class="required" readonly="readonly"/>
							</div>
							<div id="nome" class="textBox" style="width: 260px;">
								<label>Nome</label><br/>
								<input id="nomeIn" name="nomeIn" type="text" style="width: 260px;" value="<%=Util.initCap(prestadorServico.getNome())%>"  readonly="readonly" />
							</div>
							<div id="sexo" class="textBox" style="width: 70px;">
								<label>Sexo</label><br/>
								<input id="sexoIn" name="sexoIn" type="text" style="width: 70px;" value="<%= (prestadorServico.getSexo().equals("f"))? "Feminino" : "Masculino" %>"  readonly="readonly" />
							</div>						
							<div id="cpf" class="textBox" style="width: 105px;">
								<label>Cpf</label><br/>
								<input id="cpfIn" name="cpfIn" type="text" style="width: 100px" value="<%=Util.mountCpf(prestadorServico.getCpf())%>" readonly="readonly" />
							</div>
							<div id="rg" class="textBox" style="width: 90px">
								<label>Rg</label><br/>
								<input id="rgIn" name="rgIn" type="text" style="width: 90px" value="<%= prestadorServico.getRg()%>" readonly="readonly"/>
							</div>
							<div id="nascimento" class="textBox" style="width: 73px;">
								<label>Nascimento</label><br/>
								<input id="nascimentoIn" name="nascimentoIn" type="text" style="width: 73px;" value="<%= Util.parseDate(prestadorServico.getNascimento(), "dd/MM/yyyy")%>" readonly="readonly"/>
							</div>
							<div class="textBox" style="width: 80px">
								<label>Estado Cívil</label><br/>
								<input type="text" id="estadoCivilIn" name="estadoCivilIn" value="<%
									switch (prestadorServico.getEstadoCivil().charAt(0)) {
										case 'c':
											out.print("Casado(a)");
											break;
										case 's':
											out.print("Solteiro(a)");
											break;
										case 'o':
											out.print("Outro");
											break;
									}%>" style="width: 80px" />
								
							</div>
							<div id="nacionalidade" class="textBox" style="width:213px">
								<label>Nacionalidade</label><br/>
								<input id="nacionalidadeIn" name="nacionalidadeIn" type="text" style="width:213px" value="<%=Util.initCap(prestadorServico.getNacionalidade())%>" readonly="readonly" />
							</div>
							<div id="naturalidade" class="textBox" style="width:213px;">
								<label>Naturalidade</label><br/>
								<input id="naturalidadeIn" name="naturalidadeIn" type="text" style="width:213px" value="<%= Util.initCap(prestadorServico.getNaturalidade())%>" readonly="readonly" />
							</div>
							<div id="naturalUf" class="textBox" style="width: 25px">
								<label>Uf</label><br/>							
								<input id="ufIn" name="ufIn" type="text" style="width:25px" value="<%= prestadorServico.getNaturalidadeUf().toUpperCase() %>" readonly="readonly" />
							</div>
						</div>
					<%}%>				
				</div>
				<div id="mainContent">
					<div id="dadosPed" class="bigBox" >
						<div class="indexTitle">
							<h4>Dados do Pedido</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div id="pedido" class="textBox" style="width:90px">
							<label>Cód. Pedido</label><br/>
							<input id="pedidoIn" name="pedidoIn" type="text" style="width: 90px;" value="<%= compra.getCodigo() %>" readonly="readonly"/>
						</div>
						<div id="cadastro" class="textBox" style="width: 73px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" type="text" style="width: 73px;" value="<%= Util.parseDate(compra.getCadastro(), "dd/MM/yyyy") %>" readonly="readonly" />
						</div>
						<div id="documento" class="textBox" style="width:200px">
							<label>Documento</label><br/>
							<input id="documentoIn" name="documentoIn" type="text" style="width: 200px;" readonly="readonly" value="<%= documento %>" />
						</div>
						<div id="qtdeParc" class="textBox" style="width:70px">
							<label>Parcelas</label><br/>
							<input id="qtdeParcIn" name="qtdeParcIn" type="text" style="width: 70px;" readonly="readonly" value="<%= parcelaList.size() %>" />
						</div>
						<div id="vlrParc" class="textBox" style="width:120px">
							<label>Vlr. Total</label><br/>
							<input id="vlrParcIn" name="vlrParcIn" type="text" style="width: 120px;" readonly="readonly" value="<%= Util.formatCurrency(vlrParcelamento) %>" />
						</div>
						<div class="area" id="obs" name="obs" style="margin-bottom: 30px">
							<label>Observações</label><br/>
							<textarea cols="112"  rows="5" id="obsIn" name="obsIn" id="obsIn" readonly="readonly" ><%= (compra.getObservacao()== null)? "" : compra.getObservacao() %></textarea>								
						</div>
					</div>
					<div class="buttonContent" style="margin-bottom: 15px" >
						<div class="formGreenButton"  >
							<input disabled="disabled" class="grayButtonStyle" type="button" value="Salvar" onclick="sendObs()" />
						</div>							
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Editar Obs" onclick="makeObs()" />
						</div>
					</div>					
					<div id="dataGrid">
						<%int gridLines = parcelaList.size();
						DataGrid dataGrid = new DataGrid(null);
						dataGrid.addColum("10", "Parcela");
						dataGrid.addColum("15", "Vencimento");
						dataGrid.addColum("15", "Dt. Pagamento");
						dataGrid.addColum("15", "Usuário");
						dataGrid.addColum("20", "Valor Nominal");
						dataGrid.addColum("20", "Valor Pago");
						dataGrid.addColum("3", "St");
						dataGrid.addColum("2", "Ck");
						vlrAtraso = 0;
						countAtraso = 0;
						Date now = new Date();
						for(int i = 0; i < gridLines; i++) {
							dataGrid.setId(String.valueOf(i));
							dataGrid.addData("parcela", 
								String.valueOf(parcelaList.get(i).getId().getLancamento().getCodigo()), true);
							dataGrid.addData("vencimento", 
								Util.parseDate(parcelaList.get(i).getId().getLancamento().getVencimento(), "dd/MM/yyyy"), true);
							dataGrid.addData("quitacao", 
								(parcelaList.get(i).getId().getLancamento().getDataQuitacao() == null) ?
								"----------" : Util.parseDate(parcelaList.get(i).getId().getLancamento().getDataQuitacao(), "dd/MM/yyyy"), true);
							dataGrid.addData("recebimento", 
								(parcelaList.get(i).getId().getLancamento().getRecebimento() == null) ?
								"----------" : parcelaList.get(i).getId().getLancamento().getRecebimento(), true);
							dataGrid.addData("nominal",
								Util.formatCurrency(parcelaList.get(i).getId().getLancamento().getValor()), true);
							dataGrid.addData("vlrPago", 
								Util.formatCurrency(parcelaList.get(i).getId().getLancamento().getValorPago()), true);
							dataGrid.addImg(Util.getIcon(parcelaList.get(i).getId().getLancamento().getVencimento(),
									parcelaList.get(i).getId().getLancamento().getStatus()), "parcStatus");
							dataGrid.addCheck(true);
							if((parcelaList.get(i).getId().getLancamento().getStatus().equals("a")
									|| parcelaList.get(i).getId().getLancamento().getStatus().equals("n"))
									&& parcelaList.get(i).getId().getLancamento().getVencimento().before(now)) {
								vlrAtraso+= parcelaList.get(i).getId().getLancamento().getValor();
								countAtraso++;
							}
							dataGrid.addRow();
						}
						dataGrid.addTotalizador("Total Atraso", Util.formatCurrency(vlrAtraso), "atrasoTot", true);
						dataGrid.addTotalizador("Parcelas em Atraso", String.valueOf(countAtraso), "countAtraso", false);
						dataGrid.makeTotalizador();
						dataGrid.addTotalizadorRight("Total", "0.00", "totalSoma");
						dataGrid.makeTotalizadorRight();
						out.print(dataGrid.getTable(gridLines));
						%>				
					</div>
					<div class="buttonContent">
						<%if (session.getAttribute("caixaOpen").toString().trim().equals("t")) {%>
							<div class="formGreenButton" >
								<input id="selecAll" name="selecAll" class="greenButtonStyle" type="button" value="Todos" onclick="selectAll()"/>
							</div>
							<div class="formGreenButton">
								<input id="concilio" name="concilio" class="greenButtonStyle" type="button" value="Pagar" onclick="pagConcilia()" />
							</div>
							<div class="formGreenButton" >
								<input id="estorno" name="estorno" class="greenButtonStyle" type="button" value="Estornar" onclick="estorne()" />
							</div>
							<div class="formGreenButton" >
								<input id="cancelRenegocio" name="cancelRenegocio" class="greenButtonStyle" type="button" value="Cancelar" onclick="cancelParc()"/>
							</div>
						<%} else { %>
							<div class="formGreenButton" >
								<input id="selecAll" name="selecAll" class="greenButtonStyle" type="button" value="Todos" onclick="selectAll()"/>
							</div>
							<div class="formGreenButton">
								<input id="concilio" name="concilio" class="greenButtonStyle" type="button" value="Pagar" onclick="noAccess()" />
							</div>
							<div class="formGreenButton" >
								<input id="estorno" name="estorno" class="greenButtonStyle" type="button" value="Estornar" onclick="noAccess()" />
							</div>
							<div class="formGreenButton" >
								<input id="cancelRenegocio" name="cancelRenegocio" class="greenButtonStyle" type="button" value="Cancelar" onclick="cancelParc()"/>
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