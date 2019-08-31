var mensagem = "";
var link = "";
var flag= false;

$(document).ready(function() {
	$("input[type='text']").change(function() {
		flag= true;		
	});
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
		if (mensagem != "" && link != "") {
			location.href = '../error_page.jsp?errorMsg=' + mensagem +  
				'&lk=' + link;
		}
	});
});

function load() {		
	pager = new Pager($('#gridLines').val(), 10, "../CadastroInsumo");
	pager.mountPager();
	dataGrid = new DataGrid();		
	dataGrid.addOption("Reajustar Preço", "editInsumo(");
	dataGrid.addOption("Editar estoque", "EditEstoque(");
}

function appendMenu(value){
	dataGrid.expande(value, false);
}

function getNext(){
	if (flag) {
		flag= false;
		$('#descricaoIn').val("");
	} else {
		if ((pager.limit * pager.currentPage) < pager.recordCount) {
			$.get("../CadastroInsumo",{
				gridLines: pager.limit,
				limit: pager.limit,
				isFilter: "0",
				offset: pager.offSet + pager.limit,
				codigo: $("#codigoIn").val(),
				ramo: $('#ramoIn').val(),
				descricao: $('#descricaoIn').val(),
				tipo: $("#tipoIn").val(),
				statusIn: $("#statusIn").val(),
				unidade: $("#unidadeId").val(),
				from : "0"},
			function (response) {				
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.nextPage();
			dataGrid = new DataGrid();
			dataGrid.addOption("Edição", "editInsumo(");
			dataGrid.addOption("Editar estoque", "EditEstoque(");
		}			
	}
}

function getPrevious(){
	if (flag) {
		flag= false;
		$('#descricaoIn').val("");			
	} else {
		if (pager.offSet > 0) {
			$.get("../CadastroInsumo",{
				gridLines: pager.limit,
				limit: pager.limit,
				isFilter: "0",
				offset: pager.offSet - pager.limit, 
				codigo: $("#codigoIn").val(),
				ramo: $('#ramoIn').val(),
				descricao: $('#descricaoIn').val(),
				tipo: $("#tipoIn").val(),
				statusIn: $("#statusIn").val(),
				unidade: $("#unidadeId").val(),
				from : "0"},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				}
			);
			pager.previousPage();
			dataGrid = new DataGrid();
			dataGrid.addOption("Edição", "editInsumo(");
			dataGrid.addOption("Editar estoque", "EditEstoque(");
		}			
	}
}

function search() {		
	$.get("../CadastroInsumo",{
		gridLines: pager.limit, 
		limit: pager.limit,
		offset: 0, 
		isFilter: "1",
		from: "0", 
		codigo: $("#codigoIn").val(),
		ramo: $('#ramoIn').val(),
		descricao: $('#descricaoIn').val(),
		tipo: $("#tipoIn").val(),
		statusIn: $("#statusIn").val(),
		unidade: $("#unidadeId").val(),
		from : "0"},
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
		$('#descricaoIn').val("");
	} else {
		pager.sortOffSet(value);
		$.get("../CadastroInsumo",{
			gridLines: pager.limit,
			imit: pager.limit,				
			offset: pager.offSet,
			isFilter: "0",
			codigo: $("#codigoIn").val(),
			ramo: $('#ramoIn').val(),
			descricao: $('#descricaoIn').val(),
			tipo: $("#tipoIn").val(),
			statusIn: $("#statusIn").val(),
			unidade: $("#unidadeId").val(),
			from : "0"},
			function (response) {				
				$('#dataBank').empty();
				$('#dataBank').append(response);
			}
		);
		pager.calculeCurrentPage(); 	
		pager.refreshPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Edição", "editInsumo(");
		dataGrid.addOption("Editar estoque", "EditEstoque(");
	}
}


function editInsumo(id) {
	$.get("../CadastroInsumo", {
		from: '4',
		codInsumo: id
	}, function(response) {
		var custoProduto = response;
		$('#custo-produto').text(custoProduto);
		$("#cadastroWindow").dialog({
	 		modal: true,
	 		width: 350,
	 		maxWidth: 350,
	 		minWidth: 350,
	 		show: 'fade',
	 		hide: 'clip',
	 		buttons: {
	 			"Cancelar": function() {
	 				$(this).dialog('close');
				},
	 			"Reajustar Valor" : function () {
	 				//alert($('#money-reajuste').val());
					$.get('../CadastroInsumo', {
						from: 3,
						valor: $('#money-reajuste').val(),
						tipo: $('#tipo-calculo').val(),
						custo: custoProduto,
						idInumo: id
					}, function(response) {
						showOption({
							mensagem: response,
							title: "Exclusão de Mensalidades",
							show: 'fade',
					 		hide: 'clip',
							buttons: {								
								"Ok": function() {
									location.href = "estoque.jsp";
								}
							}
						});
					});
	 			}		 			
	 		},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
	 	});
	});
}

function EditEstoque(id) {
	alert ('vamos editar o estoque ' + id);
}