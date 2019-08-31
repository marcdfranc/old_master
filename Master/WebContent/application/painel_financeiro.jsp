<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Transaction"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Transaction transaction = sess.beginTransaction();
	%>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Painel Financeiro</title>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="financeiro"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="financeiro"/>
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="post" action="../CadastroPosicao">
				<div id="geralDate" class="alignHeader">
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Bancos"/>			
					</jsp:include>
					<div class="topContent">
					
					</div>
					<div id="mainContent">				
					<div id="dataGrid" style="" >
						<div id="centerGrid" style="min-height: 100px; margin-left: 193px; width: 350px">
							<div id="counter" style="width: 400px; float:left; margin-bottom: 5px" ></div>
							<%DataGrid dataGrid = new DataGrid("#");
							dataGrid.addColum("80", "Descricao");
							dataGrid.addColum("17", "Valor");
							dataGrid.addColum("3", "Ck");
							
							
							%>
						</div>
					</div>					
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%transaction.commit();	sess.close();%>
	</div>
</body>
</html>