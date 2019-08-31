var pager;

$(document).ready(function() {
	pager = new Pager($('#gridLines').val(), 30, "../CadastroBoleto");
	pager.mountPager();
	
	
	getNext = function(){
		if ($('#EmissaoInicioIn').val() != "" && $('#EmissaoFimIn').val() == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma data para \"Emissão Final\"!",
				title: "Erro de Pesquisa"
			});
		} else if ($('#EmissaoInicioIn').val() == "" && $('#EmissaoFimIn').val() != "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma data para \"Emissão Inicial\"!",
				title: "Erro de Pesquisa"
			});
		} else if ($('#vencimentoInicioIn').val() == "" && $('#vencimentoFimIn').val() != "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma data para \"Vencimento Inicial\"!",
				title: "Erro de Pesquisa"
			});
		} else if ($('#vencimentoInicioIn').val() != "" && $('#vencimentoFimIn').val() == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma data para \"Vencimento Final\"!",
				title: "Erro de Pesquisa"
			});
		} else {
			if (flag) {
				flag= false;
				search();
			} else {
				if ((pager.limit * pager.currentPage) < pager.recordCount) {
					$.get("../CadastroBoleto",{
						gridLines: pager.limit ,
						limit: pager.limit,
						isFilter: "0",
						offset: pager.offSet + pager.limit,
						codigo: $('#codigoIn').val(),
						codUser: $('#codUser').val(),
						EmissaoInicio: $('#EmissaoInicioIn').val(),						
						EmissaoFim: $('#EmissaoFimIn').val(),					
						vencimentoInicio: $("#vencimentoInicioIn").val(),
						vencimentoFim: $("#vencimentoFimIn").val(),
						from: "0"},
					function (response) {				
						$('#dataBank').empty();
						$('#dataBank').append(response);
					});
					pager.nextPage();
					dataGrid = new DataGrid();				
				}			
			}
		}
	}
	
	getPrevious= function(){
		if ($('#EmissaoInicioIn').val() != "" && $('#EmissaoFimIn').val() == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma data para \"Emissão Final\"!",
				title: "Erro de Pesquisa"
			});
		} else if ($('#EmissaoInicioIn').val() == "" && $('#EmissaoFimIn').val() != "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma data para \"Emissão Inicial\"!",
				title: "Erro de Pesquisa"
			});
		} else if ($('#vencimentoInicioIn').val() == "" && $('#vencimentoFimIn').val() != "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma data para \"Vencimento Inicial\"!",
				title: "Erro de Pesquisa"
			});
		} else if ($('#vencimentoInicioIn').val() != "" && $('#vencimentoFimIn').val() == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma data para \"Vencimento Final\"!",
				title: "Erro de Pesquisa"
			});
		} else {
			if (flag) {
				flag= false;
				search();
			} else {
				if (pager.offSet > 0) {
					$.get("../CadastroBoleto",{
						gridLines: pager.limit, 
						limit: pager.limit,
						isFilter: "0",
						offset: pager.offSet - pager.limit,	
						codigo: $('#codigoIn').val(),
						codUser: $('#codUser').val(),
						EmissaoInicio: $('#EmissaoInicioIn').val(),						
						EmissaoFim: $('#EmissaoFimIn').val(),					
						vencimentoInicio: $("#vencimentoInicioIn").val(),
						vencimentoFim: $("#vencimentoFimIn").val(),
						from: "0"},
						function(response){
							$('#dataBank').empty();
							$('#dataBank').append(response);
					});
					pager.previousPage();
					dataGrid = new DataGrid();
				}			
			}
		}
	}
	
	search= function() {
		if ($('#EmissaoInicioIn').val() != "" && $('#EmissaoFimIn').val() == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma data para \"Emissão Final\"!",
				title: "Erro de Pesquisa"
			});
		} else if ($('#EmissaoInicioIn').val() == "" && $('#EmissaoFimIn').val() != "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma data para \"Emissão Inicial\"!",
				title: "Erro de Pesquisa"
			});
		} else if ($('#vencimentoInicioIn').val() == "" && $('#vencimentoFimIn').val() != "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma data para \"Vencimento Inicial\"!",
				title: "Erro de Pesquisa"
			});
		} else if ($('#vencimentoInicioIn').val() != "" && $('#vencimentoFimIn').val() == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma data para \"Vencimento Final\"!",
				title: "Erro de Pesquisa"
			});
		} else {
			$.get("../CadastroBoleto",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: 0, 
				isFilter: "1", 
				codigo: $('#codigoIn').val(),
				codUser: $('#codUser').val(),
				EmissaoInicio: $('#EmissaoInicioIn').val(),						
				EmissaoFim: $('#EmissaoFimIn').val(),					
				vencimentoInicio: $("#vencimentoInicioIn").val(),
				vencimentoFim: $("#vencimentoFimIn").val(),
				from: "0"},
				function(response){
					$('#dataBank').empty();
					$('#dataBank').append(response);				
				}
			);
		}		
		return false;
	}
	
	renderize= function(value) {
		if ($('#EmissaoInicioIn').val() != "" && $('#EmissaoFimIn').val() == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma data para \"Emissão Final\"!",
				title: "Erro de Pesquisa"
			});
		} else if ($('#EmissaoInicioIn').val() == "" && $('#EmissaoFimIn').val() != "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma data para \"Emissão Inicial\"!",
				title: "Erro de Pesquisa"
			});
		} else if ($('#vencimentoInicioIn').val() == "" && $('#vencimentoFimIn').val() != "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma data para \"Vencimento Inicial\"!",
				title: "Erro de Pesquisa"
			});
		} else if ($('#vencimentoInicioIn').val() != "" && $('#vencimentoFimIn').val() == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione uma data para \"Vencimento Final\"!",
				title: "Erro de Pesquisa"
			});
		} else {
			if (flag) {
				flag= false;
				search();
			} else {
				pager.sortOffSet(value);
				$.get("../CadastroBoleto",{
					gridLines: pager.limit, 
					limit: pager.limit,
					offset: pager.offSet, 
					isFilter: "0", 
					codigo: $('#codigoIn').val(),
					codUser: $('#codUser').val(),
					EmissaoInicio: $('#EmissaoInicioIn').val(),						
					EmissaoFim: $('#EmissaoFimIn').val(),					
					vencimentoInicio: $("#vencimentoInicioIn").val(),
					vencimentoFim: $("#vencimentoFimIn").val(),
					from: "0"},
				function(response) {
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.calculeCurrentPage(); 	
				pager.refreshPager();
				dataGrid = new DataGrid();
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
	
	$("frame[name=ad_frame]").addClass("cpEsconde");
	
	selectAll = function() {
		aux = -1;
		while ($('#ck' + (++aux)).val() != undefined) {
			if (!document.getElementById("ck" + aux).checked) {
				document.getElementById("ck" + aux).checked = true;				
			} else {
				document.getElementById("ck" + aux).checked = false;
			}
		}		
	}
	
	mountPipeLine = function() {
		aux = -1;
		pipe = "";
		isFirst = true;
		lastId = 0;
		while($('#ck' + (++aux)).val() != undefined) {
			if (document.getElementById("ck" + aux).checked) {				
				if (isFirst) {
					isFirst = false;
					pipe+= $('#ck' + (aux)).val();
					lastId = aux;
				} else {
					flag = true; 
					pipe+= "@" + $('#ck' + (aux)).val();
					lastId = aux;
				}
			}
		}
		return pipe;
	}
	
	
	excluir = function name() {
		var aux = mountPipeLine();
		if (aux == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione os registros que deseja excluir!",
				title: "Erro de Exclusão"
			});
		} else {
	 		showOption({
				title: "Exclusão de Boleto",
				mensagem: "Esta ação irá excluir permanentemente os registros selecionados do sistema. Tem certeza que deseja excluir os registros?",
				icone: "w",
				width: 400,
				show: 'fade',
		 		hide: 'clip',
				buttons: {
					"Não": function() {
						$(this).dialog('close');
					},
					"Sim": function () {
						$.get("../CadastroBoleto",{
							pipe: aux,
							from: "2"},
							function(response) {
								location.href = "../error_page.jsp?errorMsg=" + response + 
									"&lk=application/cliente_fisico.jsp";
							}
						);
					 	$(this).dialog('close');
					}
				} 
			});			
		}
	}
	
	cancelar = function() {
	 	var aux = mountPipeLine();
		if (aux == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione os registros que deseja cancelar!",
				title: "Erro de Cancelamento"
			});
		} else {
	 		showOption({
				title: "Cancelamento de Boleto",
				mensagem: "Esta ação irá cancelar os registros selecionados. Tem certeza que deseja cancelar os registros?",
				icone: "w",
				width: 400,
				show: 'fade',
		 		hide: 'clip',
				buttons: {
					"Não": function() {
						$(this).dialog('close');
					},
					"Sim": function () {
						$.get("../CadastroBoleto",{
							pipe: aux,
							from: "3"},
							function(response) {
								location.href = "../error_page.jsp?errorMsg=" + response + 
									"&lk=application/cliente_fisico.jsp";
							}
						);
					 	$(this).dialog('close');
					}
				} 
			});			
		}
	}
	
	baixa = function() {
	 	var aux = mountPipeLine();
		if (aux == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione os registros que deseja dar baixa!",
				title: "Erro de Exclusão"
			});
		} else {
	 		$.get("../CadastroBoleto",{
				pipe: aux,
				from: "4"},
				function(response) {
					location.href = "../error_page.jsp?errorMsg=" + response + 
						"&lk=application/cliente_fisico.jsp";
				}
			);			
		}
	}
	
	noAccess = function() {
		showErrorMessage ({
			mensagem: "Para realizar esta operação é necessário abrir o caixa.",
			title: "Acesso Negado"
		});
	}
	
	imprimir = function() {
		aux = mountPipeLine();
		if (aux == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "Selecione os registros que deseja imprimir!",
				title: "Erro de Exclusão"
			});
		} else {
			aux = pipeToVirgula(aux);
			var top = (screen.height - 200)/2;
			var left= (screen.width - 600)/2;
			showOption({
				title: "Exclusão de Boleto",
				mensagem: "Selecione a impressão desejada.",
				width: 400,
				buttons: {					
		 			"Boleto A4" : function () {
		 				window.open("../GeradorRelatorio?rel=135&parametros=12@" + aux, 'nova', 
		 					'width= 800, height= 600, top=0' + top + ', ' +	'left= ' + left);
						$(this).dialog('close');
		 			},
		 			"Boleto" : function () {
		 				window.open("../GeradorRelatorio?rel=136&parametros=13@" + aux, 'nova', 
		 					'width= 800, height= 600, top=0' + top + ', ' +	'left= ' + left);
						$(this).dialog('close');
		 			},
		 			"Fatura" : function () {
						if ($('#tipoBoleto').val() == 'f') {
			 				window.open("../GeradorRelatorio?rel=134&parametros=11@" + aux, 'nova', 
			 					'width= 800, height= 600, top=0' + top + ', ' +	'left= ' + left);
						} else {
							window.open("../GeradorRelatorio?rel=137&parametros=15@" + aux, 'nova', 
			 					'width= 800, height= 600, top=0' + top + ', ' +	'left= ' + left);							
						}
						$(this).dialog('close');
		 			},
		 			"Cancelar": function() {
		 				$(this).dialog('close');		 				
					}
				} 
			});
		}
	}
	
});