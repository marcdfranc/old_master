var pager;
var flag= false;
var dataGrid;

$(document).ready(function() {	
	load= function () {
		pager = new Pager($('#gridLines').val(), 12, "../CadastroFaturaEmpresa");
		pager.mountPager();
		dataGrid = new DataGrid();
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
	}	
	
	pag = function() {
		aux = mountPipeLine();		
		if (aux == "") {
			alert("Selecione os pagamentos que deseja efetuar.");
		} else {
			$.get("../CadastroFaturaEmpresa",{
				from: "1",
				dataBase: $('#now').val(),
				pipe: aux
				},
				function(response){
					if(response == "0") {
						alert("Ocorreu um erro durante o pagamento das parcelas.\n" +
						"Contate o administrador do sistema para maiores esclarecimentos.")
					} else {
						$('#dataBank').empty();
						$('#dataBank').append(response);
					}
			});			
		}		
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