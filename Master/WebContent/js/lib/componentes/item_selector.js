var adminCalbackItSel = new Array();
var idCall;
$(document).ready(function() {
	$('.connectedSortable li').click(function() {
		if ($(this).hasClass('selectedItem')) {
			$(this).removeClass('selectedItem');
		} else {
			$(this).addClass('selectedItem');
		}
	});
});

var MsfItSelCallback = function(functionCall) {
	this.functionCall = functionCall;
	this.parametro = "";
	this.secondParametro;
	
	this.setParametro = function(parametro) {
		this.parametro = parametro;
	}
	
	this.setSecondParametro = function(parametro) {
		this.secondParametro = parametro;
	}
	
	this.execFunction = function() {
		this.functionCall(this.parametro);
	}
	
	this.execFunctioParametro = function() {
		this.functionCall(this.parametro, this.secondParametro);
	}
};


/** 
 * @param {String} local 
 * @param {int} height
 * @param {int} width
 * @classDescription seletor de linhas
 */
ItemSelector = function(id, titulo, tituloRight, TituloLeft, local, height, width, callBack) {
	idCall =  adminCalbackItSel.push(new MsfItSelCallback(callBack)) - 1;
	
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
	this.width = ($.browser.msie)? width + 18 : width;		
	this.widthBox = parseInt(((width - 45) / 2) - 15);	
	this.heightBox= height - 90;
	this.maginTopButton = parseInt((this.heightBox - 40) / 2);
	this.leftValue = new Array();
	this.rightValue = new Array();
	this.value;
	this.id = id;
	this.titulo= titulo;
	this.rightTitulo = tituloRight;
	this.leftTitulo = TituloLeft;
	this.header = "";
	this.leftHtm = "";
	this.rightHtm = "";
	this.htm = "";
	this.footer= "";
	this.buttonHtm;
	this.visible = true;
	this.poster= "";
	this.posterId= "";
	this.loaded= false;
	this.px;
	this.py;
	
	this.init = function(data) {
		this.loaded = true;
		this.header = "<div class=\"cpItemSelector\" style=\"height:" +
			this.height + "px; width: " + this.width + "px\">" +
			"<div class=\"cpTitleItemSelector\">" +
			"<label>" + this.titulo + "</label></div>";
			
		this.leftHtm = "<div class=\"cpLeftBoxItemSelector\" style=\"width: " +
			this.widthBox + "px\"><div class=\"tituloBoxItemSelector\"><label>" + 
			this.leftTitulo + "</label></div><div id=\"" + this.id + 
			"L\" class=\"cpContentItemSelector\" style=\"height: " +
			this.heightBox + "px\">";
		
		this.popular(data);
		
		/**
		 * tudoADireita = 	"r"
		 * paraDireita = 	"d"
		 * paraEsquerda= 	"e"
		 * tudoAEsquerda = 	"l"
		 * itSelecione = 	"i"
		 */
		
		this.buttonHtm = "<div class=\"cpButtonIttenSelector\" style=\"margin-top: " +
			this.maginTopButton + "px\"><input type=\"button\" value=\">>\" " +
			"onclick=\"callF('r', " + idCall + ", -1)\"/><br />" +			
			"<input type=\"button\" value=\">\" onclick=\"callF('d', " +
			idCall + ", -1)\"/><br />" +
			"<input type=\"button\" value=\"<\" onclick=\"callF('e', " +
			idCall + ", -1)\"/><br />" +
			"<input type=\"button\" value=\"<<\" onclick=\"callF('l', " +
			idCall + ", -1)\"/><br /></div>";
			
		this.rightHtm = "<div class=\"cpRightBoxItemSelector\" style=\"width: " +
			this.widthBox + "px\"><div class=\"tituloBoxItemSelector\"><label>" +
			this.rightTitulo + "</label></div><div id=\"" + this.id +
			"R\" class=\"cpContentItemSelector\" style=\"height: " +
			this.heightBox + "px\"></div></div>";
		
		this.footer = "</div>";
		
		this.htm = this.header + this.leftHtm + this.buttonHtm + this.rightHtm + this.footer;
		if (this.visible) {
			$("[id= " + this.local + "]").empty();
			$("[id= " + this.local + "]").append(this.htm);
		}
	}
	
	this.setVisible = function(value) {
		this.visible = value;
	}
	
	this.show = function() {		
		this.visible = true;
		$("[id= " + this.local + "]").empty();
		$("[id= " + this.local + "]").append(this.htm);
	}
	
	this.hide = function() {
		this.visible = false;
		$("[id= " + this.local + "]").empty();
	}
	
	this.setTitle = function(titulo) {
		this.titulo = titulo;
	}
	
	this.setLeftTitle = function(titulo) {
		this.leftTitulo = titulo;
	}
	
	this.setRightTitulo = function(titulo) {
		this.rightTitulo = titulo;
	}
	
	this.setLocal = function(local) {
		this.local = local;
	}
	
	this.setPoster= function(value) {
		this.poster = "<input id=\"" + value + "\" name=\"" + value +
		"\" type=\"hidden\" value=\"\"/>";
		this.posterId = value;
		$("[id= " + this.local + "]").parent().append(this.poster);
	}
	
	this.mountLeftHtm = function() {
		var aux = "<div class=\"cpLeftBoxItemSelector\" style=\"width: " +
			this.widthBox + "px\"><div class=\"tituloBoxItemSelector\"><label>" + 
			this.leftTitulo + "</label></div><div id=\"" + this.id + 
			"L\" class=\"cpContentItemSelector\" style=\"height: " +
			this.heightBox + "px\">";
					
		for(var i = 0; i < this.leftValue.length; i++) {
			aux+= this.leftValue[i].getHtm();
		}
		
		aux+= "</div></div>";
		this.leftHtm = aux;
		$('.connectedSortable li').click(function() {
			if ($(this).hasClass('selectedItem')) {
				$(this).removeClass('selectedItem');
			} else {
				$(this).addClass('selectedItem');
			}
		});
	}
	
	this.mountRightHtm = function() {
		var aux = "<div class=\"cpRightBoxItemSelector\" style=\"width: " +
			this.widthBox + "px\"><div class=\"tituloBoxItemSelector\"><label>" +
			this.rightTitulo + "</label></div><div id=\"" + this.id +
			"R\" class=\"cpContentItemSelector\" style=\"height: " +
			this.heightBox + "px\">";
		
		for(var i = 0; i < this.rightValue.length; i++) {
			aux+= this.rightValue[i].getHtm();
		}
		
		aux+= "</div></div>";
		this.rightHtm = aux;
	
	}
	
	this.repaint = function() {
		this.htm = this.header + this.leftHtm + this.buttonHtm + this.rightHtm + this.footer;
		if (this.visible) {
			$("[id= " + this.local + "]").empty();
			$("[id= " + this.local + "]").append(this.htm);
		}
		$('.connectedSortable li').click(function() {
			if ($(this).hasClass('selectedItem')) {
				$(this).removeClass('selectedItem');
			} else {
				$(this).addClass('selectedItem');
			}
		});
	}
	
	this.setHeight = function(value) {
		this.height = value;
		this.heightBox = value - 90;
	}
	
	this.generateConteiner = function(x, y) {
		this.local = this.id + "selecPai";
		this.px = x;
		this.py = y;
		return "<div class=\cpPrompt\" id=\"" + this.local + "\" style=\"top: " + 
			this.py + "px; left: " + this.px + "px;\"></div>";
	}
	
	this.getConteiner = function() {
		return "<div class=\cpPrompt\" id=\"" + this.local + "\" style=\"top: " + 
			this.py + "px; left: " + this.px + "px;\"></div>";
	}
	
	this.getHeight = function() {
		return this.height;
	}	
	
	this.setWidth = function(value) {
		this.width = ($.browser.msie)? value + 18 : value;		
		this.widthBox = parseInt(((value - 45) / 2) - 15);
	}
	
	this.getWidth = function() {
		return ($.browser.msie)? this.width - 18: this.width;		
	}
	
	this.getValue= function() {
		return this.value;
	}
	
	this.popular = function(values) {
		this.leftValue = new Array();
		this.rightValue = new Array();
		for (var i = 0; i < values.length; i++) {
			this.leftValue[this.leftValue.length] = new itemSelectorData("L" + this.leftValue.length, 
				values[i][0], values[i][1]); 
		}
		this.mountLeftHtm();
		this.mountRightHtm();
	}
	
	this.addLeftValue = function(text, value) {
		this.leftValue.push(new itemSelectorData("L" + this.leftValue.length, text, value));
	}
	
	this.removeLeftValue = function() {
		var i = 0;
		var notUndefined;
		try {
			notUndefined = this.leftValue[i].getText().length > 0;
		} catch (e) {
			notUndefined = false;
		}
		do {			
			if (this.leftValue[i].isSelected() && (i == this.leftValue.length - 1)) {
				this.leftValue[i] = undefined;
			} else if (this.leftValue[i].isSelected()) {
				for(var j = i; j < this.leftValue.length; j++) {
					if (j == this.leftValue.length -1) {
						this.leftValue[j] = undefined;
					} else {
						this.leftValue[j] = this.leftValue[j + 1];
						this.leftValue[j].setId(j);
					}
				}
			} else {
				i++;
			}
			try {
				notUndefined = this.leftValue[i].getText().length > 0;
			} catch (e) {
				notUndefined = false;
			}
		} while(notUndefined);
	}
	
	this.addValue = function(text, value) {
		this.rightValue[this.rightValue.length] = new itemSelectorData("R" + this.rightValue.length, text, value); 
	}
	
	this.addValueByObject = function(objeto) {
		var isFirst = true;
		objeto.setId("R" + this.rightValue.length);
		this.rightValue[this.rightValue.length] = objeto;
		this.value = "";
		for (var i = 0; i < this.rightValue.length; i++) {
			if (isFirst) {
				this.value+= this.rightValue[i].getValue();
				isFirst= false;
			} else {
				this.value+= "@" + this.rightValue[i].getValue();
			}
		}
	}
	
	this.removeRightValue = function() {
		var i = 0;		
		while(this.rightValue[i] != undefined) {
			if (this.rightValue[i].isSelected() && (i == this.rightValue.length - 1)) {
				this.rightValue[i] = undefined;
			} else if (this.rightValue[i].isSelected()) {
				for(var j = i; j < this.rightValue.length; j++) {
					if (j == this.rightValue.length -1) {
						this.rightValue[j] = undefined;
					} else {
						this.rightValue[j] = this.rightValue[j + 1];
					}
				}
			} else {
				i++;				
			}
		}
	}
	
	this.paraDireita = function() {
		var isFirst;
		var i = 0;
		while(i < this.leftValue.length) {
			if (this.leftValue[i].isSelected()) {
				this.leftValue[i].removeSelection();				
				this.rightValue.push(this.leftValue.splice(i, 1)[0]);
				this.value = "";
				isFirst = true;
				for (var j = 0; j < this.rightValue.length; j++) {
					if (isFirst) {
						this.value+= this.rightValue[j].getValue();
						isFirst = false;
					} else {
						this.value+= "@" + this.rightValue[j].getValue();
					}
				}
				if (this.poster != "") {
					$("[id= " + this.posterId + "]").val(this.value);
				}
			} else {
				i++;
			}
		}
		
		this.mountLeftHtm();
		this.mountRightHtm();
		this.repaint();
		$('.connectedSortable li').click(function() {
			if ($(this).hasClass('selectedItem')) {
				$(this).removeClass('selectedItem');
			} else {
				$(this).addClass('selectedItem');
			}
		});
	}
	
	this.tudoADireita = function() {
		var isFirst;
		var i = 0;
		while(this.leftValue.length > 0) {			
			this.leftValue[i].removeSelection();				
			this.rightValue.push(this.leftValue.splice(i, 1)[0]);
			this.value = "";
			isFirst = true;
			for (var j = 0; j < this.rightValue.length; j++) {
				if (isFirst) {
					this.value+= this.rightValue[j].getValue();
					isFirst = false;
				} else {
					this.value+= "@" + this.rightValue[j].getValue();
				}
			}
			if (this.poster != "") {
				$("[id= " + this.posterId + "]").val(this.value);
			}			
		}		
		this.mountLeftHtm();
		this.mountRightHtm();
		this.repaint();
	}
	
	this.paraEsquerda = function() {
		var isFirst;
		var i = 0;
		while(i < this.rightValue.length) {
			if (this.rightValue[i].isSelected()) {
				this.rightValue[i].removeSelection();				
				this.leftValue.push(this.rightValue.splice(i, 1)[0]);
				this.value = "";
				isFirst = true;
				for (var j = 0; j < this.rightValue.length; j++) {
					if (isFirst) {
						this.value+= this.rightValue[j].getValue();
						isFirst = false;
					} else {
						this.value+= "@" + this.rightValue[j].getValue();
					}
				}
				if (this.poster != "") {
					$("[id= " + this.posterId + "]").val(this.value);					
				}
			} else {
				i++;
			}
		}		
		this.mountLeftHtm();
		this.mountRightHtm();
		this.repaint();
	}
	
	this.tudoAEsquerda = function() {
		var isFirst;
		var i = 0;
		while(this.rightValue.length > 0) {			
			this.rightValue[i].removeSelection();				
			this.leftValue.push(this.rightValue.splice(i, 1)[0]);
			this.value = "";
			isFirst = true;
			for (var j = 0; j < this.rightValue.length; j++) {
				if (isFirst) {
					this.value+= this.rightValue[j].getValue();
					isFirst = false;
				} else {
					this.value+= "@" + this.rightValue[j].getValue();
				}
			}
			if (this.poster != "") {
				$("[id= " + this.posterId + "]").val(this.value);					
			}			
		}		
		this.mountLeftHtm();
		this.mountRightHtm();
		this.repaint();
	}
	
	this.selecioneItem = function(value) {		
		for(var i = 0; i < this.leftValue.length;  i++) {
			if (value.id == this.leftValue[i].getId()) {
				this.leftValue[i].selecione();
				break;
			}
		}
		for(var i = 0; i < this.rightValue.length;  i++) {
			if (value.id == this.rightValue[i].getId()) {
				this.rightValue[i].selecione();
				break;
			}
		}
	}
	
	this.executeAct = function(firstParam, secondParam) {		
		switch(firstParam) {
			case 'r':
				this.tudoADireita();
				break;
				
			case 'd':
				this.paraDireita()
				break;
				
			case 'e':
				this.paraEsquerda();
				break;
			
			case 'l':
				this.tudoAEsquerda();
				break;
				
			case 'i':
				this.selecioneItem(secondParam);
				break;			
		}
	}
	
	this.isLoaded = function() {
		return this.loaded;
	}
}

itemSelectorData = function(id, value, text) {
	this.text = text;
	this.value= value;
	this.id = this.text + "itSel" + id;
	this.htm = "<div id=\"" + this.id + 
		"\" onclick=\"callF('i', " + idCall + ", this);\"><label>" + 
		text + "</label><br /></div>";
	this.selected = false;
	
	this.setText = function(text) {
		this.text = text;
		this.htm = "<div id=\"" + this.id + 
			"\" onclick=\"callF('i', " + idCall + ", this);\" ><label>" + 
			text + "</label><br /></div>";
	}
	
	this.setValue = function(value) {
		this.value = value;
	}
	
	this.isSelected = function() {
		return this.selected;
	}
	
	this.removeSelection = function() {
		this.selected = false;
	}
	
	this.selecione = function() {
		this.selected = !this.selected;
		if (this.selected) {
			$("[id= " + this.id + "]").addClass("selectedItemselector");
		} else {
			$("[id= " + this.id + "]").removeClass("selectedItemselector");
		}
	}
	
	this.getHtm = function() {
		return this.htm;
	}
	
	this.setId = function(id) {
		this.id = this.text + "itSel" + id;
		this.htm = "<div id=\"" + this.id + 
			"\" onclick=\"callF('i', " + idCall + ", this)\" ><label>" + 
			text + "</label><br /></div>";
	}
	
	this.getId = function() {
		return this.id;
	}
	
	this.getValue = function() {
		return this.value;
	}
	
	this.getText = function() {
		return this.text;
	} 
}

callF = function(act, idx, complemento) {
	adminCalbackItSel[idx].setParametro(act);
	adminCalbackItSel[idx].setSecondParametro(complemento);
	adminCalbackItSel[idx].execFunctioParametro();
	$('.connectedSortable li').click(function() {
		if ($(this).hasClass('selectedItem')) {
			$(this).removeClass('selectedItem');
		} else {
			$(this).addClass('selectedItem');
		}
	});
}
