var pager;
var flag= false;
var dataGrid;

$(document).ready(function() {
	load= function () {		
		pager = new Pager($('#gridLines').val(), 10, "../CadastroEncargo");
		pager.mountPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Editar", "editEncargo(");		
		dataGrid.addOption("Excluir", "deleteEncargo(");
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
				$.get("../CadastroEncargo",{
					gridLines: pager.limit,
					limit: pager.limit,
					isFilter: "0",
					offset: pager.offSet + pager.limit,
					codigo: $("#codigoIn").val(),					
					descricao: $('#descricaoIn').val(), 
					percentual: $("#percentualIn").val(),					
					from : "0"},
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
			$('#descricaoIn').val("");			
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroEncargo",{
					gridLines: pager.limit,
					limit: pager.limit,
					isFilter: "0",
					offset: pager.offSet - pager.limit, 
					codigo: $("#codigoIn").val(),					
					descricao: $('#descricaoIn').val(), 
					percentual: $("#percentualIn").val(),
					from : "0"},
					function (response) {				
						$('#dataBank').empty();
						$('#dataBank').append(response);
					}
				);
				pager.previousPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Editar", "editEncargo(");		
				dataGrid.addOption("Excluir", "deleteEncargo(");
			}			
		}
	}
	
	search = function() {		
		$.get("../CadastroEncargo",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1",
			from: "0", 
			codigo: $("#codigoIn").val(),					
			descricao: $('#descricaoIn').val(), 
			percentual: $("#percentualIn").val(),
			from : "0"},
			function(response){
				$('#dataBank').empty();
				$('#dataBank').append(response);				
			}
		);
	}
	
	renderize= function(value) {
		if (flag) {
			flag= false;
			$('#descricaoIn').val("");
		} else {
			pager.sortOffSet(value);
			$.get("../CadastroEncargo",{
				gridLines: pager.limit,
				imit: pager.limit,				
				offset: pager.offSet,
				isFilter: "0",
				codigo: $("#codigoIn").val(),					
				descricao: $('#descricaoIn').val(), 
				percentual: $("#percentualIn").val(),
				from : "0"},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				}
			);
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
			dataGrid = new DataGrid();
			dataGrid.addOption("Editar", "editEncargo(");		
			dataGrid.addOption("Excluir", "deleteEncargo(");
		}
	}
	
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
	
	addRecord = function() {
		if ($("#codigoIn").val() != "") {
			showOption({
				title: "edição",
				mensagem: "Tem certeza que deseja editar este ítem?",
				icone: "w",
				show: 'fade',
		 		hide: 'clip',
				buttons: {
					"Não": function() {
						$(this).dialog('close');
					},
					"Sim": function () {
						mensagem = "";
						link = "";
						$.get("../CadastroEncargo",{						
							codigo: $("#codigoIn").val(),					
							descricao: $('#descricaoIn').val(), 
							percentual: $("#percentualIn").val(),
							from : "1"},
							function (response) {				
								mensagem = response;
								link = "application/encargo.jsp";
							}
						);
						$(this).dialog('close');
					}
				} 
			});
		} else {
			showOption({
				title: "Salvar",
				mensagem: "Deseja inserir um novo íten?",
				icone: "w",
				show: 'fade',
		 		hide: 'clip',
				buttons: {
					"Não": function() {
						$(this).dialog('close');
					},
					"Sim": function () {
						mensagem = "";
						link = "";						
						$.get("../CadastroEncargo",{						
							codigo: "",												
							descricao: $('#descricaoIn').val(), 
							percentual: $("#percentualIn").val(),
							from : "1"},
							function (response) {				
								mensagem = response;
								link = "application/encargo.jsp";
							}							
						);
						$(this).dialog('close');
					}
				} 
			});
		}
	}
	
	editEncargo = function(value) {		
		$("#codigoIn").val($("#codigo" + value).text());		
		$("#descricaoIn").val($("#descricao" + value).text());		
		$("#percentualIn").val($("#percentual" + value).text());
	}
	
	deleteEncargo = function (value) {		
		showOption({
			title: "Exclusão",
			mensagem: "Deseja realmente excluir este Encargo?",
			icone: "w",
			show: 'fade',
		 	hide: 'clip',
			buttons: {
				"Não": function() {
					$(this).dialog('close');
				},
				"Sim": function () {
					mensagem = "";
					link = "";
					$.get("../CadastroEncargo",{				
						codigo: value,						
						from : "2"},
						function (response) {				
							location.href = '../error_page.jsp?errorMsg=' + response +  
								'&lk=application/encargo.jsp';							
						}
					);
				}
			} 
		});
	}
	
});