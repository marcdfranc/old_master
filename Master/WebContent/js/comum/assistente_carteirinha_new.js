var carteirinhaWindow;
	
function showAssistente() {
	$("#stage1").removeClass("cpEscondeWithHeight");
 	if ($.browser.msie) {
	 	$("#stage1").dialog({
	 		modal: true,
	 		width: 450,
	 		minWidth: 450,
	 		show: 'fade',
		 	hide: 'clip',
	 		buttons: {
	 			"Cancelar": function() {
	 				$(this).dialog('close');	 				
	 			},
	 			"Avançar >" : function() {
	 				loadItenSelector(this);
	 			}
	 		},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
	 	});	 		
 	} else {
 		$("#stage1").dialog({
	 		modal: true,
	 		width: 450,
	 		minWidth: 450,
	 		show: 'fade',
		 	hide: 'clip',
	 		buttons: {
	 			"Cancelar": function() {
	 				$(this).dialog('close');	 				
	 			},
	 			"Avançar >" : function() {
	 				loadItenSelector(this);
	 			}
	 		},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
	 	});
 	}
 	
 	

}

function loadItenSelector(elemento) {
 	$.get("../Carteirinha", {
		from: "0",
		via: $("#via").val(),
		ctrEmpresa: $("#selecao").val(),
		pipe: $("#ctrCarteira").val(),
		unidade: $("#CarteiraUnd").val(),
		dependenteType: $("#emissao").val()},
		function (response) {
			var dado = unmountPipe(response);
			var leftBox = "";
			for(var i = 0; i < dado.length; i++) {
				leftBox+= "<li  style=\"height: 20px\" title=\"" + 
				getPart(dado[i], 1) + "\" >" + getPart(dado[i], 2) + 
				"</li>";
			}
			$("#sortableLeft").empty();
			$("#sortableRight").empty();
			$("#sortableLeft").append(leftBox);
			carteirinhaWindow.addToLeftBox();
			$('ul.connectedSortable  li').click(function() {				
				if ($(this).hasClass("selectedItem")) {
					$(this).removeClass("selectedItem");      		
				} else {
					$(this).addClass("selectedItem");
				}
			});
		}
	);
	$(elemento).dialog('close');
	showStage2();
}

function showStage2() {
	$("#stage2").removeClass("cpEscondeWithHeight");
 	if ($.browser.msie) {
 		$("#stage2").dialog({
	 		modal: true,
	 		width: 759,
	 		height: 450,
	 		minWidth: 759,
	 		show: 'fade',
		 	hide: 'clip',
	 		buttons: {	 			
	 			"Cancelar": function() {
	 				$(this).dialog('close');	 				
	 			},
	 			"Avançar >" : function() {
	 				showReport(this);
	 			},
	 			"< voltar": function() {
	 				$(this).dialog('close');	 				
	 				showAssistente();
	 			}	 			
	 		},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
	 	});
 	} else {
 		$("#stage2").dialog({
	 		modal: true,
	 		width: 759,
	 		height: 450,
	 		minWidth: 759,
	 		show: 'fade',
		 	hide: 'clip',
	 		buttons: {	 			
	 			"Cancelar": function() {
	 				$(this).dialog('close');
	 			},
	 			"Avançar >" : function() {
	 				showReport(this);
	 			},
	 			"< voltar": function() {
	 				$(this).dialog('close'); 				
	 				showAssistente();
	 			}	 			
	 		},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
	 	});
 	}
}

function showReport(elemento) {
	var refPessoa = "";
	var top = (screen.height - 600)/2;
	var left= (screen.width - 800)/2;
	var isTeste = (document.getElementById("isTeste").checked)? "s" : "f";
	$("#itemSelValues > *").each(function(index, domEle) {
		if (index == 0) {
			refPessoa += $(domEle).val();	 						
		} else {
			refPessoa += "," + $(domEle).val();
		}
	});
	//alert($('#tipoImpressao:checked').val());
	window.open("../Carteirinha?unidadeId=" +  $("#CarteiraUnd").val() + "&from=1&isTeste=" + isTeste +
		"&parametros=" + refPessoa + "&tipoRel=" + $('#tipoImpressao:checked').val(), 
		'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
	
	//window.open("../GeradorRelatorio?rel=11&parametros=7@" +  $("#CarteiraUnd").val() +
	//	"|8@" + refPessoa, 'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
	
	//$(elemento).dialog('close');
}

$(document).ready(function() {
	$('#isTeste').button();
	
	carteirinhaWindow = new MsfItemsSelectorAdm({
		id:"selectorNames", 
		leftId: "sortableLeft", 
		rightId: "sortableRight", 
		valueId:"valorUsuario",
		conteinerValues: 'itemSelValues',
		height: 270
	});
});