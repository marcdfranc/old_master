var pager;
var flag= false;
var dataGrid;

$(document).ready( function(){
	load= function () {		
		pager = new Pager($('#gridLines').val(), 10, "../CadastroPosicao");
		pager.mountPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Editar", "editPosicao(");
		dataGrid.addOption("Excluir", "deletePosicao(");	
	}
	
	appendMenu= function(value){
		dataGrid.expande(value, false);
	}
	
	getNext = function(){
		if (flag) {
			flag= false;
			$('#descricaoIn').val("");
		} else {
			if ((pager.limit * pager.currentPage) < pager.recordCount) {
				$.get("../CadastroPosicao",{gridLines: pager.limit , limit: pager.limit, 
					isFilter: "0", offset: pager.offSet + pager.limit,					
					descricaoIn: $('#descricaoIn').val(), isEdit : "n"},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.nextPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Editar", "editPosicao(");
				dataGrid.addOption("Excluir", "deletePosicao(");
			}			
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			$('#descricaoIn').val("");
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroPosicao",{gridLines: pager.limit, limit: pager.limit,
					isFilter: "0", offset: pager.offSet - pager.limit,
					descricaoIn: $('#descricaoIn').val(), isEdit : "n"},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.previousPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Editar", "editPosicao(");
				dataGrid.addOption("Excluir", "deletePosicao(");
			}			
		}
	}
	
	renderize= function(value) {
		if (flag) {
			flag= false;
			search();
		} else {
			pager.sortOffSet(value);
			$.get("../CadastroPosicao",{gridLines: pager.limit, limit: pager.limit,
			offset: pager.offSet, isFilter: "0",
				descricaoIn: $('#descricaoIn').val(), isEdit : "n"},
			function (response) {				
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
			dataGrid = new DataGrid();
			dataGrid.addOption("Editar", "editPosicao(");
			dataGrid.addOption("Excluir", "deletePosicao(");						
		}
	}		
	
	$("input[type='text']").change(function() {
		flag= true;
	});	
	
	
	addRecord = function(){				
		pager.goToLastPage();
		$.get("../CadastroPosicao", {
			gridLines: pager.limit,
			limit: pager.limit,
			isFilter: "1",
			offset: pager.offSet,
			descricaoIn: $('#descricaoIn').val(), isEdit : "f"
		}, function(response){
			$('#dataBank').empty();
			$('#dataBank').append(response);			
		});
		pager.recordCount++;
		pager.calculePages();		
		pager.calculeCurrentPage();
		pager.refreshPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Editar", "editPosicao(");
		dataGrid.addOption("Excluir", "deletePosicao(");
		$('#descricaoIn').val("");
	}
	
	editPosicao = function(value) {
		showPrompt("Digite a nova descrição para a posição atual.", 
			"Nova Posição", "Descrição", 180, 500, 300, 'd', OK, false,
			function(btn, text) {
				if (btn == 'o') {
					$.get("../CadastroPosicao", {gridLines: pager.limit, limit: pager.limit, 
						isFilter: "1", offset: pager.offSet, descricaoIn: text,
						id : value, isEdit : "t"
					}, function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);			
					});					
				}
			}
		);
	}
	
	deletePosicao = function(value) {
		showOption("Deseja realmente excluir este registro ?", 
			"Confirmação de Exclusão", 150, 450, 'w', SIM_NAO, false,
			function(btn) {
				if (btn == 's') {
					$.get("../CadastroPosicao", {gridLines: pager.limit, limit: pager.limit, 
						isFilter: "1", offset: pager.offSet, descricaoIn: $('#descricaoIn').val(),
						id : value, isEdit : "d"
						}, 
						function(response){
							$('#dataBank').empty();
							$('#dataBank').append(response);			
					});
				}
			}
		);
	}
});