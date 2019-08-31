<?xml version="1.0" encoding="ISO-8859-1"?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
pageEncoding="ISO-8859-1"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Transaction"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.FormaPagamento"%>
<%@page import="com.marcsoftware.utilities.Util"%><html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />	
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]--> 
    
    <script type="text/javascript" src="../js/jquery/jquery.js"></script>
  	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_window.js"></script>
	<script type="text/javascript" src="../js/comum/forma_pagamento.js" ></script>
<title>Master Formas de pagamento</title>
</head>
<body onload="load()">
	<!-- <input type="button" value="mostra janela" onclick="mostraJanela()">
	<input type="button" value="esconde janela" onclick="escondeJanela()">	
	<input type="button" value="entra com label" onclick="addLabel()">
	<input type="button" value="muda titulo" onclick="showteste();"> -->
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="financeiro"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="financeiro"/>
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="post" action="../CadastroFormaPagamento">
				<div id="geralDate" class="alignHeader">
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Formas Pagam."/>			
					</jsp:include>
					<div class="topContent">
						<div id="concilia" class="textBox" style="margin-left: 180px;">
							<label>Concilia</label><br/>
							<select type="select-multiple" id="conciliaIn" name="conciliaIn" style="width: 70px">
								<option value="s">Sim</option>
								<option value="n" selected="selected">Não</option>
							</select>
						</div>
						<div id="descricao" class="textBox" style="width: 280px;">
							<label>Descrição</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 280px;"/>
						</div>
						
						<!--  <div id="data" class="textBox" style="width: 90px;">
							<label style="margin-left: 190px;">data</label><br/>
							<input id="dataIn" name="dataIn" type="text" style="width: 90px; margin-left: 190px" onkeydown="mask(this, dateType);"/>
						</div>-->						
					</div>					
				</div>
				<div class="topButtonContent" >
					<div class="formGreenButton">
						<input id="inserir" name="inserir" class="greenButtonStyle" onclick="addRecord();" type="button" value="Inserir"/>
					</div>
				</div>
				<div id="mainContent">
					<div id="dataGrid" style="" >
						<div id="centerGrid" style="min-height: 100px; margin-left: 193px; width: 350px">
							<div id="counter" style="width: 400px; float:left; margin-bottom: 5px" ></div>
							<%
							DataGrid dataGrid= new DataGrid(null);
							Session sess= HibernateUtil.getSession();
							Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
							Transaction transaction = sess.beginTransaction();
							Query query= sess.createQuery("from FormaPagamento as f order by f.codigo");
							int gridLines= query.list().size();
							query.setFirstResult(0);
							query.setMaxResults(10);
							List<FormaPagamento> formaPagamento= (List<FormaPagamento>) query.list();
							dataGrid.addColum("30", "Código");
							dataGrid.addColum("120", "Descrição");
							dataGrid.addColum("10", "Conc.");
							if (formaPagamento != null) {
								for(FormaPagamento fPag: formaPagamento) {
									dataGrid.setId(String.valueOf(fPag.getCodigo()));
									dataGrid.addData(String.valueOf(fPag.getCodigo()));
									dataGrid.addData(Util.initCap(fPag.getDescricao()));
									dataGrid.addData((fPag.getConcilia().trim().equals("s"))? "Sim" : "Não");
									dataGrid.addRow();
								}									
							}							
							out.print(dataGrid.getTable(gridLines));
							transaction.commit();
							sess.close();
							%>						
						</div>
						<div id="pagerGrid" class="pagerGrid" style="width: 500px; margin-right: 280px; margin-bottom: 30px">
						</div>						
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
	</div>		
</body>
</html>