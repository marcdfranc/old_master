var sufix = "http://localhost:8080/birt-viewer/frameset?__report=";
var dataGrid;

$(document).ready(function() {
	load = function() {
		pager = new Pager($('#gridLines').val(), 10, "../CadastroBanco");
		pager.mountPager();
		dataGrid = new DataGrid();
	}
	
	appendMenu= function(value){		
		value= value.replace("rowMenu", "");
		var top = (screen.height - 600)/2;
		var left= (screen.width - 800)/2;
		var widthId = value.replace("wd", "");
		var mimWidth = parseInt($("#prWd" + widthId).val());
		if ($("#prWd" + widthId).val() == undefined) {
			window.open("../GeradorRelatorio?rel=" + widthId + "&parametros=", 'Relatório', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
		} else {
		 	$('#' + value).dialog({
		 		modal: true,
		 		width: mimWidth,
		 		minWidth: mimWidth,
		 		show: 'scale',
		 		buttons: {
		 			"cancelar": function() {
		 				$(this).dialog('close');
		 			},
		 			"Exibir": function() {
		 				var formulario = document.forms['form' + widthId];
		 				var url = "../GeradorRelatorio?rel=" + widthId + "&parametros=";
						var isFirst = true;					
		 				for(var i = 1; i < formulario.elements.length; i++) {
		 					if (isFirst) {
		 						if ($(formulario.elements[i]).hasClass('dpPrompt') && $(formulario.elements[i]).hasClass('itemA')) {
		 							var idAux = formulario.elements[i].id.replace("nextA", "");
		 							url+= idAux + '@' + $('#nextA' + idAux).val() + "?" + $('#nextB' + idAux).val();
		 						} else if (formulario.elements[i].type == "radio") {
			 						if (formulario.elements[i].checked) {
				 						url+= formulario.elements[i].id.replace("param", "") + "@" +
					 						formulario.elements[i].value;
					 					isFirst = false;			 							
			 						}
		 						} else if (formulario.elements[i].type != "radio"){
			 						if (formulario.elements[i].value != undefined) {
			 							if (formulario.elements[i].id.substr(0, 4) != 'next') {
				 							url+= formulario.elements[i].id.replace("param", "") + "@" +
						 						formulario.elements[i].value;
					 						isFirst = false;			 								
			 							}
			 						}
		 						}			 								 					
		 					} else {
		 						if ($(formulario.elements[i]).hasClass('dpPrompt') && $(formulario.elements[i]).hasClass('itemA')) {
		 							var idAux = formulario.elements[i].id.replace("nextA", "");
		 							url+= "|" + idAux + '@' + $('#nextA' + idAux).val() + "?" + $('#nextB' + idAux).val();
								} else 	if (formulario.elements[i].type == 'radio') {
		 							if (formulario.elements[i].checked) {
				 						url+= "|" + formulario.elements[i].id.replace("param", "") + "@" +
					 						formulario.elements[i].value;
		 							}
		 						} else if (formulario.elements[i].type != 'radio'){
			 						if (formulario.elements[i].value != undefined && !$(formulario.elements[i]).hasClass('itemB') && !$(formulario.elements[i]).hasClass('dpPrompt')) {
			 							if (formulario.elements[i].id.substr(0, 4) != 'next') {
				 							url+= "|" + formulario.elements[i].id.replace("param", "") + "@" +
						 						formulario.elements[i].value;
			 							}
			 						}
		 						}
		 					}
		 				}
		 				//alert(url);
		 				window.open(url, 'Relatório', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
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
	 * refreshDoubleValue
	 * @param {type} idObj 
	 */
	refreshDoubleValue = function(idObj) {
	 	var idReal = idObj.replace("param", "");
	 	$("#" + idObj).val($("#nextA" + idReal).val() + "?" + $("#nextB" + idReal).val());
	}
		
});