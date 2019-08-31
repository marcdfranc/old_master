var pager;
var flag = false;

$(document).ready(function() {
	pager = new Pager($('#gridLines').val(), 30, "../CadastroAcesso");
	pager.mountPager();
});


function appendMenu(value){
			
}

function getNext(){
	if (flag) {
		flag= false;
		search();
	} else {
		if ((pager.limit * pager.currentPage) < pager.recordCount) {
			$.get("../CadastroAdministrador",{
				gridLines: pager.limit , 
				limit: pager.limit, 
				isFilter: "0",
				from: "0", 
				offset: pager.offSet + pager.limit,
				codigoIn: $('#codigoIn').val(),				
				nomeIn: $('#nomeIn').val(),
				cpfIn: $('#cpfIn').val()},
			function (response) {				
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.nextPage();			
		}			
	}
}

function getPrevious(){
	if (flag) {
		flag= false;
		search();
	} else {
		if (pager.offSet > 0) {
			$.get("../CadastroAdministrador",{
				gridLines: pager.limit, 
				limit: pager.limit,
				isFilter: "0",
				from: "0",
				offset: pager.offSet - pager.limit,	
				codigoIn: $('#codigoIn').val(),				
				nomeIn: $('#nomeIn').val(),
				cpfIn: $('#cpfIn').val()},
				function(response){
					$('#dataBank').empty();
					$('#dataBank').append(response);
			});
			pager.previousPage();			
		}			
	}
}

function search() {
	$.get("../CadastroAdministrador",{
		gridLines: pager.limit, 
		limit: pager.limit,
		offset: 0, 
		isFilter: "1",
		from: "0", 
		codigoIn: $('#codigoIn').val(),				
		nomeIn: $('#nomeIn').val(),
		cpfIn: $('#cpfIn').val()},
		function(response){
			$('#dataBank').empty();
			$('#dataBank').append(response);				
		}
	);
	return false;
}

function renderize(value) {
	if (flag) {
		flag= false;
		search();
	} else {
		pager.sortOffSet(value);
		$.get("../CadastroAdministrador",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: pager.offSet, 
			isFilter: "0",
			from: "0", 
			codigoIn: $('#codigoIn').val(),				
			nomeIn: $('#nomeIn').val(),
			cpfIn: $('#cpfIn').val()},
		function(response) {
			$('#dataBank').empty();
			$('#dataBank').append(response);
		});
		pager.calculeCurrentPage(); 	
		pager.refreshPager();		
	}
}

