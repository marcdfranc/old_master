var pager;
var flag= false;

$(document).ready(function() {
	load= function () {
		pager = new Pager($('#gridLines').val(), 30, "../CadastroHistorico");
		pager.mountPager();		
	}
	
	getNext = function(){		
		if (flag) {
			flag= false;
			search();
		} else {
			if ((pager.limit * pager.currentPage) < pager.recordCount) {
				$.get("../CadastroHistorico",{
					gridLines: pager.limit,
					limit: pager.limit,
					isFilter: "0",
					from: "1",
					offset: pager.offSet + pager.limit,
					idAcesso: $('#codigoIn').val()}, 
					function (response) {				
						$('#dataBank').empty();
						$('#dataBank').append(response);
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
				$.get("../CadastroHistorico",{
					gridLines: pager.limit, 
					limit: pager.limit,	
					isFilter: "0",
					from: "1",
					offset: pager.offSet - pager.limit,
					idAcesso: $('#codigoIn').val()},						
					function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);
					}
				);
				pager.previousPage();
			}			
		}
	}
	
	renderize= function(value) {
		if (flag) {
			flag= false;
			search();
		} else {
			pager.sortOffSet(value);
			$.get("../CadastroHistorico",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: pager.offSet,
				from: "1", 
				isFilter: "0",
				idAcesso: $('#codigoIn').val()},
				function(response) {
					$('#dataBank').empty();
					$('#dataBank').append(response);
				}
			);
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
	
	$("input[type='text']").change(function() {
		flag= true;
	});
});