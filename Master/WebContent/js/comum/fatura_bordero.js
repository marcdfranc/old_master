var pager;
var flag= false;
var dataGrid;

$(document).ready(function() {
	load= function () {		
		pager = new Pager($('#gridLines').val(), 30, "../CadastroBordero");
		pager.mountPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Cadastro", "goToCadastro(");
		dataGrid.addOption("Estornar", "estorne(");
		dataGrid.addOption("Excluir", "delFatura(");
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
				$.get("../CadastroClienteFisico",{
					gridLines: pager.limit , 
					limit: pager.limit, 
					isFilter: "0",
					from: "0",
					offset: pager.offSet + pager.limit,			
					inicio: $('#inicioIn').val(), 
					fim: $('#fimIn').val(),
					statusIn: $('#status').val(), 
					profissional: $('#profissionalIn').val()},
					function (response) {
						$('#dataBank').empty();
						$('#dataBank').append(response);
					}
				);
				pager.nextPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");
				dataGrid.addOption("Estornar", "estorne(");
				dataGrid.addOption("Excluir", "delFatura(");
			}			
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroClienteFisico",{
					gridLines: pager.limit, 
					limit: pager.limit,
					isFilter: "0",
					from: "0",
					offset: pager.offSet - pager.limit,
					inicio: $('#inicioIn').val(), 
					fim: $('#fimIn').val(),
					statusIn: $('#status').val(), 
					profissional: $('#profissionalIn').val()},
					function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);
					}
				);
				pager.previousPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");
				dataGrid.addOption("Estornar", "estorne(");
				dataGrid.addOption("Excluir", "delFatura(");
			}			
		}
	}
	
	search= function() {		
		$.get("../CadastroClienteFisico",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			from: "0",
			isFilter: "1",		 
			inicio: $('#inicioIn').val(), 
			fim: $('#fimIn').val(),
			statusIn: $('#status').val(), 
			profissional: $('#profissionalIn').val()},
			function(response){
				$('#dataBank').empty();
				$('#dataBank').append(response);				
			}
		);			
		return false;
	}
	
	renderize= function(value) {
		if (flag) {
			flag= false;
			search();
		} else {
			pager.sortOffSet(value);
			$.get("../CadastroClienteFisico",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: pager.offSet, 
				isFilter: "0",
				from: "0", 
				inicio: $('#inicioIn').val(), 
				fim: $('#fimIn').val(),
				statusIn: $('#status').val(), 
				profissional: $('#profissionalIn').val()},
				function(response) {
					$('#dataBank').empty();
					$('#dataBank').append(response);
				}
			);
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
			dataGrid = new DataGrid();
			dataGrid.addOption("Cadastro", "goToCadastro(");
			dataGrid.addOption("Estornar", "estorne(");
			dataGrid.addOption("Excluir", "delFatura(");
		}
	}
	
	$(this).ajaxStart(function(){
		showLoader('Carregando...', 'body', false);
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
	
	goToCadastro = function (value) {
		location.href= 'cadastro_bordero.jsp?state=1&id=' + value;
	}
	
	estorne = function(value) {
		if ($("#caixaOpen").val() == "f") {
			showWarning({
				mensagem: "Para realizar esta operação é necessário abrir o caixa.",
				title: "Acesso Negado"
			});
		} else {
			showOption({
				title: "Aviso",
				mensagem: "Esta fatura será estornada e cancelada. Todos os lançamentos voltarão para o borderô." +
						"Deseja realmente estornar!",
				icone: 'w',
				show: 'fade',
		 		hide: 'clip',
				buttons: {
					"Não": function () {
						$(this).dialog('close');
					},
					"Sim": function () {
						$.get("../CadastroBordero",{
							from: "1",
							bordero: value},
							function(response){
								location.href= '../error_page.jsp?errorMsg=' + response + "&lk=" +
									"application/profissionais.jsp";
							}
						);
					}
				}
			});
		}
	}
		
	delFatura = function() {
		alert("delete fatura");
	}
	
});