<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.database.Funcionario"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Funcionario funcionario = (Funcionario) sess.get(Funcionario.class, Long.valueOf(request.getParameter("id")));
	%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->		
	
	<title>Master Requisição de Contrato</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/pilot_grid.js" ></script>
	<script type="text/javascript" src="../js/comum/requisicao_contrato.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
</head>
<body onload="load()">
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="rh"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="rh"/>
		</jsp:include>
		<div id="formStyle">		
			<form id="formPost" method="post" action="../CadastroContrato" onsubmit= "return validForm(this)">
				<input type="hidden" id="unidadeId" name="unidadeId" value="<%= funcionario.getUnidade().getCodigo() %>" />
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Requisição CTR's"/>
					</jsp:include>
					<div id="localCtr"></div>
					<div id="editedsCtr"></div>
					<div id="deletedsCtr"></div>
					<input id="edCtr" name="edCtr" type="hidden" value="n"/>
					<input id="idFuncionario" name="idFuncionario" type="hidden" value="<%= funcionario.getCodigo()%>" />
					<div id="abaMenu">
						<div class="aba2">
							<a href="cadastro_funcionario.jsp?state=1&id=<%= funcionario.getCodigo()%>">Cadastro</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="anexo_rh.jsp?id=<%= funcionario.getCodigo()%>">Anexo</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Requisição</label>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="contrato.jsp?state=1&id=<%= funcionario.getCodigo()%>">Contratos</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>						
						<div class="aba2">
							<a href="bordero_funcionario.jsp?state=1&id=<%= funcionario.getCodigo()%>">Borderô</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="fatura_vendedor.jsp?id=<%= funcionario.getCodigo()%>">Histórico de Faturas</a>
						</div>
					</div>
					<div class="topContent">						
						<div id="requisicao" class="textBox" style="width: 73px;">
							<label>Requisicao</label><br/>
							<input id="requisicaoIn" name="requisicaoIn" type="text" style="width: 73px;" value="<%= Util.getToday() %>" onkeydown="mask(this, typeDate);"/>
						</div>
						<div id="nome" class="textBox" style="width: 270px;">
							<label>Funcionário</label><br/>
							<input id="nomeIn" name="nomeIn" type="text" style="width: 270px;" readonly="readonly" value="<%=Util.initCap(funcionario.getNome()) %>" enable="false"/>
						</div>
						<div id="unidade" class="textBox" style="width: 73px;">
							<label>Unidade</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" readonly="readonly" style="width: 73px;" value="<%= funcionario.getUnidade().getReferencia() %>"/>
						</div>
						<div id="qtde" class="textBox" style="width: 73px;">
							<label>Qtde</label><br/>
							<input id="qtdeIn" name="qtdeIn" type="text" readonly="readonly" style="width: 73px;" value="" onkeydown="mask(this, onlyInteger);"/>
						</div>
					</div>
				</div>
				<div class="topButtonContent">					
					<div class="formGreenButton" id="periodoBt" name="periodoBt">
						<input id="periodo" name="periodo" class="greenButtonStyle" type="button" value="Por Lote" onclick="byPeriodo()"/>
					</div>
					<div class="formGreenButton" id="ctrSelecaoBt" name="ctrSelecaoBt">
						<input id="ctrBt" name="ctrBt" class="greenButtonStyle" type="button" value="Por CTR" onclick="bySelecao()"/>
					</div>
				</div>
				<div id="mainContent">
					<div id="dadosPessoais" class="bigBox" >
						<div class="indexTitle">
							<h4>CTR's</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div id="tableCtr" class="multGrid"></div>
						<div class="area cpEsconde" id="ctrArea" name="ctrArea">
							<label>CTRs</label><br/>
							<textarea cols="112"  rows="3" id="ctrAreaIn" name="ctrAreaIn"></textarea>								
						</div>												
					</div>
					<div id="bottonButton" class="buttonContent cpEsconde" >
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="submit" value="Salvar" />
						</div>
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Inserir" onclick="insereCtr()" />
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