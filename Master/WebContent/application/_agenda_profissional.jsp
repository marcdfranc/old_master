<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@page import="com.marcsoftware.database.Profissional"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="com.marcsoftware.database.Login"%><html xmlns="http://www.w3.org/1999/xhtml">
<%	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query = sess.createQuery("from Login as l where l.username = :username");
	query.setString("username", session.getAttribute("username").toString());
	Login login = (Login) query.uniqueResult();
	Profissional profissional = (Profissional) sess.load(Profissional.class, Long.valueOf(request.getParameter("id")));
%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Agenda Pessoal</title>
	
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<link rel='stylesheet' type='text/css' href='../js/jquery/fullcalendar/fullcalendar.css' />
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type='text/javascript' src='../js/jquery/fullcalendar/fullcalendar.js'></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>	
	<script type="text/javascript" src="../js/comum/agenda_profissional.js"></script>
	
</head>
<body>
	<input type="hidden" id="idProfissional" name="idProfissional" value="<%= request.getParameter("id") %>" />
	<div id="windowAgenda" class="removeBorda" title="Evento" style="display: none;">
		<form id="formGrupo" onsubmit="return false;">
			<fieldset>
				<label for="descricao">Nome</label>
				<input type="text" name="descricao" id="descricao" class="textDialog ui-widget-content ui-corner-all" />
				<label for="inicio">Data Inícial</label>
				<input type="text" name="inicio" id="inicio" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, dateType);"/>
				<label for="horaInicio">Hora Inícial</label>
				<input type="text" name="horaInicio" id="horaInicio" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, tipoHora);"/>
				<label for="fim">Data Final</label>
				<input type="text" name="fim" id="fim" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, dateType);"/>
				<label for="horaFim">Hora Final</label>
				<input type="text" name="horaFim" id="horaFim" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, tipoHora);"/>				
				<label for="obs">Observações</label>
				<textarea rows="5" class="textDialog ui-widget-content ui-corner-all" id="obs" name="obs"></textarea>
			</fieldset>
		</form>
	</div>
	<div id="windowNota" class="removeBorda" title="Bloco de Notas" style="display: none">
		<form id="formNota" onsubmit="return false;">
			<fieldset>
				<label for="blcNota">Notas</label>
				<textarea name="blcNota" id="blcNota" class="textDialog ui-widget-content ui-corner-all" rows="30" ><%=(login.getBlocoNotas() == null)? "" : login.getBlocoNotas() %></textarea>
			</fieldset>
		</form>
	</div>
	<div id="windowReport" class="removeBorda" title="Evento" style="display: none;">
		<form id="formReport" onsubmit="return false;">
			<fieldset>				
				<label for="dtInicio">Data Inícial</label>
				<input type="text" name="dtInicio" id="dtInicio" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, dateType);"/>
				<label for="hrInicio">Hora Inícial</label>
				<input type="text" name="hrInicio" id="hrInicio" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, tipoHora);"/>
				<label for="dtFim">Data Final</label>
				<input type="text" name="dtFim" id="dtFim" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, dateType);"/>
				<label for="hrFim">Hora Final</label>
				<input type="text" name="hrFim" id="hrFim" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, tipoHora);"/>
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
			<form id="formPost" name="formPost" method="post" action="../CadastroTabelaFranchising"  onsubmit= "return validForm(this)" >
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Agenda Pessoal"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="cadastro_profissional.jsp?state=1&id=<%= profissional.getCodigo()%>">Cadastro</a>
						</div>								
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="anexo_profissional.jsp?id=<%= profissional.getCodigo()%>">Anexo</a>
						</div>
						
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Agenda</label>
						</div>
						
						
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="bordero_profissional.jsp?id=<%= profissional.getCodigo()%>">Borderô</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="cadastro_bordero.jsp?id=<%= profissional.getCodigo()%>">Cadastro de Fatura</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="fatura_bordero_profissional.jsp?id=<%= profissional.getCodigo()%>">Histórico de Faturas</a>
						</div>
					</div>
					<div class="topContent">
						<div class="indexTitle">
							<div id="fot" class="textBox"style="width: 103px; height: 137px;">
								<img src="<%=(profissional.getLogin() != null && profissional.getLogin().getFoto() != null)? profissional.getLogin().getFoto(): "../image/foto.gif" %>" width="103" height="137"/>
							</div>
							<h4 style="margin-left: 150px" >Profissional: <%= Util.initCap(profissional.getNome()) %></h4>
							<h4 style="margin-left: 150px">Bem vindo a Área de Agendamento de Consultas.</h4>
							<h4 style="margin-left: 150px">Tenha um Bom dia!</h4>
						</div>
					</div>
				</div>
				<div id="mainContent">
					<div class="indexTitle" style="margin-top: 15px !important; margin-bottom: 15px !important; width: 956px !important"><div id='calendar'></div></div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
	</div>
</body>
</html>