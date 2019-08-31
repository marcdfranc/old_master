<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@page import="com.marcsoftware.database.Login"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.AcessoNotificacao"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%><html>
<%	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query = sess.createQuery("from Login as l where l.username = :username");
	query.setString("username", session.getAttribute("username").toString());
	Login login = (Login) query.uniqueResult();	
	String labelFim = " novas mensagens!";
	if (request.getParameter("tipo") != null && request.getParameter("tipo").equals("l")) {
		query = sess.createQuery("from AcessoNotificacao as a where a.id.login = :login and a.visualizada = 's'");
			query.setEntity("login", login);
		labelFim = " mensagens lidas!";		
	} else if (request.getParameter("tipo") != null && request.getParameter("tipo").equals("n")) {
		query = sess.createQuery("from AcessoNotificacao as a where a.id.login = :login and a.visualizada = 'n'");
		query.setEntity("login", login);
		labelFim= " mensagens não lidas!";
	} else if (request.getParameter("tipo") != null && request.getParameter("tipo").equals("e")) {
		query = sess.createQuery("from AcessoNotificacao as a where a.id.notificacao.remetente = :login");
		query.setEntity("login", login);
		labelFim = " mensagens enviadas!";
	} else {
		query = sess.createQuery("from AcessoNotificacao as a where a.id.login = :login and a.visualizada = 'n'");
		query.setEntity("login", login);
	}
	int visualizdas = query.list().size();
	
	
%>

<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" /> 
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>	
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/comum/notificacao.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	
	<title>Master - Notificações</title>
</head>
<body onload="load()">	
	<div id="visualizaWindow" class="removeBorda" title="Mensagem" style="display: none;">
		<input name="idLida" id="idLida" type="hidden" />
		<p id="visuRemetente"><b>Remetente:</b></p>	
		<p id="visuAssunto"><b>Assunto:</b></p>		
		<p id="visuData"><b>Data:</b></p>
		<p id="visuHora"><b>Data:</b></p><br/>
		<textarea id="visuMsg" name="visuMsg" readonly="readonly" rows="15" cols="60" class="textDialog ui-widget-content ui-corner-all"></textarea>
	</div>
	<div id="responseWindow" class="removeBorda" title="Mensagem" style="display: none;">
		<form id="respondeNotificacao" onsubmit="return false;">
			<fieldset>
				<label for="prioridade">Prioridade</label>
				<select style="width: 105px; margin-right: 15px; margin-bottom: 20px;" type="select-multiple" id="prioridade" name="prioridade" >
					<option value="b" >Baixa</option>									
					<option value="m" >Média</option>
					<option value="a" >Alta</option>
				</select>
				<label for="setBaner">Banner</label>
				<select style="width: 105px; margin-right: 15px;" type="select-multiple" id="setBaner" name="setBaner">
					<option value="a" >Exibir</option>
					<option value="i" >Não Exibir</option>
				</select><br/>
				<label for="respMsg">Mensagem</label>
				<textarea id="respMsg" name="respMsg" rows="15" cols="60" class="textDialog ui-widget-content ui-corner-all"></textarea>								
			</fieldset>
		</form>
	</div>
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
				<input type="hidden" name="tipoTela" id="tipoTela" value="<%= request.getParameter("tipo") %>" />
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Notificações"/>
					</jsp:include>
					<div id="abaMenu">
						<% if (request.getParameter("tipo") == null) {%>
							<div class="sectedAba2">
								<label>Todas</label>
							</div>
						<%} else {%>
							<div class="aba2">
								<a href="notificacao.jsp">Todas</a>
							</div>
						<%}%>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<% if (request.getParameter("tipo") != null && request.getParameter("tipo").equals("l")) {%>						
							<div class="sectedAba2">
								<label>Lidas</label>								
							</div>
						<%} else {%>
							<div class="aba2">
								<a href="notificacao.jsp?tipo=l">Lidas</a>
							</div>
						<%} %>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<% if (request.getParameter("tipo") != null && request.getParameter("tipo").equals("n")) {%>
							<div class="sectedAba2">
								<label>Não lidas</label>
							</div>
						<%} else {%>
							<div class="aba2">
								<a href="notificacao.jsp?tipo=n">Não lidas</a>
							</div>
						<%} %>
						<div class="sectedAba2">
							<label>></label>
						</div>
						<% if (request.getParameter("tipo") != null && request.getParameter("tipo").equals("e")) {%>
							<div class="sectedAba2">
								<label>Enviadas</label>								
							</div>
						<%} else {%>
							<div class="aba2">
								<a href="notificacao.jsp?tipo=e">Enviadas</a>
							</div>
						<%} %>
						<div class="sectedAba2">
							<label>></label>	
						</div>	
						<div class="aba2">
							<a href="cadastro_notificacao.jsp">Nova Notificação</a>
						</div>
					</div>
					<div class="topContent">
						<div class="indexTitle">
							<div id="fot" class="textBox"style="width: 103px; height: 137px;">
								<img src="<%=(login.getFoto() != null)? login.getFoto(): "../image/foto.gif" %>" width="103" height="137"/>
							</div>
							<h4 style="margin-left: 150px" >Usuario: <%= login.getUsername() %></h4>
							<h4 style="margin-left: 150px">Seja bem vindo a sua area de notificações.</h4>
							<h4 style="margin-left: 150px">Tenha um Bom dia!</h4>
							<div class="textBox" >
								<label class="titleCounter" style="float: left; margin-top: 30px; margin-left: 20px; position: absolute;">Você tem <%= visualizdas + "" + labelFim %></label>
							</div>
						</div>
					</div>
				</div>
				<div id="mainContent">
					<div id="dadosPessoais" class="bigBox" >
						<div class="indexTitle">
							<h4>Histórico de Notificações</h4>
							<div class="alignLine">
								<hr>
							</div>
							<div id="counter" class="counter"></div>
							<div id="dataGrid">
							<%
								if (request.getParameter("tipo") != null && request.getParameter("tipo").equals("l")) {
									query = sess.createQuery("from AcessoNotificacao as a where a.id.login = :login " +
										" and a.visualizada = 's' order by a.visualizada, a.id.notificacao.data desc");
								} else if (request.getParameter("tipo") != null && request.getParameter("tipo").equals("n")) {
									query = sess.createQuery("from AcessoNotificacao as a where a.id.login = :login " +
										" and a.visualizada = 'n' order by a.visualizada , a.id.notificacao.data desc");
								} else if (request.getParameter("tipo") != null && request.getParameter("tipo").equals("e")) {
									query = sess.createQuery("from AcessoNotificacao as a " + 
										" where a.id.notificacao.remetente = :login " +
										" order by a.visualizada , a.id.notificacao.data desc");
								} else {
									query = sess.createQuery("from AcessoNotificacao as a where a.id.login = :login " +
										" and a.visualizada not in('e') order by a.visualizada, a.id.notificacao.data desc");
								}
								query.setEntity("login", login);
								int gridLines = query.list().size();
								query.setFirstResult(0);
								query.setMaxResults(30);
								List<AcessoNotificacao> notificacaoList = (List<AcessoNotificacao>) query.list();
								DataGrid dataGrid = new DataGrid(null);
								dataGrid.addColumWithOrder("24", "Remetente", false);
								dataGrid.addColumWithOrder("44", "Assunto", false);
								dataGrid.addColumWithOrder("20", "Data", true);
								dataGrid.addColum("10", "Hora");
								dataGrid.addColum("2", "St.");
								for(AcessoNotificacao notificacao : notificacaoList) {
									dataGrid.setId(String.valueOf(notificacao.getId().getNotificacao().getCodigo()));									
									dataGrid.addData(notificacao.getId().getNotificacao().getRemetente().getUsername());
									dataGrid.addData(notificacao.getId().getNotificacao().getAssunto());
									dataGrid.addData(Util.parseDate(notificacao.getId().getNotificacao().getData(), "dd/MM/yyyy"));
									dataGrid.addData(Util.getTime(notificacao.getId().getNotificacao().getData()));
									if (notificacao.getVisualizada().equals("s")) {
										dataGrid.addImg("../image/ok_icon.png");
									} else {
										dataGrid.addImg("../image/em_aberto.gif");
									}
									dataGrid.addRow();
								}
								out.print(dataGrid.getTable(gridLines));
							%>
							</div>
							<div id="pagerGrid" class="pagerGrid"></div>
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