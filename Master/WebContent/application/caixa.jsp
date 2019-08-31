<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Caixa"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">	
	
	<%
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
	if (session.getAttribute("perfil").equals("a")) {
		query= sess.createQuery("from Unidade as u where u.deleted =\'n\'");		
	} else if (session.getAttribute("perfil").equals("f")) {
		query= sess.getNamedQuery("unidadeByUser");
		query.setString("username", (String) session.getAttribute("username"));
	} else {
		query = sess.createQuery("select p.unidade from Pessoa as p where p.login = :username");
		query.setString("username", (String) session.getAttribute("username"));
	}
	List<Unidade> unidadeList = (List<Unidade>) query.list();
	if (session.getAttribute("perfil").toString().equals("a")
			|| session.getAttribute("perfil").toString().equals("d")
			|| session.getAttribute("perfil").toString().equals("f")) {
		if (session.getAttribute("perfil").toString().equals("f")
				&& (unidadeList.size() > 1)) {
			query= sess.createQuery("from Caixa as c where (1 <> 1)");			
		} else if (session.getAttribute("perfil").toString().equals("f")
				&& (unidadeList.size() == 1)){
			query= sess.createQuery("from Caixa as c " +
					" where c.unidade= :unidade " +					
					" order by c.status, c.inicio desc, c.login.username desc");
			query.setEntity("unidade", unidadeList.get(0));			
		} else {
			query= sess.createQuery("from Caixa as c " +
					" where c.unidade.codigo= :unidade " +
					" and c.login.username = :username " +
					" order by c.status, c.inicio desc, c.login.username desc");
			query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
			query.setString("username", (String) session.getAttribute("username"));
		}
	} else {
		query= sess.createQuery("from Caixa as c where c.login.username = :username " +
				" order by c.status, c.inicio desc, c.login.username");
		query.setString("username", (String) session.getAttribute("username"));				
	}
	
	/*if (session.getAttribute("perfil").equals("f")) {
		query= sess.createQuery("from Caixa as c order by c.status, c.inicio desc, c.login.username desc");		
	} else {
		query= sess.createQuery("from Caixa as c where c.login.username = :username order by c.login.username, c.status, c.inicio desc");
		query.setString("username", (String) session.getAttribute("username"));				
	}*/		
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
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/comum/caixa.js" ></script>	
	
	<title>Master - Caixa</title>
</head>
<body onload="load()">
	<div id="abreCaixa" class="removeBorda" title="Abertura de Caixa" style="display: none;">			
		<form id="formInicio" onsubmit="return false;">
			<fieldset>				
				<label for="valorInicial">Valor Inicial</label>
				<input type="text" name="valorInicial" id="valorInicial" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, decimalNumber)" />			
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="financeiro"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="financeiro"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formPost" method="get" onsubmit= "return search()">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Caixa"/>
					</jsp:include>
					<div class="topContent">						
						<div id="codigo" class="textBox" style="width: 70px;">
							<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 70px;" onkeydown="mask(this, onlyNumber);"/>
						</div>
						<div id="inicio" class="textBox" style="width: 90px;">
							<label>Data de Inicio</label><br/>
							<input id="inicioIn" name="inicioIn" type="text" style="width: 90px;" onkeydown="mask(this, dateType);"/>
						</div>
						<div id="fim" class="textBox" style="width: 90px;">
							<label>Data Final</label><br/>
							<input id="fimIn" name="fimIn" type="text" style="width: 90px;" onkeydown="mask(this, dateType);"/>
						</div>						
						<div id="usuario" class="textBox" style="width: 200px;">
							<label>Usuário</label><br/>
							<input id="usuarioIn" name="usuarioIn" type="text" style="width: 200px;"/>
						</div>
						<div id="unidadeIn" class="textBox">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId">
								<% if (session.getAttribute("perfil").toString().equals("a")) {%>
									<option value="">Selecione</option>									
								<%} else {%>
									<option value="0">Selecione</option>
								<%}%>							
								<%if (unidadeList.size() == 1) {
									out.print("<option value=\"" + unidadeList.get(0).getCodigo() + 
											"\" selected=\"selected\">" + unidadeList.get(0).getReferencia() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										out.print("<option value=\"" + un.getCodigo() + "\">" + 
												un.getReferencia() + "</option>");
									}
								}
								%>
							</select>
						</div>					
					</div>
				</div>
				<div class="topButtonContent">					
					<div class="formGreenButton">
						<input id="buscar" name="buscar" class="greenButtonStyle" type="submit" value="Buscar"/>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>					
					<div id="dataGrid">
						<%DataGrid dataGrid = new DataGrid("cadastro_caixa.jsp");
						dataGrid.addColum("3", "Código");
						dataGrid.addColum("27", "Usuário");
						dataGrid.addColum("10", "Data Início");
						dataGrid.addColum("10", "Hr. Início");
						dataGrid.addColum("10", "Data Final");
						dataGrid.addColum("10", "Hr. Final");
						dataGrid.addColum("10", "Status");
						dataGrid.addColum("10", "Abertura");
						dataGrid.addColum("10", "Fechamento");
						int gridLines = query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(30);
						List<Caixa> caixa= (List<Caixa>) query.list();
						boolean isOpen= false;
						for(Caixa cx: caixa) {
							dataGrid.setId(String.valueOf(cx.getCodigo()));
							dataGrid.addData(String.valueOf(cx.getCodigo()));
							dataGrid.addData(cx.getLogin().getUsername());
							dataGrid.addData(Util.parseDate(cx.getInicio(), "dd/MM/yyyy"));							
							dataGrid.addData(Util.getTime(cx.getInicio()));
							dataGrid.addData((cx.getFim() == null) ? "" : Util.parseDate(cx.getFim(), "dd/MM/yyyy"));
							dataGrid.addData((cx.getFim() == null) ? "" : Util.getTime(cx.getFim()));
							if (cx.getStatus().trim().equals("a")) {
								dataGrid.addData("Aberto");
								if ((session.getAttribute("perfil").equals("f")
										&& cx.getLogin().getUsername().equals(session.getAttribute("username")))
										|| (!session.getAttribute("perfil").equals("f"))) {
									isOpen = true;
								}
							} else {
								dataGrid.addData("Fechado");
							}
							dataGrid.addData(Util.formatCurrency(cx.getValorInicial()));
							dataGrid.addData(Util.formatCurrency(cx.getValorFinal()));
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));						
						%>
						<div id="pagerGrid" class="pagerGrid"></div>
					</div>
				</div>
				<div class="buttonContent" style="margin-top: 80px;">
					<%if (!isOpen && !session.getAttribute("perfil").toString().equals("f")
							&& !session.getAttribute("perfil").toString().equals("a")) {%>
						<div class="formGreenButton">
							<input id="novo" name="novo" class="greenButtonStyle" type="button" value="Novo" onclick="abrirCaixa()" />
						</div>
					<%}%>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>