function pdfGenerate() {
	var top = (screen.height - 600)/2;
	var left= (screen.width - 800)/2;
	window.open("../GeradorRelatorio?rel=130&parametros=461@" + 
		$("#faturaId").val() + "|14@" + 
		$('#vencimentoIn').val(), 
		'nova', 'width= 800, height= 600, top= ' + top + 
		', left= ' + left);
}
function pagueFaura() {	$("#pagWindow").dialog({
				modal: true,		width: 300,		minWidth: 300,		show: 'fade',		hide: 'clip',		buttons: {			"Cancelar": function() {				$(this).dialog('close');				$("#lancJuros [value='n']").attr("checked", "checked");			},			"Pagar" : function () {				$.get("../CadastroFaturaEmpresa",{					faturaId: $('#faturaId').val(),					juros: $('#lancJuros').val(),					automatico: $('#tpPagamento').val(),					dtPagamento: $('#dtPagamento').val() ,					from: "1" },					function (response) {						if (response == "0") {							location.href= "fatura_empresa.jsp?id=-1";						} else {							location.href= "../error_page.jsp?errorMsg=ocorreu um erro durante o pagamento da fatura!\n" +							"contate o administrador do sistema!&lk=application/fatura_empresa.jsp?id=-1";						}									}				);				$(this).dialog('close');			}		 					},		close: function() {			$(this).dialog('destroy');		}	}	);
}
function emitCupom() {	$("#faturaWindow").dialog({		modal: true,		width: 332,		minWidth: 332,		buttons: {			"Cancelar": function() {				$(this).dialog('close');			},			"Imprimir" : function () {				if ($('#vencimentoIn').val() == "") {					showErrorMessage ({						mensagem: "Não é possível imprimir faturas sem uma data de vencimento!",						title: "Acesso Negado"					});				} else {					var top = (screen.height - 600)/2;					var left= (screen.width - 800)/2;					window.open('rel_matricial/cupom_empresa.jsp?pp=' + 							$('#faturaId').val() + '&vpg=' + $('#moneyCupon').val(), 'nova',							'width= 600, height= 200, top= ' + top + ',' +							' left= ' + left);				}				$(this).dialog('close');			}		 					},		close: function() {			$(this).dialog('destroy');		}	}	);}function emitBoleto() {		var aux = mountPipeLine();	var top = (screen.height - 200)/2;	var left= (screen.width - 800)/2;	$("#boletoWindow").dialog({		modal: true,		width: 420,		minWidth: 420,		buttons: {	 						"Boleto A4" : function () {				window.open("../CadastroBoleto?pipe=" + aux + "&valor=" + 						$('#total').text() + "&vencimento=" + 						$('#dtVencimento').val() + "&conta=" +						$('#conta').val() + "&pessoa=" +						$('#codJuridico').val() + "&getBoleto= " +						$('#getBoleto').val() + "&tipo=0&from=1" , 'nova', 						'width= 800, height= 600, top=0' + top + ', ' +						'left= ' + left);				$(this).dialog('close');			},			"Boleto" : function () {				window.open("../CadastroBoleto?pipe=" + aux + "&valor=" + 						$('#total').text() + "&vencimento=" + 						$('#dtVencimento').val() + "&conta=" +						$('#conta').val() + "&pessoa=" +						$('#codJuridico').val() + "&getBoleto= " +						$('#getBoleto').val() + "&tipo=1&from=1" , 'nova', 						'width= 800, height= 600, top= ' + top + ', ' +						'left= ' + left);				$(this).dialog('close');			},			"Fatura" : function () {				window.open("../CadastroBoleto?pipe=" + aux + "&valor=" + 						$('#total').text() + "&vencimento=" + 						$('#dtVencimento').val() + "&conta=" +						$('#conta').val() + "&pessoa=" +						$('#codJuridico').val() + "&getBoleto= " +						$('#getBoleto').val() + "&tipo=2&from=1" , 'nova', 						'width= 800, height= 600, top= ' + top + ', ' +						'left= ' + left);				$(this).dialog('close');			},			"Cancelar": function() {				$(this).dialog('close');			}		},		close: function() {			$(this).dialog('destroy');		}	});}
function getErro(tipo) {	switch(tipo) {
	case '0':
		showErrorMessage ({			mensagem: "Não é possível imprimir cupons antes do recebimento!",			title: "Erro"		});
		break;			case '1':		showErrorMessage ({			mensagem: "Não é possível imprimir cupons de outro usuário!",			title: "Erro"		});		break;			case '2':		showErrorMessage ({			mensagem: "Não é possível imprimir cupons de datas anteriores!",			title: "Erro"		});		break;
	}}

function mountPipeLine(param) {
	var i = 0;	var aux = "";	while (document.getElementById("cod_lanc" + i) != null) {
		aux+= (i == 0)? document.getElementById("cod_lanc" + i++).text : 			"@" + document.getElementById("cod_lanc" + i++).text;
	}	return aux;
}

function noAccess() {	showErrorMessage ({		mensagem: "Para realizar esta operação é necessário abrir o caixa.",		title: "Acesso Negado"	});}

function excluiFatura(idCliente, idFatura) {
	showOption({
		mensagem: "Deseja realmente excluir esta fatura?",
		title: "Exclusão de Faturas",
		width: 350,
		show: 'fade',
		hide: 'clip',
		buttons: {
			"Não": function () {
				$(this).dialog('close');
			},
			"Sim": function() {
				$.get("../CadastroFaturaEmpresa",{							
					codigo: idFatura,
					from: 3
				}, function (response) {
					var erroOrMsg = "";
					if (response == 'z') {
						erroOrMsg = "é necessário que a fatura esteja em aberto para a exclusão!"; 
					} else if (response = 'o') {
						erroOrMsg = 'Fatura excluída com sucesso!';
					} else {
						erroOrMsg = 'Não foi possível excluir a fatura devido a um erro interno!';
					}
					
					showOption({
						mensagem: erroOrMsg,
						title: "Exclusão de Faturas",
						width: 350,
						show: 'fade',
						hide: 'clip',
						buttons: {
							'Ok': function() {
								if (response != 'o') {
									$(this).dialog('close');									
								} else {
									location.href = "fatura_empresa.jsp?&id=" + idCliente;
								}
							}
						}
					});				
				});
			}
		}
	});
}