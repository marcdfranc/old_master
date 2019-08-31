/**
 * @author Marcelo
 */

var seletorNomes

function MM_openBrWindow() {	
	var configuracao = "";	
	var end = "www.scpc.inf.br";
	var pagina="/cgi-bin/spcnweb";
	var programa="md000008.int";
	var imagem="/spcn/imagens/logosentrada/araraquara.jpg";
	var css = "/spcn/imagens/logosentrada/araraquara.css";
	var entidade = "14800";
	document.title = "Sophus - Consultas de Informações";
	var stringEnvio = "";
	stringEnvio = "https://" + end + pagina + "?HTML_PROGRAMA=" + programa;
	if (imagem != "") {
		stringEnvio += "&HTML_IMAGEM="+imagem;
	}
	if (css != "") {
		stringEnvio += "&HTML_CSS="+css;
	}
	if (entidade != "")	{
		stringEnvio += "&HTML_ENTIDADE="+entidade;
	}
	var top = (screen.height - 600)/2;
	var left= (screen.width - 800)/2;
	configuracao = 'width= 800, height= 600, top= ' + top + ', left= ' + left;
	window.open(stringEnvio,'',configuracao);
}

function editObs() {		
	$("#obsWindow").dialog({
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
 			"Salvar": function () {
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
						} else {
							$('#obsw').val(response);
							$('#obsLabel').text(response);
							$('#obsIn').val(response);
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
 		close: function() {
 			$(this).dialog('destroy');	 			
 		}
 	});
}

function editVias(value) {
	var isDependente = "t";
	var id = $('#codUser').val();
	if (value == '-1') {
		$('#viasW').val($('#viaIn').val());
		isDependente = "f";
	} else {
		$('#viasW').val($('#carteira_' + value).val());
		id = value;
	}
	$('#viasWindow').dialog({
 		modal: true,
 		width: 201,
 		minWidth: 201,
 		show: 'fade',
	 	hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close');	 				
 			},
 			"Salvar": function () {
 				$.get("../MensalidadeAdapter",{
					vias: $('#viasW').val(),
					id: id,
					isDependente: isDependente, 
					from: "11"},
					function (response) {
						if (response == "-1") {
							showErrorMessage ({
								mensagem: "Ocorreu um erro durante o processo de salvamento!",
								title: "Edição de Observação"
							});
						} else {
							if (isDependente == "t") {
								$('#carteira_' + value).val(response);
							} else {
								$('#viaIn').val(response);
							}							
							showErrorMessage ({
								mensagem: "Edição realizada com sucesso!",
								title: "Edição de Observação"
							});
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

function showReport() {
	$('#carteirinhaWindow').dialog({
 		modal: true,
 		width: 759,
 		height: 457,
 		minWidth: 759,
 		show: 'fade',
	 	hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close');	 				
 			},
 			"Imprimir": function () {
 				var refPessoa = "";
				var top = (screen.height - 600)/2;
				var left= (screen.width - 800)/2;
				var isTeste = (document.getElementById("isTeste").checked)? "s" : "f";
				$("#itemSelValues > *").each(function(index, domEle) {
					if (index == 0) {
						refPessoa += $(domEle).val();	 						
					} else {
						refPessoa += "," + $(domEle).val();
					}
				});
				$(this).dialog('close');
					 				
				//window.open("../GeradorRelatorio?rel=11&parametros=7@" +  $("#unidadeId").val() +
		 			//"|8@" + refPessoa, 'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
		 		window.open("../Carteirinha?unidadeId=" +  $("#CarteiraUnd").val() + "&from=1&isTeste=" + isTeste +
					"&parametros=" + refPessoa, 'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
 			}
 		},
 		close: function() {
 			$(this).dialog('destroy');
 		}
 	});
}

function editCredito(value) {		
	var id;
	var isDependente = 't';
	if (value == -1) {
		id = $('#codUser').val();
		isDependente = 'f';
		$('#protestosWd').val($('#protrestoIn').val());
		$('#spcWd').val($('#spcIn').val());
		$('#devolucaoWd').val($('#chequeIn').val());
		$('#consultaWd').val($('#consultaIn').val());
	} else {
		id = value;
		$('#protestosWd').val($("#Protesto_" + id).val());
		$('#spcWd').val($("#spc_" + id).val());
		$('#devolucaoWd').val($("#devolucao_" + id).val());
		$('#consultaWd').val($("#dataConsulta_" + id).val());
	}	
	$("#consultaWindow").dialog({
 		modal: true,
 		width: 320,
 		show: 'fade',
	 	hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close');
 			},
 			"Salvar": function () {
 				$.get("../CobrancaAdapter",{
					from: '2',
					id: id,
					isDependente: isDependente,
					protestos: $('#protestosWd').val(),
					spc: $('#spcWd').val(),
					devolucao: $('#devolucaoWd').val(),
					dataConsulta: $('#consultaWd').val()}, 
					function (response) {
						if (response == "0") {
							location.reload();
						} else {
							showErrorMessage({
								width: 400,
								mensagem: "Não foi possível salvar o arquivo devido a um erro interno!",
								title: "Consulta de Crédito"
							});
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

$(document).ready(function() {
	$('#isTeste').button();
	
	seletorNomes = new MsfItemsSelectorAdm({
		id:"selectorNames", 
		leftId: "sortableLeft", 
		rightId: "sortableRight", 
		valueId:"valorUsuario",
		conteinerValues: 'itemSelValues',
		height: 270
	});
		
	$("#accordion").accordion({
		collapsible: true
	});	
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
	});
});