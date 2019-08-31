var pager;
var flag= false;

$(document).ready(function() {
	
	load = function() {
 		pager = new Pager($('#gridLines').val(), 30, "../CobrancaAdapter");
		pager.mountPager();	
 	}
	
	getNext = function(){		
		if (flag) {
			flag= false;
			search();
		} else {
			if ((pager.limit * pager.currentPage) < pager.recordCount) {
				$.get("../CobrancaAdapter",{
					gridLines: pager.limit , 
					limit: pager.limit, 
					isFilter: "0", 
					offset: pager.offSet + pager.limit, 
					from: "0",
					dias: $('#diasCarteira').val(),
					referenciaIn: $('#referenciaIn').val(), 
					nomeIn: $('#nomeIn').val(),
					cpfIn: $('#cpfIn').val(), 
					nascimentoIn: $('#nascimentoIn').val(),
					telIn: $('#telIn').val(),
					plano: $('#planoIn').val(),
					ativoChecked: $('#ativoChecked').val(),					
					unidadeId: $('#unidadeId').val()},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.nextPage();
			}			
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if (pager.offSet > 0) {
				$.get("../CobrancaAdapter",{
					gridLines: pager.limit, 
					limit: pager.limit,	
					isFilter: "0",
					offset: pager.offSet - pager.limit, 
					from: "0",
					dias: $('#diasCarteira').val(),
					referenciaIn: $('#referenciaIn').val(), 
					nomeIn: $('#nomeIn').val(),
					cpfIn: $('#cpfIn').val(),
					nascimentoIn: $('#nascimentoIn').val(), 
					telIn: $('#telIn').val(),
					plano: $('#planoIn').val(),
					ativoChecked: $('#ativoChecked').val(),					
					unidadeId: $('#unidadeId').val()},
					function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);
				});
				pager.previousPage();
			}			
		}
	}
	
	search= function() {
		$.get("../CobrancaAdapter",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1", 
			from: "0",
			dias: $('#diasCarteira').val(),
			referenciaIn: $('#referenciaIn').val(), 
			nomeIn: $('#nomeIn').val(),
			cpfIn: $('#cpfIn').val(),
			nascimentoIn: $('#nascimentoIn').val(), 
			telIn: $('#telIn').val(),
			plano: $('#planoIn').val(),
			ativoChecked: $('#ativoChecked').val(),					
			unidadeId: $('#unidadeId').val()},
			function(response){
				$('#dataBank').empty();
				$('#dataBank').append(response);				
			});		
		return false;
	}
	
	
	renderize= function(value) {
		if (flag) {
			flag= false;
			search();
		} else {
			pager.sortOffSet(value);
			$.get("../CobrancaAdapter",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: pager.offSet, 
			isFilter: "0", 
			from: "0",
			dias: $('#diasCarteira').val(),
			referenciaIn: $('#referenciaIn').val(), 
			nomeIn: $('#nomeIn').val(),
			cpfIn: $('#cpfIn').val(),
			nascimentoIn: $('#nascimentoIn').val(), 
			telIn: $('#telIn').val(),
			plano: $('#planoIn').val(),
			ativoChecked: $('#ativoChecked').val(),					
			unidadeId: $('#unidadeId').val()},
			function(response) {
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
		}
	}
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
		if (pager != undefined) {
			if (parseInt($('#gridLines').val()) != pager.recordCount) {
				pager.Search();
			}
		}
	});
	
	pdfGenerate = function (base) {
 		if ($('#unidadeId').val() == "") {
 			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma unidade para fazer a impressão!",
				title: "Entrada inválida"
			});
 		} else {
 			$("#relWindow").dialog({
		 		modal: true,
		 		width: 250,
		 		minWidth: 250,
		 		buttons: {
		 			"Cancelar": function() {
		 				$(this).dialog('close');
					},
		 			"Ok" : function () {
				 		var top = (screen.height - 600)/2;
						var left= (screen.width - 800)/2;
						var inicio = 0;
						if (base == 180) {
							base = 999999;
							inicio = 150
						} else {
							inicio = (base == 30)? 1 : parseInt(base) - 30; 
						}		
						if ($('#modalidade').val() == 'm') {
							window.open("../GeradorRelatorio?rel=131&parametros=5@" + inicio + "?" + base +
								"|99@" + $('#unidadeId').val(), 'nova', 
								'width= 800, height= 600, top= ' + top + ', left= ' + left);				
						} else {
							window.open("../GeradorRelatorio?rel=186&parametros=337@" + inicio + "?" + base +
								"|335@" + $('#unidadeId').val(), 'nova', 
								'width= 800, height= 600, top= ' + top + ', left= ' + left);
						}
						$(this).dialog('close');
		 			}		 			
		 		},
		 		close: function() {
		 			$(this).dialog('destroy');
		 		}
		 	});
		}
 	}
	
});