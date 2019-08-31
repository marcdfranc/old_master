var pager;
var flag= false;

$(document).ready(function() {	
	
	load= function () {		
		pager = new Pager($('#gridLines').val(), 30, "../CadastroLancamento");
		pager.mountPager();	
	}
	
	getNext = function(){
		if (($("#inicioIn").val() == "" && $("#fimIn").val() != "")) {
			showErrorMessage ({
				mensagem: "É necessário o preenchimento do campo \"Inicio\" para que a busca seja realizada!",
				title: "Entrada inválida"
			});
		} else if (($("#inicioIn").val() != "" && $("#fimIn").val() == "")) {
			showErrorMessage ({
				mensagem: "É necessário o preenchimento do campo \"Fim\" para que a busca seja realizada!",
				title: "Entrada inválida"
			});
		} else {
			if (flag) {
				flag= false;
				search();
			} else {
				if ((pager.limit * pager.currentPage) < pager.recordCount) {
					$.get("../CadastroLancamento",{
						gridLines: pager.limit,
						limit: pager.limit,
						isFilter: "0",
						offset: pager.offSet + pager.limit,
						lancamento: $('#lancamentoIn').val(),
						documentoIn: $('#documentoIn').val(),
						descricaoIn: $('#descricaoIn').val(),
						tipoIn: $('#tipo').val(),
						inicioIn: $('#inicioIn').val(),
						fimIn: $('#fimIn').val(),
						tipoIn: $('#tipoIn').val(),
						unidadeId: $('#unidadeId').val(),
						status: $('#status').val()}, 
						function (response) {				
							$('#dataGrid').empty();
							$('#dataGrid').append(response);
						}
					);
					pager.nextPage();			
				}			
			}
		}
	}
	
	
	getPrevious= function(){
		if (($("#inicioIn").val() == "" && $("#fimIn").val() != "")) {
			showErrorMessage ({
				mensagem: "É necessário o preenchimento do campo \"Inicio\" para que a busca seja realizada!",
				title: "Entrada inválida"
			});
		} else if (($("#inicioIn").val() != "" && $("#fimIn").val() == "")) {
			showErrorMessage ({
				mensagem: "É necessário o preenchimento do campo \"Fim\" para que a busca seja realizada!",
				title: "Entrada inválida"
			});
		} else {
			if (flag) {
				flag= false;
				search();
			} else {
				if (pager.offSet > 0) {
					$.get("../CadastroLancamento",{
						gridLines: pager.limit, 
						limit: pager.limit,	
						isFilter: "0",
						offset: pager.offSet - pager.limit,
						lancamento: $('#lancamentoIn').val(),
						documentoIn: $('#documentoIn').val(),
						descricaoIn: $('#descricaoIn').val(),
						tipoIn: $('#tipo').val(),
						inicioIn: $('#inicioIn').val(),
						fimIn: $('#fimIn').val(),
						tipoIn: $('#tipoIn').val(),
						unidadeId: $('#unidadeId').val(),
						status: $('#status').val()},						
						function(response){
							$('#dataGrid').empty();
							$('#dataGrid').append(response);
						}
					);
					pager.previousPage();
				}			
			}			
		}
	}
	
	search= function() {
		if (($("#inicioIn").val() == "" && $("#fimIn").val() != "")) {
			showErrorMessage ({
				mensagem: "É necessário o preenchimento do campo \"Inicio\" para que a busca seja realizada!",
				title: "Entrada inválida"
			});
		} else if (($("#inicioIn").val() != "" && $("#fimIn").val() == "")) {
			showErrorMessage ({
				mensagem: "É necessário o preenchimento do campo \"Fim\" para que a busca seja realizada!",
				title: "Entrada inválida"
			});
		} else {
			$.get("../CadastroLancamento",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: 0, 
				isFilter: "1",
				lancamento: $('#lancamentoIn').val(), 
				documentoIn: $('#documentoIn').val(),
				descricaoIn: $('#descricaoIn').val(),
				tipoIn: $('#tipo').val(),
				inicioIn: $('#inicioIn').val(),
				fimIn: $('#fimIn').val(),
				tipoIn: $('#tipoIn').val(),
				unidadeId: $('#unidadeId').val(),
				status: $('#status').val()},
				function(response){
					$('#dataGrid').empty();
					$('#dataGrid').append(response);				
				}
			);
		}
		return false;
	}
	
	renderize= function(value) {
		if (($("#inicioIn").val() == "" && $("#fimIn").val() != "")) {
			showErrorMessage ({
				mensagem: "É necessário o preenchimento do campo \"Inicio\" para que a busca seja realizada!",
				title: "Entrada inválida"
			});
		} else if (($("#inicioIn").val() != "" && $("#fimIn").val() == "")) {
			showErrorMessage ({
				mensagem: "É necessário o preenchimento do campo \"Fim\" para que a busca seja realizada!",
				title: "Entrada inválida"
			});
		} else {
			if (flag) {
				flag= false;
				search();
			} else {
				pager.sortOffSet(value);
				$.get("../CadastroLancamento",{
					gridLines: pager.limit, 
					limit: pager.limit,
					offset: pager.offSet, 
					isFilter: "0",
					lancamento: $('#lancamentoIn').val(),
					documentoIn: $('#documentoIn').val(),
					descricaoIn: $('#descricaoIn').val(),
					tipoIn: $('#tipo').val(),
					inicioIn: $('#inicioIn').val(),
					fimIn: $('#fimIn').val(),
					tipoIn: $('#tipoIn').val(),
					unidadeId: $('#unidadeId').val(),
					status: $('#status').val()},
					function(response) {
						$('#dataGrid').empty();
						$('#dataGrid').append(response);
					}
				);
				pager.calculeCurrentPage(); 	
				pager.refreshPager();						
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
	
});