var pager;
var flag= false;
var dataGrid;

$(document).ready(function() {
	load= function () {		
		pager = new Pager($('#gridLines').val(), 10, "../CadastroEspecialidade");
		pager.mountPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Editar", "editEspecialidade(");
		dataGrid.addOption("Excluir", "deleteEspecialidade(");
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
				$.get("../CadastroEspecialidade",{
					gridLines: pager.limit , 
					limit: pager.limit, 
					isFilter: "0", 
					offset: pager.offSet + pager.limit,					
					descricaoIn: $('#descricaoIn').val(), 
					setorIn: $('#setorIn').val(),
					isEdit : "n"},					
					function (response) {				
						$('#dataBank').empty();
						$('#dataBank').append(response);
					}
				);
				pager.nextPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Editar", "editEspecialidade(");
				dataGrid.addOption("Excluir", "deleteEspecialidade(");
			}
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			$('#descricaoIn').val("");			
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroEspecialidade",{gridLines: pager.limit, limit: pager.limit, 
					isFilter: "0", offset: pager.offSet - pager.limit, 
					descricaoIn: $('#descricaoIn').val(), setorIn: $('#setorIn').val(),
					isEdit : "n"},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.previousPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Editar", "editEspecialidade(");
				dataGrid.addOption("Excluir", "deleteEspecialidade(");
			}			
		}
	}
	
	renderize= function(value) {
		if (flag) {
			flag= false;
			$('#descricaoIn').val("");
		} else {
			pager.sortOffSet(value);
			$.get("../CadastroEspecialidade",{gridLines: 
				pager.limit, limit: pager.limit, 
				offset: pager.offSet, 
				isFilter: "0", 
				descricaoIn: $('#descricaoIn').val(), 
				setorIn: $('#setorIn').val(), 
				isEdit : "n"},
			function (response) {				
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
			dataGrid = new DataGrid();
			dataGrid.addOption("Editar", "editEspecialidade(");
			dataGrid.addOption("Excluir", "deleteEspecialidade(");
		}
	}

	$("input[type='text']").change(function() {
		flag= true;		
	});	
	
	addRecord = function(){
		if ((document.getElementById("setorIn").selectedIndex == 0) || ($('#descricaoIn').val() == "")) {
			showErrorMessage ({
				width: 400,
				mensagem: "é necessário o preenchimento dos campos para que possa ocorrer a inserção!",
				title: "Erro"
			});
		} else {
			pager.goToLastPage();		
			$.get("../CadastroEspecialidade", {
				gridLines: pager.limit, 
				limit: pager.limit, 
				isFilter: "1", 
				offset: pager.offSet, 
				descricaoIn: $('#descricaoIn').val(),
				setorIn: $('#setorIn').val(), 
				isEdit : "f"}, 
				function(response){
					$('#dataBank').empty();
					$('#dataBank').append(response);			
				}
			);
			pager.recordCount++;
			pager.calculePages();		
			pager.calculeCurrentPage();
			pager.refreshPager();
			$('#descricaoIn').val("");
			document.getElementById("setorIn").selectedIndex= 0;
			dataGrid = new DataGrid();
			dataGrid.addOption("Editar", "editEspecialidade(");
			dataGrid.addOption("Excluir", "deleteEspecialidade(");
		}		
	}
	
	editEspecialidade = function(value) {
		$("#editWindow").dialog({
	 		modal: true,
	 		width: 350,
	 		minWidth: 350,
	 		show: 'fade',
		 	hide: 'clip',
	 		buttons: {
	 			"Cancelar" : function () {
	 				$(this).dialog('close');
	 			},
	 			"Editar": function () {
	 				if ($('#descEspecialidade').val() == "") {
	 					showErrorMessage ({
							width: 400,
							mensagem: "É necessaria a descrição para o setor atual!",
							title: "Erro"
						});						
	 				} else if ($('#setorWin').val() == "") {
	 					showErrorMessage ({
							width: 400,
							mensagem: "escolha uma atividade para edição!",
							title: "Erro"
						});
	 				} else {
		 				$.get("../CadastroEspecialidade", {
							gridLines: pager.limit, 
							limit: pager.limit, 
							isFilter: "1", 
							offset: pager.offSet, 
							descricaoIn: $('#descEspecialidade').val(), 
							setorIn: $('#setorWin').val(),
							id : value, 
							isEdit : "t"}, 
							function(response){
								$('#dataBank').empty();
								$('#dataBank').append(response);			
							}
						);
						document.getElementById("setorIn").selectedIndex= 0;
	 				}
					$(this).dialog('close');
	 			}
	 		},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
	 	});
	}
	
	
	deleteEspecialidade = function(value) {
		showOption({
			mensagem: "Deseja realmente excluir este registro?",
			title: "Confirmação de Exclusão",
			width: 350,
			show: 'fade',
		 	hide: 'clip',
			buttons: {
				"Não": function () {
					$(this).dialog('close');
				},
				"Sim": function() {
					var elemento = $(this);
					$.get("../CadastroEspecialidade", {
						gridLines: pager.limit, 
						limit: pager.limit, 
						isFilter: "1", 
						offset: pager.offSet, 
						descricaoIn: $('#descricaoIn').val(),
						id : value, 
						isEdit : "d"}, 
						function(response){
							$('#dataBank').empty();
							$('#dataBank').append(response);
							elemento.dialog('close');
						}
					);
				}
			}
		});
	}
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
	});
});