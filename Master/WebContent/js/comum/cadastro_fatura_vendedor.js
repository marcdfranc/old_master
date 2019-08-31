
	
/**
 * pdfGenerate
 * @param {type}  
 */
function pdfGenerate() {	 	
 	var top = (screen.height - 600)/2;
	var left= (screen.width - 800)/2;
	window.close();
	window.open("../GeradorRelatorio?rel=81&parametros=101@" + $("#faturaId").val(), 'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
}

function reproc() {
	showOption({
		title: "Aviso",
		mensagem: "Tem certeza que deseja excluir esta fatura?",
		icone: "w",
		width: 400,
		show: 'fade',
		hide: 'clip',
		buttons: {
			"Não": function() {
				$(this).dialog('close');
			},
			"Sim": function () {
				$.get("../CadastroFaturaVendedor", {
					from: '1',
					id: $('#faturaId').val()},
					function(response) {
						if (response == "0") {
							showErrorMessage({
								width: 400,
								mensagem: "Fatura excluida com sucesso!",
								title: "Erro de Cadastro"
							});
						} else {
							showErrorMessage({
								width: 400,
								mensagem: "Não foi possível cadastrar o evento devido a um erro interno!",
								title: "Erro de Cadastro"
							});
						}
						location.href = "funcionario.jsp";
					}
				);			
				$(this).dialog('close');
			}
		} 
	});
}
