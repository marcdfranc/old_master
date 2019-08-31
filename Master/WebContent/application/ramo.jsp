<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Ramo"%>
<%@page import="com.marcsoftware.utilities.Util"%><html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/comum/ramo.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_window.js"></script>
	
	<title>Master Ramos</title>
</head>
<body onload="load()">
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="clienteJ"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="clienteJ"/>
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="post" action="../CadastroPosicao">
				<div id="geralDate" class="alignHeader">
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Ramos"/>			
					</jsp:include>
					<div class="topContent">
						<div id="descricao" class="textBox" style="width: 280px;">
							<label style="margin-left: 190px;">Descrição</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 280px; margin-left: 190px" class="required" />
						</div>					
					</div>					
				</div>
				<div class="topButtonContent" >
					<div class="formGreenButton">
						<input id="inserir" name="inserir" class="greenButtonStyle" onclick="addRecord();" type="button" value="Inserir"/>
					</div>
				</div>
				<div id="mainContent">				
					<div id="dataGrid" style="" >
						<div id="centerGrid" style="min-height: 100px; margin-left: 100px; width: 550px">
							<div id="counter" style="width: 700px; float:left; margin-bottom: 5px" ></div>
							<%
							DataGrid dataGrid= new DataGrid(null);
							Session sess = (Session) session.getAttribute("hb");
							Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
							if (!sess.isOpen()) {
								sess = HibernateUtil.getSession();
							}
							Query query= sess.createQuery("from Ramo as r order by r.codigo");
							int gridLines= query.list().size();
							query.setFirstResult(0);
							query.setMaxResults(10);							 
							List<Ramo> ramo= (List<Ramo>) query.list();
							dataGrid.addColum("10", "Código");
							dataGrid.addColum("120", "Descrição");
							if (ramo != null) {
								for(Ramo rm: ramo) {
									dataGrid.setId(String.valueOf(rm.getCodigo()));
									dataGrid.addData(String.valueOf(rm.getCodigo()));
									dataGrid.addData(Util.initCap(rm.getDescricao()));
									dataGrid.addRow();
								}
							}
							out.print(dataGrid.getTable(gridLines));
							sess.close();
							%>
						</div>
						<div id="pagerGrid" class="pagerGrid" style="width: 500px; margin-right: 280px; margin-bottom: 30px"></div>						
					</div>					
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
	</div>
</body>
</html>