var pager;
var flag= false;
var dataGrid;

$(document).ready(function() {
	pager = new Pager($('#gridLines').val(), 30, "../DependenteGet");
	pager.mountPager();
	dataGrid = new DataGrid();
	dataGrid.addOption("Cadastro", "goToCadastro(");
	dataGrid.addOption("Mensalidades", "goToMensalidades(");
	dataGrid.addOption("Tratamentos", "goToTratamento(");
	$("#codUserIn").focus();

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
});

function appendMenu(value){
	dataGrid.expande(value, false);		
}

function getNext(){
	if (flag) {
		flag= false;
		search();
	} else {
		if ((pager.limit * pager.currentPage) < pager.recordCount) {
			$.get("../DependenteGet",{
				gridLines: pager.limit , 
				limit: pager.limit, 
				isFilter: "0", 
				offset: pager.offSet + pager.limit,
				refTitular: $('#refTitularIn').val(), 
				referencia: $('#referenciaIn').val(),
				nomeIn: $('#nomeIn').val(),
				cpfIn: $('#cpfIn').val(), 
				nascimentoIn: $('#nascimentoIn').val(),
				fone: $("#telIn").val(),
				codUser: $("#codUserIn").val(),
				plano: $('#planoIn').val(),
				ativoChecked: $('#ativoChecked').val(),
				unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
					$('#unidadeId').val(),
					order: getOrderGd()},
					function (response) {				
						$('#dataBank').empty();
						$('#dataBank').append(response);
					});
			pager.nextPage();
			dataGrid = new DataGrid();
			dataGrid.addOption("Cadastro", "goToCadastro(");
			dataGrid.addOption("Mensalidades", "goToMensalidades(");
			dataGrid.addOption("Tratamentos", "goToTratamento(");
		}			
	}
}

function getPrevious(){
	if (flag) {
		flag= false;
		search();
	} else {
		if (pager.offSet > 0) {
			$.get("../DependenteGet",{
				gridLines: pager.limit, 
				limit: pager.limit,
				isFilter: "0",
				offset: pager.offSet - pager.limit,	
				refTitular: $('#refTitularIn').val(), 
				referencia: $('#referenciaIn').val(),
				nomeIn: $('#nomeIn').val(),
				cpfIn: $('#cpfIn').val(), 
				nascimentoIn: $('#nascimentoIn').val(),
				fone: $("#telIn").val(),
				codUser: $("#codUserIn").val(),
				plano: $('#planoIn').val(),				
				ativoChecked: $('#ativoChecked').val(),
				unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
					$('#unidadeId').val(),
					order: getOrderGd()},
					function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);
					});
			pager.previousPage();
			dataGrid = new DataGrid();
			dataGrid.addOption("Cadastro", "goToCadastro(");
			dataGrid.addOption("Mensalidades", "goToMensalidades(");
			dataGrid.addOption("Tratamentos", "goToTratamento(");
		}			
	}
}

function search() {
	if ($("#codUserIn").val() != "") {
		var aux = "cadastro_cliente_fisico.jsp?state=1&id=" + 
		removeZeroToLeft($("#codUserIn").val());			
		location.href = aux;
	} else {
		$.get("../DependenteGet",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1", 
			refTitular: $('#refTitularIn').val(), 
			referencia: $('#referenciaIn').val(),
			nomeIn: $('#nomeIn').val(),
			cpfIn: $('#cpfIn').val(), 
			nascimentoIn: $('#nascimentoIn').val(),
			fone: $("#telIn").val(),
			codUser: $("#codUserIn").val(),
			plano: $('#planoIn').val(),				
			ativoChecked: $('#ativoChecked').val(),
			unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
				$('#unidadeId').val(),
				order: getOrderGd()},
				function(response){
					$('#dataBank').empty();
					$('#dataBank').append(response);				
				});		 		
	}	
	return false;
}

function renderize(value) {
	if (flag) {
		flag= false;
		search();
	} else {
		pager.sortOffSet(value);
		$.get("../DependenteGet",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: pager.offSet, 
			isFilter: "0", 
			refTitular: $('#refTitularIn').val(), 
			referencia: $('#referenciaIn').val(),
			nomeIn: $('#nomeIn').val(),
			cpfIn: $('#cpfIn').val(), 
			nascimentoIn: $('#nascimentoIn').val(),
			fone: $("#telIn").val(),
			codUser: $("#codUserIn").val(),
			plano: $('#planoIn').val(),				
			ativoChecked: $('#ativoChecked').val(),
			unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
				$('#unidadeId').val(),
				order: getOrderGd()},
				function(response) {
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
		pager.calculeCurrentPage(); 	
		pager.refreshPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Cadastro", "goToCadastro(");
		dataGrid.addOption("Mensalidades", "goToMensalidades(");
		dataGrid.addOption("Tratamentos", "goToTratamento(");
	}
}

function orderModify() {		
	$.get("../DependenteGet",{
		gridLines: pager.limit, 
		limit: pager.limit,
		offset: 0, 
		isFilter: "1", 
		refTitular: $('#refTitularIn').val(), 
		referencia: $('#referenciaIn').val(),
		nomeIn: $('#nomeIn').val(),
		cpfIn: $('#cpfIn').val(), 
		nascimentoIn: $('#nascimentoIn').val(),
		fone: $("#telIn").val(),
		codUser: $("#codUserIn").val(),
		plano: $('#planoIn').val(),				
		ativoChecked: $('#ativoChecked').val(),
		unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
			$('#unidadeId').val(),
			order: getOrderGd()},
			function(response){
				$('#dataBank').empty();
				$('#dataBank').append(response);				
			});			
	return false;
}

function goToCadastro(value) {		
	location.href= 'cadastro_cliente_fisico.jsp?state=1&dep=' + value;
}
			
function goToMensalidades(value) {			
	location.href = "mensalidade.jsp?dep=" + value;
}

function goToTratamento(value) {		
	location.href = "orcamento.jsp?id=-1&dep=" + value;
}