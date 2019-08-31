var pager;
var flag= false;
var dataGrid;
var Message = false;

$(document).ready(function() {	
	
	load = function() {		
		pager = new Pager($('#gridLines').val(), 30, "../CadastroPrestadorServico");
		pager.mountPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Cadastro", "goToCadastro(");		
		dataGrid.addOption("Borderô", "goToBordero(");
		dataGrid.addOption("Gerar Pedido", "goToNewPedido(");		
		dataGrid.addOption("Histórico de Pedidos", "goToCompras(");
		dataGrid.addOption("Gerar Fatura", "generateGroup(");
		dataGrid.addOption("Histórico de Faturas", "goToAgrupamento(");
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
				$.get("../CadastroPrestadorServico",{
					gridLines: pager.limit , 
					limit: pager.limit,	
					isFilter: "0", 
					offset: pager.offSet + pager.limit,
					referenciaIn: $('#referenciaIn').val(), 
					nomeIn: $('#nomeIn').val(), 
					cpfIn: $('#cpfIn').val(),
					ramoIn : $('#ramoIn').val(),
					order: getOrderGd(),
					unidadeId: ($('#unidadeId').val() == "")? "" :
						$('#unidadeId').val(),					
					ativoChecked: $('#ativoChecked').val()},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.nextPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");		
				dataGrid.addOption("Borderô", "goToBordero(");
				dataGrid.addOption("Gerar Pedido", "goToNewPedido(");		
				dataGrid.addOption("Histórico de Pedidos", "goToCompras(");
				dataGrid.addOption("Gerar Fatura", "generateGroup(");
				dataGrid.addOption("Histórico de Faturas", "goToAgrupamento(");			
			}			
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroPrestadorServico",{
					gridLines: pager.limit, 
					limit: pager.limit,	
					isFilter: "0", 
					offset: pager.offSet - pager.limit,	
					referenciaIn: $('#referenciaIn').val(), 
					nomeIn: $('#nomeIn').val(), 
					cpfIn: $('#cpfIn').val(),
					ramoIn : $('#ramoIn').val(),
					order: getOrderGd(),
					unidadeId: ($('#unidadeId').val() == "")? "" :
						$('#unidadeId').val(),					
					ativoChecked: $('#ativoChecked').val()},
					function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);
				});
				pager.previousPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");		
				dataGrid.addOption("Borderô", "goToBordero(");
				dataGrid.addOption("Gerar Pedido", "goToNewPedido(");		
				dataGrid.addOption("Histórico de Pedidos", "goToCompras(");
				dataGrid.addOption("Gerar Fatura", "generateGroup(");
				dataGrid.addOption("Histórico de Faturas", "goToAgrupamento(");
			}			
		}
	}
	
	search= function() {
		$.get("../CadastroPrestadorServico",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1", 			
			referenciaIn: $('#referenciaIn').val(), 
			nomeIn: $('#nomeIn').val(), 
			cpfIn: $('#cpfIn').val(),
			ramoIn : $('#ramoIn').val(),
			order: getOrderGd(),
			unidadeId: ($('#unidadeId').val() == "")? "" :
				$('#unidadeId').val(),					
			ativoChecked: $('#ativoChecked').val()},
			function(response){
				$('#dataBank').empty();
				$('#dataBank').append(response);				
			});
		return false;
	}
	
	renderize= function(value) {
		if (flag) {
			flag= false;
			search();
		} else {
			pager.sortOffSet(value);
			$.get("../CadastroPrestadorServico",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: pager.offSet, 
				isFilter: "0", 
				referenciaIn: $('#referenciaIn').val(), 
				nomeIn: $('#nomeIn').val(), 
				cpfIn: $('#cpfIn').val(),
				ramoIn : $('#ramoIn').val(),
				order: getOrderGd(),
				unidadeId: ($('#unidadeId').val() == "")? "" :
					$('#unidadeId').val(),					
				ativoChecked: $('#ativoChecked').val()},
			function(response) {
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
			dataGrid = new DataGrid();
			dataGrid.addOption("Cadastro", "goToCadastro(");		
			dataGrid.addOption("Borderô", "goToBordero(");
			dataGrid.addOption("Gerar Pedido", "goToNewPedido(");		
			dataGrid.addOption("Histórico de Pedidos", "goToCompras(");
			dataGrid.addOption("Gerar Fatura", "generateGroup(");
			dataGrid.addOption("Histórico de Faturas", "goToAgrupamento(");
		}
	}
	
	orderModify = function() {		
		$.get("../CadastroPrestadorServico",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1", 			
			referenciaIn: $('#referenciaIn').val(), 
			nomeIn: $('#nomeIn').val(), 
			cpfIn: $('#cpfIn').val(),
			ramoIn : $('#ramoIn').val(),
			order: getOrderGd(),
			unidadeId: ($('#unidadeId').val() == "")? "" :
				$('#unidadeId').val(),					
			ativoChecked: $('#ativoChecked').val()},
			function(response){
				$('#dataBank').empty();
				$('#dataBank').append(response);				
			});
		return false;
	}
	
	pagTeste = function() {
		var aux = "";
		var count= 0;
		while ($('#ck' + count).val() != undefined) {
			if(document.getElementById("ck" + count).checked) {
				if (count == 0) {
					aux+= $('#ck' + count).val();
				} else {
					aux+= "@" + $('#ck' + count).val();
				}
			}
			count++;
		}
		alert(aux);
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
	
	goToCadastro = function (value) {
		location.href= 'cadastro_prestador_servico.jsp?state=1&id=' + value;
	}
	
	goToNewPedido = function (value) {
		location.href = 'pedido.jsp?idFornecedor=' + value + "&origem=prest";
	}
	
	goToCompras = function(value) {
		location.href= 'compra.jsp?origem=prest&idFornecedor=' + value;
	}
	
	goToBordero = function (value) {
		location.href= 'bordero_fornecedor.jsp?origem=prest&idFornecedor=' + value;
	}
	
	goToAgrupamento = function (value) {
		location.href = 'agrupamento.jsp?idFornecedor=' + value + '&origem=prest';
	}
	
	generateGroup = function (value) {
		$('#geracaoWindow').dialog({
	 		width: 220,
	 		modal: true,
	 		zindex: 0,
	 		show: 'fade',
			hide: 'clip',
	 		buttons: {
	 			"Cancelar": function () {
	 				$(this).dialog('close');
	 			},
	 			"Gerar" : function () {	 				
	 				$.get("../ParcelaCompraAdapter",{							
							idFornecedor: value, 
							mes: $('#mesId').val(), 
							ano: $('#anoId').val()},
						function (response) {
							if (response == "0") {
								showOkMessage({
									mensagem: "Geração realizada com sucesso!",
									title: "Sucesso"
								});
							} else if (response == "1") {
								showErrorMessage ({
									mensagem: "Não foi possível gerar o agrupamento devido a um erro interno!",
									title: "Erro de Geração"
								});
							} else {
								showErrorMessage ({
									mensagem: "Não existem parcelas para serem agrupadas!",
									title: "Erro de Geração"
								});
							}
						}
					);
					$(this).dialog('close');
 				}
	 		},
	 		close: function () {
	 			$(this).dialog('destroy');
	 		}
		});
	}
});