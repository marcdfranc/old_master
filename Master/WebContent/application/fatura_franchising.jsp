<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.database.FaturaFranchising"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%><html>
	<%Session sess = HibernateUtil.getSession();	
	Unidade unidade = (Unidade) sess.load(Unidade.class, Long.valueOf(request.getParameter("id")));	
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />	
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/item_selector.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	
	<title>Master Fatura Franchising</title>
</head>
<body>
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
						<div id="codigo" class="textBox" style="width: 70px;" >
							<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 70px;" />												
						</div>
						<div id="unidade" class="textBox" style="width: 70px;" >
							<label>Unidade</label><br/>
							<input id="unidadeIn" readonly="readonly" name="unidadeIn" type="text" style="width: 70px;" value="<%= unidade.getReferencia() %>" />												
						</div>
						<div id="inicioCad" class="textBox" style="width: 100px;" >
							<label>Cadastro Início</label><br/>
							<input id="inicioCadIn" name="inicioCadIn" type="text" style="width: 100px;" />												
						</div>
						<div id="fimCad" class="textBox" style="width: 100px;" >
							<label>Cadastro Fim</label><br/>
							<input id="fimCadIn" name="fimCadIn" type="text" style="width: 100px;" />												
						</div>
						<div id="inicioVenc" class="textBox" style="width: 100px;" >
							<label>Venc. Início</label><br/>
							<input id="inicioVencIn" name="inicioVencIn" type="text" style="width: 100px;" />												
						</div>
						<div id="fimVenc" class="textBox" style="width: 100px;" >
							<label>Venc. Fim</label><br/>
							<input id="fimVenc" name="fimVenc" type="text" style="width: 100px;" />												
						</div>						
					</div>
				</div>
				<div class="topButtonContent">
					<div class="formGreenButton">
						<input id="buscar" name="insertConta" class="greenButtonStyle" type="submit" value="Buscar"/>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid" >
						<%						 
						Query query = sess.createQuery("from FaturaFranchising as f where f.unidade = :unidade");
						query.setEntity("unidade", unidade);
						int gridLines = query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(30);
						List<FaturaFranchising> faturaList = (List<FaturaFranchising>) query.list();
						DataGrid dataGrid = new DataGrid("cadastro_fatura_franchising.jsp");
						dataGrid.addColum("10", "Código");
						dataGrid.addColum("10", "Início");
						dataGrid.addColum("10", "Fim");
						dataGrid.addColum("10", "Vencimento");
						dataGrid.addColum("10", "Status");
						for(FaturaFranchising fatura: faturaList) {
							dataGrid.setId(String.valueOf(fatura.getCodigo()));
							dataGrid.addData(Util.zeroToLeft(fatura.getCodigo(), 4));
							dataGrid.addData(Util.parseDate(fatura.getDataInicio(), "dd/MM/yyyy"));
							if (fatura.getDataFim() == null) {
								dataGrid.addData("----------");
							} else {
								dataGrid.addData(Util.parseDate(fatura.getDataFim(), "dd/MM/yyyy"));
							}
							if (fatura.getVencimento() == null) {
								dataGrid.addData("----------");
							} else {
								dataGrid.addData(Util.parseDate(fatura.getVencimento(), "dd/MM/yyyy"));
							}
							if (fatura.getStatus().equals("a")) {
								dataGrid.addImg("../image/em_aberto.gif");
							} else {
								dataGrid.addImg("../image/fechado.gif");
							}
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));						
						%>
					</div>
					<div id="pagerGrid"  class="pagerGrid"></div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<% sess.close(); %>
	</div>
</body>
</html>
