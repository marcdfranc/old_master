var isEdition = false;

function makeObs() {
	editObservacao();
}

function editObservacao() {
	if (isEdition) {
		$.get("../CadastroFaturaFranchising",{
			obs: $('#obsIn').val(), 
			faturaId: removeZeroToLeft($('#codigoIn').val()), 
			from: "1"},
			function (response) {
				if (response != "0") {
					showErrorMessage ({
						mensagem: "Ocorreu um erro durante o processo de salvamento da observação!",
						title: "Edição de Observação"
					});
				}
				isEdition = false;
				$('#editObs').removeAttr("disabled", "disabled");
				$('#saveObs').attr({disabled : "disabled"});
				$('#obsIn').attr({readOnly: "readOnly"});
				$('#editObs').removeClass("grayButtonStyle");
				$('#saveObs').removeClass("greenButtonStyle");
				$('#editObs').addClass("greenButtonStyle");
				$('#saveObs').addClass("grayButtonStyle");
				$('#obsw').val($('#obsIn').val());
			}
		);
	} else {
		isEdition = true;
		$('#obsIn').removeAttr("readOnly", "readOnly");
		$('#saveObs').removeAttr("disabled", "disabled");
		$('#editObs').attr({disabled : "disabled"});
		$('#editObs').removeClass("greenButtonStyle");
		$('#saveObs').removeClass("grayButtonStyle");
		$('#editObs').addClass("grayButtonStyle");
		$('#saveObs').addClass("greenButtonStyle");
	}
}

function showNovoWd() {
	$('#novoWindow').dialog({
		modal: true,
	 	width: 650,
	 	minWidth: 450,
	 	show: 'fade',
		hide: 'clip',
	 	buttons: {
 			"Salvar": function() {
 				if ($('#itTabela').val() == "") {
 					showErrorMessage ({
						width: 400,
						mensagem: "Selecione um ítem para ser inserido!",
						title: "Erro de Inserção"
					});
 				} else if (getPart($('#itTabela').val(), 2) == "h" 
					&& ($('#itInicio').val() == "" || $('#itFim').val() == "")) {
					showErrorMessage ({
						width: 400,
						mensagem: "É necessário o preenchimento dos horários de início e fim do serviço!",
						title: "Erro de Inserção"
					});
				} else if (getPart($('#itTabela').val(), 2) == "q" && $('#itQtde').val() == ""){
					showErrorMessage ({
						width: 400,
						mensagem: "É necessário o preenchimento da quantidade solicitada!",
						title: "Erro de Inserção"
					});
				} else {
	 				$.get("../CadastroFaturaFranchising", {
	 					tipo: getPart($('#itTabela').val(), 2),
	 					tabelaId: getPart($('#itTabela').val(), 1),
	 					faturaId: $('#codigoIn').val(),
	 					unidadeId: $('#unidadeId').val(),
	 					qtde: $('#itQtde').val(),
	 					inicio: $('#itInicio').val(),
	 					fim: $('#itFim').val(),
	 					from: "2"}, 
	 					function(response) {
	 						location.href = response;
	 					}
	 				);					
				} 				
 				$(this).dialog('close');
 			},
 			"Cancelar": function () {
				$(this).dialog('close');
			}
	 	},
	 	close: function () {
			$(this).dialog('destroy');
		}
	});
}

$(document).ready(function() {
	$('#openObs').click(function (param) {
		if (isEdition) {
			$('#obsw').removeAttr("readOnly", "readOnly");
			$('#obsWindow').dialog({
				modal: true,
			 	width: 650,
			 	minWidth: 450,
			 	show: 'fade',
		 		hide: 'clip',
			 	buttons: {
		 			"Salvar": function() {
		 				$('#obsIn').val($('#obsw').val());
		 				$.get("../CadastroFaturaFranchising",{
		 					obs: $('#obsw').val(),
							faturaId: removeZeroToLeft($('#codigoIn').val()),
							from: "1"},
							function (response) {
								if (response != "0") {
									showErrorMessage ({
										mensagem: "Ocorreu um erro durante o processo de salvamento da observação!",
										title: "Edição de Observação"
									});
								}
								isEdition = false;
								$('#editObs').removeAttr("disabled", "disabled");
								$('#saveObs').attr({disabled : "disabled"});
								$('#obsIn').attr({readOnly: "readOnly"});
								$('#editObs').removeClass("grayButtonStyle");
								$('#saveObs').removeClass("greenButtonStyle");
								$('#editObs').addClass("greenButtonStyle");
								$('#saveObs').addClass("grayButtonStyle");
							}
						);
		 				$(this).dialog('close');
					},
				 	close: function (param) {
						$(this).dialog('destroy');		
					}
			 	}
			});			
		} else {
			$('#obsw').attr({readOnly: "readOnly"});
			$('#obsWindow').dialog({
				modal: true,
			 	width: 650,
			 	minWidth: 450,
			 	show: 'fade',
		 		hide: 'clip',
			 	buttons: {
		 			"Fechar": function() {
		 				$(this).dialog('close');
					}
			 	},
			 	close: function (param) {
					$(this).dialog('destroy');		
				}
			 	
			});	
		}

	});
	
	$('#itTabela').change(function () {
		if (getPart($(this).val(), 2) == 'h') {
			$('#itenQtde').addClass('cpEscondeWithHeight');
			$('#itenHora').removeClass('cpEscondeWithHeight');			
		} else if (getPart($(this).val(), 2) == 'q') {
			$('#itenQtde').removeClass('cpEscondeWithHeight');
			$('#itenHora').addClass('cpEscondeWithHeight');
		} else {
			$('#itenQtde').addClass('cpEscondeWithHeight');
			$('#itenHora').addClass('cpEscondeWithHeight');
		}
	});
	
});