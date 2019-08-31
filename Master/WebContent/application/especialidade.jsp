<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Especialidade"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<% String origem= request.getParameter("origem"); %>	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/comum/especialidade.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
		
<title>Master Especialidade</title>
</head>
<body onload="load();" >
	<div id="editWindow" class="removeBorda" title="Edição de Especialidades" style="display: none;">
		<form id="formPagamento" onsubmit="return false;">
			<fieldset>
				<label for="descEspecialidade">Digite a nova descrição para o setor atual.</label>
				<input type="text" name="descEspecialidade" id="descEspecialidade" class="textDialog ui-widget-content ui-corner-all" />
				<label for="setorWin">Atividade</label><br/>
				<select id="setorWin" name="setorWin" style="width: 100%">					
					<option value="o">Odontológico</option>								
					<option value="l">Laboratorial</option>
					<option value="m">Médico</option>
					<option value="h">Hospitalar</option>
					<option value="a">Administrativa</option>
					<option value="e">Estética</option>
				</select><br/>
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>
	<%if ((origem.equals("serv"))) {%>
		<jsp:include page="../inc/menu.jsp">
			<jsp:param name="currentPage" value="servico"/>
		</jsp:include>
	<%} else {%>
		<jsp:include page="../inc/menu.jsp">
			<jsp:param name="currentPage" value="profissional"/>
		</jsp:include>	
	<%}%>
	<div id="centerAll">
		<%if ((origem.equals("serv"))) {%>
			<jsp:include page="../inc/submenu.jsp">
				<jsp:param name="currentPage" value="servico"/>
			</jsp:include>
		<%} else {%>
			<jsp:include page="../inc/submenu.jsp">
				<jsp:param name="currentPage" value="profissional"/>
			</jsp:include>
		<%}%>		
		<div id="formStyle">
			<form id="unit" method="post" action="../CadastroPosicao">
				<div id="geralDate" class="alignHeader">
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Especialidades"/>			
					</jsp:include>					
					<div class="topContent">
						<div id="setor" class="textBox" style="margin-left: 170px; width: 110px">
							<label>Atividade</label><br/>
							<select type="select-multiple" id="setorIn" name="setorIn" style="width: 110px">
								<option value="">Selecione</option>
								<option value="o">Odontológico</option>								
								<option value="l">Laboratorial</option>
								<option value="m">Médico</option>
								<option value="h">Hospitalar</option>		
								<option value="a">Administrativa</option>
								<option value="e">Estética</option>						
								<option value="n">Ensino</option>						
								<option value="p">Prest. de Serviços</option>						
								<option value="j">Jurídica</option>						
								<option value="u">Automobilistica</option>						
								<option value="c">Construção Cívil</option>						
							</select>
						</div>
						<div id="descricao" class="textBox" >
							<label>Setor</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 280px;" class="required" />
						</div>						
					</div>					
				</div>
				<div class="topButtonContent" >
					<div class="formGreenButton">
						<input id="inserir" name="inserir" class="greenButtonStyle" onclick="addRecord();" type="button" value="Inserir"/>
					</div>
				</div>
				<div id="mainContent">				
					<div id="dataGrid" style="" >
						<div id="centerGrid" style="min-height: 100px; margin-left: 170px; width: 450px">
							<div id="counter" style="width: 400px; float:left; margin-bottom: 5px" ></div>
							<%DataGrid dataGrid= new DataGrid(null);
							Session sess = (Session) session.getAttribute("hb");
							Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
							if (!sess.isOpen()) {
								sess = HibernateUtil.getSession();
							}
							Query query= sess.createQuery("from Especialidade order by setor, codigo");
							int gridLines = query.list().size();
							query.setFirstResult(0);
							query.setMaxResults(10);
							List<Especialidade> especialidade= (List<Especialidade>) query.list();
							dataGrid.addColum("20", "Código");
							dataGrid.addColum("20", "setor");
							dataGrid.addColum("60", "Descricao");
							if (!especialidade.equals(null)) {
								for(Especialidade esp: especialidade) {
									dataGrid.setId(String.valueOf(esp.getCodigo()));
									dataGrid.addData(String.valueOf(esp.getCodigo()));
									dataGrid.addData((esp.getSetor().trim().equals("m"))? "Médico" : "Odontológico");
									dataGrid.addData(Util.initCap(esp.getDescricao()));
									dataGrid.addRow();
								}
							}
							out.print(dataGrid.getTable(gridLines));
							sess.close();
							%>							
						</div>
						<div id="pagerGrid" class="pagerGrid" style="width: 500px; margin-right: 140px; margin-bottom: 30px"></div>						
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
	</div>	
</body>
</html>