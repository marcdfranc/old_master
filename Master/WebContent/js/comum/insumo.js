var pager;
var flag= false;
var dataGrid;
var mensagem = "";
var link = "";

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
	dataGrid.addOption("Edição", "editInsumo(");
	dataGrid.addOption("Excluir", "deleteInsumo(");
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
			dataGrid.addOption("Excluir", "deleteInsumo(");
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
			dataGrid.addOption("Excluir", "deleteInsumo(");
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
		dataGrid.addOption("Excluir", "deleteInsumo(");
	}
}

function addInsumo() {
	if (autentic()) {
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
						$.get("../CadastroInsumo",{						
							qtde: '0',     
							valor: '0.0',
							codigo: $("#codigoIn").val(),
							ramo: $('#ramoIn').val(),
							descricao: $('#descricaoIn').val(),
							tipo: $("#tipoIn").val(),
							statusIn: $("#statusIn").val(),
							unidade: $("#unidadeId").val(),
							from : "1"},
							function (response) {
								mensagem = response;
								link = "application/insumo.jsp?origem=" + $('#origem').val();
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
						$.get("../CadastroInsumo",{						
							codigo: '',
							ramo: $('#ramoIn').val(),
							descricao: $('#descricaoIn').val(),
							tipo: $("#tipoIn").val(),
							statusIn: $("#statusIn").val(),
							unidade: $("#unidadeId").val(),
							from : "1"},
							function (response) {				
								mensagem = response;
								link = "application/insumo.jsp?origem=" + $('#origem').val();
							}							
						);
						$(this).dialog('close');
					}
				} 
			});
		}			
	} else {
		showErrorMessage ({
			mensagem: "Todos os campos desta seção precisam ser preenchidos para inserção!",
			width: 400,
			title: "Entrada inválida"
		});
	}


}


function editInsumo(value) {
//	$("#codigoCad").val($("#codigo" + value).text());
	$("#codigoCad").val(value);
	
	$("#ramoIn > *").each(function(index, domEle) {
		if (domEle.text == $("#ramo" + value).text()) {
			$("#ramoIn").val(domEle.value);
		}
	});
	
	$("#descricaoIn").val($("#descricao" + value).text());
	
	if ($("#tipo" + value).text() == 'Serviço') {
		$("#tipoIn").val('s');
	} else {
		$("#tipoIn").val('p');
	}
	if ($("#status" + value).text() == 'Ativo') {
		$("#statusIn").val('a');
	} else {
		$("#statusIn").val('d');
	}
	
	$("#unidadeId > *").each(function(index, domEle) {
		if (domEle.text == $("#unidade" + value).text()) {
			$("#unidadeId").val(domEle.value);
		}
	});
}

function deleteInsumo(value) {
	showOption({
		title: "Exclusão",
		mensagem: "Deseja realmente excluir este Insumo?",
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
				$.get("../CadastroInsumo",{				
					codigo: value,						
					from : "2"},
					function (response) {				
						mensagem = response;
						link = "application/insumo.jsp?origem=" + $('#origem').val();
					}
				);
				location.href = '../error_page.jsp?errorMsg=' + mensagem +  
					'&lk=application/insumo.jsp?origem=' + $('#origem').val();
			}
		} 
	});
}

function autentic() {
	var mensagem = '';
	var result = true;
	if ($('#ramoCad').val() == '') {
		mensagem = 'Ramo é um campo requerido!';
		result = false;
	}
	if ($('#descricaoCad').val() == '') {
		mensagem = 'Descrição é um campo requerido!';
		result = false;
	}
	if ($('#tipoCad').val() == '') {
		mensagem = 'Tipo é um campo requerido!';
		result = false;
	}
	if ($('#statusCad').val() == '') {
		mensagem = 'Status é um campo requerido!';
		result = false;
	}
	if (($('#unidadeCad').val() == '') || ($('#unidadeId').val() == '0')) {
		mensagem = 'Unidade é um campo requerido!';
		result = false;
	}
	if (!result) {
		showErrorMessage ({
			mensagem: mensagem,
			width: 400,
			title: "Entrada inválida"
		});
	}
	return result;
}


function cadastro() {
	$("#cadastroWindow").dialog({
 		modal: true,
 		width: 580,
 		minWidth: 520,
 		show: 'fade',
 		hide: 'clip',
 		buttons: {
 			"Cancelar": function() {
 				$(this).dialog('close');
			},
 			"Cadastrar" : function () {
 				if (autentic()) {
					$.get("../CadastroInsumo",{						
						codigo: $("#codigoCad").val(),
						ramo: $('#ramoCad').val(),
						descricao: $('#descricaoCad').val(),
						tipo: $("#tipoCad").val(),
						statusIn: $("#statusCad").val(),
						unidade: $("#unidadeCad").val(),
						qtde: '0',     
						valor: '0.0',
						from : "1"},
						function (response) {
							mensagem = response;
							link = "application/insumo.jsp?origem=" + $('#origem').val();
						}
					);
					$(this).dialog('close');
 						
				}		
 			}		 			
 		},
 		close: function() {
 			$(this).dialog('destroy');
 		}
 	});
}