var pager;
var flag= false;
var dataGrid;
var Message = false;

$(document).ready(function() {	
	
	load = function() {		
		pager = new Pager($('#gridLines').val(), 30, "../CadastroClienteJuridico");
		pager.mountPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Cadastro", "goToCadastro(");
		dataGrid.addOption("Anexo", "goToAnexo(");
		dataGrid.addOption("Boletos", "goToBoletos(");
		dataGrid.addOption("Funcionários", "goToFuncionario(");
		dataGrid.addOption("Histórico de Faturas", "goToFatura(");
		dataGrid.addOption("Borderô", "goToBordero(");				
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
				$.get("../CadastroClienteJuridico",{gridLines: pager.limit , 
					limit: pager.limit,	isFilter: "0", offset: pager.offSet + pager.limit,
					referenciaIn: $('#referenciaIn').val(), 
					rzSocial: $('#razaoSocialIn').val(), fantasia: $('#fantasiaIn').val(),
					nomeContato: $('#nomeContatoIn').val(),
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
				dataGrid.addOption("Anexo", "goToAnexo(");
				dataGrid.addOption("Boletos", "goToBoletos(");
				dataGrid.addOption("Funcionários", "goToFuncionario(");				
				dataGrid.addOption("Histórico de Faturas", "goToFatura(");
				dataGrid.addOption("Borderô", "goToBordero(");				
			}			
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroClienteJuridico",{gridLines: pager.limit, 
					limit: pager.limit,	isFilter: "0", offset: pager.offSet - pager.limit,	
					referenciaIn: $('#referenciaIn').val(), 
					rzSocial: $('#razaoSocialIn').val(), fantasia: $('#fantasiaIn').val(),
					nomeContato: $('#nomeContatoIn').val(),
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
				dataGrid.addOption("Anexo", "goToAnexo(");
				dataGrid.addOption("Boletos", "goToBoletos(");
				dataGrid.addOption("Funcionários", "goToFuncionario(");				
				dataGrid.addOption("Histórico de Faturas", "goToFatura(");
 				dataGrid.addOption("Borderô", "goToBordero(");				
			}			
		}
	}
	
	search= function() {
		$.get("../CadastroClienteJuridico",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1", 			
			referenciaIn: $('#referenciaIn').val(), 
			rzSocial: $('#razaoSocialIn').val(), 
			fantasia: $('#fantasiaIn').val(),
			nomeContato: $('#nomeContatoIn').val(),
			unidadeId: ($('#unidadeId').val() == "")? "" : $('#unidadeId').val(),
			order: getOrderGd(),					
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
			$.get("../CadastroClienteJuridico",{gridLines: pager.limit, limit: pager.limit,
			offset: pager.offSet, isFilter: "0", referenciaIn: $('#referenciaIn').val(), 
			rzSocial: $('#razaoSocialIn').val(), fantasia: $('#fantasiaIn').val(),
			nomeContato: $('#nomeContatoIn').val(), 
			unidadeId: ($('#unidadeId').val() == "")? "" :
				$('#unidadeId').val(),
			order: getOrderGd(),					
			ativoChecked: $('#ativoChecked').val()},
			function(response) {
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
			dataGrid = new DataGrid();
			dataGrid.addOption("Cadastro", "goToCadastro(");
			dataGrid.addOption("Anexo", "goToAnexo(");
			dataGrid.addOption("Boletos", "goToBoletos(");
			dataGrid.addOption("Funcionários", "goToFuncionario(");			
			dataGrid.addOption("Histórico de Faturas", "goToFatura(");
			dataGrid.addOption("Borderô", "goToBordero(");				
		}
	}
	
	orderModify = function() {		
		$.get("../CadastroClienteJuridico",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1", 			
			referenciaIn: $('#referenciaIn').val(), 
			rzSocial: $('#razaoSocialIn').val(), 
			fantasia: $('#fantasiaIn').val(),
			nomeContato: $('#nomeContatoIn').val(),
			unidadeId: ($('#unidadeId').val() == "")? "" : $('#unidadeId').val(),
			order: getOrderGd(),					
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
		showLoader();
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
		if (condition) {
			if (parseInt($('#gridLines').val()) != pager.recordCount) {
				pager.Search();
			}			
		}
	});
	
	$("input[type='text']").change(function() {
		flag= true;
	});	
	
	
	goToCadastro = function(value) {
		location.href= 'cadastro_cliente_juridico.jsp?state=1&id=' + value;
	}
	
	goToAnexo = function(value) {
		alert("Em Manutenção");
	}
	
	goToBoletos = function(value) {
		location.href = "boleto.jsp?id=" + value + "&origem=j";
	}
	
	goToFuncionario = function(value) {
		location.href= 'cliente_fisico.jsp?id=' + value;
	}
	
	goToBordero = function(value) {
		location.href= 'bordero_empresa.jsp?id=' + value;
	}
	
	goToFatura= function(value) {
		location.href = "fatura_empresa.jsp?id=" + value;		
	}	
});