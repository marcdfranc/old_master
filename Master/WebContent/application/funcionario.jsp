<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="com.marcsoftware.database.Funcionario"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.database.Posicao"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="org.hibernate.Query"%>
<%@page import="org.hibernate.Session"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.database.Informacao"%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<jsp:useBean id="OnePosicao" class="com.marcsoftware.database.Posicao"></jsp:useBean>	
	<jsp:useBean id="informacao" class="com.marcsoftware.database.Informacao"></jsp:useBean>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
    
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/comum/funcionario.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/item_selector.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	
	<%!Query query;%>
	<%!Session sess;%>
	<%!List<Unidade> unidadeList;%>
	<%!List<Posicao> posicao;%>		
	<%sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
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
	query = sess.createQuery("from Posicao");
	posicao= (List<Posicao>) query.list();
	%>		

<title>Marster Funcionários</title>
</head>
<body onload="load()">
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
		<jsp:param name="currentPage" value="rh"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="rh"/>
		</jsp:include>
		<div id="formStyle">
			<form id="funcionario" method="get" onsubmit="return search()">
				<div id="geralDate" class="alignHeader">
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="RH"/>			
					</jsp:include>
					<div class="topContent">
						<div id="referencia" class="textBox" style="width: 70px;">
							<label>Referência</label><br/>
							<input id="referenciaIn" name="referenciaIn" type="text" style="width: 70px;" class="required" />												
						</div>
						<div id="nome" class="textBox" style="width: 243px;">
							<label>Nome</label><br/>
							<input id="nomeIn" name="nomeIn" type="text" style="width: 243px;" />
						</div>
						<div id="cpf" class="textBox" style="width: 100px">
							<label>Cpf</label><br/>
							<input id="cpfIn" name="cpfIn" type="text" style="width: 100px" class="required" onkeydown="mask(this, cpf);"/>
						</div>				
						<div id="nascimentoCalendar" class="textBox" style="width: 73px;">
							<label>Nascimento</label><br/>
							<input id="nascimentoIn" name="nascimentoIn" type="text" style="width: 73px;" onkeydown="mask(this, typeDate);"/>
						</div>
						<div id="tel" class="textBox" style="width: 80px">
							<label>Telefone</label><br/>					
							<input id="telIn" name="telIn" type="text" style="width: 80px"/>
						</div>
						<div id="status" class="textBox" style="width: 280px">
							<label >Status</label><br />
							<div class="checkRadio">
								<label class="labelCheck" >Ativo</label>
								<input id="ativoChecked" name="ativoChecked" type="radio" checked="checked" value="a" />
								<label class="labelCheck" >Bloqueado</label>
								<input id="ativoChecked" name="ativoChecked" type="radio" value="b" />
								<label class="labelCheck" >Cancelado</label>
								<input id="ativoChecked" name="ativoChecked" type="radio" value="c" />
							</div>
						</div>
						<div class="textBox">
							<label>Cargo</label><br/>
							<select id="cargoId" name="cargoId" style="width: 235px">
								<option>Selecione</option>
								<%for(Posicao pos: posicao) {
									out.print("<option value=\"" + pos.getCodigo() + 
											"\">" + pos.getDescricao() + "</option>");
								}
								%>								
							</select>
						</div>
						<div id="unidadeIn" class="textBox">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId">
								<option value="0@0">Selecione</option>
								<%if (unidadeList.size() == 1) {
									out.print("<option value=\"" + unidadeList.get(0).getRazaoSocial() + "@" + 
											unidadeList.get(0).getCodigo() + 
											"\" selected=\"selected\">" + unidadeList.get(0).getReferencia() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										out.print("<option value=\"" + un.getRazaoSocial() + "@" +
												un.getCodigo() + "\">" + un.getReferencia() + "</option>");
									}
								}
								%>
							</select>
						</div>
					</div>
				</div>
				<div class="topButtonContent">
					<%if (session.getAttribute("perfil").equals("a")
							|| session.getAttribute("perfil").equals("f")) {%>
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Cartão" onclick="operacaoCartao()"/>								
						</div>
					<%}%>
					<div class="formGreenButton">
						<input class="greenButtonStyle" type="submit" value="Buscar" />								
					</div>
				</div> 
				<div id="mainContent">										
					<div id="counter" class="counter"></div>
					<div id="dataGrid">													
						<%
						DataGrid dataGrid = new DataGrid(null);
						if (session.getAttribute("perfil").toString().equals("a")
								|| session.getAttribute("perfil").toString().equals("d")
								|| unidadeList.size() > 1) {							
							query= sess.createQuery("from Funcionario as f where (1 <> 1) order by f.nome");
						} else {
							query= sess.createQuery("from Funcionario as f where " +
									" f.unidade.codigo = :unidade order by f.nome");
							query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
						}
						List<Funcionario> funcionario = (List<Funcionario>) query.list();
						int gridLines= query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(30);
						funcionario = (List<Funcionario>) query.list();
						dataGrid.addColum("10", "Ref.");
						dataGrid.addColum("30", "Nome");
						dataGrid.addColum("20", "Cargo");
						dataGrid.addColum("20", "cpf");
						dataGrid.addColum("20", "Telefone");
						dataGrid.addColum("2", "St.");
						for (Funcionario fn: funcionario) {
							query = sess.getNamedQuery("informacaoPrincipal").setEntity("pessoa", fn);
							query.setFirstResult(0);
							query.setMaxResults(1);
							informacao = (Informacao) query.uniqueResult();
							dataGrid.setId(String.valueOf(fn.getCodigo()));
							dataGrid.addData(String.valueOf(fn.getCodigo()));
							dataGrid.addData(fn.getNome());
							dataGrid.addData(fn.getPosicao().getDescricao());
							dataGrid.addData(Util.mountCpf(fn.getCpf()));
							dataGrid.addData((informacao == null)? "" : informacao.getDescricao());
							dataGrid.addImg(Util.getIcon(fn.getAtivo()));
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