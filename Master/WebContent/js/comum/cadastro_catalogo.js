var globalIndex;
var isEdit = false;
var idForDel = "";

function checkRequerido() {
	$('#enderecoRequeridovalidMsg').parent().remove();
	$('#cidadeRequeridovalidMsg').parent().remove();
	$('#ufRequeridovalidMsg').parent().remove();
	if ($('#cepIn').val() != ""
		|| $('#ruaIn').val() != ""
		|| $('#complementoIn').val() != ""
		|| $('#bairroIn').val() != ""
		|| $('#cidadeIn').val() != ""
		|| $('#ufIn').val() != "") {
		
		if ($('#ruaIn').val() == "") {
			$('#ruaIn').after("<div class=\"errorMsg\"> " +
				"<p class=\"validMsg\" id=\"enderecoRequeridovalidMsg\">"+
				"Campo Requerido!</p></div>");
			return false;
		}
		
		if ($('#cidadeIn').val() == "") {
			$('#cidadeIn').after("<div class=\"errorMsg\"> " +
				"<p class=\"validMsg\" id=\"cidadeRequeridovalidMsg\">"+
				"Campo Requerido!</p></div>");
			return false;
		} 			
			
		
		if ($('#ufIn').val() == "") {
			$('#uf').after("<div class=\"errorMsg\"> " +
				"<p class=\"validMsg\" id=\"ufRequeridovalidMsg\">"+
				"Campo Requerido!</p></div>");
			return false;
		}
	}
	
	$('#empresaRequeridovalidMsg').parent().remove();
	if ($('#cargoIn').val() != ""
		|| $('#setorIn').val() != ""
		|| $('#cepEmpIn').val() != ""
		|| $('#enderecoIn').val() != ""
		|| $('#complementoEmpIn').val() != ""
		|| $('#bairroEmpIn').val() != ""
		|| $('#cidadeEmpIn').val() != ""
		|| $('#ufEmpIn').val() != ""
		|| $('#siteIn').val() != ""
		|| $('#telefoneEmpIn').val() != "") {
		
		if ($('#empresaIn').val() == "") {
			$('#empresaIn').after("<div class=\"errorMsg\"> " +
				"<p class=\"validMsg\" id=\"empresaRequeridovalidMsg\">"+
				"Campo Requerido!</p></div>");
			return false;
		}
		
		
	}
	
	$('#empresaEnderecoRequeridovalidMsg').parent().remove();
	$('#empresaCidadeRequeridovalidMsg').parent().remove();
	$('#empresaUfRequeridovalidMsg').parent().remove();
	if ($('#cepEmpIn').val() != ""
		|| $('#enderecoIn').val() != ""
		|| $('#complementoEmpIn').val() != ""
		|| $('#bairroEmpIn').val() != ""
		|| $('#cidadeEmpIn').val() != ""
		|| $('#ufEmpIn').val() != "") {
		
		if ($('#enderecoIn').val() == "") {
			$('#enderecoIn').after("<div class=\"errorMsg\"> " +
				"<p class=\"validMsg\" id=\"empresaEnderecoRequeridovalidMsg\">"+
				"Campo Requerido!</p></div>");
			return false;
		}
		
		if ($('#cidadeEmpIn').val() == "") {
			$('#cidadeEmpIn').after("<div class=\"errorMsg\"> " +
				"<p class=\"validMsg\" id=\"empresaCidadeRequeridovalidMsg\">"+
				"Campo Requerido!</p></div>");
			return false;
		}
		
		if ($('#ufEmpIn').val() == "") {
			$('#ufEmpIn').after("<div class=\"errorMsg\"> " +
				"<p class=\"validMsg\" id=\"empresaUfRequeridovalidMsg\">"+
				"Campo Requerido!</p></div>");
			return false;
		}
	}
	return true;
}

function checaValidacao(obj) {
	var result = checkRequerido();
	if (!result) {
		return result;
	} else {
		return validForm(obj);
	}
}

function addRowInfo() {
	if (isEdit) {
		document.getElementById(idForDel).checked = true;
		isEdit = false;
		idForDel = "";
		removeRowInfo();
	}
	$("#gridLines").remove();
	var last = $("#dataBank").html();
	var htm = getRowMonted(globalIndex);
	if (htm != "") {
		htm = last + htm;
		$("#dataBank").empty();
		$("#dataBank").append(htm);
		
		document.getElementById("tipoContato").selectedIndex = 0;
		$("#descricaoIn").val("");		
		document.getElementById("principalIn").selectedIndex = 1;		
		globalIndex++;
	}
} 

function removeRowInfo() {
	var htm = "";
	var indexNew = 0;
	$("#dataBank >*").each(function(ind, domEle) {
		if ($(domEle).attr("class") == "gridRow") {
			if (document.getElementById("checkrowTabela" + ind).checked) {
				globalIndex--;
				indexNew++;
			} else {
				htm+= getRowForDel(ind - indexNew , ind);
			}
		}
	});
	$("#dataBank").empty();
	$("#dataBank").append(htm);	
	$("#tipoContato").focus();
}

function getRowMonted(value) {
	var seletorTipo = document.getElementById("tipoContato");	
	if ((seletorTipo.value == "") || ($("#descricaoIn").val() == "")) {
		showWarning({
			width: 400,
			mensagem: "Para realizar esta operação é necessário prrencher todos os campos da informação!",
			title: "Acesso Negado"
		});	
 		return "";
	}
		
	var htm = "<tr class=\"gridRow\" id=\"line" + value + "\" name=\"line" + value +
			"\" ><td><label id=\"rowTipo" + value + "\" name=\"rowTipo" + value + "\"" +
			" onclick=\"editarLinha(" + value + ")\" >" + $('#tipoContato').val() + "</label></td>";
			
	
	htm += "<td><label id=\"rowDescricao" + value + "\" name=\"rowDescricao" + value + 
			"\" onclick=\"editarLinha(" + value + ")\" >" + $("#descricaoIn").val() + "</label></td>";		
		
	htm += "<td><label id=\"rowPrincipal" + value + "\" name=\"rowPrincipal" + value + "\" " +
			" onclick=\"editarLinha(" + value + ")\" >" + $('#principalIn').val() + "</label></td>";
		
	htm += "<td style=\"width: 10px;\"><input id=\"checkrowTabela" + value + 
		"\" name=\"checkrowTabela" + value + "\" type=\"checkbox\"/></td></tr>";
	
	return htm;
}

function getRowForDel(value, indexRow) {
	var htm = "<tr class=\"gridRow\" id=\"line" + value + "\" name=\"line" + value +
			"\" ><td><label id=\"rowTipo" + value + "\" name=\"rowTipo" + value + "\" " +
			" onclick=\"editarLinha(" + value + ")\">" + $("#rowTipo" + indexRow).text() + "</label></td>";
		
	htm += "<td><label id=\"rowDescricao" + value + "\" name=\"rowDescricao" + value + 
			"\" onclick=\"editarLinha(" + value + ")\" >" + $("#rowDescricao" + indexRow).text() + "</label></td>";
	
	htm += "<td><label id=\"rowPrincipal" + value + "\" name=\"rowPrincipal" + value + "\" " +
			" onclick=\"editarLinha(" + value + ")\">" + $("#rowPrincipal" + indexRow).text() + "</label></td>";
		
	htm += "<td style=\"width: 10px;\"><input id=\"checkrowTabela" + value + 
			"\" name=\"checkrowTabela" + value + "\" type=\"checkbox\"/></td></tr>";
	
	return htm;
}

function mountTabelaPost() {
	var htm = "";
	var  principal;
	$("#dataBank > *").each(function (ind, domEle) {
		principal = ($("#rowPrincipal" + ind).text() == "Sim")? "s" : "n";
		
		htm += "<input type=\"hidden\" id=\"rowTipo" + ind + "\" name=\"rowTipo" +
			ind + "\" value=\"" + $("#rowTipo" + ind).text() + "\">";
		
		htm += "<input type=\"hidden\" id=\"rowDescricao" + ind + "\" name=\"rowDescricao" +
			ind + "\" value=\"" + $("#rowDescricao" + ind).text() + "\">";
		
		htm += "<input type=\"hidden\" id=\"rowPrincipal" + ind + "\" name=\"rowPrincipal" +
			ind + "\" value=\"" + principal + "\">";
	});
	
	$("#dataBank").remove();
	$("#localTabela").append(htm);
}

function editarLinha(value) {
	var tipo = 	$('#rowTipo' + value).text();
	tipo = tipo.toLowerCase();
	//document.getElementById("checkrowTabela" + value).checked = true;
	$('#tipoContato').val(tipo);
	$('#descricaoIn').val($("#rowDescricao" + value).text());
	$('#principalIn').val($("#rowPrincipal" + value).text());
	isEdit = true;
	idForDel = "checkrowTabela" + value;
}

function showGlobal() {
	
}

function loadEndereco(xml) {
	$('#ruaIn').val($(xml).find("rua").text() + ", ");
	$('#bairroIn').val($(xml).find("bairro").text());
	$('#cidadeIn').val($(xml).find("cidade").text());
	$('#ufIn').val($(xml).find("uf").text());
	$('#ruaIn').focus();
}

function loadEnderecoEmp(xml) {
	$('#enderecoIn').val($(xml).find("rua").text() + ", ");
	$('#bairroEmpIn').val($(xml).find("bairro").text());
	$('#cidadeEmpIn').val($(xml).find("cidade").text());
	$('#ufEmpIn').val($(xml).find("uf").text());
	$('#enderecoIn').focus();
}

function stringToXml(xmlData) {
	if (window.ActiveXObject) {
		//for IE
		xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
		xmlDoc.async="false";
		xmlDoc.loadXML(xmlData);
		return xmlDoc;
	} else if (document.implementation && document.implementation.createDocument) {
		//for Mozila
		parser=new DOMParser();
		xmlDoc=parser.parseFromString(xmlData,"text/xml");
		return xmlDoc;
	}
}


function enviarCatalogo() {
	if (checaValidacao(document.forms["formPost"])) {
		mountTabelaPost();
		document.forms["formPost"].submit();
	} else {
		showErrorMessage({
			width: 400,
			mensagem: "Existem campos vazios ou preenchidos incorretamente no formulário!",
			title: "Erro de Validação"
		});	
	}
}

function editBlocoNota() {
	var oldText = $('#blcNota').val();
	var isSave = false;
	$("#windowNota").dialog({
 		modal: true,
 		width: 800,
 		minWidth: 300,
 		show: 'fade',
		hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close');
 			},
 			"imprimir" : function() {
 				top = (screen.height - 600)/2;
				left= (screen.width - 800)/2;
				window.open("../GeradorRelatorio?rel=197&parametros=448@" + $('#usuario').val(), 
						'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
				$(this).dialog('close');
			},
 			"Salvar": function () {
 				isSave = true;
 				$.get("../CadastroCatalogo", {
 					from: '5',
 					blcNota: $('#blcNota').val() }, 
 					function(response) {
 						showMessage({
							mensagem: response,
							title: "Mensagem"
						});
 					}
 				);
				$(this).dialog('close');
 			}
 		},
 		close: function() {
 			$(this).dialog('destroy');
 			if (!isSave) {
 				$('#blcNota').val(oldText);
 			}
 		}
 	});
}

$(document).ready(function() {	
	if ($('#catalogoId').val() == "-1") {
		globalIndex = 0;
	} else {
		globalIndex = parseInt($('#gridLines').val());
	}
	
	$('#cepIn').blur(function() {
		if ($('#cepIn').val() != "" && $('#cepIn').val().length == 9) {
			$.ajax({
				type: "GET",
				url: "../FuncionarioGet?from=15&cep=" + $('#cepIn').val(),
				success: function(response) {
					loadEndereco(response)
				}, 
				error: function(response) {
					loadEndereco(stringToXml(response));
				}
			});
		}
	});
	
	$('#cepEmpIn').blur(function() {
		if ($('#cepEmpIn').val() != "" && $('#cepEmpIn').val().length == 9) {
			$.ajax({
				type: "GET",
				url: "../FuncionarioGet?from=15&cep=" + $('#cepEmpIn').val(),
				success: function(response) {
					loadEnderecoEmp(response)
				}, 
				error: function(response) {
					loadEnderecoEmp(stringToXml(response));
				}
			});
		}
	});
});