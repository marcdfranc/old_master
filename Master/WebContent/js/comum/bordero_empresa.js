var dataGrid;

$(document).ready(function() {
	load = function(){
		dataGrid = new DataGrid();
		$('#mesBase').val(getMonth(getToday()));
		$('#vencFatura').val($('#diaVencEmpresa').val() + "/" + zeroToLeft(getMonth(getToday()), 2) +
			"/" + getYear(getToday()));	
	}
	
	generate= function(value) {
		var aux = mountPipeLine();
		if (aux == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione os lançamentos para as quais deseja gerar a fatura!",
				title: "Entrada inválida"
			});
		} else {			
		 	$("#geracao").dialog({
		 		modal: true,
		 		width: 250,
		 		minWidth: 250,
		 		show: 'fade',
		 		hide: 'clip',
		 		buttons: {
		 			"Cancelar": function() {
		 				$(this).dialog('close');
		 				$("#lancJuros [value='s']").attr("checked", "checked");		 				
						$("#cobBoleto [value='n']").attr("checked", "checked");
					},
		 			"Gerar" : function () {
		 				var aux = mountPipeLine();
						$.get("../BorderoEmpresaAdapter",{
							from: "0",
							empresaId: $('#empresaId').val(), 
							mesBase: $('#mesBase').val(),					
							anoBase: $('#anoBase').val(),
							vencimento: $('#vencFatura').val(),
							lancamentos: aux},
							function (response) {				
								if (getPart(response, 1) == "0") {
									location.href = "../error_page.jsp?errorMsg=" + getPart(response, 2) + 
										"&lk=application/empresa.jsp"
								} else {				
									location.href= "cadastro_fatura_empresa.jsp?state=1&id=" + getPart(response, 2);
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