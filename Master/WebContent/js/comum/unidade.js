var dataGrid;
var pager;
var flag= false;

$(document).ready(function(){
	seletorLogin = new MsfItemsSelectorAdm({
		id:"selectorLogins", 
		leftId: "sortableLeft", 
		rightId: "sortableRight", 
		valueId:"valorUsuario",
		conteinerValues: 'itemSelValues',
		height: 270
	});
	
	dataGrid = new DataGrid();
	dataGrid.addOption("Cadastro", "goToCadastro(");
	dataGrid.addOption("Anexo", "goToAnexo(");
	dataGrid.addOption("Requisição", "goToRequisicao(");
	dataGrid.addOption("Gerar Fatura", "gerarFatura(");		
	dataGrid.addOption("Histórico de Fatura", "goToFatura(");
	pager = new Pager($('#gridLines').val(), 30, "../CadastroFuncionario");
	pager.mountPager();		
	
	$(this).ajaxStop(function(){
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

//copiar para todo datagrid composto 
function appendMenu(value){
	dataGrid.expande(value, false); //true se for link, false para função
}

function getNext(){
	if (flag) {
		flag= false;
		search();
	} else {
		if ((pager.limit * pager.currentPage) < pager.recordCount) {
			$.get("../CadastroUnidade",{gridLines: pager.limit , limit: pager.limit, 
				isFilter: "0", offset: pager.offSet + pager.limit, 
				referenciaIn: $("#referenciaIn").val(), 
				tipoIn: ($("#tipoIn").val() == "Selecione")? "" : $("#tipoIn").val().toLowerCase() ,
				ativo: $("#ativoChecked").val(),cnpjIn: $("#cnpjIn").val(), isSearch: "n",				
				cidadeIn: $("#cidadeIn").val(), razaoSocialIn: $("#razaoSocialIn").val(), 
				cpfIn: $("#cpfIn").val(), nomeIn: $("#nomeIn").val()},
			function (response) {				
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.nextPage();
			dataGrid = new DataGrid();
			dataGrid.addOption("Cadastro", "goToCadastro(");
			dataGrid.addOption("Anexo", "goToAnexo(");
			dataGrid.addOption("Requisição", "goToRequisicao(");
			dataGrid.addOption("Gerar Fatura", "gerarFatura(");
			dataGrid.addOption("Histórico de Fatura", "goToFatura(");
		}			
	}
}

function getPrevious(){
	if (flag) {
		flag= false;
		search();
	} else {
		if (pager.offSet > 0) {
			$.get("../CadastroUnidade", {
				gridLines: pager.limit,	limit: pager.limit,	isFilter: "0",
				offset: pager.offSet - pager.limit, referenciaIn: $("#referenciaIn").val(),
				tipoIn: ($("#tipoIn").val() == "Selecione") ? "" : $("#tipoIn").val().toLowerCase(),
				ativo: $("#ativoChecked").val(), cnpjIn: $("#cnpjIn").val(), isSearch: "n",
				cidadeIn: $("#cidadeIn").val(),	razaoSocialIn: $("#razaoSocialIn").val(),
				cidadeIn: $("#cidadeIn").val(),	cpfIn: $("#cpfIn").val(),
				nomeIn: $("#nomeIn").val()
			}, function(response){
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.previousPage();
			dataGrid = new DataGrid();
			dataGrid.addOption("Cadastro", "goToCadastro(");
			dataGrid.addOption("Anexo", "goToAnexo(");
			dataGrid.addOption("Requisição", "goToRequisicao(");
			dataGrid.addOption("Gerar Fatura", "gerarFatura(");
			dataGrid.addOption("Histórico de Fatura", "goToFatura(");
		}			
	}
}

function search() {
	$.get("../CadastroUnidade", {
			gridLines: pager.limit,	limit: pager.limit,	offset: 0, isFilter: "1",
			referenciaIn: $("#referenciaIn").val(),
			tipoIn: ($("#tipoIn").val() == "Selecione") ? "" : $("#tipoIn").val().toLowerCase(),
			ativo: $("#ativoChecked").val(), cnpjIn: $("#cnpjIn").val(), isSearch: "n",
			cidadeIn: $("#cidadeIn").val(),	razaoSocialIn: $("#razaoSocialIn").val(),
			cidadeIn: $("#cidadeIn").val(),	cpfIn: $("#cpfIn").val(),
			nomeIn: $("#nomeIn").val()
		}, function(response){
			$('#dataBank').empty();
			$('#dataBank').append(response);				
		});
	dataGrid = new DataGrid();
	dataGrid.addOption("Cadastro", "goToCadastro(");
	dataGrid.addOption("Anexo", "goToAnexo(");
	dataGrid.addOption("Requisição", "goToRequisicao(");
	dataGrid.addOption("Gerar Fatura", "gerarFatura(");
	dataGrid.addOption("Histórico de Fatura", "goToFatura(");		
	return false;
}

function renderize(value) {
	if (flag) {
		flag= false;
		search();
	} else {
		pager.sortOffSet(value);
		$.get("../CadastroUnidade", {
				gridLines: pager.limit,	limit: pager.limit,	offset: pager.offSet, isFilter: "0",
				referenciaIn: $("#referenciaIn").val(),
				tipoIn: ($("#tipoIn").val() == "Selecione") ? "" : $("#tipoIn").val().toLowerCase(),
				ativo: $("#ativoChecked").val(), cnpjIn: $("#cnpjIn").val(), isSearch: "n",
				cidadeIn: $("#cidadeIn").val(),	razaoSocialIn: $("#razaoSocialIn").val(),
				cidadeIn: $("#cidadeIn").val(),	cpfIn: $("#cpfIn").val(),
				nomeIn: $("#nomeIn").val()
			}, function(response){
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
		pager.calculeCurrentPage(); 	
		pager.refreshPager();			
		dataGrid = new DataGrid();
		dataGrid.addOption("Cadastro", "goToCadastro(");
		dataGrid.addOption("Anexo", "goToAnexo(");
		dataGrid.addOption("Requisição", "goToRequisicao(");
		dataGrid.addOption("Gerar Fatura", "gerarFatura(");
		dataGrid.addOption("Histórico de Fatura", "goToFatura(");			
	}
}

function loadItenSelector(elemento) {
 	$.get("../CartaoAdapter", {
		from: "1",
		tipo: "u",
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

function operacaoCartao() {
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

function secondStage() {
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

function enviarOperacao(tipoOperacao) {
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

function goToCadastro(value) {
	location.href = "cadastro_unidade.jsp?state=1&id=" + value;
}
	
function goToAnexo(value) {
	location.href = "anexo_unidade.jsp?id=" + value;
}
	
function goToRequisicao(value) {
	alert("Em Manutenção");
}
	
function gerarFatura(value) {
	$.get("../CadastroFaturaFranchising",{
		from: "0",			 
		unidadeId: value},
	function (response) {
		location.href = response;
	});
}
	
function goToFatura(value) {
	location.href = "fatura_franchising.jsp?id=" + value;
}