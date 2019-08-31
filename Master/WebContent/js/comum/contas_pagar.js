var pager;
var flag= false;

$(document).ready(function() {	
	load= function () {		
		pager = new Pager($('#gridLines').val(), 30, "../ContaReceber");
		pager.mountPager();	
	}
	
	getNext = function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if ((pager.limit * pager.currentPage) < pager.recordCount) {
				$.get("../ContaReceber",{
					gridLines: pager.limit,
					limit: pager.limit,
					isFilter: "0",
					offset: pager.offSet + pager.limit,
					from: "1",
					lancamento: $('#lancamentoIn').val(),
					documento: $('#documentoIn').val(),
					descricao: $('#descricaoIn').val(),					
					unidadeId: ($('#unidadeId').val() == "Selecione") ? "" : $('#unidadeId').val(),
					statusLancamento: $('#status').val()
				},
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
				$.get("../ContaReceber",{
					gridLines: pager.limit, 
					limit: pager.limit,	
					isFilter: "0",
					offset: pager.offSet - pager.limit,
					from: "1",
					lancamento: $('#lancamentoIn').val(),	
					documento: $('#documentoIn').val(),
					descricao: $('#descricaoIn').val(),
					unidadeId: ($('#unidadeId').val() == "Selecione") ? "" : $('#unidadeId').val(),
					statusLancamento: $('#status').val()					
					},
					function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);
				});
				pager.previousPage();
			}			
		}
	}
	
	search = function() {
		$.get("../ContaReceber",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1",
			from: "1",
			lancamento: $('#lancamentoIn').val(),
			documento: $('#documentoIn').val(),
			descricao: $('#descricaoIn').val(),
			unidadeId: ($('#unidadeId').val() == "Selecione") ? "" : $('#unidadeId').val(),
			statusLancamento: $('#status').val()},
			function(response){
				$('#dataBank').empty();
				$('#dataBank').append(response);				
			}
		);
		return false;
	}
	
	renderize= function(value) {
		if (flag) {
			flag= false;
			search();
		} else {
			pager.sortOffSet(value);
			$.get("../ContaReceber",{gridLines: pager.limit, 
			limit: pager.limit,
			offset: pager.offSet, 
			isFilter: "0",
			from: "1",
			lancamento: $('#lancamentoIn').val(),
			documento: $('#documentoIn').val(),
			descricao: $('#descricaoIn').val(),
			unidadeId: ($('#unidadeId').val() == "Selecione") ? "" : $('#unidadeId').val(),
			statusLancamento: $('#status').val()
			},
			function(response) {
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.calculeCurrentPage(); 	
			pager.refreshPager();						
		}
	}
	
	$(this).ajaxStart(function(){
		showLoader('Carregando...', 'body', false);
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
		if (condition) {
			if (parseInt($('#gridLines').val()) != pager.recordCount) {
				pager.Search();
			}
		}
	});
	
	$("input[type='text']").change(function() {
		flag= true;
	});
	
});