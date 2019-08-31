var conta;
var informacao;
var isEdition= false;
var lastIndex= -1;

$(document).ready(function() {	
	isEd = $('#isEdition').val() == "t";  
	var aux = 0;
	conta= new dtGrid("editedsBank", "deletedsBank", "delBank", "edBank", "editBank", true);		
	conta.setLocalHidden("localBank");
	conta.setLocalAppend("tableBank");
	conta.setIdHidden("rowBank");
	conta.addCol("Titular", "35", "rowPrincipal");		
	conta.addCol("Banco", "35", "rowBank");
	conta.addCol("Agencia", "10", "rowAgency");
	conta.addCol("Conta", "20", "rowCont");
	conta.setSequence(false);
	conta.mountHeader(isEd);
	informacao= new dtGrid("editedsContact", "deletedsContact", "delContact", "edInfo", "editContact", true);		
	informacao.setLocalHidden("localContact");
	informacao.setLocalAppend("tableContact");
	informacao.setIdHidden("rowContact");				
	informacao.addCol("Tipo", "38", "rowType");
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
			conta.addValue($('#edCont' + parseInt(aux++)).val());				
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
	
	$('#unidadeId').change(function(){
		if ($('#unidadeId').val() == "") {
			$('#unidadeIn').val("");
		} else {
			$.get("../FuncionarioGet",{unidadeId: getPart($('#unidadeId').val(), 2), 
				from: "0"},
				function (response) {
					$('#unidadeIn').val(response);
				});
		}
	});
	
	$('#setorIn').change(function() {
		if($('#setorIn').val() != "") {
			$.get("../FuncionarioGet",{setorIn: $('#setorIn').val(), 
				from: "4"},
				function (response) {
					$('#especialidadeIn').empty();
					$('#especialidadeIn').append(response);
					document.getElementById("especialidadeIn").selectedIndex= 0;					
			});
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
	
	var pathName = location.pathname;
	var conteiner = '';
	
	for (var i = 1; i < pathName.length; i++) {
		if (pathName.charAt(i) != '/') {
			conteiner+= pathName.charAt(i);			
		} else {
			conteiner+= pathName.charAt(i);
			break;
		}
	}
	
	//alert("http://" + location.host + "/" + conteiner);
	
	//alert(location.pathname);
	
	$("#uploadify").uploadify({		
		'script' : "../ImageUpload",
		'uploader' : '../flash/uploadify.swf',
		'cancelImg' : '../image/cancel.png',
		'buttonImg' : '../image/upload.gif',								
		'folder' : 'upload/ctrs',
		'queueID' : 'fileQueue',
		'fileDesc': 'Arquivos de Imagem',		
		'fileExt': '*.jpg;*.jpeg;*.gif;*.png', 
		'width' : 320,
		'height': 200,
		'scriptData' : {
			'idPessoa': $('#codProfissional').val()
		},
		'queueSizeLimit': 1,
		'sizeLimit': 550000,
		'onError': function (event, queueID ,fileObj, errorObj) {
			var msg = errorObj.type+"::"+errorObj.info;
			
			showErrorMessage ({
				width: 400,
				mensagem: msg,
				title: "Erro"
			});
			$("#fileUpload" + queueID).fadeOut(250,	 function() { 
				$("#fileUpload" + queueID).remove();
			});
			return false;
		},
		'onComplete' : function (event, queueID, fileObj, response, data) {
			alert(response);
			//location.href= response;
			return true;
		},
		'auto' : true,
		'multi' : false
	});
	
});


function addRowBank() {
	if (($('#numeroContaIn').val() != "") && ($('#banco').val() != "-1" && 
			($('#titularContaIn').val() != ""))) {
		if (isEdition) {				
			conta.editValue($('#titularContaIn').val());
			conta.editValue(document.getElementById("banco").value + "@" +
					document.getElementById("banco").text);
			conta.editValue($('#agenciaIn').val());
			conta.editValue($('#numeroContaIn').val());
			conta.setRowInPosition(lastIndex);
			isEdition= false;
			lastIndex= -1;
		} else {				
			conta.addValue($('#titularContaIn').val());
			conta.addValue(document.getElementById("banco").value);
			conta.addValue($('#agenciaIn').val());
			conta.addValue($('#numeroContaIn').val());1
		}
		conta.appendTable();
		$('#titularContaIn').val("");
		$('#agenciaIn').val("");
		$('#numeroContaIn').val("");
		document.getElementById("banco").selectedIndex= 0;
	} else {
		showErrorMessage ({
			width: 400,
			mensagem: "Os campos banco, número da conta e titular devem ser preenchidos para que possa ocorrer a inserção!",
			title: "Erro"
		});
	}
}

function editBank(valueIn) {
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
	$('#agenciaIn').val(aux[2]);
	$('#numeroContaIn').val(aux[3]);
	$('#titularContaIn').val(aux[0]);
	isEdition= true;
	lastIndex= valueIn;
}	

function removeRowBank() {
	conta.removeData();
}

function addRowContact(){
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
			width: 400,
			mensagem: "Os campos de contato devem ser preenchidos para que possa ocorrer a inserção!",
			title: "Erro"
		});
	}
}

function editContact(valueIn) {
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

function removeRowContact() {
	setChange('i');
	informacao.removeData();
}

function setChange(value){
	switch (value) {
	case "u":
		$('#edUnit').val("s");
		break;
	case "e":
		$('#edMainAddress').val("s");
		break;
	case "a":
		$('#edAdmin').val("s");
		break;
	case "r":
		$('#edAdminAddress').val("s");
		break;
	case "c":
		$('#edAcount').val("s");
		break;
	case "i":
		$('#edInfo').val("s");
		break;
	}
}

function init() {
	if (window.XMLHttpRequest) {
		return new XMLHttpRequest();
	} else if (window.ActiveXObject) {
		return new ActiveXObject("Microsoft.XMLHTTP");
	}
}

function editarSenha(object) {
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

function confirmarSenha(object) {
	if (object.className == "greenButtonStyle") {
		if ($('#senhaIn').val() != $('#senhaConfirmIn').val()) {
			showErrorMessage ({
				width: 400,
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

function loadFile() {
	$("#uploadCadastro").dialog({
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
	/*var top = (screen.height - 200)/2;
	var left= (screen.width - 600)/2;
	window.open('upload.jsp?id=\'' + $('#codProfissional').val() + '\'', 'nova', 'width= 600, height= 200, top= ' + top + ', left= ' + left);*/
}

function imprimeCadastro() {
	showErrorMessage ({
		width: 200,
		mensagem: "em manutenção!",
		title: "Erro"
	});
	
}

function loadDocDigital() {
	alert($('#codProfissional').val());
	
	$.get("../CTRProfUpload",{		 
		from: "2"},
		function (response) {
			alert(response);			
		}
	);
}

function showUploadWd() {
	$("#uploadCadastro").dialog({
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