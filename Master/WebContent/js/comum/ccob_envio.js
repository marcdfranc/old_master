var pager;
var flag= false;
var dataGrid;
var mensagem = "";
var link = "";

$(document).ready(function() {
	pager = new Pager($('#gridLines').val(), 30, "../CadastroPlano");
	pager.mountPager();
	dataGrid = new DataGrid();
	dataGrid.addOption("Imprimir Retorno", "imprime(");
	dataGrid.addOption("Baixar Arquivo", "baixe(");
	dataGrid.addOption("Excluir Arquivo", "exclui(");
	$("body").ajaxStart(function() {
		showLoader();
	}).ajaxStop(function() {
		hideLoader();
	});
});

function appendMenu(value){
	dataGrid.expande(value, false);		
}

function getNext() {
	if (flag) {
		flag= false;
	} else {
		if ((pager.limit * pager.currentPage) < pager.recordCount) {
			$.get("../Centercob",{
				gridLines: pager.limit,
				limit: pager.limit,
				isFilter: "0",
				offset: pager.offSet + pager.limit,
				inicio: $("#inicio").val(),
				fim: $('#fim').val(), 
				unidade: $("#unidadeId").val(),
				from : "1"},
			function (response) {				
				$('#dataBank').empty().append(response);
			});
			pager.nextPage();
			dataGrid = new DataGrid();
		}			
	}
}

function getPrevious() {
	if (flag) {
		flag= false;
	} else {
		if (pager.offSet > 0) {
			$.get("../Centercob",{
				gridLines: pager.limit,
				limit: pager.limit,
				isFilter: "0",
				offset: pager.offSet - pager.limit, 
				inicio: $("#inicio").val(),
				fim: $('#fim').val(), 
				unidade: $("#unidadeId").val(),
				from : "1"},
				function (response) {				
					$('#dataBank').empty().append(response);
				}
			);
			pager.previousPage();
			dataGrid = new DataGrid();
		}			
	}
}

function search() {
	$.get("../Centercob",{
		gridLines: pager.limit, 
		limit: pager.limit,
		offset: 0, 
		isFilter: "1",
		inicio: $("#inicio").val(),
		fim: $('#fim').val(), 
		unidade: $("#unidadeId").val(),
		from : "1"},
		function(response){
			$('#dataBank').empty().append(response);		
		}
	);
}

function renderize() {
	if (flag) {
		flag= false;
	} else {
		pager.sortOffSet(value);
		$.get("../Centercob",{
			gridLines: pager.limit,
			imit: pager.limit,				
			offset: pager.offSet,
			isFilter: "0",
			inicio: $("#inicio").val(),
			fim: $('#fim').val(), 
			unidade: $("#unidadeId").val(),
			from : "1"},
			function (response) {				
				$('#dataBank').empty().append(response);
			}
		);
		pager.calculeCurrentPage(); 	
		pager.refreshPager();
		dataGrid = new DataGrid();
	}
}

function marcarEnviado() {
	var marcados = $(".ck-grid:checked").length - 1;
	var ids = "";
	
	$(".ck-grid:checked").each(function(i, domEle) {
		ids+= (i == 0)? $(domEle).val() : ", " + $(domEle).val();
		if (i == marcados) {
			$.get("../Centercob", {
				from: 3,
				arquivos: ids
			}, function(response) {				
				showOption({
					title: "Mensagem",
					mensagem: response,					
					show: 'fade',
					hide: 'clip',
					buttons: {
						"ok": function() {
							var url = location.href;
							location.href = url;							
						}
					} 
				});	
			});
		}
	});
}

function imprime(id) {
	top = (screen.height - 600)/2;
	left= (screen.width - 800)/2;
	window.open("../GeradorRelatorio?rel=224&parametros=540@" + id, 
			'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
}

function baixe(id) {
	window.open("../Centercob?state=1&id=" + id, "_blank");
}

function exclui(id) {
	$.get("../Centercob",{
		from: 5,
		id: id
	}, function (response) {				
		showOption({
			title: "Excluir Arquivo",
			mensagem: response,
			width: 400,
			show: 'fade',
			hide: 'clip',
			buttons: {
				"Ok": function() {
					location.reload();
				}
			}
		});
	});
}