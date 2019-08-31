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
				width: 400,
				mensagem: "É necessário o preenchimento do campo \"Dt. Inicial\" para que a busca seja realizada!",
				title: "Erro de Pesquisa"
			});
		} else if (($("#inicioIn").val() != "" && $("#fimIn").val() == "")) {
			showErrorMessage ({
				width: 400,
				mensagem: "É necessário o preenchimento do campo \"Dt. Final\" para que a busca seja realizada!",
				title: "Erro de Pesquisa"
			});
		} else {
			if (flag) {
				flag= false;
				search();
			} else {
				if ((pager.limit * pager.currentPage) < pager.recordCount) {
					$.get("../CadastroConciliacao",{
						gridLines: pager.limit,
						limit: pager.limit,
						isFilter: "0",
						offset: pager.offSet + pager.limit,
						from: "0",
						codigoIn: $('#codigoIn').val(),
						numeroIn: $('#numeroIn').val(),
						tipoLancamento: $('#tipoLancamento').val(),
						tipoPagamento: $('#tipoPagamento').val(),
						inicioIn: $('#inicioIn').val(),
						fimIn: $('#fimIn').val(),						
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
				width: 400,
				mensagem: "É necessário o preenchimento do campo \"Dt. Inicial\" para que a busca seja realizada!",
				title: "Erro de Pesquisa"
			});
		} else if (($("#inicioIn").val() != "" && $("#fimIn").val() == "")) {
			showErrorMessage ({
				width: 400,
				mensagem: "É necessário o preenchimento do campo \"Dt. Final\" para que a busca seja realizada!",
				title: "Erro de Pesquisa"
			});
		} else {
			if (flag) {
				flag= false;
				search();
			} else {
				if (pager.offSet > 0) {
					$.get("../CadastroConciliacao",{
						gridLines: pager.limit, 
						limit: pager.limit,	
						isFilter: "0",
						offset: pager.offSet - pager.limit,
						from: "0",	
						codigoIn: $('#codigoIn').val(),
						numeroIn: $('#numeroIn').val(),
						tipoLancamento: $('#tipoLancamento').val(),
						tipoPagamento: $('#tipoPagamento').val(),
						inicioIn: $('#inicioIn').val(),
						fimIn: $('#fimIn').val(),						
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
				width: 400,
				mensagem: "É necessário o preenchimento do campo \"Dt. Inicial\" para que a busca seja realizada!",
				title: "Erro de Pesquisa"
			});
		} else if (($("#inicioIn").val() != "" && $("#fimIn").val() == "")) {
			showErrorMessage ({
				width: 400,
				mensagem: "É necessário o preenchimento do campo \"Dt. Final\" para que a busca seja realizada!",
				title: "Erro de Pesquisa"
			});
		} else {
			$.get("../CadastroConciliacao",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: 0, 
				isFilter: "1",
				from: "0", 
				codigoIn: $('#codigoIn').val(),
				numeroIn: $('#numeroIn').val(),
				tipoLancamento: $('#tipoLancamento').val(),
				tipoPagamento: $('#tipoPagamento').val(),
				inicioIn: $('#inicioIn').val(),
				fimIn: $('#fimIn').val(),						
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
				width: 400,
				mensagem: "É necessário o preenchimento do campo \"Dt. Inicial\" para que a busca seja realizada!",
				title: "Erro de Pesquisa"
			});
		} else if (($("#inicioIn").val() != "" && $("#fimIn").val() == "")) {
			showErrorMessage ({
				width: 400,
				mensagem: "É necessário o preenchimento do campo \"Dt. Final\" para que a busca seja realizada!",
				title: "Erro de Pesquisa"
			});
		} else {
			if (flag) {
				flag= false;
				search();
			} else {
				pager.sortOffSet(value);
				$.get("../CadastroConciliacao",{
					gridLines: pager.limit, 
					limit: pager.limit,
					offset: pager.offSet, 
					isFilter: "0",
					from: "0",
					codigoIn: $('#codigoIn').val(),
					numeroIn: $('#numeroIn').val(),
					tipoLancamento: $('#tipoLancamento').val(),
					tipoPagamento: $('#tipoPagamento').val(),
					inicioIn: $('#inicioIn').val(),
					fimIn: $('#fimIn').val(),						
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
	
	/**
	 * execBaixa
	 * @param {type}  
	 */
	execBaixa = function() {
		var aux = mountPipeLine();
		if (aux == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione as conciliações que deseja da baixa",
				title: "Edição de Observação"
			});
		} else {
		 	$.get("../CadastroConciliacao",{
		 		pipe: $('#obsIn').val(),
		 		pipe: aux,
		 		from: "1"},
				function (response) {
					if (response == "0") {
						location.href = '../error_page.jsp?errorMsg=Não foi possível baixar as conciliações devido a um erro interno!' + 
									'&lk=application/conciliacao.jsp';
					} else {
						location.href = '../error_page.jsp?errorMsg=Conciliações baixadas com sucesso!' + 
									'&lk=application/conciliacao.jsp';
					}
				}
			);
		}	
	}
	
	mountPipeLine = function() {
		aux = -1;
		pipe = "";
		isFirst = true;
		while($('#ck' + (++aux)).val() != undefined) {
			if (document.getElementById("ck" + aux).checked) {
				if (isFirst) {
					isFirst = false;
					pipe+= $('#ck' + (aux)).val();				
				} else {
					pipe+= "@" + $('#ck' + (aux)).val();
				}
			}
		}
		return pipe;
	}
	
	ckFunction = function(value) {
		var id = 'gridValue' + value.id.replace('ck', "");
		var i = 0;
		var valorTotal = 0;
		while($("#ck" + i).val() != undefined){
			if (document.getElementById("ck" + i).checked) {
				id = "valTot" + i;				
				valorTotal+= parseFloat($("#" + id).text());				
			}
			i++;
		}
		valorTotal = formatCurrency(valorTotal);		
		$("#totalSoma").empty();
		$("#totalSoma").append(valorTotal);
	}
	
	selectAll = function() {
		aux = -1;
		while ($('#ck' + (++aux)).val() != undefined) {
			if (!document.getElementById("ck" + aux).checked) {
				document.getElementById("ck" + aux).checked = true;				
			} else {
				document.getElementById("ck" + aux).checked = false;
			}
		}
		ckFunction(document.getElementById("ck0"));
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
});