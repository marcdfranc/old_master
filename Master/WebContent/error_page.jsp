<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<link rel="shortcut icon" href="icone.ico">
	<link rel="StyleSheet" href="css/estilo.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="css/ieStyle.css" type="text/css" /><![endif]-->
	<title>Master Mensagem</title>
</head>
<body>
	<%@ include file="inc/generic_header.html" %>
	<div id="centerContent" >
		<div id="bigRoundBox">
			<blockquote><% out.print(Util.removeAspas(request.getParameter("errorMsg"))); %></blockquote>
			<div style="position: absolute; left: 50%; margin-left: -90px">				
				<input id="login" name="login" class="greenButtonStyle" value="Voltar" type="button" 
				onclick="location.href='<%
					if (request.getParameter("lk")== null) {
						out.print("index.jsp");
					} else {
						out.print(request.getParameter("lk"));
					}%>'" />
			</div>
		</div>		
		<%@ include file="inc/footer.html" %>	
	</div>
</body>
</html>

