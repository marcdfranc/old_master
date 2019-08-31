

$(document).ready(function() {	
	/**
	 * saveLanc
	 * @param {type} 
	 */
	saveLanc = function() {
		
	 	if (getPart($("#tipoPagamento").val(), 2) == "s") {
	 		showPrompt("Digite o título a ser conciliado.", "Conciliação", 
	 			"Título", 180, 500, 300, 'd', OK, false, function(btn, text) {
					if (btn == 'o') {
						$("#numTitulo").val(text);	 					
						if (validForm(document.forms["formPost"])) {
							$("form#formPost").submit();	 						
						}
					}
				}
			);
	 	} else {
	 		if (validForm(document.forms["formPost"])) {
				$("form#formPost").submit();	 						
			}
	 	} 
	}
	
	noAccess = function() {
		showWarning("Para realizar esta operação é necessário abrir o caixa.",
		 		"Acesso Negado", 130, 500, false);
	}	
});