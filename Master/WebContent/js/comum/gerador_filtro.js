var componentes;
var filtro;
var pager;
var dataGrid;
var btExibe;
var indexRel;
var idParam;
var dataMount;
var geterArray;
var auxRepos;

$(document).ready(function() {
	componentes = new Array();
	
	load = function() {
		pager = new Pager($('#gridLines').val(), 100, "../CadastroBanco");
		pager.mountPager();
		dataGrid = new DataGrid();				
		var auxArray = new Array();	
		var count = 0;
		var aux = "";
		var lastIndex = 0
		var idRel;
		var relWidth;
		var relHeight;	
		if ($("#edParam0").val() != undefined) {			
			idRel= getPipeByIndex($("#edParam0").val(), 0);
			relWidth = parseInt(getPipeByIndex($("#edParam0").val(), 1));
			relHeight = parseInt(getPipeByIndex($("#edParam0").val(), 2));
			filtro = new MsfWindow("filtro", "Assistente de Filtro", "body", 
				relHeight, relWidth, "filtro", true, false);
			filtro.setVisible(false);
			btExibe = new MsfButton("btExibe", "Exibir", "d", relWidth - 130, 
				relHeight - 40, "exibicao");
			idParam = "";
			dataMount = new Array();
			while($('#edParam' + count).val() != undefined) {
				if (idRel != getPipeByIndex($("#edParam" + count).val(), 0)) {
					componentes.push([idRel, relWidth, relHeight, auxArray]);	
					idRel = getPipeByIndex($("#edParam" + count).val(), 0);
					relWidth = getPipeByIndex($("#edParam" + count).val(), 1);
					relHeight = getPipeByIndex($("#edParam" + count).val(), 2);
					auxArray = new Array();
				}				
				aux = getPipeByIndex($("#edParam" + count).val(), 8);
				aux = virgulaToPipe(aux);
				aux = ptVirgulaToRealPipe(aux);				
				auxArray.push(new adminFiltro(getPipeByIndex($("#edParam" + count).val(), 3), 
					getPipeByIndex($("#edParam" + count).val(), 4),  
					getPipeByIndex($("#edParam" + count).val(), 5), aux,
					getPipeByIndex($("#edParam" + count).val(), 6), 
					getPipeByIndex($("#edParam" + count).val(), 7),
					getPipeByIndex($("#edParam" + count).val(), 9)));			
				
				
				if (getPipeByIndex($("#edParam" + count).val(), 4) == "i"
					|| (getPipeByIndex($("#edParam" + count).val(), 4) == "c" 
						&& aux.substring(0, 2) == "-1")) {						
					if (idParam == "") {
						idParam= getPipeByIndex($("#edParam" + count).val(), 3);
					} else {
						idParam+= "@" + getPipeByIndex($("#edParam" + count).val(), 3);
					}
				}
				count++;
			}
			componentes.push([idRel, relWidth, relHeight, auxArray]);
			if (idParam != "") {
				$.get("../GenericQuery", {
					parametro: idParam},
					function(response) {
						aux = "";
						repositorio = unmountPipe(response);
						for(var i=0; i<repositorio.length; i++) {
							auxArray = new Array();
							geterArray = new Array();
							aux = getPart(repositorio[i], 1);
							auxRepos = getPart(repositorio[i], 2);
							auxRepos = virgulaToPipe(auxRepos);
							auxRepos = ptVirgulaToRealPipe(auxRepos);						
							auxArray = unmountPipe(auxRepos);
							for(var j = 0; j< auxArray.length; j++) {
								if (j == 0) {
									geterArray.push(["0", "Selecione"]);
								}
								geterArray.push([getPart(auxArray[j], 1), getPart(auxArray[j], 2)]);
							}
							dataMount.push([aux, geterArray]);
						}
					}
				);
			}
			
			for(var j=0; j<componentes[0][3].length; j++) {
				if (componentes[0][3][j].tipoComponente() == "i") {
					if (dataMount != undefined) {
						for (var i=0; i<dataMount.length; i++) {
							if (dataMount[i][0] == componentes[0][3][j].getId()) {
								filtro.addConponent(componentes[0][3][j].getItemSelectorHtm());								
								componentes[i][3][j].showItemSelector(dataMount[i][1]);						
							}
						}						
					}
				} else if (componentes[0][3][j].tipoComponente() != "c"){
					filtro.addConponent(componentes[0][3][j].getHtm());
				} else {
					if (dataMount != undefined) {
						for (var i=0; i<dataMount.length; i++) {
							if (dataMount[i][0] == componentes[0][3][j].getId()) {
								filtro.addConponent(componentes[0][3][j].getComboHtm(dataMount[i][1]));						
							}
						}
					}
				}
			}
			filtro.init();
		}
	}
	
	appendMenu= function(value){
		var aux= "";
		var height= 0;
		var width = 0;
		var vazio= true;
		var top = (screen.height - 600)/2;
		var left= (screen.width - 800)/2;
		value= value.replace("rowMenu", "");
		for(var i=0; i<componentes.length; i++) {
			if (componentes[i][0] == value) {
				vazio = false;
				indexRel = i;
				width = parseInt(componentes[i][1]);
				height = parseInt(componentes[i][2]);
				filtro.clearContent();
				filtro.setHeight(height);
				filtro.setWidth(width);
				for(var j=0; j<componentes[i][3].length; j++) {
					if (componentes[indexRel][3][j].tipoComponente() == "i") {
						if (dataMount != undefined) {
							for (var z=0; z<dataMount.length; z++) {
								if (dataMount[z][0] == componentes[indexRel][3][j].getId()) {
									filtro.addConponent(componentes[indexRel][3][j].getItemSelectorHtm());
									componentes[indexRel][3][j].showItemSelector(dataMount[z][1]);						
								}
							}						
						}
					} else if (componentes[indexRel][3][j].tipoComponente() != "c"){
						filtro.addConponent(componentes[indexRel][3][j].getHtm());
					} else {
						if (dataMount != undefined) {
							for (var z=0; z<dataMount.length; z++) {
								if (dataMount[z][0] == componentes[indexRel][3][j].getId()) {
									filtro.addConponent(componentes[indexRel][3][j].getComboHtm(dataMount[z][1]));						
								}
							}
						} else {
							filtro.addConponent(componentes[indexRel][3][j].getHtm());
						}
					}					
					/*if (componentes[i][3][j].tipoComponente() == "i") {
						filtro.addConponent(componentes[i][3][j].getItemSelectorHtm());
						componentes[i][3][j].showItemSelector();						
					} else {
						filtro.addConponent(componentes[i][3][j].getHtm());												
					}*/					
				}
			}
		}
		if (!vazio) {
			btExibe = new MsfButton("btExibe", "Exibir", "d", width - 130, 
					height - 40, "exibicao");
			filtro.addConponent(btExibe.getHtm())
			filtro.repaint();
			filtro.show();			
		} else {
			//alert("relatorio: " + value);
			//alert("parametros: ");
			window.open("../GeradorRelatorio?rel=" + value +
			"&parametros=", 'Relatório', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
		}
		/*for(var i=0; i<componentes.length; i++) {
			for(var j=0; j<componentes[i][3].length; j++) {
				alert("parametro 1");
				alert(componentes[i][3][j].getValue());
			}
			
		}*/
	}
	
	exibicao = function() {		
		var aux = "";
		var top = (screen.height - 600)/2;
		var left= (screen.width - 800)/2;		
		for(var i=0; i<componentes[indexRel][3].length; i++) {			
			if (i == 0) {								
				aux+= componentes[indexRel][3][i].getId() + "@" + 
					pipeToVirgula(componentes[indexRel][3][i].getValue());
			} else {
				aux+= "|" + componentes[indexRel][3][i].getId() + "@" + 
					pipeToVirgula(componentes[indexRel][3][i].getValue());				
			}
		}
		//alert("relatorio: " + componentes[indexRel][0]);
		//alert("parametros: " + aux);
		filtro.hide();
		window.open("../GeradorRelatorio?rel=" + componentes[indexRel][0] +
			"&parametros=" + aux, 'Relatório', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
	}
	
	$(this).ajaxStart(function(){
		showLoader('Carregando...', 'body', false);
	});
	
	$(this).ajaxStop(function(){
		hideLoader();	
	});
	
	load();
});