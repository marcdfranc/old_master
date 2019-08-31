adminFiltro = function(id, tipo, rotulo, data, px, py, mascara) {
	var elemento;
	var subElemento;
	var label = new Array();
	var dataMount;	
	var pipe;
	var px = px;
	var py = py;
	var tipo= tipo;
	var id = id;
	var rotulo = rotulo;
	var mascara = mascara;	

	switch(tipo) {
		case 'r':
			dataMount = new Array();
			label.push(new MsfLabel(id + "MainLabel", rotulo, px, py, false));
			pipe = unmountPipe(data);
			for(var i=0; i<pipe.length; i++) {
				if (i == 0) {
					dataMount.push([true, parseInt(getPipeByIndex(pipe[i],3)), 
						parseInt(getPipeByIndex(pipe[i], 4)), getPipeByIndex(pipe[i], 5)]);
				} else {
					dataMount.push([false, parseInt(getPipeByIndex(pipe[i],3)), 
						parseInt(getPipeByIndex(pipe[i], 4)), getPipeByIndex(pipe[i], 5)]);
				}
				label.push(new MsfLabel(id + "Label" + i, getPipeByIndex(pipe[i], 0), 
					parseInt(getPipeByIndex(pipe[i], 1)), 
					parseInt(getPipeByIndex(pipe[i], 2)), false));
			}			 
			elemento = new MsfRadioGroup(id, dataMount , function(value) {
				elemento.setValue(value);
			});			
			break;
			
		case 'k':
			elemento = new MsfCheck(id, rotulo, px, py, getPart(data, 1),
				 getPart(data, 2), "f",	function() {
					elemento.changeValue();
				}
			);
			break;
			
		case 'i':
			/*elemento = new ItemSelector(id,	rotulo, "Selecionados", "valores", "", 
				parseInt(getPart(data, 2)) , parseInt(getPart(data, 1)),
				function(act, item) {
					elemento.executeAct(act, item);
			});						
			elemento.generateConteiner(px, py);*/
			dataMount = data;
			break;
			
		case 't':
			if (mascara == "") {
				elemento = new MsfPrompt(id, "", parseInt(getPipeByIndex(data, 0)), 
					parseInt(getPipeByIndex(data, 1)), 
					parseInt(getPipeByIndex(data, 2)));
			} else {
				elemento = new MsfPromptMask(id, "", parseInt(getPipeByIndex(data, 0)), 
				parseInt(getPipeByIndex(data, 1)), parseInt(getPipeByIndex(data, 2)),
				 mascara);	
			}
			label.push(new MsfLabel(id + "Label", rotulo, parseInt(px), 
				parseInt(py), false));
			break;
			
		case 'd':	
			if (mascara == "") {
				elemento = new MsfPrompt(id + "main", "", parseInt(getPipeByIndex(data, 0)),
					parseInt(getPipeByIndex(data, 1)), 
					parseInt(getPipeByIndex(data, 2)));
				
				subElemento = new MsfPrompt(id, "", parseInt(getPipeByIndex(data, 6)),
					parseInt(getPipeByIndex(data, 7)), 
					parseInt(getPipeByIndex(data, 8)));
			} else {
				elemento = new MsfPromptMask(id, "", parseInt(getPipeByIndex(data, 0)),
					parseInt(getPipeByIndex(data, 1)), 
					parseInt(getPipeByIndex(data, 2)), mascara);
				
				subElemento = new MsfPromptMask(id, "", parseInt(getPipeByIndex(data, 6)),
					parseInt(getPipeByIndex(data, 7)), 
					parseInt(getPipeByIndex(data, 8)), mascara);
			}			
			label.push(new MsfLabel(id + "Label", rotulo, parseInt(px), 
				parseInt(py), false));
								
			label.push(new MsfLabel(id + "Labelpp2", getPipeByIndex(data, 3), 
				parseInt(getPipeByIndex(data, 4)),
				parseInt(getPipeByIndex(data, 5)), false));
			break;
			
		case 'c':
			mascara = virgulaToPipe(mascara);
			mascara = ptVirgulaToRealPipe(mascara);
			dataMount = new Array();
			dataMount.push(["0","Selecione"]);
			label.push(new MsfLabel(id + "Label", rotulo, parseInt(px), 
				parseInt(py), false));			 
			if (data != "-1") {
				pipe = unmountPipe(data);
				for (var i=0; i<pipe.length; i++) {
					dataMount.push([getPart(pipe[i], 1), getPart(pipe[i], 2)]);					
				}
				elemento = new MsfComboBox(id , dataMount, parseInt(getPipeByIndex(mascara, 0), function(valor) {
					elemento.setValue(valor);
				}), 
					parseInt(getPipeByIndex(mascara, 1)), "");
				dataMount = data;
			} else {
				elemento = undefined;
			}
			break;
	}	
	
	this.setPosition = function(x, y) {
		elemento.setPosition(x, y);
	}
	
	this.setRadioPosition = function(index, x, y) {
		elemento.setPosition(index, x, y);
	}
	
	this.show = function() {
		elemento.show();		
	}
	
	this.hide = function() {
		elemento.hide();
	}
	
	this.getHtm = function() {
		var aux= "";		
		for(var i=0; i<label.length; i++) {
			aux+= label[i].getHtm();
		}
		return (tipo == 'd')? aux + elemento.getHtm() + subElemento.getHtm()
			: aux + elemento.getHtm();
	}
	
	this.getComboHtm = function(arrayData) {
		var aux= "";
		if (dataMount != "-1") {
			elemento = new MsfComboBox(id , arrayData, parseInt(getPipeByIndex(mascara, 0), function(valor) {
				elemento.setValue(valor);	
			}), 
				parseInt(getPipeByIndex(mascara, 1)), "");
		}
		for(var i=0; i<label.length; i++) {
			aux+= label[i].getHtm();
		}
		aux+= (elemento == undefined)? "": elemento.getHtm();
		return aux;
	}
	
	this.getItemSelectorHtm = function() {
		var htmlItemSel = "";		
		elemento = new ItemSelector(id,	rotulo, "Selecionados", "valores", "", 
				parseInt(getPart(dataMount, 2)) , parseInt(getPart(dataMount, 1)),
				function(act, item) {
					elemento.executeAct(act, item);
			});
		htmlItemSel = elemento.generateConteiner(parseInt(px), parseInt(py));		
		return elemento.generateConteiner(parseInt(px), parseInt(py));
	}
	
	this.showItemSelector = function(ArrayData) {
		elemento.init(ArrayData);
		elemento.show();		
	}
	
	this.getValue = function() {		
		if (tipo == "t" || tipo == "c") {
			return elemento.getSpecialValue();
		} else if (tipo == 'd') {
			return elemento.getSpecialValue() + "?" + subElemento.getSpecialValue();
		} else if (elemento == undefined) {
			return "";
		} else {
			return elemento.getValue();
		}
	}
	
	this.getXPosition = function() {
		return elemento.getXPosition();
	}
	
	this.getRadioXPosition = function(index) {
		return elemento.getXPosition(index);
	}
	
	this.getYPosition = function(index) {
		return this.data[index][2];
	}
	
	this.getRadioYPosition = function(index) {
		return elemento.getYPosition(index);
	}
	
	this.tipoComponente = function() {
		return tipo;
	}
	
	this.getId = function() {
		return id;
	}
}
