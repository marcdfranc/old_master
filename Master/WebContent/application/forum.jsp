<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Fisica"%>
<%@page import="com.marcsoftware.database.Acesso"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}	
	
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query = sess.createQuery("from Fisica as f where f.login.username = :username");
	query.setString("username", session.getAttribute("username").toString());
	Fisica fisica = (Fisica) query.uniqueResult();
	query = sess.createQuery("from Acesso as a where " + 
			" a.login.username = :username and a.saida <> null order by a.entrada desc");
	query.setString("username", fisica.getLogin().getUsername());
	query.setFirstResult(0);
	query.setMaxResults(1);
	Acesso acesso = (Acesso) query.uniqueResult();
	query = sess.createSQLQuery("SELECT COUNT(*) FROM cartao_acesso " +
			"WHERE username = :username AND status = 'a'");
	query.setString("username", fisica.getLogin().getUsername());
	int acessos = Integer.parseInt(query.uniqueResult().toString());
	query = sess.createQuery("select count(*) from AcessoNotificacao as a " +
			" where a.id.login.username = :username  and a.visualizada = 'n'");
	query.setString("username", session.getAttribute("username").toString());
	int notificacoes = Integer.parseInt(query.uniqueResult().toString());
	%>

<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Forum</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/validation.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/comum/cadastro_funcionario.js"></script>
	<script type="text/javascript" src="../js/lib/pilot_grid.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_window.js"></script>
</head>
<body>
	<%@ include file="../inc/header.jsp"%>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="forum"/>
	</jsp:include>
	<div id="centerAll" >
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="forum"/>
		</jsp:include>
		<div id="formStyle">		
			<form id="formPost" method="post" action="../CadastroFuncionario" onsubmit= "return validForm(this)" >
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Tela Inicial"/>			
					</jsp:include>
					<div class="topContent">
						<div class="indexTitle">
							<div id="fot" class="textBox"style="width: 103px; height: 137px;">
								<img src="<%=(fisica.getLogin().getFoto() != null)? fisica.getLogin().getFoto(): "../image/foto.gif" %>" width="103" height="137"/>
							</div>
							<h4 style="margin-left: 150px" >Olá <%= Util.initCap(Util.getFirstName(fisica.getNome())) %>!</h4>
							<h4 style="margin-left: 150px">Seja bem vind<%=(fisica.getSexo().equals("m"))? "o" :"a" %> a sua estação de trabalho.</h4>
							<h4 style="margin-left: 150px">Tenha um bom dia!</h4>
							<%if (acessos < 4) {%>
								<div style="top: 5px; position: relative; margin-left: 150px">
									<label class="titleCounter" style="float: left; position: absolute; color: red;">Atenção! Restam apenas <%= acessos %> acessos em seu cartão!</label>
								</div>								
							<%}%>
							<div class="textBox" >
								<%if (acesso == null) { %>
									<label class="titleCounter" style="float: left; margin-top: 30px; position: absolute;">Seu último login foi em: Sem registros anteriores, este é seu primeiro acesso.</label>
								<%} else {%>
									<label class="titleCounter" style="float: left; margin-left: 20px; margin-top: 30px; position: absolute;">Seu último login foi em: <%= Util.parseDate(acesso.getEntrada(), "dd/MM/yyyy") %> às <%= Util.getTime(acesso.getEntrada()) %> até <%=Util.parseDate(acesso.getSaida(), "dd/MM/yyyy") %> às <%=Util.getTime(acesso.getSaida()) %>.</label>
								<%}%>
							</div>
						</div>
					</div>
				</div>
				<div id="mainContent">
					<div id="responsavel" class="bigBox" >
						<div class="indexTitle" style="margin-bottom: 20px;">
							<h4>Painel Inicial</h4>
							<div class="alignLine">
								<hr>
							</div>
							<div style="width: 1000px;">
								<div id="dataGrid" >
									<div class="panelLines" style="width: 600px; background: url('../image/back_check.png') repeat-x top left; border-bottom: none !important;">
										<label id="headerLabel"  style="float: left;">Descrição</label>
									</div>								
									<div class="panelLines" style="width: 265px; background: url('../image/back_check.png') repeat-x top left; border-bottom: none !important;">
										<label id="headerResult" style="float: right;" >Qtde.</label>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="solicitacaoLabel" name="solicitacaoLabel" href="#" style="float: left;">Solicitações</a>
										</div>
										<div class="panelLines" style="width: 265px;">
											<a id="solicitacao" name="solicitacao" href="#" style="float: right;">10</a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="notificacaoLabel" name="notificacaoLabel" href="notificacao.jsp" style="float: left;">Notificações</a>
										</div>
										<div class="panelLines" style="width: 265px;">
											<a id="solicitacao" name="solicitacao" href="notificacao.jsp" style="float: right;"><%= notificacoes %></a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="emailLabel" name="emailLabel" href="#" style="float: left;">E-mails não lidos</a>
										</div>
										<div class="panelLines" style="width: 265px;">
											<a id="email" name="email" href="#" style="float: right;">5</a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="skypeLabel" name="skypeLabel" href="#" style="float: left;">Chamadas no Skype</a>
										</div>
										<div class="panelLines" style="width: 265px;">
											<a id="skype" name="skype" href="#" style="float: right;">01</a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="msnLabel" name="msnLabel" href="#" style="float: left;">Chamadas no Messenger</a>
										</div>
										<div class="panelLines" style="width: 265px;">
											<a id="msn" name="msn" href="#" style="float: right;">01</a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="sacLabel" name="sacLabel" href="#" style="float: left;">Chamadas no Sac</a>
										</div>
										<div class="panelLines" style="width: 265px;">
											<a id="sac" name="sac" href="#" style="float: right;">01</a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="postLabel" name="postLabel" href="#" style="float: left;">Novas Postagens no forum</a>
										</div>
										<div class="panelLines" style="width: 265px;">
											<a id="posts" name="posts" href="#" style="float: right;">20</a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="niverLabel" name="niverLabel" href="#" style="float: left;">Aniverssariantes</a>
										</div>
										<div class="panelLines" style="width: 265px;">
											<a id="niver" name="niver" href="#" style="float: right;">20</a>
										</div>
									</div>
									
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="agendaLabel" name="agendaLabel" href="#" style="float: left;">Compromissos Agendados</a>
										</div>
										<div class="panelLines" style="width: 265px;">
											<a id="agenda" name="agenda" href="#" style="float: right;">30</a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="agendaDiaLabel" name="agendaDiaLabel" href="#" style="float: left;">Compromissos de Hoje</a>
										</div>
										<div class="panelLines" style="width: 265px;">
											<a id="agendaDia" name="agendaDia" href="#" style="float: right;">5</a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">
											<a id="tomorrowLabel" name="tomorrowLabel" href="#" style="float: left;">Compromissos de Amanhã</a>
										</div>
										<div class="panelLines" style="width: 265px;">
											<a id="tomorrow" name="tomorrow" href="#" style="float: right;">3</a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">
											<a id="weekLabel" name="weekLabel" href="#" style="float: left;">Compromissos da Semana</a>
										</div>
										<div class="panelLines" style="width: 265px;">
											<a id="week" name="week" href="#" style="float: right;">15</a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">
											<a id="rotinaLabel" name="rotinaLabel" href="#" style="float: left;">Rotina de Trabalho</a>
										</div>
										<div class="panelLines" style="width: 265px;">
											<a id="rotina" name="rotina" href="#" style="float: right;">5</a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">
											<a id="acessoLabel" name="acessoLabel" href="#" style="float: left;">Acessos Disponíveis no Cartão</a>
										</div>
										<div class="panelLines" style="width: 265px;">
											<a id="acesso" name="acesso" href="#" style="float: right;"><%= acessos %></a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">
											<a id="pontoLabel" name="pontoLabel" href="#" style="float: left;">Cartão de Ponto</a>
										</div>
										<div class="panelLines" style="width: 265px;">
											<a id="ponto" name="ponto" href="#" style="float: right;">OK</a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">
											<a id=" discoLabel" name="discoLabel" href="#" style="float: left;">Espaço no Disco Virtual</a>
										</div>
										<div class="panelLines" style="width: 265px;">
											<a id="ponto" name="ponto" href="#" style="float: right;">50 MB</a>
										</div>
									</div>
								</div>
							</div>
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