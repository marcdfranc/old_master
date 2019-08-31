<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.database.Vigencia"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	//Query query= sess.createQuery("select distinct t.vigencia from Tabela as t where t.aprovacao not in('s')");
	//Query query= sess.createQuery("select descricao from Vigencia as v where v.aprovacao not in('s')");
	Query query;
	//query = sess.createQuery("select distinct t.vigencia from Tabela as t where t.aprovacao = 's'");
	query = sess.createQuery("select descricao from Vigencia as v where v.aprovacao = 's'");
	
	if (session.getAttribute("perfil").equals("a")) {
		query= sess.createQuery("from Unidade as u where u.deleted =\'n\'");		
	} else if (session.getAttribute("perfil").equals("f")) {
		query= sess.getNamedQuery("unidadeByUser");
		query.setString("username", (String) session.getAttribute("username"));
	} else {
		query = sess.createQuery("select p.unidade from Pessoa as p where p.login = :username");
		query.setString("username", (String) session.getAttribute("username"));
	}
	List<Unidade> unidadeList = null;
	if (query.list().size() > 0) {
		unidadeList = (List<Unidade>) query.list();		
	} else {
		query = sess.createQuery("from Unidade as u where u.codigo = 1");
		unidadeList = query.list();
	}
	
	query = sess.createQuery("from Vigencia as v where v.unidade = :unidade " +
			" and v.aprovacao not in('s')");
	query.setEntity("unidade", unidadeList.get(0));	
	
	List<Vigencia> tabelas = (List<Vigencia>) query.list();
	query = sess.createQuery("from Vigencia as v where v.unidade = :unidade " +
			" and  v.aprovacao = 's'"); 
	query.setEntity("unidade", unidadeList.get(0));
	List<Vigencia> tabelaAprovada = (List<Vigencia>) query.list();
	int index = -1;
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
    <script type="text/javascript" src="../js/jquery/interface.js"></script> 
	<script type="text/javascript" src="../js/comum/tabela_vigencia.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/item_selector.js"></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>	
	
	<title>Master Tabela de Vigências</title>
</head>
<body>
	<div id="tableGenerateWindow" class="removeBorda" title="Geração de Tabela" style="display: none;">			
		<form id="formTableGenerate" onsubmit="return false;">
			<fieldset>
				<p>Será gerada uma nova tabela com as mesmas caracteísticas da tabela selecionada.</p>
				<p>Digite a descrição para nova tabela</p>
				<label for="moneyCupon">Descrição</label>
				<input type="text" name="descTable" id="descTable" class="textDialog ui-widget-content ui-corner-all"/>
			</fieldset>
		</form>
	</div>
	<div id="newTableWindow" class="removeBorda" title="Criação de Tabela" style="display: none;">			
		<form id="formTableGenerate" onsubmit="return false;">
			<fieldset>
				<p>Será criada uma nova tabela contendo apenas o procedimento 1.1!</p>
				<p>Digite a descrição para nova tabela</p>
				<label for="moneyCupon">Descrição</label>
				<input type="text" name="descNewTable" id="descNewTable" class="textDialog ui-widget-content ui-corner-all"/>
			</fieldset>
		</form>
	</div>
	<div id="vigenciaWindow" class="removeBorda" title="Edição do Nome da Tabela" style="display: none;">			
		<form id="formVig" onsubmit="return false;">
			<fieldset>				
				<label for="descVigencia">Digite a nova descrição para tabela selecionada</label>
				<input type="text" name="descVigencia" id="descVigencia" class="textDialog ui-widget-content ui-corner-all"/>
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
			<form id="unit" method="get">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Hist. de Tabelas"/>			
					</jsp:include>
					<div class="topContent">
						<div id="unidadeId" class="textBox">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeIdIn" name="unidadeIdIn" style="width: 90px;" onchange="reloadTables()">
								<%if (unidadeList.size() == 1) {
									out.print("<option value=\"" + unidadeList.get(0).getCodigo() + 
											"\" selected=\"selected\">" + unidadeList.get(0).getReferencia() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										out.print("<option value=\"" + un.getCodigo() + 
												"\">" + un.getReferencia() + "</option>");
									}									
								}
								%>
							</select>
						</div>
					</div>					
				</div>
				<div id="mainContent">
					<div id="dadosPessoais" class="bigBox" >
						<div class="indexTitle" style="margin-top: 0!important">
							<h4>Histórico de Tabelas</h4>
							<div class="alignLine">
								<hr>
							</div>
							<div class="itContent ui-corner-all" id="selectorTable" style="margin-top: 10px;">
								<div style="width: 440px; height: 350px; float:left; margin-bottom: 0 !important">
									<label class="ui-corner-all titleBar">Histórico</label>
									<ul id="sortable1" class="connectedSortable ui-corner-all leftList" style="width: 440px; height: 300px;">
										<%for(int i = 0; i < tabelas.size(); i++) {
											out.print("<li style=\"height: 20px\" title=\"" + tabelas.get(i).getCodigo() + 
													"\">" +	tabelas.get(i).getDescricao() + "</li>");
											index = i;
										}%>								
									</ul>
								</div>
								<div class="btContent" ></div>
								<div style="width: 440px; height: 350px; float:left; margin-bottom: 0 !important">
									<label class="ui-corner-all titleBar">Vigentes</label>
									<ul id="sortable2" class="connectedSortable ui-corner-all leftList" style="width: 440px; height: 300px;">
										<% for (int i = 0; i < tabelaAprovada.size(); i++) {%>
											<li title="<%= tabelaAprovada.get(i).getCodigo() %>" 
											style="min-height: 20px"><%= tabelaAprovada.get(i).getDescricao() %></li>
										<%}%>
									</ul>
								</div>
							</div>
						</div>
					</div>
					<div class="buttonContent" style="margin-top: 20px;">
						<%if (session.getAttribute("perfil").equals("a")
								|| session.getAttribute("perfil").equals("f")) {%>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Salvar" onclick="save()" />
							</div>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Editar" onclick="editVigencia()" />
							</div>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Duplicar Tab." onclick="generateTable()" />
							</div>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Nova Tabela" onclick="createTable()" />
							</div>														
						<%} else {%>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Salvar" onclick="noAccess()" />
							</div>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Editar" onclick="noAccess()" />
							</div>						
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Duplicar Tab." onclick="noAccess()" />
							</div>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Nova Tabela" onclick="noAccess()" />
							</div>
						<%}%>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>