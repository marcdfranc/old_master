var pager;
var flag= false;
var dataGrid;
var seletorLogin;

$(document).ready(function() {
	seletorLogin = new MsfItemsSelectorAdm({
		id:"selectorLogins", 
		leftId: "sortableLeft", 
		rightId: "sortableRight", 
		valueId:"valorUsuario",
		conteinerValues: 'itemSelValues',
		height: 270
	});
	
	load= function () {		
		pager = new Pager($('#gridLines').val(), 30, "../CadastroProfissional");
		dataGrid = new DataGrid();
		dataGrid.addOption("Cadastro", "goToCadastro(");
		dataGrid.addOption("Anêxo", "goToAnexo(");
		dataGrid.addOption("Agenda", "goToAgenda(");
		dataGrid.addOption("Borderô", "goToLancamentos(");
		dataGrid.addOption("Cadastro de Fatura", "goToGeracao(");
		dataGrid.addOption("Histórico de Faturas", "goToFaturas(");
		pager.mountPager();	
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
				$.get("../CadastroProfissional",{
					gridLines: pager.limit, 
					limit: pager.limit,
					isFilter: "0",
					offset: pager.offSet + pager.limit,
					referenciaIn: $('#referenciaIn').val(),
					nomeIn: $('#nomeIn').val(),
					cpfIn: $('#cpfIn').val(),
					conselhoIn: $('#conselhoIn').val(),
					setorIn: $('#setorIn').val(), 
					especialidadeIn: $('#especialidadeIn').val(),
					unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
						$('#unidadeId').val(),									
					ativoChecked: $('#ativoChecked').val()},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.nextPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");
				dataGrid.addOption("Anêxo", "goToAnexo(");
				dataGrid.addOption("Agenda", "goToAgenda(");
				dataGrid.addOption("Borderô", "goToLancamentos(");
				dataGrid.addOption("Gerar Fatura", "goToGeracao(");
				dataGrid.addOption("Faturas", "goToFaturas(");
			}			
		}
	}
	
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroProfissional",{
					gridLines: pager.limit,
					limit: pager.limit,
					isFilter: "0",
					offset: pager.offSet - pager.limit,	
					referenciaIn: $('#referenciaIn').val(),
					nomeIn: $('#nomeIn').val(),
					cpfIn: $('#cpfIn').val(),
					conselhoIn: $('#conselhoIn').val(),
					setorIn: $('#setorIn').val(), 
					especialidadeIn: $('#especialidadeIn').val(),
					unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
						$('#unidadeId').val(),									
					ativoChecked: $('#ativoChecked').val()},
					function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);
				});
				pager.previousPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");
				dataGrid.addOption("Anêxo", "goToAnexo(");
				dataGrid.addOption("Agenda", "goToAgenda(");
				dataGrid.addOption("Borderô", "goToLancamentos(");
				dataGrid.addOption("Gerar Fatura", "goToGeracao(");
				dataGrid.addOption("Faturas", "goToFaturas(");
			}
		}
	}
	
	search= function() {
		$.get("../CadastroProfissional",{
			gridLines: pager.limit,
			limit: pager.limit,
			offset: 0,
			isFilter: "1", 
			referenciaIn: $('#referenciaIn').val(),
			nomeIn: $('#nomeIn').val(),
			cpfIn: $('#cpfIn').val(),
			conselhoIn: $('#conselhoIn').val(),
			setorIn: $('#setorIn').val(), 
			especialidadeIn: $('#especialidadeIn').val(),
			unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
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
			$.get("../CadastroProfissional",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: pager.offSet,
				isFilter: "0", 
				referenciaIn: $('#referenciaIn').val(),
				nomeIn: $('#nomeIn').val(),
				cpfIn: $('#cpfIn').val(),
				conselhoIn: $('#conselhoIn').val(),
				setorIn: $('#setorIn').val(), 
				especialidadeIn: $('#especialidadeIn').val(),
				unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
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
			dataGrid.addOption("Anêxo", "goToAnexo(");
			dataGrid.addOption("Agenda", "goToAgenda(");
			dataGrid.addOption("Borderô", "goToLancamentos(");
			dataGrid.addOption("Gerar Fatura", "goToGeracao(");
			dataGrid.addOption("Faturas", "goToFaturas(");						
		}
	}
	
	$('#setorIn').change(function() {
		if($('#setorIn').val() != "") {
			$.get("../FuncionarioGet",{setorIn: $('#setorIn').val(), 
				from: "4"},
				function (response) {
					$('#especialidadeIn').empty();
					$('#especialidadeIn').append(response);
					document.getElementById("especialidadeIn").selectedIndex= 0;					
			});
		}
	});
	
	loadItenSelector = function(elemento) {
	 	$.get("../CartaoAdapter", {
			from: "1",
			tipo: "p",
			unidade: $("#unidadeIds").val()},
			function (response) {
				var dado = unmountPipe(response);
				var leftBox = "";
				for(var i = 0; i < dado.length; i++) {
					leftBox+= "<li style=\"height: 20px\" title=\"" + dado[i] + 
					"\" >" + dado[i] + "</li>";
				}
				$('#sortableRight').empty();
				$("#sortableLeft").empty();
				$("#sortableLeft").append(leftBox);
				seletorLogin.addToLeftBox();
			}
		);
		$(elemento).dialog('close');
		secondStage();
	}
	
	operacaoCartao = function () {
	 	$("#preWindow").dialog({
	 		modal: true,
	 		width: 220,
	 		minWidth: 220,
	 		show: 'fade',
			hide: 'clip',
	 		buttons: {
	 			"Cancelar": function() {
	 				$(this).dialog('close');
				},
	 			"Avançar" : function () {
	 				loadItenSelector(this);					
	 			}		 			
	 		},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
	 	});
	}
	
	secondStage = function () {
	 	$("#cartaoWindow").dialog({
	 		modal: true,
	 		width: 701,
	 		minWidth: 701,
	 		show: 'fade',
			hide: 'clip',
	 		buttons: {
	 			"Cancelar": function() {
	 				$(this).dialog('close');
				},
	 			"Gerar Acesso" : function () {
	 				enviarOperacao("0");
					$(this).dialog('close');
	 			},
	 			"Excluir Acesso" : function () {
	 				enviarOperacao("4");
					$(this).dialog('close');
	 			},
	 			"Bloq. Acesso" : function () {
	 				enviarOperacao("2");
					$(this).dialog('close');
	 			},
	 			"Lib. Acesso" : function () {
	 				enviarOperacao("3");					
					$(this).dialog('close');
	 			},
	 			"Imp. Cartão" : function () {
	 				enviarOperacao("5");
					$(this).dialog('close');
	 			}
	 		},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
	 	});
	}
	
	enviarOperacao = function (tipoOperacao) {
		var pipe = "";
 		$("#itemSelValues > *").each(function(index, domEle) {
			if (index == 0) {
				pipe += $(domEle).val();
			} else {
				pipe += (tipoOperacao == "5")? "," + $(domEle).val() 
					: "@" + $(domEle).val();
			}
		});
		if (tipoOperacao == "5") {
			var top = (screen.height - 200)/2;
			var left= (screen.width - 600)/2;
			window.open("../GeradorRelatorio?rel=132&parametros=6@" + pipe , 
				'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
		} else {
			$.get("../CartaoAdapter", {
				from: tipoOperacao,
				pipe: pipe},
				function (response) {
					showMessage({
						width: 393,
						mensagem: response,
						title: "Operação"
					});
				}
			);
		}
	}
	
	goToCadastro = function (value) {
		location.href = "cadastro_profissional.jsp?state=1&id=" + value;	
	}
	
	goToGeracao = function (value){
		location.href = "cadastro_bordero.jsp?id=" + value;	
	}
	
	goToFaturas = function (value) {
		location.href = "fatura_bordero_profissional.jsp?id=" + value;
	}
		
	goToLancamentos = function (value) {
		location.href = "bordero_profissional.jsp?id=" + value;
	}	
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	/**
	 * goToAnexo
	 * @param {type}  
	 */
	goToAnexo = function (value) {
	 	location.href = "anexo_profissional.jsp?id=" + value;
	}
	
	$(this).ajaxStop(function(){
		hideLoader();
		if (pager != undefined) {
			if (parseInt($('#gridLines').val()) != pager.recordCount) {
				pager.Search();
			}
		}
	});
	
	/*$("input[type='text']").keyup(function() {				
		
	});*/
	
	$("input[type='text']").change(function() {
		flag= true;
	});
});

function goToAgenda(value) {
	location.href = "agenda_profissional.jsp?id=" + value;
}	