var pager;
var flag= false;
var dataGrid;
var Message = false;

$(document).ready(function() {
	load = function() {
		pager = new Pager($('#gridLines').val(), 30, "../CadastroPedido");
		pager.mountPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Cadastro", "goToCadastro(");
		dataGrid.addOption("Parcelamento", "goToParcelamento(");						
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
				$.get("../CadastroPedido",{
					gridLines: pager.limit , 
					limit: pager.limit,	
					isFilter: "0", 
					offset: pager.offSet + pager.limit,
					origem: $('#origem').val(),
					fornecedorId: ($('#fornecedorId').val() == undefined)? "" : $('#fornecedorId').val(), 
					fantasia: ($('#fantasiaIn').val() == undefined)? "" : $('#fantasiaIn').val(),					
					rzSocial: ($('#rzSocialIn').val() == undefined)? "" : $('#rzSocialIn').val(),
					cnpj: ($('#cnpjIn').val() == undefined)? "" : $('#cnpjIn').val(),
					pedido: ($('#pedidoIn').val() == undefined)? "" : $('#pedidoIn').val(),
					cadastro: $('#cadastroIn').val(),
					documento: $('#documentoIn').val(),					
					nome: ($('#nomeIn').val() == undefined)? "": $('#nomeIn').val(),
					cpf: ($('#cpfIn').val() == undefined)? "" : $('#cpfIn').val(),
					rg: ($('#rgIn').val() == undefined)? "" : $('#rgIn').val(),
					nascimento: ($('#nascimentoIn').val() == undefined)? "" : $('#nascimentoIn').val(),
					from: "0",
					unidadeId: ($('#unidadeId').val() == "")? "" :
						$('#unidadeId').val()},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.nextPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");
				dataGrid.addOption("Parcelamento", "goToParcelamento(");				
			}			
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroPedido",{
					gridLines: pager.limit, 
					limit: pager.limit,	
					isFilter: "0", 
					offset: pager.offSet - pager.limit,
					origem: $('#origem').val(),
					fornecedorId: ($('#fornecedorId').val() == undefined)? "" : $('#fornecedorId').val(), 
					fantasia: ($('#fantasiaIn').val() == undefined)? "" : $('#fantasiaIn').val(),					
					rzSocial: ($('#rzSocialIn').val() == undefined)? "" : $('#rzSocialIn').val(),
					cnpj: ($('#cnpjIn').val() == undefined)? "" : $('#cnpjIn').val(),
					pedido: ($('#pedidoIn').val() == undefined)? "" : $('#pedidoIn').val(),
					cadastro: $('#cadastroIn').val(),
					documento: $('#documentoIn').val(),					
					nome: ($('#nomeIn').val() == undefined)? "": $('#nomeIn').val(),
					cpf: ($('#cpfIn').val() == undefined)? "" : $('#cpfIn').val(),
					rg: ($('#rgIn').val() == undefined)? "" : $('#rgIn').val(),
					nascimento: ($('#nascimentoIn').val() == undefined)? "" : $('#nascimentoIn').val(),
					from: "0",
					unidadeId: ($('#unidadeId').val() == "")? "" :
						$('#unidadeId').val()},
					function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);
				});
				pager.previousPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");
				dataGrid.addOption("Parcelamento", "goToParcelamento(");
			}			
		}
	}
	
	search= function() {
		$.get("../CadastroPedido",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1", 			
			origem: $('#origem').val(),
			fornecedorId: ($('#fornecedorId').val() == undefined)? "" : $('#fornecedorId').val(), 
			fantasia: ($('#fantasiaIn').val() == undefined)? "" : $('#fantasiaIn').val(),					
			rzSocial: ($('#rzSocialIn').val() == undefined)? "" : $('#rzSocialIn').val(),
			cnpj: ($('#cnpjIn').val() == undefined)? "" : $('#cnpjIn').val(),
			pedido: ($('#pedidoIn').val() == undefined)? "" : $('#pedidoIn').val(),
			cadastro: $('#cadastroIn').val(),
			documento: $('#documentoIn').val(),					
			nome: ($('#nomeIn').val() == undefined)? "": $('#nomeIn').val(),
			cpf: ($('#cpfIn').val() == undefined)? "" : $('#cpfIn').val(),
			rg: ($('#rgIn').val() == undefined)? "" : $('#rgIn').val(),
			nascimento: ($('#nascimentoIn').val() == undefined)? "" : $('#nascimentoIn').val(),
			from: "0",
			unidadeId: ($('#unidadeId').val() == "")? "" :
				$('#unidadeId').val()},
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
			$.get("../CadastroPedido",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: pager.offSet, 
				isFilter: "0", 
				origem: $('#origem').val(),
				fornecedorId: ($('#fornecedorId').val() == undefined)? "" : $('#fornecedorId').val(), 
				fantasia: ($('#fantasiaIn').val() == undefined)? "" : $('#fantasiaIn').val(),					
				rzSocial: ($('#rzSocialIn').val() == undefined)? "" : $('#rzSocialIn').val(),
				cnpj: ($('#cnpjIn').val() == undefined)? "" : $('#cnpjIn').val(),
				pedido: ($('#pedidoIn').val() == undefined)? "" : $('#pedidoIn').val(),
				cadastro: $('#cadastroIn').val(),
				documento: $('#documentoIn').val(),					
				nome: ($('#nomeIn').val() == undefined)? "": $('#nomeIn').val(),
				cpf: ($('#cpfIn').val() == undefined)? "" : $('#cpfIn').val(),
				rg: ($('#rgIn').val() == undefined)? "" : $('#rgIn').val(),
				nascimento: ($('#nascimentoIn').val() == undefined)? "" : $('#nascimentoIn').val(),
				from: "0",
				unidadeId: ($('#unidadeId').val() == "")? "" :
					$('#unidadeId').val()},
			function(response) {
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
			dataGrid = new DataGrid();
			dataGrid.addOption("Cadastro", "goToCadastro(");
			dataGrid.addOption("Parcelamento", "goToParcelamento(");			
		}
	}
	
	orderModify = function() {		
		$.get("../CadastroPedido",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1",
			origem: $('#origem').val(),
			fornecedorId: ($('#fornecedorId').val() == undefined)? "" : $('#fornecedorId').val(), 
			fantasia: ($('#fantasiaIn').val() == undefined)? "" : $('#fantasiaIn').val(),					
			rzSocial: ($('#rzSocialIn').val() == undefined)? "" : $('#rzSocialIn').val(),
			cnpj: ($('#cnpjIn').val() == undefined)? "" : $('#cnpjIn').val(),
			pedido: ($('#pedidoIn').val() == undefined)? "" : $('#pedidoIn').val(),
			cadastro: $('#cadastroIn').val(),
			documento: $('#documentoIn').val(),					
			nome: ($('#nomeIn').val() == undefined)? "": $('#nomeIn').val(),
			cpf: ($('#cpfIn').val() == undefined)? "" : $('#cpfIn').val(),
			rg: ($('#rgIn').val() == undefined)? "" : $('#rgIn').val(),
			nascimento: ($('#nascimentoIn').val() == undefined)? "" : $('#nascimentoIn').val(),
			from: "0",
			unidadeId: ($('#unidadeId').val() == "")? "" :
				$('#unidadeId').val()},
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
	 
	goToCadastro = function(value) {
		location.href= 'pedido.jsp?state=1&id=' + value + "&origem=" + $('#origem').val();
	}
	
	goToParcelamento = function(value) {
		location.href = 'parcela_compra.jsp?id=' + value + "&origem=" + $('#origem').val();
	}	
});