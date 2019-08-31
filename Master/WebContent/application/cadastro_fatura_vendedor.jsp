<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.ItensVendedor"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Contrato"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query = sess.createQuery("from ItensVendedor as i where i.id.faturaVendedor.codigo = :fatura");
	query.setLong("fatura", Long.valueOf(request.getParameter("id")));
	List<ItensVendedor> itensVendedorList = (List<ItensVendedor>) query.list();
	double vlrTotal = 0;
	boolean isQuit = itensVendedorList.get(0).getId().getContrato().getLancamento().getStatus().equals("q"); 
	%>

<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->

	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Cadastro de Faturas de Vendedores</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/comum/cadastro_fatura_vendedor.js" ></script>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="rh"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="rh"/>
		</jsp:include>
		<div id="formStyle">
			<form id="orc" method="post" action="../CadastroFaturaVendedor"  >
				<div>
					<input id="faturaId" name="faturaId" type="hidden" value="<%= itensVendedorList.get(0).getId().getFaturaVendedor().getCodigo() %>"/>
				</div>				
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Fatura"/>			
					</jsp:include>
					<input id="idFatura" name="idFatura" type="hidden" value="<%= itensVendedorList.get(0).getId().getFaturaVendedor().getCodigo() %>"/>
					<div id="abaMenu">
						<div class="aba2">
							<a href="cadastro_funcionario.jsp?state=1&id=<%= itensVendedorList.get(0).getId().getContrato().getFuncionario().getCodigo()%>">Cadastro</a>
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
							<a href="requisicao_contrato.jsp?id=<%= itensVendedorList.get(0).getId().getContrato().getFuncionario().getCodigo()%>">Requisição</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="contrato.jsp?state=1&id=<%= itensVendedorList.get(0).getId().getContrato().getFuncionario().getCodigo()%>">Contratos</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="bordero_funcionario.jsp?id=<%= itensVendedorList.get(0).getId().getContrato().getFuncionario().getCodigo()%>">Borderô</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="fatura_vendedor.jsp?id=<%= itensVendedorList.get(0).getId().getContrato().getFuncionario().getCodigo()%>">Histórico de Faturas</a>
						</div>					
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Cadastro de Fatura</label>
						</div>
					</div>
					<div class="topContent">
						<div class="textBox" id="Numero" name="Numero" style="width: 50px;">
							<label>Numero</label><br/>
							<input id="numeroIn" name="numeroIn" type="text" style="width:50px" readonly="readonly" value="<%= itensVendedorList.get(0).getId().getFaturaVendedor().getCodigo() %>"/>
						</div>
						<div class="textBox" id="cadastro" name="cadastro" style="width: 73px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" type="text" style="width:73px" readonly="readonly" value="<%=Util.parseDate(itensVendedorList.get(0).getId().getFaturaVendedor().getCadastro(), "dd/MM/yyyy") %>"/>
						</div>
						<div class="textBox" id="funcionario" name="funcionario" style="width: 300px;">
							<label>Funcionario</label><br/>
							<input id="funcionarioIn" name="funcionarioIn" type="text" style="width:300px" readonly="readonly" value="<%= itensVendedorList.get(0).getId().getContrato().getFuncionario().getNome() %>"/>
						</div>
						<div class="textBox" id="inicio" name="inicio" style="width: 73px;">
							<label>Início</label><br/>
							<input id="inicioIn" name="inicioIn" type="text" style="width:73px" readonly="readonly" value="<%=Util.parseDate(itensVendedorList.get(0).getId().getFaturaVendedor().getInicio(), "dd/MM/yyyy") %>"/>
						</div>
						<div class="textBox" id="fim" name="fim" style="width: 73px;">
							<label>Fim</label><br/>
							<input id="fimIn" name="fimIn" type="text" style="width:73px" readonly="readonly" value="<%=Util.parseDate(itensVendedorList.get(0).getId().getFaturaVendedor().getFim(), "dd/MM/yyyy") %>"/>
						</div>
					</div>					
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<% DataGrid dataGrid = new DataGrid("#");
						int gridLines = itensVendedorList.size();						
						dataGrid.addColum("5", "CTR");
						dataGrid.addColum("10", "Requisição");
						dataGrid.addColum("10", "Ref. Func.");
						dataGrid.addColum("35", "Nome");
						dataGrid.addColum("10", "Lanç.");						
						dataGrid.addColum("10", "Emissão");
						dataGrid.addColum("10", "valor");
						for(ItensVendedor itens: itensVendedorList) {
							dataGrid.setId(String.valueOf(itens.getId().getContrato().getCodigo()));							
							dataGrid.addData(Util.zeroToLeft((itens.getId().getContrato().getCtr()), 4));
							dataGrid.addData(Util.parseDate(itens.getId().getContrato().getRequisicao(), "dd/MM/yyyy"));
							dataGrid.addData(itens.getId().getContrato().getFuncionario().getReferencia());
							dataGrid.addData(itens.getId().getContrato().getFuncionario().getNome());
							dataGrid.addData(String.valueOf(itens.getId().getContrato().getLancamento().getCodigo()));
							dataGrid.addData(Util.parseDate(itens.getId().getContrato().getLancamento().getEmissao(), "dd/MM/yyyy"));
							dataGrid.addData(Util.formatCurrency(itens.getId().getContrato().getLancamento().getValor()));
							vlrTotal += itens.getId().getContrato().getLancamento().getValor(); 
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
						<%if (isQuit) {%>
							<div id="btGere" class="formGreenButton">
								<input id="pagBt" name="pagBt" class="greenButtonStyle" type="button" value="Imprimir" onclick="pdfGenerate()" />
							</div>
						<%} else {%>
							<div id="btGere" class="formGreenButton">
								<input class="greenButtonStyle" type="submit" value="Pagar" />
								<% if (session.getAttribute("perfil").equals("f")) { %>
									<input class="greenButtonStyle" type="button" value="Excluir" onclick="reproc()" />
								<%} %>
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