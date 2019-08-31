var dataGrid;
var pager;
var flag= false;

$(document).ready(function() {
	load= function () {
		dataGrid = new DataGrid();
		dataGrid.addOption("Cadastro", "goToCadastro(");
		dataGrid.addOption("Parcelamento", "goToParcela(");
		//dataGrid.addOption("Estornar", "estorne(");
		if ($("#prive").val() == "a") {
			dataGrid.addOption("Excluir", "exclui(");			
		}
		pager = new Pager($('#gridLines').val(), 30, "../CadastroOrcamento");
		pager.mountPager();	
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
				$.get("../CadastroOrcamento",{gridLines: pager.limit , limit: pager.limit, 
					isFilter: "0", offset: pager.offSet + pager.limit, from: "0",
					codigoIn: $('#orcIn').val(), 
					profIdIn: $('#profissionalIdIn').val(),
					profissionalIn: $('#profissionalIn').val(), 
					userIdIn: $('#userIdIn').val(),
					usuarioIn: $('#usuarioIn').val(),
					dependenteIn: $('#dependenteIn').val(),					
					unidadeIdIn: $('#unidadeIdIn').val(),
					order: getOrderGd()},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.nextPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");
				dataGrid.addOption("Parcelamento", "goToParcela(");
				//dataGrid.addOption("Estornar", "estorne(");
				if ($("#prive").val() == "a") {
					dataGrid.addOption("Excluir", "exclui(");			
				}
			}			
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroOrcamento",{gridLines: pager.limit, limit: pager.limit,	isFilter: "0",
					offset: pager.offSet - pager.limit, from: "0",	
					codigoIn: $('#orcIn').val(), 
					profIdIn: $('#profissionalIdIn').val(),
					profissionalIn: $('#profissionalIn').val(), 
					userIdIn: $('#userIdIn').val(),
					usuarioIn: $('#usuarioIn').val(),
					dependenteIn: $('#dependenteIn').val(),
					unidadeIdIn: $('#unidadeIdIn').val(),
					order: getOrderGd()},
					function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);
				});
				pager.previousPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");
				dataGrid.addOption("Parcelamento", "goToParcela(");
				//dataGrid.addOption("Estornar", "estorne(");
				if ($("#prive").val() == "a") {
					dataGrid.addOption("Excluir", "exclui(");			
				}
			}			
		}
	}
	
	search= function() {
		$.get("../CadastroOrcamento",{gridLines: pager.limit, limit: pager.limit,
			offset: 0, isFilter: "1", from: "0", 
			codigoIn: $('#orcIn').val(), 
			profIdIn: $('#profissionalIdIn').val(),
			profissionalIn: $('#profissionalIn').val(), 
			userIdIn: $('#userIdIn').val(),
			usuarioIn: $('#usuarioIn').val(),
			dependenteIn: $('#dependenteIn').val(),
			unidadeIdIn: $('#unidadeIdIn').val(),
			order: getOrderGd()},
			function(response){
				$('#dataBank').empty();
				$('#dataBank').append(response);				
			});
		dataGrid = new DataGrid();
		dataGrid.addOption("Cadastro", "goToCadastro(");
		dataGrid.addOption("Parcelamento", "goToParcela(");
		//dataGrid.addOption("Estornar", "estorne(");
		if ($("#prive").val() == "a") {
			dataGrid.addOption("Excluir", "exclui(");			
		}
		return false;
	}
	
	
	renderize= function(value) {
		if (flag) {
			flag= false;
			search();
		} else {
			pager.sortOffSet(value);
			$.get("../CadastroOrcamento",{gridLines: pager.limit, limit: pager.limit,
			offset: pager.offSet, isFilter: "0", from: "0",
			codigoIn: $('#orcIn').val(),
			profIdIn: $('#profissionalIdIn').val(),
			profissionalIn: $('#profissionalIn').val(),
			userIdIn: $('#userIdIn').val(),
			usuarioIn: $('#usuarioIn').val(),
			dependenteIn: $('#dependenteIn').val(),
			unidadeIdIn: $('#unidadeIdIn').val(),
			order: getOrderGd()},
			function(response) {
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
			dataGrid = new DataGrid();
			dataGrid.addOption("Cadastro", "goToCadastro(");
			dataGrid.addOption("Parcelamento", "goToParcela(");
			//dataGrid.addOption("Estornar", "estorne(");
			if ($("#prive").val() == "a") {
				dataGrid.addOption("Excluir", "exclui(");			
			}
		}
	}
	
	estorne = function(value) {
		showOption({
			title: "Confirmação de Estorno",
			mensagem: "Deseja realmente estornar este orçamento?",
			icone: "w",
			width: 400,
			show: 'fade',
			hide: 'clip',
			buttons: {
				"Não": function() {
					$(this).dialog('close');
				},
				"Sim": function () {
				 	$.get("../CadastroOrcamento", {
						gridLines: pager.limit, 
						limit: pager.limit, 
						isFilter: "0", 
						offset: pager.offSet,
						from: "1",
						orcamento : value,
						codigoIn: $('#orcIn').val(),
						profIdIn: $('#profissionalIdIn').val(),
						profissionalIn: $('#profissionalIn').val(),
						userIdIn: $('#userIdIn').val(),
						usuarioIn: $('#usuarioIn').val(),
						dependenteIn: $('#dependenteIn').val(),
						unidadeIdIn: $('#unidadeIdIn').val(),
						order: getOrderGd()
						}, 
						function(response){
							if (response == "0") {
								location.href = '../error_page.jsp?errorMsg=' +  
									'ocorreu um erro durante o estorno!&lk=' +
									'application/orcamento.jsp?id=' + $('#idUser').val();
							} else {
								$('#dataBank').empty();
								$('#dataBank').append(response);
							}
						}
					);
					$(this).dialog('close');
				}
			} 
		});
	}
	
	orderModify = function() {
		$.get("../CadastroOrcamento",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1",
			from: "0",
			codigoIn: $('#orcIn').val(),
			profIdIn: $('#profissionalIdIn').val(),
			profissionalIn: $('#profissionalIn').val(),
			userIdIn: $('#userIdIn').val(),
			usuarioIn: $('#usuarioIn').val(),
			dependenteIn: $('#dependenteIn').val(),
			unidadeIdIn: $('#unidadeIdIn').val(),
			order: getOrderGd()},
			function(response){
				$('#dataBank').empty();
				$('#dataBank').append(response);				
			});			
		return false;
	}
	
	exclui = function(value) {
		showOption({
			title: "Confirmação de Exclusão",
			mensagem: "Deseja realmente excluir este orçamento?",
			icone: "w",
			width: 400,
			show: 'fade',
			hide: 'clip',
			buttons: {
				"Não": function() {
					$(this).dialog('close');
				},
				"Sim": function () {
				 	$.get("../CadastroOrcamento", {					 
						gridLines: pager.limit, 
						limit: pager.limit, 
						isFilter: "0", 
						offset: pager.offSet,
						from: "2",
						orcamento : value
						}, 
						function(response){
							if (response == "0") {
								location.href = '../error_page.jsp?errorMsg=' +  
									'Este orçamento não pode ser excluido pois existem parcelas vinculadas a ele!&lk=' +
									'application/orcamento.jsp?id=' + $('#idUser').val();
							} else {
								$("#windowAlertOk").dialog({
							 		modal: true,
							 		width: 300,
							 		minWidth: 300,
							 		show: 'fade',
									hide: 'clip',
							 		buttons: {
							 			"Ok" : function () {							 				
							 				$(this).dialog('close');
							 				location.reload();
							 			}
							 		},
							 		close: function() {
							 			$(this).dialog('destroy');
							 		}
							 	});
							}
						}
					);
					$(this).dialog('close');
				}
			} 
		});
	}
	
	goToParcela= function(value) {
		location.href = "cadastro_parcela.jsp?id=" + value;
	}
	
	goToCadastro = function(value) {
		location.href = "cadastro_orcamento.jsp?state=1&id=" + value;
	}
	
	voltar= function() {
		window.close();
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
	
	deleteData= function() {
		//alert("meleca");
	}
});