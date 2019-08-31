load= function(isEd) {
	if (isEd) {
		refreshValues();		
	}
}


refreshValues= function() {	
	percent= parseFloat(getPart($('#unidadeIdIn').val(), 1)) / 100;
	result= parseFloat($('#vlrClienteIn').val()) - parseFloat($('#operacionalIn').val());
	$('#holdIn').val(formatDecimal(round(result * percent,2)));
	$('#vlrUnidadeIn').val(formatDecimal(round(result - (result * percent),2)));
}

$(document).ready(function() {
	$('#operacionalIn').blur(function() {
		if ($('#vlrClienteIn').val() != "0.00" && $('#unidadeIdIn').val() != "") {			
			refreshValues();
		}
	});	
	
	$('#vlrClienteIn').blur(function() {		
		if ($('#operacionalIn').val() != "0.00" && $('#unidadeIdIn').val() != "") {
			refreshValues();
		}
	});
	
	$('#unidadeIdIn').change(function () {
		if (($('#operacionalIn').val() != "0.00") && ($('#vlrClienteIn').val() != "0.00")) {			
			refreshValues();
		}
		if($('#unidadeIdIn').val() == "") {
			$('#unidadeIn').val("");
		} else {
			$.get("../CadastroTabela",{
				from: "1",
				unidadeId: getPart($('#unidadeIdIn').val(), 2)},
				function (response) {
					var arrayAux = unmountPipe(response);
					var out= "<option value=\"\">Selecione</option>"					
					for(var i = 0; i < arrayAux.length; i++) {
						if (i == 0) {
							$('#unidadeIn').val(arrayAux[i]);
						}  else {
							out+= "<option value=\"" + getPart(arrayAux[i], 1) +"\">" + 
								getPart(arrayAux[i], 2) + "</option>"
						}												
					}
					$("#tabelaIn").empty();
					$("#tabelaIn").append(out);
				}
			);
		}		
	});
	
	processar = function (tipo) {
		isOk = true;
		if (tipo == 'e') {
			showOption({
				title: "Bloqueio",
				mensagem: "Tem certeza que deseja excluir este registro?",
				icone: "w",
				width: 400,
				show: 'fade',
		 		hide: 'clip',
				buttons: {
					"Não": function() {
						$(this).dialog('close');
						isOk = false;
					},
					"Sim": function () {
					 	isOk = true;
						$(this).dialog('close');
					}
				} 
			});
		}
		if (isOk) {
			$('#tipoSubmit').val(tipo)
	 		document.forms["formPost"].submit();
		}
	}
	
	$('#refServicoIn').blur(function() {		
		for(var i = 0; i < document.getElementById("servicoIn").options.length; i++) {
			if ($('#refServicoIn').val() == getPipeByIndex(document.getElementById("servicoIn").options[i].value, 1)) {
				document.getElementById("servicoIn").options[i].selected = true;
			}
		}
		especialidadeComp();
	});
	
	$('#especialidadeIn').change(function () {
 		$.get("../CadastroTabela",{
 			idEspecialidade: $('#especialidadeIn').val(), 
			from: "2"},
			function (response) {
				$('#servicoIn').empty();
				$('#servicoIn').append(response);
				document.getElementById("servicoIn").selectedIndex= 0;					
		});
	});
	
	especialidadeComp = function() {
		for(var i = 0; i < document.getElementById("especialidadeIn").options.length; i++) {
			if (document.getElementById("especialidadeIn").options[i].value == getPipeByIndex($('#servicoIn').val(), 2)) {
				document.getElementById("especialidadeIn").options[i].selected = true;
			}
		}
	}
	
	
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
	
	ckPerfil = function() {
		return $('#perfil').val() == 'a' || $('#perfil').val() == 'f';
	}
	
	noAccess = function () {
		showErrorMessage ({
			width: 400,
			mensagem: "Você não tem permissão suficiente para realizar esta operação!",
			title: "Erro"
		});
	}
});

