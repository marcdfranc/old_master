var dataGrid;
var pager;
var flag= false;

$(document).ready(function() {
	load = function(){
		dataGrid = new DataGrid();
		pager = new Pager($('#gridLines').val(), 30, "../CadastroBordero");
		pager.mountPager();		
		if (document.getElementById("pagerGrid").innerHTML != "" ) {
			$('#lastButton').addClass("justificaRight");			
		} else {
			$('#lastButton').removeAttr("class", "justificaRight");	
		}
	}	
	
	getNext = function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if ((pager.limit * pager.currentPage) < pager.recordCount) {
				$.get("../CadastroFaturaEmpresa",{
					gridLines: pager.limit , 
					limit: pager.limit, 
					isFilter: "0", 
					offset: pager.offSet + pager.limit, 
					from: "2",
					ref: $('#refIn').val(),
					titular: $("#clienteIn").val(),
					dependente: $("#dependenteIn").val(),
					orcamento: $('#orcamentoIn').val(),
					profissional: $('#profissionalIdIn').val(),
					empresaIdIn: $('#empresaIdIn').val(),
					unidadeId: $('#unidadeIdIn').val(),
					lancamento: $('#guiaIn').val()},
					function (response) {				
						$('#dataGrid').empty();
						$('#dataGrid').append(response);
					}
				);
				pager.nextPage();				
			}			
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroFaturaEmpresa",{
					gridLines: pager.limit, 
					limit: pager.limit,	
					isFilter: "0",
					offset: pager.offSet - pager.limit, 
					from: "2",	
					ref: $('#refIn').val(),
					titular: $("#clienteIn").val(),
					dependente: $("#dependenteIn").val(),
					orcamento: $('#orcamentoIn').val(),
					profissional: $('#profissionalIdIn').val(),
					empresaIdIn: $('#empresaIdIn').val(),
					unidadeId: $('#unidadeIdIn').val(),
					lancamento: $('#guiaIn').val()},
					function(response){
						$('#dataGrid').empty();
						$('#dataGrid').append(response);
					}
				);
				pager.previousPage();				
			}			
		}
	}

	search= function() {
		$.get("../CadastroFaturaEmpresa",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1", 
			from: "2",
			ref: $('#refIn').val(),
			titular: $("#clienteIn").val(),
			dependente: $("#dependenteIn").val(),
			orcamento: $('#orcamentoIn').val(),
			profissional: $('#profissionalIdIn').val(),
			empresaIdIn: $('#empresaIdIn').val(),
			unidadeId: $('#unidadeIdIn').val(),
			lancamento: $('#guiaIn').val()},
			function(response){
				$('#dataGrid').empty();
				$('#dataGrid').append(response);				
			}
		);
		return false;
	}
		
	renderize= function(value) {
		if (flag) {
			flag= false;
			search();
		} else {
			pager.sortOffSet(value);
			$.get("../CadastroFaturaEmpresa",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: pager.offSet, 
				isFilter: "0",
				from: "2", 
				ref: $('#refIn').val(),
				titular: $("#clienteIn").val(),
				dependente: $("#dependenteIn").val(),
				orcamento: $('#orcamentoIn').val(),
				profissional: $('#profissionalIdIn').val(),
				empresaIdIn: $('#empresaIdIn').val(),
				unidadeId: $('#unidadeIdIn').val(),
				lancamento: $('#guiaIn').val()},
				function(response) {
					$('#dataGrid').empty();
					$('#dataGrid').append(response);
				}
			);
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
		}
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
	
	$('#profissionalIdIn').change(function () {
		if($('#empresaIdIn').val() != "") {
			showErrorMessage({
				mensagem: "Posicione a combo box \"Emp. Saúde\" em \"Selecione\" para mudar este campo.",
				title: "Erro"
			});
			document.getElementById('profissionalIdIn').selectedIndex = 0;
		}
	});
	
	$('#empresaIdIn').change(function () {
		if($('#profissionalIdIn').val() != "") {
			showErrorMessage({
				mensagem: "Posicione a combo box \"Profissional\" em \"Selecione\" para mudar este campo.",
				title: "Erro"
			});
			document.getElementById('empresaIdIn').selectedIndex = 0;
		}
	});
	
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
		if (document.getElementById("pagerGrid").innerHTML != "" ) {
			$('#lastButton').addClass("justificaRight");		
		} else {
			$('#lastButton').removeAttr("class", "justificaRight");	
		}
	});
	
	$("input[type='text']").change(function() {
		flag= true;
	});
});