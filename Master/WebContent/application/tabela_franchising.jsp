<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.TabelaFranchising"%><html>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	
	<title>Master Tabela Franchising</title>
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
			<form id="orc" method="get" onsubmit="return search()" >				
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Tabelas Franchising"/>			
					</jsp:include>
					<div class="topContent">
						<div id="codigo" class="textBox" style="width:50px">
							<label>Codigo</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 50px;"/>
						</div>
						<div id="descricao" class="textBox" style="width:270px">
							<label>Descrição</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 270px;"/>
						</div>
						<div class="textBox" id="cadastro" name="nascimento" style="width: 75px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" type="text" style="width:75px" onkeydown="mask(this, dateType);"/>
						</div>
						<div class="buttonContent">
							<div class="leftButtonContent">
								<input id="buscar" name="insertConta" class="greenButtonStyle" type="submit" value="Buscar"/>
							</div>
						</div>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%Session sess = (Session) session.getAttribute("hb");						
						if (!sess.isOpen()) {
							sess = HibernateUtil.getSession();
						}
						Query query = sess.createQuery("from TabelaFranchising AS t");
						int gridLines = query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(30);
						List<TabelaFranchising> tabelaList = (List<TabelaFranchising>) query.list();
						DataGrid dataGrid= new DataGrid("cadastro_tabela_franchising.jsp");
						dataGrid.addColum("10", "Código");
						dataGrid.addColum("10", "Descricao");
						dataGrid.addColum("10", "Cadastro");
						for(TabelaFranchising tabela: tabelaList) {
							dataGrid.setId(String.valueOf(tabela.getCodigo()));
							dataGrid.addData(Util.zeroToLeft(tabela.getCodigo(), 3));
							dataGrid.addData(tabela.getDescricao());
							dataGrid.addData(Util.parseDate(tabela.getCadastro(), "dd/MM/yyyy"));
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