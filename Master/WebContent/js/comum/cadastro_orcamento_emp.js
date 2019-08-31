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
		$("#gridLines").remove();
		var last = $("#dataBank").html();
		var htm = getRowMonted(globalIndex);
		if (htm != "") {
			htm = last + htm;
			$("#dataBank").empty();
			$("#dataBank").append(htm);
			$("#servicoRefIn").val("");		
			$("#especialidadeIn").val("");
			$("#servicoIn").val("");
			$("#qtdeIn").val("1");
			$("#vlrUnitIn").val("0.00");
			getValor();
			$("#servicoRefIn").focus();
			if (globalIndex == 0) {
				$('#tabelaIn').attr("disabled", "disabled");
			}
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
		getValor();
		if (globalIndex < 1) {
			$('#tabelaIn').removeAttr("disabled", "disabled");
		}
		$("#servicoRefIn").focus();
	}
	
	getRowMonted = function (value) {
		var seletorTabela = document.getElementById("tabelaIn");
		var seletorSetor = document.getElementById("setorIn");
		if ((seletorTabela.value == "") || (seletorSetor.value == "") 
				|| ($("#servicoRefIn").val() == "")	|| ($("#servicoIn").val() == "")
				|| ($("#qtdeIn").val() == "")) {
			showWarning({
				width: 400,
				mensagem: "Para realizar esta operação é necessário prrencher todos os campos de procedimento.",
				title: "Acesso Negado"
			});	
	 		return "";
		}
			
		var htm = "<tr class=\"gridRow\" id=\"line" + value + "\" name=\"line" + value +
			"\" ><td><label id=\"rowSetor" + value + "\" name=\"rowSetor" + value + "\" >";
			
		switch (seletorSetor.value) {
			case 'o':
				htm += "Odontológica</label></td>";
				break;

			case 'l':
				htm += "Laboratorial</label></td>";
				break;
				
			case 'm':
				htm += "Médica</label></td>";
				break;
				
			case 'h':
				htm += "Hospitalar</label></td>";
				break;
		}	  
		htm += "<td><label id=\"rowEspecialidade" + value + "\" name=\"rowEspecialidade" + value + 
			"\" >" + $("#especialidadeIn").val() + "</label></td>";
			
		htm+= "<td><label id=\"rowCodigo" + value + "\" name=\"rowCodigo" + 
			value + "\" >" + $("#servicoRefIn").val() + "</label></td>"; 
			
		htm += "<td><label id=\"rowServico" + value + "\" name=\"rowServico" + value + "\" >" + 
			$("#servicoIn").val() +	"</label></td>";
		
		htm += "<td><label id=\"rowValor" + value + "\" name=\"rowValor" + value + "\" >" + 
			$("#vlrUnitIn").val() + "</label></td>";
		
		htm += "<td><label id=\"rowQtde" + value + "\" name=\"rowQtde" + value + "\" >" + 
			$("#qtdeIn").val() + "</label></td>";
			
		htm += "<td><label id=\"rowTotal" + value + "\" name=\"rowTotal" + value + "\" >" + 
			formatCurrency(parseFloat($("#qtdeIn").val()) * parseFloat($("#vlrUnitIn").val())) + 
			"</label></td>";
			
		htm += "<td style=\"width: 10px;\"><input id=\"checkrowTabela" + value + 
			"\" name=\"checkrowTabela" + value + "\" type=\"checkbox\"/></td></tr>";
		
		return htm;
	}
	
	getRowForDel = function (value, indexRow) {
		var htm = "<tr class=\"gridRow\" id=\"line" + value + "\" name=\"line" + value +
			"\" ><td><label id=\"rowSetor" + value + "\" name=\"rowSetor" + value + "\" >" +
			$("#rowSetor" + indexRow).text() + "</label></td>";
			
		htm += "<td><label id=\"rowEspecialidade" + value + "\" name=\"rowEspecialidade" + value + 
			"\" >" + $("#rowEspecialidade" + indexRow).text() + "</label></td>";
		
		htm += "<td><label id=\"rowCodigo" + value + "\" name=\"rowCodigo" + 
			value + "\" >" + $("#rowCodigo" + indexRow).text() + "</label></td>";
		
		htm += "<td><label id=\"rowServico" + value + "\" name=\"rowServico" + value + "\" >" + 
			$("#rowServico" + indexRow).text() + "</label></td>";
			
		htm += "<td><label id=\"rowValor" + value + "\" name=\"rowValor" + value + "\" >" + 
			$("#rowValor" + indexRow).text() + "</label></td>";
		
		htm += "<td><label id=\"rowQtde" + value + "\" name=\"rowQtde" + value + "\" >" + 
			$("#rowQtde" + indexRow).text() + "</label></td>";
			
		htm += "<td><label id=\"rowTotal" + value + "\" name=\"rowTotal" + value + "\" >" + 
			 $("#rowTotal" + indexRow).text() + "</label></td>";
			
		htm += "<td style=\"width: 10px;\"><input id=\"checkrowTabela" + value + 
			"\" name=\"checkrowTabela" + value + "\" type=\"checkbox\"/></td></tr>";
		
		return htm;
	}
	
	processarEmpresas = function () {
 		if ($('#unidadeIdIn').val() != "" && $('#setorIn').val()) {
			$.get("../FuncionarioGet",{
				unidadeId: getPart($('#unidadeIdIn').val(), 2),
				setor: $('#setorIn').val(),
				from: "16"
				},
				function (response) {
					var empresas = "<option value=\"\">Selecione</option>";
					var tabelaVigencia = empresas;
					var pipeTabela = unmountPipe(response);
					var pipe = unmountPipe(ptVirgulaToRealPipe(pipeTabela[0]));
					pipeTabela = unmountPipe(ptVirgulaToRealPipe(pipeTabela[1]));
					for(var i=0; i<pipe.length; i++) {
						empresas+= "<option value=\"" + getPipeByIndex(pipe[i], 0) + 
							"@" + getPipeByIndex(pipe[i], 2) +  "\">" + 
							getPipeByIndex(pipe[i], 1) + "</option>";
					}
					for(var i = 0; i < pipeTabela.length; i++) {
						tabelaVigencia+= "<option value=\"" + getPart(pipeTabela[i], 1) + "\">" +
							getPart(pipeTabela[i], 2) + "</option>";
					}
					$('#empIdIn').empty();
					$('#empIdIn').append(empresas);
					if (!isEdition) {
						$('#tabelaIn').empty();
						$('#tabelaIn').append(tabelaVigencia);
					}
					document.getElementById("empIdIn").selectedIndex= 0;
				}
			);
 		} else {
 			$('#empIdIn').empty();
 			$('#empIdIn').append("<option value=\"\">Selecione</option>");
 		}
	}
	
	$('#unidadeIdIn').change(function(){
		$('#unidadeIn').val(getPart($('#unidadeIdIn').val(), 1));
		processarEmpresas();
	});	
	
	$('#setorIn').change(function(){
		processarEmpresas();
	});	
	
	$('#empIdIn').change(function() {
		if($('#empIdIn').val() != "") {
			index = document.getElementById("empIdIn").selectedIndex;
			$('#conselhoIn').val(getPart(document.getElementById("empIdIn").options[index].value, 2));
		} else {
			$('#conselhoIn').val("");
		}
	});	
	
	$('#empIdIn').blur(function() {
		if ($('#empIdIn').val() != "") {
			if ($('#ctr').val() != "") {				
				$("#servicoRefIn").removeAttr("readOnly", "readOnly");				
				$('#qtdeIn').removeAttr("readOnly", "readOnly");
			}			
		} else {
			$('#servicoRefIn').attr({readOnly: "readOnly"});			
			$('#qtdeIn').attr({readOnly: "readOnly"});
		}
		$("#ctr").focus();
	});
	
	$('#ctr').blur(function() {
		if($('#ctr').val() != "") {
			if ($('#empIdIn').val() != "") {				
				$("#servicoRefIn").removeAttr("readOnly", "readOnly");				
				$('#qtdeIn').removeAttr("readOnly", "readOnly");
			}					
			$.get("../FuncionarioGet",{
				ctr: $('#ctr').val(),
				unidade: $('#unidadeIdIn').val(), 
				from: "12"
				},
				function (response) {
					var pipe = unmountPipe(response);
					var aux = "<option value=\"\">Selecione</option>";					
					for(var i=0; i<pipe.length; i++) {
						if (i == 0) {
							$("#userIdIn").val(getPipeByIndex(pipe[i], 0));
							$("#usuarioIn").val(getPipeByIndex(pipe[i], 1));
							if (getPipeByIndex(pipe[i], 2) == 2) {
								$("#tabelaIn").val('particular');
							}
						} else {
							aux+= "<option value=\"" + getPart(pipe[i], 1) + 
								"\">" + getPart(pipe[i], 2) + "</option>";
						}
					}					
					$('#dependenteIdIn').empty();
					$('#dependenteIdIn').append(aux);
					document.getElementById("dependenteIdIn").selectedIndex= 0;					
				}
			);
		} else {
			$('#servicoRefIn').attr({readOnly: "readOnly"});			
			$('#qtdeIn').attr({readOnly: "readOnly"});
			$("#usuarioIn").val("");
		}
		$('#dependenteIdIn').focus();
	});
	
	$('#servicoRefIn').blur(function() {
		var qtde = 0;
		$("#dataBank >*").each(function (index, domEle) {
 			if ($("#rowCodigo" + index).text() == $("#servicoRefIn").val()) {
 				qtde++;
 			}
 		});
 		var seletorSetor = document.getElementById("setorIn");
 		var seletorTabela = document.getElementById("tabelaIn");
		$.get("../FuncionarioGet",{			
			referencia: $("#servicoRefIn").val(),
			unidade: getPart($("#unidadeIdIn").val(), 2),
			setor:  seletorSetor.value,
			tabela: seletorTabela.value,
			usuarioId : $("#userIdIn").val(),
			dependente: $("#dependenteIdIn").val(),
			qtde: qtde,
			from: "13"},
			function (response) {
				$("#servicoIdIn").val(getPipeByIndex(response, 0));
				$("#servicoIn").val(getPipeByIndex(response, 1));
				$("#vlrUnitIn").val(getPipeByIndex(response, 2));
				$("#especialidadeIn").val(getPipeByIndex(response, 3));
				$('#qtdeIn').focus();
			}
		);
	});
	
		
	subtractValor= function() {
		aux= 0;	
		var teste= document.getElementById("checkrowTabela" + aux);
		while(document.getElementById("checkrowTabela" + aux) != undefined) {
			if (document.getElementById("checkrowTabela" + aux).checked) {
				vlrTotal-= parseFloat($('#noneD' + aux).val());
			}
			aux++;
		}
		$('#total').empty();
		$('#total').append(": " + formatDecimal(vlrTotal));
	}
	
	getValor= function() {
		var total = 0;
		$("#dataBank > *").each(function (ind, domEle) {
 			total += parseFloat($("#rowTotal" + ind).text());
 		});
 		$("#total").text(formatCurrency(total));
	}
	
	/**
	 * erroSalve
	 * @param {type}  
	 */
	erroSalve = function () {
		showErrorMessage ({
			width: 400,
			mensagem: "Não é permitida a edição de orçamentos.",
			title: "Erro"
		});
	}
	
	$("input").keypress(function (e) {
		if (e.which == 13) {
			addRowServico();
		}
	});
	
	$("#tabelaIn").change(function() {
		isChange = true;	
	});
	
	mountTabelaPost = function () {
		var htm = "";
 		$("#dataBank > *").each(function (ind, domEle) {
 			htm += "<input type=\"hidden\" id=\"rowCodigo" + ind + "\" name=\"rowCodigo" +
 				ind + "\" value=\"" + $("#rowCodigo" + ind).text() + "\">";
 			
 			htm += "<input type=\"hidden\" id=\"rowQtde" + ind + "\" name=\"rowQtde" +
 				ind + "\" value=\"" + $("#rowQtde" + ind).text() + "\">";
 		}); 		
 		$("#dataBank").remove();
 		$("#localTabela").append(htm);
 	}
	
	/**
	 * enviarOrcamento
	 * @param {type}  
	 */
	enviarOrcamento = function() {		
		if (flag && isChange) {
			if (($("#tabelaIn").val() != "") && ($("#haveParcela").val() == "n")) {
				showOption({
					mensagem: "Atenção! A tabela de referencia foi alterada. Deseja manter a tabela selecionada?",
					title: "Salvar",
					width: 350,
					buttons: {
						"Não": function () {
							location.href = "orcamento_empresa.jsp?id=" + $("#userIdIn").val();
						},
						"Sim": function() {
							$("#tabelaIn").removeAttr("disabled", "disabled");
							mountTabelaPost();
							document.forms["formPost"].submit();
						}
					}
				});
			} else if($("#haveParcela").val() == "s") {
				showErrorMessage ({
					width: 400,
					mensagem: "Não é possível mudar a tabela de um orçamento já parcelado.",
					title: "Erro"
				});
			} else {
				showErrorMessage ({
					width: 400,
					mensagem: "Escolha uma tabela de referencia.",
					title: "Erro"
				});
			}
		} else if(flag) {
			location.href = "orcamento_empresa.jsp?id=" + $("#userIdIn").val();
		} else {
			$("#tabelaIn").removeAttr("disabled", "disabled");
			mountTabelaPost();
		 	document.forms["formPost"].submit();
		}
	}
	
	noAccess = function() {
		showErrorMessage ({
			width: 400,
			mensagem: "Não é permitido ao administrador cadastrar orçamentos!",
			title: "Acesso Negado"
		});
	}
	
	/**
	 * printOrcamento
	 * @param {type}  
	 */
	printOrcamento = function() {
	 	var top = (screen.height - 600)/2;
		var left= (screen.width - 800)/2;
		window.close();
		window.open("../GeradorRelatorio?rel=169&parametros=228@" + $("#orcIdIn").val(), 'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
	}
	
	$(this).ajaxStart(function(){
		//showLoader('Carregando...', 'body', false);
	});
	
	$(this).ajaxStop(function(){
		//hideLoader();
	});
});