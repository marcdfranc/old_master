<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Especialidade"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Servico"%>
<%@page import="com.marcsoftware.utilities.Util"%>

<%@page import="com.marcsoftware.database.Unidade"%><html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
    
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>	
	<script type="text/javascript" src="../js/comum/servico.js" ></script>
		<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query= sess.createQuery("from Especialidade");
	List<Especialidade> especialidade = (List<Especialidade>) query.list();
	if (session.getAttribute("perfil").equals("a")) {
		query= sess.createQuery("from Unidade as u where u.deleted =\'n\'");		
	} else if (session.getAttribute("perfil").equals("f")) {
		query= sess.getNamedQuery("unidadeByUser");
		query.setString("username", (String) session.getAttribute("username"));
	} else {
		query = sess.createQuery("select p.unidade from Pessoa as p where p.login = :username");
		query.setString("username", (String) session.getAttribute("username"));
	}
	List<Unidade> unidadeList= (List<Unidade>) query.list();
	%>
	
	<title>Master - Serviço</title>
</head>
<body onload="load()" >
	<div id="tabelaWindow" class="removeBorda" title="Impressão de Tabelas" style="display: none;">			
		<form id="formTabela" onsubmit="return false;">
			<fieldset>
				<label for="unidadeWin">Selecione a unidade</label><br/>
				<select id="unidadeWin" style="width: 100%">
					<%for(Unidade un: unidadeList) {
						out.print("<option value=\"" + un.getCodigo() + "\">" + 
								un.getReferencia() + "</option>");									
					}%>
				</select>				
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="servico"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="servico"/>			
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="get" onsubmit="return search()">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Procedimentos"/>			
					</jsp:include>
					<div class="topContent">					
						<div id="codigo" class="textBox" style="width: 80px;">
							<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 80px;" class="required" onblur="genericValid(this);" />
						</div>						
						<div id="descricao" class="textBox" style="width: 240px;">
							<label>Descricao</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 240px;" class="required" enable="false" onblur="genericValid(this);" />
						</div>										
						<div id="setor" class="textBox">
							<label>Atividade</label><br/>
							<select type="select-multiple" id="setorIn" name="setorIn" class="required" onblur="genericValid(this);">
								<option value="">Selecione</option>
								<option value="o">Odontológica</option>								
								<option value="l">Laboratorial</option>
								<option value="m">Médica</option>
								<option value="h">Hospitalar</option>								
							</select>
						</div>
						<div id="especialidade" class="textBox">
							<label>Setor</label><br/>
							<select type="select-multiple" id="especialidadeIn" name="especialidadeIn" class="required" onblur="genericValid(this);">
								<option value="">Selecione</option>
								<%for(Especialidade esp: especialidade) {
									out.print("<option value=\"" + esp.getCodigo() +
										"\">" + esp.getDescricao() + "</option>");
								}%>
							</select>
						</div>
					</div>
				</div>
				<div class="topButtonContent">
					<div class="formGreenButton">
						<input class="greenButtonStyle" type="button" value="Imprimir" onclick="printProcedimento()"/>
					</div>
					<div class="formGreenButton">
						<input id="buscar" name="insertConta" class="greenButtonStyle" type="submit" value="Buscar"/>
					</div>
				</div>
				<div id="mainContent">										
					<div id="counter" class="counter"></div>
					<div id="dataGrid" >
						<%
						DataGrid dataGrid = new DataGrid("cadastro_servico.jsp");
						//DataGrid dataGrid = new DataGrid("");
						query = sess.createQuery("from Servico as s order by s.especialidade.descricao, s.descricao");
						int gridLines = query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(30);
						List<Servico> servico= (List<Servico>) query.list();						
						dataGrid.addColum("10", "Código");
						dataGrid.addColum("15", "Atividade");
						dataGrid.addColum("30", "Setor");
						dataGrid.addColum("45", "Descrição");
						for(Servico serv: servico) {
							dataGrid.setId(String.valueOf(serv.getCodigo()));
							dataGrid.addData(serv.getReferencia());
							if (serv.getEspecialidade().getSetor().equals("o")) {
								dataGrid.addData("Odontológica");								
							} else if (serv.getEspecialidade().getSetor().equals("m")){
								dataGrid.addData("Médica");
							} else if (serv.getEspecialidade().getSetor().equals("l")){
								dataGrid.addData("Laboratorial");
							} else {
								dataGrid.addData("Hospitalar");
							}
							dataGrid.addData(Util.initCap(serv.getEspecialidade().getDescricao()));
							dataGrid.addData(Util.initCap(serv.getDescricao()));
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));
						%>
						<div id="pagerGrid" class="pagerGrid"></div>						
					</div>
				</div>
			</form>		
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close(); %>
	</div>
</body>
</html>