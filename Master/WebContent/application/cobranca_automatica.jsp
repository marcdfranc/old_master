<?xml version="1.0" encoding="ISO-8859-1" ?>

<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Cc"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="java.util.Date"%>
<%@page import="com.marcsoftware.database.Lancamento"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Date now = new Date();
	Query query;
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	if (session.getAttribute("perfil").equals("a")) {
		query= sess.createQuery("from Unidade as u");		
	} else if (session.getAttribute("perfil").equals("f")) {
		//query= sess.getNamedQuery("unidadeByUser");
		query = sess.createQuery("from Unidade as u where u.administrador.login.username = :username and u.deleted = \'n\'");
		query.setString("username", (String) session.getAttribute("username"));
	} else {
		query = sess.createQuery("select p.unidade from Pessoa as p where p.login = :username");
		query.setString("username", (String) session.getAttribute("username"));
	}
	List<Unidade> unidadeList= (List<Unidade>) query.list();	
	
	
	
	%>
<head>
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<link rel="shortcut icon" href="../icone.ico">
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>	
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/comum/cobranca_automatica.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>	
	
	<title>Master - Cobrança automática.</title>
</head>
<body onload="load()">	
	<%if (session.getAttribute("perfil").equals("a")) {%>
		<div id="imprimeWindow" title="Imprimir" style="display: none;">
			<form onsubmit="return false;">			
				<label for="ccobStatusIn">Status</label>
				<select id="ccobStatusIn" name="ccobStatusIn" style="width: 100%">	
					<option value="">Selecione</option>										
					<option value="O">Não Enviar - Pagamento por Boleto</option>
					<option value="P">Não Enviar - Pagamento no Corporativo</option>
					<option value="N">Não Enviar - Pag. Esc.</option>
					<option value="I">Para Enviar</option>
					<option value="E">Enviado</option>
					<option value="A">Para Alterar - UC</option>
					<option value="C">Para Cancelar</option>
					<option value="L">Cancelado</option>
					<option value="R">Com falta ou erro de Dados</option>
					<option value="D">Com Contas em Atraso</option>
					<option value="S">Sem Conta de Energia Elétrica</option>
					<option value="B">Ocorrência de Erro na CPFL</option>
					<option value="T">Lista Negra da CPFL</option>
					<option value="G">Lista Negra do Plano</option>
					<option value="M">Houve troca de Titularidade</option>
					<option value="U">Duplicidade de Cobrança na mesma UC</option>
					<option value="F">Aguardando Definição</option>
				</select>			
			</form>
		</div>
	<%} %>
	<%@ include file="../inc/header.jsp" %>	
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="financeiro"/>
	</jsp:include>	
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="financeiro"/>			
		</jsp:include>
		<div id="formStyle">
			<form method="post" target="_blank" action="../Centercob" >
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Cobr. Automática"/>			
					</jsp:include>
					<div id="abaMenu">							
						<div class="sectedAba2">
							<label>Tela inicial</label>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>							
						<div class="aba2">
							<a href="ccob_envio.jsp?">Histórico de Remessas</a>
						</div>
						
						<div class="aba2">
							<a href="http://app.sacmaster.web1211.kinghost.net" target="blank">Processamento de Retornos</a>
						</div>
					
					</div>
					<div class="topContent">
						<div id="unidadeIn" class="textBox" style="width: 200px">
							<label>Selecione a Unidade</label><br/>
							<select id="unidadeId" name="unidadeId" style="width: 200px;" onchange="setLiberacao()">								
								<% for(Unidade und: unidadeList) {
										out.print("<option value=\"" + und.getCodigo() + 
												"\">" + und.getReferencia() + " - " + und.getDescricao() + "</option>");										
									}							
								%>
							</select>
						</div>
					</div>					
				</div>
				<div id="mainContent">
					<div id="situacaoFinanceira" class="bigBox" style=" bottom: 30px !important" >
						<div class="indexTitle" style="margin-top: 50px;">
							<h4>Histórico da Gestão e Tercerização de Cobranças</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div class="dataGrid">
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Selecione</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="nulos" href="#" style="float: right;">01</a>
							</div>
							
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Não Enviar - Pagamento no Boleto</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="pagBoleto" href="#" style="float: right;">01</a>
							</div>
							
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Não Enviar - Pagamento no Corporativo</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="pagCorporativo" href="#" style="float: right;">01</a>
							</div>
							
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Não Enviar - Pag. Esc.</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="semEnvio" href="#" style="float: right;">01</a>
							</div>
							
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Para Enviar</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="incluir" href="#" style="float: right;">01</a>
							</div>
							
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Enviado</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="enviado" href="#" style="float: right;">01</a>
							</div>
							
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Para Alterar - UC</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="alterar" href="#" style="float: right;">01</a>
							</div>
							
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Para Cancelar</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="cancelar" href="#" style="float: right;">01</a>
							</div>
							
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Cancelado</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="cancelado" href="#" style="float: right;">01</a>
							</div>
							
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Com Falta ou Erro de Dados</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="erro" href="#" style="float: right;">01</a>
							</div>
							
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Com Contas em atraso</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="atraso" href="#" style="float: right;">01</a>
							</div>
							
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Sem Conta de Energia Elétrica</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="semConta" href="#" style="float: right;">01</a>
							</div>
							
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Ocorrência de Erro na CPFL</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="erroCpfl" href="#" style="float: right;">01</a>
							</div>
							
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Lista Negra da CPFL</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="negraCpfl" href="#" style="float: right;">01</a>
							</div>
							
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Lista Negra do Plano</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="negra" href="#" style="float: right;">01</a>
							</div>
							
						
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Houve troca de Titularidade</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="trocaTitular" href="#" style="float: right;">01</a>
							</div>
							
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Duplicidade de Cobrança na mesma UC</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="duplicidade" href="#" style="float: right;">01</a>
							</div>
							
							<div class="panelLines" style="width: 600px;">										
								<a href="#" style="float: left;">Aguardando Definição</a>
							</div>
							<div class="panelLines" style="width: 265px;">
								<a id="indefinido" href="#" style="float: right;">01</a>
							</div>
						</div>
					</div>
					<div class="buttonContent" style="margin-right: 112px">
						<div class="formGreenButton" >
							<input  class="greenButtonStyle" type="button" value="Gerar Arq." onclick="geraArquivo();"/>
						</div>
						<%if (session.getAttribute("perfil").equals("a")) {%>
							<div class="formGreenButton" style="margin-right: 15px">
								<input  class="greenButtonStyle" type="button" value="imprimir" onclick="imprimir();"/>
							</div>
						<%} %>
					</div>
					
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>