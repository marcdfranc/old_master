<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.database.Acesso"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">	
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query = null;
	List<Acesso> acessoList= null;
	List<Unidade> unidadeList = null;
	int gridLines = 0;
	boolean isReadOnly = false;	
	if (session.getAttribute("perfil").equals("a")) {
		query = sess.createQuery("from Unidade as u where u.deleted =\'n\'");
		unidadeList= (List<Unidade>) query.list();
		query = sess.createQuery("from Acesso as a order by a.saida desc");
		gridLines = query.list().size();
		query.setFirstResult(0);
		query.setMaxResults(30);
		acessoList = (List<Acesso>) query.list();
	} else if (session.getAttribute("perfil").equals("f")) {
		query= sess.getNamedQuery("unidadeByUser");
		query.setString("username", (String) session.getAttribute("username"));
		unidadeList= (List<Unidade>) query.list();
		query = sess.createQuery("from Acesso as a where a.unidade in(" +
				"from Unidade as u where u.administrador.login.username = :username) " +
				" order by a.saida desc");
		query.setString("username", (String) session.getAttribute("username"));
		gridLines = query.list().size();
		query.setFirstResult(0);
		query.setMaxResults(30);
		acessoList = (List<Acesso>) query.list();
	} else {
		query = sess.createQuery("select p.unidade from Pessoa as p where p.login.username = :username");
		query.setString("username", (String) session.getAttribute("username"));
		unidadeList= (List<Unidade>) query.list();
		query = sess.createQuery("from Acesso as a where a.login.username = :username order by a.saida desc");
		query.setString("username", (String) session.getAttribute("username"));
		gridLines = query.list().size();
		query.setFirstResult(0);
		query.setMaxResults(30);
		acessoList = (List<Acesso>) query.list();
		isReadOnly = true;
	} 
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" /> 
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Painel de Conexão</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>	
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/comum/painel_web.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
</head>
<body onload="load()">
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="forum"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="forum"/>
		</jsp:include>
		<input type="hidden" id="origem" name="origem" value="sys" />
		<div id="formStyle">
			<form id="unit" method="get" onsubmit="return search()">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Conexões"/>			
					</jsp:include>
					<div class="topContent">
						<div id="usuario" class="textBox" style="width: 200px;">
							<label>Usuário</label><br/>
							<input id="usuarioIn" name="usuarioIn" type="text" style="width: 200px;" <%if (isReadOnly) {%> readonly="readonly"  <%}%> value="<%= (isReadOnly)? session.getAttribute("username").toString() : ""%>" />
						</div>
						<div id="ipAcesso" class="textBox" style="width: 200px;">
							<label>Ip de Acesso</label><br/>
							<input id="ipAcessoIn" name="ipAcessoIn" type="text" style="width: 200px;"/>
						</div>						
						<div id="inicio" class="textBox" style="width: 90px;">
							<label>Data de Inicio</label><br/>
							<input id="inicioIn" name="inicioIn" type="text" style="width: 90px;" onkeydown="mask(this, dateType);"/>
						</div>
						<div id="fim" class="textBox" style="width: 90px;">
							<label>Data Final</label><br/>
							<input id="fimIn" name="fimIn" type="text" style="width: 90px;" onkeydown="mask(this, dateType);"/>
						</div>
					</div>
				</div>
				<div class="topButtonContent">
					<div class="formGreenButton">
						<input id="buscar" name="insertConta" class="greenButtonStyle" type="submit" value="Buscar"/>
					</div>
				</div>
				<div id="mainContent">
					<div id="responsavel" class="bigBox" >
						<div class="indexTitle" style="margin-bottom: 30px;">
							<h4>Histórico de Conexões</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>	
							
						<div id="counter" class="counter"></div>
						<div id="dataGrid">						
						<%
							DataGrid dataGrid = new DataGrid("historico_navegacao.jsp");
							dataGrid.addColum("15", "Usuário");
							dataGrid.addColum("15", "Unidade");
							dataGrid.addColum("10", "Dt. Entrada");
							dataGrid.addColum("15", "Hr. Entrada");
							dataGrid.addColum("10", "Dt. Saída");
							dataGrid.addColum("15", "Hr. Saída");
							dataGrid.addColum("20", "Endereço Ip");														
							for(Acesso acesso : acessoList) {
								//out.print(acesso.getCodigo() + " - " + acesso.getLogin().getUsername());
								dataGrid.setId(String.valueOf(acesso.getCodigo()));
								dataGrid.addData(acesso.getLogin().getUsername());
								dataGrid.addData((acesso.getUnidade() == null)? "Várias" :
									acesso.getUnidade().getReferencia());
								dataGrid.addData(Util.parseDate(acesso.getEntrada(), "dd/MM/yyyy"));
								dataGrid.addData(Util.getTime(acesso.getEntrada()));
								if (acesso.getSaida() == null) {
									dataGrid.addData("-------");
									dataGrid.addData("-------");
								} else {
									dataGrid.addData(Util.parseDate(acesso.getSaida(), "dd/MM/yyyy"));
									dataGrid.addData(Util.getTime(acesso.getSaida()));
								}
								dataGrid.addData(acesso.getIp());
								dataGrid.addRow();
							}
							out.print(dataGrid.getTable(gridLines));
						%>
						<div id="pagerGrid" class="pagerGrid"></div>
					</div>					
					<div class="buttonContent" style="margin-top: 30px;">
						<div class="formGreenButton">
							<input id="selecione" name="selecione" class="greenButtonStyle" type="button" value="todos" onclick="selectAll()" />
						</div>
					</div>
				</div>
			</div>
		</form>
	</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close(); %>
</div>
</body>
</html>