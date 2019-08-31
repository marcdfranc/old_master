<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Unidade"%>

<%@page import="java.util.List"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Endereco"%>
<%@page import="com.marcsoftware.database.Informacao"%>
<%@page import="com.marcsoftware.utilities.Util"%>

<html xmlns="http://www.w3.org/1999/xhtml">
	
	<jsp:useBean id="endereco" class="com.marcsoftware.database.Endereco"></jsp:useBean>
	<jsp:useBean id="informacao" class="com.marcsoftware.database.Informacao"></jsp:useBean>
	
	<%Session sess = (Session) session.getAttribute("hb");
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
	List<Unidade> unidadeList= (List<Unidade>) query.list();	
	%>
		
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />	
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
		
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/comum/unidade.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/item_selector.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	
	<title>Master Unidades</title>	
</head>
<body>
	<div id="preWindow" class="removeBorda" title="Selecione a Unidade" style="display: none;">			
		<form id="formCarteirinha" onsubmit="return false;">
			<fieldset>
				<label for="unidadeIds"></label>
				<select id="unidadeIds" name="unidadeIds">
					<%for(Unidade unidade: unidadeList) {%>
						<option value="<%= unidade.getCodigo() %>"><%= unidade.getReferencia() %></option>
					<%}%>
				</select>
			</fieldset>
		</form>
	</div>
	<div id="cartaoWindow" class="removeBorda" title="Selecione os Logins para Operação" style="display: none;">			
		<form id="formCarteirinha" onsubmit="return false;">
			<fieldset>
				<label for="userIds">Seleção de Logins</label>
				<div class="itContent ui-corner-all" id="selectorLogins" style="width: 639px">
					<div style="width: 300px; height: 100px; float:left; margin-bottom: 0 !important">
						<label class="ui-corner-all titleBar">Itens</label>
						<ul id="sortableLeft" class="connectedSortable ui-corner-all leftList" style="width: 300px; height: 250px;">
							
						</ul>
					</div>
					<div class="btContent" ></div>
					<div style="width: 300px; height: 80px; float:left; margin-bottom: 0 !important">
						<label class="ui-corner-all titleBar">Selecinados</label>
						<ul id="sortableRight" class="connectedSortable ui-corner-all leftList" style="width: 300px; height: 250px;">							
							
						</ul>
					</div>
				</div>
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="unidade"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="unidade"/>			
		</jsp:include>
		<div id="formStyle">
			<form id="formUnit" method="get" onsubmit="return search()">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Unidades"/>			
					</jsp:include>					
					<div class="topContent">
						<div id="referencia" class="textBox" style="width: 70px;" >
							<label>Código</label><br/>
							<input id="referenciaIn" name="referenciaIn" type="text" style="width: 70px;" class="required" />												
						</div>
						<div id="cidade" class="textBox" style="width: 315px">
							<label>Unidade</label><br/>					
							<input id="cidadeIn" name="cidadeIn" type="text" style="width: 315px" />
						</div>
						<div id="cnpj" class="textBox" style="width: 115px">
							<label>Cnpj</label><br/>						
							<input id="cnpjIn" name="cnpjIn" type="text" style="width: 115px" onkeydown="mask(this, cnpj);" />
						</div>
						<div id="tipo" class="textBox" style="width: 88px;">
							<label>Tipo</label><br/>
							<select id="tipoIn" name="tipoIn" style="width: 88px;">
								<option>Selecione</option>
								<option value="u">Filial</option>
								<option value="f">Franquia</option>
							</select>
							<input id=type name="type" type="hidden" />
						</div>
						<div id="status" class="textBox" style="width: 280px">
							<label >Status</label><br />
							<div class="checkRadio">
								<label class="labelCheck" >Ativo</label>
								<input id="ativoChecked" name="ativoChecked" onchange="setChange('u')" type="radio" checked="checked" value="a" />
								<label class="labelCheck" >Bloqueado</label>
								<input id="ativoChecked" name="ativoChecked" type="radio" onchange="setChange('u')" value="b" />
								<label class="labelCheck" >Cancelado</label>
								<input id="ativoChecked" name="ativoChecked" type="radio" onchange="setChange('u')" value="c" />
							</div>
						</div>
						<div id="tel" class="textBox" style="width: 80px">
							<label>Telefone</label><br/>					
							<input id="telIn" name="telIn" type="text" style="width: 80px"/>
						</div>
						<div id="razaoSocial" class="textBox" style="width: 240px;" >
							<label>Razão Social</label><br/>
							<input id="razaoSocialIn" name="razaoSocialIn" type="text" style="width: 240px" />						
						</div>
						<div id="nome" class="textBox" style="width: 255px">
							<label>Nome Responsável</label><br/>					
							<input id="nomeIn" name="nomeIn" type="text" style="width: 255px"/>
						</div>
						<div id="cpf" class="textBox" style="width: 89px">
							<label>Cpf Resp.</label><br/>					
							<input id="cpfIn" name="cpfIn" type="text" style="width: 89px" onkeydown="mask(this, cpf);" />						
						</div>
					</div>					
				</div>
				<div class="topButtonContent">
					<%if (session.getAttribute("perfil").equals("d")
							|| session.getAttribute("perfil").equals("a")) {%>
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Cartão" onclick="operacaoCartao()"/>								
						</div>
					<%}%>
					<div class="formGreenButton">
						<input id="buscar" name="insertConta" class="greenButtonStyle" type="submit" value="Buscar"/>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid" >
						<%					
						DataGrid dataGrid = null;						
						if (request.getSession().getAttribute("perfil").toString().trim().equals("a") ||
								request.getSession().getAttribute("perfil").toString().trim().equals("d")) {
							query = sess.createQuery("from Unidade as u where u.deleted= \'n\' order by u.razaoSocial");
							dataGrid = new DataGrid(null);
						} else {
							query = sess.createQuery("from Unidade as u where u.administrador.login.username = :username");
							query.setString("username", (String) request.getSession().getAttribute("username"));
							if (query.list().size() == 1) {
								dataGrid = new DataGrid(null);
							} else {
								dataGrid = new DataGrid("cadastro_unidade.jsp");
							}
						}
						query.setFirstResult(0);
						query.setMaxResults(30);
						List<Unidade> unidade= (List<Unidade>) query.list();
						dataGrid.addColum("8", "Código");
						dataGrid.addColum("40", "Razão Social");
						dataGrid.addColum("32", "Cidade");
						dataGrid.addColum("18", "Fone");
						dataGrid.addColum("2", "St.");
						for(Unidade un: unidade) {							
							query= sess.getNamedQuery("informacaoPrincipal").setEntity("pessoa", un);
							query.setFirstResult(0);
							query.setMaxResults(1);
							informacao= (Informacao) query.uniqueResult();
							dataGrid.setId(String.valueOf(un.getCodigo()));
							dataGrid.addData("referencia", un.getReferencia());
							dataGrid.addData("rzSocial", Util.initCap(un.getRazaoSocial()));
							dataGrid.addData("cidade", un.getDescricao());							
							dataGrid.addData("informacao",
									(informacao == null)? "" : informacao.getDescricao());
							dataGrid.addImg(Util.getIcon(un.getAtivo()));
							dataGrid.addRow();
						}
						query= sess.getNamedQuery("unidadesAtivas");						
						out.print(dataGrid.getTable(Integer.parseInt(query.uniqueResult().toString())));						
						sess.close();
						%>
						<div id="pagerGrid"  class="pagerGrid"></div>						
					</div>					
				</div>
			</form>			
		</div>
		<%@ include file="../inc/footer.html" %>
	</div>
</body>
</html>