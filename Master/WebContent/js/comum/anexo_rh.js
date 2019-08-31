var editSenha = false;
var edicaoPorta = false;

$(document).ready(function() {

	if ($('#senhaConfirmIn').val() == "" && $('#senhaIn').val() == "" && $('#loginIn').val() == "") {
		editSenha = true;
	}

});

/**
 * editarSenha
 */
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
	if (!editSenha) {
		if ($('#senhaConfirmIn').val() != $('#senhaIn').val()) {
			showErrorMessage({
				mensagem : "As senhas são diferentes",
				title : "Erro"
			});
		} else if ($('#loginIn').val() == "") {
			showErrorMessage({
				mensagem : "Para o cadastro do login é necessário o nome de usuário!",
				title : "Erro"
			});
		} else {
			$.get("../RHAnexo", {
				idRh : $('#registroIn').val(),
				senha : $('#senhaIn').val(),
				login : $('#loginIn').val(),
				isAdm: $('#isAdm').val(),
				idUnidade: $('#idUnidade').val(),
				from : "0"
			}, function(response) {
				location.href = '../error_page.jsp?errorMsg=' + response + '&lk=application/anexo_rh.jsp?id=' + $('#registroIn').val();
			});
		}
	}
}

/**
 * generateAccess
 */
function generateAccess() {
	$.get("../RHAnexo", {
		idRh : $('#registroIn').val(),
		tipo : 'f',
		from : "1"
	}, function(response) {
		location.href = '../error_page.jsp?errorMsg=' + response + '&lk=application/anexo_rh.jsp?id=' + $('#registroIn').val();
	});
}

/**
 * BloquearCartao
 */
function BloquearCartao() {
	showOption({
		title : "Bloqueio",
		mensagem : "Tem certeza que deseja bloquear o cartão deste usuário?",
		icone : "w",
		width : 400,
		show : 'fade',
		hide : 'clip',
		buttons : {
			"Não" : function() {
				$(this).dialog('close');
			},
			"Sim" : function() {
				$.get("../RHAnexo", {
					idRh : $('#registroIn').val(),
					tipo : 'f',
					from : "2"
				}, function(response) {
					location.href = '../error_page.jsp?errorMsg=' + response + '&lk=application/anexo_rh.jsp?id=' + $('#registroIn').val();
				});
				$(this).dialog('close');
			}
		}
	});
}

/**
 * liberarCartao
 */
function liberarCartao() {
	$.get("../RHAnexo", {
		idRh : $('#registroIn').val(),
		tipo : 'f',
		from : "3"
	}, function(response) {
		location.href = '../error_page.jsp?errorMsg=' + response + '&lk=application/anexo_rh.jsp?id=' + $('#registroIn').val();
	});
}

/**
 * delCartao
 */
function delCartao() {
	showOption({
		title : "Bloqueio",
		mensagem : "Tem certeza que deseja excluir o cartão de acesso deste usuário?",
		icone : "w",
		width : 400,
		show : 'fade',
		hide : 'clip',
		buttons : {
			"Não" : function() {
				$(this).dialog('close');
			},
			"Sim" : function() {
				$.get("../RHAnexo", {
					idRh : $('#registroIn').val(),
					tipo : 'f',
					from : "5"
				}, function(response) {
					location.href = '../error_page.jsp?errorMsg=' + response + '&lk=application/anexo_rh.jsp?id=' + $('#registroIn').val();
				});
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
		$.get("../RHAnexo", {
			idRh : $('#registroIn').val(),
			porta : $('#portaIn').val(),
			colunas : $('#colunasIn').val(),
			headerCupom : $('#headerCupomIn').val(),
			subHeader : $('#subHeaderIn').val(),
			footerCupom : $('#footerCupomIn').val(),
			subFooter : $('#subFooterIn').val(),
			from : "4"
		}, function(response) {
			showMessage({
				mensagem : response,
				title : "Mensagem"
			});
		});
		editarPorta();
	}
}

/**
 * editarObs
 */
function editarObs() {
	$('#obsw').removeAttr("readOnly", "readOnly");
	$('#obsWindow').dialog({
		modal : true,
		width : 800,
		minWidth : 790,
		maxWidth : 800,
		maxHeight : 483,
		show : 'fade',
		hide : 'clip',
		buttons : {
			"Cancelar" : function() {
				$(this).dialog('close');
			},
			"Salvar" : function() {
				oldText = $('#obsIn').val();
				$('#obsIn').val($('#obsw').val());
				$.get("../RHAnexo", {
					idRh : $('#registroIn').val(),
					obs : $('#obsw').val(),
					from : "6"
				}, function(response) {
					if (response == "0") {
						showErrorMessage({
							mensagem : "Ocorreu um erro durante o processo de salvamento da observação!",
							title : "Edição de Observação"
						});
						$('#obsIn').val(oldText);
						$('#obsw').val(oldText);
					} else {
						showMessage({
							mensagem : "Observação salva com sucesso!",
							title : "Edição de Observação"
						});
					}
				});
				$(this).dialog('close');
			}
		},
		close : function() {
			$(this).dialog('destroy');
		}
	});
}

function imprimeCartao() {
	var top = (screen.height - 200) / 2;
	var left = (screen.width - 600) / 2;
	window.open("../GeradorRelatorio?rel=132&parametros=6@" + $('#loginIn').val(), 'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
}