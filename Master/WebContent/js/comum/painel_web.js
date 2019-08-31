var pager;
var flag= false;

$(document).ready(function() {	
	load= function () {				
		pager = new Pager($('#gridLines').val(), 30, "../CadastroAcesso");
		pager.mountPager();
	}
	
	getNext = function(){
		if (($("#inicioIn").val() == "" && $("#fimIn").val() != "")) {
			showErrorMessage ({
				mensagem: "É necessário o preenchimento do campo \"Dt. Inicial\" para que a busca seja realizada!",
				title: "Erro de Pesquisa"
			});
		} else if (($("#inicioIn").val() != "" && $("#fimIn").val() == "")) {
			showErrorMessage ({
				mensagem: "É necessário o preenchimento do campo \"Dt. Final\" para que a busca seja realizada!",
				title: "Erro de Pesquisa"
			});
		} else {
			if (flag) {
				flag= false;
				search();
			} else {
				if ((pager.limit * pager.currentPage) < pager.recordCount) {
					$.get("../CadastroAcesso",{
						gridLines: pager.limit,
						limit: pager.limit,
						isFilter: "0",
						offset: pager.offSet + pager.limit,
						from: "0",
						logados: $('#origem').val(),
						usuario: $('#usuarioIn').val(),
						ipAcesso: $('#ipAcessoIn').val(),
						inicio: $('#inicioIn').val(),
						fim: $('#fimIn').val()},
						function (response) {				
							$('#dataBank').empty();
							$('#dataBank').append(response);
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
				mensagem: "É necessário o preenchimento do campo \"Dt. Inicial\" para que a busca seja realizada!",
				title: "Erro de Pesquisa"
			});
		} else if (($("#inicioIn").val() != "" && $("#fimIn").val() == "")) {
			showErrorMessage ({
				mensagem: "É necessário o preenchimento do campo \"Dt. Final\" para que a busca seja realizada!",
				title: "Erro de Pesquisa"
			});			
		} else {
			if (flag) {
				flag= false;
				search();
			} else {
				if (pager.offSet > 0) {
					$.get("../CadastroAcesso",{
						gridLines: pager.limit, 
						limit: pager.limit,	
						isFilter: "0",
						offset: pager.offSet - pager.limit,
						from: "0",
						logados: $('#origem').val(),
						usuario: $('#usuarioIn').val(),
						ipAcesso: $('#ipAcessoIn').val(),
						inicio: $('#inicioIn').val(),
						fim: $('#fimIn').val()}, 						
						function(response){
							$('#dataBank').empty();
							$('#dataBank').append(response);
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
				mensagem: "É necessário o preenchimento do campo \"Dt. Inicial\" para que a busca seja realizada!",
				title: "Erro de Pesquisa"
			});			
		} else if (($("#inicioIn").val() != "" && $("#fimIn").val() == "")) {
			showErrorMessage ({
				mensagem: "É necessário o preenchimento do campo \"Dt. Final\" para que a busca seja realizada!",
				title: "Erro de Pesquisa"
			});
		} else {
			$.get("../CadastroAcesso",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: 0, 
				isFilter: "1",
				from: "0",
				logados: $('#origem').val(), 
				usuario: $('#usuarioIn').val(),
				ipAcesso: $('#ipAcessoIn').val(),
				inicio: $('#inicioIn').val(),
				fim: $('#fimIn').val()}, 
				function(response){
					$('#dataBank').empty();
					$('#dataBank').append(response);				
				}
			);
		}
		return false;
	}
	
	renderize= function(value) {
		if (($("#inicioIn").val() == "" && $("#fimIn").val() != "")) {
			showErrorMessage ({
				mensagem: "É necessário o preenchimento do campo \"Dt. Inicial\" para que a busca seja realizada!",
				title: "Erro de Pesquisa"
			});			
		} else if (($("#inicioIn").val() != "" && $("#fimIn").val() == "")) {
			showErrorMessage ({
				mensagem: "É necessário o preenchimento do campo \"Dt. Final\" para que a busca seja realizada!",
				title: "Erro de Pesquisa"
			});
		} else {
			if (flag) {
				flag= false;
				search();
			} else {
				pager.sortOffSet(value);
				$.get("../CadastroAcesso",{
					gridLines: pager.limit, 
					limit: pager.limit,
					offset: pager.offSet, 
					isFilter: "0",
					from: "0",
					logados: $('#origem').val(),
					usuario: $('#usuarioIn').val(),
					ipAcesso: $('#ipAcessoIn').val(),
					inicio: $('#inicioIn').val(),
					fim: $('#fimIn').val()},
					function(response) {
						$('#dataBank').empty();
						$('#dataBank').append(response);
					}
				);
				pager.calculeCurrentPage();
				pager.refreshPager();						
			}
		}
	}
	
	desconectUser = function() {
		var aux= mountPipeLine();
		if (aux == "") {
			showErrorMessage ({
				mensagem: "Selecione os usuários que deseja desconectar do sistema!",
				title: "Entrada inválida"
			});
		} else {
			$.get("../CadastroAcesso",{			
				from: "1",
				pipe: aux},
				function(response) {
					location.href = '../error_page.jsp?errorMsg=' + response +  
						'&lk=application/painel_web.jsp';
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
					pipe+= ", " + $('#ck' + (aux)).val();
				}
			}
		}
		return pipe;
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
	
	limparHistorico = function () {
		$.get("../CadastroAcesso",{			
			from: "0"},
			function(response) {
				if (response == 0) {
					showOkMessage ({
						mensagem: "Histórico de navegação limpo com sucesso!",
						title: "Entrada inválida"
					});	
				} else {
					showErrorMessage ({
						mensagem: "Não foi possível limpar o historico de navegação devido a um erro interno",
						title: "Entrada inválida"
					});
				}

			}
		);	
	}
	
});