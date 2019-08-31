<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />	
	<title>Master Cadastro de Unidade</title>
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	
	<script type="text/javascript">
		mostraTudo = function() {
			alert($("#valor").val());
		}
	</script>	
</head>
<body>
	<input type="hidden" id="valor" name="valor" value="<%=request.getParameter("rel") %>" />
	<input type="button" value="mostrar" onclick="mostraTudo()" />
</body>
</html>