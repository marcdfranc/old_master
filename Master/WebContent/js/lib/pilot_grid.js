function dtGrid(localEdit, localDeleted, aliasId, aliasEd, editMetod, isEdition){	
	this.header= "";
	this.row= new Array();
	this.idHidden= "";
	this.localHidden= "";
	this.localAppend= "";
	this.localEditeds= localEdit; 
	this.localDeleteds= localDeleted;
	this.aliasDel= aliasId;
	this.aliasEd= aliasEd;
	this.colLength= new Array();	
	this.gridValues= new Array();
	this.gridCols= new Array();
	this.aliases= new Array();
	this.editeds= new Array();	
	this.ids= new Array();
	this.useSequence= false;
	this.lastIndex= 0;
	this.idGrid= "";
	this.sequence= 1;
	this.editMetod = editMetod;
	this.isEditable= isEdition
	this.useException= false;
	
	this.setSequence= function(value) {
		var aux = 1;
		var inConflict= -1;
		if (this.row.length > 0 ) {
			for(var i= 0; i< this.row.length; i++) {
				if (parseInt(this.row[i][0]) == 0) {
					inConflict= i;
				}				
				if (parseInt(this.row[i][0]) > aux) {
					aux= parseInt(this.row[i][0]);
				}
			}
			aux++;
			if (inConflict > -1) {
			if (confirm("O sistema detectou que a contagem dos ítens de " +
				"uma tabela interna inicia-se em \"0\". \n " +
				"click em OK se desejar que a contagem se inicie em \"1\".")) {
					for (var i= 0; i< this.row[inConflict].length; i++) {
						this.gridValues[i]= (i== 0)? aux++ : this.row[inConflict][i]; 
					}
					this.setRowInPosition(inConflict);
					this.appendTable();
					alert("A reordenação dos elementos da tabela foi realizada com sucesso!\n" +
						"Click em salvar para que as alterações tenham efeito.");					
				}
			}						
			this.sequence= aux;
		}
		this.useSequence= value;
	}	
	
	this.setLocalHidden= function(local) {
		this.localHidden= local;
	}
	
	this.setException = function() {
		this.useException= true;
	}
	
	this.setLocalAppend= function(local) {
		this.localAppend= local;
	}
	
	this.setIdHidden= function(id) {
		this.idHidden= id;
	}
			
	this.addCol= function(name, lengthCol, alias){
		this.gridCols[this.gridCols.length]= name;
		this.colLength[this.colLength.length]= lengthCol;
		this.aliases[this.aliases.length]= alias;	
	}
	
	this.useCombo = function(value) {
		var er = /(.*)@(.*)/;		
		return (er.test(value) && (!this.useException));
	}
	
	this.addValue= function(value){
		if ((this.gridValues.length == 0) && (this.useSequence)) {
			this.gridValues[0]= this.sequence++;
		}
		this.gridValues[this.gridValues.length]= value;				
	}
	
	this.addComboValue= function(value, id) {
		if ((this.gridValues.length == 0) && (this.useSequence)) {
			this.gridValues[0]= this.sequence++;
		}
		this.gridValues[this.gridValues.length]= value;
	}
	
	this.editValue= function(value, index) {
		if (index != undefined) {
			this.gridValues[this.gridValues.length]= this.row[index][0];
		}
		this.gridValues[this.gridValues.length]= value;
	}
	
	this.addIds= function(value) {
		this.ids[this.ids.length] = value;
	}
	
	this.setRow= function(){
		this.row[this.row.length]= this.gridValues;
		if(this.row.length -1 == this.ids.length) {
			this.ids[this.ids.length]= "-1";
		}		 		
		this.clearValues();
	}
	
	this.setRowInPosition= function(index) {				
		if (this.ids[index]!= "-1") {
			for(var i= 0; i< this.editeds.length; i++) {
				if (this.editeds[i] == this.ids[index]) {
					this.row[index]= this.gridValues;
					this.clearValues();
					return;
				}
			}
			this.editeds[this.editeds.length]= this.ids[index];
			this.appendEdited();
		}
		this.row[index]= this.gridValues;
		this.clearValues();
	}
			
	this.addRow= function(value) {
		this.row[this.row.length]= value;
	}
	
	this.clearValues= function() {
		this.gridValues= new Array();
	}
	
	this.mountHeader= function(isEd){
		this.header= "<div " + ((isEd && this.isEditable) ? " id=\"dataGrid\" " : "") + 
			" class=\"dataGrid\"><div id=\"gridContent\" class=\"dataGrid\">" +
			"<table id=\"dg\" cellpadding=\"1\" cellspacing=\"0\" class=\"lstGrid\">" +
			"<thead class=\"headerGrid\"><tr> ";			
		for (var i=0; i<this.gridCols.length; i++) {
			this.header+= "<th style=\"width:" + this.colLength[i] + 
				"%\"><div class=\"headerColum\"><p>" + this.gridCols[i] + "</p></div></th>";
		}
		this.header+= "<th style=\"width:2%\"><div class=\"headerColum\"><p>ck</p></div></th>" +
			"</tr></thead><tbody id=\"dataBank\">";	
	}
	
	this.getTable= function(){
		var table= this.header;
		var aux= 0
		for(var i=0; i < this.row.length; i++){
			table+= "<tr id=\"row" + this.idHidden + parseInt(i) + "\" class=\"gridRow\">";			
			for(var j = 0; j < this.gridCols.length ; j++) {
				if (this.useCombo(this.row[i][j])) {
					table+= "<td><label" + ((this.isEditable)? 
					" onClick=\"" + this.editMetod + "(" + i + ")\"" : 
					"") + ">" + getPart(this.row[i][j], 2) + "</label></td> ";
				} else {
					table+= "<td><label" + ((this.isEditable)? 
						" onClick=\"" + this.editMetod + "(" + i + ")\"" : 
						"") + ">" + this.row[i][j] + "</label></td> ";					
				}
			}
			table+= "<td style=\"width: 10px\"><input type=\"checkbox\" id =\"check" +			
				this.idHidden + parseInt(i) + "\"/></td></tr>";
			aux++;
		}
		table+= "</tbody></table></div></div>";
		if (this.row.length == 0){
			return "";
		} else {
			return table;			
		}
	}
	
	this.getHidden= function() {
		var aux= "";
		for (var i = 0; i < this.row.length; i++) {
			for (var j = 0; j < this.gridCols.length; j++) {
				if (this.useCombo(this.row[i][j])) {
					aux += "<input id=\"" + this.aliases[j] + parseInt(i) + "\" name=\"" +
						this.aliases[j] + parseInt(i) + "\" type=\"hidden\" value=\"" +
						getPart(this.row[i][j], 1) + "\" />";					
				} else {
					aux += "<input id=\"" + this.aliases[j] + parseInt(i) + "\" name=\"" +
						this.aliases[j] + parseInt(i) + "\" type=\"hidden\" value=\"" +
						this.row[i][j] + "\" />";
				}
			}			
			aux+= "<input type=\"hidden\" id=\"ck" + this.aliasDel + parseInt(i) + 
					"\" name=\"ck" +  this.aliasDel + parseInt(i) + "\" value=\"" + 
					this.ids[i] + "\"/>"
		}
		aux+= this.getEdited();
		return aux;
	}
	
	this.appendTable = function(){
		if (this.gridValues.length > 0) {
			this.setRow();
		}
		$('#' + this.localAppend).empty();		
		$('#' + this.localAppend).append(this.getTable());
		this.appendHidden();
	}	
	
	this.appendHidden = function(){		
		$('#' + this.localHidden).empty();
		$('#' + this.localHidden).append(this.getHidden());
	}
	
	this.appendEdited= function() {
		var aux= "";
		for(var i=0; i< this.editeds.length; i++) {
			aux+= "<input type=\"hidden\" id=\"" + this.aliasEd + i +
				"\" name=\"" + this.aliasEd + i + "\" value=\"" + this.editeds[i] + "\"/>";						
		}
		$('#' + this.localEditeds).empty();
		$('#' + this.localEditeds).append(aux);	
	}
	
	this.getEdited= function() {
		var aux= "";
		for(var i= 0; i < this.editeds.length; i++) {
			aux+= "<input type=\"hidden\" id=\"" + this.aliasEd + i + "\" name=\"" +
				this.aliasEd + i + "\" value=\"" + this.editeds[i] + "\"/>";
		} 
		return aux;
	}
	
	this.removeRow= function() {
		var aux;
		for(var i= 0; i < this.row.length; i++) {
			if (this.row[i]== "0") {
				this.addDeleted(i);								
				aux= this.row.slice(i + 1, this.row.length);
				this.row= this.row.slice(0, i);
				for(var j= 0; j < aux.length; j++) {
					this.addRow(aux[j]);
				}
				i--;
			}
		}
		this.appendTable();
	}
		
	this.removeIds= function(index) {
		var aux = this.ids.slice(index + 1, this.ids.length);
		this.ids= this.ids.slice(0, index);
		for(var i= 0; i< aux.length; i++) {
			this.addIds(aux[i]);
		}
	}
	
	this.addDeleted= function(index) {
		if (this.ids[index] != "-1") {
			this.removeEdited(this.ids[index]);
			$('#' + this.localDeleteds).append("<input type=\"hidden\" id=\"" + 
				this.aliasDel +	parseInt(this.lastIndex) + "\" name=\"" +
				this.aliasDel +	parseInt(this.lastIndex++) + "\" value=\"" + 
				this.ids[index] + "\"/>");
			this.removeIds(index);
		}			 
	}
	
	this.removeEdited= function(value) {
		var aux;
		for(var i=0; i< this.editeds.length; i++) {
			if (this.editeds[i] == value) {
				aux= this.editeds.slice(i + 1, this.editeds.length);
				this.editeds= this.editeds.slice(0, i);
				for(var j=0; j< aux.length; j++) {
					this.editeds[this.editeds.length] = aux[j];
				}
			}
		}
		this.appendEdited();
	}
	
	this.removeData= function() {
		for(var i= 0; i < this.row.length; i++) {
			if (document.getElementById("check" + this.idHidden + parseInt(i)).checked) {
				this.row[i]= "0";				
			}
		}
		this.removeRow();	
	}
	
	this.parseIndex= function(value) {
		value = value.replace(/^(.*)(\d)/, "$2");		
		return parseInt(value);
	}
	
	this.getRow= function(value) {
		return this.row[value];
	}
	
	this.getLastId= function(value) {
		return this.ids[this.parseIndex(value)];
	}
}
 