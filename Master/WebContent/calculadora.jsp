<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<link rel="StyleSheet" href="css/estilo.css" type="text/css" />
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Marcsoftware Calculadora</title>
	
	<script type="text/javascript" src="js/lib/calculadora.js"></script>
	
	<style type="text/css">
		body {
			background-color:#DBEFFA;
			color:#000000;
			font-family:Verdana,sans-serif;
			font-size:12px;
			text-align:center;
		}
		h1 {
			font-size:16px;
			margin:0;
			padding:0;
		}
		h2 {
			display:inline;
			font-size:12px;
		}
		h3 {
			display:inline;
			font-size:12px;
			font-weight:normal;
		}
		td {
			font-size:12px;
			vertical-align:top;
		}
		form {
			margin:0;
			padding:0;
		}
		.unit {
			text-align:right;
		}	
		.buttonContent {
			margin-right: 450px;
		}
	</style>
</head>
<body>
	<center>
	<form>
		<h1>Convers&atilde;o de unidades de Medidas de impress&atilde;o</h1>
		<table border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td>
					<table border="0" cellspacing="0" cellpadding="5">
						<tr>
							<td class="unit">Mil&iacute;metro (mm):</td>
							<td><input id="1" onchange="doCalc(1)" /></td>
						</tr>
						<tr>
							<td class="unit">Cent&iacute;metro (cm):</td>
							<td><input id="0" onchange="doCalc(0)" /></td>
						</tr>
						<tr>
							<td class="unit">Inch:</td>
							<td><input id="2" onchange="doCalc(2)" /></td>
						</tr>
					</table>
				</td>
				<td>
					<table border="0" cellspacing="0" cellpadding="5">
						<tr>
							<td class="unit">Pica:</td>
							<td><input id="3" onchange="doCalc(3)" /></td>
						</tr>
						<tr>
							<td class="unit">Point:</td>
							<td><input id="4" onchange="doCalc(4)" /></td>
						</tr>
						<tr>
							<td class="unit">Twip:</td>
							<td><input id="5" onchange="doCalc(5)" /></td>
						</tr>
						<tr>
							<td class="unit">Pixel (Resolu&ccedil;&atilde;o 600*800):</td>
							<td><input id="6" onchange="doCalc(6)" /></td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		<div class="buttonContent" >
			<input class="greenButtonStyle" type="button" value="Calcular" style="margin-left: 50px" />
			<input class="greenButtonStyle" type="reset" value="Apagar" />
		</div>
	</form>
</center>
</body>
</html>