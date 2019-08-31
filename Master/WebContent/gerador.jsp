<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<link rel="shortcut icon" href="icone.ico">
	<script type="text/javascript" src="js/jquery/jquery.js"></script>
	<script type="text/javascript" src="js/lib/gerador.js"></script>	
<title>Gerador</title>
</head>
<body>
	<form name="form1" method="post" action="">
  		<table width="261" border="0" align="center" cellpadding="0" cellspacing="2">
    		<tr align="center">
      			<td colspan="2" bgcolor="#003399">
      				<font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">
      					<strong>Gerador	de CPF e CNPJ Válidos</strong>
      				</font>
      			</td>
    		</tr>
		    <tr>
		    	<td colspan="2" align="center" bgcolor="#CCCCCC"><input name="numero" type="text" id="numero" size="20"></td>
		    </tr>
		    <tr>
		      	<td width="168" align="center" bgcolor="#CCCCCC">
		      		<font size="2" face="Verdana, Arial, Helvetica, sans-serif">
		        		<input name="tipo" type="radio" value="cpf" checked="checked">CPF
		        		<input name="tipo" type="radio" value="cnpj">CNPJ
		        	</font>
		        </td>		
		      <td width="126" align="center" bgcolor="#CCCCCC">
		      	<input type="button" name="Button" value="Gerar" onclick="faz()">
		      </td>
		    </tr>
  		</table>
	</form>
	<div align="center">
	     <font size="1" face="Verdana, Arial, Helvetica, sans-serif">
	     	Por: Marcelo de Oliveira Francisco<br> 
	     	Marcsoftware
		</font> 
	</div>
</body>
</html>