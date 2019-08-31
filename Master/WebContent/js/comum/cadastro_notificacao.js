var globalIndex= 0;
var isEdition= false;
var flag;
var isChange = false;
var isAppend = false;
var isFree = false;
var vlrTotal= 0;

$(document).ready(function() {
	loadPage = function(isEd){
		var	aux= 0;
		isEdition = isEd;		
	}
	
	addRowServico = function() {
		var last = "";
		var htm = "";
		if ($("#contatoIn :selected").val() == ""
			&& $("#contatoAtendenteIn :selected").val() == "") {
			showWarning({
				width: 400,
				mensagem: "Selecione ao menos um usuario para enviar a mensagem.",
				title: "Erro"
			});	
		} else if ($("#contatoIn :selected").val() == "allCombo"
			&& $("#contatoAtendenteIn :selected").val() == "allCombo") {
			$('#contatoIn >*').each(function(ind, domEle) {
				if (domEle.value != "allCombo" && domEle.value != "") {
					$("#gridLines").remove();
					last = $("#dataBank").html();					
					htm = getRowMonted(domEle.value, globalIndex);
					processInc(htm, last);
				}
			});			
			$('#contatoAtendenteIn >*').each(function(ind, domEle) {
				if (domEle.value != "allCombo" && domEle.value != "") {
					$("#gridLines").remove();
					last = $("#dataBank").html();					
					htm = getRowMonted(domEle.value, globalIndex);
					processInc(htm, last);
				}
			});
			
		} else if ($("#contatoIn :selected").val() == "allCombo") {
			$('#contatoIn >*').each(function(ind, domEle) {
				if (domEle.value != "allCombo" && domEle.value != "") {
					$("#gridLines").remove();
					last = $("#dataBank").html();					
					htm = getRowMonted(domEle.value, globalIndex);
					processInc(htm, last);
				}
			});
		} else if ($("#contatoAtendenteIn :selected").val() == "allCombo") {
			$('#contatoAtendenteIn >*').each(function(ind, domEle) {
				if (domEle.value != "allCombo" && domEle.value != "") {
					$("#gridLines").remove();
					last = $("#dataBank").html();					
					htm = getRowMonted(domEle.value, globalIndex);
					processInc(htm, last);
				}
			});
		} else if ($("#contatoIn :selected").val() != ""
		&& $("#contatoAtendenteIn :selected").val() != "") {	
			$("#gridLines").remove();
			last = $("#dataBank").html();
			htm = getRowMonted($("#contatoAtendenteIn :selected").val(), globalIndex);
			processInc(htm, last);
			$("#gridLines").remove();
			last = $("#dataBank").html();
			htm = getRowMonted($("#contatoIn :selected").val(), globalIndex);
			processInc(htm, last);
		} else if ($("#contatoIn :selected").val() == "") {			
			$("#gridLines").remove();
			last = $("#dataBank").html();
			htm = getRowMonted($("#contatoAtendenteIn :selected").val(), globalIndex);
			processInc(htm, last);
		} else {
			$("#gridLines").remove();
			last = $("#dataBank").html();
			htm = getRowMonted($("#contatoIn :selected").val(), globalIndex);
			processInc(htm, last);
		}
		document.getElementById("contatoIn").selectedIndex = 0;
		document.getElementById("contatoAtendenteIn").selectedIndex = 0;
	} 
	
	processInc = function(htm, last) {
		if (htm != "") {
			htm = last + htm;
			$("#dataBank").empty();
			$("#dataBank").append(htm);			
			$("#contatoIn").focus();
			globalIndex++;
		}
	}
	
	removeRowServico= function() {
		var htm = "";
		var indexNew = 0;
		$("#dataBank >*").each(function(ind, domEle) {
			if (document.getElementById("checkrowTabela" + ind).checked) {
				globalIndex--;
				indexNew++;
			} else {
				htm+= getRowForDel(ind - indexNew , ind);
			}
		});
		$("#dataBank").empty();
		$("#dataBank").append(htm);				
		$("#contatoIn").focus();
	}
	
	getRowMonted = function (valueCombo, index) {
		var aux = "";		
		var htm = "<tr class=\"gridRow\" id=\"line" + index + "\" name=\"line" + index +
			"\" ><td><img style=\"height: 60px; width: 55px\" id=\"rowFoto" + index +
			 "\" name=\"rowFoto" + index + "\" src=\""; 
			
		aux = getPipeByIndex(valueCombo, 1); 
		if (aux == "" || aux == "null") {
			htm+= "../image/foto.gif" + "\" /></td>";
		} else {
			htm+=  getPipeByIndex(valueCombo, 1) +"\" /></td>";
		}		
			  
		htm += "<td><label id=\"rowUser" + index + "\" name=\"rowUser" + index + 
			"\" >" + getPipeByIndex(valueCombo, 0) + "</label></td>";
			
		htm+= "<td><label id=\"rowPerfil" + index + "\" name=\"rowPerfil" + 
			index + "\" >";
		
		switch (getPipeByIndex(valueCombo, 2)) {
			case 'a':
			case 'f':
				 htm+= "Administrador</label></td>";
				break;
				
			case 'd':
				 htm+= "Desenvolvedor</label></td>";			
				break;
			
			case 'r':
				 htm+= "Atendente</label></td>";			
				break;
		}
			
		htm += "<td><label id=\"rowVista" + index + "\" name=\"rowVista" + index + "\" >" + 
			"Não</label></td>";
			
		htm += "<td style=\"width: 10px;\"><input id=\"checkrowTabela" + index + 
			"\" name=\"checkrowTabela" + index + "\" type=\"checkbox\"/></td></tr>";
	
		return htm;
	}
	
	getRowForDel = function (value, indexRow) {
		var htm = "<tr class=\"gridRow\" id=\"line" + value + "\" name=\"line" + value +
			"\" ><td><img style=\"height: 60px; width: 55px\" id=\"rowFoto" + value + "\" name=\"rowFoto" + value + "\" src=\"" +
			$("#rowFoto" + indexRow).attr("src") + "\" /></td>";
			
		htm += "<td><label id=\"rowUser" + value + "\" name=\"rowUser" + value + 
			"\" >" + $("#rowUser" + indexRow).text() + "</label></td>";
		
		htm += "<td><label id=\"rowPerfil" + value + "\" name=\"rowPerfil" + 
			value + "\" >" + $("#rowPerfil" + indexRow).text() + "</label></td>";
		
		htm += "<td><label id=\"rowVista" + value + "\" name=\"rowVista" + value + "\" >" + 
			$("#rowVista" + indexRow).text() + "</label></td>";
			
		htm += "<td style=\"width: 10px;\"><input id=\"checkrowTabela" + value + 
			"\" name=\"checkrowTabela" + value + "\" type=\"checkbox\"/></td></tr>";
		
		return htm;
	}
	
	/*$('#unidadeIn').change(function () {
		var unidadeId = $(this).val(); 
		if(unidadeId != "") {
			$.get("../CadastroNotificacao", {
				from: "7",
				unidadeId: unidadeId
			}, function (response) {
				var admList = $(response).find("logins[id=adm]");
				var atendenteList = $(response).find("logins[id=atendente]");
				var countAdm = $(admList).find("login").length;
				var countAtendente = $(atendenteList).find("login").length;
				var htm;
				$(admList).find("login").each(function (i) {
					if (i == 0) {
						htm = "<option value=\"\">Selecione</option><option value=\"allCombo\">Todos</option>";							
					}
					htm+= "<option value=\"" + $(this).attr("username") + "@" +
						 $(this).attr("foto") + "@f\">" + $(this).attr("username") +
						 "</option>"				
					if (i == countAdm) {
						$('#contatoIn').empty();
						$('#contatoIn').append(htm);
					}								
				});
				$(atendenteList).find("login").each(function (i) {
					if (i == 0) {
						htm = "<option value=\"\">Selecione</option><option value=\"allCombo\">Todos</option>";							
					}
					htm+= "<option value=\"" + $(this).attr("username") + "@" +
						 $(this).attr("foto") + "@f\">" + $(this).attr("username") +
						 "</option>"				
					if (i == countAtendente) {
						$('#contatoAtendenteIn').empty();
						$('#contatoAtendenteIn').append(htm);
					}
				});
			});
		}
	});*/	
	
	
	mountTabelaPost = function () {
		var htm = "";
		var isOk = false; 
		var tamanho = $("#dataBank > *").length;
 		$("#dataBank > *").each(function (ind, domEle) {
 			htm += "<input type=\"hidden\" id=\"rowUser" + ind + "\" name=\"rowUser" +
 				ind + "\" value=\"" + $("#rowUser" + ind).text() + "\">" +
 				"<input type=\"hidden\" id=\"rowVista" + ind + "\" name=\"rowVista" +
 				ind + "\" value=\"" + $("#rowVista" + ind).text() + "\">";
 			isok = true;
 		}); 		
 		$("#dataBank").remove();
 		$("#localContato").append(htm);
 		return tamanho;		
 	}
	
	$("input").keypress(function (e) {
		if (e.which == 13) {
			addRowServico();
		}
	});
	
	marcarLida = function () {
		$.get("../CadastroNotificacao", {
			from: "1",
			id: $("#codNotificacao").val()
		}, function (response) {
			location.href = response;
		});
	} 
	
	enviarNotificacao = function () {
		if (validForm(document.forms["formPost"])) {			
			if (mountTabelaPost() == 0) {
				showWarning({
					width: 400,
					mensagem: "Selecione ao menos um usuario para enviar a mensagem.",
					title: "Erro"
				});	
			} else {
			 	document.forms["formPost"].submit();
			}		
		}
	}
});