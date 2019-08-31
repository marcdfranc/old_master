var pager;
var flag= false;
var dataGrid;

$(document).ready(function() {
	
	load= function () {		
		pager = new Pager($('#gridLines').val(), 30, "../FaturaVendedorAdapter");
		pager.mountPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Cadastro", "goToCadastro(");
		dataGrid.addOption("Estornar", "estornoFatura(");
	}
	
	appendMenu= function(value){
		dataGrid.expande(value, false);		
	}
	
	getNext = function(){
		if ($('#inicioIn').val() != "" && $('#fimIn').val() == "") {
			showErrorMessage({
				title: "Erro",
				mensagem : "É necessário o preenchimento da data final para busca!"				
			});
		} else if ($('#fimIn').val() != "" && $('#inicioIn').val() == "") {
			showErrorMessage({
				title: "Erro",
				mensagem : "É necessário o preenchimento da data inicial para busca!"				
			});
		} else {
			if (flag) {
				flag= false;
				search();
			} else {
				if ((pager.limit * pager.currentPage) < pager.recordCount) {
					$.get("../FaturaVendedorAdapter",{
						gridLines: pager.limit , 
						limit: pager.limit, 
						isFilter: "0",
						from: "0", 
						offset: pager.offSet + pager.limit,
						inicio: $('#inicioIn').val(), 
						fim: $('#fimIn').val(),
						funcionario: $('#funcionarioIn').val()},
					function (response) {				
						$('#dataBank').empty();
						$('#dataBank').append(response);
					});
					pager.nextPage();
					dataGrid = new DataGrid();
					dataGrid.addOption("Cadastro", "goToCadastro(");
					dataGrid.addOption("Estornar", "estornoFatura(");		
				}			
			}
		}
	}
	
	getPrevious= function(){
		if ($('#inicioIn').val() != "" && $('#fimIn').val() == "") {
			showErrorMessage({
				title: "Erro",
				mensagem : "É necessário o preenchimento da data final para busca!"				
			});
		} else if ($('#fimIn').val() != "" && $('#inicioIn').val() == "") {
			showErrorMessage({
				title: "Erro",
				mensagem : "É necessário o preenchimento da data inicial para busca!"				
			});
		} else {
			if (flag) {
				flag= false;
				search();
			} else {
				if (pager.offSet > 0) {
					$.get("../FaturaVendedorAdapter",{
						gridLines: pager.limit, 
						limit: pager.limit,
						isFilter: "0",
						from: "0",
						offset: pager.offSet - pager.limit,	
						inicio: $('#inicioIn').val(), 
						fim: $('#fimIn').val(),
						funcionario: $('#funcionarioIn').val()},
						function(response){
							$('#dataBank').empty();
							$('#dataBank').append(response);
					});
					pager.previousPage();
					dataGrid = new DataGrid();
					dataGrid.addOption("Cadastro", "goToCadastro(");
					dataGrid.addOption("Estornar", "estornoFatura(");
				}			
			}
		}
	}
	
	search= function() {
		if ($('#inicioIn').val() != "" && $('#fimIn').val() == "") {
			showErrorMessage({
				title: "Erro",
				mensagem : "É necessário o preenchimento da data final para busca!"				
			});
		} else if ($('#fimIn').val() != "" && $('#inicioIn').val() == "") {
			showErrorMessage({
				title: "Erro",
				mensagem : "É necessário o preenchimento da data inicial para busca!"				
			});
		} else {
			$.get("../FaturaVendedorAdapter",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: 0, 
				isFilter: "1",
				from: "0", 
				inicio: $('#inicioIn').val(), 
				fim: $('#fimIn').val(),
				funcionario: $('#funcionarioIn').val()},
				function(response){
					$('#dataBank').empty();
					$('#dataBank').append(response);				
				}
			);
		}
		return false;
	}
	
	renderize= function(value) {
		if ($('#inicioIn').val() != "" && $('#fimIn').val() == "") {
			showErrorMessage({
				title: "Erro",
				mensagem : "É necessário o preenchimento da data final para busca!"				
			});
		} else if ($('#fimIn').val() != "" && $('#inicioIn').val() == "") {
			showErrorMessage({
				title: "Erro",
				mensagem : "É necessário o preenchimento da data inicial para busca!"				
			});
		} else {
			if (flag) {
				flag= false;
				search();
			} else {
				pager.sortOffSet(value);
				$.get("../FaturaVendedorAdapter",{
					gridLines: pager.limit, 
					limit: pager.limit,
					offset: pager.offSet, 
					isFilter: "0",
					from: "0", 
					inicio: $('#inicioIn').val(), 
					fim: $('#fimIn').val(),
					funcionario: $('#funcionarioIn').val()},
				function(response) {
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.calculeCurrentPage(); 	
				pager.refreshPager();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");
				dataGrid.addOption("Estornar", "estornoFatura(");
			}
		}
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
	
	goToCadastro= function(value) {
		location.href= 'cadastro_fatura_vendedor.jsp?state=1&id=' + value;
	}
	
	estornoFatura = function (value) {
 		if ($("#caixaOpen").val() == "f") {
			showWarning({
				mensagem: "Para realizar esta operação é necessário abrir o caixa.",
				title: "Acesso Negado"
			});
		} else {
 			showOption({
				title: "Aviso",
				mensagem: "Deseja realmente estornar esta fatura!",
				icone: 'w',
				show: 'fade',
		 		hide: 'clip',
				buttons: {
					"Não": function () {
						$(this).dialog('close');
					},
					"Sim": function () {
						$.get("../FaturaVendedorAdapter",{					
								from: "1",					
								fatura: value},
							function(response) {
								location.href= '../error_page.jsp?errorMsg=' + response + "&lk=application/funcionario.jsp";
							}
						);
					}
				}
			});
 		}
 	}
 	
 	
});