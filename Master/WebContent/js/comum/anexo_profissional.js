var editSenha = false;
var edicaoPorta = false;

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

function novoLogin() {
	editSenha = true;
	salvarSenha();
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
	 		$.get("../ProfissionalAnexo",{
	 			idProfissional: $('#registroIn').val(), 
				senha: $('#senhaIn').val(),
				login:  $('#loginIn').val(),
				from: "0"},
				function (response) {
					location.href = '../error_page.jsp?errorMsg=' + response + 
					'&lk=application/anexo_profissional.jsp?id=' + $('#registroIn').val();
				}
			);
	 	}
 	}
}

/**
 * generateAccess	  
 */
function generateAccess() {
 	$.get("../ProfissionalAnexo",{
			idProfissional: $('#registroIn').val(),
		from: "1"},
		function (response) {
			location.href = '../error_page.jsp?errorMsg=' + response + 
					'&lk=application/anexo_profissional.jsp?id=' + $('#registroIn').val();
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
			 	$.get("../ProfissionalAnexo",{
		 			idProfissional: $('#registroIn').val(),
					from: "2"},
					function (response) {
						location.href = '../error_page.jsp?errorMsg=' + response + 
								'&lk=application/anexo_profissional.jsp?id=' + $('#registroIn').val();
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
 	$.get("../ProfissionalAnexo",{
			idProfissional: $('#registroIn').val(),
		from: "3"},
		function (response) {
			location.href = '../error_page.jsp?errorMsg=' + response + 
					'&lk=application/anexo_profissional.jsp?id=' + $('#registroIn').val();
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
			 	$.get("../ProfissionalAnexo",{
		 			idProfissional: $('#registroIn').val(),
					from: "5"},
					function (response) {
						location.href = '../error_page.jsp?errorMsg=' + response + 
								'&lk=application/anexo_profissional.jsp?id=' + $('#registroIn').val();
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
 		$('#editPort').addClass("greenButtonStyle");
 		$('#editPort').removeClass("grayButtonStyle");
 		$('#salvePort').addClass("grayButtonStyle");
 		$('#salvePort').removeClass("greenButtonStyle");
 		edicaoPorta = false;
 	} else {
 		$('#portaIn').removeAttr("readonly");
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
 		$.get("../ProfissionalAnexo",{
 			idProfissional: $('#registroIn').val(), 
			porta: $('#portaIn').val(),				
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
 				$('#obsIn').val($('#obsw').val());
 				$.get("../ProfissionalAnexo",{
 					idProfissional: $('#registroIn').val(), 
 					obs: $('#obsw').val(),				
 					from: "6"},
					function (response) {
						showMessage ({
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

function imprimeCartao() {
	var top = (screen.height - 200)/2;
	var left= (screen.width - 600)/2;
	window.open("../GeradorRelatorio?rel=132&parametros=6@" + $('#loginIn').val() , 
		'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
}