<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="com.marcsoftware.relmatricial.ParcelaCupom"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Transaction"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Login"%><html xmlns="http://www.w3.org/1999/xhtml">

	<jsp:useBean id="login" class="com.marcsoftware.database.Login"></jsp:useBean>
	
	<%Session sess= HibernateUtil.getSession();	
	Transaction transaction = sess.beginTransaction();
	Query query = sess.createQuery("from Login as l where l.username = :username");
	query.setString("username", session.getAttribute("username").toString());
	login = (Login) query.uniqueResult();
	String porta = login.getPorta();
	transaction.commit(); 
	sess.close();	
	ParcelaCupom cupom = new ParcelaCupom();
	if (login.getColunas() == null) {
		cupom.setCols(40);
	} else {
		cupom.setCols(login.getColunas());
	}
	cupom.setPipe(request.getParameter("pp"));
	cupom.setUsername(session.getAttribute("username").toString());
	cupom.setVlrPago(Double.parseDouble(request.getParameter("vpg")));
	cupom.mountRel();
	String relatorio = cupom.getRelatorio();
	String link = Util.linkToNewPage(request, "rel_matricial/cupom_parcela.jsp", "splash_ok.jsp");
	%>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Cupon Parcelamento</title>
</head>
<body>
	<jsp:plugin code="com.master.RelAdmin" archive="aRelMatricial.jar" jreversion="1.2" codebase="../../applets" type="applet" width="160" height="150">
		<jsp:params>
			<jsp:param value="<%= relatorio %>" name="rel"/>
			<jsp:param value="<%= porta %>" name="porta"/>
			<jsp:param value="<%= link %>" name="next_page"/>			
		</jsp:params>
		<jsp:fallback>
			<p>Ocorreu um erro de carregamento</p>
		</jsp:fallback>
	</jsp:plugin>
</body>
</html>