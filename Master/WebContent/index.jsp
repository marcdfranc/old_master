<?xml version="1.0" encoding="ISO-8859-1"?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@page import="com.marcsoftware.system.Authentic"%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<link rel="shortcut icon" href="icone.ico">
	<link rel="StyleSheet" href="css/estilo.css" type="text/css" />
	<link type="text/css" href="js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="css/ieStyle.css" type="text/css" /><![endif]-->
		
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />	
	
    <script type="text/javascript" src="js/jquery/jquery.js"></script>
    <script type="text/javascript" src="js/jquery/interface.js"></script>	
	<script type="text/javascript" src="js/lib/util.js"></script>
	<script type="text/javascript" src="js/lib/componentes/msf_window.js"></script>
    <script type="text/javascript" src="js/comum/login.js" ></script> 
    
    
    <script type="text/javascript">
    	load = function() {
        	$("#username").focus();
    	}

    	getInforme = function () {
    		$.get("Authentic",{},
			function (response) {				
				alert(response);
			});
    	}
    </script>
        
    <style type="text/css">
    	.localLoader div {
			padding:10px 10px 5px 25px;
			background: #ffffff url(image/loader.gif) no-repeat 15px 5px;
			line-height: 16px;
			height: 40px;
			width: 145px;        
		}

		.localLoader div p {
			margin: 20px 0 0 20px;
		}    	
    </style>
	
	<title>Master Login</title>
</head>
<body onload="load();">
	<%@ include file="inc/generic_header.html" %>
	<div id="center_content">
		<div id="roundBox" >
			<form id="login" method="post" action="Authentic" >
				<div style="margin: 0 0 0 100px; padding-top:30px; clear: both;" >
					<label>Usuário</label><br/>
					<input id="username" name="username" type="text" style="widht:300px !important" />
				</div>
				<div style="margin: 0 0 0 100px; clear: both;">
					<label>Senha</label><br/>					
					<input id="password" name="password" type="password" style="widht:200px"/>
				</div>
				<div class="textBox">
					<div class="greenBtn" >
						<input id="login" class="greenButtonStyle" value="Login" type="submit" />
					</div>
				</div>
			</form>
		</div>
		<%@ include file="inc/footer.html" %>
	</div>
</body>
</html>