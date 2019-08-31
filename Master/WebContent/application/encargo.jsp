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
<%@page import="com.marcsoftware.database.Encargo"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/comum/encargo.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
<title>Master - Encargos</title>
</head>
<body onload="load()">
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="rh"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="rh"/>
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="post" action="../CadastroPosicao">
				<div id="geralDate" class="alignHeader">
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Encargos"/>			
					</jsp:include>
					<div class="topContent">
						<div id="codigo" class="textBox" style="width: 70px;">
							<label style="margin-left: 120px;">Descrição</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 70px; margin-left: 120px" readonly="readonly"/>
						</div>
						<div id="descricao" class="textBox" style="width: 280px;">
							<label style="margin-left: 120px;">Descrição</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 280px; margin-left: 120px"  />
						</div>
						<div id="percentual" class="textBox" style="width: 67px;">
							<label style="margin-left: 120px;">Percentual</label><br/>
							<input id="percentualIn" name="percentualIn" type="text" style="width: 67px; margin-left: 120px" onkeydown="mask(this, decimalNumber);"/>
						</div>			
					</div>
				</div>
				<div class="topButtonContent" style="margin-bottom: 20px">
					<div class="formGreenButton">
						<input id="inserir" name="inserir" class="greenButtonStyle" onclick="search();" type="button" value="Buscar"/>
					</div>
					<div class="formGreenButton">
						<input id="buscar" name="buscar" class="greenButtonStyle" onclick="addRecord();" type="button" value="Inserir"/>
					</div>
				</div>
				<div id="mainContent">				
					<div id="dataGrid" style="" >
						<div id="centerGrid" style="min-height: 100px; margin-left: 120px; width: 600px">
							<div id="counter" style="width: 400px; float:left; margin-bottom: 5px" ></div>
							<%DataGrid dataGrid= new DataGrid(null);
							Session sess = (Session) session.getAttribute("hb");
							if (!sess.isOpen()) {
								sess = HibernateUtil.getSession();
							}
							Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
							Query query= sess.createQuery("from Encargo as e order by e.codigo");
							int gridLines= query.list().size();
							query.setFirstResult(0);
							query.setMaxResults(10);							 
							List<Encargo> encargoList= (List<Encargo>) query.list();
							dataGrid.addColum("20", "Código");
							dataGrid.addColum("60", "Descrição");
							dataGrid.addColum("20", "percentual");
							if (encargoList != null) {
								for(Encargo encargo: encargoList) {
									dataGrid.setId(String.valueOf(encargo.getCodigo()));
									dataGrid.addData("codigo" + encargo.getCodigo() , String.valueOf(encargo.getCodigo()), false);
									dataGrid.addData("descricao" + encargo.getCodigo() , Util.initCap(encargo.getDescricao()), false);
									dataGrid.addData("percentual" + encargo.getCodigo(), String.valueOf(encargo.getPercentual()), false);
									dataGrid.addRow();
								}
							}
							out.print(dataGrid.getTable(gridLines));
							%>
						</div>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close(); %>
	</div>
</body>
</html>