<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Parametro"%>
<%@page import="com.marcsoftware.database.Relatorio"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.util.Arrays"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.database.Unidade"%><html xmlns="http://www.w3.org/1999/xhtml">

	<%List<Parametro> parametros;	
	int gridLines;
	String dados, mascara;
	String relAtivo = request.getParameter("rel");
	ArrayList<String[]> genericQueryRes;
	ArrayList<String> pipes;
	String[] arrayResult = new String[2];
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query= sess.createQuery("from Relatorio as r where r.tela = :tela order by r.nome");
	query.setString("tela", request.getParameter("rel"));
	List<Relatorio> relatorio = (List<Relatorio>) query.list();
	if (session.getAttribute("perfil").equals("a")) {
		query= sess.createQuery("from Unidade as u where u.deleted =\'n\'");		
	} else if (session.getAttribute("perfil").equals("f")) {
		query= sess.getNamedQuery("unidadeByUser");
		query.setString("username", (String) session.getAttribute("username"));
	} else {
		query = sess.createQuery("select p.unidade from Pessoa as p where p.login = :username");
		query.setString("username", (String) session.getAttribute("username"));
	}
	List<Unidade> unidadeList= (List<Unidade>) query.list();
	String inUnidade = "";
	for(Unidade und: unidadeList) {
		if (inUnidade == "") {
			inUnidade+= und.getCodigo();
		} else {
			inUnidade+= ", " + und.getCodigo();
		}
	}
	%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<link rel="shortcut icon" href="../icone.ico">
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />	
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
	
    <script type="text/javascript" src="../js/jquery/jquery.js"></script>
    <script type="text/javascript" src="../js/jquery/interface.js"></script>
    <script type="text/javascript" src="../js/lib/util.js"></script>	
	<script type="text/javascript" src="../js/comum/relatorio_f.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/item_selector.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>	
	<script type="text/javascript" src="../js/default.js" ></script>
		
	<title>Master Relatórios de Profissionais</title>	
</head>
<body>	
	<jsp:include page="../inc/pdv.jsp"></jsp:include>
	<%for(Relatorio rel: relatorio) {
		query = sess.createQuery("from Parametro as p where p.relatorio = :relatorio and p.tipo not in('cn') order by p.sequencial");
		query.setEntity("relatorio", rel);
		parametros = query.list();
		if (parametros.size() > 0) {%>
			<input type="hidden" id="<%= "prWd" + rel.getCodigo() %>" value="<%= rel.getWidthFiltro() %>" />
			<div id="<%= "wd" + rel.getCodigo() %>" class="removeBorda" title="Filtro de Impressão" style="display: none;">			
			<form id="<%= "form" + rel.getCodigo() %>" onsubmit="return false;"><fieldset><%		
			for(Parametro param: parametros) {
				if (param.getRefUnidade().equals("s")) {
					if (Util.getPart(param.getCampo(), 2) != ""){%>
						<label for="<%= "param" + param.getCodigo() %>"><%= Util.initCap(param.getRotulo()) %></label>
						<div class="textDialog" style="width: 100% !important;">							
							<select id="<%= "param" + param.getCodigo() %>" name="<%= "param" + param.getCodigo() %>" style="width: 100% !important;">
							<option value="">Selecione</option><%
							query = sess.createSQLQuery(param.getDados() + 
									" and " + Util.getPart(param.getCampo(), 2) + 
									" IN (" + inUnidade + ")");
							genericQueryRes = (ArrayList<String[]>) query.list();
							if (genericQueryRes.size() > 0) {
								for(int i = 0; i < genericQueryRes.size(); i++) {
									dados = Util.convertObjStr(Arrays.toString(genericQueryRes.get(i)));%>
									<option value="<%=Util.getPart(dados, 1) %>"><%=Util.getPart(dados, 2)%></option>
								<%}
							}%>						
							</select>
						</div>					
					<%} else {%>
						<label for="<%= "param" + param.getCodigo() %>"><%= Util.initCap(param.getRotulo()) %></label>
						<div class="textDialog" style="width: 100% !important;">
							<select id="<%= "param" + param.getCodigo() %>" name="<%= "param" + param.getCodigo() %>" style="width: 100% !important;">							
							<%for(Unidade und: unidadeList) {%>								
								<option value="<%=und.getCodigo() %>"><%= und.getReferencia() %></option>
							<%}%>
							</select>
						</div>												
					 <%}%>
					
				<%} else {
					switch (param.getComponente().charAt(0)) {
						case 'i':
							
							break;
							
						case 'k':
							
							break;
							
						case 't':
							if ((!param.getMascara().equals(""))
									&& (!param.getMascara().equals(null))) {%>
								<label for="<%= "param" + param.getCodigo() %>"><%= Util.initCap(param.getRotulo()) %></label>
								<input type="text" name="<%= "param" + param.getCodigo() %>" id="<%= "param" + param.getCodigo() %>" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, <%= param.getMascara() %>)" />							
							<%} else {%>
								<label for="<%= "param" + param.getCodigo() %>"><%= Util.initCap(param.getRotulo()) %></label>
								<input type="text" name="<%= "param" + param.getCodigo() %>" id="<%= "param" + param.getCodigo() %>" class="textDialog ui-widget-content ui-corner-all" />
							<%}
							break;
						
						case 'd':
							if ((!param.getMascara().equals(""))
									&& (!param.getMascara().equals(null))) {%>
								<label for="<%= "nextA" + param.getCodigo() %>"><%= Util.initCap(param.getRotulo()) %></label>
								<input type="text" name="<%= "nextA" + param.getCodigo() %>" id="<%= "nextA" + param.getCodigo() %>" class="textDialog ui-widget-content ui-corner-all dpPrompt itemA" onkeydown="mask(this, <%= param.getMascara() %>)" onkeyup="refreshDoubleValue('param<%= param.getCodigo() %>');" />
								<label for="<%= "nextB" + param.getCodigo() %>"><%= Util.initCap(Util.getPipeById(param.getDados(), 3)) %></label>
								<input type="text" name="<%= "nextB" + param.getCodigo() %>" id="<%= "nextB" + param.getCodigo() %>" class="textDialog ui-widget-content ui-corner-all dpPrompt itemB" onkeydown="mask(this, <%= param.getMascara() %>)" onkeyup="refreshDoubleValue('param<%= param.getCodigo() %>');" />
								
							<%} else {%>
								<label for="<%= "nextA" + param.getCodigo() %>"><%= Util.initCap(param.getRotulo()) %></label>
								<input type="text" name="<%= "nextA" + param.getCodigo() %>" id="<%= "nextA" + param.getCodigo() %>" class="textDialog ui-widget-content ui-corner-all dpPrompt itemA" onkeyup="refreshDoubleValue('param<%= param.getCodigo() %>');" />
								<label for="<%= "nextB" + param.getCodigo() %>"><%= Util.initCap(Util.getPipeById(param.getDados(), 3)) %></label>
								<input type="text" name="<%= "nextB" + param.getCodigo() %>" id="<%= "nextB" + param.getCodigo() %>" class="textDialog ui-widget-content ui-corner-all dpPrompt itemB" onkeyup="refreshDoubleValue('param<%= param.getCodigo() %>');" />
								
							<%}
							break;
							
						case 'r':%>
							<label for="<%= "param" + param.getCodigo() %>"><%= Util.initCap(param.getRotulo()) %></label>						
							<div id="paramBoxRd" class="checkRadio ui-widget-content ui-corner-all"><%
								pipes = Util.unmountRealPipe(param.getDados());
								for(int i = 0; i < pipes.size(); i++) {
									if (i == 0) {%>
									<label class="labelCheck" ><%= Util.getPipeById(pipes.get(i), 0) %></label>
									<input type="radio" checked="checked" id="<%= "param" + param.getCodigo()%>" name="<%= "param" + param.getCodigo()%>" value="<%= Util.getPipeById(pipes.get(i), 5) %>"/>
									<%} else {%>
										<label class="labelCheck" ><%= Util.getPipeById(pipes.get(i), 0) %></label>
										<input type="radio" id="<%= "param" + param.getCodigo()%>" name="<%= "param" + param.getCodigo()%>" value="<%= Util.getPipeById(pipes.get(i), 5) %>"/>
									<%}%>								
								<%}%>
							</div>
							<%break;
							
						case 'c':%>
							<label for="<%= "param" + param.getCodigo() %>"><%= Util.initCap(param.getRotulo()) %></label>
							<div class="textDialog" style="width: 100% !important;">
								<select id="<%= "param" + param.getCodigo() %>" name="<%= "param" + param.getCodigo() %>" style="width: 100% !important;">
									<option value="">Selecione</option>
							<%						
							if (param.getDados().toLowerCase().contains("select")) {
								query = sess.createSQLQuery(param.getDados());
								genericQueryRes = (ArrayList<String[]>) query.list();
								if (genericQueryRes.size() > 0) {
									for(int i = 0; i < genericQueryRes.size(); i++) {
										dados = Util.convertObjStr(Arrays.toString(genericQueryRes.get(i)));%>
										<option value="<%=Util.getPart(dados, 1) %>"><%=Util.getPart(dados, 2)%></option>
									<%}
								}
							} else {
								pipes = Util.unmountRealPipe(param.getDados());
								for(String pp : pipes) {%>
									<option value="<%=Util.getPart(pp, 1) %>"><%=Util.getPart(pp, 2)%></option>
								<%}
							}%></select></div>
							<%break;					
					}
					
				}
			}%>
			</fieldset>
			</form>
			</div>
		<%}			
	}%>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="<%= relAtivo %>"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="<%= relAtivo %>"/>
		</jsp:include>
		<div id="formStyle">
			<form id="parc" method="get" onsubmit="return search()">
				<div id="localEdParam"><%
					gridLines = 0;					
					for(int i=0; i < relatorio.size(); i++){
						query = sess.createQuery("from Parametro as p where p.relatorio = :relatorio and p.tipo not in('cn')");
						query.setEntity("relatorio", relatorio.get(i));
						parametros = (List<Parametro>) query.list();
						for(Parametro param: parametros) {
							if (param.getComponente().trim().equals("i")) {
								dados = param.getMascara().replace("@", ",");
							} else if (param.getComponente().trim().equals("c")) {
								if (param.getDados().toLowerCase().contains("select")) {
									dados = "-1";									
								} else {
									dados = param.getDados().replace("@", ",");
									dados = dados.replace("|", ";");
								}
							} else {
								dados = param.getDados().replace("@", ",");
								dados = dados.replace("|", ";");
							}
							mascara = (param.getMascara() == null)? "":  param.getMascara().replace("@", ",");
							mascara = mascara.replace("|", ";");
							out.print("<input id=\"edParam" + String.valueOf(gridLines) + "\" name=\"edRef" +
								String.valueOf(gridLines++) + "\"	type=\"hidden\" value=\"" +
								param.getRelatorio().getCodigo() + "@" + param.getRelatorio().getWidthFiltro() + "@" + 
								param.getRelatorio().getHeightFiltro() + "@" + param.getCodigo() + "@" + 
								param.getComponente() + "@" + param.getRotulo() + "@" + 
								param.getPx() + "@" + param.getPy() + "@" +	dados + "@" + 
								mascara + "\" />");
							dados = "";
							mascara = "";
						}
						
					}%>
				</div>				
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Relatórios"/>
					</jsp:include>
					<div class="topContent"></div>
				</div>					
				<div id="mainContent">
					<div id="counter" class="counter" style="margin-top: 110px"></div>
					<div id="dataGrid" >
						<%DataGrid dataGrid = new DataGrid(null);
						gridLines = relatorio.size();
						dataGrid.addColum("30", "Código");
						dataGrid.addColum("70", "Descrição");						
						for (Relatorio rel : relatorio) {
							dataGrid.setId("wd" + rel.getCodigo());
							dataGrid.addData(String.valueOf(rel.getCodigo()));
							dataGrid.addData(Util.initCap(rel.getNome()));
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));
						%>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close(); %>
	</div>
</body>
</html>