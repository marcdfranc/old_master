var dataGrid;
var pager;
var flag= false;

$(document).ready(function() {
	load = function(){
		dataGrid = new DataGrid();
	}
	
	/**
	 * generate
	 * @param {type}  
	 */	
	
	generate= function(value) {
		var aux = mountPipeLine();
		if (aux == "") {
			showErrorMessage({
				mensagem: "Selecione as parcelas para as quais deseja gerar a fatura!",
				title: "Entrada inválida"
			});
		} else {			
			$("#geraWindow").dialog({
		 		modal: true,
		 		minWidth: 450,
		 		show: 'fade',
		 		hide: 'clip',
		 		buttons: {
		 			"Cancelar": function() {
		 				$(this).dialog('close');
					},
		 			"Gerar Fatura" : function () {
		 				$.get("../BorderoAdapter",{
							from: "1",
							idPessoa: $('#referenciaIn').val(), 
							cadastro: $('#cadastroIn').val(),					
							lancamentos: aux,
							tpPagamentoIn: $('#tpPagamento').val()},
							function (response) {				
								location.href = '../error_page.jsp?errorMsg=' + response + 
									'&lk=application/bordero_empresa_saude.jsp?id=' + $('#referenciaIn').val();
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
	
	$(this).ajaxStop(function(){
		if (pager != undefined) {
			if (parseInt($('#gridLines').val()) != pager.recordCount) {
				pager.Search();
			}
		}
		if (document.getElementById("pagerGrid").innerHTML != "" ) {
			$('#lastButton').addClass("justificaRight");		
		} else {
			$('#lastButton').removeAttr("class", "justificaRight");	
		}		  		
	});
	
	$("input[type='text']").change(function() {
		flag= true;
	});
	
	ckFunction = function(value) {
		var id = 'gridValue' + value.id.replace('ck', "");
		var i = 0;
		var valorTotal = 0;
		while($("#ck" + i).val() != undefined){
			if (document.getElementById("ck" + i).checked) {
				id = "gridValue" + document.getElementById("ck" + i).id.replace("ck", "");				
				valorTotal+= parseFloat($("#" + id).val());				
			}
			i++;
		}
		valorTotal = valorTotal + "";
		valorTotal = formatCurrency(valorTotal);		
		$("#totalSoma").empty();
		$("#totalSoma").append((valorTotal == 0)? "0.00" : valorTotal);
	}
});