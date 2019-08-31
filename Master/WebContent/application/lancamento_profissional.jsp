<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="com.marcsoftware.pageBeans.LancamentoProfissional"%>
<%@page import="com.marcsoftware.database.Profissional"%>
<%@page import="com.marcsoftware.database.EmpresaSaude"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%
	LancamentoProfissional lancamentoProf = null;
	String stack = "";
	try {
		lancamentoProf = new LancamentoProfissional(
				session.getAttribute("perfil").toString(), 
				session.getAttribute("username").toString(), request.getParameter("tp"),
				Long.valueOf(session.getAttribute("acessoId").toString()), request);		
	} catch (Exception e) {
		stack = e.getStackTrace().toString();
	}
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
		
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />	
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>	
	<script type="text/javascript" src="../js/comum/lancamento_profissional.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>	
	
	<title>Master Bordero Profissional</title>
</head>
<body onload="load()">
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="<%= lancamentoProf.getPage() %>"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="<%= lancamentoProf.getPage() %>"/>
		</jsp:include>
		<div id="formStyle">
			<form id="parc" method="get" onsubmit="return search()">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Borderô"/>			
					</jsp:include>
					<div class="topContent">
						<div id="ref" class="textBox" style="width:65px">
							<label>CTR</label><br/>
							<input id="refIn" name="refIn" type="text" style="width: 65px;" value=""/>
						</div>
						<div id="cliente" class="textBox" style="width:250px">
							<label>Titular</label><br/>
							<input id="clienteIn" name="clienteIn" type="text" style="width: 250px;" value=""/>
						</div>
						<div id="dependente" class="textBox" style="width:250px">
							<label>Dependente</label><br/>
							<input id="dependenteIn" name="dependenteIn" type="text" style="width: 250px;" value=""/>
						</div>
						<div id="lancamento" class="textBox" style="width:65px">
							<label>Orçamento</label><br/>
							<input id="orcamentoIn" name="orcamentoIn" type="text" style="width: 65px;" value=""/>
						</div>
						<div id="guia" class="textBox" style="width:65px">
							<label>Guia</label><br/>
							<input id="guiaIn" name="guiaIn" type="text" style="width: 65px;" value=""/>
						</div>
						<div id="profissionalId" class="textBox">
							<label>Profissional</label><br/>
							<select id="profissionalIdIn" name="profissionalIdIn">
								<option value="">Selecione</option>								
								<%if (lancamentoProf != null && lancamentoProf.getUnidadeList().size() == 1) {
									for(Profissional  prof: lancamentoProf.getProfissionalList()) {
										out.print("<option value=\"" + prof.getCodigo() + 
												"\">" + prof.getNome() + "</option>");
									}
								}%>
							</select>
						</div>
						<div id="empresaId" class="textBox">
							<label>Emp. de Saúde</label><br/>
							<select id="empresaIdIn" name="empresaIdIn">
								<option value="">Selecione</option>								
								<%if (lancamentoProf != null && lancamentoProf.getUnidadeList().size() == 1) {
									for(EmpresaSaude  emp: lancamentoProf.getEmpresaList()) {
										out.print("<option value=\"" + emp.getCodigo() + 
												"\">" + Util.initCap(emp.getFantasia()) + "</option>");
									}
								}%>
							</select>
						</div>
						<div id="unidadeId" class="textBox">
							<label>Cod. Un.</label><br/>
							<select id="unidadeIdIn" name="unidadeIdIn">
								<option value="">Selecione</option>
								<%if (lancamentoProf != null && lancamentoProf.getUnidadeList().size() == 1) {
									out.print("<option value=\"" + 
											lancamentoProf.getUnidadeList().get(0).getCodigo() + 
											"\" selected=\"selected\">" + 
											lancamentoProf.getUnidadeList().get(0).getReferencia() + 
											"</option>");
								} else if (lancamentoProf != null) {
									for(Unidade un: lancamentoProf.getUnidadeList()) {
										out.print("<option value=\"" + un.getCodigo() + 
												"\">" + un.getReferencia() + "</option>");
									}									
								}
								%>
							</select>
						</div>
					</div>
				</div>
				<div class="topButtonContent">
					<div class="formGreenButton">
						<input id="buscar" name="insertConta" class="greenButtonStyle" type="submit" value="Buscar"/>								
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">					
						<%if (lancamentoProf != null) {
							DataGrid dataGrid = lancamentoProf.getDataGrid();						
							out.print(dataGrid.getTable(lancamentoProf.getLines()));							
						} else {
							out.print(stack);
						}
						%>
					</div>
					<div id="pagerGrid" class="pagerGrid"></div>				
				</div>				
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
	</div>	
</body>
</html>