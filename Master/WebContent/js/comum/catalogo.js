function cadastroGrupo(grupoId) {
	if (grupoId == 'e') {
		$('#descGrupo').val("");
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
				$.get("../CadastroGrupo", {
					from: '0',
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

function validaSubmit() {	
	$('#FirstrequeridovalidMsg').parent().remove();
	if ($('#primeiroNome').val() == "") {
		$('#primeiroNome').after("<div class=\"erroConteiner\"> " +
			"<p class=\"validMsg\" id=\"FirstrequeridovalidMsg\">"+
			"Campo Requerido!</p></div>");
			
		return false;
	}
	
	$('#enderecoRequeridovalidMsg').parent().remove();
	$('#cidadeRequeridovalidMsg').parent().remove();
	$('#ufRequeridovalidMsg').parent().remove();
	if ($('#cepIn').val() != ""
		|| $('#endereco').val() != ""
		|| $('#complemento').val() != ""
		|| $('#bairro').val() != ""
		|| $('#cidade').val() != ""
		|| $('#uf').val() != "") {
		
		if ($('#endereco').val() == "") {
			$('#endereco').after("<div class=\"erroConteiner\"> " +
				"<p class=\"validMsg\" id=\"enderecoRequeridovalidMsg\">"+
				"Campo Requerido!</p></div>");
			return false;
		}
		
		if ($('#cidade').val() == "") {
			$('#cidade').after("<div class=\"erroConteiner\"> " +
				"<p class=\"validMsg\" id=\"cidadeRequeridovalidMsg\">"+
				"Campo Requerido!</p></div>");
			return false;
		} 			
			
		
		if ($('#uf').val() == "") {
			$('#uf').after("<div class=\"erroConteiner\"> " +
				"<p class=\"validMsg\" id=\"ufRequeridovalidMsg\">"+
				"Campo Requerido!</p></div>");
			return false;
		}
	}
	
	$('#empresaRequeridovalidMsg').parent().remove();
	if (($('#cargo').val() != ""
		|| $('#setor').val() != ""
		|| $('#cepEmp').val() != ""
		|| $('#enderecoEmp').val() != ""
		|| $('#complementoEmp').val() != ""
		|| $('#bairroEmp').val() != ""
		|| $('#cidadeEmp').val() != ""
		|| $('#ufEmp').val() != ""
		|| $('#site').val() != ""
		|| $('#foneEmp').val() != "") 
		&& $('#empresa').val() == "") {
		
		$('#empresa').after("<div class=\"erroConteiner\"> " +
			"<p class=\"validMsg\" id=\"empresaRequeridovalidMsg\">"+
			"Campo Requerido!</p></div>");
			
		return false;
	}
	return true;
}

function cadastroContato(value) {
	if (value == '-1') {
		clearContato();
	} else {
		loadContato(value);
	}
	var parameters = new Array();
	parameters.push({name: "catalogoId", value: value});
	parameters.push({name: "from", value: '200'});
	$('#flex1').flexOptions({params: parameters}).flexReload();
	$('#catalogoId').val(value);
	$('#windowContato').removeClass("cpEscondeWithHeight");
	$("#windowContato").dialog({
		modal: true,
 		width: 600,
 		minWidth: 600,
 		show: 'fade',
		hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close');
 			},
 			"Salvar": function () {
 				if (validaSubmit()) {
					$.get("../CadastroGrupo", {
						from: "1",
						catalogoId: value,
						infoPipe: processaPipe(),
						primeiroNome: $('#primeiroNome').val(),
						ultimoNome: $('#ultimoNome').val(),
						apelido: $('#apelido').val(),
						usuario: $('#usuario').val(),
						aniverssario: $('#aniverssario').val(),
						grupoContato: $('#grupoContato').val(),
						cep: $('#cepIn').val(),
						endereco: $('#endereco').val(),
						complemento: $('#complemento').val(),
						bairro: $('#bairro').val(),
						cidade: $('#cidade').val(),
						uf: $('#uf').val(),
						cargo: $('#cargo').val(),
						setor: $('#setor').val(),
						empresa: $('#empresa').val(),
						cepEmp: $('#cepEmp').val(),
						enderecoEmp: $('#enderecoEmp').val(),
						complementoEmp: $('#complementoEmp').val(),
						bairroEmp: $('#bairroEmp').val(),
						cidadeEmp: $('#cidadeEmp').val(),
						ufEmp: $('#ufEmp').val(),
						site: $('#site').val(),
						foneEmp: $('#foneEmp').val()
						}, 
						function(response) {
							location.href = response;
						}
					);
					$(this).dialog('close');
 				}
 			}
 		},
 		close: function() { 			
 			$(this).dialog('destroy');
 		}		
	});	
	$('#gridLines').val('0');
}

function processaPipe() {
	var pipe = $("tr[id^='row']");
	var count = pipe.length - 1;
	//pipe = $("tr[id^='row']").attr("id");
	var aux = pipe = "";
	/*if (count >= 0) {
		pipe = pipe.substr(3, pipe.length);				
	} else {
		pipe = "";
	}0*/
	$("tr[id^='row']").each(function(i) {
		aux = $(this).attr("id");
		aux = aux.substr(3, $(this).attr("id").length);
		pipe+= aux;
		$(this).find("td").each(function (j) {
			pipe+=  "," + $(this).find("div").text();
		});
		if (count != i) {
			pipe+= "|";
		}
	});
	return pipe;
}

function processaParametros(tipo) {	
	var parametros = Array();	
	var gridLines = parseInt($('#gridLines').val());
	
	switch (tipo) {
		case 'i': //inserção de informação de contato
			if ($('#catalogoId').val() == "-1") {
				parametros.push({name:"from", value:"2"});
			} else {
				parametros.push({name:"from", value:"3"});
			}
			parametros.push({name:"idToRemove", value: 'n'});
			parametros.push({name:"idToEdit", value: 'n'});
			parametros.push({name:"total", value: ++gridLines});
			$('#gridLines').val(gridLines);
			break;

		case 'e':
			if ($('#catalogoId').val() == "-1") {
				parametros.push({name:"from", value:"2"});
			} else {
				parametros.push({name:"from", value:"3"});
			}
			parametros.push({name:"idToRemove", value: 'n'});
			parametros.push({name:"idToEdit", value: $('#idToProcess').val()});
			parametros.push({name:"total", value: gridLines});
			break;
			
		case 'r':
			if ($('#catalogoId').val() == "-1") {
				parametros.push({name:"from", value:"2"});
			} else if (parseInt($('#idToProcess').val()) < 0) {
				parametros.push({name:"from", value:"4"});
			} else {
				parametros.push({name:"from", value:"3"});
			}
			parametros.push({name:"idToRemove", value: $('#idToProcess').val()});
			parametros.push({name:"idToEdit", value: 'n'});
			parametros.push({name:"total", value: --gridLines});
			$('#gridLines').val(gridLines);
			break;
	}
	parametros.push({name:"infoPipe", value: processaPipe()});
	parametros.push({name:"tipo", value: $('#tipo').val()});
	parametros.push({name:"descricao", value: $('#descricaoInfo').val()});
	parametros.push({name:"principal", value: $('#principal').val()});
	return parametros;
}

function addInformacaoContato() {
	$('#flex1').flexOptions({params: processaParametros('i')}).flexReload();
	clearInfo()
}

function editInformacaoContato() {
	$('#flex1').flexOptions({params: processaParametros('e')}).flexReload();
}

function removeInformacaoContato() {
	$('#flex1').flexOptions({params: processaParametros('r')}).flexReload();
}

function clearContato() {
	$('#primeiroNome').val("");
	$('#ultimoNome').val("");
	$('#apelido').val("");	
	$('#usuario').val("");
	document.getElementById("grupoContato").selectedIndex = 0;
	$('#cepIn').val("");
	$('#endereco').val("");
	$('#complemento').val("");
	$('#bairro').val("");
	$('#cidade').val("");
	$('#uf').val("");	
	$('#cargo').val("");
	$('#setor').val("");
	$('#empresa').val("");
	$('#cepEmp').val("");
	$('#enderecoEmp').val("");
	$('#complementoEmp').val("");
	$('#bairroEmp').val("");
	$('#cidadeEmp').val("");
	$('#ufEmp').val("");
	$('#site').val("");
	$('#foneEmp').val("");
	clearInfo();
}

function clearInfo() {
	document.getElementById("tipo").selectedIndex = 0;
	$('#descricaoInfo').val("");
	document.getElementById("principal").selectedIndex = 1;
}

function loadEndereco(xml) {
	$('#endereco').val($(xml).find("rua").text() + ", ");
	$('#bairro').val($(xml).find("bairro").text());
	$('#cidade').val($(xml).find("cidade").text());
	$('#uf').val($(xml).find("uf").text());
	$('#endereco').focus();
}

function loadEnderecoEmp(xml) {
	$('#enderecoEmp').val($(xml).find("rua").text() + ", ");
	$('#bairroEmp').val($(xml).find("bairro").text());
	$('#cidadeEmp').val($(xml).find("cidade").text());
	$('#ufEmp').val($(xml).find("uf").text());
	$('#enderecoEmp').focus();
}

function loadContato(id) {
	var aux = "";
	$('#primeiroNome').val($('#primeiroNome' + id).val());
	$('#ultimoNome').val($('#ultimoNome' + id).val());
	$('#apelido').val($('#apelido' + id).text());
	$('#usuario').val(trim($('#usuario' + id).text()));
	$('#aniverssario').val(trim($('#aniverssario' + id).text()));
	$('#grupoContato').val(trim($('#grupoContato' + id).val()));
	$('#cepIn').val(trim($('#cep' + id).text()));
	$('#endereco').val($('#endereco' + id).text());
	$('#complemento').val($('#complemento' + id).text());
	$('#bairro').val($('#bairro' + id).text());
	aux = $('#cidade' + id).text();
	aux = aux.substr(0, aux.length - 6);	
	$('#cidade').val(aux);
	aux = $('#cidade' + id).text();
	aux = aux.substr(aux.length - 3, aux.length);
	$('#uf').val(trim(aux));
	$('#cargo').val($('#cargo' + id).text());
	$('#setor').val($('#setor' + id).text());
	$('#empresa').val($('#empresa' + id).val());
	$('#cepEmp').val(trim($('#cepEmp' + id).text()));
	$('#enderecoEmp').val($('#enderecoEmp' + id).text());
	$('#complementoEmp').val($('#complementoEmp' + id).text());
	$('#bairroEmp').val($('#bairroEmp' + id).text());
	aux = $('#cidadeEmp' + id).text();
	aux = aux.substr(0, aux.length - 6);	
	$('#cidadeEmp').val(aux);
	aux = $('#cidadeEmp' + id).text();
	aux = aux.substr(aux.length - 3, aux.length);
	$('#ufEmp').val(trim(aux));
	$('#site').val(trim($('#site' + id).text()));
	$('#foneEmp').val(trim($('#foneEmp' + id).text()));
}



function loadToEdit(fields) {
	for(var i=0; i<fields.length; i++) {
		switch (i) {
			case 0:
				$('#idToProcess').val(fields[i]);
				break;

			case 1:
				$('#tipo').find("option").each(function() {
					if ($(this).text() == fields[i]) {
						$(this).attr({selected: "selected"});
					}
				});
				break;
				
			case 2:
				$('#descricaoInfo').val(fields[i]);
				break;
				
			case 3:
				if (fields[i] == "Sim") {
					document.getElementById("principal").selectedIndex = 0;
				} else {
					document.getElementById("principal").selectedIndex = 1;
				}				
				break;
		}

	}
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

$(document).ready(function() {
	$('.accordionItem').accordion({
		collapsible: true,
		active: false,
		fillSpace: true
	});


	$('#accordiomGrupo').accordion({
		collapsible: true,
		active: false,
		fillSpace: true
	});	
	
	$('#tabsWindow').tabs();
		
	$("#flex1").flexigrid({
		url: '/CadastroGrupo',
		dataType: 'json',
		colModel : [			
			{display: 'Tipo', name : 'tipo', width : 132, sortable : false, align: 'left'},
			{display: 'Descrição', name : 'descricao', width : 223, sortable : false, align: 'left'},
			{display: 'principal', name : 'printable_name', width : 100, sortable : false, align: 'center'}
			],
		searchitems : [
			{display: 'Descricão', name : 'descricao'},
			{display: 'Principal', name : 'principal', isdefault: true}
		],
		buttons: [
			{name:'Adicionar', bclass: 'buttonAddJquery', onpress: addInformacaoContato},
			{name:'Editar', bclass: 'buttonEditJquery', onpress: editInformacaoContato},
			{name:'Remover', bclass: 'buttonRemoveJquery', onpress: removeInformacaoContato}
		],
		sortname: "codigo",
		sortorder: "asc",
		usepager: false,
		title: 'Informações',
		method: 'GET',
		useRp: true,
		singleSelect: true,
		rp: 7,
		params: [
			{name:"from", value: "200"},
			{name:"catalogoId", value: "-1"}
		],
		showTableToggleBtn: true,
		width: 511,
		height: 'auto'
	});
	
	$(this).ajaxStop(function(){
		$("tr[id^='row']").click(function () {			
			//alert($(this).find("div:first").text());
			if ($(this).hasClass("trSelected")) {
				var fields = new Array();
				var aux = $(this).find("td");
				var count = aux.length - 1;
				aux = $(this).attr("id");
				aux = aux.replace("row", "");
				fields.push(aux);
				$(this).find("td").each(function (i) {					
					aux = $(this).find("div").text();
					fields.push(aux);
					if (i == count) {
						loadToEdit(fields);
					}
				});
			}
		});
	});
	
	$('#cepIn').blur(function() {
		if ($('#cepIn').val() != "" && $('#cepIn').val().length == 9) {
			$.ajax({
				type: "GET",
				url: "../FuncionarioGet?from=15&cep=" + $('#cepIn').val(),
				success: function(response) {
					loadEndereco(response)
				}, 
				error: function(response) {
					loadEndereco(stringToXml(response));
				}
			});
		}
	});
	
	$('#cepEmp').blur(function() {
		if ($('#cepEmp').val() != "" && $('#cepEmp').val().length == 9) {
			$.ajax({
				type: "GET",
				url: "../FuncionarioGet?from=15&cep=" + $('#cepEmp').val(),
				success: function(response) {
					loadEnderecoEmp(response)
				}, 
				error: function(response) {
					loadEnderecoEmp(stringToXml(response));
				}
			});
		}
	});
	
});
