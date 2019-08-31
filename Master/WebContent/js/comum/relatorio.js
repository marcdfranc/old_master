var pager;
var flag= false;
var dataGrid;

$(document).ready(function() {
	load= function () {
		pager = new Pager($('#gridLines').val(), 20, "../CadastroRelatorio");
		pager.mountPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Cadastro", "goToCadastro(");
		dataGrid.addOption("Parametros", "goToParametros(");
		$("#codigoIn").focus();
	}
	
	appendMenu= function(value){
		dataGrid.expande(value, false);
	}
	
	getNext = function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if ((pager.limit * pager.currentPage) < pager.recordCount) {
				$.get("../CadastroRelatorio",{
					gridLines: pager.limit , 
					limit: pager.limit, 
					isFilter: "0",
					offset: pager.offSet + pager.limit,
					codigoIn: $('#codigoIn').val(),
					nomeIn: $('#nomeIn').val(),
					telaIn: $('#telaIn').val(),
					tipoIn: $('#tipoIn').val(),
					dinamicoIn: $('#dinamicoIn').val()},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.nextPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");
				dataGrid.addOption("Parametros", "goToParametros(");
			}			
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroRelatorio",{
					gridLines: pager.limit, 
					limit: pager.limit,
					isFilter: "0",
					offset: pager.offSet - pager.limit,	
					codigoIn: $('#codigoIn').val(),
					nomeIn: $('#nomeIn').val(),
					telaIn: $('#telaIn').val(),
					tipoIn: $('#tipoIn').val(),
					dinamicoIn: $('#dinamicoIn').val()},
					function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);
				});
				pager.previousPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");
				dataGrid.addOption("Parametros", "goToParametros(");
			}			
		}
	}
	
	search= function() {
		$.get("../CadastroRelatorio",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1", 
			codigoIn: $('#codigoIn').val(),
			nomeIn: $('#nomeIn').val(),
			telaIn: $('#telaIn').val(),
			tipoIn: $('#tipoIn').val(),
			dinamicoIn: $('#dinamicoIn').val()},
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
			$.get("../CadastroRelatorio",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: pager.offSet, 
				isFilter: "0", 
				codigoIn: $('#codigoIn').val(),
				nomeIn: $('#nomeIn').val(),
				telaIn: $('#telaIn').val(),
				tipoIn: $('#tipoIn').val(),
				dinamicoIn: $('#dinamicoIn').val()},
			function(response) {
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
			dataGrid = new DataGrid();
			dataGrid.addOption("Cadastro", "goToCadastro(");
			dataGrid.addOption("Parametros", "goToParametros(");
		}
	}
	
	$(this).ajaxStop(function(){
		if (pager != undefined) {
			if (parseInt($('#gridLines').val()) != pager.recordCount) {
				pager.Search();
			}
		}
	});
	
	$("input[type='text']").change(function() {
		flag= true;
	});
	
	goToCadastro= function(value) {
		location.href = 'cadastro_relatorio.jsp?state=1&id=' + value;
	}
	
	goToParametros = function(value) {
		location.href = 'parametro.jsp?id=' + value;
	}
});