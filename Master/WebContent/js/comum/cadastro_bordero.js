var tabela;
var isEdition= false;
/*var vlrTotal= 0;
var conciliaWinidow;
var conciliaPipe;
var pagamentoLabel;
var pagamentoData;
var pagamento;
var vlrAtualLabel;
var vlrAtual;
var tituloLabel;
var titulo;
var emissaoLabel;
var emissao;
var vencimentoLabel;
var vencimento;
var btPagConcilio;
*/
var lancamentos;
var conciliados;
var idConcilio;
var idPagina;

function loadPage(isEd){
	var aux;		
	var vlrSoma = 0.0;
	lancamentos = new Array();
	conciliados = new Array();		
	idConcilio = 0;
	
	tabela= new dtGrid("edLanc", "deletedsLanc", "conciliaLanc", "concLanc", "concilioFat", true);
	tabela.setLocalHidden("localTabela");
	tabela.setLocalAppend("tableLancamento");
	tabela.setIdHidden("rowTabela");
	tabela.addCol("CTR", "12", "rowCtr");
	tabela.addCol("Cliente", "48", "rowCliente");
	tabela.addCol("Orç.", "10", "rowOrcamento");
	tabela.addCol("Guia", "10", "rowGuia");
	tabela.addCol("Emissao", "10", "rowEmissao"); 
	tabela.addCol("Valor", "10", "rowValor");		
	tabela.setSequence(false);
	tabela.mountHeader(isEd);
	aux= 0;				
	if (isEd) {
		while ($('#edCtr' + parseInt(aux)).val() != undefined) {
			tabela.addIds($("#ItBorderoId" + parseInt(aux)).val());
			tabela.addValue($('#edCtr' + parseInt(aux)).val());
			tabela.addValue($('#edNome' + parseInt(aux)).val());
			tabela.addValue($('#edOrcamento' + parseInt(aux)).val());
			tabela.addValue($('#edGuia' + parseInt(aux)).val());
			tabela.addValue($('#edEmissao' + aux).val());
			tabela.addValue(formatCurrency($('#edValor' + parseInt(aux)).val()));
			vlrSoma += parseFloat($('#edValor' + aux).val());
			$('#total').empty();
			$('#total').append(": " + formatCurrency(vlrSoma));
			tabela.appendTable();
			aux++;
		}
	}
	$('#guiaIn').focus();
}

function generate() {
	var pipe = "";
	if (lancamentos.length == 0) {
		showErrorMessage ({
			mensagem: "Não existem guias inseridas para geração de repasse!",
			title: "Entrada inválida"
		});			
	} else {
		for(var i = 0; i < lancamentos.length; i++) {
			if (i == 0) {
				pipe = lancamentos[i];
			} else {
				pipe+= "@" + lancamentos[i];
			}
		}
		$.get("../BorderoAdapter",{
			from: "1",
			idPessoa: $('#pessoaId').val(), 
			cadastro: $('#cadastroIn').val(),
			tpPagamentoIn: $('#tpPagamentoIn').val(),					
			lancamentos: pipe},
			function (response) {
				idPagina = getPart(response, 2);
				if (getPart(response, 1) == "1") {
					showErrorMessage ({
						mensagem: getPart(response, 2),
						title: "Erro"
					});
				} else {
				 	$("#okWindow").dialog({
				 		modal: true,
				 		width: 300,
				 		minWidth: 300,
				 		show: 'fade',
	 					hide: 'clip',
				 		buttons: {
				 			"Ok": function() {
				 				location.href = "cadastro_bordero.jsp?state=1&id=" + 
				 					idPagina;
							}
				 		},
				 		close: function() {
				 			$(this).dialog('destroy');					 			
				 		}
				 	});
				}
			}
		);			
	}
}

function pagar() {
	var aux = "";
	var count = -1;
	for(var i = 0; i < conciliados.length; i++) {
		if (i == 0) {
			aux+= conciliados[i][0] + "@" + conciliados[i][1] + "@" + 
				conciliados[i][2] + "@" + conciliados[i][3] + "@" + 
				conciliados[i][4];
		} else {
			aux+= "|" + conciliados[i][0] + "@" + conciliados[i][1] + "@" + 
				conciliados[i][2] + "@" +  conciliados[i][3] +	"@" + 
				conciliados[i][4];
		}
	}	
		
 	$.get("../BorderoAdapter",{
		from: "2",								
		bordero: $("#borderoIdIn").val(),
		concilio: aux},
		function (response) {
			if (response == "1") {
				showErrorMessage ({
					mensagem: "ocorreu um erro durante o pagamento da fatura de repasse.",
					title: "Erro"
				});
			} else {
			 	$("#okPagWindow").dialog({
			 		modal: true,
			 		width: 300,
			 		minWidth: 300,
			 		show: 'fade',
	 				hide: 'clip',
			 		buttons: {
			 			"Ok": function() {
			 				$(this).dialog('close');
			 				location.reload(true);
						}
			 		},
			 		close: function() {
			 			$(this).dialog('destroy');
			 		}
			 	});
			}
		}
	);
}	

function pdfGenerate() {
 	var top = (screen.height - 600)/2;
	var left= (screen.width - 800)/2;
	window.close();
	window.open("../GeradorRelatorio?rel=51&parametros=72@" + $("#borderoIdIn").val(), 'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
}


/*function conciliaFatura() {

 	vlrSoma = 0;
 	var count = -1;
 	var isChecked = false;
 	while (document.getElementById("checkrowTabela" + (++count)) != undefined) {			
		if (document.getElementById("checkrowTabela" + count).checked) {				
			vlrSoma += parseFloat(tabela.getRow(count)[5]);
			if (! isChecked) {
				isChecked = true;
			}
		}
	}
 	if (isChecked) {
	 	vlrTotal.setEnable(false);
	 	vlrTotal.setValue(formatCurrency(vlrSoma));
	 	emissao.setEnable(false);
	 	titulo.setValue("");
	 	vencimento.setValue("");
	 	conciliaWinidow.show();
 	} else {
 		showErrorMessage("Selecione as guias que deseja conciliar!", "Erro", 150, 450, false);
 	}
 	location.reload(true);
}


function execConciliacao() {
 	tabela.removeData();	
	var arrayAux = new Array();
 	var count = -1;
 	conciliaWinidow.hide();
 	while ($("#conciliaLanc" + (++count)).val() != undefined) {
 		//alert($("#conciliaLanc" + count).val());
		if (conciliados[count] == undefined) {
			idConcilio++;
			arrayAux.push([idConcilio, $("#conciliaLanc" + count).val(), pagamento.getValue(), titulo.getValue(), vencimento.getValue()]);
		}
	}
	for(var i = 0; i < arrayAux.length; i++) {
		conciliados.push([arrayAux[i][0], arrayAux[i][1], arrayAux[i][2], arrayAux[i][3], arrayAux[i][4]]);
	}
	location.reload(true);
}|*/	

function mostra() {
	alert(conciliados);
 	//alert(tabela.getRow(0)[4]);
}


function noAccess() {
	showWarning ({
		mensagem: "Para realizar esta operação é necessário abrir o caixa.",
		title: "Acesso Negado"
	});
}

function showUploadWd() {
	$("#uploadBordero").dialog({
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
	if ($('#docDigital').val() == "s") {
		var url = "upload/borderos/bordero_" + $('#borderoIdIn').val() + ".pdf";
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

$(document).ready(function() {
	$("#uploadify").uploadify({
		'uploader' : '../flash/uploadify.swf',
		'script' : '../BorderoUpload',
		'cancelImg' : '../image/cancel.png',
		'buttonImg' : '../image/upload.gif',								
		'folder' : 'upload/borderos',
		'queueID' : 'fileQueue',
		'fileDesc': 'Arquivos Adobe PDF(*.pdf)',
		'fileExt': '*.pdf',
		'width' : 320,
		'height': 200,
		'scriptData' : {
			'nome_arquivo': 'bordero_' + $('#borderoIdIn').val(),
			'idBordero': $('#borderoIdIn').val()
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
	
	$("input").keypress(function (e) {
		var lancamento;	
		var valorTotal = 0.0;
		var aux = 0.0;
		var isRepeat = false;	
		if (e.which == 13) {
			lancamento = this.value;
			for(var i = 0; i < lancamentos.length; i++) {
				if (lancamento == lancamentos[i]) {
					isRepeat = true;
					break;
				}
			}								
			if ($('#guiaIn').val() != "") {
				if (!isEdition) {
					if (isRepeat) {
						showErrorMessage ({
							mensagem: "Este Lançamento já faz parte desta seleção!",
							title: "Erro"
						});
					} else if($('#tpPagamentoIn').val() == "") {
						showErrorMessage ({
							mensagem: "Selecione a forma de pagamento para inserir as guias",
							title: "Erro"
						});
					} else {
						$.get("../BorderoAdapter",{
							from: "0", 
							lancamento: lancamento,
							idPessoa: $('#pessoaId').val()},
							function(response){
								if (response == "1") {
									showErrorMessage ({
										mensagem: "Guia não encontrada!",
										title: "Erro"
									});
								} else {
									for(var i = 0; i < 6; i++) {
										tabela.addValue(getPipeByIndex(response, i));
									}
									tabela.appendTable();
									valorTotal = parseFloat($('#total').text().substr(2, $('#total').text().length));
									valorTotal+= parseFloat(getPipeByIndex(response, 5));
								}							
								$('#total').empty();
								$('#total').append(": " + formatCurrency(valorTotal));				
								$('#guiaIn').val("");
								$('#guiaIn').focus();
								lancamentos.push(getPipeByIndex(response, 3))
							}
						);						
					}
				}
			} else {
				showErrorMessage ({
					mensagem: "Todos os campos desta seção precisam ser preenchidos para inserção!",
					title: "Entrada inválida"
				});
			}
		}
	});
});