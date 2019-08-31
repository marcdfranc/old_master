<%@page import="com.marcsoftware.database.Profissional"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
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
<html>
<head>	
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link rel="StyleSheet" href="../css/calendario.css" type="text/css" />
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Master Odontologia e Saúde</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/comum/agenda_profissional.js"></script>
	<script type="text/javascript" src="../js/jquery/calendario.js"></script>
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
					<div id="calendar-content">
						
					
					</div>					
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
	</div>
</body>
</html>