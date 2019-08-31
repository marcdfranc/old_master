$(document).ready(function() {	
	$('#unidadeIdIn').change(function () {		
		$.get("../FuncionarioGet",{from: "0",			
				unidadeId: getPart($('#unidadeIdIn').val(), 2)},
			function (response) {		
				$('#unidadeIn').val(response);
			});	
	});
	
	$('#setorIn').change(function() {
		if($('#setorIn').val() != "") {
			$.get("../FuncionarioGet",{setorIn: $('#setorIn').val(), 
				from: "4"},
				function (response) {
					$('#especialidadeIn').empty();
					$('#especialidadeIn').append(response);
					document.getElementById("especialidadeIn").selectedIndex= 0;					
			});
		}
	});
	
	/**
	 * noAccess
	 * @param {type}  
	 */
	noAccess = function() {
		showWarning({
			mensagem: "Não é possível a edição de procedimentos.",
			title: "Acesso Negado"
		});
	}
});

