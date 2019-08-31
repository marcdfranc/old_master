<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Relatorio"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%><html xmlns="http://www.w3.org/1999/xhtml">	
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/comum/relatorio.js" ></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	
<title>Master Relatórios</title>
</head>
<body onload="load();">
	<%@ include file="../inc/header.jsp" %>	
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="rel"/>
	</jsp:include>	
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="rel"/>			
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="get" onsubmit="return search()">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Relatório"/>			
					</jsp:include>
					<div class="topContent">
						<div id="codigo" class="textBox" style="width: 75px;" >
							<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 75px;"/>
						</div>
						<div id="nome" class="textBox" style="width: 200px;" >
							<label>Nome</label><br/>
							<input id="nomeIn" name="nomeIn" type="text" style="width: 200px;"/>
						</div>
						<div id="nome" class="textBox" style="width: 200px;" >
							<label>Tela</label><br/>
							<input id="telaIn" name="telaIn" type="text" style="width: 200px;"/>
						</div>
						<div class="textBox">
							<label>Dinâmico</label><br/>
							<select id="dinamicoIn" name="dinamicoIn">																
								<option value="">Selecione</option>
								<option value="t">Sim</option>
								<option value="n">Não</option>
							</select>
						</div>
						<div class="textBox" style="width: 505px">
							<label>Tipo</label><br/>
							<select id="tipoIn" name="tipoIn">																
								<option value="">Selecione</option>
								<option value="j">Jasper</option>
								<option value="b">Birt</option>
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
					<div id="dataGrid" >
						<%Session sess = (Session) session.getAttribute("hb");
						if (!sess.isOpen()) {
							sess = HibernateUtil.getSession();
						}
						Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
						Query query = sess.createQuery("from Relatorio as r order by r.codigo");
						int gridLines = query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(20);
						List<Relatorio> relatorio = (List<Relatorio>) query.list();						
						DataGrid dataGrid = new DataGrid(null);
						dataGrid.addColum("10", "Código");
						dataGrid.addColum("40", "Nome");
						dataGrid.addColum("30", "Tela");
						dataGrid.addColum("17", "Tipo");
						dataGrid.addColum("3", "Dinâmico");
						for (Relatorio rel: relatorio) {
							dataGrid.setId(String.valueOf(rel.getCodigo()));
							dataGrid.addData(String.valueOf(rel.getCodigo()));
							dataGrid.addData(rel.getNome());
							dataGrid.addData(rel.getTela());
							if (rel.getTipo().trim().equals("b")) {
								dataGrid.addData("Birt Report");
							} else {
								dataGrid.addData("Jasper Report");
							}						
							if (rel.getTipo().trim().equals("s")) {
								dataGrid.addData("Sim");								
							} else {
								dataGrid.addData("Não");
							}						
							dataGrid.addRow();							
						}
						out.print(dataGrid.getTable(gridLines));
						sess.close();
						%>
					</div>
				</div>
						<div id="pagerGrid" class="pagerGrid"></div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
	</div>
</body>
</html>