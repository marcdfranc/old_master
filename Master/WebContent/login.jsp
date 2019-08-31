<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page errorPage="/exception.jsp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="java.util.Random"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.CartaoAcesso"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Random random = new Random();
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	//Session sess = HibernateUtil.getSession();
	
	if (session.getAttribute("username").toString() == null) {
		response.sendRedirect("error_page.jsp?errorMsg=\'" + Util.SENHA_INVALIDA + "\'");
	}
	Query query = sess.createQuery("from CartaoAcesso as c " +
			" where c.login.username = :login " +
			" and c.status = 'a'");
	query.setString("login", session.getAttribute("username").toString());
	List<CartaoAcesso> cartaoList = (List<CartaoAcesso>) query.list();
	int position = random.nextInt(cartaoList.size());
	
	%>
<head>
	<link rel="shortcut icon" href="icone.ico">
	<link rel="StyleSheet" href="css/estilo.css" type="text/css" />
	<link type="text/css" href="js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master - Login</title>
	
	<script type="text/javascript" src="js/jquery/jquery.js"></script>
    <script type="text/javascript" src="js/jquery/interface.js"></script>	
	<script type="text/javascript" src="js/lib/util.js"></script>
	<script type="text/javascript" src="js/lib/componentes/msf_window.js"></script>
    <script type="text/javascript" src="js/comum/acesso.js" ></script>
    
    <script type="text/javascript">
    	load = function() {
        	$("#password").focus();
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
     
     
</head>
<body onload="load();">
	<%@ include file="inc/generic_header.html" %>
	<div id="center_content">
		<div id="roundBox" >
			<form id="login" method="post" action="AcessoSys" >
				<input type="hidden" id="numeroAcesso" name="numeroAcesso" value="<%= cartaoList.get(position).getIndex() %>"/>
				<div style="margin: 0 0 0 100px; padding-top:40px; clear: both;">
					<label><%= "Digite o acesso nº " + cartaoList.get(position).getIndex() %></label><br/>					
					<input id="password" name="password" type="password" style="widht:300px"/>
				</div>
				<div class="textBox">
					<div class="greenBtn" style="padding-top: 30px;" >
						<input id="login" class="greenButtonStyle" value="Acessar" type="submit" />
					</div>
				</div>
			</form>
		</div>
		<%@ include file="inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>