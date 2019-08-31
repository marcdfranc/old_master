var msfWarningWdm;
var msfAdminCalbackWdm = new Array();
var msfPromptCallbackWdm;
var SIM_NAO = ['s', 'n'];
var SIM_NAO_CANCEL = ['s', 'n', 'c'];
var OK_CANCEL = ['o', 'c'];
var OK = ['o'];
var CANCEL = ['c'];
var SIM = ['s'];

var MsfCallBackAdminWdm = function (functionCall) {
	this.functionCall = functionCall;
	this.parametro = "";
	this.secondParametro;
	
	this.setParametro = function(parametro) {
		this.parametro = parametro;
	}
	
	this.setSecondParametro = function(parametro) {
		this.secondParametro = parametro;
	}
	
	this.execOneFunction = function() {
		this.functionCall();
	}
	
	this.execFunction = function() {
		this.functionCall(this.parametro);
	}	
	
	this.execFunctioParametro = function() {
		this.functionCall(this.parametro, this.secondParametro);
	}
}

MsfWindow = function(id, titulo, local, height, width, varName, isModal, isLong) {
	/**
	 * requerido
	 */	
	this.local = local;
	/**
	 * requerido
	 */
	this.height= height;
	/**
	 * requerido
	 */
	this.width = width;
	this.headerWidth = this.width - 19;
	this.id = id;	
	this.modal = "<div id=\"" + this.id + "Modal" + "\" class=\"cpModal\" " +
		"style=\"background-color: #DBEFFA;\"></div>";
	this.titulo= titulo;
	this.htm = "";
	this.visible = true;
	this.isModal = isModal;
	this.isAppendedModal = false;
	this.isAppended = false;
	this.haveCloser= true;
	this.isLong = isLong;
	this.color= "";
	this.y = (this.isLong)? parseInt((screen.height - this.height)/2) - 40 : (this.height/2) * -1;
	this.x = parseInt(this.width/2) * -1;	
	this.varName = varName;
	this.component= "";
	this.icon = "cpDefaultWindow";
	this.headerColor = "cpDefaulWindowHeader";
	
	this.init = function() {
		this.htm = "<div id=\"" + this.id + "Pai\" class=\"" + this.icon + " cpEsconde\" " +
			"style=\"margin-top: " +  this.y + "px; margin-left: " + this.x +
			"px; height: " + this.height + "; width: " + this.width + ";\">" +
			"<div class=\"" + this.headerColor + "\"><div class=\"cpWindowLabelHeader\" " +
			"id=\"" + this.id + "Label\"><label id=\"" + this.id + "Hd\"></label></div>";
			
		if (this.haveCloser) {
			this.htm+= "<input id=\"" + this.varName+ "\" class=\"cpWindowButtonClose\" \"type=\"button\" value=\"X\" onclick=\"cpXClose(this)\" ></div>";			
		} else {
			this.htm = "</div>"
		}			
		this.htm+= "<div id=\"" + this.id + "\" class=\"cpWindowContent\">" + 
			this.component + "</div></div>";			
		
		
		$((this.local == 'body')? document.body : 
				'#' + this.local).prepend(this.htm);		
		
		$('#' + this.id + "Pai").removeClass("cpEsconde");
		$('#' + this.id + "Pai").hide();
		
		if (this.visible) {
			this.repaint();			
		}		
	}
	
	this.repaint = function() {
		var isShow = false;
		var valX =  this.x + "px";
		var valY = (this.isLong)? (this.y - 40) + "px": this.y; 
		var valHeight = this.height;
		var valWidth = this.width;
		var valHeader = this.headerWidth;
		var id = '#' + this.id;
		var titulo = this.titulo;
		if (this.visible) {
			if (this.isAppended) {
				$('#' + this.id + "Pai").show("slow", function() {
					$(this).css({
						"margin-top": valY,
						"margin-left": valX,
						"height": valHeight,
						"width": valWidth
					});
					
					$(id + "Hd").text(titulo);
					
					$(id + "Label").css({
						"width": valHeader
					}); 
				});
				isShow = true;				
			} else {
				$('#' + this.id + "Pai").hide("fast");				
				$('#' + this.id + "Pai").show("slow", function() {
					$(this).css({
						"margin-top": valY,
						"margin-left": valX,
						"height": valHeight,
						"width": valWidth
					});
					
					$(id + "Hd").text(titulo);
					
					$(id + "Label").css({
						"width": valHeader
					});
				});
				this.isAppended = true;
			}
			if (this.isModal) {
				if (this.isAppendedModal) {
					$('#' + this.id + "Modal").show("slow");
				} else {
					this.isAppendedModal = true;
					$('#' + this.id + "Pai").after(this.modal);
				}
			} else {
				if (this.isAppendedModal) {
					$('#' + this.id + "Modal").hide("slow");
				}
			}
		} else {
			if (this.isAppended) {
				$('#' + this.id + "Pai").hide("slow");
			}
			if (this.isAppendedModal) {
				$('#' + this.id + "Modal").hide("slow");
			}
		}
		
	}	
	
	this.setVisible = function(visibilidade) {
		this.visible = visibilidade;
	}
	
	this.setCloser = function(value) {
		this.haveCloser= value; 
	}
	
	this.show = function() {
		this.visible= true;
		this.repaint();
	}
	
	this.hide = function() {
		this.visible = false;
		this.repaint();
	}
	
	this.setHeight = function(height) {
		this.height = height;
		this.y = (this.isLong)? parseInt((screen.height - this.height)/2) - 40 : (this.height/2) * -1;
	}
	
	this.setWidth = function(width) {
		this.width = width;
		this.headerWidth = this.width - 19;
		this.x = parseInt(this.width/2) * -1;
	}
	
	this.setTitle = function(title) {
		this.titulo = title;
	}
	
	this.setModal = function(modal) {
		this.isModal = modal;
	}
	
	this.setModalColor = function(color) {
		this.modal = "<div id=\"" + this.id + "Modal" + "\" class=\"cpModal\" " +
		"style=\"background-color: #" + color + ";\"></div>";
	}
	
	this.setIcon = function(value) {
		switch (value) {
			case 'd':
				this.icon = "cpDefaultWindow";
				this.headerColor = "cpDefaulWindowHeader";
				break;
			
			case 'w':
				this.icon = "cpWarning";
				this.headerColor = "cpWarningHeader";
				break;
				
			case 'o':
				this.icon = "cpOkWindow";
				this.headerColor = "cpOkWindowHeader";
				break;
				
			case 'e':
				this.icon = "cpErroWindow";
				this.headerColor = "cpErroWindowHeader";
				break;
		}
	}
	
	this.addConponent = function(htm) {
		this.component += htm
		if (!$.browser.msie) {
			$("[id= " + this.id + "]").append(htm);
		} 
	}
	
	this.clearContent = function() {
		this.component = "";
		if (!$.browser.msie) {
			$("[id= " + this.id + "]").empty();
		}
	}
	
	this.getInnerlId = function() {		
		return this.id + "Pai";
	}
	
	this.getId = function() {
		return this.id;
	}
}

cpXClose = function(value) {	
	this[value.id].hide();
}

MsfPrompt = function(id, defaultValue, x, y, width) {
	this.x = x;
	this.y = y;
	this.width = width;
	this.value = defaultValue;
	this.id = id;	
	this.visible = true;
	this.enable = true;
	this.handler = new Array();
	
	this.htm = "<div id=\"" + this.id + "Prompt\" class=\"cpPrompt\" style=\"top: " + 
		this.y + "px; left: " + this.x + "px; width: " + this.width +
		"px;\"><input id=\"" + this.id + "promptValue\" name=\"" + this.id +
		"promptValue\" type=\"text\" value=\"" + this.value + "\" style=\"width: " + 
		this.width + "px;\" ";
		
	this.repaint = function() {
		$("[id= " + this.id + "Prompt]").css({
			"top": this.y,
			"left": this.x,
			"width": this.width			
		});
		
		$("[id= " + this.id + "promptValue]").css({
			"width": this.width
		});
		
		$("[id= " + this.id + "promptValue]").val(this.value);		
		
		if (!this.visible) {
			$("[id= " + this.id + "Prompt]").addClass("cpEsconde");
		} else {
			$("[id= " + this.id + "Prompt]").removeClass("cpEsconde");
		}
	}
	
	this.show = function() {
		this.visible = true;
		this.repaint();
	}	
	
	this.hide = function() {
		this.visible = false;
		this.repaint();
	}
	
	this.setValue = function(value) {
		this.value = value;
		this.repaint();
	}
	
	this.setPosition = function(x, y) {
		this.x = x;
		this.y = y;
		this.repaint();		
	}	
	
	this.setWidth = function(width) {
		this.width = width;
		this.repaint();
	}
	
	this.setEnable = function(isEnable) {
		this.enable = isEnable;
		if (this.enable) {
			$("[id= " + this.id + "promptValue]").removeAttr("readonly");
		} else {
			$("[id= " + this.id + "promptValue]").attr("readonly", "readonly");
		}
	}
	
	this.addListener = function(evento, acao) {
		var haveEvent = false;
		for(var i = 0; i < this.listenerColecction.length; i++) {
			if (this.handhandler[i] == evento) {
				haveEvent = true;
			}
		}
		if (!haveEvent) {
			this.listenerColecction.push([evento, acao]);			
			this.repaint();
		}
	}
	
	this.getSpecialValue = function() {
		var value = "";
		$("input[id= " + this.id + "promptValue]").each(function (i) {
        	value += this.value;
      	});		
		this.value = value;		
		return this.value;
	}
	
	this.getValue = function() {
		this.value = $("#" + this.id + "promptValue").val();
		return this.value;
	}
	
	this.getXPosition = function() {
		return this.x;
	}
	
	this.getYPosition = function() {
		return this.y;
	}
		
	this.getHtm = function() {
		for(var i = 0; i < this.handler .length; i++) {
			this.htm += " " + this.handler[i][0] + "=\"" + 
				this.handler[i][1] + "\" "; 
		}			
		this.htm += "/></div>"
		return this.htm;		
	}
}

MsfPromptMask = function(id, defaultValue, x, y, width, mascara) {
	this.x = x;	
	this.y = y;
	this.width = width;
	this.value = defaultValue;
	this.id = id;	
	this.visible = true;
	this.enable = true;
	this.handler = new Array();
	
	this.htm = "<div id=\"" + this.id + "Prompt\" style=\"top: " + this.y +
		"px; left: " + this.x + "px; width: " + this.width + "px;\"><input id=\"" + 
		this.id + "vlPrompt\" name=\"" + this.id + "vl\" type=\"text\" " +
		"value=\"" + this.value + "\" style=\"width: " + this.width + "px;\" " +
		"onKeyDown=\"mask(this, " + mascara + ")\" ";
		
	this.repaint = function() {
		$("[id= " + this.id + "Prompt]").css({
			"top": this.y,
			"left": this.x,
			"width": this.width			
		});
		
		$("[id= " + this.id + "vlPrompt]").css({
			"width": this.width
		});
		
		$("[id= " + this.id + "vlPrompt]").val(this.value);		
		
		if (!this.visible) {
			$("[id= " + this.id + "Prompt]").addClass("cpEsconde");
		} else {
			$("[id= " + this.id + "Prompt]").removeClass("cpEsconde");
		}
	}
	
	this.show = function() {
		this.visible = true;
		this.repaint();
	}	
	
	this.hide = function() {
		this.visible = false;
		this.repaint();
	}
	
	this.setValue = function(value) {
		this.value = value;
		this.repaint();
	}
	
	this.setPosition = function(x, y) {
		this.x = x;
		this.y = y;
		this.repaint();		
	}	
	
	this.setWidth = function(width) {
		this.width = width;
		this.repaint();
	}
	
	this.setEnable = function(isEnable) {
		this.enable = isEnable;
		if (this.enable) {
			$("[id= " + this.id + "vlPrompt]").removeAttr("readonly");
		} else {
			$("[id= " + this.id + "vlPrompt]").attr("readonly", "readonly");
		}
	}
	
	this.addListener = function(evento, acao) {
		var haveEvent = false;
		for(var i = 0; i < this.handler.length; i++) {
			if (this.handhandler[i] == evento) {
				haveEvent = true;
			}
		}
		if (!haveEvent) {
			this.handler.push([evento, acao]);			
			this.repaint();
		}
	}
	
	this.getSpecialValue = function() {
		var value = "";
		$("input[id= " + this.id + "vlPrompt]").each(function (i) {
        	value += this.value;
      	});		
		this.value = value;		
		return this.value;
	}
	
	this.getValue = function() {
		this.value = $("#" + this.id + "vlPrompt").val();
		return this.value;
	}
	
	this.getXPosition = function() {
		return this.x;
	}
	
	this.getYPosition = function() {
		return this.y;
	}
	
	this.getHtm = function() {
		for(var i = 0; i < this.handler .length; i++) {
			this.htm += " " + this.handler[i][0] + "=\"" + 
				this.handler[i][1] + "\" "; 
		}			
		this.htm += "/></div>";
		return this.htm;
	}
	
	if (mascara = 'dateType') {
		$("[id= " + this.id + "]").datepicker({
			dayNamesMin: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'],
			monthNames: ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 
				'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'],
			dateFormat: 'dd/mm/yy',		
			yearRange: '1935:2050'		 
		});
	} else if (mascara == 'typeDate') {
		$("[id= " + this.id + "]").datepicker({
			dayNamesMin: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'],
			monthNames: ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 
				'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'],
			dateFormat: 'dd/mm/yy',
			changeYear: true,
			yearRange: '1935:2050'		 
		});	
	} else if (mascara == 'decimalNumber') {
		$("[id= " + this.id + "vl]").blur(function() {
			if (this.value != "") {			
				this.value = formatDecimal(this.value);			
			} else {
				this.value+= "0.00";	
			} 						
		});
	}
}


MsfLabel = function(id, text, x, y, isMessage) {	
	this.x = x;	
	this.y = y;
	this.text = text;
	this.id = id;
	this.value= text;
	this.visible = true;
	this.limitMessage = (isMessage)? 148 : 0;
		
	this.htm = "<div id=\"" + this.id + "Label\" style=\"top: " + this.y +
		"px; left: " + this.x + "px;\" ";
		
	this.htm+= (isMessage)? "class=\"cpLabelWindow\"" : "";
	
	this.htm+= "><label id=\"" + this.id + "\" name=\"" + this.id +
		"\" >" + this.text + "</label></div>";
	
	this.repaint = function() {
		if (this.limitMessage > 0) {
			$("[id= " + this.id + "Label]").css({
				"top": this.y,
				"left": this.x,
				"margin-right": this.limitMessage
			});
		} else {
			$("[id= " + this.id + "Label]").css({
				"top": this.y,
				"left": this.x
			});
		}
		
		$("[id= " + this.id + "]").val(this.value);
		$("[id= " + this.id + "]").text(this.text);
		
		if (!this.visible) {
			$("[id= " + this.id + "Label]").addClass("cpEsconde");
		} else {
			$("[id= " + this.id + "Label]").removeClass("cpEsconde");
		}		
	}	
	
	this.setPosition = function(x, y) {
		this.x = x;
		this.y = y;
		this.repaint();
	}
	
	this.setText = function(text) {
		this.text = text;
		this.value = text;
		this.repaint();
	}
	
	this.show = function() {
		this.visible = true;
		this.repaint();
	}
	
	this.hide = function() {
		this.visible = false;
		this.repaint();	
	}
	
	this.getHtm = function() {
		return this.htm;
	}
	
	this.getText = function() {
		return this.text;
	}
	
	this.setLimitMessage = function() {
		
	}
	
	this.setIsMessage = function(isMessage) {
		this.ismessage = isMessage;
	}
}

MsfCheck = function(id, text, x, y, trueValue, falseValue, defaultValue, changer) {
	this.x = parseInt(x);
	this.y = parseInt(y);
	this.val = defaultValue;
	this.trueValue = trueValue;
	this.falseValue = falseValue;
	this.text = text;
	this.visible = true;
	this.label = new MsfLabel(id + "label", text, this.x + 25, this.y , true);
	this.idxCalback = msfAdminCalbackWdm.push(new MsfCallBackAdminWdm(changer)) - 1;
	
	this.htm =  "<div id=\"" + id + "Pai\" name = \"" + id + "Pai\" " +
		"style=\"top: " + this.y + "px; left:" + this.x + "px\">" +
		"<img id=\"" + this.id + "ck\" name=\"" + this.id + "ck\" " + 
		"onClick=\"msfCkChange(" + this.idxCalback + ")\" ";		
	 
	if (this.val == 't') {
		this.htm+= "src=\"../image/checked_img.gif\" />"
	} else {
		this.htm+= "src=\"../image/unchecked_img.gif\" />"
	}
	this.htm += "</div>"
	
	
	this.repaint = function() {
		$("[id= " + this.id + "Pai]").css({
			"top": this.y,
			"left": this.x
		});
		
		if (this.val == 't') {
			$("[id= " + this.id + "ck]").attr({			
				src: "../image/checked_img.gif"
			});
		} else {
			$("[id= " + this.id + "ck]").attr({
				src: "../image/unchecked_img.gif"
			});			
		}
				
		if (!this.visible) {
			$("[id= " + this.id + "Pai]").addClass("cpEsconde");
			this.label.hide();
		} else {
			$("[id= " + this.id + "Pai]").removeClass("cpEsconde");
			this.label.show();
		}		
		this.label.repaint();
	}
	
	this.setText = function(text) {
		this.label.setText(text);
		this.repaint();
	}
	
	this.setTrueValue = function(value) {
		this.trueValue = value;		
	}
	
	this.setFalseValue = function(value) {
		this.falseValue = value;
	}
	
	this.changeValue = function() {
		if (this.val == 't') {
			$("#" + this.id + "ck").attr({
				src: "../image/unchecked_img.gif"
			});
			this.val = 'f'
		} else {
			$("#" + this.id + "ck").attr({
				src: "../image/checked_img.gif"
			});
			this.val = 't'
		}
		this.repaint();
	}
	
	this.setPosition = function(x, y) {
		this.x = x;
		this.y = y;
		this.repaint();
	}
	
	this.show = function() {
		this.visible = true;
		this.repaint();		
	}
	
	this.hide = function() {
		this.visible = false;
		this.repaint();
	}
	
	this.getHtm = function() {
		return this.htm + this.label.getHtm();
	}
	
	this.getText = function() {
		return this.label.getText();		
	}
	
	this.getValue = function() {		
		return (this.val == 't')? trueValue : falseValue;		
	}
	
	this.getXPosition = function() {
		return this.x;
	}
	
	this.getYPosition = function() {
		return this.y;
	}
	
	this.getConteinerId = function() {
		return this.id + "Pai";
	}
}

MsfRadio = function(id, text, pai, x, y, value) {
	this.x = x;	
	this.y = y;	
	this.id = id;
	this.value= value;
	this.text = text;	
	this.visible = true;
	this.conteinerId = pai;
	
	this.htm = "<div class=\"cpRadio\" id=\"" + this.conteinerId +
		"\" style=\"top: " + this.y + "px; left: " + this.x + "px;\"><input id=\"" + 
		this.id + "\" name=\"" + this.id + "\" " + "type=\"radio\" ";
		
	this.htm+= (this.value)? "checked=\"checked\" " : ""; 
		
	this.htm+= "value=\"" + this.text + "\" /></div>";
		
	this.repaint = function() {
		$("[id= " + this.conteinerId + "]").css({
			"top": this.y,
			"left": this.x						
		});		
		
		document.getElementById(this.id).checked = this.value;
		
		if (!this.visible) {
			$("[id= " + this.conteinerId + "]").addClass("cpEsconde");
		} else {
			$("[id= " + this.conteinerId + "]").removeClass("cpEsconde");
		}
	}
	
	this.setText = function(text) {
		this.text = text;
		this.repaint();
	}
	
	this.setValue = function(value) {
		this.value = value;
		this.repaint();
	}
	
	this.setPosition = function(x, y) {
		this.x = x;
		this.y = y;
		this.repaint();
	}
	
	this.show = function() {
		this.visible = true;
		this.repaint();		
	}
	
	this.hide = function() {
		this.visible = false;
		this.repaint();
	}
	
	this.getHtm = function() {
		return this.htm;
	}
	
	this.getText = function() {
		return this.getText();		
	}
	
	this.getValue = function() {
		//this.value = document.getElementById(this.id).checked;
		//return this.value;
		return document.getElementsByName(this.id).itens[2].value;		
	}
	
	this.getXPosition = function() {
		return this.x;
	}
	
	this.getYPosition = function() {
		return this.y;
	}
	
	this.getConteinerId = function() {
		return this.conteinerId;
	}
}

MsfRadioGroup = function(id, data, changer) {
	this.data = data;
	this.id = id;
	this.value;		
	this.visible = true;		
	this.htm = "";
	this.idxCalback = msfAdminCalbackWdm.push(new MsfCallBackAdminWdm(changer)) - 1;	
		
	for (var i = 0; i < this.data.length; i++) {
		this.htm += "<div id=\"" + this.id + "Pai" + i + "\" class=\"cpRadio\" style=\"top: " +
		this.data[i][2] + "px; left: " + this.data[i][1] + "px;\">";
		this.htm += "<img id=\"" + this.id + "MsfRd" + i + "\" class=\"cpRadioImg\" ";
		if (this.data[i][0]) {
			this.htm+= "src=\"../image/radio_color.gif\" ";
			this.value = this.data[i][3];
		} else {
			this.htm+= "src=\"../image/radio_clear.gif\" ";
		}		
		this.htm+= "onclick=\"masfRdChangeRadio('" + this.data[i][3] + "', " + 
			this.idxCalback + ")\"/></div>";		
	}
	
	
	this.repaint = function() {
		var aux = "";
		for (var i = 0; i < this.data.length; i++) {
			if (this.data[i][3]== this.value) {
				aux = this.id + "MsfRd" + i;
				$("[id= " + aux + "]").attr({
					src: "../image/radio_color.gif"
				});
				this.data[i][0] = true;
			}
			
			$("[id= " + this.id + "Pai" + i + "]").css({
				"top": this.data[i][2],
				"left": this.data[i][1]
			});
			
			if (!this.visible) {
				$("[id= " + this.id + "Pai" + i + "]").addClass("cpEsconde");
			} else {
				$("[id= " + this.id + "Pai" + i + "]").removeClass("cpEsconde");
			}			
		}
	}
	
	this.setValue = function(value) {
		var aux= ""
		for (var i = 0; i < this.data.length; i++) {			
			if (this.data[i][0]) {
				aux = this.id + "MsfRd" + i
				$("[id = " + aux + "]").attr({
					src: "../image/radio_clear.gif"
				});
				this.data[i][0] = false;
			}
		}
		this.value = value;
		this.repaint();
	}
	
	this.setPosition = function(index, x, y) {
		this.data[index][1] = x;
		this.data[index][2] = y;
		this.repaint();
	}
	
	this.show = function() {
		this.visible = true;
		this.repaint();		
	}
	
	this.hide = function() {
		this.visible = false;
		this.repaint();
	}
	
	this.getHtm = function() {
		return this.htm;
	}
	
	this.getValue = function() {		
		return this.value;	
	}
	
	this.getXPosition = function(index) {
		return this.data[index][1];
	}
	
	this.getYPosition = function(index) {
		return this.data[index][2];
	}
	
	this.repaint();
}

/**
 * 
 * @param {String} id
 * @param {Array} data
 * @param {int} x
 * @param {int} y
 * @param {String} defaultValue
 */

MsfComboBox = function(id, data, x, y, defaultValue, changer) {
	this.x = x;	
	this.y = y;	
	this.value;
	this.id = id;
	this.visible = true;
	this.data = data;
	var selected= "";	
	this.listenerColecction = new Array();
	this.idxCalback = msfAdminCalbackWdm.push(new MsfCallBackAdminWdm(changer)) - 1;
	
	this.htm = "<div id=\"" + this.id + "Combo\" class=\"cpCombo\" style=\"top: " + 
		this.y + "px; left: " + this.x + "px; width: " + this.width +
		"px;\"><select id=\"" +	this.id + "\" name=\"" + this.id + "\" ";
		
	this.repaint = function() {
		$("[id= " + this.id + "Combo]").css({
			"top": this.y,
			"left": this.x						
		});
		
		for (var i = 0; i < this.data.length; i++) {
			if (this.data[i][0] == this.value) {
				$("[id= " + this.id + "]").val(this.value);
				//document.getElementById(this.id).selected = true;
				break;
			}
		}
		
		if (!this.visible) {
			$("[id= " + this.id + "Combo]").addClass("cpEsconde");
		} else {
			$("[id= " + this.id + "Combo]").removeClass("cpEsconde");
		}
	}
	
	this.show = function() {
		this.visible = true;
		this.repaint();
	}	
	
	this.hide = function() {
		this.visible = false;
		this.repaint();
	}
	
	this.setValue = function(value) {
		this.value = value;
		this.repaint();
	}
	
	this.setPosition = function(x, y) {
		this.x = x;
		this.y = y;		
		this.repaint();		
	}
	
	this.addListener = function(evento, acao) {
		var haveEvent = false;
		for(var i = 0; i < this.listenerColecction.length; i++) {
			if (this.listenerColecction[i] == evento) {
				haveEvent = true;
			}
		}
		if (!haveEvent) {
			this.listenerColecction.push([evento, acao]);
		}
	}
	
	this.getSpecialValue = function() {
		var value = "";
		$("select[id= " + this.id + "]").each(function (i) {
        	value = this.value;
      	});		
		this.value = value;
		return this.value;
	}
	
	this.getValue = function() {
		//this.value = $("[id= " + this.id + "]").val();
		return this.value;
	}
	
	this.getText = function() {		
		this.value = $("[id= " + this.id + "]").val();
		return $("#" + this.id + ":selected").text();
	}
	
	this.getXPosition = function() {
		return this.x;
	}
	
	this.getYPosition = function() {
		return this.y;
	}
	
	this.getHtm = function() {
		var haveChange = false;
		for(var i = 0; i < this.listenerColecction.length; i++) {
			if (trim(this.listenerColecction[i][0].toLowerCase()) == "onchange") {
				haveChange = true;
				this.htm +=  " " + this.listenerColecction[i][0] + "=\"" +
					"msfCbChangeComboBox(this.value, " + this.idxCalback +  "); " +
					this.listenerColecction[i][1] + "; \" ";
			} else {
				this.htm+= " " + this.listenerColecction[i][0] + "=\"" + 
					this.listenerColecction[i][1] + "\" ";
			}
			//this.htm+= " " + this.listenerColecction[i][0] + "=\"" + 
				//this.listenerColecction[i][1] + "\" ";
		}
		
		
		if (!haveChange) {
			this.htm += " onchange=\"msfCbChangeComboBox(this.value, " + this.idxCalback + ")\" ";
		}
		this.htm +=  ">"; 
		for (var i = 0; i < this.data.length; i++) {
			if (this.data[i][0] == defaultValue) {
				selected = "selected=\"selected\"";
				this.value = this.data[i][0];
			} else {
				selected = "";
			}		
			this.htm += "<option value=\"" + this.data[i][0] + "\" " +
				selected + ">" + this.data[i][1] + "</option>";		
		}
		this.htm += "</select></div>";
		return this.htm;
	}
	
	
}

MsfButton = function(id, text, tipo, x, y, callback) {
	this.id = id;
	this.x = x;
	this.y = y;
	this.text = text;
	this.tipo = tipo;
	this.callback = callback;
	this.visible = true;
	
	switch (tipo) {
		case 'd':						
			this.htm = "<div id=\"" + this.id + "Btn\" class=\"cpBlueButtonContent\" style=\"left: " +
				this.x + "px; " +	"top: " + this.y + "px\"><input id=\"" + this.id +
				"\" class=\"cpBlueButton\" type=\"button\" " + 
				"onclick=\"" + this.callback + "()\" value=\"" + this.text + "\" ></div>";
			break;
		
		case 'w':
			this.htm = "<div id=\"" + this.id + "Btn\" class=\"cpOrangeButtonContent\" style=\"left: " +
				this.x + "px; " +	"top: " + this.y + "px\"><input id=\"" + this.id +
				"\" class=\"cpOrangeButon\" type=\"button\" " + 
				"onclick=\"" + this.callback + "()\" value=\"" + this.text + "\" ></div>";
			break;
			
		case 'o':
			this.htm = "<div id=\"" + this.id + "Btn\" class=\"cpGreenButtonContent\" style=\"left: " +
				this.x + "px; " +	"top: " + this.y + "px\"><input id=\"" + this.id +
				"\" class=\"cpGreenButton\" type=\"button\" " + 
				"onclick=\"" + this.callback + "()\" value=\"" + this.text + "\" ></div>";
			break;
			
		case 'e':			
			this.htm = "<div id=\"" + this.id + "Btn\" class=\"cpRedButtonContent\" stayle=\"left: " +
				this.x + "px; " +	"top: " + this.y + "px\"><input id=\"" + this.id +
				"\" class=\"cpRedButton\" type=\"button\" " + 
				"onclick=\"" + this.callback + "()\" value=\"" + this.text + "\" ></div>";
			break;
	}	
		
	this.repaint = function() {
		$("#" + this.id + "Btn").css({
			"top": this.y,
			"left": this.x
		});
		
		if (!this.visible) {
			$("#" + this.id + "Btn").addClass("cpEsconde");
		} else {
			$("#" + this.id + "Btn").removeClass("cpEsconde");
		}
	}
	
	this.setText = function(text) {
		this.text = text;
		this.repaint();
	}
	
	this.setCallback = function(callback) {
		this.callback = callback;
		this.repaint();
	}
	
	this.setPosition = function(x, y) {
		this.x = x;
		this.y = y;
		this.repaint();
	}
	
	this.show = function() {
		this.visible = true;
		this.repaint();
	}
	
	this.hide = function() {
		this.visible = false;
		this.repaint();
	}
	
	this.getText = function() {
		return this.text;		
	}
	
	this.getId = function() {
		return this.id;
	}
	
	this.getHtm = function() {
		return this.htm;
	}
}


/**
 * 
 * @param {String} text
 * @param {String} title
 * @param {int} height
 * @param {int} width
 */

showWarning = function (text, title, height, width, isLong) {
	var y = height - 80;
	var button = "<div class=\"cpOrangeButtonMsg\" style=\"margin-left: " + ((width/2) - 50) + "px; " +
		"margin-top: " + y + "px\">" +
		"<input id=\"msfShowWarnignBtn\" class=\"cpOrangeButon\" type=\"button\" " + 
		"onclick=\"msfWarningButtonClickWdm()\" onkeydow=\"msfWarningButtonClickWdm()\" " +
		"value=\"Ok\"/></div>";	
	msfWarningWdm = new MsfWindow('msfWarningWdm', title, 'body', height, width, "msfWarningWdm", true, isLong);
	msfWarningLabelWdm = new MsfLabel("msfWarningLabelWdm", text, 20, 35, true);
	msfWarningWdm.addConponent(msfWarningLabelWdm.getHtm());
	msfWarningWdm.addConponent(button);
	msfWarningWdm.setModalColor('DBEFFA');
	msfWarningWdm.setIcon('w');
	msfWarningWdm.init();
	msfWarningLabelWdm.repaint();
	$("#" + msfWarningWdm.getInnerlId()).draggable({
		snapDistance: 10, 
		ghosting: false,
		opacity: 0.2,
		zindex: 1000,
		handle: 'div.cpWarningHeader'
	});
	$('#msfShowWarnignBtn').focus();
}

/**
 * showOkMessage
 * @param {type} text, title, height, width, isLong 
 */
showOkMessage = function (text, title, height, width, isLong) {
	var y = height - 80;
	var button = "<div class=\"cpGreenButtonMsg\" style=\"margin-left: " + ((width/2) - 50) + "px; " +
		"margin-top: " + y + "px\">" +
		"<input id=\"msfShowWarnignBtn\" class=\"cpGreenButton\" type=\"button\" " + 
		"onclick=\"msfWarningButtonClickWdm()\" onkeydow=\"msfWarningButtonClickWdm()\" " +
		"value=\"Ok\"/></div>";	
	msfWarningWdm = new MsfWindow('msfWarningWdm', title, 'body', height, width, "msfWarningWdm", true, isLong);
	msfWarningLabelWdm = new MsfLabel("msfWarningLabelWdm", text, 20, 35, true);
	msfWarningWdm.addConponent(msfWarningLabelWdm.getHtm());
	msfWarningWdm.addConponent(button);
	msfWarningWdm.setModalColor('DBEFFA');
	msfWarningWdm.setIcon('o');
	msfWarningWdm.init();
	msfWarningLabelWdm.repaint();
	$("#" + msfWarningWdm.getInnerlId()).draggable({
		snapDistance: 10, 
		ghosting: false,
		opacity: 0.2,
		zindex: 1000,
		handle: 'div.cpOkWindowHeader'
	});
	$('#msfShowWarnignBtn').focus();
}

showErrorMessage = function (text, title, height, width, isLong) {
	var y = height - 80;
	var button = "<div class=\"cpRedButtonMsg\" style=\"margin-left: " + ((width/2) - 50) + "px; " +
		"margin-top: " + y + "px\">" +
		"<input id=\"msfShowWarnignBtn\" class=\"cpRedButton\" type=\"button\" " + 
		"onclick=\"msfWarningButtonClickWdm()\" onkeydow=\"msfWarningButtonClickWdm()\" " +
		"value=\"Ok\"/></div>";	
	msfWarningWdm = new MsfWindow('msfWarningWdm', title, 'body', height, width, "msfWarningWdm", true, isLong);
	msfWarningLabelWdm = new MsfLabel("msfWarningLabelWdm", text, 20, 35, true);
	msfWarningWdm.addConponent(msfWarningLabelWdm.getHtm());
	msfWarningWdm.addConponent(button);
	msfWarningWdm.setModalColor('DBEFFA');
	msfWarningWdm.setIcon('e');
	msfWarningWdm.init();
	msfWarningLabelWdm.repaint();
	$("#" + msfWarningWdm.getInnerlId()).draggable({
		snapDistance: 10, 
		ghosting: false,
		opacity: 0.2,
		zindex: 1000,
		handle: 'div.cpErroWindowHeader'
	});
	$('#msfShowWarnignBtn').focus();
}

showOption = function (text, title, height, width, icone, buttons, isLong, callBack) {
	var y = height - 80;		
	var classeBotao = "";
	var button = "";
	var handlerDrag = "";
	msfWarningWdm = new MsfWindow('msfWarningWdm', title, 'body', height, width, "msfWarningWdm", true, isLong);
	var idxCalback = msfAdminCalbackWdm.push(new MsfCallBackAdminWdm(callBack)) -1;
	msfWarningWdm.setModalColor('DBEFFA');
	switch (icone) {
		case 'd':
			//msfWarningWdm.setModalColor('DBEFFA');			
			button = "<div class=\"cpBlueButtonMsg\" style=\"width: " +	
				(width - 148) + "px; " + "top:" + (height - 50) + "px\">";
			classeBotao = 'cpBlueButton';
			handlerDrag = 'div.cpDefaulWindowHeader';
			break;
		
		case 'w':
			//msfWarningWdm.setModalColor('E4761F');
			button = "<div class=\"cpOrangeButtonMsg\" style=\"width: " + 
				(width - 148) + "px; " + "top:" + (height - 50) + "px\">";
			classeBotao = 'cpOrangeButon';
			handlerDrag = 'div.cpWarningHeader';
			break;
			
		case 'o':
			button = "<div class=\"cpGreenButtonMsg\" style=\"width: " +	
				(width - 148) + "px; " + "top:" + (height - 50) + "px\">";
			classeBotao = 'cpGreenButton';
			//msfWarningWdm.setModalColor('42929D');
			handlerDrag = 'div.cpOkWindowHeader';
			break;
			
		case 'e':
			button = "<div class=\"cpRedButtonMsg\" style=\"width: " +	
				(width - 148) + "px; " + "top:" + (height - 50) + "px\">";
			classeBotao = 'cpRedButton';
			//msfWarningWdm.setModalColor('974578');
			handlerDrag = 'div.cpErroWindowHeader';
			break;
	}	
			
	for (var i = 0; i < buttons.length; i++) {	
		button += "<input id=\"msfShowWarnignBtn" + i + "\" class=\"" + classeBotao + "\" type=\"button\" " + 
			"onclick=\"msfCallBackOptionWdm('" + buttons[i] + "', " + idxCalback +
			")\" onkeydow=\"msfWarningButtonClickWdm()\" value=\"";
		switch(buttons[i]) {
			case 's':
				button+= "Sim\"/>";			
				break;
				
			case 'n':
				button+= "Não\"/>";
				break;
				
			case 'c':			
				button+= "Cancelar\"/>";
				break;
			
			case 'o':
				button+= "Ok\"/>";
				break;
		}		
	}
	
	button+= "</div>";
	
	msfWarningLabelWdm = new MsfLabel("msfWarningLabelWdm", text, 20, 30, true);
	msfWarningWdm.addConponent(msfWarningLabelWdm.getHtm());
	msfWarningWdm.addConponent(button);
	msfWarningWdm.setIcon(icone);
	msfWarningWdm.init();
	msfWarningLabelWdm.repaint();
	$("#" + msfWarningWdm.getInnerlId()).draggable({
		snapDistance: 10, 
		ghosting: false,
		opacity: 0.2,
		zindex: 1000,
		handle: handlerDrag
	});	
	$('#msfShowWarnignBtn').focus();
}

showPrompt = function (text, title, label, height, width, promptWidth, icone, buttons, isLong, callBack) {
	var y = height - 110;
	var xPrompt = parseInt(((width - 148) - promptWidth)/2);
	var yPrompt = y/2 + 10; 
	var classeBotao = "";
	var button = "";
	var handlerDrag = "";
	msfWarningWdm = new MsfWindow('msfWarningWdm', title, 'body', height, width, "msfWarningWdm", true, isLong);
	var idxCallback = msfAdminCalbackWdm.push(new MsfCallBackAdminWdm(callBack)) - 1;	
	switch (icone) {
		case 'd':
			msfWarningWdm.setModalColor('DBEFFA');			
			button = "<div class=\"cpBlueButtonMsg\" style=\"margin-right: 140px; " +	
				"margin-top: " + (y + 30) + "px; left: 220px; \">";
			classeBotao = 'cpBlueButton';
			handlerDrag = 'div.cpDefaulWindowHeader';
			break;
		
		case 'w':
			msfWarningWdm.setModalColor('E4761F');
			button = "<div class=\"cpOrangeButtonMsg\" style=\"margin-right: 140px; " +	
				"margin-top: " + y + "px\">";
			classeBotao = 'cpOrangeButon';
			handlerDrag = 'div.cpWarningHeader';
			break;
			
		case 'o':
			button = "<div class=\"cpGreenButtonMsg\" style=\"margin-right: 140px; " +	
				"margin-top: " + y + "px\">";
			classeBotao = 'cpGreenButton';
			msfWarningWdm.setModalColor('42929D');
			handlerDrag = 'div.cpOkWindowHeader';
			break;
			
		case 'e':
			button = "<div class=\"cpRedButtonMsg\" style=\"margin-right: 140px; " +	
				"margin-top: " + y + "px\">";
			classeBotao = 'cpRedButton';
			msfWarningWdm.setModalColor('974578');
			handlerDrag = 'div.cpErroWindowHeader';
			break;
	}
	
	for (var i = 0; i < buttons.length; i++) {	
		button += "<input id=\"msfShowWarnignBtn" + i + "\" class=\"" + classeBotao + "\" type=\"button\" " + 
			"onclick=\"msfCallBackPromptWdm('" + buttons[i] + "', " + idxCallback +
			")\" onkeydow=\"msfWarningButtonClickWdm()\" value=\"";
		switch(buttons[i]) {
			case 's':
				button+= "Sim\"/>";			
				break;
				
			case 'n':
				button+= "Não\"/>";
				break;
				
			case 'c':			
				button+= "Cancelar\"/>";
				break;
			
			case 'o':
				button+= "Ok\"/>";
				break;
		}		
	}
	
	button+= "</div>";
	
	msfWarningLabelWdm = new MsfLabel("msfWarningLabelWdm", text, 20, 20, true);
	msfPromptLabelWdm = new MsfLabel("msfPromptLabelWdm", label, xPrompt, yPrompt, true);
	msfPromptCallbackWdm = new MsfPrompt("msfPromptCallbackWdm", "", xPrompt, yPrompt + 20, promptWidth);
	
	msfWarningWdm.addConponent(msfWarningLabelWdm.getHtm());
	msfWarningWdm.addConponent(msfPromptLabelWdm.getHtm());
	msfWarningWdm.addConponent(msfPromptCallbackWdm.getHtm());
	msfWarningWdm.addConponent(button);
	msfWarningWdm.setIcon(icone);
	msfWarningWdm.init();
	msfWarningLabelWdm.repaint();
	$("#" + msfWarningWdm.getInnerlId()).draggable({
		snapDistance: 10, 
		ghosting: false,
		opacity: 0.2,
		zindex: 1000,
		handle: handlerDrag
	});	
	$('#msfPromptCallbackWdm').focus();
}

/**
 * showPromptMask
 * @param {type} text, title, label, height, width, promptWidth, icone, buttons, mascara, callBack 
 */
showPromptMask = function(text, title, label, height, width, promptWidth, icone, buttons, mascara, callBack) {
 	var y = height - 110;
	var xPrompt = parseInt(((width - 148) - promptWidth)/2);
	var yPrompt = y/2 + 10; 
	var classeBotao = "";
	var button = "";
	var handlerDrag = "";
	msfWarningWdm = new MsfWindow('msfWarningWdm', title, 'body', height, width, "msfWarningWdm", true, false);
	var idxCallback = msfAdminCalbackWdm.push(new MsfCallBackAdminWdm(callBack)) - 1;	
	switch (icone) {
		case 'd':
			msfWarningWdm.setModalColor('DBEFFA');			
			button = "<div class=\"cpBlueButtonMsg\" style=\"margin-right: 140px; " +	
				"margin-top: " + (y + 30) + "px; left: 220px; \">";
			classeBotao = 'cpBlueButton';
			handlerDrag = 'div.cpDefaulWindowHeader';
			break;
		
		case 'w':
			msfWarningWdm.setModalColor('E4761F');
			button = "<div class=\"cpOrangeButtonMsg\" style=\"margin-right: 140px; " +	
				"margin-top: " + y + "px\">";
			classeBotao = 'cpOrangeButon';
			handlerDrag = 'div.cpWarningHeader';
			break;
			
		case 'o':
			button = "<div class=\"cpGreenButtonMsg\" style=\"margin-right: 140px; " +	
				"margin-top: " + y + "px\">";
			classeBotao = 'cpGreenButton';
			msfWarningWdm.setModalColor('42929D');
			handlerDrag = 'div.cpOkWindowHeader';
			break;
			
		case 'e':
			button = "<div class=\"cpRedButtonMsg\" style=\"margin-right: 140px; " +	
				"margin-top: " + y + "px\">";
			classeBotao = 'cpRedButton';
			msfWarningWdm.setModalColor('974578');
			handlerDrag = 'div.cpErroWindowHeader';
			break;
	}
	
	button += "<input id=\"msfShowWarnignBtn" + i + "\" class=\"" + classeBotao + "\" type=\"button\" " + 
		"onclick=\"msfCallBackPromptWdm('" + buttons[i] + "', " + idxCallback +
		")\" onkeydow=\"msfWarningButtonClickWdm()\" value=\"";
	for (var i = 0; i < buttons.length; i++) {	
		switch(buttons[i]) {
			case 's':
				button+= "Sim\"/>";			
				break;
				
			case 'n':
				button+= "Não\"/>";
				break;
				
			case 'c':			
				button+= "Cancelar\"/>";
				break;
			
			case 'o':
				button+= "Ok\"/>";
				break;
		}		
	}
	
	button+= "</div>";
	
	msfWarningLabelWdm = new MsfLabel("msfWarningLabelWdm", text, 20, 30, true);
	msfPromptLabelWdm = new MsfLabel("msfPromptLabelWdm", label, xPrompt, yPrompt, true);	
	msfPromptCallbackWdm = new MsfPromptMask("msfPromptCallbackWdm", "", xPrompt, yPrompt + 20, promptWidth, mascara);
	
	msfWarningWdm.addConponent(msfWarningLabelWdm.getHtm());
	msfWarningWdm.addConponent(msfPromptLabelWdm.getHtm());
	msfWarningWdm.addConponent(msfPromptCallbackWdm.getHtm());
	msfWarningWdm.addConponent(button);
	msfWarningWdm.setIcon(icone);
	msfWarningWdm.init();
	msfWarningLabelWdm.repaint();
	$("#" + msfWarningWdm.getInnerlId()).draggable({
		snapDistance: 10, 
		ghosting: false,
		opacity: 0.2,
		zindex: 1000,
		handle: handlerDrag
	});	
	$('#msfPromptCallbackWdm').focus();
 	
}

showLoader = function(mensagem, escopo, isLong) {	
	var img = "<div style=\"margin-left: 30px; " +
		"margin-top: 30px\">" +
		"<img src=\"../image/loader.gif\"/></div>";
	msfWarningWdm = new MsfWindow('msfWarningWdm', "Carregando", escopo, 120, 210, "msfWarningWdm", true, isLong);	
	msfWarningLabelWdm = new MsfLabel("msfWarningLabelWdm", mensagem, 35, 80, true);
	msfWarningWdm.addConponent(msfWarningLabelWdm.getHtm());	
	msfWarningWdm.addConponent(img);
	msfWarningWdm.setModalColor('DBEFFA');
	msfWarningWdm.setIcon('d');
	//msfWarningWdm.setCloser(true);
	msfWarningWdm.init();
	msfWarningLabelWdm.repaint();
}

hideLoader = function() {
	msfWarningButtonClickWdm();
}

msfCallBackOptionWdm = function(value, idx) {
	msfAdminCalbackWdm[idx].setParametro(value);
	msfAdminCalbackWdm[idx].execFunction();
	msfWarningButtonClickWdm();
}

msfCallBackPromptWdm = function(value, idx) {
	msfAdminCalbackWdm[idx].setParametro(value);
	msfAdminCalbackWdm[idx].setSecondParametro(msfPromptCallbackWdm.getValue());
	msfAdminCalbackWdm[idx].execFunctioParametro();
	msfWarningButtonClickWdm();
}

msfWarningButtonClickWdm = function() {
	msfWarningWdm.hide();
}

masfRdChangeRadio = function(value, idx) {	
	msfAdminCalbackWdm[idx].setParametro(value);
	msfAdminCalbackWdm[idx].execFunction();
}

msfCkChange = function(idx) {
	msfAdminCalbackWdm[idx].execOneFunction();
}


/**
 * msfCbChangeComboBox
 * @param {type} idx
 */
msfCbChangeComboBox = function(value, idx) {
 	msfAdminCalbackWdm[idx].setParametro(value);
 	msfAdminCalbackWdm[idx].execFunction();
}