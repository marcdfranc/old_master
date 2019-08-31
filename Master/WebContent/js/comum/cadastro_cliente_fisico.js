var dependente;
var informacao;
var isEdition= false;
var lastIndex= -1;
var oldPlano;

function loadPage(isEd){
	var aux = 0;
	dependente = new dtGrid("editedsDependente", "deletedsDependente", "delDependente", "edDependente", "editDependente", true);
	dependente.setLocalHidden("localDependente");
	dependente.setLocalAppend("tableDependente");
	dependente.setIdHidden("rowDependente");
	dependente.addCol("Ref.", "5", "rowRef");
	dependente.addCol("Nome", "30", "rowNome");
	dependente.addCol("Cpf", "20", "rowCpf");
	dependente.addCol("Nascimento", "10", "rowNascimento");
	dependente.addCol("Parentesco", "10", "rowParentesco");
	dependente.addCol("Fone", "20", "rowFone");		
	dependente.mountHeader(isEd);
	informacao= new dtGrid("editedsContact", "deletedsContact", "delContact", "edInfo", "editContact", true);
	informacao.setLocalHidden("localContact");
	informacao.setLocalAppend("tableContact");
	informacao.setIdHidden("rowContact");
	informacao.addCol("Tipo", "38", "rowType");
	informacao.addCol("Descrição", "48", "rowDescript");
	informacao.addCol("Principal", "14", "rowMain");
	informacao.setException();
	//informacao.setSequence(false);
	informacao.mountHeader(isEd);
	if (isEd) {
		while ($('#edNome' + parseInt(aux)).val() != undefined) {
			dependente.addIds($('#dependenteId' + parseInt(aux)).val());
			dependente.addValue($('#edRef' + parseInt(aux)).val());
			dependente.addValue($('#edNome' + parseInt(aux)).val());
			dependente.addValue($('#edCpf' + parseInt(aux)).val());
			dependente.addValue($('#edNasciemnto' + parseInt(aux)).val());
			dependente.addValue($('#edParentesco' + parseInt(aux)).val());
			dependente.addValue($('#edFone' + parseInt(aux++)).val());
			dependente.appendTable();								
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
	dependente.setSequence(true);
	$("#idVendedor").focus();
}	
	
function addRowDependente(){
	if (($('#nomeDependenteIn').val() != "") && 
		(document.getElementById("parentescoIn").selectedIndex > 0)) {			
		if (isEdition) {
			dependente.editValue($('#nomeDependenteIn').val(), lastIndex);
			dependente.editValue($('#cpfDependenteIn').val());
			dependente.editValue($('#nascimentoDependenteIn').val());
			dependente.editValue(document.getElementById("parentescoIn").value);
			dependente.editValue($('#foneDependenteIn').val());
			dependente.setRowInPosition(lastIndex);
			isEdition= false;
			lastIndex= -1;
		} else {
			dependente.addValue($('#nomeDependenteIn').val());
			dependente.addValue($('#cpfDependenteIn').val());
			dependente.addValue($('#nascimentoDependenteIn').val());
			dependente.addValue(document.getElementById("parentescoIn").value);
			dependente.addValue($('#foneDependenteIn').val());				
		}
		dependente.appendTable();
		$('#nomeDependenteIn').val("");
		$('#cpfDependenteIn').val("");
		$('#nascimentoDependenteIn').val("");
		document.getElementById("parentescoIn").selectedIndex= 0;
		$('#foneDependenteIn').val("");
	} else {
		showErrorMessage ({
			width: 400,
			mensagem: "Os campos nome e parentesco devem ser preenchidos para que possa ocorrer a inserção!",
			title: "Erro"
		});
	}
}

function removeRowDependente() {		
	dependente.removeData();
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
	informacao.removeData();
}
	
function setRenovacao(){
	if (!isEmpty($('#cadastroIn').val())) {
	if (document.getElementById("vigencia").selectedIndex == 0) {
		$('#renovacaoIn').val("");
	} else {
			$('#renovacaoIn').val(addMonths($('#vencimento').val() + "/" + 
			getMonth($('#cadastroIn').val()) + "/" + getYear($('#cadastroIn').val()) , 
			parseInt($('#vigencia').val())));
		}
	}
}

function editDependente(valueIn) {		 
	var aux= dependente.getRow(valueIn);		
	$('#nomeDependenteIn').val(aux[1]);
	$('#cpfDependenteIn').val(aux[2]);
	$('#nascimentoDependenteIn').val(aux[3]);		
	switch (aux[4].toLowerCase()) {
		case 'irmão(a)':
			document.getElementById("parentescoIn").selectedIndex = 1;
			break;
			
		case 'conjuge':
			document.getElementById("parentescoIn").selectedIndex = 2;
			break;
			
		case 'pai':
			document.getElementById("parentescoIn").selectedIndex = 3;
			break;
		
		case 'mãe':
			document.getElementById("parentescoIn").selectedIndex = 4;
			break;
			
		case 'sogro(a)':
			document.getElementById("parentescoIn").selectedIndex = 5;
			break;
			
		case 'filho(a)':
			document.getElementById("parentescoIn").selectedIndex = 6;
			break;
			
		case 'neto(a)':
			document.getElementById("parentescoIn").selectedIndex = 7;
			break;
			
		case 'outro':
			document.getElementById("parentescoIn").selectedIndex = 8;
			break;
	}		
	$('#foneDependenteIn').val(aux[5]);
	isEdition= true;
	lastIndex= valueIn;		
}

function generateParc() {				
	if ($('#codUser').val() != "") {
		$.get("../CadastroMensalidade",{
			usuario: $('#codUser').val(), 
			pagamentos: $('#pagamentos').val(),
			parcelaIn: $('#parcelaIn').val(),
			vencimento: $('#vencimento').val()},
			function (response) {
				if (response != "-1") {
					showErrorMessage ({
						width: 400,
						mensagem: response,
						title: "Erro"
					});													
				} else {
					showErrorMessage ({
						width: 400,
						mensagem: "ocorreu um erro durante a renovação.\n" +
								"contate imediatamente administrador do sistema!",
						title: "Erro"
					});
				}
				location.href= "cliente_fisico.jsp";
			}
		);
	}
}

function showUploadWd() {	
	$("#uploadCtr").dialog({
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
		var url = "upload/ctrs/ctr_" + $('#codUser').val() + ".pdf";
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

function getCampos(field) {
	if (field != undefined) {
	 	$.get("../CadastroClienteFisico",{
			idVendedor: field.value, 
			from: "2"},
			function (response) {
				if (response != "") {
					$("#unidadeId > *").each(function (index, domEle) {
						if (getPart(domEle.value, 2) ==  getPart(response, 1)) {
							domEle.selected = true;
							$("#unidadeIn").val(getPart(domEle.value, 1));
						}
					});
					$("#vendedorIn").val(getPart(response, 2));
				}
			}
		);
	}
	$("#cadastroIn").focus();
}

function emitContrato() {
	$("#impContrato").dialog({
 		modal: true,
 		width: 400,
 		minWidth: 400,
 		show: 'fade',
	 	hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close');
 			},
 			"Imprimir": function () {
 				var top = (screen.height - 200)/2;
				var left= (screen.width - 600)/2;
				window.open("../GeradorRelatorio?rel=" + $('#relId').val() + "&parametros=" + 
					$('#COD_USUARIO').val() + "@" + $('#codUser').val() + "|" + 
					$('#DATA_DOCUMENTO').val() + "@" + $('#dataDoc').val() + "|" + 
					$('#VALOR_ADESAO').val() + "@" + $('#vlrAdesao').val() + "|" + 
					$('#MENSALIDADE').val() + "@" + $('#vlrMensalidade').val() + "|" + 
					$('#DATA_ADESAO').val() + "@" + $('#vencAdesao').val() + "|" +
					$('#VENC_MENSALIDADE').val() + "@" + $('#vencMensalidade').val(), 
					'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
				$(this).dialog('close');
 			}
 		},
 		close: function() {
 			$(this).dialog('destroy');
 		}
 	});		
}

function init() {
	if (window.XMLHttpRequest) {
		return new XMLHttpRequest();
	} else if (window.ActiveXObject) {
		return new ActiveXObject("Microsoft.XMLHTTP");
	}
}

sendForm= function() {
	var formulario = document.getElementById("formPost");
	if (validForm(formulario)) {
		$('#plano').removeAttr("disabled"); 
		document.forms["formPost"].submit();
	}
}


$(document).ready(function(){	
	$("#uploadify").uploadify({
		'uploader' : '../flash/uploadify.swf',
		'script' : '../ContratoUpload',
		'cancelImg' : '../image/cancel.png',
		'buttonImg' : '../image/upload.gif',								
		'folder' : 'upload/ctrs',
		'queueID' : 'fileQueue',
		'fileDesc': 'Arquivos Adobe PDF(*.pdf)',
		'fileExt': '*.pdf',
		'width' : 320,
		'height': 200,
		'scriptData' : {
			'nome_arquivo': 'ctr_' + $('#codUser').val(),
			'idUsuario': $('#codUser').val()
		},
		'queueSizeLimit': 1,
		'sizeLimit': 573440,
		'onComplete' : function (event, queueID, fileObj, response, data) {
			location.href= response;
			return true;
		},
		'auto' : true,
		'multi' : false
	});
	
	$('#unidadeId').change(function(){
		if ($('#unidadeId').val() == "") {
			$('#unidadeIn').val("");
		} else {
			$.get("../FuncionarioGet",{
				unidadeId: getPart($('#unidadeId').val(), 2), 
				from: "0"},
				function (response) {
					$('#unidadeIn').val(response);
				}
			);
		}
	});
	
	$('#idEmpresa').change(function() {
		if ($('#idEmpresa').val() == ""){
			//$('#empresaIn').val("");
			$('#vencimento').removeAttr("disabled");
		} else {
			$('#vencimento').val(getPart($('#idEmpresa').val(), 2));
			$('#vencimento').attr("disabled","disabled");
		}
	});
	
	$('#idVendedor').blur(function(){
		if ($('#idVendedor').val() != "") {
			$.get("../FuncionarioGet",{
				idFuncionario: $('#idVendedor').val(), 
				from: "3"},
				function (response) {
					$('#vendedorIn').val(response);
				}
			);			
		}
	});
	
	$('#vigencia').change(function() { setRenovacao(); });
	
	$('#vencimento').change(function() {setRenovacao(); });
	
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
	
	$("#idVendedor").keypress(function(e) {
		var elemento;
		if (e.which == 13) {
			getCampos(this);
		}
	});	
	
	$("#codigoIn").blur( function() {
		if ($('#unidadeId').val() == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma unidade para inclusão do CTR!",
				title: "Erro"
			});
		} else if ($("#codigoIn").val() != ""){
			$.get("../CadastroClienteFisico",{
				ctr: $("#codigoIn").val(), 
				unidade: $("#unidadeId").val(),			
				from: "0"},
				function (response) {
					if (response == "1") {
						showErrorMessage ({
							width: 400,
							mensagem: "Número de CTR já inserido ou não cadastrado no RH!",
							title: "Erro"
						});
					}
				}
			);
		}
	});	
});
