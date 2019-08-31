var pager;
var flag= false;
var dataGrid;
var loader;
var teste;
var ckTeste;
var valorBtn;

$(document).ready(function() {	 	
	
	load= function () {		
		pager = new Pager($('#gridLines').val(), 10, "../CadastroBanco");
		pager.mountPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Editar", "editBank(");
		dataGrid.addOption("Excluir", "deleteBank(");
		teste = new MsfWindow("teste", "teste de check", "body", 450, 750, "teste", true, false);
		ckTeste = new MsfCheck("ckTeste", "Meu Teste", 30, 40,
			"valor para verdadeiro", "valore para false", "f",
			function() {
				ckTeste.changeValue();
			}
		);
		valorBtn = new MsfButton("btCkTeste", "testando", "d", 200, 100, "alertaValor");
		teste.addConponent(ckTeste.getHtm());
		teste.addConponent(valorBtn.getHtm());
		teste.setVisible(false);
		teste.init();
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
				$.get("../CadastroBanco",{gridLines: pager.limit , limit: pager.limit, 
					isFilter: "0", offset: pager.offSet + pager.limit,					
					descricaoIn: $('#descricaoIn').val(), isEdit : "n"},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.nextPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Editar", "edit(");
				dataGrid.addOption("Excluir", "delete(");
			}			
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			$('#descricaoIn').val("");			
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroBanco",{gridLines: pager.limit, limit: pager.limit, 
					isFilter: "0", offset: pager.offSet - pager.limit, 
					descricaoIn: $('#descricaoIn').val(), isEdit : "n"},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.previousPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Editar", "edit(");
				dataGrid.addOption("Excluir", "delete(");
			}			
		}
	}
	
	renderize= function(value) {
		if (flag) {
			flag= false;
			$('#descricaoIn').val("");
		} else {
			pager.sortOffSet(value);
			$.get("../CadastroBanco",{gridLines: pager.limit, limit: pager.limit, 
				offset: pager.offSet, isFilter: "0", descricaoIn: $('#descricaoIn').val(), 
				isEdit : "n"},
			function (response) {				
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
			dataGrid = new DataGrid();
			dataGrid.addOption("Editar", "edit(");
			dataGrid.addOption("Excluir", "delete(");
		}
	}		
	
	$("input[type='text']").change(function() {
		flag= true;		
	});	
	
	addRecord = function(){				
		pager.goToLastPage();
		$.get("../CadastroBanco", {gridLines: pager.limit, limit: pager.limit, 
			isFilter: "1", offset: pager.offSet, descricaoIn: $('#descricaoIn').val(), 
			isEdit : "f"
		}, function(response){
			$('#dataBank').empty();
			$('#dataBank').append(response);			
		});
		pager.recordCount++;
		pager.calculePages();		
		pager.calculeCurrentPage();
		pager.refreshPager();
		$('#descricaoIn').val("");
		dataGrid = new DataGrid();
		dataGrid.addOption("Editar", "edit(");
		dataGrid.addOption("Excluir", "delete(");
	}
	
	editBank = function(value) {
		showPrompt("Digite a nova descrição para o banco selecionado.", 
			"Novo Banco", "Descrição", 180, 500, 300, 'd', OK, false,
			function(btn, text) {
				if (btn == 'o') {
					$.get("../CadastroBanco", {gridLines: pager.limit, limit: pager.limit,
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
	
	deleteBank = function(value) {
		showOption("Deseja realmente excluir este registro ?", 
			"Confirmação de Exclusão", 150, 450, 'w', SIM_NAO, false,
			function(btn) {
				if (btn == 's') {
					$.get("../CadastroBanco", {gridLines: pager.limit, limit: pager.limit, 
						isFilter: "1", offset: p2ager.offSet, descricaoIn: $('#descricaoIn').val(),
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
	
	$(this).ajaxStart(function(){
		showLoader("Carregando...", "dataGrid", false);
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
	});
	
	mostra = function() {
		teste.show();
	}
	
	alertaValor = function() {
		alert(ckTeste.getValue());
	}
	
});
