<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>
<%@page import="com.marcsoftware.utilities.Util"%>
<html xmlns="http://www.w3.org/1999/xhtml">
	<%Util.historico(null, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Baixa Manual</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/validation.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/comum/baixa_manual.js" ></script>
	<script type="text/javascript" src="../js/lib/pilot_grid.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="clienteF"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="clienteF"/>			
		</jsp:include>
		<div id="formStyle">
			<form id="parc" method="get" onsubmit="return addRowDoc();">
				<div id="localDocumento"></div>				
				<div id="deletedsDocumento"></div>				
				<div id="editedsDocumento"></div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Baixa Manual"/>			
					</jsp:include>
					<div class="topContent">
						<div id="codigo" class="textBox" style="width: 70px;">
							<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 70px;" onkeydown="mask(this, onlyInteger)"/>
						</div>
					</div>					
				</div>
				<div class="topButtonContent">					
					<div class="formGreenButton">
						<input id="buscar" name="buscar" class="greenButtonStyle" type="button" value="Inserir" onclick="addRowDoc()"/>
					</div>
				</div>
				<div id="mainContent">					
					<div id="itensOrcamento" class="bigBox" >
						<div class="indexTitle">
							<h4>Boletos</h4>
							<div class="alignLine">
								<hr>
							</div>
							<div id="tableBoleto" style="width: 928px"></div>
						</div>						
					</div>
					<div class="buttonContent">
						<%if (session.getAttribute("caixaOpen").toString().trim().equals("t")) {%>					
							<div class="formGreenButton">
								<input id="baixa" name="baixa" class="greenButtonStyle" type="button" value="Dar Baixa" onclick="baixar()"/>
							</div>
						<%} else {%>
							<div class="formGreenButton">
								<input id="baixa" name="baixa" class="greenButtonStyle" type="button" value="Dar Baixa" onclick="noAccess()"/>
							</div>
						<%}%>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
	</div>
</body>
</html>