var isEdition = false;
$(document).ready(function() {
	load = function () {
		var htm = "";
		var indexNew = 0;
		$("#dataBank >*").each(function(ind, domEle) {
			if (ind % 2 != 0) {				
				htm+= getRowForDel(indexNew , indexNew);
				indexNew++;
			}		
		});
		$("#dataBank").empty();
		$("#dataBank").append(htm);
	}
	
	
	ckFunction = function() {
		var id = '';
		var valorTotal = 0;
		$("#dataBank >*").each(function(ind, domEle) {
			if (document.getElementById("checkrowTabela" + ind).checked) {
				id = "nominal" + ind;				
				valorTotal+= parseFloat($("#" + id).text());
			} 
		});
		valorTotal = formatCurrency(valorTotal);		
		$("#totalSoma").empty();
		$("#totalSoma").append(valorTotal);
	}
	
	getRowForDel = function (value, indexRow) {
		var htm = "<tr class=\"gridRow\" id=\"line" + value + "\" name=\"line" + value +
			"\" ><td><label id=\"parcela" + value + "\" name=\"parcela" + 
			value + "\" >" + $("#parcela" + indexRow).text() + "</label></td>";
			
		htm += "<td><label id=\"vencimento" + value + "\" name=\"vencimento" + value + "\" >" +
			$("#vencimento" + indexRow).text() + "</label></td>";
			
		htm += "<td><label id=\"quitacao" + value + "\" name=\"quitacao" + value + 
			"\" >" + $("#quitacao" + indexRow).text() + "</label></td>";
			
		htm += "<td><label id=\"recebimento" + value + "\" name=\"recebimento" + value + "\" >" + 
			$("#recebimento" + indexRow).text() + "</label></td>";
		
		htm += "<td><label id=\"nominal" + value + "\" name=\"nominal" + value + "\" >" + 
			$("#nominal" + indexRow).text() + "</label></td>";
			
		htm += "<td><label id=\"vlrPago" + value + "\" name=\"vlrPago" + value + "\" >" + 
			$("#vlrPago" + indexRow).text() + "</label></td>";
			
		htm += "<td><img name=\"parcStatus" + value + "\" id=\"parcStatus" + value + 
					"\" src=\"" + $('#parcStatus' + indexRow).attr("src") + "\"/></td>";
			
		htm += "<td style=\"width: 10px;\"><input id=\"checkrowTabela" + value + 
			"\" name=\"checkrowTabela" + value + "\" type=\"checkbox\" " +
			" onclick=\"ckFunction()\" /></td></tr>";
		
		return htm;
	}
	
	selectAll = function() {
		aux = -1;		
		$("#dataBank >*").each(function(ind, domEle) {
			if (!document.getElementById("checkrowTabela" + ind).checked) {				
				document.getElementById("checkrowTabela" + ind).checked = true;				
			} else {
				document.getElementById("checkrowTabela" + ind).checked = false;
			}
		});
		ckFunction();
	}
	
	mountPipeLine = function() {
		aux = -1;
		pipe = "";
		isFirst = true;
		while($('#checkrowTabela' + (++aux)).val() != undefined) {
			if (document.getElementById("checkrowTabela" + aux).checked) {
				if (isFirst) {
					isFirst = false;
					pipe+= $('#parcela' + (aux)).text();				
				} else {
					pipe+= "@" + $('#parcela' + (aux)).text();
				}
			}
		}
		return pipe;
	}
	
	pagConcilia = function() {
		var aux = mountPipeLine();
		if (aux == "") {
			showErrorMessage({
				mensagem: "Selecione as parcelas que deseja pagar!",
				title: "Entrada inválida"
			});	
		} else {
			$('#vlrTotal').val($('#totalSoma').text());		
			$('#aPagar').val($('#totalSoma').text());
			$("#conciliaWindow").dialog({
		 		modal: true,
		 		width: 450,
		 		minWidth: 450,
		 		show: 'fade',
				hide: 'clip',
		 		buttons: {
		 			"Cancelar": function() {
		 				$(this).dialog('close');
					},
		 			"Pagar" : function () {
		 				$.get("../CadastroParcelaCompra", {
							from: "0",
							pipe: aux,
							formaPagamento : $("#tpPagamento").val(),
							emissao: $('#dtEmit').val(),
							vencimentoConcilia: $('#dtVenc').val(),
							numeroConcilio: $('#numConcilio').val(),							
							vlrPago: $("#aPagar").val()}, 
							function(response){
								location.href = '../error_page.jsp?errorMsg=' + response + 
									'&lk=application/compra.jsp?origem=' + $('#origem').val();
							}
						);						
						$(this).dialog('close');
		 			}		 			
		 		},
		 		close: function() {
		 			$(this).dialog('close');
		 		}
		 	});
		}
	}
	
	estorne = function () {
		var aux = mountPipeLine();
		if (aux == "") {
			showErrorMessage({
				mensagem: "Selecione as parcelas que deseja estornar!",
				title: "Entrada inválida"
			});	
		} else {
			showOption({
				mensagem: "Deseja realmente estorna este registro?",
				title: "Confirmação de Estorno",
				icone: 'q',
				show: 'fade',
				hide: 'clip',
				buttons: {
					"Não": function () {
						$(this).dialog('close');
					},
					"Sim": function() {
						$.get("../CadastroParcelaCompra",{							
							pipe: aux,
							from: "1"},
							function (response) {								
								location.href = '../error_page.jsp?errorMsg=' + response + 
									'&lk=application/compra.jsp?origem=' + $('#origem').val();
							}
						);
					}
				}
			});
		}
	}
	
	cancelParc = function () {
		var aux = mountPipeLine();
		if (aux == "") {
			showErrorMessage({
				mensagem: "Selecione as parcelas que deseja Cancelar!",
				title: "Entrada inválida"
			});	
		} else {
			showOption({
				mensagem: "Deseja realmente cancelar este registro?",
				title: "Confirmação de Cancelamento",
				icone: 'q',
				show: 'fade',
				hide: 'clip',
				buttons: {
					"Não": function () {
						$(this).dialog('close');
					},
					"Sim": function() {
						$.get("../CadastroParcelaCompra",{							
							pipe: aux,
							from: "2"},
							function (response) {								
								location.href = '../error_page.jsp?errorMsg=' + response + 
									'&lk=application/compra.jsp?origem=' + $('#origem').val();
							}
						);
					}
				}
			});
		}
	}
	
	makeObs = function () {
		if (!isEdition) {
			$('#obsIn').removeAttr("readonly");
			$('#saveObs').removeAttr("disabled");			
			$('#saveObs').removeClass("grayButtonStyle");			
			$('#saveObs').addClass("greenButtonStyle");
			isEdition = true;
		} else {
			$('#obsIn').attr("readonly", "readonly");
			$('#saveObs').attr("disabled", "disabled");			
			$('#saveObs').removeClass("greenButtonStyle");			
			$('#saveObs').addClass("grayButtonStyle");
			isEdition = false 
		}

	}
	
	sendObs = function() {		
		$.get("../CadastroParcelaCompra",{							
			obs: $('#obsIn').val(),
			compra: $('#pedidoIn').val(),
			from: "3"},
			function (response) {								
				if (response == '1') {
					showErrorMessage({
						mensagem: "Selecione as parcelas que deseja pagar!",
						title: "Entrada inválida"
					});	
				}
			}
		);
		makeObs();
	}
	
	adjustPagamento = function(combo) {
		if (getPart($('#tpPagamento').val(), 2) == 's') {
			$('#numConcilio').removeAttr("readonly");
			$('#dtVenc').removeAttr("readonly");
		} else {
			$('#numConcilio').attr("readonly","readonly");
			$('#dtVenc').attr("readonly","readonly");
		}
	}	
	
	noAccess = function () {
		showWarning({
			mensagem: "Para realizar esta operação é necessário abrir o caixa.",
			title: "Acesso Negado"
		});
	}	
});