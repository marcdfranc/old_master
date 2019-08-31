<%@page import="com.marcsoftware.database.Video"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Session"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<jsp:useBean id="video" class="com.marcsoftware.database.Video"></jsp:useBean>
	<%boolean isEdition= false;
	isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}
	
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query = null;
	
	if (isEdition) {
		video = (Video) sess.load(Video.class, Long.valueOf(request.getParameter("id")));
	}
	
	%>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="shortcut icon" href="../icone.ico">	
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/validation.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/comum/cadastro_video.js" ></script>
	<script type="text/javascript" src="../js/lib/pilot_grid.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>	
	<title>Master Cadastro de Clientes Físicos</title>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="adm"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="adm"/>
		</jsp:include>
		<div id="formStyle">		
			<form id="formPost" method="post" action="../CadastroVideo " onsubmit= "return validForm(this)">
				<input id="codVideo" name="codVideo" type="hidden" value="<%=(isEdition)? video.getCodigo(): "" %>" />
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Vídeo"/>			
					</jsp:include>
					
					<div class="topContent">						
						<div class="textBox" style="width: 180px;">
							<label>Categoria</label><br/>
							<select id="menuIn" name="menuIn" style="width: 180px;">
 								<option <%if (isEdition && video.getMenu().equals("unidade")) { %>selected="selected"<% } %> value="unidade">Unidade</option>
 								<option <%if (isEdition && video.getMenu().equals("clienteF")) { %>selected="selected" <% } %> value="clienteF">Cliente Físico</option>
 								<option <%if (isEdition && video.getMenu().equals("clienteJ")) { %>selected="selected" <% } %> value="clienteJ">Cliente Jurídico</option>
 								<option <%if (isEdition && video.getMenu().equals("rh")) { %>selected="selected" <% } %> value="rh">RH</option>
 								<option <%if (isEdition && video.getMenu().equals("financeiro")) { %>selected="selected" <% } %> value="financeiro">Financeiro</option>
 								<option <%if (isEdition && video.getMenu().equals("profissional")) { %>selected="selected" <% } %> value="profissional">Profissional</option>
 								<option <%if (isEdition && video.getMenu().equals("servico")) { %>selected="selected" <% } %> value="servico">Planos</option>
 								<option <%if (isEdition && video.getMenu().equals("orcamento")) { %>selected="selected" <% } %> value="orcamento">Orçamento</option>
 								<option <%if (isEdition && video.getMenu().equals("orcamentoEmp")) { %>selected="selected" <% } %> value="orcamentoEmp">Orçamento de Empresas</option>
 								<option <%if (isEdition && video.getMenu().equals("fornecedor")) { %>selected="selected" <% } %> value="fornecedor">Fornecedor</option>
 								<option <%if (isEdition && video.getMenu().equals("prestador")) { %>selected="selected" <% } %> value="prestador">Prestador de Serviços</option>
 								<option <%if (isEdition && video.getMenu().equals("empSaude")) { %>selected="selected" <% } %> value="empSaude">Empresa de Saúde</option>
 								<option <%if (isEdition && video.getMenu().equals("forum")) { %>selected="selected" <% } %> value="forum">Intranet</option>
 								<option <%if (isEdition && video.getMenu().equals("adm")) { %>selected="selected" <% } %> value="adm">ADM</option>
							</select>
						</div>
						
						<div id="titulo" class="textBox" style="width: 300px;" >
							<label>Titulo</label><br/>
							<input id="tituloIn" name="tituloIn" type="text" style="width: 300px;" value="<%=(isEdition)? Util.initCap(video.getTitulo()): "" %>" class="required" onblur="genericValid(this);"/>
						</div>
						
						<div id="url" class="textBox" style="width: 150px;" >
							<label>Id do video</label><br/>
							<input id="urlIn" name="urlIn" type="text" style="width: 150px;" value="<%=(isEdition)? Util.initCap(video.getUrl()): "" %>" class="required" onblur="genericValid(this);"/>
						</div>
					
					</div>
					
				</div>
				<div class="topButtonContent" style="margin-bottom: 130px">	
					<div class="formGreenButton">
						<input class="greenButtonStyle" type="submit" value="Salvar" />
					</div>
					<div class="formGreenButton">
						<input class="greenButtonStyle" type="button" value="Excluir" onclick="excluiVideo()" />
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>