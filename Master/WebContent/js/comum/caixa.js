var pager;
var flag= false;
var dataGrid;

$(document).ready(function(){
	load = function(){
		pager = new Pager($('#gridLines').val(), 30, "../CadastroCaixa");
		pager.mountPager();
	}
	
	getNext = function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if ((pager.limit * pager.currentPage) < pager.recordCount) {
				$.get("../CadastroCaixa",{
					gridLines: pager.limit ,
					limit: pager.limit,
					isFilter: "0",
					offset: pager.offSet + pager.limit,
					codigo: $('#codigoIn').val(),
					dataInicio: $('#inicioIn').val(),						
					dataFim: $('#fimIn').val(),					
					usuario: $("#usuarioIn").val(),
					unidadeId: $("#unidadeId").val(),
					from: "0"},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.nextPage();
				dataGrid = new DataGrid();				
			}			
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroCaixa",{
					gridLines: pager.limit, 
					limit: pager.limit,
					isFilter: "0",
					offset: pager.offSet - pager.limit,	
					codigo: $('#codigoIn').val(),
					dataInicio: $('#inicioIn').val(),					
					dataFim: $('#fimIn').val(),					
					usuario: $("#usuarioIn").val(),
					unidadeId: $("#unidadeId").val(),
					from: "0"},
					function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);
				});
				pager.previousPage();
				dataGrid = new DataGrid();
			}			
		}
	}
	
	search= function() {
		$.get("../CadastroCaixa",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1", 
			codigo: $('#codigoIn').val(),
			dataInicio: $('#inicioIn').val(),
			dataFim: $('#fimIn').val(),
			usuario: $("#usuarioIn").val(),
			unidadeId: $("#unidadeId").val(),
			from: "0"},
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
			$.get("../CadastroCaixa",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: pager.offSet, 
				isFilter: "0", 
				codigo: $('#codigoIn').val(),
				dataInicio: $('#inicioIn').val(),
				dataFim: $('#fimIn').val(),
				usuario: $("#usuarioIn").val(),
				unidadeId: $("#unidadeId").val(),
				from: "0"},
			function(response) {
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
			dataGrid = new DataGrid();
		}
	}
	
	orderModify = function() {		
		$.get("../CadastroCaixa",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1", 
			codigo: $('#codigoIn').val(),
			dataInicio: $('#inicioIn').val(),
			dataFim: $('#fimIn').val(),
			usuario: $("#usuarioIn").val(),
			unidadeId: $("#unidadeId").val(),
			from: "0"},
			function(response){
				$('#dataBank').empty();
				$('#dataBank').append(response);				
			});			
		return false;
	}
	
	abrirCaixa = function() {
	 	$("#abreCaixa").dialog({
	 		modal: true,
	 		width: 240,
	 		minWidth: 240,
	 		buttons: {
	 			"Cancelar": function() {
	 				$(this).dialog('close');
				},
	 			"Abrir Caixa" : function () {
	 				$.get("../CadastroCaixa",{
						gridLines: pager.limit, 
						limit: pager.limit,
						offset: 0, 
						isFilter: "1",
						valorInicial: $('#valorInicial').val(), 
						codigo: $('#codigoIn').val(),
						dataInicio: $('#inicioIn').val(),
						dataFim: $('#fimIn').val(),
						usuario: $("#usuarioIn").val(),
						unidadeId: $("#unidadeId").val(),
						from: "1"},
						function (response) {
							if (response != "0") {
								location.href = '../error_page.jsp?errorMsg=Abertura de caixa realizada com sucesso!' + 
									'&lk=application/caixa.jsp';
							} else {
								location.href = '../error_page.jsp?errorMsg=Ocorreu um erro durante a abertura de caixa!' + 
									'&lk=application/caixa.jsp';
							}
						}
					);
					$(this).dialog('close');
	 			}		 			
	 		},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
	 	});
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
	
	$("frame[name=ad_frame]").addClass("cpEsconde");
});