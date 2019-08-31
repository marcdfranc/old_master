<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Query"%>
<%@page import="org.hibernate.Session"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Lancamento"%>
<%@page import="com.marcsoftware.utilities.Util"%>

<%@page import="com.marcsoftware.database.TipoConta"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
		if (!sess.isOpen()) {
			sess = HibernateUtil.getSession();
		}
	%>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/comum/lancamento.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	
	<%!Query query; %>	
	<%! List<Unidade> unidadeList; %>
	<%
		Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
		if (session.getAttribute("perfil").equals("a")) {
			query= sess.createQuery("from Unidade as u where u.tipo <> 'h'");		
		} else if (session.getAttribute("perfil").equals("f")) {
			query= sess.getNamedQuery("unidadeByUser");
			query.setString("username", (String) session.getAttribute("username"));
		} else {
			query = sess.createQuery("select p.unidade from Pessoa as p where p.login = :username");
			query.setString("username", (String) session.getAttribute("username"));
		}
		unidadeList= (List<Unidade>) query.list();
		
		query = sess.createQuery("from TipoConta as t order by t.codigo");
		List<TipoConta> conta = (List<TipoConta>) query.list();
		if (conta.size() > 0) {
			
		}
	%>
<title>Lançamentos</title>
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
			<form id="lanca" method="get" onsubmit="return search()">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Lançamentos"/>			
					</jsp:include>
					<div class="topContent">
						<div id="lancamento" class="textBox" style="width: 70px;">
							<label>Lançamento</label><br/>
							<input id="lancamentoIn" name="lancamentoIn" type="text" style="width: 70px;"/>												
						</div>
						<div id="documento" class="textBox" style="width: 150px;">
							<label>Documento</label><br/>
							<input id="documentoIn" name="documentoIn" type="text" style="width: 150px;"/>												
						</div>
						<div class="textBox">
							<label>Descrição</label><br/>
							<select id="descricaoIn" name="descricaoIn" style="width: 300px" >
								<option value="" >Selecione</option>
								<%for(TipoConta tpConta: conta) {
									out.println("<option value=\"" + tpConta.getCodigo() +
										"\">" + tpConta.getDescricao() + "</option>");
								}%>
							</select>
						</div>
						<div class="textBox" >
							<label>Status</label><br />
							<select id="status" name="status">
								<option value="">Selecione</option>
								<option value="a">Aberto</option>
								<option value="q">Quitado</option>
								<option value="n">Negociado</option>
								<option value="at">Em Atraso</option>
							</select>
						</div>						
						<div id="inicio" class="textBox" style="width: 73px;">
							<label>Inicio</label><br/>
							<input id="inicioIn" name="inicioIn" type="text" style="width: 73px;" onkeydown="mask(this, dateType);"/>
						</div>
						<div id="fim" class="textBox" style="width: 73px;">
							<label>Fim</label><br/>
							<input id="fimIn" name="fimIn" type="text" style="width: 73px;" onkeydown="mask(this, dateType);"/>
						</div>
						<div class="textBox" style="width:85px">
							<label>Tipo</label><br/>			
							<select id="tipoIn" name="tipoIn">
								<option value="">Selelcione</option>
								<option value="c">Crédito</option>
								<option value="d">Débito</option>
							</select>
						</div>
						<div id="unidadeIn" class="textBox">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId">
								<%if (session.getAttribute("perfil").toString().equals("a")) {%>
									<option value="">Selecione</option>
								<%} else {%>
									<option value="0@0">Selecione</option>
								<%}%>
								<%if (unidadeList.size() == 1) {
									out.print("<option value=\"" + unidadeList.get(0).getRazaoSocial() + "@" + 
											unidadeList.get(0).getCodigo() + 
											"\" selected=\"selected\">" + unidadeList.get(0).getReferencia() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										out.print("<option value=\"" + un.getRazaoSocial() + "@" +
												un.getCodigo() + "\">" + un.getReferencia() + "</option>");
									}
								}%>
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
						
					</div>
					<div id="pagerGrid" class="pagerGrid"></div>												
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close(); %>
	</div>
</body>
</html>