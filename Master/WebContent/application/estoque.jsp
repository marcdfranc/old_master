<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Insumo"%>
<%@page import="com.marcsoftware.database.Ramo"%>
<%@page import="com.marcsoftware.database.Unidade"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query = sess.createQuery("from Ramo as r");
	List<Ramo> ramoList = (List<Ramo>) query.list();
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
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Insumos</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/comum/estoque.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/default.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
</head>
<body onload="load()">
	<jsp:include page="../inc/pdv.jsp"></jsp:include>
	<div id="cadastroWindow" class="removeBorda" title="Cadastro de Produto Serviço" style="display: none;">
		<form id="formObs" onsubmit="return false;">
			<h2 style="float: right;"><strong>Custo: </strong> R$ <span id="custo-produto">20,00</span></h2>
			
			<label>Calcular por:</label>
			<select id="tipo-calculo" name="tipo-calculo">
				<option value="p">Percentagem</option>
				<option value="v">Valor</option>
			</select>
			</br>
			<label>valor</label><br/>
			<input type="text" name="money-reajuste" id="money-reajuste" class="textDialog ui-widget-content ui-corner-all" value="0.00" style="height: 35px; font-size: 30px; color: #666666;" onkeydown="mask(this, decimalNumber);"/>
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>
	
		<jsp:include page="../inc/menu.jsp">
			<jsp:param name="currentPage" value="fornecedor"/>
		</jsp:include>
		
	<div id="centerAll">
		
			<jsp:include page="../inc/submenu.jsp">
				<jsp:param name="currentPage" value="fornecedor"/>
			</jsp:include>
		
		<div id="formStyle">
			<form id="unit" method="get" onsubmit="return search()">
				<input type="hidden" id="origem" name="origem" value="<%= request.getParameter("origem") %>" />
				<input type="hidden" id="codigoCad" name="codigoCad" value="" />
				
				<div id="geralDate" class="alignHeader">
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Prod. e Serviços"/>			
					</jsp:include>
					<div class="topContent">
						<div id="codigo" class="textBox" style="width: 75px;">
							<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 75px;" />
						</div>
						<div id="ramo" class="textBox">
							<label>Ramo</label><br/>
							<select id="ramoIn" name="ramoIn">
								<option value="">Selecione</option>						
								<%for(Ramo ramo: ramoList) {
										out.print("<option value=\"" + ramo.getCodigo() + "\">" + 
												ramo.getDescricao() + "</option>");
								}%>
							</select>
						</div>
						<div id="descricao" class="textBox" style="width: 230px;">
							<label>Descrição</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 230px;" class="required" />
						</div>							
						<div id="tipo" class="textBox">
							<label>Tipo</label><br/>
							<select id="tipoIn" name="tipoIn">
								<option value="">Todos</option>
								<option value="p">Produto</option>
								<option value="s">Serviço</option>
							</select>
						</div>
						<div id="ativo" class="textBox">
							<label >Status</label><br />
							<select id="statusIn" name="statusIn">
								<option value="">Todos</option>
								<option value="a">Ativo</option>								
								<option value="d">Descontinuado</option>
							</select>
						</div>
						<div id="unidadeIn" class="textBox">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId">
								<% if (session.getAttribute("perfil").toString().equals("a")) {%>
									<option value="">Selecione</option>									
								<%} else {%>
									<option value="0">Selecione</option>
								<%}%>							
								<%if (unidadeList.size() == 1) {
									out.print("<option value=\"" + unidadeList.get(0).getCodigo() + 
											"\" selected=\"selected\">" + unidadeList.get(0).getReferencia() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										out.print("<option value=\"" + un.getCodigo() + "\">" + 
												un.getReferencia() + "</option>");
									}
								}
								%>
							</select>
						</div>
					</div>
				</div>
				<div class="topButtonContent">					
					<div class="formGreenButton">
						<input id="insercao" name="insercao" class="greenButtonStyle" type="submit" value="Buscar"/>
					</div>
					
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%if (session.getAttribute("perfil").toString().equals("a")
								|| session.getAttribute("perfil").toString().equals("d")) {
							query = sess.createQuery("from Insumo as i order by i.codigo");							
						} else {
							query = sess.createQuery("from Insumo as i " + 
									" where i.unidade.codigo = :unidade " +
									" order by i.codigo");
							query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
						}
						int gridLines = query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(10);
						List<Insumo> insumoList = (List<Insumo>) query.list();
						DataGrid dataGrid = new DataGrid(null);
						dataGrid.addColum("5", "Código");						
						dataGrid.addColum("35" ,"ramo");
						dataGrid.addColum("30" ,"Descrição");
						dataGrid.addColum("5" ,"Unid.");
						dataGrid.addColum("10" ,"Valor");
						dataGrid.addColum("10" ,"Estoque");
						dataGrid.addColum("5" ,"Status");						
						for(Insumo insumo: insumoList) {
							dataGrid.setId(String.valueOf(insumo.getCodigo()));
							dataGrid.addData("codigo" + insumo.getCodigo(), String.valueOf(insumo.getCodigo()), false);
							dataGrid.addData("ramo" + insumo.getCodigo(), Util.encodeString(insumo.getRamo().getDescricao(), "ISO-8859-1", "UTF-8"), false);
							dataGrid.addData("descricao" + insumo.getCodigo(), Util.encodeString(insumo.getDescricao(), "ISO-8859-1", "UTF-8"), false);
							dataGrid.addData("unidade" + insumo.getCodigo(), insumo.getUnidade().getReferencia());
							dataGrid.addData("valor" + insumo.getCodigo(), Util.formatCurrency(insumo.getValor()), false);
							dataGrid.addData("estoque" + insumo.getCodigo(), String.valueOf(insumo.getQtde()), false);
							
							if(insumo.getTipo().trim().equals("d")) {
								dataGrid.addData("status" + insumo.getCodigo(), "Descontinuado", false);
							} else {
								dataGrid.addData("status" + insumo.getCodigo(), "Ativo", false);
							}
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
		<%sess.close();%>
	</div>
</body>
</html>