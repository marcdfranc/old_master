var editSenha = false;
var edicaoPorta = false;
var edicaoObs = false;

$(document).ready(function() {
	
	/**
	 * editarSenha	 
	 */
	editarSenha = function() {
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
	salvarSenha = function() {
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
		 		$.get("../EmpresaSaudeAnexo",{
		 			idEmpresaSaude: $('#registroIn').val(), 
					senha: $('#senhaIn').val(),
					login:  $('#loginIn').val(),
					from: "0"},
					function (response) {
						location.href = '../error_page.jsp?errorMsg=' + response + 
							'&lk=application/anexo_empresa_saude.jsp?id=' + $('#registroIn').val();
					}
				);
		 	}
	 	}
	}
	
	/**
	 * generateAccess	  
	 */
	generateAccess = function() {
	 	$.get("../EmpresaSaudeAnexo",{
 			idEmpresaSaude: $('#registroIn').val(),
			from: "1"},
			function (response) {
				location.href = '../error_page.jsp?errorMsg=' + response + 
						'&lk=application/anexo_empresa_saude.jsp?id=' + $('#registroIn').val();
			}
		);
	}
	
	/**
	 * BloquearCartao	 
	 */
	BloquearCartao = function() {
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
				 	$.get("../EmpresaSaudeAnexo",{
			 			idEmpresaSaude: $('#registroIn').val(),
						from: "2"},
						function (response) {
							location.href = '../error_page.jsp?errorMsg=' + response + 
									'&lk=application/anexo_empresa_saude.jsp?id=' + $('#registroIn').val();
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
	liberarCartao = function() {	 	
	 	$.get("../EmpresaSaudeAnexo",{
 			idEmpresaSaude: $('#registroIn').val(),
			from: "3"},
			function (response) {
				location.href = '../error_page.jsp?errorMsg=' + response + 
						'&lk=application/anexo_empresa_saude.jsp?id=' + $('#registroIn').val();
			}
		);
	}
	
	/**
	 * delCartao	  
	 */
	delCartao = function() {
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
				 	$.get("../EmpresaSaudeAnexo",{
			 			idEmpresaSaude: $('#registroIn').val(),
						from: "5"},
						function (response) {
							location.href = '../error_page.jsp?errorMsg=' + response + 
									'&lk=application/anexo_empresa_saude.jsp?id=' + $('#registroIn').val();
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
	editarPorta = function() {
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
	salvarPorta = function() {
	 	if (edicaoPorta) {		 	
	 		$.get("../EmpresaSaudeAnexo",{
	 			idEmpresaSaude: $('#registroIn').val(), 
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
	editarObs = function() {
	 	if (edicaoObs) {
	 		$('#obsIn').attr("readonly", "readonly");
	 		$('#editObs').addClass("greenButtonStyle");
	 		$('#editObs').removeClass("grayButtonStyle");
	 		$('#salveObs').addClass("grayButtonStyle");
	 		$('#salveObs').removeClass("greenButtonStyle");
	 		edicaoObs = false;
	 	} else {
	 		$('#obsIn').removeAttr("readonly");
	 		$('#editObs').addClass("grayButtonStyle");
	 		$('#editObs').removeClass("greenButtonStyle");
	 		$('#salveObs').addClass("greenButtonStyle");
	 		$('#salveObs').removeClass("grayButtonStyle");
	 		edicaoObs = true;
	 	}
	}
	
	/**
	 * salvarObs
	 */
	salvarObs = function() {
	 	if (edicaoObs) {		 	
	 		$.get("../EmpresaSaudeAnexo",{
	 			idEmpresaSaude: $('#registroIn').val(), 
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
	
	imprimeCartao = function () {
		var top = (screen.height - 200)/2;
		var left= (screen.width - 600)/2;
		window.open("../GeradorRelatorio?rel=132&parametros=6@" + $('#loginIn').val() , 
			'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
	}
	
});