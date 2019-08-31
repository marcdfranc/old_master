$(document).ready(function() {
	search= function() {
		if (($("#inicioIn").val() != "") && ($("#fimIn").val() == "")) {
			showErrorMessage ({
				width: 400,
				mensagem: "É necessário o preenchimento do campo \"Fim\"!",
				title: "Campos Requeridos"
			});
		} else if (($("#fimIn").val() != "") && ($("#inicioIn").val() == "")){
			showErrorMessage ({
				width: 400,
				mensagem: "É necessário o preenchimento do campo \"Início\"!",
				title: "Campos Requeridos"
			});
		} else {
			$.get("../CustoOperacionalAdapter",{				
				unidadeId: $('#unidadeId').val(), 
				inicio: $('#inicioIn').val(),
				fim: $("#fimIn").val()},
				function(response){
					$('#dataGrid').empty();
					$('#dataGrid').append(response);
				});		 		
		}	
		return false;
	}	
	
	/*generatePdf = function() {
		if (($('#unidadeId').val() == "") || ($('#unidadeId').val() == "0")) {
			showErrorMessage ({
				width: 400,
				mensagem: "É necessário o preenchimento do campo \"Unidade\"!",
				title: "Campos Requeridos"
			});
		} else if (($("#inicioIn").val() != "") && ($("#fimIn").val() == "")) {
			showErrorMessage ({
				width: 400,
				mensagem: "É necessário o preenchimento do campo \"Fim\"!",
				title: "Campos Requeridos"
			});
		} else if ((($("#fimIn").val() != "") && ($("#inicioIn").val() == ""))
				|| (($("#fimIn").val() == "") && ($("#inicioIn").val() == ""))){
			showErrorMessage ({
				width: 400,
				mensagem: "É necessário o preenchimento do campo \"Início\"!",
				title: "Campos Requeridos"
			});
		} else {
			var top = (screen.height - 200)/2;
			var left= (screen.width - 600)/2;
			window.open("../GeradorRelatorio?rel=114&parametros=361@" + 
				$('#inicioIn').val() + "?" +  $('#fimIn').val() + "|98@" +
				$('#unidadeId').val(), 'nova', 
				'width= 800, height= 600, top= ' + top + ', left= ' + left);
		}	
	}*/
	
	$(this).ajaxStart(function(){
		showLoader();		
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
	});		
});