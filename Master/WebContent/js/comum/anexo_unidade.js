var editSenha = false;
var edicaoPorta = false;
var edicaoObs = false;

function editarSenha() {
 	if (!editSenha) {
	 	$('#senhaConfirmIn').removeAttr("readonly");
	 	$('#senhaIn').removeAttr("readonly");
	 	$('#confirmSenha').removeClass("grayButtonStyle");
	 	$('#editSenha').removeClass("greenButtonStyle");
	 	$('#editSenha').addClass("grayButtonStyle");
	 	$('#confirmSenha').addClass("greenButtonStyle");
	 	editSenha = true;
 	} else {
 		$('#senhaConfirmIn').attr("readonly", "readonly");
	 	$('#senhaIn').attr("readonly", "readonly");
	 	$('#confirmSenha').removeClass("greenButtonStyle");
	 	$('#editSenha').removeClass("grayButtonStyle");
	 	$('#editSenha').addClass("greenButtonStyle");
	 	$('#confirmSenha').addClass("grayButtonStyle");
	 	editSenha = false;
 	}
}

/**
 * salvarSenha
 * @param  
 */
function salvarSenha() {
 	if (editSenha) {
	 	if ($('#senhaConfirmIn').val() != $('#senhaIn').val()) {
	 		showErrorMessage({
				mensagem: "As senhas são diferentes",
				title: "Erro"
			});
	 	} else if ($('#loginIn').val() == "") {
	 		showErrorMessage({
				mensagem: "Para o cadastro do login é necessário o nome de usuário!",
				title: "Erro"
			});			
	 	} else {
	 		$.get("../UnidadeAnexo",{
	 			idUnidade: $('#unidadeId').val(), 
				senha: $('#senhaIn').val(),
				login:  $('#loginIn').val(),
				from: "0"},
				function (response) {
					location.href = '../error_page.jsp?errorMsg=' + response + 
						'&lk=application/anexo_unidade.jsp?id=' + $('#unidadeId').val();
				}
			);
	 	}
 	}
}

/**
 * generateAccess	  
 */
function generateAccess() {
 	$.get("../UnidadeAnexo",{
			idUnidade: $('#unidadeId').val(),
		from: "1"},
		function (response) {
			location.href = '../error_page.jsp?errorMsg=' + response + 
					'&lk=application/anexo_unidade.jsp?id=' + $('#unidadeId').val();
		}
	);
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
			 	$.get("../UnidadeAnexo",{
		 			idUnidade: $('#unidadeId').val(),
					from: "2"},
					function (response) {
						location.href = '../error_page.jsp?errorMsg=' + response + 
								'&lk=application/anexo_unidade.jsp?id=' + $('#unidadeId').val();
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
 	$.get("../UnidadeAnexo",{
			idUnidade: $('#unidadeId').val(),
		from: "3"},
		function (response) {
			location.href = '../error_page.jsp?errorMsg=' + response + 
					'&lk=application/anexo_unidade.jsp?id=' + $('#unidadeId').val();
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
			 	$.get("../UnidadeAnexo",{
		 			idUnidade: $('#unidadeId').val(),
					from: "5"},
					function (response) {
						location.href = '../error_page.jsp?errorMsg=' + response + 
								'&lk=application/anexo_unidade.jsp?id=' + $('#unidadeId').val();
					}
				);
				$(this).dialog('close');
			}
		} 
	});
}

/**
 * editarPorta	  
 */
function editarPorta() {
 	if (edicaoPorta) {
 		$('#portaIn').attr("readonly", "readonly");
 		$('#colunasIn').attr("readonly", "readonly");
 		$('#headerCupomIn').attr("readonly", "readonly");
 		$('#subHeaderIn').attr("readonly", "readonly");
 		$('#footerCupomIn').attr("readonly", "readonly");
 		$('#subFooterIn').attr("readonly", "readonly");	 			 		
 		$('#editPort').addClass("greenButtonStyle");
 		$('#editPort').removeClass("grayButtonStyle");
 		$('#salvePort').addClass("grayButtonStyle");
 		$('#salvePort').removeClass("greenButtonStyle");
 		edicaoPorta = false;
 	} else {
 		$('#portaIn').removeAttr("readonly");
 		$('#colunasIn').removeAttr("readonly");
 		$('#headerCupomIn').removeAttr("readonly");
 		$('#subHeaderIn').removeAttr("readonly");
 		$('#footerCupomIn').removeAttr("readonly");
 		$('#subFooterIn').removeAttr("readonly");
 		$('#editPort').addClass("grayButtonStyle");
 		$('#editPort').removeClass("greenButtonStyle");
 		$('#salvePort').addClass("greenButtonStyle");
 		$('#salvePort').removeClass("grayButtonStyle");
 		edicaoPorta = true;
 	}
}

/**
 * salvarPorta	  
 */
function salvarPorta() {
 	if (edicaoPorta) {		 	
 		$.get("../UnidadeAnexo",{
 			idUnidade: $('#unidadeId').val(), 
			porta: $('#portaIn').val(),				
			colunas: $('#colunasIn').val(),
			headerCupom: $('#headerCupomIn').val(),
			subHeader: $('#subHeaderIn').val(),
			footerCupom: $('#footerCupomIn').val(),
			subFooter: $('#subFooterIn').val(),
			from: "4"},
			function (response) {
				showMessage({
					mensagem: response,
					title: "Mensagem"
				});
			}
		);
		editarPorta();
 	}
}

/**
 * editarObs
 */
function editarObs() {	
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
 				$('#obsIn').val($('#obsw').val());
 				$.get("../UnidadeAnexo",{
 					idUnidade: $('#unidadeId').val(), 
 					obs: $('#obsw').val(),				
 					from: "6"},
					function (response) {
						showErrorMessage ({
							mensagem: response,
							title: "Edição de Observação"
						});
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

/**
 * salvarObs
 */
function salvarObs() {
	
 	if (edicaoObs) {		 	
 		$.get("../UnidadeAnexo",{
 			idUnidade: $('#unidadeId').val(), 
			obs: $('#obsIn').val(),				
			from: "6"},
			function (response) {
				showMessage({
					mensagem: response,
					title: "Mensagem"
				});
			}
		);
		editarObs();
 	}
}

function imprimeCartao() {
	var top = (screen.height - 200)/2;
	var left= (screen.width - 600)/2;
	window.open("../GeradorRelatorio?rel=132&parametros=6@" + $('#loginIn').val() , 
		'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
}

function uploadReport() {
		var top = (screen.height - 200)/2;
	var left= (screen.width - 600)/2;
	window.open('upload_logo_report.jsp?id=\'' + $('#unidadeId').val() + '\'', 'nova', 'width= 600, height= 200, top= ' + top + ', left= ' + left);
}

function uploadHeader() {
		var top = (screen.height - 200)/2;
	var left= (screen.width - 600)/2;
	window.open('upload_logo_header.jsp?id=\'' + $('#unidadeId').val() + '\'', 'nova', 'width= 600, height= 200, top= ' + top + ', left= ' + left);
}

function uploadCarteirinha() {
	//alert('Hello world!');
	var top = (screen.height - 200)/2;
	var left= (screen.width - 600)/2;
	window.open('upload_logo_carteirinha.jsp?id=\'' + $('#unidadeId').val() + '\'', 'nova', 'width= 600, height= 200, top= ' + top + ', left= ' + left);
}


function criarUsuario() {
	$('#loginIn, #senhaIn, #senhaConfirmIn').val('').removeAttr('readonly');
	$('#confirmSenha').removeClass("grayButtonStyle").addClass('greenButtonStyle');
	editSenha = true;
}

function trocaAdm() {
	$('#trocaWindow').dialog({
		modal: true,
		width: 300, 		
 		maxWidth: 800,
 		maxHeight: 400,
	 	show: 'fade',
	 	hide: 'clip',
	 	buttons: {
	 		"Cancelar" : function () {
 				$(this).dialog('close');
 			},
 			"Trocar": function() {
 				alert('troca');
			}
	 	},
	 	close: function () {
			$(this).dialog('destroy');
		}
	});
}