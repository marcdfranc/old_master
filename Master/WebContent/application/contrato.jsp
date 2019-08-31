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
<%@page import="com.marcsoftware.database.Contrato"%>

<%@page import="com.marcsoftware.database.Funcionario"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
	Funcionario funcionario = (Funcionario) sess.get(Funcionario.class, Long.valueOf(request.getParameter("id")));
	%>
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
	<script type="text/javascript" src="../js/comum/contrato.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	
	<title>Master Requisições de Contratos</title>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="rh"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="rh"/>
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="get">
				<div id="geralDate" class="alignHeader">
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Contratos"/>			
					</jsp:include>
					<div>
						<input id="funcionarioId" name="funcionarioId" type="hidden" value="<%= funcionario.getCodigo() %>" />
						<input id="idUnidade" name="idUnidade" type="hidden" value="<%= funcionario.getUnidade().getCodigo() %>" />
					</div>
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
						<div class="aba2">
							<a href="requisicao_contrato.jsp?id=<%= funcionario.getCodigo()%>">Requisição</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Contratos</label>
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
						<div class="textBox" id="unidadeRef" name="unidadeRef" style="width: 65px;">
							<label>Cód. Unid.</label><br/>
							<input id="unidadeRefIn" name="unidadeRefIn" type="text" style="width:65px" readonly="readonly" value="<%=funcionario.getUnidade().getReferencia()%>"/>
						</div>
						<div id="unidade" class="textBox" style="width: 200px;" >
							<label>Unidade</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" style="width: 200px;" value="<%= Util.initCap(funcionario.getUnidade().getFantasia()) %>" readonly="readonly" />
						</div>
						<div id="requisicao" class="textBox" style="width: 73px;">
							<label>Requisição</label><br/>
							<input id="requisicaoIn" name="requisicaoIn" type="text" style="width: 73px;" onkeydown="mask(this, typeDate);" value="<%= Util.getToday() %>" />
						</div>
						<div id="" class="textBox" style="width:45px;">
							<label>Ref.</label><br/>
							<input id="referenciaIn" name="referenciaIn" readonly="readonly" type="text" style="width: 45px" value="<%= funcionario.getCodigo() %>" />
						</div>
						<div id="funcionario" class="textBox" style="width: 200px;" >
							<label>Funcionario</label><br/>
							<input id="funcionarioIn" name="funcionarioIn" type="text" style="width: 200px;" value="<%=Util.initCap(funcionario.getNome())%>" readonly="readonly" />
						</div>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">					
						<%query = sess.createQuery("from Contrato as c " + 
								"where c not in (select u.contrato from Usuario as u) " +
								"and c.funcionario = :funcionario");
						query.setEntity("funcionario", funcionario);
						List<Contrato> contratoList = (List<Contrato>) query.list();
						int gridLines = contratoList.size();
						query.setFirstResult(0);
						query.setMaxResults(5);
						DataGrid dataGrid = new DataGrid(null);
						dataGrid.addColum("5", "CTR");
						dataGrid.addColum("10", "Requisição");
						dataGrid.addColum("10", "Ref.");
						dataGrid.addColum("35", "Funcionario");
						dataGrid.addColum("34", "Unidade");
						dataGrid.addColum("3", "St");
						dataGrid.addColum("3", "Ck");
						for(Contrato contrato: contratoList) {
							dataGrid.setId(String.valueOf(contrato.getCodigo()));
							dataGrid.addData(Util.zeroToLeft(contrato.getCtr(), 4));
							dataGrid.addData(Util.parseDate(contrato.getRequisicao(), "dd/MM/yyyy"));
							dataGrid.addData(String.valueOf(contrato.getFuncionario().getCodigo()));
							dataGrid.addData(contrato.getFuncionario().getNome());
							dataGrid.addData(contrato.getFuncionario().getUnidade().getFantasia());
							dataGrid.addImg((contrato.getStatus().equals("a"))? "../image/em_aberto.gif" 
									: "../image/fechado.gif");
							dataGrid.addCheck();
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));
						sess.close();
						%>
					</div>
				</div>
				<div class="buttonContent">
					<div class="formGreenButton">
						<input class="greenButtonStyle" type="button" value="todos" onclick="selectAll()" />
					</div>
					<div class="formGreenButton">
						<input class="greenButtonStyle" type="button" value="Excluir" onclick="delCtr()" />						
					</div>
					<div class="formGreenButton">
						<input class="greenButtonStyle" type="button" value="Imprimir" onclick="emitContrato()" />						
					</div>									
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
	</div>
</body>
</html>