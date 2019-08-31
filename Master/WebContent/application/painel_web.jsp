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
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.database.Fisica"%>
<%@page import="com.marcsoftware.database.Juridica"%><html xmlns="http://www.w3.org/1999/xhtml">	
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query = null;
	List<Acesso> acessoList= null;
	Fisica fisica = null;
	Juridica juridica = null;
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
		<jsp:param name="currentPage" value="financeiro"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="financeiro"/>
		</jsp:include>
		<div id="formStyle">
			<input type="hidden" id="origem" name="origem" value="log" />
			<form id="unit" method="get" onsubmit="return search()">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Conexões"/>			
					</jsp:include>
					<div class="topContent">
						<div id="usuario" class="textBox" style="width: 200px;">
							<label>Usuário</label><br/>
							<input id="usuarioIn" name="usuarioIn" type="text" style="width: 200px;"/>
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
						<div class="indexTitle" style="margin-bottom: 20px;">
							<h4>Status Atual</h4>
							<div class="alignLine">
								<hr>
							</div>
							<div id="counter" class="counter"></div>
							<div id="dataGrid">						
								<%query = sess.createQuery("from Acesso as a where a.saida is null order by a.entrada desc");
								acessoList = (List<Acesso>) query.list();
								int gridLines = acessoList.size();
								query.setFirstResult(0);
								query.setMaxResults(30);
								DataGrid dataGrid = new DataGrid("historico_navegacao.jsp");
								dataGrid.addColum("30", "Nome");
								dataGrid.addColum("20", "Usuario");
								dataGrid.addColum("18", "Unidade");
								dataGrid.addColum("10", "Data");
								dataGrid.addColum("10", "Hora");
								dataGrid.addColum("10", "nº Ip");
								dataGrid.addColum("2", "Ck");
								for(Acesso acesso : acessoList) {
									dataGrid.setId(String.valueOf(acesso.getCodigo()));
									query = sess.createQuery("from Fisica as f where f.login = :login");
									query.setEntity("login", acesso.getLogin());
									if (query.list().size() == 0) {
										query = sess.createQuery("from Juridica as j where j.login = :login");
										query.setEntity("login", acesso.getLogin());
										juridica = (Juridica) query.uniqueResult();
										dataGrid.addData(Util.initCap(juridica.getRazaoSocial()));
										dataGrid.addData(acesso.getLogin().getUsername());
										if (juridica.getUnidade() == null) {
											dataGrid.addData("Várias");
										} else {
											dataGrid.addData(juridica.getUnidade().getDescricao());
										}
									} else {
										fisica = (Fisica) query.uniqueResult();
										dataGrid.addData(Util.initCap(fisica.getNome()));
										dataGrid.addData(acesso.getLogin().getUsername());
										if (fisica.getUnidade() == null) {
											dataGrid.addData("Várias");
										} else {
											dataGrid.addData(fisica.getUnidade().getDescricao());
										}
									}
									dataGrid.addData(Util.parseDate(acesso.getEntrada(), "dd/MM/yyyy"));
									dataGrid.addData(Util.getTime(acesso.getEntrada()));
									dataGrid.addData(acesso.getIp());
									dataGrid.addCheck(true);
									dataGrid.addRow();										
								}
								out.print(dataGrid.getTable(gridLines));
								%>
							</div>
						</div>
						<div class="buttonContent">
							<div class="formGreenButton">
								<input id="selecione" name="selecione" class="greenButtonStyle" type="button" value="todos" onclick="selectAll()" />
							</div>
							<div class="formGreenButton">
								<input id="desconect" name="desconect" class="greenButtonStyle" type="button" value="Desconectar" onclick="desconectUser()" />
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