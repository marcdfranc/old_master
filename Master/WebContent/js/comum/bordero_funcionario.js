$(document).ready(function() {	
	/**
	 * generate
	 * @param {type}  
	 */
	generate = function () {
	 	var aux = mountPipeLine();
	 	if (aux == "") {
			showErrorMessage("Selecione os contratos para as quais deseja gerar a fatura!", 
				"Entrada inválida", 150, 450, false);
		} else {		
			$.get("../CadastroContrato",{
				from: "1",
				cadastro: $('#requisicaoIn').val(),
				contratos: aux},
				function (response) {				
					if (response == "-1") {
						showErrorMessage("ocorreu um erro durante a geração da fatura de Contrato.", "Erro", 150, 500, false);
					} else {				
						location.href= "fatura_vendedor.jsp?id=" + $("#funcionarioId").val();
					}
				}
			);
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
		$("#totalSoma").append(valorTotal);
	}
	
});