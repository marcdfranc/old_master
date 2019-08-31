<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Relatorio"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Parametro"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%!boolean isEdition= false;%>
	<%isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}%>
	
	<jsp:useBean id="relatorio" class="com.marcsoftware.database.Relatorio"></jsp:useBean>	
	
	<%
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
	if (isEdition) {
		query= sess.createQuery("from Relatorio as r where r.codigo = :codigo");
		query.setLong("codigo", Long.valueOf(request.getParameter("id")));
		relatorio = (Relatorio) query.uniqueResult();		
	}	
	%>
	
<head>
	<link rel="shortcut icon" href="../icone.ico">	
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
		
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/comum/cadastro_relatorio.js" ></script>

<title>Master Cadastro de Relatórios</title>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="rel"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="rel"/>
		</jsp:include>
		<div id="formStyle">		
			<form id="formPost" method="post" action="../CadastroRelatorio" onsubmit= "return validForm(this)">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Relatórios"/>			
					</jsp:include>
					<div>
						<input id="codRel" name="codRel" type="hidden" value="<%=(isEdition)? relatorio.getCodigo() : "" %>"/>
					</div>
					<div class="topContent">					
						<%if (isEdition) {%>
							<div id="codigo" class="textBox" style="width: 75px;" >
								<label>Código</label><br/>
								<input id="codigoIn" name="codigoIn" type="text" style="width: 75px;" value="<%= relatorio.getCodigo() %>" enable="false" readonly="readonly"/>
							</div>
						<%}%>
						<div class="textBox">
							<label>Dinâmico</label><br/>
							<select id="dinamicoIn" name="dinamicoIn">																
								<option value="">Selecione</option>
								<option value="t" <%
									if (isEdition) {
										if(relatorio.getDinamico().trim().equals("t")) {
											out.print("selected=\"selected\"");
										}
									}
								%>>Sim</option>
								<option value="f" <%
									if (isEdition) {
										if(relatorio.getDinamico().trim().equals("f")) {
											out.print("selected=\"selected\"");
										}
									}
								%>>Não</option>
							</select>
						</div>
						<div id="nome" class="textBox" style="width: 320px;" >
							<label>Nome</label><br/>
							<input id="nomeIn" name="nomeIn" type="text" style="width: 320px;" value="<%=(isEdition)? relatorio.getNome(): "" %>" class="required" onblur="genericValid(this);"/>
						</div>
						<div id="tela" class="textBox" style="width: 120px;" >
							<label>Tela</label><br/>
							<input id="telaIn" name="telaIn" type="text" style="width: 120px;" value="<%=(isEdition)? relatorio.getTela(): "" %>" class="required" onblur="genericValid(this);"/>
						</div>
						<div id="path" class="textBox" style="width: 315px;" >
							<label>Path</label><br/>
							<input id="pathIn" name="pathIn" type="text" style="width: 315px;" value="<%=(isEdition)? relatorio.getPath(): "" %>" class="required" onblur="genericValid(this);"/>
						</div>												
						<div id="descricao" class="textBox" style="width: 315px;" >
							<label>Descrição</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 315px;" value="<%=(isEdition)? relatorio.getDescricao(): "" %>" class="required" onblur="genericValid(this);"/>
						</div>
						<div id="width" class="textBox" style="width: 80px;" >
							<label>Width</label><br/>
							<input id="widthIn" name="widthIn" type="text" style="width: 80px;" value="<%=(isEdition)? relatorio.getWidthFiltro(): "" %>" class="required" onblur="genericValid(this);"/>
						</div>
						<div id="height" class="textBox" style="width: 80px;" >
							<label>Height</label><br/>
							<input id="heightIn" name="heightIn" type="text" style="width: 80px;" value="<%=(isEdition)? relatorio.getHeightFiltro(): "" %>" class="required" onblur="genericValid(this);"/>
						</div>
						<div class="textBox">
							<label>Tipo</label><br/>
							<select id="tipoIn" name="tipoIn">																
								<option value="">Selecione</option>
								<option value="j" <%
									if (isEdition) {
										if(relatorio.getTipo().trim().equals("j")) {
											out.print("selected=\"selected\"");
										}
									}
								%>>Jasper</option>
								<option value="b" <%
									if (isEdition) {
										if(relatorio.getTipo().trim().equals("b")) {
											out.print("selected=\"selected\"");
										}
									}
								%>>Birt</option>
							</select>
						</div>
						<div class="textBox" style="width: 15px">
							<label>Vizualização</label><br/>
							<select id="birtView" name="birtView">																
								<option value="">Selecione</option>
								<option value="b" <%
									if (isEdition && relatorio.getTipo().trim().equals("b")) {
										if(relatorio.getDinamico().trim().equals("b")) {
											out.print("selected=\"selected\"");
										}
									}
								%>>Birt Viewer</option>
								<option value="p" <%
									if (isEdition && relatorio.getTipo().trim().equals("b")) {
										if(relatorio.getDinamico().trim().equals("p")) {
											out.print("selected=\"selected\"");
										}
									}
								%>>pdf</option>
								<option value="h" <%
									if (isEdition && relatorio.getTipo().trim().equals("b")) {
										if(relatorio.getDinamico().trim().equals("h")) {
											out.print("selected=\"selected\"");
										}
									}
								%>>HTML</option>							
							</select>
						</div>
					</div>
				</div>
				<div id="mainContent">
					<div id="caixasTexto" class="bigBox" >
						<div class="area" id="comando" name="comando" style="margin-bottom: 30px">
							<label>Comando</label><br/>
							<textarea cols="112"  rows="20" id="comandoIn" name="comandoIn" id="obsIn"><%=(isEdition && relatorio.getComando() != null)? relatorio.getComando() : ""%></textarea>
						</div>
					</div>
					<div id="caixasTexto" class="bigBox" >
						<div class="area" id="ordem" name="comando" style="margin-bottom: 30px">
							<label>Order by</label><br/>
							<textarea cols="112"  rows="5" id="ordemIn" name="ordemIn" id="obsIn"><%=(isEdition && relatorio.getOrdem() != null)? relatorio.getOrdem() : ""%></textarea>
						</div>
					</div>					
					<div id="endPage" class="bigBox" >
						<div class="indexTitle">
							<h4>&nbsp;</h4>
						</div>
					</div>
					<div class="buttonContent" >
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="submit" value="Salvar" />
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