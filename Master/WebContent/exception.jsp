<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
 <%@ page isErrorPage="true" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.utilities.ControleErro"%>
<%@page import="org.hibernate.Session"%>
<html xmlns="http://www.w3.org/1999/xhtml">
<%	Session sess = (Session) session.getAttribute("hb");
	if (sess != null && sess.isOpen()) {
		sess.close(); 
	}
%>
<head>
	<link rel="shortcut icon" href="icone.ico">
	<link rel="StyleSheet" href="css/estilo.css" type="text/css" />
	<link type="text/css" href="js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Mensagem</title>
	<script type="text/javascript" src="js/jquery/jquery.js"></script>
	<script type="text/javascript" src="js/jquery/interface.js"></script>
	<script type="text/javascript" src="js/lib/componentes/msf_window.js"></script>
	<script type="text/javascript" src="js/lib/util.js"></script>
	
	<script type="text/javascript">
		function showExcept() {
			$("#exceptionWindow").removeClass("cpEscondeWithHeight");
		 	$("#exceptionWindow").dialog({
		 		modal: true,
		 		width: 450,
		 		minWidth: 450,
		 		buttons: {
		 			"Ok": function() {
		 				$(this).dialog('destroy');
		 				$(this).addClass('cpEscondeWithHeight');
					}		 			
		 		},
		 		close: function() {
		 			$(this).dialog('destroy');
		 			$(this).addClass('cpEscondeWithHeight');
		 		}
		 	});
		}
	</script>
	
</head>
<body onload="showExcept()">
	<div id="exceptionWindow" class="cpEscondeWithHeight removeBorda" title="Erro de exibição">			
		<form id="formExceptionWindow" onsubmit="return false;">
			<fieldset>
				<label>Está página não foi exibida corretamente devido a um erro interno!</label>
			</fieldset>
		</form>
	</div>
</body>
</html>