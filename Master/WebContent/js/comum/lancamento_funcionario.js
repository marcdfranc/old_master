var pager;
var flag= false;

$(document).ready(function() {
	load = function(){		
		pager = new Pager($('#gridLines').val(), 30, "../CadastroBordero");
		pager.mountPager();		
		if (document.getElementById("pagerGrid").innerHTML != "" ) {
			$('#lastButton').addClass("justificaRight");			
		} else {
			$('#lastButton').removeAttr("class", "justificaRight");	
		}
	}
	
	getNext = function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if ((pager.limit * pager.currentPage) < pager.recordCount) {
				$.get("../CadastroFaturaVendedor",{
					gridLines: pager.limit , 
					limit: pager.limit, 
					isFilter: "0", 
					offset: pager.offSet + pager.limit, 
					from: "0",
					ref: $('#refIn').val(),
					funcionario: $("#nomeIn").val(),
					cpf: $("#cpfIn").val(),
					nascimento: $('#nascimentoIn').val(),					
					unidadeId: $('#unidadeIdIn').val()},
					function (response) {				
						$('#dataGrid').empty();
						$('#dataGrid').append(response);
					}
				);
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
				$.get("../CadastroFaturaVendedor",{
					gridLines: pager.limit, 
					limit: pager.limit,	
					isFilter: "0",
					offset: pager.offSet - pager.limit, 
					from: "0",
					ref: $('#refIn').val(),
					funcionario: $("#nomeIn").val(),
					cpf: $("#cpfIn").val(),
					nascimento: $('#nascimentoIn').val(),					
					unidadeId: $('#unidadeIdIn').val()},
					function(response){
						$('#dataGrid').empty();
						$('#dataGrid').append(response);
					}
				);
				pager.previousPage();				
			}			
		}
	}

	search= function() {
		$.get("../CadastroFaturaVendedor",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1", 
			from: "0",
			ref: $('#refIn').val(),
			funcionario: $("#nomeIn").val(),
			cpf: $("#cpfIn").val(),
			nascimento: $('#nascimentoIn').val(),					
			unidadeId: $('#unidadeIdIn').val()},
			function(response){
				$('#dataGrid').empty();
				$('#dataGrid').append(response);				
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
			$.get("../CadastroFaturaVendedor",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: pager.offSet, 
				isFilter: "0",
				from: "0", 
				ref: $('#refIn').val(),
				funcionario: $("#nomeIn").val(),
				cpf: $("#cpfIn").val(),
				nascimento: $('#nascimentoIn').val(),					
				unidadeId: $('#unidadeIdIn').val()},
				function(response) {
					$('#dataGrid').empty();
					$('#dataGrid').append(response);
				}
			);
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
		}
	}
	
	$(this).ajaxStart(function(){
		showLoader('Carregando...', 'body', false);
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
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
});