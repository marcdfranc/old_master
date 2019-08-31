$(document).ready(function() {	
	
	
	$('#unidadeId').change(function () {
		if ($(this).val() != "0") {
			$.get("../CobrancaAdapter", {
				from: "1",
				unidadeId: $(this).val()}, 
				function(response) {
					var aux = $(response).find("cadastrados").text(); 
					$('#cadastrados').text(aux);
					
					aux = $(response).find("ativos").text();					
					$('#ativos').text(aux);
					
					aux = $(response).find("bloqueados").text();					
					$('#bloqueados').text(aux);
					
					aux = $(response).find("cancelados").text();					
					$('#cancelados').text(aux);
					
					aux = $(response).find("ativos").text();					
					$('#ativos').text(aux);
					
					aux = $(response).find("ativos").text();					
					$('#ativos').text(aux);
					
					for(var i=0; i <= 6; i++) {
						if (i == 0) {
							aux = $(response).find("carteira0").text();					
							$('#adimplentes').text(aux);
						} else {
							aux = $(response).find("carteira" + i).text();					
							$('#c' + i).text(aux);
						}

					}
				}
			);
		}	
	});
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
	});
	
});