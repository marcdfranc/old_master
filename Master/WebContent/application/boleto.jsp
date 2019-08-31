<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Boleto"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	boolean isJuridica = request.getParameter("origem").equals("j");
	%>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" /> 
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
	
	<title>Master Boletos</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/comum/boleto.js" ></script>	
</head>
<body>
	<%@ include file="../inc/header.jsp" %>	
	<%if (isJuridica) {%>
		<jsp:include page="../inc/menu.jsp">
			<jsp:param name="currentPage" value="clienteJ"/>
		</jsp:include>	
	<%} else {%>
		<jsp:include page="../inc/menu.jsp">
			<jsp:param name="currentPage" value="clienteF"/>
		</jsp:include>
	<%}%>
	<div id="centerAll">
		<%if (isJuridica) {%>
			<jsp:include page="../inc/submenu.jsp">
				<jsp:param name="currentPage" value="clienteJ"/>
			</jsp:include>
		<%} else {%>
			<jsp:include page="../inc/submenu.jsp">
				<jsp:param name="currentPage" value="clienteF"/>
			</jsp:include>
		<%}%>
		<div id="formStyle">
			<form id="unit" method="get" onsubmit="return search()">
				<input id="codUser" name="codUser" type="hidden" value="<%= request.getParameter("id") %>"/>
				<input id="tipoBoleto" name="tipoBoleto" type="hidden" value="<%= (isJuridica)? "j" : "f" %>"/>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Baixa de Boletos"/>
					</jsp:include>
					<div class="topContent">						
						<div id="codigo" class="textBox" style="width: 70px;">
							<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 70px;" onkeydown="mask(this, onlyNumber);"/>
						</div>
						<div id="EmissaoInicio" class="textBox" style="width: 100px;">
							<label>Emissão Inicial</label><br/>
							<input id="EmissaoInicioIn" name="EmissaoInicioIn" type="text" style="width: 100px;" onkeydown="mask(this, dateType);"/>
						</div>
						<div id="EmissaoFim" class="textBox" style="width: 90px;">
							<label>Emissão Final</label><br/>
							<input id="EmissaoFimIn" name="EmissaoFimIn" type="text" style="width: 90px;" onkeydown="mask(this, dateType);"/>
						</div>
						<div id="vencimentoInicio" class="textBox" style="width: 113px;">
							<label>Vencimento Inicial</label><br/>
							<input id="vencimentoInicioIn" name="vencimentoInicioIn" type="text" style="width: 113px;" onkeydown="mask(this, dateType);"/>
						</div>
						<div id="vencimentoFim" class="textBox" style="width: 106px;">
							<label>Vencimento Final</label><br/>
							<input id="vencimentoFimIn" name="vencimentoFimIn" type="text" style="width: 106px;" onkeydown="mask(this, dateType);"/>
						</div>
						<div id="status" class="textBox">
							<label>Status</label><br />
							<select id="statusIn" name="statusIn">
								<option value="">Selecione</option>
								<option value="a">Em Aberto</option>
								<option value="q">Quitado</option>
							</select>
						</div>
					</div>
				</div>
				<div class="topButtonContent">					
					<div class="formGreenButton">
						<input id="buscar" name="buscar" class="greenButtonStyle" type="submit" value="Buscar"/>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>					
					<div id="dataGrid">
						<%Query query = sess.createQuery("from Boleto as b where b.pessoa.codigo = :pessoa order by b.codigo");
						query.setLong("pessoa", Long.valueOf(request.getParameter("id")));
						int gridLines = query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(30);
						List<Boleto> boletos = (List<Boleto>) query.list();						
						DataGrid dataGrid = new DataGrid("cadastro_boleto.jsp");
						dataGrid.addColum("15", "Código");
						dataGrid.addColum("25", "Emissão");
						dataGrid.addColum("25", "Vencimento");
						dataGrid.addColum("25", "Valor");
						dataGrid.addColum("5", "Status");
						dataGrid.addColum("5", "Ck");
						for(Boleto boleto: boletos) {
							dataGrid.setId(String.valueOf(boleto.getCodigo()));
							dataGrid.addData(String.valueOf(boleto.getCodigo()));
							dataGrid.addData(Util.parseDate(boleto.getEmissao(), "dd/MM/yyyy"));
							dataGrid.addData(Util.parseDate(boleto.getVencimento(), "dd/MM/yyyy"));
							dataGrid.addData(Util.formatCurrency(boleto.getValor()));
							if (boleto.getStatus().trim().equals("a")) {
								dataGrid.addImg("../image/em_aberto.gif");
							} else if (boleto.getStatus().trim().equals("c")) {
								dataGrid.addImg("../image/cancelado.png");
							} else {
								dataGrid.addImg("../image/ok_icon.png");
							}
							dataGrid.addCheck();
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));
						%>
						<div id="pagerGrid" class="pagerGrid"></div>
					</div>
				</div>
				<div class="buttonContent" style="margin-top: 55px;">
					<div class="formGreenButton">
						<input id="selecione" name="selecione" class="greenButtonStyle" type="button" value="todos" onclick="selectAll()" />
					</div>
					<div class="formGreenButton">
						<input id="btExclui" name="btExclui" class="greenButtonStyle" type="button" value="Exclui" onclick="excluir()" />
					</div>
					<div class="formGreenButton">
						<input id="btCancel" name="btCancel" class="greenButtonStyle" type="button" value="Cancelar" onclick="cancelar()" />
					</div>
					<div class="formGreenButton">
						<input id="btImprimir" name="btImprimir" class="greenButtonStyle" type="button" value="Imprimir" onclick="imprimir()" />
					</div>
					<%if (session.getAttribute("caixaOpen").toString().trim().equals("t")) {%>					
						<div class="formGreenButton">
							<input id="btBaixa" name="btBaixa" class="greenButtonStyle" type="button" value="Dar Baixa" onclick="baixa()" />
						</div>
					<%} else {%>
						<div class="formGreenButton">
							<input id="btBaixa" name="btBaixa" class="greenButtonStyle" type="button" value="Dar Baixa" onclick="noAccess()" />
						</div>
					<%}%>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>

</html>