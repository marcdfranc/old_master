var pager;
var flag= false;

$(document).ready(function() {
	load= function () {		
		pager = new Pager($('#gridLines').val(), 30, "../CadastroTabela");
		pager.mountPager();	
	}
	
	getNext = function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if ((pager.limit * pager.currentPage) < pager.recordCount) {
				$.get("../CadastroTabela",{
					gridLines: pager.limit , 
					limit: pager.limit, 
					isFilter: "0", 
					offset: pager.offSet + pager.limit,
					from: "0",
					referenciaIn: $('#codigoIn').val(), 
					tabelaIn : $('#tabelaIn').val(),
					setorIn: $('#setorIn').val(),
					especialidadeIn: $('#especialidadeIn').val(),					
					descricaoIn: $('#descricaoIn').val(),
					unidadeId: getPart($('#unidadeIdIn').val(), 2)},
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
				$.get("../CadastroTabela",{
					gridLines: pager.limit, 
					limit: pager.limit,	
					isFilter: "0",
					offset: pager.offSet - pager.limit,	
					from: "0",
					referenciaIn: $('#codigoIn').val(),
					tabelaIn : $('#tabelaIn').val(), 
					setorIn: $('#setorIn').val(),
					especialidadeIn: $('#especialidadeIn').val(),					
					descricaoIn: $('#descricaoIn').val(),
					unidadeId: getPart($('#unidadeIdIn').val(), 2)}, 
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
		$.get("../CadastroTabela",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1", 
			from: "0",
			referenciaIn: $('#codigoIn').val(), 
			tabelaIn : $('#tabelaIn').val(),
			setorIn: $('#setorIn').val(),
			especialidadeIn: $('#especialidadeIn').val(),					
			descricaoIn: $('#descricaoIn').val(),
			unidadeId: getPart($('#unidadeIdIn').val(), 2)},
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
			$.get("../CadastroTabela",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: pager.offSet, 
				isFilter: "0", 
				from: "0",
				referenciaIn: $('#codigoIn').val(),
				tabelaIn : $('#tabelaIn').val(), 
				setorIn: $('#setorIn').val(),
				especialidadeIn: $('#especialidadeIn').val(),					
				descricaoIn: $('#descricaoIn').val(),
				unidadeId: getPart($('#unidadeIdIn').val(), 2)},
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
	
	generateTabela = function () {
		$("#tabelaWindow").dialog({
	 		modal: true,
	 		width: 350,
	 		minWidth: 259,
	 		show: 'fade',
			hide: 'clip',
	 		buttons: {
	 			"Cancelar" : function () {
	 				$(this).dialog('close');
	 			},
	 			"Exibir" : function() {
	 				var top = (screen.height - 200)/2;
					var left= (screen.width - 600)/2;
	 				switch ($('#tipo').val()) {
	 					case '0':
	 						window.open("../GeradorRelatorio?rel=150&parametros=123@"+
		 						$('#unidadeWin').val() + "|124@" + $('#tabelaWin').val(),
		 						'nova', 'width= 800, height= 600, top= ' + top + ', ' +
		 						'left= ' + left);
	 						break;
	 					
	 					case '1':
	 						window.open("../GeradorRelatorio?rel=147&parametros=113@"+
		 						$('#unidadeWin').val() + "|114@" + $('#tabelaWin').val(),
		 						'nova', 'width= 800, height= 600, top= ' + top + ', ' +
		 						'left= ' + left);
	 						break;

	 					case '2':
	 						window.open("../GeradorRelatorio?rel=148&parametros=116@"+
		 						$('#unidadeWin').val() + "|117@" + $('#tabelaWin').val(),
		 						'nova', 'width= 800, height= 600, top= ' + top + ', ' +
		 						'left= ' + left);
	 						break;
	 						
	 					case '3':
	 						window.open("../GeradorRelatorio?rel=149&parametros=119@"+
		 						$('#unidadeWin').val() + "|120@" + $('#tabelaWin').val(),
		 						'nova', 'width= 800, height= 600, top= ' + top + ', ' +
		 						'left= ' + left);
	 						break;
	 				}
	 				$(this).dialog('close');
	 			}
	 		},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
		 });
	}
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
		if (parseInt($('#gridLines').val()) != pager.recordCount) {
			pager.Search();
		}
	});
	
	$("input[type='text']").change(function() {
		flag= true;
	});

});