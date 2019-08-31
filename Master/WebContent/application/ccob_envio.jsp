<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@page import="com.marcsoftware.database.CobrancaCcob"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Plano"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%List<Unidade> unidadeList;
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
	
	if (session.getAttribute("perfil").equals("a")) {
		query= sess.createQuery("from Unidade as u where u.deleted =\'n\'");		
	} else if (session.getAttribute("perfil").equals("f")) {
		query= sess.getNamedQuery("unidadeByUser");
		query.setString("username", (String) session.getAttribute("username"));
	} else {
		query = sess.createQuery("select p.unidade from Pessoa as p where p.login = :username");
		query.setString("username", (String) session.getAttribute("username"));
	}
	
	unidadeList= (List<Unidade>) query.list();
	
	
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->

	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master - Planos</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<%if ((session.getAttribute("perfil").equals("a")) 
			|| (session.getAttribute("perfil").equals("f"))) {%>
		<script type="text/javascript" src="../js/comum/ccob_envio.js" ></script>
	<%}%>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>	
	<script type="text/javascript" src="../js/lib/mask.js"></script>
</head>
<body  >
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="financeiro"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="financeiro"/>
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="post" action="../CadastroPosicao">
				<div id="geralDate" class="alignHeader">
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Hist. Envios"/>			
					</jsp:include>
					<div id="abaMenu">							
						<div class="aba2">
							<a href="cobranca_automatica.jsp?">Tela inicial</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>							
						<div class="sectedAba2">
							<label>Histórico de Remessas</label>
						</div>
						
						<div class="aba2">
							<a href="http://app.sacmaster.web1211.kinghost.net" target="blank">Processamento de Retornos</a>
						</div>
					</div>
					<div class="topContent">
						<div id="unidadeIn" class="textBox">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId" style="width: 200px;" >								
								<% for(Unidade und: unidadeList) {
										out.print("<option value=\"" + und.getCodigo() + 
												"\">" + und.getReferencia() + " - " + und.getDescricao() + "</option>");										
									}							
								%>
							</select>
						</div>
						<div class="textBox" style="width: 90px;">
							<label>Data de Inicio</label><br/>
							<input id="inicio" name="inicio" type="text" style="width: 90px;" onkeydown="mask(this, dateType);"/>
						</div>
						<div class="textBox" style="width: 90px;">
							<label>Data Final</label><br/>
							<input id="fim" name="fim" type="text" style="width: 90px;" onkeydown="mask(this, dateType);"/>
						</div>
					</div>
				</div>
				<div class="topButtonContent">
					<div class="formGreenButton">
						<input id="insercao" name="insercao" class="greenButtonStyle" type="button" value="Buscar" onclick="search();"/>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%
						query = sess.createQuery("from CobrancaCcob c where c.unidade = :unidade order by c.cadastro DESC");
						query.setEntity("unidade", unidadeList.get(0));
						int gridLines = query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(30);
						DataGrid dataGrid;
						List<CobrancaCcob> ccobs = (List<CobrancaCcob>) query.list();
						if (session.getAttribute("perfil").toString().trim().equals("a")
								|| session.getAttribute("perfil").toString().trim().equals("d")) {
							 //dataGrid = new DataGrid("../Centercob", true);							
							 dataGrid = new DataGrid(null);							
						} else {
							dataGrid = new DataGrid("#");
						}
						dataGrid.addColum("10", "Código");
						dataGrid.addColum("30" ,"Unidade");
						dataGrid.addColum("35" ,"Nome do Arquivo");
						if (request.getSession().getAttribute("perfil").toString().trim().equals("a")				
								|| request.getSession().getAttribute("perfil").toString().trim().equals("d")) {
							dataGrid.addColum("21" ,"Cadastro");
							dataGrid.addColum("2" ,"St");			
							dataGrid.addColum("2" ,"Ck");							
						} else {
							dataGrid.addColum("23" ,"Cadastro");
							dataGrid.addColum("2" ,"St");
						}
						for(CobrancaCcob ccob: ccobs) {							
							dataGrid.setId(String.valueOf(ccob.getCodigo()));
							
							dataGrid.addData("codigo" + ccob.getCodigo(), 
									String.valueOf(ccob.getCodigo()), false);
							
							dataGrid.addData("unidade" + ccob.getCodigo(), 
									ccob.getUnidade().getReferencia() + " - "
									+ ccob.getUnidade().getDescricao(), false);
							dataGrid.addData("descricao" + ccob.getCodigo(), ccob.getDescricao(), false);
							
							dataGrid.addData("cadastro" + ccob.getCodigo(), Util.parseDate(
									ccob.getCadastro(), "dd/MM/yyyy"), false);
							dataGrid.addImg(ccob.getEnviado().equals("n")? "../image/em_aberto.gif" 
									: "../image/fechado.gif");
							if (request.getSession().getAttribute("perfil").toString().trim().equals("a")				
									|| request.getSession().getAttribute("perfil").toString().trim().equals("d")) {
								dataGrid.addCheck(true);
							}
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));
						%>
						<div id="pagerGrid" class="pagerGrid"></div>
					</div>
				</div>
					<div class="buttonContent" style="margin: 70px 112px 0 0">
						<div class="formGreenButton" >
							<input  class="greenButtonStyle" type="button" value="Marcar" onclick="marcarEnviado();"/>
						</div>
					</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>