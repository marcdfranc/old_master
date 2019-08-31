var index;
$(document).ready(function() {
	index = $("#startIndex").val();
		
	changeDesc = function (obj) {
		document.getElementById("insumoDesc").selectedIndex = obj.selectedIndex;
	}
	
	changeCod = function (obj) {
		document.getElementById("insumoId").selectedIndex = obj.selectedIndex;
	}
	
	addRowInsumo = function () {
		$("#gridLines").remove();
		var last = $("#dataBank").html();
		var htm = "";
		if (!isUpdatable()) {
			htm = getRowMonted(index);		
		}		
		if (htm != "") {
			htm = last + htm;
			$("#dataBank").empty();
			$("#dataBank").append(htm);
			index++;
		}
		document.getElementById("insumoDesc").selectedIndex = 0;
		document.getElementById("insumoId").selectedIndex = 0;			
		$("#qtdeIn").val("1");
		$("#custoIn").val("0.00");			
		getValor();
		$("#insumoId").focus();			
	}
	
	removeRowInsumo = function () {
		var htm = "";
		var indexNew = 0;
		$("#dataBank >*").each(function(ind, domEle) {
			if (document.getElementById("checkrowTabela" + ind).checked) {
				index--;
				indexNew++;
			} else {
				htm+= getRowForDel(ind - indexNew , ind);
			}
		});		
		$("#dataBank").empty();
		$("#dataBank").append(htm);
		getValor();
		$("#insumoId").focus();
	}
	
	$("input").keypress(function (e) {
		if (e.which == 13) {
			addRowInsumo();
		}
	});
	
	getRowMonted = function (value) {
		var seletorDesc = document.getElementById("insumoDesc");
		var seletorCod = document.getElementById("insumoId");
		var valor = 0;
		var descricao = "";
		if ((seletorDesc.value == "") || (seletorCod.value == "") 
				|| ($("#custoIn").val() == "") || ($("#qtdeIn").val() == "")) {
			return "";
		}
		
		valor = parseFloat($('#qtdeIn').val()) * parseFloat($('#custoIn').val());
		descricao = seletorDesc.options[seletorDesc.selectedIndex].text; 
		
		var htm = "<tr class=\"gridRow\" id=\"line" + value + "\" name=\"line" + value +
			"\" ><td><label id=\"rowCodigo" + value + "\" name=\"rowCodigo" + 
			value + "\" >" + seletorCod.value + "</label></td>";
		
		htm += "<td><label id=\"rowDescricao" + value + "\" name=\"rowSetor" + value + "\" >" +
			descricao + "</label></td>";	
		
		htm += "<td><label id=\"rowTipo" + value + "\" name=\"rowTipo" + value + "\" >";
		if (seletorDesc.value == 's') {
			htm += "Serviço</label></td>";
		} else {
			htm += "Produto</label></td>";
		}
		
		htm += "<td><label id=\"rowVlrUnit" + value + "\" name=\"rowVlrUnit" + value + 
			"\" >" + $("#custoIn").val() + "</label></td>";
			
		htm += "<td><label id=\"rowQtde" + value + "\" name=\"rowQtde" + value + "\" >" + 
			$("#qtdeIn").val() + "</label></td>";			
			
		htm += "<td><label id=\"rowValor" + value + "\" name=\"rowValor" + value + "\" >" + 
		 	formatCurrency(valor + "")  +	"</label></td>";					
			
		htm += "<td style=\"width: 10px;\"><input id=\"checkrowTabela" + value + 
			"\" name=\"checkrowTabela" + value + "\" type=\"checkbox\"/></td></tr>";
		
		return htm;
	} 
	
	getRowForDel = function (value, indexRow) {
		var htm = "<tr class=\"gridRow\" id=\"line" + value + "\" name=\"line" + value +
			"\" ><td><label id=\"rowCodigo" + value + "\" name=\"rowCodigo" + 
			value + "\" >" + $("#rowCodigo" + indexRow).text() + "</label></td>";
			
		htm += "<td><label id=\"rowDescricao" + value + "\" name=\"rowDescricao" + value + "\" >" +
			$("#rowDescricao" + indexRow).text() + "</label></td>";
			
		htm += "<td><label id=\"rowTipo" + value + "\" name=\"rowTipo" + value + "\" >" +
			$("#rowTipo" + indexRow).text() + "</label></td>";
			
		htm += "<td><label id=\"rowVlrUnit" + value + "\" name=\"rowVlrUnit" + value + 
			"\" >" + $("#rowVlrUnit" + indexRow).text() + "</label></td>";
			
		htm += "<td><label id=\"rowQtde" + value + "\" name=\"rowQtde" + value + "\" >" + 
			$("#rowQtde" + indexRow).text() + "</label></td>";
		
		htm += "<td><label id=\"rowValor" + value + "\" name=\"rowValor" + value + "\" >" + 
			$("#rowValor" + indexRow).text() + "</label></td>";
			
		htm += "<td style=\"width: 10px;\"><input id=\"checkrowTabela" + value + 
			"\" name=\"checkrowTabela" + value + "\" type=\"checkbox\"/></td></tr>";
		
		return htm;
	}
	
	removeRowForEdit = function () {
		var htm = "";
		var indexNew = 0;
		var delAppend = "";
		$("#gridLines").remove();
		$("#dataBank >*").each(function(ind, domEle) {
			if (document.getElementById("checkrowTabela" + ind).checked) {
				index--;
				delAppend = "<input id=\"delConfig" + indexNew + "\" name=\"delConfig" +
					indexNew + "\" type=\"hidden\" value=\"" + 
					$("#rowCodigo" + ind).text() + "\"/>";
					
				$("#deletedsContent").append(delAppend);
				indexNew++;
			} else {
				htm+= getRowForDel(ind - indexNew , ind);
			}
		});
		$("#dataBank").empty();
		$("#dataBank").append(htm);
		$("#insumoId").focus();
	}
	
	/**
	 * saveConfig
	 * @param {type}  
	 */
	savePedido = function() {
		var pipe = "";
		var juridica = $("#origem").val();
	 	$('#dataBank >*').each(function (ind, domEle) {
	 		if (ind == 0) {
	 			pipe += $("#rowCodigo" + ind).text() + "@" + $("#rowQtde" + ind).text() + 
	 				"@" +  $("#rowVlrUnit" + ind).text();
	 		} else {
	 			pipe += "|" + $("#rowCodigo" + ind).text() + "@" + $("#rowQtde" + ind).text() +
	 				"@" +  $("#rowVlrUnit" + ind).text();
	 		}
	 	});	 	
	 	
	 	$.get("../CadastroPedido",{
	 		codigo: $('#codigoIn').val(),
	 		isJuridica: ($("#origem").val() == 'forn')? 't' : 'f',
	 		idFornecedor: $("#idFornecedorIn").val(),
	 		cadastro: $("#cadastroIn").val(),
	 		unidade: $("#unidadeId").val(), 
			pipe: pipe,
			from : "1"},
			function (response) {				
				location.href = '../error_page.jsp?errorMsg=' + response +  
				'&lk=application/compra.jsp?idFornecedor=0&origem=' + $("#origem").val();
			}
		);
	}
	
	saveEdition = function () {
		var delPipe = "";
		var pipe = "";
		$('#deletedsContent >*').each(function (ind, domEle) {
			if (ind == 0) {
				delPipe+= domEle.value;
			} else {
				delPipe+= "|" + domEle.value;
			}
		});
		
		$('#dataBank >*').each(function (ind, domEle) {
	 		if (ind == 0) {
	 			pipe += $("#rowCodigo" + ind).text() + "@" + $("#rowQtde" + ind).text();
	 		} else {
	 			pipe += "|" + $("#rowCodigo" + ind).text() + "@" + $("#rowQtde" + ind).text();
	 		}
	 	});
		
		$.get("../CadastroPedido",{
	 		codigo: $("#codigoIn").val(),
	 		delPipe: delPipe,
			pipe: pipe,
			from : "5"},
			function (response) {				
				location.href = '../error_page.jsp?errorMsg=' + response +  
				'&lk=application/compra.jsp?idFornecedor=0&origem=' + $("#origem").val();
			}
		);
	}
	
	
	getValor= function() {
		var total = 0;
		$("#dataBank > *").each(function (ind, domEle) {
 			total += parseFloat($("#rowValor" + ind).text());
 		});
 		$("#total").text(formatCurrency(total));
	}
	
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
	
	isUpdatable = function () {
		var result = false;
		$("#dataBank > *").each(function (ind, domEle) {			
			if ($("#rowCodigo" + ind).text() == $("#insumoId").val()) {
				var vlrQtde = parseInt($("#rowQtde" + ind).text()) +
					parseInt($("#qtdeIn").val());
				var vlrUnit = parseFloat($("#custoIn").val());
				$("#rowQtde" + ind).text(vlrQtde);
				$("#rowVlrUnit" + ind).text($('#custoIn').val());
				$("#rowValor" + ind).text(formatCurrency(vlrQtde * vlrUnit));				
				result = true;
			}
 		});
 		return result;
	}
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
	});
	
	generate = function() {
		$('#geracaoWindow').dialog({
	 		width: 300,
	 		modal: true,
	 		zindex: 0,
	 		show: 'fade',
			hide: 'clip',
	 		buttons: {
	 			"Cancelar": function () {
	 				$(this).dialog('close');
	 			},
	 			"Gerar" : function () {	 				
	 				$.get("../CadastroPedido",{
				 		compra: $('#codigoIn').val(),
				 		qtde: $("#qtdeParcela").val(),
				 		vlrTotal: $("#total").text(),
				 		inicio: $("#iniParcela").val(),
				 		documento: $("#docParcela").val(),
				 		emissao: $("#emitDoc").val(),
				 		entrada : $("#entrada").val(),
						from : "2"},
						function (response) {				
							location.href = '../error_page.jsp?errorMsg=' + response +  
							'&lk=application/compra.jsp?idFornecedor=0&origem=' + $("#origem").val();
						}
					);
					$(this).dialog('close');
 				}
	 		},
	 		close: function (param) {
				$(this).dialog('destroy');
			}
		});
	}
	
	addInsumo = function () {
		$('#novoInsumoWindow').dialog({
	 		width: 300,
	 		modal: true,
	 		zindex: 0,
	 		show: 'fade',
			hide: 'clip',
	 		buttons: {
	 			"Cancelar": function () {
	 				$(this).dialog('close');
	 			},
	 			"Salvar" : function () {	 				
	 				$.get("../CadastroInsumo",{						
						codigo: '',
						ramo: $('#ramoId').val(),
						descricao: $('#descInsumo').val(),
						tipo: $("#tipoInsumo").val(),
						statusIn: $("#statusInsumo").val(),
						unidade: $("#unidadeId").val(),
						from : "3"},
						function (response) {
							var pipe;
							var combo = "<option value=\"\">Selecione</option>";
							var comboCodigo =  "<option value=\"\">Selecione</option>";
							if (getPipeByIndex(response, 0) == "0") {
								pipe = unmountPipe(response);
								for(var i = 0; i < pipe.length; i++) {
									if (i == 0) {
										combo+= "<option value=\"" + getPipeByIndex(pipe[i], 2) + "\">" + 
											getPipeByIndex(pipe[i], 3) + "</option>";
											
										comboCodigo += "<option value=\"" + getPipeByIndex(pipe[i], 1) + "\">" + 
											getPipeByIndex(pipe[i], 1) + "</option>";
									} else {
										combo += "<option value=\"" + getPipeByIndex(pipe[i], 1) + "\">" + 
											getPipeByIndex(pipe[i], 2)+ "</option>";
											
										comboCodigo += "<option value=\"" + getPipeByIndex(pipe[i], 0) + "\">" + 
											getPipeByIndex(pipe[i], 0) + "</option>";
									}
								}
								$('#insumoId').empty();
								$('#insumoId').append(comboCodigo);
								$('#insumoDesc').empty();
								$('#insumoDesc').append(combo);
								
							}
						}
					);
					$(this).dialog('close');
 				}
	 		},
	 		close: function () {
				$(this).dialog('destroy');
			}
		});
	}	
});