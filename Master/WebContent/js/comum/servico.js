var pager;
var flag= false;

function printProcedimento() {
	$("#tabelaWindow").dialog({
		modal: true,
		width: 259,
		minWidth: 259,
		show: 'fade',
		hide: 'clip',
		buttons: {
			"Cancelar" : function () {
				$(this).dialog('close');
			},
			"Exibir" : function() {
				var top = (screen.height - 600)/2;
				var left= (screen.width - 800)/2;
				window.open("../GeradorRelatorio?rel=161&parametros=200@"+
					$('#unidadeWin').val(),'nova', 'width= 800, height= 600, top= ' + top + ', ' +
					'left= ' + left);
				$(this).dialog('close');
			}
		},
		close: function() {
			$(this).dialog('destroy');
		}
	 });
}


$(document).ready(function() {
	load= function () {		
		pager = new Pager($('#gridLines').val(), 30, "../CadastroServico");
		pager.mountPager();	
	}
	
	getNext = function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if ((pager.limit * pager.currentPage) < pager.recordCount) {
				$.get("../CadastroServico",{
					gridLines: pager.limit , 
					limit: pager.limit, 
					isFilter: "0", 
					offset: pager.offSet + pager.limit,				
					referenciaIn: $('#codigoIn').val(), 
					setorIn: $('#setorIn').val(),
					especialidadeIn: $('#especialidadeIn').val(), 
					descricaoIn: $('#descricaoIn').val()},
					function (response) {				
						$('#dataBank').empty();
						$('#dataBank').append(response);
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
				$.get("../CadastroServico",{
					gridLines: pager.limit, 
					limit: pager.limit,
					isFilter: "0",
					offset: pager.offSet - pager.limit,	
					referenciaIn: $('#codigoIn').val(), 
					setorIn: $('#setorIn').val(),
					especialidadeIn: $('#especialidadeIn').val(), 
					descricaoIn: $('#descricaoIn').val()},
					function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);
					}
				);
				pager.previousPage();
			}			
		}
	}
	
	search= function() {
		$.get("../CadastroServico",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, isFilter: "1", 
			referenciaIn: $('#codigoIn').val(), 
			setorIn: $('#setorIn').val(),
			especialidadeIn: $('#especialidadeIn').val(), 
			descricaoIn: $('#descricaoIn').val()},
			function(response){
				$('#dataBank').empty();
				$('#dataBank').append(response);				
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
			$.get("../CadastroServico",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: pager.offSet, 
				isFilter: "0", 
				referenciaIn: $('#codigoIn').val(), 
				setorIn: $('#setorIn').val(),
				especialidadeIn: $('#especialidadeIn').val(), 
				descricaoIn: $('#descricaoIn').val()},
				function(response) {
					$('#dataBank').empty();
					$('#dataBank').append(response);
				}
			);
			pager.calculeCurrentPage(); 	
			pager.refreshPager();						
		}
	}
	
	$('#setorIn').change(function() {
		if($('#setorIn').val() != "") {
			$.get("../FuncionarioGet",{
				setorIn: $('#setorIn').val(), 
				from: "4"},
				function (response) {
					$('#especialidadeIn').empty();
					$('#especialidadeIn').append(response);
					document.getElementById("especialidadeIn").selectedIndex= 0;					
				}
			);
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
	});
	
	$("input[type='text']").change(function() {
		flag= true;
	});	
});