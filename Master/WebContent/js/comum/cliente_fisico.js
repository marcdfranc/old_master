var pager;
var flag= false;
var dataGrid;

function load() {		
	pager = new Pager($('#gridLines').val(), 30, "../CadastroClienteFisico");
	pager.mountPager();
	dataGrid = new DataGrid();
	dataGrid.addOption("Cadastro", "goToCadastro(");
	dataGrid.addOption("Anexo", "goToAnexo(");
	dataGrid.addOption("Mensalidades", "goToMensalidades(");
	//dataGrid.addOption("Boletos", "goToBoletos(");		
	dataGrid.addOption("Orç. de Empresas", "goToOrcamento(");
	dataGrid.addOption("Orç. de Profissionais", "goToTratamento(");
	$("#codUserIn").focus();
}

function appendMenu(value){
	dataGrid.expande(value, false);		
}

function getNext(){
	if (flag) {
		flag= false;
		search();
	} else {
		if ((pager.limit * pager.currentPage) < pager.recordCount) {
			$.get("../CadastroClienteFisico",{
				gridLines: pager.limit , 
				limit: pager.limit, 
				isFilter: "0",
				from: "1", 
				offset: pager.offSet + pager.limit,
				referenciaIn: $('#referenciaIn').val(),
				diasCarteira: $('#diasCarteira').val(),
				nomeIn: $('#nomeIn').val(),
				cpfIn: $('#cpfIn').val(), 
				nascimentoIn: $('#nascimentoIn').val(),
				ucIn: $("#ucIn").val(),
				unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
					$('#unidadeId').val(),
				plano: $('#planoIn').val(),				
				ativoChecked: $('#ativoChecked').val(),
				order: getOrderGd(),
				codUser: $("#codUserIn").val(),
				empresaId: $("#empresaId").val()},
			function (response) {				
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.nextPage();
			dataGrid = new DataGrid();
			dataGrid.addOption("Cadastro", "goToCadastro(");
			dataGrid.addOption("Anexo", "goToAnexo(");
			dataGrid.addOption("Mensalidades", "goToMensalidades(");
			//dataGrid.addOption("Boletos", "goToBoletos(");
			dataGrid.addOption("Orç. de Empresas", "goToOrcamento(");
			dataGrid.addOption("Orç. de Profissionais", "goToTratamento(");
		}			
	}
}

function getPrevious(){
	if (flag) {
		flag= false;
		search();
	} else {
		if (pager.offSet > 0) {
			$.get("../CadastroClienteFisico",{
				gridLines: pager.limit, 
				limit: pager.limit,
				isFilter: "0",
				from: "1",
				offset: pager.offSet - pager.limit,	
				referenciaIn: $('#referenciaIn').val(),
				diasCarteira: $('#diasCarteira').val(),					 
				nomeIn: $('#nomeIn').val(),
				cpfIn: $('#cpfIn').val(), 
				nascimentoIn: $('#nascimentoIn').val(),
				ucIn: $("#ucIn").val(),
				unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
					$('#unidadeId').val(), plano: $('#planoIn').val(),				
				ativoChecked: $('#ativoChecked').val(),
				order: getOrderGd(),
				codUser: $("#codUserIn").val(),
				empresaId: $("#empresaId").val()},
				function(response){
					$('#dataBank').empty();
					$('#dataBank').append(response);
			});
			pager.previousPage();
			dataGrid = new DataGrid();
			dataGrid.addOption("Cadastro", "goToCadastro(");
			dataGrid.addOption("Anexo", "goToAnexo(");
			dataGrid.addOption("Mensalidades", "goToMensalidades(");
			//dataGrid.addOption("Boletos", "goToBoletos(");
			dataGrid.addOption("Orç. de Empresas", "goToOrcamento(");
			dataGrid.addOption("Orç. de Profissionais", "goToTratamento(");
		}			
	}
}

function search() {
	if ($("#codUserIn").val() != "") {
		var aux = "cadastro_cliente_fisico.jsp?state=1&id=" + 
			removeZeroToLeft($("#codUserIn").val());			
		location.href = aux;
	} else {
		$.get("../CadastroClienteFisico",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1",
			from: "1", 
			referenciaIn: $('#referenciaIn').val(), 
			diasCarteira: $('#diasCarteira').val(),
			nomeIn: $('#nomeIn').val(),
			cpfIn: $('#cpfIn').val(),				
			nascimentoIn: $('#nascimentoIn').val(),
			ucIn: $("#ucIn").val(),
			unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
				$('#unidadeId').val(), plano: $('#planoIn').val(), 
			ativoChecked: $('#ativoChecked').val(),
			order: getOrderGd(),
			codUser: $("#codUserIn").val(),
			empresaId: $("#empresaId").val()},
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
		$.get("../CadastroClienteFisico",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: pager.offSet, 
			isFilter: "0",
			from: "1", 
			referenciaIn: $('#referenciaIn').val(),
			diasCarteira: $('#diasCarteira').val(), 
			nomeIn: $('#nomeIn').val(),
			cpfIn: $('#cpfIn').val(), 
			nascimentoIn: $('#nascimentoIn').val(),
			ucIn: $("#ucIn").val(), 
			unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
					$('#unidadeId').val(), plano: $('#planoIn').val(), 
			ativoChecked: $('#ativoChecked').val(),
			order: getOrderGd(),
			codUser: $("#codUserIn").val(),
			empresaId: $("#empresaId").val()},
		function(response) {
			$('#dataBank').empty();
			$('#dataBank').append(response);
		});
		pager.calculeCurrentPage(); 	
		pager.refreshPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Cadastro", "goToCadastro(");
		dataGrid.addOption("Anexo", "goToAnexo(");
		dataGrid.addOption("Mensalidades", "goToMensalidades(");
		//dataGrid.addOption("Boletos", "goToBoletos(");
		dataGrid.addOption("Orç. de Empresas", "goToOrcamento(");
		dataGrid.addOption("Orç. de Profissionais", "goToTratamento(");
	}
}

function orderModify() {
	$.get("../CadastroClienteFisico",{
		gridLines: pager.limit, 
		limit: pager.limit,
		offset: 0, 
		isFilter: "1",
		from: "1", 
		referenciaIn: $('#referenciaIn').val(), 
		diasCarteira: $('#diasCarteira').val(),
		nomeIn: $('#nomeIn').val(),
		cpfIn: $('#cpfIn').val(), 
		nascimentoIn: $('#nascimentoIn').val(),
		ucIn: $("#ucIn").val(),
		unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
			$('#unidadeId').val(), plano: $('#planoIn').val(), 
		ativoChecked: $('#ativoChecked').val(),
		order: getOrderGd(),
		codUser: $("#codUserIn").val(),
		empresaId: $("#empresaId").val()},
		function(response){
			$('#dataBank').empty();
			$('#dataBank').append(response);				
		});			
	return false;
}

function goToCadastro(value) {
	location.href= 'cadastro_cliente_fisico.jsp?state=1&id=' + value;
}

function goToAnexo(value) {
	location.href = "anexo_fisico.jsp?id=" + value;
}

function goToMensalidades(value) {
	location.href = "mensalidade.jsp?id=" + value;
}

function goToBoletos(value) {
	location.href = "boleto.jsp?id=" + value + "&origem=f";
}

function goToTratamento(value) {
	location.href = "orcamento.jsp?id=" + value;
}

function goToOrcamento(value) {
	location.href = "orcamento_empresa.jsp?id=" + value;
}


function delUsuario(value) {
	$.get("../CadastroClienteFisico",{			
		from: "3", 
		codigo: value},
		function(response){
			location.href = '../error_page.jsp?errorMsg=' + response + '&lk=application/cliente_fisico.jsp';
		}
	);
}

$(document).ready(function() {	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
		if (pager != undefined) {
			if ((parseInt($('#gridLines').val()) != pager.recordCount) && (pager != undefined)) {
				pager.Search();
			}
		}
	});
	
	$("input[type='text']").change(function() {
		flag= true;
	});
	
	$("frame[name=ad_frame]").addClass("cpEsconde");
});

function imprime() {
	$("#imprimeWindow").dialog({
 		modal: true,
 		width: 250,
 		minWidth: 250,
 		show: 'fade',
	 	hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close');
 			},
 			"Imprimir" : function() {
 				showRelatorio();
 				$(this).dialog('close');
 			}
 		},
 		close: function() {
 			$(this).dialog('destroy'); 			
 		}
	 });
}

function showRelatorio() {
	var top = (window.height - 600)/2;
	var left= (window.width - 700)/2;
	left-= 350;
	top-= 300;
	
	var url = "../GeradorRelatorio?rel=217&parametros=509@"
		+ $("#statusConta").val() + "|508@" + $("#empresaId").val();	
	window.open(url, 'nova', 'width= 700, height= 600, top= ' + top + ', left= ' + left);
}