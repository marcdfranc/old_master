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
		pager = new Pager($('#gridLines').val(), 30, "../CadastroClienteFisico");
		pager.mountPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Cadastro", "goToCadastro(");
		dataGrid.addOption("Anexo", "goToAnexo(");
		dataGrid.addOption("Requisição", "goToRequisicao(");
		dataGrid.addOption("Contratos", "goToBordero(");
		dataGrid.addOption("Borderô", "goToContratos(");
		dataGrid.addOption("Histórico de Faturas", "goToFatura(");
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
				$.get("../CadastroFuncionario",{
					gridLines: pager.limit , 
					limit: pager.limit, 
					isFilter: "0", 
					offset: pager.offSet + pager.limit,					
					referenciaIn: $('#referenciaIn').val(),
					nomeIn: $('#nomeIn').val(),
					ativoChecked: $('#ativoChecked').val(),
					unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
						$('#unidadeId').val(), cpfIn: $('#cpfIn').val(), 
					cargoId:($('#cargoId').val() == "Selecione")? "" :
						$('#cargoId').val(),
					nascimentoIn: $('#nascimentoIn').val(),
					from: "0"},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.nextPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");
				dataGrid.addOption("Anexo", "goToAnexo(");
				dataGrid.addOption("Requisição", "goToRequisicao(");
				dataGrid.addOption("Contratos", "goToBordero(");
				dataGrid.addOption("Borderô", "goToContratos(");
				dataGrid.addOption("Histórico de Faturas", "goToFatura(");
			}			
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroFuncionario",{
					gridLines: pager.limit, 
					limit: pager.limit,
					isFilter: "0", 
					offset: pager.offSet - pager.limit,	
					referenciaIn: $('#referenciaIn').val(),
					nomeIn: $('#nomeIn').val(),
					ativoChecked: $('#ativoChecked').val(),
					unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
						$('#unidadeId').val(), cpfIn: $('#cpfIn').val(), 
					cargoId:($('#cargoId').val() == "Selecione")? "" :
						$('#cargoId').val(),
					nascimentoIn: $('#nascimentoIn').val(),
					from: "0"},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.previousPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");
				dataGrid.addOption("Anexo", "goToAnexo(");
				dataGrid.addOption("Requisição", "goToRequisicao(");
				dataGrid.addOption("Contratos", "goToBordero(");
				dataGrid.addOption("Borderô", "goToContratos(");
				dataGrid.addOption("Histórico de Faturas", "goToFatura(");
			}			
		}
	}
	
	search= function() {
		$.get("../CadastroFuncionario",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1",
			referenciaIn: $('#referenciaIn').val(),	
			nomeIn: $('#nomeIn').val(),
			ativoChecked: $('#ativoChecked').val(),
			unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
				$('#unidadeId').val(), 
			cpfIn: $('#cpfIn').val(), 
			cargoId:($('#cargoId').val() == "Selecione")? "" :
					$('#cargoId').val(),
			nascimentoIn: $('#nascimentoIn').val(),
			from: "0"},
			function (response) {				
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
			$.get("../CadastroFuncionario",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: pager.offSet, isFilter: "0", 
				referenciaIn: $('#referenciaIn').val(),
				nomeIn: $('#nomeIn').val(),	
				ativoChecked: $('#ativoChecked').val(),
				unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
					$('#unidadeId').val(), 
				cpfIn: $('#cpfIn').val(), 
				cargoId:($('#cargoId').val() == "Selecione")? "" :
					$('#cargoId').val(),
				nascimentoIn: $('#nascimentoIn').val(),
				from: "0"},
			function (response) {				
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
			dataGrid = new DataGrid();
			dataGrid.addOption("Cadastro", "goToCadastro(");
			dataGrid.addOption("Anexo", "goToAnexo(");
			dataGrid.addOption("Requisição", "goToRequisicao(");
			dataGrid.addOption("Contratos", "goToBordero(");
			dataGrid.addOption("Borderô", "goToContratos(");
			dataGrid.addOption("Histórico de Faturas", "goToFatura(");
		}
	}
	
	loadItenSelector = function(elemento) {
	 	$.get("../CartaoAdapter", {
			from: "1",
			tipo: "f",
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
	 			$(this).dialog('close');
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
	
	goToCadastro= function(value) {
		location.href= 'cadastro_funcionario.jsp?state=1&id=' + value;
	}
	
	/**
	 * goToAnexo
	 * @param {type} value 
	 */
	goToAnexo = function (value) {
	 	location.href = 'anexo_rh.jsp?id=' + value;
	}
	
	/**
	 * goToContratos
	 * @param {type} value 
	 */
	goToContratos = function (value) {
	 	location.href = 'bordero_funcionario.jsp?id=' + value;
	}
	
	/**
	 * goToBordero
	 * @param {type} value 
	 */
	goToBordero = function (value) {
	 	location.href= 'contrato.jsp?id=' + value;
	}	
	
	/**
	 * goToRequisicao
	 * @param {type} value 
	 */
	goToRequisicao = function (value) {
	 	location.href = 'requisicao_contrato.jsp?id=' + value;
	}
	
	/**
	 * goToFatura
	 * @param {type} value 
	 */
	goToFatura = function (value) {
	 	location.href= 'fatura_vendedor.jsp?id=' + value;
	}	
});
