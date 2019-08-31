var pager;
var flag= false;
var dataGrid;

$(document).ready(function() {
	
	load= function () {		
		pager = new Pager($('#gridLines').val(), 30, "../CadastroTipoConta");
		pager.mountPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Editar", "editConta(");
		dataGrid.addOption("Excluir", "deleteConta(");
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
				$.get("../CadastroTipoConta",{
					gridLines: pager.limit ,
					limit: pager.limit,
					isFilter: "0",
					offset: pager.offSet + pager.limit,
					descricaoIn: $('#descricaoIn').val(),
					isEdit : "n"},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.nextPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Editar", "editConta(");
			dataGrid.addOption("Excluir", "deleteConta(");
			}			
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			$('#descricaoIn').val("");			
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroTipoConta",{
					gridLines: pager.limit,
					limit: pager.limit,
					isFilter: "0",
					offset: pager.offSet - pager.limit,
					descricaoIn: $('#descricaoIn').val(),
					isEdit : "n"},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.previousPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Editar", "editConta(");
				dataGrid.addOption("Excluir", "deleteConta(");
			}			
		}
	}
	
	renderize= function(value) {
		if (flag) {
			flag= false;
			$('#descricaoIn').val("");
		} else {
			pager.sortOffSet(value);
			$.get("../CadastroTipoConta",{
				gridLines: pager.limit,
				limit: pager.limit, 
				offset: pager.offSet,
				isFilter: "0",
				descricaoIn: $('#descricaoIn').val(), 
				isEdit : "n"},
			function (response) {				
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
			dataGrid = new DataGrid();
			dataGrid.addOption("Editar", "editConta(");
			dataGrid.addOption("Excluir", "deleteConta(");
		}
	}
	
	$("input[type='text']").change(function() {
		flag= true;		
	});	
	
	addRecord = function(){	
		if (trim($("#descricaoIn").val()) == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "É necessária uma descrição para que ocorra a inserção.",
				title: "Erro de Inserção"
			});
		} else {
			pager.goToLastPage();
			$.get("../CadastroTipoConta", {
				gridLines: pager.limit,
				limit: pager.limit, 
				isFilter: "1",
				offset: pager.offSet,
				descricaoIn: $('#descricaoIn').val(),
				adm: ($('#admPop').val() == undefined)? "n" : $('#admPop').val(),
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
			dataGrid.addOption("Editar", "editConta(");
			dataGrid.addOption("Excluir", "deleteConta(");
		}
			
	}
	
	/**
	 * editConta
	 * @param {type} value 
	 */
	 editConta = function(value) {
	 	$("#editaWindow").dialog({
	 		modal: true,
	 		width: 422,
	 		minWidth: 422,
	 		show: 'fade',
			hide: 'clip',
	 		buttons: {
	 			"Cancelar": function() {
	 				$(this).dialog('close');
				},
	 			"Editar" : function () {	 				
					$.get("../CadastroTipoConta", {
						gridLines: pager.limit, 
						limit: pager.limit,
						isFilter: "1", 
						offset: pager.offSet, 
						descricaoIn: $('#descricaoPop').val(),
						adm: ($('#admPop').val() == undefined)? "n" : $('#admPop').val(),
						id : value, 
						isEdit : "t"
					}, function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);
					});
					$(this).dialog('close');
	 			}		 			
	 		},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
	 	});		
	 }
	 
	 /**
	  * deleteConta
	  * @param {type} value 
	  */
	deleteConta = function (value) {
		showOption({
			mensagem: "Deseja realmente excluir este registro ?",
			title: "Confirmação de Exclusão",
			width: 350,
			buttons: {
				"Não": function () {
					$(this).dialog('close');
				},
				"Sim": function() {
					$.get("../CadastroTipoConta", {
						gridLines: pager.limit, 
						limit: pager.limit, 
						isFilter: "1", 
						offset: pager.offSet, 
						descricaoIn: $('#descricaoIn').val(),
						//adm: ($('#admPop').val() == undefined)? "n" : $('#admPop').val(),							
						id : value, 
						isEdit : "d"}, 
						function(response){
							$('#dataBank').empty();
							$('#dataBank').append(response);			
						}
					);
					$(this).dialog('close');
				}
			}
		});
	}
});