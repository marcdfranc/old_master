<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link rel="stylesheet" type="text/css" href="../css/component.css">
	<link rel="stylesheet" type="text/css" href="../js/ext/resources/css/ext-all.css">	
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<script type="text/javascript" src="../js/ext/adapter/ext/ext-base.js"></script>
    <script type="text/javascript" src="../js/ext/ext-all-debug.js"></script>
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/item_selector.js"></script>
	<script type="text/javascript" src="../js/comum/carteirinha.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	
	<title>Master Carteirinha</title>
</head>
<body>
	<div id="upload" class="carteiraUpload">
		<h1>Assistente de Carteirinha</h1>
	</div>
	<div id="center">
		<form name="formPost" method="post" name="formPost" action="../ImageUpload" enctype="multipart/form-data">
			<div id="texto">
				<p>Este assistente irá auxilia-lo na impressão de carteirinhas.</p>
				<p>Siga corretamente as intruções a fim de que sejam geradas as carteirinhas desejadas.</p><br />			
				<blockquote>Primeiramente escolha se deseja que a seleção seja feita somente entre carteirinhas que estejam em sua primeira via.</blockquote>
				<br />			
			</div>
			<div id="cpStore" class="textBox" style="width: 300px">
				<label >Vias</label><br />
				<div class="checkRadio">
					<label class="labelCheck">Todas as Carteirinhas</label>					
					<input id="viaT" name="via" type="radio" checked="checked" value="t" />
					<label class="labelCheck" >Primeiras Vias</label>
					<input id="viaP" name="via" type="radio" value="p" />
				</div>
			</div>			
			<div class="textBoxComponent" style="margin-left: 190px; margin-top: 30px">
				<div class="buttonContentLeft" >
					<div class="formGreenButton">							
						<input id="volta" name="volta" class="greenButtonStyle" type="button" value="< Voltar" onclick="voltar()"/>
					</div>
					<div class="formGreenButton">
						<input id="avante" name="avante" class="greenButtonStyle" style="margin-right: 40px" type="button" value="Avançar >" onclick="avancar()"/>
					</div>					
					<div class="formGreenButton" >
						<input id="cancel" name="cancel" class="greenButtonStyle" type="button" value="Cancelar" onclick="cancelar()"/>
					</div>				
				</div>				
			</div>
		</form>
	</div>
</body>
</html>