var pager;
var flag= false;
var dataGrid;
var mensagem = "";
var link = "";

$(document).ready(function() {
	load= function () {		
		pager = new Pager($('#gridLines').val(), 10, "../CadastroPlano");
		pager.mountPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Edição de Cobertura", "configPlano(");
		dataGrid.addOption("Edição do Plano", "editPlano(");
		dataGrid.addOption("Excluir", "deletePlano(");
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
				$.get("../CadastroPlano",{
					gridLines: pager.limit,
					limit: pager.limit,
					isFilter: "0",
					offset: pager.offSet + pager.limit,
					codigo: $("#codigoIn").val(),
					unidadeId: $("#unidadeId").val(),
					descricao: $('#descricaoIn').val(), 
					cadastro: $("#cadastroIn").val(),
					tipo: $("#tipoIn").val(),
					from : "0"},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.nextPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Edição de Cobertura", "configPlano(");
				dataGrid.addOption("Edição do Plano", "editPlano(");
				dataGrid.addOption("Excluir", "deletePlano(");
			}			
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			$('#descricaoIn').val("");			
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroPlano",{
					gridLines: pager.limit,
					limit: pager.limit,
					isFilter: "0",
					offset: pager.offSet - pager.limit, 
					codigo: $("#codigoIn").val(),
					unidadeId: $("#unidadeId").val(),
					descricao: $('#descricaoIn').val(), 
					cadastro: $("#cadastroIn").val(),
					tipo: $("#tipoIn").val(),
					from : "0"},
					function (response) {				
						$('#dataBank').empty();
						$('#dataBank').append(response);
					}
				);
				pager.previousPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Edição de Cobertura", "configPlano(");
				dataGrid.addOption("Edição do Plano", "editPlano(");
				dataGrid.addOption("Excluir", "deletePlano(");
			}			
		}
	}
	
	search = function() {		
		$.get("../CadastroPlano",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1",
			from: "0", 
			codigo: $("#codigoIn").val(),
			unidadeId: $("#unidadeId").val(),
			descricao: $('#descricaoIn').val(), 
			cadastro: $("#cadastroIn").val(),
			tipo: $("#tipoIn").val(),
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
			$.get("../CadastroPlano",{
				gridLines: pager.limit,
				imit: pager.limit,				
				offset: pager.offSet,
				isFilter: "0",
				codigo: $("#codigoIn").val(),
				unidadeId: $("#unidadeId").val(),
				descricao: $('#descricaoIn').val(), 
				cadastro: $("#cadastroIn").val(),
				tipo: $("#tipoIn").val(),
				from : "0"},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				}
			);
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
			dataGrid = new DataGrid();
			dataGrid.addOption("Edição de Cobertura", "configPlano(");
			dataGrid.addOption("Edição do Plano", "editPlano(");
			dataGrid.addOption("Excluir", "deletePlano(");
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
	
	addPlano = function() {
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
						$.get("../CadastroPlano",{						
							codigo: $("#codigoIn").val(),
							unidadeId: $("#unidadeId").val(),
							descricao: $('#descricaoIn').val(), 
							cadastro: $("#cadastroIn").val(),
							tipo: $("#tipoIn").val(),
							from : "1"},
							function (response) {				
								mensagem = response;
								link = "application/plano.jsp";
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
						$.get("../CadastroPlano",{						
							codigo: "",
							unidadeId: $("#unidadeId").val(),
							descricao: $('#descricaoIn').val(), 
							cadastro: $("#cadastroIn").val(),
							tipo: $("#tipoIn").val(),
							from : "1"},
							function (response) {				
								mensagem = response;
								link = "application/plano.jsp";
							}							
						);
						$(this).dialog('close');
					}
				} 
			});
		}

	}
	
	configPlano = function(value) {
		if ($("#tipo" + value).text() == "Sem Cobertura") {
			showErrorMessage({
				title: "Erro",
				mensagem: "Este plano não tem cobertura!"
			});
		} else {
			location.href = "plano_config.jsp?id=" + value;			
		}

	}
	
	editPlano = function(value) {
		$("#codigoIn").val($("#codigo" + value).text());
		$("#unidadeId").val($("#unidade" + value).text());
		$("#descricaoIn").val($("#descricao" + value).text());
		$("#cadastroIn").val($("#cadastro" + value).text());
		$("#tipoIn").val($("#tipo" + value).text());
	}
	
	deletePlano = function (value) {
		showOption({
			title: "Exclusão",
			mensagem: "Deseja realmente excluir este plano?",
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
					$.get("../CadastroPlano",{				
						codigo: value,						
						from : "2"},
						function (response) {				
							mensagem = response;
							link = "application/plano.jsp";
						}
					);
					location.href = '../error_page.jsp?errorMsg=' + mensagem +  
						'&lk=application/plano.jsp';
				}
			} 
		});
	}
});