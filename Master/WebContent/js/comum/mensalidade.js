var isComplete= false;
var flag= false;
var box;


$(document).ready(function() {
	$('#lancJuros').button();
	$('#cobBoleto').button();
	$("#impCupon" ).button();
	$("#impNf" ).button();
	
	$('#btClose').mouseover(function () {
		$(this).addClass("ui-state-hover");
		$(this).css({"cursor": "pointer"})
	});
	
	$('#btClose').mouseout(function () {
		$(this).removeClass("ui-state-hover");
	});
		
	$("#vigencia").change(function() {		
		$.get("../MensalidadeAdapter",{		
			from: "7",
			userId: $("#codUser").val(),
			vigencia: this.value},
			function (response) {
				if (response != "0") {
					$('#dataGrid').empty();
					$('#dataGrid').append(response);
				}
			}
		);
	});
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
	});
});

function appendMenu(value){
	
}

function pagConcilia() {
	var aux= mountPipeLine();		
	if ($("#tpPagamento").val() == "") {
		showErrorMessage ({
			width: 400,
			mensagem: "Não existem conciliações cadastradas!",
			title: "Erro de Conciliação"
		});
	} else if (aux == "") {
		showErrorMessage ({
			mensagem: "Selecione as mensalidades que deseja fazer o recebimento!",
			title: "Entrada inválida"
		});			
	} else {
		$('#vlrTotal').val($('#totalSoma').text());
		$('#aPagar').val($('#totalSoma').text());			
		$("#money").val("0.00");
		atualizaTotal();		 	
	 	$("#conciliaWindow").dialog({
	 		modal: true,
	 		width: 580,
	 		minWidth: 520,
	 		show: 'fade',
	 		hide: 'clip',
	 		buttons: {
	 			"Cancelar": function() {
	 				$(this).dialog('close');		 				
	 				document.getElementById("lancJuros").checked = true;
	 				document.getElementById("cobBoleto").checked = false;
	 				document.getElementById("impCupon").checked = true;
					showLoader();
				},
	 			"Pagar" : function () {
	 				var isEmissao = document.getElementById("impCupon").checked;
					$.get("../MensalidadeAdapter",{
						pipe: aux,
						from: "1",
						userId: $("#codUser").val(),
						vigencia: $("#vigAtual").val(),
						cobBoleto : (document.getElementById("cobBoleto").checked)? "s" : "n",
						dinheiro : $("#money").val(),
						formaPag : $("#tpPagamento").val(),
						emissao : $("#dtEmit").val(),
						numeroConcilio : $("#numConcilio").val(),
						vencimentoConcilia: $("#dtVenc").val(),
						totalPagar: $("#aPagar").val(),
						troco: $("#troco").val(),
						juros: (document.getElementById("lancJuros").checked)? "s" : "n"},
						function (response) {
							if (response != "0") {									
								if (isEmissao) {
									emitCupom(false);
								}
								$('#dataGrid').empty();
								$('#dataGrid').append(response);									
							} else {
								location.href= '../error_page.jsp?errorMsg=Ocorreu um erro durante o pagamento das mensalidades!&lk=' +
									'application/mensalidade.jsp?id=' + $('#codUser').val();
							}
						}
					);						
					$(this).dialog('close');
	 			}		 			
	 		},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
	 	});
	}
}

function estorne() {
	aux= mountPipeLine();
	if (aux == "") {
		showErrorMessage ({
			mensagem: "Selecione as mensalidades que deseja estornar!",
			title: "Entrada inválida"
		});			
	} else {
		showOption({
			mensagem: "Atenção! Esta Operação efetua alterações em caixas e contas corrente.\nDeseja realmente estornar?",
			title: "Estorno de Mensalidades",
			width: 350,
			show: 'fade',
			hide: 'clip',
			buttons: {
				"Não": function () {
					$(this).dialog('close');
				},
				"Sim": function() {
					$.get("../MensalidadeAdapter",{							
						pipe: aux,
						from: "0",
						vigencia: $("#vigAtual").val(),
						userId: $('#codUser').val()},
						function (response) {
							if (response != "0") {
								location.href= '../error_page.jsp?errorMsg=Estorno realizado com sucesso!&lk=' +
									'application/mensalidade.jsp?id=' + $('#codUser').val();
							} else {
								location.href= '../error_page.jsp?errorMsg=Ocorreu um erro durante o estorno das mensalidades!&lk=' +
									'application/mensalidade.jsp?id=' + $('#codUser').val();
							}
						}
					);
				}
			}
		});				
	}
}

function negociar() {
	var aux= mountPipeLine();
	if (aux == "") {
		showErrorMessage ({
			mensagem: "Selecione as mensalidades que deseja renegociar!",
			title: "Entrada inválida"
		});
	} else {
		$("#negociaWindow").dialog({
	 		modal: true,
	 		width: 450,
	 		minWidth: 450,
	 		show: 'fade',
	 		hide: 'clip',
	 		buttons: {
	 			"Cancelar" : function () {
	 				$(this).dialog('close');
	 			},
	 			"Negociar": function () {
	 				$.get("../MensalidadeAdapter",{ 
						pipe: aux,
						vencimento: $('#dtNegocio').val(), 
						from: "3",
						vigencia: $("#vigAtual").val(), 
						userId: $('#codUser').val(),
						sim: $('#jurosNegocio:checked').val(),
						desconto: $('#desconto').val()},
						function (response) {
							if (response != "0") {				
								location.href= '../error_page.jsp?errorMsg=Parcela negociada com sucesso!&lk=' +
									'application/mensalidade.jsp?id=' + $('#codUser').val();
							} else {
								location.href= '../error_page.jsp?errorMsg=Ocorreu um erro durante a negociação das mensalidades!&lk=' +
									'application/mensalidade.jsp?id=' + $('#codUser').val();
							}
						}
					);
	 			}
	 		},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
	 	});
	}
}
	
function cancela() {
	var tamanho = $('.ck-grid').length;
	var isOk = true;
	$('.ck-grid').each(function(i, domEle) {
		if (isOk && $(this).data("status") == 'q' && $(this).is(":checked")) {
			isOk = false;
		}		
		if (i == (tamanho - 1)) {
			if (isOk) {
				aux= mountPipeLine();		
				if (aux == "") {
					showErrorMessage ({
						mensagem: "Selecione as mensalidades que deseja cancelar!",
						title: "Entrada inválida"
					});
				} else {
					showOption({
						mensagem: "Deseja realmente cancelar este registro?",
						title: "Confirmação de Cancelamento",
						show: 'fade',
						hide: 'clip',
						buttons: {
							"Não": function () {
								$(this).dialog('close');
							},
							"Sim": function() {
								$.get("../MensalidadeAdapter",{							
									pipe: aux,
									from: "5",
									userId: $('#codUser').val()},
									function (response) {
										if (response != "0") {
											$('#dataGrid').empty();
											$('#dataGrid').append(response);
										} else {
											location.href = '../error_page.jsp?errorMsg=Ocorreu um erro durante o cancelamento das mensalidades!' + 
											'&lk=application/mensalidade.jsp?id=' + $('#codUser').val();
										}
									}
								);
							}
						}
					});
				}
			} else {
				showErrorMessage ({
					mensagem: "Não é possível cancelar lançamentos já recebidos!",
					title: "Entrada inválida"
				});
			}
		}
	});
	
}

function addMensalidade(){		
	$("#addMensalWindow").dialog({
 		modal: true,
 		width: 450,
 		minWidth: 450,
 		show: 'fade',
	 	hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close');	 				
 			},
 			"ok" : function() {
				$.get("../MensalidadeAdapter", {
					valor: $('#valMensalAdd').val(),
					vencimento: $('#inicioAdd').val(),
					taxa: $('#mora').val(),
					qtde: $('#qtdeAdd').val(),
					unidadeId: $('#unidadeId').val(),
					userId: $('#codUser').val(),
					vigencia: $("#vigAtual").val(),
					tipoLancamento: $("#tpLancamento").val(),
					from: "4"},
					function(response) {
						if (response != "0") {
							location.href = '../error_page.jsp?errorMsg=Mensalidades adicionadas com sucesso!' + 
								'&lk=application/mensalidade.jsp?id=' + $('#codUser').val();				
						} else {
							location.href = '../error_page.jsp?errorMsg=Ocorreu um erro durante a geração das mensalidades!' + 
								'&lk=application/mensalidade.jsp?id=' + $('#codUser').val();
						}
					}
				);
 			}
 		},
 		close: function() {
 			$(this).dialog('destroy');
 		}
	 });
}
	
function renovar() {
	$("#renovaWindow").dialog({
 		modal: true,
 		width: 450,
 		minWidth: 450,
 		show: 'fade',
	 	hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close');
 			},
 			"Renovar" : function() {
				$.get("../Renovacao", {
					from: "3",
					userId: $('#codUser').val(),
					renovacao: $('#dtRenov').val(),
					vigencia: $('#vigRenovacao').val(),
					vencimento: $('#vencRenovacao').val(),
					qtde: $('#qtdeRenovacao').val(),
					vigAtual: $("#vigAtual").val(),
					valor: $("#valRenov").val(),
					vlrRenovacao: $("#vlrRenovacao").val()}, 
					function(response){
						if (response != "1") {
							location.href = '../error_page.jsp?errorMsg=Ocorreu um erro durante a renovação!' + 
								'&lk=application/mensalidade.jsp?id=' + $('#codUser').val();
						} else {
							location.href = '../error_page.jsp?errorMsg=renovação realizada com sucesso!' + 
								'&lk=application/mensalidade.jsp?id=' + $('#codUser').val();
						}
					}
				);
 			}
 		},
 		close: function() {
 			$(this).dialog('destroy'); 			
 		}
	 });
}	

function emitCupom(isPop) {
 	var aux = mountPipeLine();
 	if (aux == "") {
 		showErrorMessage ({
			mensagem: "Selecione as mensalidades que deseja fazer a impresão!",
			title: "Entrada inválida"
		});
 	} else {
 		$.get("../MensalidadeAdapter",{		
			from: "8",
			pipe: aux},
			function (response) {
				if (response == "0") {
					showErrorMessage ({
						mensagem: "Ocorreu um erro durante a impressão de cupons!",
						title: "Erro"
					});
				} else {
					switch (response) {
						case "r":
							showErrorMessage ({
								mensagem: "Não é possível imprimir cupons antes do recebimento!",
								title: "Erro"
							});
							break;
						
						case "u":
							showErrorMessage ({
								mensagem: "Não é possível imprimir cupons de outro usuário!",
								title: "Erro"
							});
							break;
							
						case "a":
							showErrorMessage ({
								mensagem: "Não é possível imprimir cupons de datas anteriores!",
								title: "Erro"
							});
							break;	
							
						default:
							if (isPop) {
								$("#cuponWindow").dialog({
							 		modal: true,
							 		width: 332,
							 		minWidth: 332,
							 		show: 'fade',
	 								hide: 'clip',
							 		buttons: {
							 			"Cancelar" : function () {
							 				$(this).dialog('close');								 				
							 			},
							 			"Imprimir": function () {
							 				var top = (screen.height - 200)/2;
											var left= (screen.width - 600)/2;
											window.open('rel_matricial/cupom_mensalidade.jsp?pp=' + 
												aux + '&vpg=' + $('#moneyCupon').val(), 'nova',
												 'width= 600, height= 200, top= ' + top + 
												 ', left= ' + left);
											$(this).dialog('close');
							 			}
							 		},
							 		close: function() {
							 			$(this).dialog('destroy');								 			
							 		}
								 });									
							} else {
								var top = (screen.height - 200)/2;
								var left= (screen.width - 600)/2;
								window.open('rel_matricial/cupom_mensalidade.jsp?pp=' + 
									aux + '&vpg=' + $('#money').val(), 'nova',
									 'width= 600, height= 200, top= ' + top + 
									 ', left= ' + left);
							}

							break;
					}				
				}
			}
		);
 	}
}

function emitBoleto() {
	var aux = mountPipeLine();		
	if (aux == "") {
		showErrorMessage ({
			mensagem: "Selecione as mensalidades para as quais deseja emitir boletos!",
			title: "Entrada inválida"
		});
	} else {
		var top = (screen.height - 200)/2;
		var left= (screen.width - 600)/2;			
	 	$("#boletoWindow").dialog({
	 		modal: true,
	 		width: 580,
	 		resizable: false,
	 		minWidth: 520,
	 		show: 'fade',
	 		hide: 'clip',
	 		buttons: {		 			
	 			"Boleto A4-agp" : function () {
	 				if ($('#dtVencimento').val() == "") {
	 					showErrorMessage ({
							width: 400,
							mensagem: "Não é possível gerar agrupamentos sem data de vencimento!",
							title: "Erro de Conciliação"
						});
	 				} else {
		 				window.open("../CadastroBoleto?pipe=" + aux + "&valor=" +
		 					$('#totalSoma').text() + "&vencimento=" + 
		 					$('#dtVencimento').val() + "&conta=" +
		 					$('#conta').val() + "&pessoa=" +
		 					$('#codUser').val() + "&getBoleto= " +
		 					$('#getBoleto').val() + "&maisJuros=" +
		 					$('#getJurosMais').val() + "&tipo=0&from=1" , 'nova', 
		 					'width= 800, height= 600, top=0' + top + ', ' +
		 					'left= ' + left);
	 				}						
					$(this).dialog('close');
	 			},
	 			"Boleto-agp" : function () {
	 				if ($('#dtVencimento').val() == "") {
	 					showErrorMessage ({
							width: 400,
							mensagem: "Não é possível gerar agrupamentos sem data de vencimento!",
							title: "Erro de Conciliação"
						});
	 				} else {
		 				window.open("../CadastroBoleto?pipe=" + aux + "&valor=" + 
		 					$('#totalSoma').text() + "&vencimento=" + 
		 					$('#dtVencimento').val() + "&conta=" +
		 					$('#conta').val() + "&pessoa=" +
		 					$('#codUser').val() + "&getBoleto= " +
		 					$('#getBoleto').val() + "&maisJuros=" +
		 					$('#getJurosMais').val() + "&tipo=1&from=1" , 'nova', 
		 					'width= 800, height= 600, top= ' + top + ', ' +
		 					'left= ' + left);
	 				}						
					$(this).dialog('close');
	 			},
	 			"Fatura-agp" : function () {
	 				if ($('#dtVencimento').val() == "") {
	 					showErrorMessage ({
							width: 400,
							mensagem: "Não é possível gerar agrupamentos sem data de vencimento!",
							title: "Erro de Conciliação"
						});
	 				} else {
		 				window.open("../CadastroBoleto?pipe=" + aux + "&valor=" + 
		 					$('#totalSoma').text() + "&vencimento=" + 
		 					$('#dtVencimento').val() + "&conta=" +
		 					$('#conta').val() + "&pessoa=" +
		 					$('#codUser').val() + "&getBoleto= " +
		 					$('#getBoleto').val() + "&maisJuros=" +
		 					$('#getJurosMais').val() + "&tipo=2&from=1" , 'nova', 
		 					'width= 800, height= 600, top= ' + top + ', ' +
		 					'left= ' + left);
	 				}						
					$(this).dialog('close');
	 			},
	 			"Carne" : function () {
	 				window.open("../CadastroBoleto?pipe=" + aux + "&valor=" + 
	 					$('#totalSoma').text() + "&vencimento=" + 
	 					$('#dtVencimento').val() + "&conta=" +
	 					$('#conta').val() + "&pessoa=" +
	 					$('#codUser').val() + "&getBoleto= " +
	 					$('#getBoleto').val() + "&maisJuros=" +
	 					$('#getJurosMais').val() + "&tipo=3&from=1" , 'nova', 
	 					'width= 800, height= 600, top= ' + top + ', ' +
	 					'left= ' + left);
					$(this).dialog('close');
	 			},
	 			"Carne A4" : function () {
	 				window.open("../CadastroBoleto?pipe=" + aux + "&valor=" + 
	 					$('#totalSoma').text() + "&vencimento=" + 
	 					$('#dtVencimento').val() + "&conta=" +
	 					$('#conta').val() + "&pessoa=" +
	 					$('#codUser').val() + "&getBoleto= " +
	 					$('#getBoleto').val() + "&maisJuros=" +
	 					$('#getJurosMais').val() + "&tipo=6&from=1" , 'nova', 
	 					'width= 800, height= 600, top= ' + top + ', ' +
	 					'left= ' + left);
					$(this).dialog('close');
	 			},	 			
				"Boleto" : function () {
	 				window.open("../CadastroBoleto?pipe=" + aux + "&valor=" + 
	 					$('#totalSoma').text() + "&vencimento=" + 
	 					$('#dtVencimento').val() + "&conta=" +
	 					$('#conta').val() + "&pessoa=" +
	 					$('#codUser').val() + "&getBoleto= " +
	 					$('#getBoleto').val() + "&maisJuros=" +
	 					$('#getJurosMais').val() + "&tipo=4&from=1" , 'nova', 
	 					'width= 800, height= 600, top= ' + top + ', ' +
	 					'left= ' + left);				
					$(this).dialog('close');
	 			},
	 			"Fatura" : function () {
	 				window.open("../CadastroBoleto?pipe=" + aux + "&valor=" + 
	 					$('#totalSoma').text() + "&vencimento=" + 
	 					$('#dtVencimento').val() + "&conta=" +
	 					$('#conta').val() + "&pessoa=" +
	 					$('#codUser').val() + "&getBoleto= " +
	 					$('#getBoleto').val() + "&maisJuros=" +
	 					$('#getJurosMais').val() + "&tipo=5&from=1" , 'nova', 
	 					'width= 800, height= 600, top= ' + top + ', ' +
	 					'left= ' + left);				
					$(this).dialog('close');
	 			},
	 			"Cancelar": function() {
	 				$(this).dialog('close');
	 				document.getElementById("lancJuros").checked = true;
 					document.getElementById("cobBoleto").checked = false;
 					document.getElementById("impCupon").checked = true;
				}
	 		},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
	 	});
	}
}

function adjustPagamento(combo) {
	if (getPart($('#tpPagamento').val(), 2) == 's') {			
		$('#blocoShow').removeClass("cpEscondeWithHeight");			
	} else {
		$('#blocoShow').addClass("cpEscondeWithHeight");
	}
}

/**
 * getTroco
 * @param {type}  
 */
function getTroco() {
	var aPagar = parseFloat($('#aPagar').val());
	var dinheiro = parseFloat($('#money').val());
	var troco = dinheiro - aPagar;
	if (troco >= 0) {
	 	$('#troco').val(formatCurrency(troco));			
	} else {
		$('#troco').val("0.00");
	}
}

function atualizaTotal() {
	var aux;
	var i = -1;
	var countBoleto = 0;
	var totalSimples = 0;
	var lastDate;
	var auxDate;
	while ($("#ck" + (++i)).val() != undefined) {
		if (document.getElementById("ck" + i).checked) {
			totalSimples+= parseFloat($("#valSimplesGd" + i).text());
			lastDate = $("#vencMensGd" + i).text();
			countBoleto++;
		}
	}
	if (document.getElementById("lancJuros").checked) {			
		aux = parseFloat(calculaAtraso($('#vlrTotal').val(), 
			 $('#dtVenc').val(), 1, $('#dtEmit').val()));
		if (document.getElementById("cobBoleto").checked) {
			aux += 2 * countBoleto;
		} 
		$('#aPagar').val(trunc(aux, 2));
	} else {
		if (document.getElementById("cobBoleto").checked) {
			totalSimples += 2 * countBoleto;
		} 
		$('#aPagar').val(formatCurrency(totalSimples));
	}
	getTroco();
}

function selectAll() {
	aux = -1;
	while ($('#ck' + (++aux)).val() != undefined) {
		if (!document.getElementById("ck" + aux).checked) {
			document.getElementById("ck" + aux).checked = true;				
		} else {
			document.getElementById("ck" + aux).checked = false;
		}
	}
	ckFunction(0);
}

function makeObs() {
	$('#obsw').removeAttr("readOnly", "readOnly");
	$('#obsWindow').dialog({
		modal: true,
		width: 800,
 		minWidth: 790,
 		maxWidth: 800,
 		maxHeight: 483,
	 	show: 'fade',
	 	hide: 'clip',
	 	buttons: {
	 		"Cancelar" : function () {
 				$(this).dialog('close');
 			},
 			"Salvar": function() {
 				oldText = $('#obsIn').val();
 				$('#obsIn').val($('#obsw').val());
 				$.get("../MensalidadeAdapter",{
 					obs: $('#obsw').val(),
					usuario: $('#codUser').val(),							
					from: "2"},
					function (response) {
						if (response == "0") {
							showErrorMessage ({
								mensagem: "Ocorreu um erro durante o processo de salvamento da observação!",
								title: "Edição de Observação"
							});
							$('#obsIn').val(oldText);
							$('#obsw').val(oldText);
						} else {
							showMessage ({
								mensagem: "Observação salva com sucesso!",
								title: "Edição de Observação"
							});
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
	
function excluir() {
	aux= mountPipeLine();
	if (aux == "") {
		showErrorMessage ({
			mensagem: "Selecione as mensalidades que deseja excluir!",
			title: "Entrada inválida"
		});
	} else {
		showOption({
			mensagem: "Deseja realmente excluir as mensalidades selecionadas?",
			title: "Exclusão de Mensalidades",
			show: 'fade',
	 		hide: 'clip',
			buttons: {
				"Não": function () {
					$(this).dialog('close');
				},
				"Sim": function() {
					$.get("../MensalidadeAdapter",{							
						pipe: aux,
						from: "6",
						vigencia: $("#vigAtual").val(),
						userId: $('#codUser').val()},
						function (response) {
							if (response != "0") {
								location.href = '../error_page.jsp?errorMsg=Mensalidades excluídas com sucesso!' + 
									'&lk=application/mensalidade.jsp?id=' + $('#codUser').val();
							} else {
								location.href = '../error_page.jsp?errorMsg=Ocorreu um erro durante a exclusão das mensalidades!' + 
									'&lk=application/mensalidade.jsp?id=' + $('#codUser').val();
							}
						}
					);
				}
			}
		});	
	}
}

function gerarPdf(tipo) {
	

	/*$.get("../CadastroBoleto",{
		valor: $('#totalSoma').text()
	},
	function (response) {
	 	alert(response);
	});*/
}

function mountPipeLine() {
	aux = -1;
	pipe = "";
	isFirst = true;
	lastId = 0;
	while($('#ck' + (++aux)).val() != undefined) {
		if (document.getElementById("ck" + aux).checked) {				
			if (isFirst) {
				isFirst = false;
				pipe+= $('#ck' + (aux)).val();
				lastId = aux;
			} else {
				flag = true; 
				pipe+= "@" + $('#ck' + (aux)).val();
				lastId = aux;
			}
		}
	}
	return pipe;
}

function ckFunction(value) {		
	var i = 0;
	var valorTotal = 0;
	var dataAux;		
	while($("#ck" + i).val() != undefined){			
		dataAux = new Date(getYear($('#vencMensGd' + i).text()), 
			getMonth($('#vencMensGd' + i).text()) - 1, 
			getDay($('#vencMensGd' + i).text()));
		if (document.getElementById("ck" + i).checked) {								
			valorTotal+= parseFloat($("#valRecebGd" + i).text());				
		}			
		i++;
	}
	valorTotal = valorTotal + "";
	valorTotal = formatCurrency(valorTotal);		
	$("#totalSoma").empty();
	$("#totalSoma").append(valorTotal);
}

/**
 * noAccess
 * @param {type}  
 */
function noAccess() {
	showErrorMessage ({
		mensagem: "Para realizar esta operação é necessário abrir o caixa.",
		title: "Acesso Negado"
	});
}