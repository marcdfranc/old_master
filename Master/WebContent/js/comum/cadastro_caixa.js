
 function fecharCaixa() {
 	$("#fechaCaixa").dialog({
 		modal: true,
 		width: 294,
 		minWidth: 240,
 		show: 'fade',
		hide: 'clip',
 		buttons: {
 			"Cancelar": function() {
 				$(this).dialog('close');
			},
 			"Fechar Caixa" : function () {
				$.get("../CadastroCaixa",{
					isFilter: "1",												
					valorFinal: $('#valorFechamento').val(),
					tpPagamento: $('#tpPagamento').val(),
					id: $('#codigoIn').val(),
					from: "2"},
					function (response) {
						if (response != "0") {
							location.href = "caixa.jsp"
						} else {								
							location.href = '../error_page.jsp?errorMsg=Ocorreu um erro durante o fechamento do caixa!' + 
								'&lk=application/caixa.jsp';							
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

 
pdfGenerate = function () {
 	var top = (screen.height - 600)/2;
	var left= (screen.width - 800)/2;
	window.close();
	window.open("../GeradorRelatorio?rel=133&parametros=9@" + $('#codigoIn').val(), 
		'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
} 

bloquear = function(tipo) {
	var msg = "";
	if (tipo == 'p') {
		msg = "Não é possível imprimir demonstrativos de caixas anteriores!";
	} else {
		msg = "Caixa bloqueado, contate o administrador da unidade para liberação.";
	}
	showErrorMessage ({
		width: 450,
		mensagem: msg,
		title: "Caixa Bloqueado"
	});
}