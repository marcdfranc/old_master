<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.TipoConta"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/comum/tipo_conta.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master - Cadastro Tipo de Contas</title>
</head>
<body onload="load();">
	<div id="editaWindow" class="removeBorda" title="Edição" style="display: none;">			
		<form id="formEditTp" onsubmit="return false;">
			<fieldset>
				<label for="descricaoPop">Digite a nova descrição para o Tipo de conta selecionado.</label>
				<input type="text" name="descricaoPop" id="descricaoPop" class="textDialog ui-widget-content ui-corner-all"/>
				<%if (session.getAttribute("perfil").toString().equals("d")) {%>
					<label for="admPop">Adm</label>				
					<br />
					<select id="admPop" name="admPop">
						<option value="s">Sim</option>
						<option value="n">Não</option>
					</select>					
				<%}%>
			</fieldset>
		</form>
	</div>
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
						<jsp:param name="currPage" value="Tipos de Conta"/>			
					</jsp:include>
					<div class="topContent">
						<div id="descricao" class="textBox" style="width: 280px;">
							<label style="margin-left: 190px;">Descrição</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 280px; margin-left: 190px" class="required" />
						</div>
						<%if (session.getAttribute("perfil").toString().equals("d")) {%>
							<div id="adm" class="textBox">
								<label style="margin-left: 190px;">Adm</label><br/>
								<select id="admIn" name="admIn" style="margin-left: 190px;">
									<option value="s">Sim</option>
									<option value="n">Não</option>
								</select>
							</div>
						<%}%>
					</div>					
				</div>
				<div class="topButtonContent" >
					<div class="formGreenButton">
						<input id="inserir" name="inserir" class="greenButtonStyle" onclick="addRecord();" type="button" value="Inserir"/>
					</div>
				</div>
				<div id="mainContent">				
					<div id="dataGrid" style="" >
						<div id="centerGrid" style="min-height: 100px; margin-left: 193px; width: 450px">
							<div id="counter" style="width: 800px; float:left; margin-bottom: 5px" ></div>
							<%
							DataGrid dataGrid = new DataGrid(null);
							Session sess = (Session) session.getAttribute("hb");
							if (!sess.isOpen()) {
								sess = HibernateUtil.getSession();
							}
							Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
							Query query;
							if (session.getAttribute("perfil").equals("d")) {
								query = sess.createQuery("from TipoConta as t order by t.codigo");								
							} else {
								query = sess.createQuery("from TipoConta as t where t.administrativo = 'n' order by t.codigo");
							}
							int gridLines = query.list().size();
							query.setFirstResult(0);
							query.setMaxResults(30);
							List<TipoConta> conta = (List<TipoConta>) query.list();
							if (session.getAttribute("perfil").toString().equals("d")) {
								dataGrid.addColum("15", "Código");
								dataGrid.addColum("70", "Descrição");
								dataGrid.addColum("15", "Adm");
							} else {
								dataGrid.addColum("15", "Código");
								dataGrid.addColum("85", "Descrição");
							}
							if (conta != null) {
								for (TipoConta ct: conta) {
									dataGrid.setId(String.valueOf(ct.getCodigo()));
									dataGrid.addData(String.valueOf(ct.getCodigo()));
									dataGrid.addData(Util.initCap(ct.getDescricao()));
									if (session.getAttribute("perfil").toString().equals("d")) {
										dataGrid.addData((ct.getAdministrativo().equals("s"))? "Sim" : "Não");
									}
									dataGrid.addRow();
								}
							}
							out.print(dataGrid.getTable(gridLines));
							sess.close();
							%>
						</div>
						<div id="pagerGrid" class="pagerGrid" style="width: 500px; margin-right: 55px; margin-bottom: 30px"></div>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
	</div>
</body>
</html>