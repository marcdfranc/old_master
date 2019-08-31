//var unidade;
//var grdInfo;
//var infoGenerate = 0;
//var undGenerate = 0;
//var dataTeste = new Array();
var grdUnidade;
var informacao;
var isEdition;
var lastIndex= -1;

$(document).ready(function() {
	isEdition = $('#isEdition').val() == 's';
	
	grdUnidade = new dtGrid("editedsUnd", "deletedsUnd", "delUnd", "edUnd", "editUnd", true);
	grdUnidade.setLocalHidden("localUnd");
	grdUnidade.setLocalAppend("tableUnidade");
	grdUnidade.setIdHidden("rowUnd");
	grdUnidade.addCol("Código", "10", "rowUndId");
	grdUnidade.addCol("Ref.", "5", "rowRef");
	grdUnidade.addCol("Razão Social", "31", "rowRzSocial");
	grdUnidade.addCol("Cidade", "26", "rowCidade");
	grdUnidade.addCol("Fone", "1", "RowFone");
	grdUnidade.setException();
	grdUnidade.setSequence(false);
	grdUnidade.mountHeader(isEdition);
	
	informacao= new dtGrid("editedsContact", "deletedsContact", "delContact", "edInfo", "editContact", true);
	informacao.setLocalHidden("localContact");
	informacao.setLocalAppend("tableContact");
	informacao.setIdHidden("rowContact");
	informacao.addCol("Tipo", "38", "rowType");
	informacao.addCol("Descrição", "48", "rowDescript");
	informacao.addCol("Principal", "14", "rowMain");
	informacao.setException();
	//informacao.setSequence(false);	
	informacao.mountHeader(isEdition);
	aux = 0;
	if (isEdition) {
		while ($('#edRzSocial' + parseInt(aux)).val() != undefined) {
			grdUnidade.addIds($('#undFisicaId' + parseInt(aux)).val());
			grdUnidade.addValue($('#undFisicaId' + parseInt(aux)).val());
			grdUnidade.addValue($('#edReferencia' + parseInt(aux)).val());
			grdUnidade.addValue($('#edRzSocial' + parseInt(aux)).val());
			grdUnidade.addValue($('#edDescricao' + parseInt(aux)).val());
			grdUnidade.addValue($('#edFone' + parseInt(aux++)).val());			
			grdUnidade.appendTable();
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
	$("#idVendedor").focus();	
	
	$('#loginIn').change(function() {
		loginOld = getPart($('#loginOld').val(), 2);
		if (getPart($('#loginOld').val(), 1) == 'n' && isEdition) {
			$('#loginOld').val('s@' + loginOld);
		}
	});
	
	$('#cepResponsavelIn').blur(function() {				
		if ($('#cepResponsavelIn').val() != "") {
			var req = init();
			var url = "../FuncionarioGet?from=15&cep=" + $('#cepResponsavelIn').val();
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
							
							document.getElementById("ufResponsavel").selectedIndex = getSelectIndex(
								document.getElementById("ufResponsavel").options, 
								req.responseXML.getElementsByTagName("uf")[0].firstChild.nodeValue);
						}
					}
				}
			}
		}
	});
	
	
	/*aux = unmountPipe($('#infoList').val());
	informacao = new Array();
	for (var i = 0; i < aux.length; i++) {
		informacao.push({
			id: getPipeByIndex(aux[i], 0),
			data: new Array(getPipeByIndex(aux[i], 1), getPipeByIndex(aux[i], 2), getPipeByIndex(aux[i], 3))
		});
	}
	
	grdInfo = new DataTable({
		id: 'grdInfo',
		name: 'grdInfo',
		model: new Array(
			{style: 'width: 10%', value: 'Tipo'},
			{style: 'width: 36%', value: 'Descrição'},
			{style: 'width: 26%', value: 'Principal'},
			{style: 'width: 2%', value: 'Ck'}
		),
		data: informacao,
		conteiner: '#tableContact',
		remove: true
	});
	$('#tableContact').append(grdInfo.getTable());
	$('#infoData').val(grdInfo.getDataGrid());
	
	aux = unmountPipe($('#unidadeList').val());
	unidade = new Array();
	for (var i = 0; i < aux.length; i++) {
		unidade.push({
			id: getPipeByIndex(aux[i], 0), 
			data: new Array(getPipeByIndex(aux[i], 1), getPipeByIndex(aux[i], 2), getPipeByIndex(aux[i], 3), getPipeByIndex(aux[i], 4))
		});
	}
	
	grdUnidade = new DataTable({
		id: 'grdUnidade',
		name: 'grdUnidade',
		model: new Array(
				{style: 'width: 10%', value: 'Codigo'},
				{style: 'width: 36%', value: 'Razão Social'},
				{style: 'width: 26%', value: 'Cidade'},
				{style: 'width: 26%', value: 'Fone'},
				{style: 'width: 2%', value: 'Ck'}
		),
		data: unidade,
		conteiner: '#tableUnidade',
		remove: true
	});	
	$('#tableUnidade').append(grdUnidade.getTable());
	$('#unidadeData').val(grdUnidade.getDataGrid());*/
	
});


function editarSenha() {
	if ($('#editSenha').hasClass('greenButtonStyle')) {
		$('#editSenha').removeClass('greenButtonStyle');
		$('#editSenha').addClass('grayButtonStyle');
		$('#confirmSenha').removeClass('grayButtonStyle');
		$('#confirmSenha').addClass('greenButtonStyle');
		
		$('#senhaIn').removeAttr('readonly');
		$('#senhaConfirmIn').removeAttr('readonly');
		
		if ($('#senhaChange').val() == 'n') {
			$('#senhaChange').val('s');
		}	
	}
}

function confirmarSenha() {
	if ($('#confirmSenha').hasClass('greenButtonStyle')) {
		$('#editSenha').addClass('greenButtonStyle');
		$('#editSenha').removeClass('grayButtonStyle');
		$('#confirmSenha').addClass('grayButtonStyle');
		$('#confirmSenha').removeClass('greenButtonStyle');
		
		$('#senhaIn').attr('readonly', 'readonly');
		$('#senhaConfirmIn').attr('readonly', 'readonly');
	}
}

function mountTabelaPost() {
	var htm = "";
	$("#grdUnidadeConteiner > *").each(function (ind, domEle) {
		htm += "<input type=\"hidden\" id=\"CodigoUnid" + ind + "\" name=\"rowCodigo" +
			ind + "\" value=\"" + $("#rowCodigo" + ind).text() + "\">";
		
		htm += "<input type=\"hidden\" id=\"rowQtde" + ind + "\" name=\"rowQtde" +
			ind + "\" value=\"" + $("#rowQtde" + ind).text() + "\">";
	}); 		
	$("#dataBank").remove();
	$("#localTabela").append(htm);
}


function getCampos() {
	resut = false;
	
	return resut;	
}

function addRowContato() {
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

function addRowUnidade() {
	administrador = "";
	$.ajax({
		type: "GET",
		url: '../CadastroAdministrador',
		data: 'from=1&id=' + $('#unidade').val(),
		dataType: 'json',
		success: function(response) {
			if (response.administrador == "-1") {
				grdUnidade.addValue(response.id);
				grdUnidade.addValue(response.ref);
				grdUnidade.addValue(response.rzSocial);
				grdUnidade.addValue(response.cidade);
				grdUnidade.addValue(response.fone);
				grdUnidade.appendTable();
			} else {
				administrador = response.administrador; 
				showErrorMessage ({
					width: 400,
					mensagem: "Esta unidade não pode ser adicionada por já pertencer ao Sr(a) " +  administrador + "!",
					title: "Erro"
				});
			}
		}, 
		error: function(response) {
			showErrorMessage({
				width: 400,
				mensagem: "Ocorreu um erro durante o processamento dos dados desta unidade!",
				title: "Erro de Processamento"
			});
		}
	});
	
	document.getElementById('unidade').selectedIndex = 0;
}

function removeRowContato() {
	informacao.removeData();
}

function removeRowUnidade() {
	grdUnidade.removeData();
}

function init() {
	if (window.XMLHttpRequest) {
		return new XMLHttpRequest();
	} else if (window.ActiveXObject) {
		return new ActiveXObject("Microsoft.XMLHTTP");
	}
}

function generateAccess() {
	if (isEdition) {
		$.get("../RHAnexo",{
			idRh: $('#codAdm').val(),
			tipo: 'a',
			from: "1"},
			function (response) {
				location.href = '../error_page.jsp?errorMsg=' + response + 
				'&lk=application/cadastro_administrador.jsp?state=1&id=' + $('#codAdm').val();
			}
		);
	}
}

/**
 * BloquearCartao	 
 */
function BloquearCartao() {
	showOption({
		title: "Bloqueio",
		mensagem: "Tem certeza que deseja bloquear o cartão deste usuário?",
		icone: "w",
		width: 400,
		show: 'fade',
	 	hide: 'clip',
		buttons: {
			"Não": function() {
				$(this).dialog('close');
			},
			"Sim": function () {
			 	$.get("../RHAnexo",{
		 			idRh: $('#codAdm').val(),
		 			tipo: 'a',
					from: "2"},
					function (response) {
						location.href = '../error_page.jsp?errorMsg=' + response + 
								'&lk=application/cadastro_administrador.jsp?state=1&id=' + $('#codAdm').val();
					}
				);
				$(this).dialog('close');
			}
		} 
	});
}

/**
 * liberarCartao	  
 */
function liberarCartao() {	 	
 	$.get("../RHAnexo",{			
 		idRh: $('#codAdm').val(),
 		tipo: 'a',
		from: "3"},
		function (response) {
			location.href = '../error_page.jsp?errorMsg=' + response + 
					'&lk=application/cadastro_administrador.jsp?state=1&id=' + $('#codAdm').val();
		}
	);
}

/**
 * delCartao	  
 */
function delCartao() {
 	showOption({
		title: "Bloqueio",
		mensagem: "Tem certeza que deseja excluir o cartão de acesso deste usuário?",
		icone: "w",
		width: 400,
		show: 'fade',
	 	hide: 'clip',
		buttons: {
			"Não": function() {
				$(this).dialog('close');
			},
			"Sim": function () {
			 	$.get("../RHAnexo",{
		 			idRh: $('#codAdm').val(),
		 			tipo: 'a',
					from: "5"},
					function (response) {
						location.href = '../error_page.jsp?errorMsg=' + response + 
								'&lk=application/cadastro_administrador.jsp?state=1&id=' + $('#codAdm').val();
					}
				);
				$(this).dialog('close');
			}
		}
	});
}

function imprimeCartao() {	
	top = (screen.height - 200)/2;
	left= (screen.width - 600)/2;
	if (isEdition) {
		window.open("../GeradorRelatorio?rel=132&parametros=6@" + $('#loginIn').val() , 
				'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
	}
}

function loadFile() {
	var top = (screen.height - 200)/2;
	var left= (screen.width - 600)/2;
	window.open('upload.jsp?id=\'' + $('#codAdm').val() + '\'', 'nova', 'width= 600, height= 200, top= ' + top + ', left= ' + left);
}

/*function addRowContato() {
data = {id: --infoGenerate + "", data: new Array(
	$('#tipoContato').val(), $('#descricaoIn').val(), $('#principalIn').val()
)};
grdInfo.addRow(data);
$('#infoData').val(grdInfo.getData());
$('#descricaoIn').val("");
$('#tipoContato').val("");
$('#principalIn').val("");
}

function addRowUnidade() {
dados = null;
$.ajax({
	type: "GET",
	url: '../CadastroAdministrador',
	data: 'from=1&id=' + $('#unidade').val(),
	dataType: 'json',
	success: function(response) {
		dados = {id: response.id , data: new Array(
				response.id, response.rzSocial , response.cidade, response.fone
		)};
		grdUnidade.addRow(dados);
	}, 
	error: function(response) {
		showErrorMessage({
			width: 400,
			mensagem: "Ocorreu um erro durante o processamento dos dados desta unidade!",
			title: "Erro de Processamento"
		});
	}
});
//grdUnidade.addRow(dados);
$('#unidadeData').val(grdInfo.getDataGrid());
document.getElementById('unidade').selectedIndex = 0;
}



function removeRowContato() {
grdInfo.removeRow();
$('#infoData').val(grdInfo.getDataGrid());
}

function removeRowUnidade() {
alert(grdUnidade.removeRow());
$('#unidadeData').val(grdInfo.getDataGrid());
}*/