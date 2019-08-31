var pager;
var flag= false;
var dataGrid;
var componentesConfig;

function load() {
	var count = 0;
	componentesConfig = new Array();
	pager = new Pager($('#gridLines').val(), 20, "../CadastroParametro");
	pager.mountPager();
	dataGrid = new DataGrid();
	while($("#cpParam" + count).val() != undefined) {
		componentesConfig.push([
			getPipeByIndex($("#cpParam" + count).val(), 0),
			getPipeByIndex($("#cpParam" + count).val(), 1),
			getPipeByIndex($("#cpParam" + count).val(), 2),
			getPipeByIndex($("#cpParam" + count).val(), 3),
			$("#cpData" + count++).val()
		]);
	}
}

function getNext(){
	if (flag) {
		flag= false;
		search();
	} else {
		if ((pager.limit * pager.currentPage) < pager.recordCount) {
			$.get("../CadastroParametro",{
				gridLines: pager.limit , 
				limit: pager.limit, 
				isFilter: "0",
				offset: pager.offSet + pager.limit,				
				from: "0"},
			function (response) {				
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.nextPage();
			dataGrid = new DataGrid();
		}			
	}
}

function getPrevious(){
	if (flag) {
		flag= false;
		search();
	} else {
		if (pager.offSet > 0) {
			$.get("../CadastroParametro",{
				gridLines: pager.limit, 
				limit: pager.limit,
				isFilter: "0",
				offset: pager.offSet - pager.limit,	
				from: "0"},
				function(response){
					$('#dataBank').empty();
					$('#dataBank').append(response);
			});
			pager.previousPage();
			dataGrid = new DataGrid();
		}			
	}
}

function renderize(value) {
	if (flag) {
		flag= false;
		search();
	} else {
		pager.sortOffSet(value);
		$.get("../CadastroParametro",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: pager.offSet, 
			isFilter: "0", 
			from: "0"},
		function(response) {
			$('#dataBank').empty();
			$('#dataBank').append(response);
		});
		pager.calculeCurrentPage(); 	
		pager.refreshPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Cadastro", "goToCadastro(");
		dataGrid.addOption("Parametros", "goToParametros(");
	}
}

function goToCadastro() {
	location.href = 'cadastro_parametro.jsp?codRel=' + $("#codRel").val();
}

function upConfig(){
	var posicao;
	var aux = "";
	var pipe = new Array();
	for (var i=0; i<componentesConfig.length; i++) {			
		if (componentesConfig[i][1] == "r") {
			posicao = $("#" + componentesConfig[i][0] + "RdTitle").position();
			componentesConfig[i].splice(2, 1, parseInt(posicao.left));
			componentesConfig[i].splice(3, 1, parseInt(posicao.top));
			pipe = unmountPipe(componentesConfig[i][4]);
			for (var j = 0; j < pipe.length; j++) {
				if (j == 0) {
					aux += getPipeByIndex(pipe[j], 0);
				}
				else {
					aux += "|" + getPipeByIndex(pipe[j], 0);
				}
				posicao = $("#" + componentesConfig[i][0] + "RdLb" + j).position();
				aux += "@" + parseInt(posicao.left) + "@" + parseInt(posicao.top);
				posicao = $("#" + componentesConfig[i][0] + "Rd" + j).position();
				aux += "@" + parseInt(posicao.left) + "@" + parseInt(posicao.top);
				aux += "@" + getPipeByIndex(pipe[j], 5);
			}
			componentesConfig[i].splice(4, 1, aux);
		} else if (componentesConfig[i][1] == "i") {
			posicao = $("#selector" + componentesConfig[i][0]).position();
			componentesConfig[i].splice(2, 1, parseInt(posicao.left));
			componentesConfig[i].splice(3, 1, parseInt(posicao.top));
		} else if(componentesConfig[i][1] == "t" || componentesConfig[i][1] == "c") {
			posicao = $("#lbText" + componentesConfig[i][0]).position();
			componentesConfig[i].splice(2, 1, parseInt(posicao.left));
			componentesConfig[i].splice(3, 1, parseInt(posicao.top));
			posicao = $("#dataPrompt" + componentesConfig[i][0]).position();
			aux+= parseInt(posicao.left) + "@" + parseInt(posicao.top) + "@" + getPipeByIndex(componentesConfig[i][4], 2);
			componentesConfig[i].splice(4, 1, aux); 
		} else if (componentesConfig[i][1] == "d") {
			posicao = $("#1lbText" + componentesConfig[i][0]).position();
			componentesConfig[i].splice(2, 1, parseInt(posicao.left));
			componentesConfig[i].splice(3, 1, parseInt(posicao.top));
			posicao = $("#1dataPrompt" + componentesConfig[i][0]).position();
			aux+= parseInt(posicao.left) + "@" + parseInt(posicao.top) + "@" + getPipeByIndex(componentesConfig[i][4], 2);
			posicao = $("#2lbText" + componentesConfig[i][0]).position();
			aux+= "@" + getPipeByIndex(componentesConfig[i][4], 3) + "@" + parseInt(posicao.left) + "@" + parseInt(posicao.top);
			posicao = $("#2dataPrompt" + componentesConfig[i][0]).position();
			aux+= "@" + parseInt(posicao.left) + "@" + parseInt(posicao.top) + "@" + getPipeByIndex(componentesConfig[i][4], 8);
			componentesConfig[i].splice(4, 1, aux);
		} else if (componentesConfig[i][1] == "k") {
			posicao = $("#checkPai" + componentesConfig[i][0]).position();				
			componentesConfig[i].splice(2, 1, parseInt(posicao.left));
			componentesConfig[i].splice(3, 1, parseInt(posicao.top));
			$("#imgCheck" + componentesConfig[i][0]).css({
				"top": posicao.top,
				"left": posicao.left + 25					
			});
		}
		aux = "";
	}
}

function refreshParametro() {
	var id = "";
	var position = "";
	var dados= "";
	var aux= "";
	for(var i=0; i<componentesConfig.length; i++) {
		aux = pipeToVirgula(componentesConfig[i][4]);
		aux = realPipeToPtVirgula(aux);
		if (i == 0) {
			id+= componentesConfig[i][0];
			position+= componentesConfig[i][0] + "@" + componentesConfig[i][2] + 
				"@" + componentesConfig[i][3];
			 dados+= componentesConfig[i][0] + "@" + aux;
		} else {
			id+= "@" + componentesConfig[i][0];
			position+= "|" + componentesConfig[i][0] + "@" + 
				componentesConfig[i][2] + "@" + componentesConfig[i][3];
			dados+= "|" + componentesConfig[i][0] + "@" + aux;
		}			
	}
	//alert(id);
	//alert(position);
	//alert(dados);
	$.get("../CadastroParametro",{
		id: id,
		position: position,
		dados: dados,
		from: "1"		
	}, function(response) {
		if (response == 0) {
			alert("Erro!!")
		} else {
			location.href = "relatorio_adm.jsp";
		}
	});
}

function showWd() {
	if ($('#haveParam').val() == "s") {
		$("#paramWindow").dialog({
	 		modal: true,
	 		width: 580,
	 		minWidth: 520,
	 		show: 'fade',
	 		hide: 'clip',
	 		buttons: {
	 			"Cancelar": function() {
	 				$(this).dialog('close');
				},
	 			"Sequenciar" : function () {	 				
					$.get("../CadastroParametro",{						
						from: "3",
						codRel: $("#codRel").val(),
						pipe: mountPipe()},
						function (response) {
							if (response == "0") {									
								location.reload();
							} else {
								location.href= '../error_page.jsp?errorMsg=Ocorreu um erro durante o pagamento das mensalidades!&lk=' +
									'application/relatorio.jsp';
							}
						}
					);						
					$(this).dialog('close');
					//alert(mountPipe());
	 			}		 			
	 		},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
	 	});
	}
}

function mountPipe() {
	var result = "";
	$('#conteinerSeq >*').each(function (index) {
		if ($(this).val() == undefined || $(this).val() == "") {
			result+= (index == 0)? $(this).text() : "|" + $(this).text();		
		} else  {
			result+= "@" + $(this).val();
		}
	});
	return result;
}


$(document).ready(function() {
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
	
	$("#WdContente > *").draggable({
		snapDistance: 10, 
		ghosting: false,
		opacity: 0.2,
		zindex: 1000,
		handle: 'div.cpWarningHeader',
		stop: function(event, ui) {
			upConfig();
		}
	});
});