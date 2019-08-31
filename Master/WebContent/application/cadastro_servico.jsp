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
<%@page import="com.marcsoftware.database.Especialidade"%>
<%@page import="com.marcsoftware.database.Tabela"%>
<%@page import="com.marcsoftware.database.Servico"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<html xmlns="http://www.w3.org/1999/xhtml">
	<%!boolean isEdition= false;%>
	<%isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}%>		
	
	<jsp:useBean id="servico" class="com.marcsoftware.database.Servico"></jsp:useBean>
	
	<%
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query= sess.createQuery("from Especialidade");
	List<Especialidade> especialidade = (List<Especialidade>) query.list();	
	if(isEdition) {
		query= sess.createQuery("from Servico as s where s.codigo = :codigo");
		query.setLong("codigo", Long.valueOf(request.getParameter("id")));
		servico= (Servico) query.uniqueResult();
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
	<script type="text/javascript" src="../js/lib/validation.js" ></script>	
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/comum/cadastro_servico.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	
	<title>Master - Cadastro Serviços</title>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="servico"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="servico"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formPost" method="post" action="../CadastroServico" onsubmit= "return validForm(this)">
				<div>
					<input id="codServico" name="codServico" type="hidden" value="<%=(isEdition)? servico.getCodigo(): "" %>" />
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Procedimentos"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="servico.jsp">Procedimentos</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Novo Cadastro</label>
						</div>						
					</div>
					<div class="topContent">
						<div id="codigo" class="textBox" style="width: 50px;">
							<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 50px;" <%if (isEdition
									&& (!request.getSession().getAttribute("perfil").equals("a"))
									&& (!request.getSession().getAttribute("perfil").equals("d"))) { out.print("readonly=\"readonly\""); } %> value="<%=(isEdition)? servico.getReferencia() : "" %>" class="required" onblur="genericValid(this);" />
						</div>
						<div id="setor" class="textBox">
							<label>Atividade</label><br/>
							<select type="select-multiple" id="setorIn" name="setorIn" class="required" onblur="genericValid(this);">
								<option value="">Selecione</option>
								<option <%if (isEdition && servico.getEspecialidade().getSetor().equals("o")) {
									out.print("selected=\"selected\"");
								}%> value="o">Odontológica</option>								
								<option <%if (isEdition && servico.getEspecialidade().getSetor().equals("l")) {
									out.print("selected=\"selected\"");
								}%> value="l">Laboratorial</option>
								<option <%if (isEdition && servico.getEspecialidade().getSetor().equals("m")) {
									out.print("selected=\"selected\"");
								}%> value="m">Médica</option>
								<option <%if (isEdition && servico.getEspecialidade().getSetor().equals("h")) {
									out.print("selected=\"selected\"");
								}%> value="h">Hospitalar</option>	
								
								<option value="a" 
									<%if (isEdition && servico.getEspecialidade().getSetor().trim().equals("a")) {
										out.print("selected=\"selected\"");
									}%>>Administrativa</option>									
								<option value="e" 
									<%if (isEdition && servico.getEspecialidade().getSetor().trim().equals("e")) {
										out.print("selected=\"selected\"");
									}%>>Estética</option>
								<option value="n" <%if (isEdition && servico.getEspecialidade().getSetor().trim().equals("n")) {
										out.print("selected=\"selected\"");
									}%>>Ensino</option>						
								<option value="p"
									<%if (isEdition && servico.getEspecialidade().getSetor().trim().equals("p")) {
										out.print("selected=\"selected\"");
									}%>>Prest. de Serviços</option>						
								<option value="j" 
									<%if (isEdition && servico.getEspecialidade().getSetor().trim().equals("j")) {
										out.print("selected=\"selected\"");
									}%> >Jurídica</option>						
								<option value="u"
									<%if (isEdition && servico.getEspecialidade().getSetor().trim().equals("u")) {
										out.print("selected=\"selected\"");
									}%>>Automobilistica</option>
								<option value="c" 
									<%if (isEdition && servico.getEspecialidade().getSetor().trim().equals("c")) {
										out.print("selected=\"selected\"");
									}%>>Construção Cívil</option>
							</select>
						</div>
						<div id="especialidade" class="textBox">
							<label>Setor</label><br/>
							<select type="select-multiple" id="especialidadeIn" name="especialidadeIn" class="required" onblur="genericValid(this);">
								<option value="">Selecione</option>
								<%for(Especialidade esp: especialidade) {
									if (isEdition && servico.getEspecialidade().equals(esp)) {
										out.print("<option value=\"" + esp.getCodigo() +
												"\" selected=\"selected\">" + esp.getDescricao() + "</option>");
									} else {
										out.print("<option value=\"" + esp.getCodigo() +
												"\">" + esp.getDescricao() + "</option>");
									}
								}%>
							</select>
						</div>
						<div id="descricao" class="textBox" style="width: 250px;">
							<label>Descricao</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 250px;" value="<%=(isEdition)? Util.initCap(servico.getDescricao()): "" %>" class="required" enable="false" onblur="genericValid(this);" />
						</div>
					</div>
				</div>
				<div id="mainContent">
					<div class="topButtonContent" >
						<div class="formGreenButton">
							<%if (session.getAttribute("perfil").toString().trim().equals("d")
									|| session.getAttribute("perfil").toString().trim().equals("a")) {%>
								<input class="greenButtonStyle" style="margin-top: 70px;" type="submit" value="Salvar" />
							<%} else {%>
								<input class="greenButtonStyle" style="margin-top: 70px;" type="button" value="Salvar" onclick="noAccess()"/>
							<%}%>
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