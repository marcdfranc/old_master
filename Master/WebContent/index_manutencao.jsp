<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<link rel="stylesheet" type="text/css" href="css/component.css">
	<link rel="StyleSheet" href="css/estilo.css" type="text/css" />
	<script type="text/javascript" src="js/jquery/jquery.js"></script>
	<script type="text/javascript" src="js/lib/componentes/item_selector.js"></script>
	<script type="text/javascript" src="js/lib/util.js"></script>
	<script type="text/javascript" src="js/lib/componentes/msf_datagrid.js"></script>
	
	<script type="text/javascript">
		$(document).ready(function() {
			var data = [["1", "Marcelo Francisco"], ["2", "2 Lucina de Oliveira Francisco"],
				["3", "3 Marcilio Francisco"], ["4", "4 Leonilda Francisco"],
				["5", "5 Moacir Francisco"], ["6", "6 Alexandre do Carmo"],
				["7", "7 Vanessa Carnassale"], ["8", "8 Cristiane dos Santos"],
				["9", "9 Maria de Lurdes Francisco"]
			];

			
			var selec = new ItemSelector("macaco", "Seleção de nomes", "Selecionados",
					"valores", "maluco", 250, 745);
			selec.init(data);
			selec.setPoster("meleca");

			var dt = new MsfDataGrid("Marc", 600);
			dt.setPosition(200, 400);
			dt.addFields("50", "Nome");
			dt.addFields("50", "Idade");
			//data = "nome@marcelo;idade@31 anos|nome@Leonilda;idade@53 anos|" +
				//"nome@Marcilio;idade@55 anos";
			data = [
					[["nome", "marcelo"], ["idade", "31 anos"]], 
					[["nome", "Leonilda"], ["idade", "53 anos"]],
					[["nome", "marcilio"], ["idade", "55 anos"]]];
			dt.init(data, false);

			$("#dataGrid").empty();
			$("#dataGrid").append(dt.getHtm());

			dt.hide();

			mostraGd = function() {
				//alert("mostra");
				dt.show();
			}
			
			pega = function() {
				dt.setValueByIndex(2, "nome", "pai Francisco");
			}

			escondeGd= function() {
				//alert("esconde");
				dt.hide();
			}			
			
			mostraValor= function() {
				alert($("#meleca").text());
			}
		});
	</script>
		
	<title>Master Odontologia & Saúde</title>    
</head>
<body>
	<div id="maluco" name="maluco"></div>
	<input type="button" value="mostrar" onclick="mostrar()"/>
	<input type="button" value="esconder" onclick="esconder()"/>
	<a id="meleca" name="meleca" href="application/unidade.jsp">Sol que brilha</a>
	<input type="button" id="test" name="test" value="teste" onclick="mostraValor()"/>	
	<div id="dataGrid" style="margin-top: 40px"></div>
	
	<input type="button" value="pegar valor" onclick="pega()"/>
	<input type="button" value="mostra grid" onclick="mostraGd()"/>
	<input type="button" value="esconde grid" onclick="escondeGd()"/>
</body>
</html>