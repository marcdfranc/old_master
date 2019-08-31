var doc;
var isEdition= false;

$(document).ready(function(){	
	doc = new dtGrid("editedsDocumento", "deletedsDocumento", "delDoc", "edDoc", "editDoc", true);
	doc.setLocalHidden("localDocumento");
	doc.setLocalAppend("tableBoleto");
	doc.setIdHidden("rowCodigo");		
	doc.addCol("Código", "40", "rowCodigo");
	doc.addCol("Emissão", "25", "rowEmissao");
	doc.addCol("Vencimento", "10", "rowVencimento");
	doc.addCol("Valor", "25", "rowValor");
	doc.setSequence(false);		
	doc.mountHeader(false);	
	
	addRowDoc = function(param) {
	 	if ($('#codigoIn').val() != "") {
	 		$.get("../BoletoAdapter",{
	 			codigo: $('#codigoIn').val(), 
	 			from: 0},
				function (response) {		 					
					doc.addValue(getPipeByIndex(response, 0));
					doc.addValue(getPipeByIndex(response, 1));
					doc.addValue(getPipeByIndex(response, 2));
					doc.addValue(getPipeByIndex(response, 3));			
					doc.appendTable();
				}
			);
			/*doc.addValue("xuxu");
			doc.addValue("meleca");
			doc.addValue("banana");
			doc.addValue("MAÇA");			
			doc.appendTable();*/
			$('#codigoIn').val("");
		} else {
			showErrorMessage ({
				width: 400,
				mensagem: "Digite um código para inserção!",
				title: "Erro de Pesquisa"
			});
		}
		$('#codigoIn').focus();
		return false;
	}
	
	removeRowDoc= function() {
		conta.removeData();
	}
	
	baixar = function() {
	 	var i = 0;
	 	var pipeBoleto = "";
	 	var pipeLancamento = "";
	 	var codBoleto = undefined;
	 	var provisorio = [210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 
	 		222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234];
	 	while ($('#rowCodigo' + i).val() != undefined) {
 			codBoleto = parseInt($('#rowCodigo' + i).val()); 			
	 		if (codBoleto > 199999 || jQuery.inArray(codBoleto, provisorio) > -1) {
	 			pipeBoleto+= (pipeBoleto == "")? $('#rowCodigo' + i).val() :
	 				"@" + $('#rowCodigo' + i).val();
	 		} else {
	 			pipeLancamento+= (pipeLancamento == "")? $('#rowCodigo' + i).val() :
	 				"@" + $('#rowCodigo' + i).val();
	 		}
			i++;
	 	}
	 	$.get("../CadastroBoleto",{
 			codigo: $('#codigoIn').val(),
 			pipeBoleto: pipeBoleto,
 			pipeLancamento: pipeLancamento, 
 			from: 5},
			function (response) {		 					
				location.href = "../error_page.jsp?errorMsg=" + response + 
					"&lk=application/baixa_manual.jsp";
			}
		);
	}
	
	noAccess = function() {
		showErrorMessage ({
			mensagem: "Para realizar esta operação é necessário abrir o caixa.",
			title: "Acesso Negado"
		});
	}
	
	$(this).ajaxStart(function(){
		showLoader();
	});
		
	$(this).ajaxStop(function(){
		hideLoader();		
	});
});