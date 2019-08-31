var ctr
var isEdition= false;
var lastIndex= -1;
var isSelected = false;

$(document).ready(function(){
	/**
	 * load
	 * @param {type}  
	 */
	load = function () {
	 	ctr = new dtGrid("editedsCtr", "deletedsCtr", "delCtr", "edCtr", "editCtr", true);
	 	ctr.setLocalHidden("localCtr");
		ctr.setLocalAppend("tableCtr");
		ctr.setIdHidden("rowCtr");
		ctr.addCol("CTR", "5", "rowCtr");
	 	ctr.addCol("Funcionário", "5", "rowNome");
	 	ctr.mountHeader(false);
	}
	
	/**
	 * byPeriodo
	 * @param {type}  
	 */
	byPeriodo = function () {
		if (!isSelected) {
		 	$("#ctrSelecaoBt").addClass("cpEsconde");
		 	$("#periodoBt").addClass("cpEsconde");
			$("#bottonButton").removeClass("cpEsconde");
		 	$("#inicioIn").removeAttr("readonly");
			$("#qtdeIn").removeAttr("readonly");
			isSelected = true;
		}
	}	
	
	/**
	 * bySelecao
	 * @param {type}
	 */
	bySelecao = function () {
		if (!isSelected) {
			$("#ctrSelecaoBt").addClass("cpEsconde");
		 	$("#periodoBt").addClass("cpEsconde");
		 	$("#bottonButton").removeClass("cpEsconde");
		 	$("#ctrArea").removeClass("cpEsconde");
		 	isSelected = true;
		}
	}
	
	/**
	 * inserCtr
	 * @param {type}  
	 */
	insereCtr = function () {
		var pipe;
		var aux = "";
	 	if ($("#qtdeIn").val() != "") {
	 		if (parseInt($("#qtdeIn").val()) > 50 ) {
	 			showErrorMessage ({
					width: 374,
					mensagem: "Numero máximo de requisição por lote excedido! \n A Quantidade deve ser inferior a 51 \"CTRs\".",
					title: "Erro de Geração"
				});
	 		} else {
				$.get("../CadastroContrato",{
					byPeriodo: "s", 
					from: "0",
					unidade: $('#unidadeId').val(),
					qtde: $('#qtdeIn').val()},
					function (response) {
						if (getPart(response, 1) == "1") {
							showErrorMessage ({
								width: 400,
								mensagem: getPart(response, 2),
								title: "Erro de Geração"
							});
						} else {
							pipe = unmountPipe(getPart(response, 2));
							for(var i = 0; i < pipe.length; i++) {
								ctr.addValue(pipe[i]);
								ctr.addValue($('#nomeIn').val());
								ctr.appendTable();
							}
						}
					}
				);
	 		}

	 	} else if($("#ctrAreaIn").val() != "") {
	 		aux = virgulaToRealPipe($("#ctrAreaIn").val());
	 		pipe = unmountPipe(aux);
	 		for(var i = 0; i < pipe.length; i++) {
				ctr.addValue(pipe[i]);
				ctr.addValue($('#nomeIn').val());
				ctr.appendTable();
			}			
	 	} else {
	 		showErrorMessage ({
				width: 400,
				mensagem: getPart(response, 2),
				title: "Existem campos não preencidos no formulário."
			});
		}
	}
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	
	$(this).ajaxStop(function(){
		hideLoader();
	});	
	
});