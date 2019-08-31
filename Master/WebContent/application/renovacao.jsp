<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link rel="stylesheet" type="text/css" href="../js/ext/resources/css/ext-all.css">
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<script type="text/javascript" src="../js/ext/adapter/ext/ext-base.js"></script>
    <script type="text/javascript" src="../js/ext/ext-all-debug.js"></script>
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript">
		Ext.onReady(function() {
			cadastro = new Ext.form.DateField({
				id: 'renova',
				name: 'renova',
				cls: 'required',
				width: 95,
				height: 10,		
				validationEvent: false,
				validateOnBlur: false,
				enableKeyEvents: true,
				renderTo: 'renovaIn',
				value: document.getElementById("now").value												
			});	
			
			cadastro.on({
				'keyup': {
					fn: function() {
						aux = cadastro.getRawValue();
						aux= dateType(aux);				
						cadastro.setRawValue(aux);
					},
					escope: this
				}
			});		
		});
	
		renovar = function() {			
			$.get("../Renovacao", {
				from: "3",
				userId: $('#userId').val(),
				renovacao: $('#renova').val(),
				vigencia: $('#vigencia ').val(),
				vencimento: $('#vencimento').val(),
				qtde: $('#parcIn').val(),
				valor: $('#parcelaIn').val()
			}, function(response){
				if (response != "1") {
					alert("Ocorreu um erro durante a renoovação!");
					window.close();
				} else {
					alert("renovação realizada com sucesso!");
					window.close();
				}
			});
		}

		loadQtde = function() {
			$('#parcIn').val($('#vigencia ').val());
		}
	</script>
	
	<title>Master - Renovação</title>
</head>
<body>
	<div id="upload" class="carteiraUpload">
		<h1>Assistente de Renovação</h1>
	</div>
	<div>
		<input id="userId" name="userId" type="hidden" value="<%= request.getParameter("id") %>" />
	</div>
	<div id="cadastroCalendar" class="textBox" style="width:95px">
		<label>Data Renov.</label>
		<input id="now" name="now" type="hidden" value="<%=Util.getToday() %>" />
		<div id="renovaIn" name="renovaIn" class="calendario"></div>
	</div>
	<div class="textBox" style="width: 65px">
		<label>Venc.</label><br/>
		<select id="vencimento" name="vencimento">
			<option value="01">Dia 01</option>
			<option value="05">Dia 05</option>
			<option value="10">Dia 10</option>
			<option value="15">Dia 15</option>
			<option value="20">Dia 20</option>
			<option value="25">Dia 25</option>
		</select>
	</div>
	<div class="textBox" style="width: 90px">
		<label>Vigência</label><br/>
		<select id="vigencia" name="vigencia" onchange="loadQtde()">
			<option value="0">Selecione</option>
			<option value="6">6 meses</option>
			<option value="12">12 meses</option>
			<option value="18">18 meses</option>
			<option value="24">24 meses</option>
		</select>
	</div>
	<div id="parc" class="textBox" style="width: 90px;">
		<label>Qtde. Parc.</label><br/>
		<input id="parcIn" name="parcIn" type="text" onkeydown="mask(this, onlyInteger);" style="width: 90px;"/>
	</div>
	<div id="parcela" class="textBox" style="width: 100px;">
		<label>Parcela</label><br/>
		<input id="parcelaIn" name="parcelaIn" type="text" style="width: 100px;" value="10.00" onkeydown="mask(this, decimalNumber);" class="required"/>
	</div>
	<div class="buttonContent" >
		<div class="formGreenButton">							
			<input id="renovaButton" name="renovaButton" class="greenButtonStyle" type="button" value="Renovar" onclick="renovar()"/>
		</div>
	</div>
</body>
</html>