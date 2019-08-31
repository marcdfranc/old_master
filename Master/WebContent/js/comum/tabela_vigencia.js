var itTabela;
var selectorData;
var arrayAux;
var tabelaSelector;

$(document).ready(function() {
	tabelaSelector = new MsfItemsSelectorAdm({
		id:"selectorTable", 
		leftId: "sortable1", 
		rightId: "sortable2", 
		valueId:"valorUsuario",
		conteinerValues: 'itemSelValues',
		height: 270
	});	
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	$(this).ajaxStop(function(){		
		hideLoader();
	});	
});



/**
 * save
 * @param {type}  
 */
save = function() {	
	var vig = ""; 
	var size = -1;
 	$("#itemSelValues > *").each(function(index, domEle) {
 		if (index == 0) {
 			vig = $(domEle).val();
 		} else {
 			vig += ', ' + $(domEle).val();
 		}
 		size = index;
	});		
	if (size == -1) {
		showErrorMessage ({
			width: 400,
			mensagem: "É necessária a escolha de pelo menos uma das tabela para aprovação!",
			title: "Erro"
		});
	} else {						
		$.get("../CadastroTabelaVigente",{
			aprovadas: vig,
			from: "2",
			unidadeId: $("#unidadeIdIn").val()},
			function (response) {
				location.href = '../error_page.jsp?errorMsg=' + response + 
								'&lk=application/tabela_vigencia.jsp';
			}
		);
	}
}

/**
 * generateTable
 * @param {type}  
 */
function generateTable() { 	
	if ($("#sortable2 li.selectedItem").length > 1) {
		showErrorMessage ({
			width: 400,
			mensagem: "Só pode haver uma tabela modelo para geração!",
			title: "Erro"
		});
	} else if ($("#sortable2 li.selectedItem").length == 0) {
		showErrorMessage ({
			width: 400,
			mensagem: "É necessária a escolha de uma das tabela para modelo de geração!",
			title: "Erro"
		});			
	} else {
		$("#tableGenerateWindow").dialog({
	 		modal: true,
	 		width: 650,
	 		minWidth: 450,
	 		show: 'fade',
			hide: 'clip',
	 		buttons: {
	 			"Cancelar": function() {
	 				$(this).dialog('close');
				},
	 			"Gerar Tabela" : function () {
	 				//alert($("#sortable2 li.selectedItem").attr("title"));
	 				$.get("../CadastroTabelaVigente",{
						vigencia: $("#sortable2 li.selectedItem").attr("title"),
						from: "1",
						unidadeId: $("#unidadeIdIn").val(),
						descricao: $("#descTable").val()},
						function (response) {
							//var url = location.href;
							showOption({
								title: "Mensagem",
								mensagem: response,
								width: 400,
								show: 'fade',
								hide: 'clip',
								buttons: {
									"Ok": function() {
										location.href = url;
									}
								}
							});							
							/*location.href = '../error_page.jsp?errorMsg=' + response + 
								'&lk=application/tabela_vigencia.jsp';*/
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
}

function addEventsTable() {
	/*$("#sortable1 li").click(function() {
		alert("aqui é lado A tbm conhecido como um na parada");
	});
	
	$("#sortable2 li").click(function() {
		alert("somos lado b");
	});*/
	
}

function reloadTables() {
	$.get("../CadastroTabelaVigente",{
		from: "3",
		unidadeId: $("#unidadeIdIn").val()
	},
	function (response) {
		var tabela;
		var aprovada;
		var html = "";
		if (getPart(response, 0) == "1") {
			location.href = '../error_page.jsp?errorMsg=' + 
			getPart(response, 1) + 
			'&lk=application/tabela_vigencia.jsp';
		} else {
			tabela = unmountPipe(response);
			aprovada = unmountPipe(toRealPipe(tabela[1]));
			tabela = unmountPipe(toRealPipe(tabela[0]));
			for(var i = 1; i < tabela.length; i++) {
				if (tabela[i] != "") {							
					html+= "<li style=\"min-height: 20px\" title=\"" + 
					getPart(virgulaToPipe(tabela[i]), 1)  +
					"\" onclick=\"msfEventClickItenOfItSelector(this)\" >" +
					getPart(virgulaToPipe(tabela[i]), 2) + "</li>"
				}
			}
			$('#sortable1').empty();
			$('#sortable1').append(html);
			html = "";
			for(var i = 0; i < aprovada.length; i++) {
				if (aprovada[i] != "") {
					html+= "<li style=\"min-height: 20px\" title=\"" + 
					getPart(virgulaToPipe(aprovada[i]), 1) +
					"\" onclick=\"msfEventClickItenOfItSelector(this)\" >" + 
					getPart(virgulaToPipe(aprovada[i]), 2) + "</li>"
				}
			}
			$('#sortable2').empty();
			$('#sortable2').append(html);
			
			addEventsTable();
		}
	});
	
}

function editVigencia() {
	var id = "";
		$("#sortable1 > *").each(function(index, domEle) {
 		if(domEle.className == "selectedItem") {
 			if (id == "") {
 				id = domEle.title;
 			} else {
 				id = "-1";
 			}
 		}
	});
	$("#sortable2 > *").each(function(index, domEle) {
 		if(domEle.className == "selectedItem") {
 			if (id == "") {
 				id = domEle.title;
 			} else {
 				id = "-1";
 			}
 		}
	});
	if (id == "") {
		showErrorMessage ({
			width: 400,
			mensagem: "É necessária a seleção de uma tabela para edição!",
			title: "Erro"
		});
	} else if(id == "-1") {
		showErrorMessage ({
			width: 400,
			mensagem: "Só é possível editar uma tabela por vez!",
			title: "Erro"
		});
	} else {
		$("#vigenciaWindow").dialog({
	 		modal: true,
	 		width: 300,
	 		minWidth: 300,
	 		show: 'fade',
			hide: 'clip',
	 		buttons: {
	 			"Cancelar": function() {
	 				$(this).dialog('close');
				},
	 			"Editar" : function () {
	 				$.get("../CadastroTabelaVigente",{
						from: "4",
						vigenciaId: id,
						descricao: $("#descVigencia").val()},
						function (response) {
							reloadTables();
							showMessage ({
								width: 400,
								mensagem: response,
								title: "Edição de tabela"
							});	
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

}

/**
 * createTable
 * @param {type} param 
 */
function createTable(param) {
	$("#newTableWindow").dialog({
 		modal: true,
 		width: 650,
 		minWidth: 450,
 		show: 'fade',
		hide: 'clip',
 		buttons: {
 			"Cancelar": function() {
 				$(this).dialog('close');
			},
 			"Gerar Tabela" : function () {
 				$.get("../CadastroTabelaVigente",{
					from: "0",
					unidadeId: $("#unidadeIdIn").val(),
					descricao: $("#descNewTable").val()},
					function (response) {
						alert(response);
						
						/*location.href = '../error_page.jsp?errorMsg=' + response + 
							'&lk=application/tabela_vigencia.jsp';*/
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

function noAccess() {
	showErrorMessage ({
		width: 400,
		mensagem: "Você não tem permissão suficiente para realizar esta operação!",
		title: "Erro"
	});
}
