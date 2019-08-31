<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.database.Relatorio"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Parametro"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.utilities.WindowConfig"%><html xmlns="http://www.w3.org/1999/xhtml">


	<jsp:useBean id="relatorio" class="com.marcsoftware.database.Relatorio"></jsp:useBean>

	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}	
	Query query = sess.createQuery("from Relatorio as r where r.codigo = :codigo");
	query.setLong("codigo", Long.valueOf(request.getParameter("id")));
	relatorio = (Relatorio) query.uniqueResult();
	query = sess.createQuery("from Parametro as p where p.relatorio = :relatorio and p.operador not in('cn') and p.tipo not in('cn')");
	query.setEntity("relatorio", relatorio);
	query.setFirstResult(0);
	query.setMaxResults(20);
	List<Parametro> parametro = (List<Parametro>) query.list();
	query = sess.createQuery("from Parametro as p where p.relatorio = :relatorio order by p.sequencial");
	query.setEntity("relatorio", relatorio);
	List<Parametro> parametros = (List<Parametro>) query.list();
	%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<link rel="shortcut icon" href="../icone.ico">
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/comum/parametro.js" ></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
<title>Master Parametros</title>
</head>
<body onload="load();">
	<div id="paramWindow" class="removeBorda" title="Edição de observação" style="display: none;">
		<form id="formParam" onsubmit="return false;">
			<fieldset id="conteinerSeq">
				<%for(Parametro param: parametros) {%>
					<label for="<%= "seq_" + param.getCodigo() %>"><%= param.getCodigo() %></label>
					<input type="text" name="<%= "seq_" + param.getCodigo() %>" id="<%= "seq_" + param.getCodigo() %>" class="textDialog ui-widget-content ui-corner-all" value="<%= param.getSequencial() %>" />
				<%}%>
			</fieldset>
		</form>
	</div>
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
				<input type="hidden" id="haveParam" name="haveParam" value="<%= (parametros.size() > 0)? "s" : "n" %>" />
				<div id="localConfig">
					<%for(int i = 0 ; i < parametro.size(); i++) {
						if (parametro.get(i).getComponente().trim().equals("i") 
								|| parametro.get(i).getComponente().trim().equals("c")) {%>
							<input type="hidden" id="cpParam<%=i%>" name="cpParam<%=i%>" value="<%=parametro.get(i).getCodigo() + "@" + parametro.get(i).getComponente() + "@" + parametro.get(i).getPx() + "@" + parametro.get(i).getPy()%>"/>
							<input type="hidden" id="cpData<%=i%>" name="cpData<%=i%>" value="-1"/>
						<%} else if(parametro.get(i).getComponente().trim().equals("c")) {%>
							<input type="hidden" id="cpParam<%=i%>" name="cpParam<%=i%>" value="<%=parametro.get(i).getCodigo() + "@" + parametro.get(i).getComponente() + "@" + parametro.get(i).getPx() + "@" + parametro.get(i).getPy()%>"/>
							<input type="hidden" id="cpData<%=i%>" name="cpData<%=i%>" value="<%=parametro.get(i).getMascara()%>"/>
						<%} else {%>
							<input type="hidden" id="cpParam<%=i%>" name="cpParam<%=i%>" value="<%=parametro.get(i).getCodigo() + "@" + parametro.get(i).getComponente() + "@" + parametro.get(i).getPx() + "@" + parametro.get(i).getPy()%>"/>
							<input type="hidden" id="cpData<%=i%>" name="cpData<%=i%>" value="<%=parametro.get(i).getDados()%>"/>
						<%}
					}%>
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Relatório"/>			
					</jsp:include>
					<div class="topContent">
						<div class="textBox" id="codRelatorio" name="codRelatorio" style="width: 75px;">
							<label>Código</label><br/>
							<input id="codRel" name="codRel" type="text" style="width:75px" readonly="readonly" value="<%=relatorio.getCodigo()%>"/>
						</div>
						<div class="textBox" id="nomeRelatorio" name="nomeRelatorio" style="width: 300px;">
							<label>nome</label><br/>
							<input id="nomeRel" name="nomeRel" type="text" style="width:300px" readonly="readonly" value="<%=relatorio.getNome()%>"/>
						</div>
						<div class="textBox" id="telaRelatorio" name="telaRelatorio" style="width: 180px;">
							<label>Tela</label><br/>
							<input id="nomeRel" name="nomeRel" type="text" style="width:180px" readonly="readonly" value="<%=relatorio.getNome()%>"/>
						</div>
						<div class="textBox" id="tipoRelatorio" name="tipoRelatorio" style="width: 110px;">
							<label>Tipo</label><br/>
							<%if (relatorio.getTipo().trim().equals("b")) {%>
								<input id="tipoRel" name="tipoRel" type="text" style="width:75px" readonly="readonly" value="Birt Report"/>
							<%} else {%>
								<input id="tipoRel" name="tipoRel" type="text" style="width:110px" readonly="readonly" value="Jasper Report"/>
							<%}%>
						</div>
						<div class="textBox" id="dinaRelatorio" name="dinaRelatorio" style="width: 75px;">
							<label>Dinâmico</label><br/>
							<%if (relatorio.getDinamico().trim().equals("s")) {%>
								<input id="dinamicRel" name="dinamicRel" type="text" style="width:75px" readonly="readonly" value="Sim"/>
							<%} else {%>
								<input id="dinamicRel" name="dinamicRel" type="text" style="width:75px" readonly="readonly" value="Não"/>
							<%}%>
						</div>
					</div>
				</div>				
				<div class="buttonContent" style="margin-right: 380px">
					<div class="formGreenButton">
						<input name="insertParam" id="insertParam" class="greenButtonStyle" type="button" value="Novo" onclick="goToCadastro()" />						
					</div>
					<div class="formGreenButton">
						<input class="greenButtonStyle" type="button" value="Sequenciar" onclick="showWd()" />						
					</div>
				</div>
				<div id="window" name="window" style="margin-bottom: <%= 200 - (600 - relatorio.getHeightFiltro()) %>px;">
					<%
					if (parametro.size() > 0) {
						WindowConfig windowConfig = new WindowConfig(parametro.get(0).getRelatorio().getWidthFiltro(), parametro.get(0).getRelatorio().getHeightFiltro());						
						for(Parametro param: parametro) {								
							if (param.getComponente().trim().equals("i") 
									|| param.getComponente().trim().equals("c")) {
								windowConfig.addComponent(String.valueOf(param.getCodigo()), 
										param.getRotulo(), param.getComponente(), param.getPx(), 
										param.getPy(), param.getMascara());
							} else {
								windowConfig.addComponent(String.valueOf(param.getCodigo()), 
										param.getRotulo(), param.getComponente(), param.getPx(), 
										param.getPy(), param.getDados());									
							}
						}
						out.print(windowConfig.getWindow());							
					}					
					%>
				</div>				
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid" >
						<%
						query = sess.createQuery("from Parametro as p where p.relatorio = :relatorio order by p.sequencial");
						query.setEntity("relatorio", relatorio);
						parametro = (List<Parametro>) query.list();
						int gridLines = parametro.size();
						DataGrid dataGrid = new DataGrid("cadastro_parametro.jsp");
						dataGrid.addColum("10", "Código");
						dataGrid.addColum("20", "Descrição");
						dataGrid.addColum("20", "Tipo");
						dataGrid.addColum("20", "Componente");
						dataGrid.addColum("20", "Rótulo");
						dataGrid.addColum("10", "Requerido");
						for(Parametro param: parametro) {
							dataGrid.setId(String.valueOf(param.getCodigo()));
							dataGrid.addData(String.valueOf(param.getCodigo()));
							dataGrid.addData(param.getDescricao());
							if (param.getTipo().trim().equals("cn")) {
								dataGrid.addData("Conexão");
							} else if (param.getTipo().trim().equals("i")) {
								dataGrid.addData("Integer");
							}  else if (param.getTipo().trim().equals("s")) {
								dataGrid.addData("String");
							}  else if (param.getTipo().trim().equals("f")) {
								dataGrid.addData("Decimal");
							} else if (param.getTipo().trim().equals("d")) {
								dataGrid.addData("Date");
							} else if (param.getTipo().trim().equals("l")) {
								dataGrid.addData("Long");
							}
							if (param.getComponente().trim().equals("r")) {
								dataGrid.addData("Radio Button");
							} else if (param.getComponente().trim().equals("i")) {
								dataGrid.addData("Item Selector");
							} else if (param.getComponente().trim().equals("c")) {
								dataGrid.addData("Combo Box");
							} else if (param.getComponente().trim().equals("t")) {
								dataGrid.addData("Prompt");
							} else {
								dataGrid.addData("Check Box");
							}
							dataGrid.addData(param.getRotulo());
							if (param.getRequerido().trim().equals("s")) {
								dataGrid.addData("Sim");
							} else {
								dataGrid.addData("Não");
							}
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));
						%>
						<div id="pagerGrid" class="pagerGrid"></div>
					</div>					
					<div class="buttonContent" >
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Redefinir" onclick="refreshParametro()"/>
						</div>
					</div>
				</div>
			</form>
		</div>		
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>