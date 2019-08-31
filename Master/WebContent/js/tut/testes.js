var janela;
var text;
var admIteSel;
$(document).ready(function() {
	admIteSel = new  MsfItemsSelectorAdm({
		id:'testeIt', 
		leftId: 'sortable1', 
		rightId: 'sortable2', 
		valueId:'valorConteiner'
	});
	
	
	
	
	selectItenListPP = function(obj) {
		/*var elemento = "";
		$("#sortable1 > *").each(function (index, domEle) {
        	elemento += "| " + index + " - " + domEle.textContent + "@" + domEle.title ; 
      	});*/
		//alert(elemento);
      	if ($(obj).hasClass("selectedItem")) {
	      	$(obj).removeClass("selectedItem");      		
      	} else {
      		$(obj).addClass("selectedItem");
      	}
      	//alert(obj.textContent);
		//alert(obj.title);
	}
	
	showAssistente = function(param) {
		alert(navigator.appVersion);
		alert(getIeVersion());
		
	 	/*$('#meleca').removeClass('cpEscondeWithHeight');
	 	$('#meleca').dialog({
	 		modal: true,
	 		close: function() {
	 			$(this).dialog('destroy');
	 			$(this).addClass('cpEscondeWithHeight');
	 		}	 		
	 	});*/
	}	
});


	/*showOption({
 		isModal : true,
 		titulo: 'Teste de Opção',
 		mensagem: 'Tem certesa que deseja efetuar este teste maluco cara! Vc é doido!',
 		id: 'meleca',
 		icone: 'e',
 		botoes: {'Sim': function() {
 				alert("Sim swou doido de pedra!");
 				$(this).dialog('close');
 			},
 			'Não': function() {
 				alert("Nunca estive no hospício!");
 				$(this).dialog('close');
 			}
 		}
 	});
 	
 	exemple de janela
 	
 	text = new MsfPrompt({
		id: "melecaPrt",
		label: 'campo de texto comum'	
	});
	
	janela = new MsfWindow({
		id: 'meleca',
		title: "janela de teste",
		message: 'teste de janela de formulario.',
		icon: 'w',
		isModal: false,
		idMessage: 'msgMeleca',		
		buttons: {'pega valor do campo': function() {
				alert(text.getValue());
			},
			'escreve alerta': function() {
				alert("este é o outro botão!");
			},
			'fechar': function() {
				janela.close();
			}			
		}
	});	
	janela.addComponente("melecaPrt", text.getHtm());
	janela.init();
 	* */