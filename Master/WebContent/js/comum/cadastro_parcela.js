var isComplete= false;
var flag= false;

$(document).ready(function() {
	$('#lancJuros').button();
	$('#cobBoleto').button();
	$("#impCupon" ).button();
	$("#impNf" ).button();
	
	$("#uploadify").uploadify({
		'uploader' : '../flash/uploadify.swf',
		'script' : '../OrcamentoUpload',
		'cancelImg' : '../image/cancel.png',
		'buttonImg' : '../image/upload.gif',								
		'folder' : 'upload/ctrs',
		'queueID' : 'fileQueue',
		'fileDesc': 'Arquivos Adobe PDF(*.pdf)',
		'fileExt': '*.pdf',
		'width' : 320,
		'height': 200,
		'scriptData' : {
			'nome_arquivo': 'orcamento_' + $('#codOrcamento').val(),
			'idOrcamento': $('#codOrcamento').val()
		},		
		'queueSizeLimit': 1,
		'sizeLimit': 250000,
		'onComplete' : function (event, queueID, fileObj, response, data) {
			location.href= response + "?id=-1";
			return true;
		},
		'auto' : true,
		'multi' : false
	});
		
	$('#entradaIn').blur(function() {
		var qtde = parseInt($("#parcelaIn").val());
		var entrada = parseFloat($("#entradaIn").val());
		var taxa = parseFloat($("#jurosIn").val());
		var vlrOrcamento = parseFloat($("#valorIn").val());
		vlrOrcamento-= entrada;
		var vlrParcela =  0.0;
		if (entrada > 0) {
			vlrParcela = (vlrOrcamento * Math.pow((1 + taxa/100), (qtde -1)));
			vlrParcela = vlrParcela / (qtde -1);
		} else {
			vlrParcela = (vlrOrcamento * Math.pow((1 + taxa/100), qtde));
			vlrParcela = vlrParcela / qtde;
		}
		$("#vlrParcelaIn").val(formatCurrency(vlrParcela));
	});
	
	
});

function showUploadWd() {
	$("#uploadOrcamento").dialog({
 		modal: true,
 		width: 508,
 		minWidth: 400,
 		show: 'fade',
		hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close');
 			}
 		},
 		close: function() {
 			$(this).dialog('destroy');
 		}
 	});
}

function loadDocDigital() {
	if ($('#haveDoc').val() == "s") {
		var url = "upload/orcamentos/orcamento_" + $('#codOrcamento').val() + ".pdf";
		var top = (screen.height - 600)/2;
		var left= (screen.width - 800)/2;
		window.open(url ,'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
	} else {
		showErrorMessage ({
			width: 300,
			mensagem: "Imagem não encontrada ou arquivo inexistente!",
			title: "Erro"
		});
	}
}

function appendMenu(value){
		
}
	
function estorne(value) {
	var aux = mountPipeLine();
	if (aux == "") {
		showErrorMessage ({
			width: 400,
			mensagem: "Selecione as parcelas que deseja estornar!",
			title: "Entrada inválida"
		});
	} else {
		showOption({
			mensagem: "Atenção! Esta operação efetua alterações em caixas, " +
						"profissionais e contas corrente, deseja realmente estornar?",
			title: "Estorno de Parcelas",
			width: 350,
			show: 'fade',
	 		hide: 'clip',
			buttons: {
				"Não": function () {
					$(this).dialog('close');
				},
				"Sim": function() {
					$.get("../ContaAdapter",{ 
						pipe: aux,
						orcamento: $('#codOrcamento').val(),
						now: $('#now').val(), 
						from: "0"},
						function (response) {
							var menssagen = ""
							if (response != "0") {
								mensagem = "Parcelas estornadas com sucesso!"					
							} else {
								mensagem = "Ocorreu um erro durante o estorno da parcela!";
							}
							location.href= '../error_page.jsp?errorMsg=' + mensagem + '&lk=' +
									'application/cadastro_parcela.jsp?id=' + 
									$('#codOrcamento').val();
						}
					);
				}
			}
		});
	}
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
			mensagem: "Selecione as parcelas que deseja efetuar o pagamento!",
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
	 		mimWidth: 520,		 		
	 		resizable: false,
	 		show: 'fade',
	 		hide: 'clip',
	 		buttons: {
	 			"Cancelar": function() {
	 				document.getElementById("lancJuros").checked = true;
	 				document.getElementById("cobBoleto").checked = false;
	 				document.getElementById("impCupon").checked = true;
	 				$(this).dialog( "close" );
	 				
	 				//$(this).addClass('cpEscondeWithHeight');
				},
	 			"Pagar" : function () {	 				
	 				var isEmissao = document.getElementById("impCupon").checked;
					$.get("../ContaAdapter",{
						pipe: aux,
						juros: (document.getElementById("lancJuros").checked)? "s" : "n",
						cobBoleto : (document.getElementById("cobBoleto").checked)? "s" : "n",
						formaPag: $("#tpPagamento").val(),
						emissao: $("#dtEmit").val(),
						numeroConcilio: $("#numConcilio").val(),
						totalPagar: $("#aPagar").val(),
						vencimentoConcilia: $("#dtVenc").val(),
						orcamento: $('#codOrcamento').val(),
						qtde: $("#parcelaIn").val(),
						troco: $('#troco').val(),
						from: "1"},							
						function (response) {
							if (response != "0") {									
								if (isEmissao) {
									emitCupom(false);
								}
								$('#dataBank').empty();
								$('#dataBank').append(response);									
							} else {
								location.href= '../error_page.jsp?errorMsg=Ocorreu um erro durante o pagamento das mensalidades!&lk=' +
									'application/cadastro_parcela.jsp?id=' + 
									$('#codOrcamento').val();
							}
						}
					);
					$(this).dialog( "close" );
	 			}		 			
	 		},
	 		close: function() {
	 			document.getElementById("lancJuros").checked = true;
 				document.getElementById("cobBoleto").checked = false;
 				document.getElementById("impCupon").checked = true;		 			
	 			$(this).dialog('destroy');
	 			
	 		}
	 	});
	}
}
	
function emitCupom(isPop) {
 	var aux = mountPipeLine();
 	if (aux == "") {
 		showErrorMessage ({
			mensagem: "Selecione as parcela que deseja fazer a impresão!",
			title: "Entrada inválida"
		});	 		
 	} else {
 		$.get("../CadastroParcela",{
			pipe: aux,		
			from: "6"},
			function (response) {
				switch (response) {
					case '0':
						showErrorMessage ({
							mensagem: "Ocorreu um erro durante a impressão de cupons!",
							title: "Erro"
						});
						break;

					case '1':
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
										window.open('rel_matricial/cupom_parcela.jsp?pp=' + 
											aux + '&vpg=' + $('#moneyCupon').val(), 'nova',
											'width= 600, height= 200, top= ' + top + ',' +
											' left= ' + left);
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
							window.open('rel_matricial/cupom_parcela.jsp?pp=' + aux + 
								'&vpg=' + $('#money').val(), 'nova', 
								'width= 600, height= 200, top= ' + top + ', left= ' + left);
						}
						break;
					
					case '2':
						showErrorMessage ({
							mensagem: "Não é possível imprimir cupons de outro usuário!",
							title: "Erro"
						});
						break;
						
					case '3':
						showErrorMessage ({
							mensagem: "Não é possível imprimir cupons de datas anteriores.",
							title: "Erro"
						});
						break;
						
					case '4':
						showErrorMessage ({
							mensagem: "Não é possível imprimir cupons antes do recebimento.",
							title: "Erro"
						});
						break;
				}
			}
		);
 	}
}

function emitBoleto() {
	var aux = mountPipeLine();		
	if (aux == "") {
		showErrorMessage ({
			mensagem: "Selecione as guias para as quais deseja emitir boletos!",
			title: "Entrada inválida"
		});
	} else {
		var top = (screen.height - 200)/2;
		var left= (screen.width - 600)/2;
	 	$("#boletoWindow").dialog({
	 		modal: true,
	 		width: 595,
	 		minWidth: 595,
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
		 					$('#getBoleto').val() +  "&tipo=0&from=1" , 'nova', 
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
		 					$('#codUser').val() +  "&getBoleto= " +
		 					$('#getBoleto').val() + "&tipo=1&from=1" , 'nova', 
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
		 					$('#codUser').val() +  "&getBoleto= " +
		 					$('#getBoleto').val() + "&tipo=2&from=1" , 'nova', 
		 					'width= 800, height= 600, top= ' + top + ', ' +
		 					'left= ' + left);
	 				}
					$(this).dialog('close');
	 			},
	 			"Boleto A4" : function () {
	 				window.open("../CadastroBoleto?pipe=" + aux + "&valor=" + 
	 					$('#totalSoma').text() + "&vencimento=" + 
	 					$('#dtVencimento').val() + "&conta=" +
	 					$('#conta').val() + "&pessoa=" +
	 					$('#codUser').val() +  "&getBoleto= " +
	 					$('#getBoleto').val() + "&tipo=3&from=1" , 'nova', 
	 					'width= 800, height= 600, top= ' + top + ', ' +
	 					'left= ' + left);
					$(this).dialog('close');
	 			},		 			
				"Boleto" : function () {
	 				window.open("../CadastroBoleto?pipe=" + aux + "&valor=" + 
	 					$('#totalSoma').text() + "&vencimento=" + 
	 					$('#dtVencimento').val() + "&conta=" +
	 					$('#conta').val() + "&pessoa=" +
	 					$('#codUser').val() +  "&getBoleto= " +
	 					$('#getBoleto').val() + "&tipo=4&from=1" , 'nova', 
	 					'width= 800, height= 600, top= ' + top + ', ' +
	 					'left= ' + left);
					$(this).dialog('close');
	 			},
	 			"Fatura" : function () {
	 				window.open("../CadastroBoleto?pipe=" + aux + "&valor=" + 
	 					$('#totalSoma').text() + "&vencimento=" + 
	 					$('#dtVencimento').val() + "&conta=" +
	 					$('#conta').val() + "&pessoa=" +
	 					$('#codUser').val() +  "&getBoleto= " +
	 					$('#getBoleto').val() + "&tipo=5&from=1" , 'nova', 
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
	 			document.getElementById("lancJuros").checked = true;
 				document.getElementById("cobBoleto").checked = false;
 				document.getElementById("impCupon").checked = true;
	 			$(this).dialog('destroy');
	 		}
	 	});
	}
}


function cancelParc() {
	var tamanho = $('.ck-grid').length;
	var isOk = true;
	$('.ck-grid').each(function(i, domEle) {
		if (isOk && $(this).data("status") == 'q' && $(this).is(":checked")) {
			isOk = false;
		}		
		if (i == (tamanho - 1)) {
			if (isOk) {
				var aux = mountPipeLine();
				if (aux == "") {
					showErrorMessage ({
						mensagem: "Selecione as parcelas que deseja efetuar o cancelamento!",
						title: "Entrada inválida"
					});
				} else {
					showOption({
						mensagem: "Atenção! As parcelas selecionadas podem conter pagamentos efetuados a profissionais. " +
						"Deseja relamente cancelar as parcelas selecionadas?",
						title: "Confirmação de Cancelamento",
						show: 'fade',
						hide: 'clip',
						buttons: {
							"Não": function () {
								$(this).dialog('close');
							},
							"Sim": function() {
								$.get("../ContaAdapter",{
									pipe: aux,
									orcamento: $('#codOrcamento').val(),
									from: "3"},
									function (response) {
										if (response != "0") {
											$('#dataGrid').empty();
											$('#dataGrid').append(response);
										} else {
											location.href = '../error_page.jsp?errorMsg=Ocorreu um erro durante o cancelamento das parcelas!' + 
											'&lk=application/cadastro_parcela.jsp?id=' + 
											$('#codOrcamento').val();
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

function restitui() {
	var aux = mountPipeLine();
	if (aux == "") {
		showErrorMessage ({
			mensagem: "Selecione as parcelas que deseja restituir!",
			title: "Entrada inválida"
		});
	} else {
		showOption({
			mensagem: "Você está prestes a fazer uma restituição. " +
						"Deseja efetuar o pagamento neste momento?",
			title: "Restituição de Parcelas",
			show: 'fade',
	 		hide: 'clip',
			buttons: {
				"Cancelar": function () {
					$(this).dialog('close');
				},
				"Não": function() {
					$.get("../ContaAdapter",{
						pipe: aux,
						orcamento: $('#codOrcamento').val(),
						pagar: 'n',
						from: "4"},
						function (response) {
							if (response != "0") {
								$('#dataGrid').empty();
								$('#dataGrid').append(response);
							} else {
								location.href = '../error_page.jsp?errorMsg=Ocorreu um erro durante a restituição das parcelas!' + 
									'&lk=application/cadastro_parcela.jsp?id=' + 
									$('#codOrcamento').val();
							}
						}
					);
				},
				"Sim": function() {
					$.get("../ContaAdapter",{
						pipe: aux,
						orcamento: $('#codOrcamento').val(),
						pagar: 's',
						from: "4"},
						function (response) {
							if (response != "0") {
								$('#dataGrid').empty();
								$('#dataGrid').append(response);
							} else {
								location.href = '../error_page.jsp?errorMsg=Ocorreu um erro durante a restituição das parcelas!' + 
									'&lk=application/cadastro_parcela.jsp?id=' + 
									$('#codOrcamento').val();
							}
						}
					);
				}
			}
		});
	}
}

function excluir() {
	showOption({
		mensagem: "Você está prestes a excluir permanentemente todas as parecelas do orçamento. "+
			"Clique em \"Sim\" se deseja continuar com o processo. ",
		title: "Confirmação de Exclusão",
		show: 'fade',
	 	hide: 'clip',
		buttons: {
			"Não": function () {
				$(this).dialog('close');
			},
			"Sim": function() {
				$.get("../ContaAdapter",{							
					orcamento: $('#codOrcamento').val(),							
					from: "5"},
					function (response) {
						if (getPart(response, 1) == "1") {
							showErrorMessage ({
								mensagem: getPart(response, 2),
								title: "Erro de Exclusão"
							});
						} else {
							location.href = '../error_page.jsp?errorMsg=' + 
								getPart(response, 2) + 
								'&lk=application/cadastro_parcela.jsp?id=' + 
								$('#codOrcamento').val();
						}
					}
				);
				$(this).dialog('close');					
			}
		}
	});		
}

function reparcela() {
	var aux = mountPipeLine();
	var pipe = unmountPipe(toRealPipe(aux));
	var lancamento = "";
	if (aux == "") {
		showErrorMessage ({
			width: 400,
			mensagem: "Selecione a parcela que deseja reparcelar!",
			title: "Entrada inválida"
		});
	} else if(pipe.length > 1) {
		showErrorMessage ({
			width: 400,
			mensagem: "Só é permitido o reparcelamento de 1(uma) parcela!",
			title: "Entrada inválida"
		});
	} else {
		lancamento = pipe[0];
		$("#reparcelaWindow").dialog({
	 		modal: true,
	 		width: 450,
	 		minWidth: 450,
	 		show: 'fade',
	 		hide: 'clip',
	 		buttons: {
	 			"Cancelar" : function () {
	 				$(this).dialog('close');
	 			},
	 			"Reparcelar": function () {
	 				$.get("../CadastroParcela",{
						lancamento: lancamento,
						valor: $('#valorAdicional').val(),
						vencimento: $('#vencimentoParcela').val(),
						from: "1"},
						function (response) {
							if (getPart(response, 0) == "1") {
								showErrorMessage ({
									width: 400,
									mensagem: getPart(response, 1),
									title: "Erro"
								});
							} else {
								$("#reloadWindow").dialog({
									modal: true,
							 		width: 450,
							 		minWidth: 450,
							 		show: 'fade',
	 								hide: 'clip',
							 		buttons: {
							 			"Ok": function () {
								 			document.location.reload();
								 			$(this).dialog('close');
										}
						 			},
						 			close: function() {
								 			$(this).dialog('destroy');
								 		}
									}
								);
								$(this).dialog('close');
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

function checaGeracao() {
	var msg = "";		
	var isOk= true;
	if (isComplete) {
		msg = "Erro, as parcelas já foram geradas para este orçamento!";			
		isOk = false;			
	} else if (($('#vencimento').val() == "") && ($('#parcelaIn').val() == "")) {
		msg= "Favor Preencher os dados do parcelamento!"				
		isOk= false;
	} else if ($("#aprovacao").val() == "n") {
		msg= "Não é possível gerar as parcelas para um orçamento fora da tabela vigente!"			
		isOk= false;
	}
	if (!isOk) {
		showErrorMessage({
			mensagem: msg,
			title: "Erro"
		});
	} 
	return isOk;
}

function generate() {
	if (checaGeracao()) {			
		$.get("../CadastroParcela",{
			vencimento: $('#vencimento').val(),
			parcela: $('#parcelaIn').val(),
			valor: $('#valorIn').val(),
			operacional: $('#operacionalIn').val(),
			orcamento: $('#codOrcamento').val(),
			taxa: $('#jurosIn').val(),
			tipoPagamento: $('#tipoPagamento').val(),
			cadastro: $('#cadastroIn').val(),
			unidadeId: $('#unidadeId').val(),
			obs: $('#obsIn').val(),
			atraso: $('#jurosIn').val(),
			entrada: $('#entradaIn').val(),
			from: "0"},
			function (response) {
				if (response != "0") {						
					isComplete = true;
					location.href = '../error_page.jsp?errorMsg=Geração de parcelas realizada com sucesso!' + 
								'&lk=application/cadastro_parcela.jsp?id=' + $("#codOrcamento").val();
				} else {
					isComplete = true;
					location.href = '../error_page.jsp?errorMsg=Ocorreu um erro durante a geração das parcelas!' + 
								'&lk=application/cadastro_parcela.jsp?id=' + $("#codOrcamento").val();
				}
			}
		);
	}				
}

function impressaoGuia() {
	var aux = mountPipeLine();
	var top = 0;
	var left = 0;		
	if (aux == "") {
		showErrorMessage({
			mensagem: "Selecione as parcelas que deseja imprimir!",
			title: "Entrada inválida"
		});
	} else {
		$.get("../CadastroParcela",{
			pipe: aux,		
			from: "6"},
			function (response) {
				switch (response) {
					case '0':
						showErrorMessage({
							mensagem: "Ocorreu um erro durante o processo de impressão!",
							title: "Erro"
						});
						break;

					case '1':
						top = (screen.height - 600)/2;
						left = (screen.width - 800)/2;
						if ($('#isProfissional').val() == "t") {
							window.open("../GeradorRelatorio?rel=61&parametros=92@" + pipeToVirgula(aux), 
								'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
						} else {
							window.open("../GeradorRelatorio?rel=173&parametros=243@" + pipeToVirgula(aux), 
								'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
						}					
						break;
					
					case '2':
						showErrorMessage({
							mensagem: "Não é possível imprimir guias de outro usuário!",
							title: "Erro"
						});
						break;
						
					case '3':
						showErrorMessage({
							mensagem: "Não é possível imprimir guias de datas anteriores.",
							title: "Erro"
						});
						break;
						
					case "4":
						showErrorMessage({
							mensagem: "Não é possível imprimir guias antes do recebimento.",
							title: "Erro"
						});
						break;
				}
			}
		);
	}
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
}

function mountPipeLine() {
	aux = -1;
	pipe = "";
	isFirst = true;
	while($('#ck' + (++aux)).val() != undefined) {
		if (document.getElementById("ck" + aux).checked) {
			if (isFirst) {
				isFirst = false;
				pipe+= $('#ck' + (aux)).val();				
			} else {
				pipe+= "@" + $('#ck' + (aux)).val();
			}
		}
	}
	return pipe;
}

function makeObs() {
	$('#obsWindow').removeClass("cpEscondeWithHeight");
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
 				$.get("../CadastroParcela",{
 					obs: $('#obsw').val(),
 					orcamento: $('#codOrcamento').val(),
 					from: "3"},
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

function ckFunction(value) {
	var id = 'gridValue' + value.id.replace('ck', "");
	var i = 0;
	var valorTotal = 0;
	while($("#ck" + i).val() != undefined){
		if (document.getElementById("ck" + i).checked) {
			id = "gridValue" + document.getElementById("ck" + i).id.replace("ck", "");				
			valorTotal+= parseFloat($("#" + id).val());				
		}
		i++;
	}
	valorTotal = formatCurrency(valorTotal);		
	$("#totalSoma").empty();
	$("#totalSoma").append(valorTotal);
}	

function noAccess() {
	showErrorMessage ({
		mensagem: "Para realizar esta operação é necessário abrir o caixa.",
		title: "Acesso Negado"
	});
}

function atualizaTotal(textoPrompt) {
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

function adjustPagamento(comboItem) {
	if (getPart($('#tpPagamento').val(), 2) == 's') {			
		$('#blocoShow').removeClass("cpEscondeWithHeight");						
	} else {
		$('#blocoShow').addClass("cpEscondeWithHeight");
	}
	getTroco();
}

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


function generatePdf() {
 	var top = (screen.height - 600)/2;
	var left= (screen.width - 800)/2;
	if ($('#isProfissional').val() == "t") {
		window.open("../GeradorRelatorio?rel=93&parametros=131@" + $("#codOrcamento").val(), 'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
	} else {
		window.open("../GeradorRelatorio?rel=170&parametros=230@" + $("#codOrcamento").val(), 'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
	}

}

function generateProfPdf() {
 	var top = (screen.height - 600)/2;
	var left= (screen.width - 800)/2;		
	if ($('#isProfissional').val() == "t") {
		window.open("../GeradorRelatorio?rel=94&parametros=141@" + $("#codOrcamento").val(), 'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
	} else {
		window.open("../GeradorRelatorio?rel=171&parametros=233@" + $("#codOrcamento").val(), 'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
	}
}

