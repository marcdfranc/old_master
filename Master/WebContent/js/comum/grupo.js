var dataGrid;
var pager;
var flag= false;
var tabelaSelector;

function appendMenu(value){
	dataGrid.expande(value, false);
}

function getNext(){		
	if (flag) {
		flag= false;
		search();
	} else {
		if ((pager.limit * pager.currentPage) < pager.recordCount) {
			$.get("../CadastroCatalogo",{
				gridLines: pager.limit , 
				limit: pager.limit, 
				isFilter: "0", 
				offset: pager.offSet + pager.limit, 
				from: "0",
				nome: $('#nomeContato').val(), 
				grupo: $('#grp').val(),
				aniverssario: $('#mesNiver').val()},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				}
			);
			pager.nextPage();
			dataGrid = new DataGrid();
			dataGrid.addOption("Visualizar", "showCadastro(");
			dataGrid.addOption("Editar", "goToCadastro(");
			dataGrid.addOption("Excluir", "excluiContato(");
		}			
	}
}

function getPrevious(){
	if (flag) {
		flag= false;
		search();
	} else {
		if (pager.offSet > 0) {
			$.get("../CadastroCatalogo",{
				gridLines: pager.limit, 
				limit: pager.limit,	
				isFilter: "0",
				offset: pager.offSet - pager.limit, 
				from: "0",	
				nome: $('#nomeContato').val(), 
				grupo: $('#grp').val(),
				aniverssario: $('#mesNiver').val()},
				function(response){
					$('#dataBank').empty();
					$('#dataBank').append(response);
				}
			);
			pager.previousPage();
			dataGrid = new DataGrid();
			dataGrid.addOption("Visualizar", "showCadastro(");
			dataGrid.addOption("Editar", "goToCadastro(");
			dataGrid.addOption("Excluir", "excluiContato(");			
		}			
	}
}

function search() {	
	$.get("../CadastroCatalogo",{
		gridLines: pager.limit, 
		limit: pager.limit,
		offset: 0, 
		isFilter: "1", 
		from: "0", 
		nome: $('#nomeContato').val(), 
		grupo: $('#grp').val(),
		aniverssario: $('#mesNiver').val()},
		function(response){
			$('#dataBank').empty();
			$('#dataBank').append(response);				
		}
	);
	dataGrid = new DataGrid();
	dataGrid.addOption("Visualizar", "showCadastro(");
	dataGrid.addOption("Editar", "goToCadastro(");
	dataGrid.addOption("Excluir", "excluiContato(");
	return false;
}


function renderize(value) {
	if (flag) {
		flag= false;
		search();
	} else {
		pager.sortOffSet(value);
		$.get("../CadastroCatalogo",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: pager.offSet, 
			isFilter: "0", 
			from: "0",
			nome: $('#nomeContato').val(), 
			grupo: $('#grp').val(),
			aniverssario: $('#mesNiver').val()},
			function(response) {
				$('#dataBank').empty();
				$('#dataBank').append(response);
			}
		);
		pager.calculeCurrentPage(); 	
		pager.refreshPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Visualizar", "showCadastro(");
		dataGrid.addOption("Editar", "goToCadastro(");
		dataGrid.addOption("Excluir", "excluiContato(");
	}
}

function setSelected(grp) {
	$(".selctedGrp").removeClass("selctedGrp");
	$(grp).addClass("selctedGrp");
}

function setGrp(value) {
	$('#grp').val(value);
	search();
}

function cadastroGrupo(isEdit) {
	var grupoId = ($('#grp').val() == "")? "e" : $('#grp').val();
	if (grupoId != "e") {
		$('#descGrupo').val($('.selctedGrp').text());
	}
	$("#windowGrupo").dialog({
 		modal: true,
 		width: 300,
 		minWidth: 300,
 		show: 'fade',
		hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close');
 			},
 			"Salvar": function () {
				$.get("../CadastroCatalogo", {
					from: '2',
					grupoId: grupoId,
					descricao: $('#descGrupo').val()}, 
					function(response) {
						location.href = response;
					}
				);
				$(this).dialog('close');
 			}
 		},
 		close: function() {
 			$(this).dialog('destroy');
 		}
 	});
}

function stringToXml(xmlData) {
	if (window.ActiveXObject) {
		//for IE
		xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
		xmlDoc.async="false";
		xmlDoc.loadXML(xmlData);
		return xmlDoc;
	} else if (document.implementation && document.implementation.createDocument) {
		//for Mozila
		parser=new DOMParser();
		xmlDoc=parser.parseFromString(xmlData,"text/xml");
		return xmlDoc;
	}
}

function loadView(xml) {
	var informacoes = xml.informacoes;
	var infoHtm = "";
	idCatalogo = xml.id;
	for(var i=0; i<informacoes.length; i++) {
		infoHtm += "<strong>" + informacoes[i].tipo + ": </strong><span>" + informacoes[i].descricao +
		 	"</span><br />";
	}
		
	$('#viewInfo').empty();
	$('#viewInfo').append(infoHtm);
	
	$('#viewNome').text(xml.nome);
	$('#viewApelido').text(xml.apelido);
	$('#viewUsuario').text(xml.usuario);
	$('#viewAniverssario').text(xml.aniverssario);
	$('#viewCep').text(xml.cep);
	$('#viewEndereco').text(xml.endereco);
	$('#viewComplemento').text(xml.complemento);
	$('#viewBairro').text(xml.bairro);
	$('#viewCidade').text(xml.cidade);
	$('#viewTrabalho').text(xml.empresa);	
	$('#viewCargo').text(xml.cargo);
	$('#viewSetor').text(xml.setor);
	$('#viewCepEmp').text(xml.cep_empresa);
	$('#viewEnderecoEmp').text(xml.endereco_empresa);
	$('#viewComplementoEmp').text(xml.complemento_empresa);
	$('#viewBairroEmp').text(xml.bairro_empresa);
	$('#viewCidadeEmp').text(xml.cidade_empresa);
	$('#viewSite').text(xml.site);
	$('#viewFone').text(xml.fone);	
	
	$("#windowView").dialog({
 		modal: true,
 		width: 774,
 		show: 'fade',
		hide: 'clip',
		resizable: false,
 		buttons: {
 			"imprimir": function() {
 				top = (screen.height - 600)/2;
				left= (screen.width - 800)/2;
				window.open("../GeradorRelatorio?rel=195&parametros=444@" + idCatalogo, 
						'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
 				$(this).dialog('close');
			},
			"fechar" : function () {
				$(this).dialog('close');
			}
 		},
 		close: function() {
 			$(this).dialog('destroy');
 		}
 	});
}

function goToCadastro(value) {
	location.href = "cadastro_catalogo.jsp?state=1&id=" + value;
}

function showCadastro(value) {
	$.ajax({
		type: "GET",		
		url:"../CadastroCatalogo?from=3&contatoId=" + value,
		success: function(response) {
			loadView(response);
		}, 
		error: function(response) {
			loadView(stringToXml(response));
		}
	});
}

function excluiContato(value) {
	$.ajax({
		type: "GET",
		url:"../CadastroCatalogo?from=4&contatoId=" + value,
		success: function(response) {
			location.href = response;
		}
	});
}

function editBlocoNota() {
	var oldText = $('#blcNota').val();
	var isSave = false;
	$("#windowNota").dialog({
 		modal: true,
 		width: 800,
 		minWidth: 300,
 		show: 'fade',
		hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close');
 			},
 			"imprimir" : function() {
 				top = (screen.height - 600)/2;
				left= (screen.width - 800)/2;
				window.open("../GeradorRelatorio?rel=197&parametros=448@" + $('#usuario').val(), 
						'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
				$(this).dialog('close');
			},
 			"Salvar": function () {
 				isSave = true;
 				$.get("../CadastroCatalogo", {
 					from: '5',
 					blcNota: $('#blcNota').val() }, 
 					function(response) {
 						showMessage({
							mensagem: response,
							title: "Mensagem"
						});
 					}
 				);
				$(this).dialog('close');
 			}
 		},
 		close: function() {
 			$(this).dialog('destroy');
 			if (!isSave) {
 				$('#blcNota').val(oldText);
 			}
 		}
 	});
}

function montaRel(rel, grp) {
	link = "";
	if (rel == 189) {
		link = "../GeradorRelatorio?rel=189&parametros=367@%(login)s|368@%(nome)s|369@%(mesAniversario)s|370@%(informacao)s|375@%(grupo)s";
	} else {
		link = "../GeradorRelatorio?rel=194&parametros=438@%(login)s|439@%(nome)s|440@%(mesAniversario)s|442@%(informacao)s|443@%(grupo)s";
	}
	return $.sprintf(link, {
		login: $('#login').val(),
		nome: $('#nomeRel').val().toLowerCase(),
		mesAniversario: $('#mesAniversario').val(),
		informacao: $('#descInfo').val(),
		grupo: grp
	});
}

function printRel(rel) {
	$("#windowRel").dialog({
 		modal: true,
 		width: 688,
 		minWidth: 300,
 		show: 'fade',
		hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close');
 			},
 			"imprimir": function () { 				
 				var grupoSel = "";
				var top = (screen.height - 600)/2;
				var left= (screen.width - 800)/2;
 				$("#itemSelValues > *").each(function(index, domEle) {
			 		if (index == 0) {
			 			grupoSel = $(domEle).val();
			 		} else {
			 			grupoSel += ',' + $(domEle).val();
			 		}			 		
				});
				/*window.open("../GeradorRelatorio?rel=189&parametros=367@" + $('#login').val() + 
					"|368@" +  $('#nomeRel').val().toLowerCase() + "|369@" +  $('#mesAniversario').val() + 
					"|370@" + $('#descInfo').val() + "|375@" + grupoSel, 'nova', 
					'width= 800, height= 600, top= ' + top + ', left= ' + left);*/
 				window.open(montaRel(rel, grupoSel), 'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
				$(this).dialog('close');
 			}
 		},
 		close: function() {
 			$(this).dialog('destroy');
 		}
 	});
}

function printContato() {
	printRel(189);
}

function printCompleto() {
	printRel(194);
}

$(document).ready(function() {
	tabelaSelector = new MsfItemsSelectorAdm({
		id:"selectorTable", 
		leftId: "sortable1", 
		rightId: "sortable2", 
		valueId:"valorUsuario",
		conteinerValues: 'itemSelValues',
		height: 270
	});
	
	dataGrid = new DataGrid();
	dataGrid.addOption("Visualizar", "showCadastro(");
	dataGrid.addOption("Editar", "goToCadastro(");
	dataGrid.addOption("Excluir", "excluiContato(");
	pager = new Pager($('#gridLines').val(), 30, "../CadastroOrcamento");
	pager.mountPager();
	
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