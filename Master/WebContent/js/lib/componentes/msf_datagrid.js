
MsfDataGrid = function(id, width) {	
	var id = id;
	var width = width;
	var header;
	var headerValues = "";
	var visible = true;
	var px;
	var py;	
	var html;
	var rollValues = new Array();
	var arrayHeader = new Array();
	
	this.addFields = function(width, value) {
		headerValues += "<th style=\"width:" + width + "%\"><div class=\"headerColum\"><p>" +
			value + "</p></div></th>";
		arrayHeader.push(value);
	}
	
	this.init = function(data, bruta) {
		var arrayAux = new Array();
		var arrayColum = new Array();
		var arrayRoll;
		var aux = "";
		if (bruta) {
			arrayAux = unmountPipe(data);
			data = new Array();
			for(var i = 0; i < arrayAux.length; i++) {
				aux = arrayAux[i].replace(";", "|");
				arrayColum = unmountPipe(aux);
				arrayRoll = new Array(); 
				for(var j = 0; j< arrayColum.length; j++) {
					arrayRoll.push([getPart(arrayColum[j], 1), getPart(arrayColum[j], 2)]);
				}
				data.push(arrayRoll);
			}
		}
		aux = "";
		var lastIndex = 0;
		var auxHeader = "";
		for(var i = 0; i < data.length; i++) {			
			rollValues.push(new DataField(data[i]));
			lastIndex = rollValues.length -1;
			for(var j = 0; j < rollValues[lastIndex].getSize(); j++) {
				if (j == 0) {
					aux+= "<tr class=\"gridRowEmpty\">";
				}
				aux+= "<td><label>" + 
					rollValues[lastIndex].getFieldValue(
						rollValues[lastIndex].getFieldByIndex(j)) + "</label></td>";
				if (j == rollValues[lastIndex].getSize() -1) {
					aux+= "</tr>";
				}
			}
		}
		
		header = "<div id=\"" + id + "\" style=\"width: " + width + "px;"			
		
		if (px != undefined && py != undefined) {
			header+= "position: absolute; top: " + py + "px; left: " + px + "px;\" "; 
		} else {
			header+= "\" ";			
		}
		
		if (visible) {
			header+= " class=\"dataGrid cpEsconde\"><table id=\"dg\" cellpadding=\"0\" " +
				"cellspacing=\"0\" class=\"lastGrid\"><thead class=\"headerGrid\"><tr>" + headerValues;			
		} else {
			header+= " class=\"dataGrid\"><table id=\"dg\" cellpadding=\"0\" " +
				"cellspacing=\"0\" class=\"lastGrid\"><thead class=\"headerGrid\"><tr>" + headerValues;
		}
		
		html = header + "</tr></thead><tbody id=\"dataBank" + id + "\">" + aux + 
			"</tbody></table></div>"; 
	}
	
	this.repaint = function() {
		var aux = "";
		for(var i = 0; i < rollValues.length; i++) {
			for(var j = 0; j < rollValues[i].getSize(); j++) {
				if (j == 0) {
					aux+= "<tr class=\"gridRowEmpty\">";
				}
				aux+= "<td><label>" + 
					rollValues[i].getFieldValue(
						rollValues[i].getFieldByIndex(j)) + "</label></td>";
				if (j == rollValues[i].getSize() -1) {
					aux+= "</tr>";
				}
			}
		}
		
		header = "<div id=\"" + id + "\" style=\"width: " + width + "px;"
		
		if (px != undefined && py != undefined) {
			header+= "position: absolute; top: " + py + "px; left: " + px + "px;\" ";
			$("#" + id).css({
				"left": px,
				"top": py,
				"position": "absolute",
				"width": width
			});			 
		} else {
			header+= "\" ";
			$("#" + id).css({
				"width": width
			});			
		}
		
		if (visible) {
			header+= " class=\"dataGrid\"><table id=\"dg\" cellpadding=\"0\" " +
				"cellspacing=\"0\" class=\"lastGrid\"><thead class=\"headerGrid\"><tr>" + 
				headerValues;
			$("#" + id).removeClass("cpEsconde");			
		} else {
			$("#" + id).addClass("cpEsconde");
		}
		
		html = header + "</tr></thead><tbody id=\"dataBank\">" + aux + 
			"</tbody></table></div>";
			
		$("#dataBank" + id).empty();
		$("#dataBank" + id).append(aux);
	}
	
	this.getHtm = function () {
		return html;
	}
	
	this.getValueByIndex = function (index, field) {
		return rollValues[index].getFieldValue(field);
	}
	
	this.setValueByIndex = function(index, field, value) {
		rollValues[index].setValue(field, value);
		this.repaint();
	}
	
	this.setPosition = function(x, y) {
		px= x;
		py = y;
		this.repaint();
	}
	
	this.setWidth = function(valor) {
		width = valor;
		this.repaint();
	}	
	
	this.show = function() {
		visible = true;
		this.repaint();
	}
	
	this.hide = function() {
		visible = false;
		this.repaint();
	}
	
	var DataField = function(data) {		
		var values = new Array();
		var fields = new Array();
		
		for(var j = 0; j < data.length; j++) {
			values[data[j][0]] = [data[j][1], data[j][2]];
			fields.push(data[j][0])
		}
				
		this.setValue = function(field, value) {
			values[field][0] = value;
		}
		
		this.setWidth= function(field, value) {
			values[field][1] = value;
		}
		
		this.getFieldValue = function(field) {
			return values[field][0];
		}
		
		this.getWidth = function(field) {
			return values[field][1];
		}
		
		this.getFields = function() {
			return fields;
		}
		
		this.getFieldByIndex = function(index) {
			return fields[index];
		}
		
		this.getSize = function() {
			return fields.length;
		}
	}
}


