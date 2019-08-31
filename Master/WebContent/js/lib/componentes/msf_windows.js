var idLoader = "msfLdLoaderModalWD";
/**
 * msfPrompt
 * @param {type} id, defaultValue 
 */
MsfPrompt = function(param) {
	var id = param.id;
	var value = (param.defaultValue == undefined)? "" : param.defaultValue;
	var visible = (param.visible == undefined)? true : false;
	var enable = (param.enable == undefined)? true : false;	
	
 	var htm = "<label id=\"msfLBPt" + id + "\" for=\"" + id + "\">" + param.label + "</label>" +
		" <input type=\"text\" name=\"" + id + "\" id=\"" + id + "\" " +
		" class=\"text textDialog ui-widget-content ui-corner-all ";
	htm += (visible)? "\"" : "cpEsconde";	
	htm += (enable)? "" : "readonly=\"readonly\"";	
	htm+= " value=\"" + value + "\" />";
	
	this.setValue = function(newValue) {
		value = newValue;
		$("#" + id).val(value);
	}
	
	this.getValue = function() {
		if ($('#' + id).val() == '') {
			return value;
		} else {
			value = $('#' + id).val();
			return value;
		}
	}
	
	this.setEnable = function(newValue) {
		enable = newValue;
		if (enable) {
			$("#" + id).removeAttr("readOnly", "readOnly");	
		} else {
			$("#" + id).attr("readonly","readonly");			
		}
	}
	
	this.setVisible = function(newValue) {
		visible = newValue;
		if (visible) {
			$("#msfLBPt" + id).removeClass("cpEsconde");
			$("#" + id).removeClass("cpEsconde");
		} else {
			$("#msfLBPt" + id).addClass("cpEsconde");
			$("#" + id).addClass("cpEsconde");
		}
	}
		
	this.getHtm = function() {
		return ($("#" + id).html() == null)? htm: $("#" + id).html();
	}
}

MsfItemsSelectorAdm = function(param) {
	var id = param.id;
	var leftId = param.leftId;
	var rightId = param.rightId;
	var valueId = param.valueId;
	var idConteinerHidden = (param.conteinerValues == undefined)? 'msfIteSelect' + id 
		: param.conteinerValues ;
	var height = param.height;
	var conteinerHiden = "<div id=\"" + idConteinerHidden + "\"></div>";
	var botaoCode = "<div class=\"buttonContentIte\" style=\"height: " + height + "px\">" +
				"<input type=\"button\" value=\">\" class=\"ui-state-default ui-corner-all\" " +
				"onclick=\"msfDireitaItenSelected('" + leftId + "' , '" + rightId + "', '" + 
				idConteinerHidden + "', '" + valueId + "')\"/>" +
				"<input type=\"button\" value=\">>\" class=\"ui-state-default ui-corner-all\" " +
				"onclick=\"msfDireitaAllItenSelected('" + leftId + "' , '" + rightId + "', '" + 
				idConteinerHidden + "', '" + valueId + "')\"/>" +
				"<input type=\"button\" value=\"<\" class=\"ui-state-default ui-corner-all\" " +
				"onclick=\"msfEsquerdaItenSelected('" + leftId + "' , '" + rightId + "', '" + 
				idConteinerHidden + "', '" + valueId + "')\"/>" +
				"<input type=\"button\" value=\"<<\" class=\"ui-state-default ui-corner-all\"" +
				"onclick=\"msfEsquerdaAllItenSelected('" + leftId + "' , '" + rightId + "', '" + 
				idConteinerHidden + "', '" + valueId + "')\"/></div>";
	$("#" + id).append(conteinerHiden);
	$("#" + id + " > *").each(function(index, domEle) {
		if ($(domEle).hasClass("btContent")) {
			$(domEle).append(botaoCode);
		}
	});	
	$("#" + rightId + " > *").each(function(index, domEle){		
		$("#" + idConteinerHidden).append("<input type=\"hidden\" id=\"" + valueId + index +
			"\" value=\"" + domEle.title + "\" />");
	});	
	
	$("#" + leftId + " > *").each(function (index, domEle) {
		var aux = "";
        if ($.browser.msie) {
        	aux = "<li style=\"height: 20px\" title=\"" + domEle.title + 
    			"\" onclick=\"msfEventClickItenOfItSelector(this)\">" + 
    			domEle.innerText + "</li>";
    		domEle.outerHTML = aux;
        } else {
	        $(domEle).attr("onclick", "msfEventClickItenOfItSelector(this)");
        }

     });
    
    $("#" + rightId + " > *").each(function (index, domEle) {
    	var aux = ""
    	if ($.browser.msie) {
    		aux = "<li style=\"height: 20px\" title=\"" + domEle.title + 
    			"\" onclick=\"msfEventClickItenOfItSelector(this)\">" + 
    			domEle.innerText + "</li>";
    		domEle.outerHTML = aux;
    	} else {
	        $(domEle).attr("onclick", "msfEventClickItenOfItSelector(this)");
    	}

    });
    
    this.addToLeftBox = function() {
    	$("#" + leftId + " > *").each(function (index, domEle) {
    		var aux = "";
    		if ($.browser.msie) {
    			aux = "<li style=\"height: 20px\" title=\"" + domEle.title + 
    			"\" onclick=\"msfEventClickItenOfItSelector(this)\">" + 
    			domEle.innerText + "</li>";
    			domEle.outerHTML = aux;
    		} else {
			     $(domEle).attr("onclick", "msfEventClickItenOfItSelector(this)");
    		}

		 });
    }
}

MsfItenSelector = function(appendTo) {
	
}

MsfWindow = function(param) {
	var id = param.id;
	var titulo = param.title;
	var height = param.height;
	var width = param.width;
	var isModal;
	if (param.isModal == undefined) {
		isModal = true;
	} else {
		 isModal = param.isModal;
	}
	var isStack;
	if (param.isStack == undefined) {
		isStack = false;
	} else {
		isStack = param.stack;		
	}
	var resizable;
	if (param.resizable) {
		resizable = true;
	} else {
		resizable = param.resizable;
	}
	var idMessage = param.idMessage;
	var message = param.message;
	var icon;
	switch (param.icon) {
		case 'w':
			icon = 'ui-icon-alert';
			break;

		case 'o':
			icon = 'ui-icon-check';
			break;
			
		case 'e':
			icon = 'ui-icon-notice';
			break;
		
		case 'i':
			icon = 'ui-icon-alert';
			break;
			
		case 'q':
			icon = 'ui-icon-help'
			break;
	}
	
	var botoes = param.buttons;
	var components = new Array();
	var htm = "<div class=\"removeBorda\" id=\"" + id + "\" title=\"" + titulo + "\">";
	if (icon == undefined) {
		htm+= "<p id=\"" + idMessage + "\" >" + message + "</p><form><fieldset>"; 
	} else {
		htm+= "<p id=\"" + idMessage + "\"><span class=\"ui-icon " + icon + 
			"\" style=\"float:left; margin:0 7px 20px 0;\"></span>" + 
			message + "</p><form><fieldset id=\"msfFds" + id + "\"" +
					"style=\"border: none !important\" >";
	}
	
	this.init = function() {
		for(var i = 0; i < components.length; i++) {
			htm+= components[i][1];
		}
		htm+= "</fieldset></form></div>";
	}
	
	this.addComponente = function(cpId, cp) {
		components.push([cpId, cp]);
	}
	
	this.removeComponente = function(cpId) {
		var inicio;
		var fim;
		for(var i = 0; i < components.length; i++) {
			if (components[i][0] == cpId) {
				if (i == 0) {
					components.shift();
				} else {
					inicio = components.slice(0, i -1);
					fim = components.slice(i + 1, components.length);
					components = inicio;
					for(var j = 0; j < fim.length; j++) {
						components.push(fim[j]);
					}
				}
				repaint();
				break;
			}
		}
	}
	
	var repaint = function() {
		$("#msfFds" + id).empty();
		for(var i = 0; i < components.length; i++) {
			$("#msfFds" + id).append(components[i][1]);
		}
	}
	
	this.close = function() {		
		$("#" + id).dialog("destroy");
		$("#" + id).remove();
	}
	
	this.show = function() {
		$('body').prepend(htm);		
		$("#" + id).dialog({
			buttons: botoes,
			width: width,
			height: height,
			resizable: resizable,
			modal: isModal,
			stack: isStack,
			closeOnEscape: true,
			close: function(event, ui) {
				handle.close();
			}
		});				
	}
	
	var handle = this;
}

showMessage = function(param, icone) {	
	var id = (param.id == undefined)? "msfWdShowMessage" : param.id;
	var titulo = (param.title == undefined)? "Mensagem": param.title;
	var mensagem = (param.mensagem == undefined)? "Erro, pop sem mensagem": param.mensagem;
	var isModal; 
	var width = (param.width == undefined)? 300 : param.width;
	if (param.isModal != undefined) {
		isModal = param.isModal;		
	} else {
		isModal = true;
	}
	
	var htm = "<div id=\"" + id + "\" title=\"" +  titulo + "\"> " + 
		"<p><span class=\"ui-icon " + icone + "\" style=\"float:left; margin:0 7px 20px 0;\">" +
		"</span>" + mensagem + "</p></div>";
	$('body').prepend(htm);
	
	$('#' + id).dialog({
		modal: isModal,
		closeOnEscape: true,
		resizable: false,
		width: width,
		show: 'fade',
		hide: 'clip',
		buttons: { "Ok": function() { 
			$(this).dialog("close"); 
		}},
		close: function(event, ui) { 
			$(this).dialog('destroy');
			$(this).remove();
		}
	});	
}

showLoader = function() {
	var htm = "<div id=\"" + idLoader + "\" class=\"removeBorda\" title=\"Carregando...\"> " +			
		"<form id=\"formStage2\" onsubmit=\"return false;\"><fieldset><div style=\"margin-top: 20px\">" +
		"<img src=\"../image/loader.gif\ /></div></fieldset></form></div>";	
	
	$('body').prepend(htm);
	
	$('#' + idLoader).dialog({
		modal: true,
		closeOnEscape: false,
		resizable: false,
		stack: true,
		height: 120,
		width: 189,
		close: function(event, ui) { 
			$(this).dialog('destroy');
			$(this).remove();
		}
	});
}

hideLoader = function () {
	$("#" + idLoader).dialog('close');
}

/**
 * showMessage
 * @param {type}  
 */
showWarning = function(param) {
	showMessage(param, "ui-icon-alert");
}

showErrorMessage = function(param) {
	showMessage(param, "ui-icon-notice");
}

showOkMessage = function(param) {
	showMessage(param, "ui-icon-check");
}

showInfo = function(param) {
	showMessage(param, "ui-icon-info");
}

showOption = function(param) {
	var id = (param.id == undefined)? "msfWdShowMessage" : param.id;
	var titulo = (param.titulo == undefined)? "Mensagem": param.title;
	var mensagem = (param.mensagem == undefined)? "Erro, pop sem mensagem": param.mensagem;
	var isModal;
	var width = (param.width == undefined)? 300 : param.width;
	if (param.isModal != undefined) {
		isModal = param.isModal;		
	} else {
		isModal = true;
	}
	var botoes = param.buttons;
	var icone = "";
	if (param.icone != undefined) {
		switch (param.icone) {
			case 'w':
				icone = 'ui-icon-alert';
				break;

			case 'o':
				icone = 'ui-icon-check';
				break;
				
			case 'e':
				icone = 'ui-icon-notice';
				break;
			
			case 'i':
				icone = 'ui-icon-alert';
				break;
				
			case 'q':
				icone = 'ui-icon-help'
				break;
		}
	}
	
	var htm = "<div id=\"" + id + "\" title=\"" + titulo + "\"><p>" + 
		"<span " + ((icone == "")? "" : "class=\"ui-icon " + icone) + "\" style=\"float:left; margin:0 7px 20px 0;\">" +
		"</span>" + mensagem + "</p></div>"
	$('body').prepend(htm);
	
	$('#' + id).dialog({
		modal: isModal,
		closeOnEscape: true,
		resizable: false,
		buttons: botoes,
		show: 'slide',
		hide: 'clip',
		width: width,
		close: function(event, ui) { 
			$(this).dialog('destroy');
			$(this).remove();
		}
	});
	
}

// Eventos de componente

msfEventClickItenOfItSelector = function(obj) {
	if ($(obj).hasClass("selectedItem")) {
	   	$(obj).removeClass("selectedItem");      		
      } else {
      	$(obj).addClass("selectedItem");
      }
}

msfDireitaItenSelected = function(idLeft, idRight, idHiden, valueId) {
	$("#" + idLeft + " > *").each(function(index, domEle) {
		if ($(domEle).hasClass("selectedItem")) {
			$(domEle).removeClass("selectedItem");
			$("#" + idRight).append($(domEle).clone());
			$(domEle).remove();
		}
	});
	adjusteSelectorValues(idRight, valueId, idHiden);
}

msfDireitaAllItenSelected = function(idLeft, idRight, idHiden, valueId) {
	$("#" + idLeft + " > *").each(function(index, domEle) {
		if (!$(domEle).hasClass("titleBar")) {
			$(domEle).removeClass("selectedItem");
			$("#" + idRight).append($(domEle).clone());
			$(domEle).remove();
		}
	});
	adjusteSelectorValues(idRight, valueId, idHiden);
}

msfEsquerdaItenSelected = function(idLeft, idRight, idHiden, valueId) {
	$("#" + idRight + " > *").each(function(index, domEle) {
		if ($(domEle).hasClass("selectedItem")) {
			$(domEle).removeClass("selectedItem");
			$("#" + idLeft).append($(domEle).clone());
			$(domEle).remove();
		}
	});	
	adjusteSelectorValues(idRight, valueId, idHiden);
}

msfEsquerdaAllItenSelected = function(idLeft, idRight, idHiden, valueId) {
	$("#" + idRight + " > *").each(function(index, domEle) {
		if (!$(domEle).hasClass("titleBar")) {
			$(domEle).removeClass("selectedItem");
			$("#" + idLeft).append($(domEle).clone());
			$(domEle).remove();
		}
	});	
	adjusteSelectorValues(idRight, valueId, idHiden);
}

adjusteSelectorValues = function(idRight, valueId, idHiden) {
	$("#" + idHiden).empty();
	$("#" + idRight + " > *").each(function(index, domEle) {
		$("#" + idHiden).append("<input type=\"hidden\" id=\"" + valueId + index +
			"\" value=\"" + domEle.title + "\" />");
	});	
}

