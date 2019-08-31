var conta;
var informacao;
var isEdition= false;
var lastIndex= -1;
var cadastro;

function showUploadWd() {
	$("#uploadCtrSocial").dialog({
 		modal: true,
 		width: 549,
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
		var url = "upload/contratos_sociais/ctr_social_" + $('#codUnit').val() + ".pdf";
		var top = (screen.height - 600)/2;
		var left= (screen.width - 800)/2;
		window.open(url ,'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
	} else {
		showErrorMessage ({
			width: 400,
			mensagem: "Arquivo inexistente, imagem não encontrada!",
			title: "Erro"
		});
	}
}

function notAtorize() {
	showErrorMessage ({
		width: 400,
		mensagem: "Somente o administrador da Matriz pode realizar esta operação!",
		title: "Erro"
	});
}

$(document).ready(function() {
	$("#uploadify").uploadify({
		'uploader' : '../flash/uploadify.swf',
		'script' : '../ContratoSocialUpload',
		'cancelImg' : '../image/cancel.png',
		'buttonImg' : '../image/upload.gif',								
		'folder' : 'upload/contratos_sociais',
		'queueID' : 'fileQueue',
		'fileDesc': 'Arquivos Adobe PDF(*.pdf)',
		'fileExt': '*.pdf',
		'width' : 320,
		'height': 200,
		'scriptData' : {
			'nome_arquivo': 'ctr_social_' + $('#codUnit').val(),
			'idUnidade': $('#codUnit').val()
		},
		'queueSizeLimit': 1,
		'sizeLimit': 250000,
		'onComplete' : function (event, queueID, fileObj, response, data) {
			location.href= response;
			return true;
		},
		'auto' : true,
		'multi' : false
	});
	
	loadPage = function(isEd){		
		var aux = 0;
		conta= new dtGrid("editedsBank", "deletedsBank", "delBank", "edBank", "editBank", true);
		conta.setLocalHidden("localBank");
		conta.setLocalAppend("tableBank");
		conta.setIdHidden("rowBank");
		conta.addCol("Titular", "30", "rowPrincipal");		
		conta.addCol("Banco", "30", "rowBank");
		conta.addCol("Agencia", "10", "rowAgency");
		conta.addCol("Conta", "10", "rowCont");
		conta.addCol("Carteira", "10", "rowCarteira");
		conta.addCol("Boleto", "10", "rowBoleto");
		
		conta.setSequence(false);		
		conta.mountHeader(isEd);
		informacao= new dtGrid("editedsContact", "deletedsContact", "delContact", "edContact", "editContact", true);
		informacao.setLocalHidden("localContact");
		informacao.setLocalAppend("tableContact");
		informacao.setIdHidden("rowContact");
		informacao.addCol("Tipo", "48", "rowType");
		informacao.addCol("Descrição", "48", "rowDescript");
		informacao.addCol("Principal", "14", "rowMain");
		informacao.setException();
		informacao.setSequence(false);
		informacao.mountHeader(isEd);		
		if (isEd) {
			while ($('#edBank' + parseInt(aux)).val() != undefined) {
				conta.addIds($('#acountId' + parseInt(aux)).val());
				conta.addValue($('#edOwner' + parseInt(aux)).val());				
				conta.addValue($('#edBank' + parseInt(aux)).val());
				conta.addValue($('#edAgency' + parseInt(aux)).val());
				conta.addValue($('#edCont' + parseInt(aux)).val());				
				conta.addValue($('#edCarteira' + parseInt(aux)).val());
				conta.addValue($('#edBoleto' + parseInt(aux++)).val());
				conta.appendTable();								
			}
			aux= 0;	
			while ($('#edDescription' + parseInt(aux)).val() != undefined) {
				informacao.addIds($('#contactId' + parseInt(aux)).val());
				informacao.addValue($('#edType' + parseInt(aux)).val());
				informacao.addValue($('#edDescription' + parseInt(aux)).val());
				informacao.addValue($('#edPrincipal' + parseInt(aux++)).val());
				informacao.appendTable();
			}
		}
	}
	
	addRowBank= function() {
		if (($('#numeroContaIn').val() != "") && ($('#banco').val() != "-1" && 
				($('#titularContaIn').val() != ""))) {
			if (isEdition) {				
				conta.editValue($('#titularContaIn').val());
				conta.editValue(document.getElementById("banco").value + "@" +
					document.getElementById("banco").text);
				conta.editValue($('#agenciaIn').val());
				conta.editValue($('#numeroContaIn').val());
				conta.editValue($('#carteiraIn').val());
				conta.editValue($('#boletoIn').val());
				conta.setRowInPosition(lastIndex);
				isEdition= false;
				lastIndex= -1;
			} else {				
				conta.addValue($('#titularContaIn').val());
				conta.addValue(document.getElementById("banco").value);
				conta.addValue($('#agenciaIn').val());
				conta.addValue($('#numeroContaIn').val());
				conta.addValue($('#carteiraIn').val());
				conta.addValue($('#boletoIn').val());
			}
			conta.appendTable();
			$('#titularContaIn').val("");
			$('#agenciaIn').val("");
			$('#numeroContaIn').val("");
			$('#carteiraIn').val("");
			$('#boletoIn').val("0.00");
			document.getElementById("banco").selectedIndex= 0;			
		} else {
			showErrorMessage ({
				width: 600,
				mensagem: "Os campos banco, número da conta e titular devem ser preenchidos para que possa ocorrer a inserção!",
				title: "Erro"
			});
		}
	}
	
	editBank = function(valueIn) {
		var aux= conta.getRow(valueIn);
		var counter = -1;
		var arrayValue = getPart(aux[1], 2).toLowerCase();  
		while(document.getElementById("banco").options[++counter] != undefined) {
			selectValue = document.getElementById("banco").options[counter].text.toLowerCase();
			if (selectValue == arrayValue) {
				document.getElementById("banco").selectedIndex= counter;
				break;
			}
		}
		$('#titularContaIn').val(aux[0]);
		$('#agenciaIn').val(aux[2]);
		$('#numeroContaIn').val(aux[3]);
		$('#carteiraIn').val(aux[4]);
		$('#boletoIn').val(aux[5]);
		isEdition= true;
		lastIndex= valueIn;
	}
	
	removeRowBank= function() {
		conta.removeData();
	}
	
	addRowContact= function(){
		if (($('#descricaoIn').val() != "") && 
			(document.getElementById("tipoContato").selectedIndex > 0)) {				
			if (isEdition) {				
				informacao.editValue(document.getElementById("tipoContato").value);
				informacao.editValue($('#descricaoIn').val());
				informacao.editValue($('#principalIn').val());
				informacao.setRowInPosition(lastIndex);
				isEdition= false;
				lastIndex= -1;
			} else {
				informacao.addValue(document.getElementById("tipoContato").value);
				informacao.addValue($('#descricaoIn').val());
				informacao.addValue($('#principalIn').val());
			}
			informacao.appendTable();
			document.getElementById("tipoContato").selectedIndex= 0;
			document.getElementById("principalIn").selectedIndex= 1;
			$('#descricaoIn').val("");				
		} else {
			showErrorMessage ({
				width: 600,
				mensagem: "Os campos de contato devem ser preenchidos para que possa ocorrer a inserção!",
				title: "Erro"
			});
		}
	}
	
	editContact = function(valueIn) {
		var aux = informacao.getRow(valueIn);
		var counter= -1;
		var arrayValue = aux[0].toLowerCase();
		while(document.getElementById("tipoContato").options[++counter] != undefined) {
			selectValue = document.getElementById("tipoContato").options[counter].text.toLowerCase();
			if ((selectValue == arrayValue) || (arrayValue == "site" && selectValue == "pagina web")) {				
				document.getElementById("tipoContato").selectedIndex = counter;
				break;
			}
		}
		$('#descricaoIn').val(aux[1]);
		if (aux[2].toLowerCase() == "sim") {
			document.getElementById("principalIn").selectedIndex = 0;
		} else {
			document.getElementById("principalIn").selectedIndex = 1;
		}
		isEdition= true;
		lastIndex= valueIn;
	}
	
	removeRowContact= function() {		
		informacao.removeData();
	}
	
	editarSenha= function(object) {
		if (object.className == "greenButtonStyle") {
			$('#senhaIn').val("");
			$('#senhaConfirmIn').val("");
			$('#senhaIn').removeAttr("readOnly", "readOnly");
			$('#senhaConfirmIn').removeAttr("readOnly", "readOnly");
			$('#confirmSenha').removeClass();
			$('#confirmSenha').addClass("greenButtonStyle");
			$('#editSenha').removeClass();
			$('#editSenha').addClass("grayButtonStyle");			
		}
	}
	
	confirmarSenha= function(object) {
		if (object.className == "greenButtonStyle") {
			if ($('#senhaIn').val() != $('#senhaConfirmIn').val()) {
				showErrorMessage ({
					width: 600,
					mensagem: "As duas senhas devem ser iguais para que ocorra alteração!",
					title: "Erro"
				});
			} else {
				$('#senhaIn').attr({readOnly: "readOnly"});
				$('#senhaConfirmIn').attr({readOnly: "readOnly"});				
				$('#confirmSenha').removeClass();
				$('#confirmSenha').addClass("grayButtonStyle");
				$('#editSenha').removeClass();
				$('#editSenha').addClass("greenButtonStyle");				
			}
		}
	}
	
	function init() {
    	if (window.XMLHttpRequest) {
    		return new XMLHttpRequest();
    	} else if (window.ActiveXObject) {
    		return new ActiveXObject("Microsoft.XMLHTTP");
    	}
    }

	
	$('#codAdministradorIn').change(function() {
		aux= document.getElementById("codAdministradorIn");		
		if($('#codAdministradorIn').val() != "") {
			var req= init();
			var url = "../FuncionarioGet?from=5&codAdm=" + $('#codAdministradorIn').val();
			req.open("GET", url, true);
			req.send(null);
			req.onreadystatechange= function() {
				if (req.readyState == 4) {
					if (req.status == 200) {
						$('#nomeIn').val(
							req.responseXML.getElementsByTagName("nome")[0].firstChild.nodeValue							
						);
						if (req.responseXML.getElementsByTagName("sexo")[0].firstChild.nodeValue == "m") {
							document.getElementById("sexoIn").checked= true;
						} else {
							document.getElementById("sexo").checked= true;
						}
						$('#cpfIn').val(
							req.responseXML.getElementsByTagName("cpf")[0].firstChild.nodeValue							
						);
						$('#rgIn').val(
							req.responseXML.getElementsByTagName("rg")[0].firstChild.nodeValue							
						);
						$('#nascimentoIn').val(
							req.responseXML.getElementsByTagName("nascimento")[0].firstChild.nodeValue							
						);
						$('#nacionalidadeIn').val(
							req.responseXML.getElementsByTagName("nacionalidade")[0].firstChild.nodeValue							
						);
						$('#naturalidadeIn').val(
							req.responseXML.getElementsByTagName("naturalidade")[0].firstChild.nodeValue							
						);
						$('#naturalUfIn').val(
							req.responseXML.getElementsByTagName("naturalidadeUf")[0].firstChild.nodeValue							
						);
						$('#estadoCivilIn').val(
							req.responseXML.getElementsByTagName("estadoCivil")[0].firstChild.nodeValue							
						);
						$('#loginIn').val(
							req.responseXML.getElementsByTagName("login")[0].firstChild.nodeValue							
						);
						$('#senhaIn').val(
							req.responseXML.getElementsByTagName("senha")[0].firstChild.nodeValue							
						);
						$('#senhaConfirmIn').val(
							req.responseXML.getElementsByTagName("senha")[0].firstChild.nodeValue							
						);
						$('#cepResponsavelIn').val(
							req.responseXML.getElementsByTagName("cep")[0].firstChild.nodeValue							
						);
						$('#ruaResponsavelIn').val(
							req.responseXML.getElementsByTagName("rua")[0].firstChild.nodeValue							
						);
						$('#numeroResponsavelIn').val(
							req.responseXML.getElementsByTagName("numero")[0].firstChild.nodeValue							
						);
						$('#complementoResponsavelIn').val(
							req.responseXML.getElementsByTagName("complemento")[0].firstChild.nodeValue							
						);
						$('#bairroResponsavelIn').val(
							req.responseXML.getElementsByTagName("bairro")[0].firstChild.nodeValue							
						);
						$('#cidadeResponsavelIn').val(
							req.responseXML.getElementsByTagName("cidade")[0].firstChild.nodeValue							
						);
						$('#ufResponsavel').val(
							req.responseXML.getElementsByTagName("uf")[0].firstChild.nodeValue							
						);
						$('#isDel').val("1");
					}
				}
			}
		} else {
			//$('#refAdmin').val() != aux.options[aux.selectedIndex].text
			//$('#codFisicaIn').val("");
			$('#nomeIn').val("");
			$('#cpfIn').val("");
			$('#rgIn').val("");
			$('#nascimentoIn').val("");
			$('#nacionalidadeIn').val("");
			$('#naturalidadeIn').val("");
			$('#naturalUfIn').val("");
			$('#estadoCivilIn').val("");
			$('#loginIn').val("");
			$('#senhaIn').val("");
			$('#senhaConfirmIn').val("");			
			$('#cepResponsavelIn').val("");
			$('#ruaResponsavelIn').val("");
			$('#numeroResponsavelIn').val("");
			$('#complementoResponsavelIn').val("");
			$('#bairroResponsavelIn').val("");
			$('#cidadeResponsavelIn').val("");
			$('#ufResponsavel').val("");
		}
		if ($('#refAdmin').val() != aux.options[aux.selectedIndex].text && 
				$('#codAdministradorIn').val() != "") {
			//$('#codFisicaIn').attr({readOnly: "readOnly"});
			$('#nomeIn').attr({readOnly: "readOnly"});			
			$('#sexo').attr({disabled : "disabled"});
			$('#sexoIn').attr({disabled : "disabled"});
			$('#cpfIn').attr({readOnly: "readOnly"});
			$('#rgIn').attr({readOnly: "readOnly"});
			$('#nascimentoIn').attr({readOnly: "readOnly"});
			$('#nacionalidadeIn').attr({readOnly: "readOnly"});
			$('#naturalidadeIn').attr({readOnly: "readOnly"});
			$('#naturalUfIn').attr({disabled : "disabled"});
			$('#estadoCivilIn').attr({disabled : "disabled"});
			$('#loginIn').attr({readOnly: "readOnly"});
			$('#senhaIn').attr({readOnly: "readOnly"});
			$('#senhaConfirmIn').attr({readOnly: "readOnly"});
			$('#cepResponsavelIn').attr({readOnly: "readOnly"});
			$('#ruaResponsavelIn').attr({readOnly: "readOnly"});
			$('#numeroResponsavelIn').attr({readOnly: "readOnly"});
			$('#complementoResponsavelIn').attr({readOnly: "readOnly"});
			$('#bairroResponsavelIn').attr({readOnly: "readOnly"});
			$('#cidadeResponsavelIn').attr({readOnly: "readOnly"});
			$('#ufResponsavel').attr({disabled : "disabled"});				
		} else {
			if ($('#refAdmin').val() != aux.options[aux.selectedIndex].text) {
				//$('#codFisicaIn').removeAttr("readOnly", "readOnly");
				$('#senhaIn').removeAttr("readOnly", "readOnly");
				$('#senhaConfirmIn').removeAttr("readOnly", "readOnly");
			}
			$('#nomeIn').removeAttr("readOnly", "readOnly");			
			$('#sexo').removeAttr("disabled", "disabled");
			$('#sexoIn').removeAttr("disabled", "disabled");
			$('#cpfIn').removeAttr("readOnly", "readOnly");	
			$('#rgIn').removeAttr("readOnly", "readOnly");
			$('#nascimentoIn').removeAttr("readOnly", "readOnly");
			$('#nacionalidadeIn').removeAttr("readOnly", "readOnly");
			$('#naturalidadeIn').removeAttr("readOnly", "readOnly");
			$('#naturalUfIn').removeAttr("disabled", "disabled");
			$('#estadoCivilIn').removeAttr("disabled", "disabled");
			$('#loginIn').removeAttr("readOnly", "readOnly");
			$('#cepResponsavelIn').removeAttr("readOnly", "readOnly");
			$('#ruaResponsavelIn').removeAttr("readOnly", "readOnly");
			$('#numeroResponsavelIn').removeAttr("readOnly", "readOnly");
			$('#complementoResponsavelIn').removeAttr("readOnly", "readOnly");
			$('#bairroResponsavelIn').removeAttr("readOnly", "readOnly");
			$('#cidadeResponsavelIn').removeAttr("readOnly", "readOnly");
			$('#ufResponsavel').removeAttr("disabled", "disabled");			
		}
	});
	
	$('#tratamentoIn').change(function () {
		if (parseInt($(this).val()) > 0) {
			$('#tabela2In').val("0.0");
			$('#tabela2In').attr({readOnly: "readOnly"});			
		} else {
			$('#tabela2In').removeAttr("readOnly");
		}
	});
	
	$('#tabela2In').change(function () {
		if (parseInt($(this).val()) > 0) {
			$('#tratamentoIn').val("0.0");
			$('#tratamentoIn').attr({readOnly: "readOnly"});			
		} else {
			$('#tratamentoIn').removeAttr("readOnly");
		}
	});
	
	$('#cepIn').change(function() {
		if ($('#cepIn').val() != "") {
			var req = init();
			var url = "../FuncionarioGet?from=15&cep=" + $('#cepIn').val();
			req.open("GET", url, true);
			req.send(null);
			req.onreadystatechange = function(){
				if (req.readyState == 4) {
					if (req.status == 200) {
						if (req.responseXML.getElementsByTagName("rua")[0].firstChild.nodeValue != "0") {
							
							$('#ruaIn').val(
								req.responseXML.getElementsByTagName("rua")[0].firstChild.nodeValue
							);
							
							$('#bairroIn').val(
								req.responseXML.getElementsByTagName("bairro")[0].firstChild.nodeValue
							);
							
							$('#cidadeIn').val(
								req.responseXML.getElementsByTagName("cidade")[0].firstChild.nodeValue
							);
							
							document.getElementById("ufIn").selectedIndex = getSelectIndex(
								document.getElementById("ufIn").options, 
								req.responseXML.getElementsByTagName("uf")[0].firstChild.nodeValue);
						}
					}
				}
			}
		}
	});
	
	$('#cepResponsavelIn').change(function() {
		if ($('#cepResponsavelIn').val() != "") {
			var req = init();
			var url = "../FuncionarioGet?from=15&cep=" + $('#cepIn').val();
			req.open("GET", url, true);
			req.send(null);
			req.onreadystatechange = function(){
				if (req.readyState == 4) {
					if (req.status == 200) {
						if (req.responseXML.getElementsByTagName("rua")[0].firstChild.nodeValue != "0") {
							
							$('#ruaResponsavelIn').val(
								req.responseXML.getElementsByTagName("rua")[0].firstChild.nodeValue
							);
							
							$('#bairroResponsavelIn').val(
								req.responseXML.getElementsByTagName("bairro")[0].firstChild.nodeValue
							);
							
							$('#cidadeResponsavelIn').val(
								req.responseXML.getElementsByTagName("cidade")[0].firstChild.nodeValue
							);
							
							document.getElementById("ufResponsavel").selectedIndex = getSelectIndex(
								document.getElementById("ufResponsavel").options, 
								req.responseXML.getElementsByTagName("uf")[0].firstChild.nodeValue);
						}
					}
				}
			}
		}
	});	
	
	loadFile = function() {
		var top = (screen.height - 200)/2;
		var left= (screen.width - 600)/2;
		window.open('upload.jsp?id=\'' + $('#codFisica').val() + '\'', 'nova', 'width= 600, height= 200, top= ' + top + ', left= ' + left);
	}
	
	pdfCartao = function () {
		var top = (screen.height - 600)/2;
		var left= (screen.width - 800)/2;		
		window.open("../GeradorRelatorio?rel=132&parametros=6@" + $('#loginOld').val(),
			'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);	
	}
	
	noAccess = function() {
		showErrorMessage ({
			width: 400,
			mensagem: "Operação não permitida!",
			title: "Erro"
		});
	}
	
});