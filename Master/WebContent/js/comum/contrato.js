$(document).ready(function() {	
	/**
	 * generate
	 * @param {type}  
	 */
	delCtr = function () {
	 	var aux = mountPipeLine();
	 	if (aux == "") {
	 		showErrorMessage ({
				mensagem: "Selecione os contratos que deseja excluir!",
				title: "Entrada inválida"
			});
		} else {		
		 	showOption({
				title: "Bloqueio",
				mensagem: "Tem certeza que deseja excluir os registros selecionados?",
				icone: "w",
				width: 400,
				show: 'fade',
		 		hide: 'clip',
				buttons: {
					"Não": function() {
						$(this).dialog('close');
					},
					"Sim": function () {
					 	$.get("../CadastroContrato",{
							from: "2",
							contratos: aux},
							function (response) {				
								if (response == "-1") {
									showErrorMessage ({
										mensagem: "Ocorreu um erro durante a exclusão dos Contratos.",
										title: "Erro"
									});
								} else {				
									location.href= "fatura_vendedor.jsp?id=" + $("#funcionarioId").val();
								}
							}
						);
						$(this).dialog('close');
					}
				} 
			});
		}
	}
	
	emitContrato = function() {
	 	var aux = mountPipeLine();
	 	if (aux == "") {
	 		showErrorMessage ({
				mensagem: "Selecione os contratos que deseja imprimir!",
				title: "Entrada inválida"
			});
	 	} else {
	 		var top = (screen.height - 600)/2;
			var left = (screen.width - 800)/2;
	 		window.open("../CadastroContrato?from=3&idUnidade=" + $('#idUnidade').val() + 
	 		"&contratos=" + aux, 'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
	 	}
	}
	
	selectAll = function() {
		aux = -1;
		while ($('#ck' + (++aux)).val() != undefined) {
			if (!document.getElementById("ck" + aux).checked) {
				document.getElementById("ck" + aux).checked = true;				
			} else {
				document.getElementById("ck" + aux).checked = false;
			}
		}
		ckFunction(document.getElementById("ck" + (--aux)));
	}
	
	mountPipeLine = function() {
		aux = -1;
		pipe = "";
		isFirst = true;
		while($('#ck' + (++aux)).val() != undefined) {
			if (document.getElementById("ck" + aux).checked) {
				if (isFirst) {
					isFirst = false;
					pipe+= $('#ck' + (aux)).val();				
				} else {
					pipe+= "@" + $('#ck' + (aux)).val();
				}
			}
		}
		return pipe;
	}
	
});