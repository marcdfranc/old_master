var linesBank = 0;
var headerBank= "";
var bodyBank= "";
var rowBank;
var countDeletedBank = 0;
var vencimento= "";
var tipoPagamento= "";
var hiddenEd= "";

var linesContact = 0;
var headerContact= "";
var bodyContact= "";
var rowContact;
var countDeletedContact = 0;

var bankValues;
var AgencyValues;
var acountValues;
var ownerValues;

var typeValues;
var descriptyValues;


var isEd= false;
var execMethod;
var countHiddens= 0;
var countHiddensContact= 0;

loadPage= function(type, geralUf, civil, responsavelUf, naturalUf, listSize, infoSize, edVencimento, edTipoPagamento) {
	isEd= type;
	setheaderBank();
	setheaderContact();
	rowBank= new Array();
	rowContact= new Array();
	bankValues= new Array();
	AgencyValues= new Array();
	acountValues= new Array();
	ownerValues= new Array();
	typeValues= new Array();
	descriptyValues= new Array();
	idBankValues = new Array();
	idCountactValues = new Array();
	if(isEd) {
		$('#ufIn').val(geralUf);
		$('#ufResponsavel').val(responsavelUf);
		$('#estadoCivilIn').val(civil);
		$('#vencimento').val(edVencimento);
		$('#tipoPagamento').val(edTipoPagamento);		
		$('#naturalUfIn').val(naturalUf);
		addRowBank(listSize);
		addRowContact(infoSize);
		isEd = false;					
	}
}

setheaderBank= function(){
	headerBank= "<div class=\"dataGrid\"><div id=\"gridContent\" class=\"dataGrid\">" +
				"<table id=\"dg\" cellpadding=\"1\" cellspacing=\"0\" class=\"lstGrid\">" +
				"<thead> "+
				"<tr> " +
				"<th style=\"width: 30%\"><div class=\"headerColum\" ><p>Banco</p></div></th>" + 
				"<th style=\"width: 10%\"><div class=\"headerColum\"><p>Agencia</p></div></th>" +
				"<th style=\"width: 15%\"><div class=\"headerColum\"><p>Numero</p></div></th>" +
				"<th style=\"width: 40%\"><div class=\"headerColum\"><p>Agencia</p></div></th>" +
				"<th style=\"width:2%\"><div class=\"headerColum\"><p>Remover</p></div></th>" +
				"</tr>" +
				"</thead>" +
				"<tbody id=\"dataBank\" >";
}


setRowBank= function(bank, agency, numCont, owner, id) {		
	rowBank[rowBank.length]= "<tr id=\"row" + parseInt(rowBank.length) + "\">" +
			"<td class=\"gridRow\">" + bank + "</td> " +
			"<td class=\"gridRow\">" + agency + "</td>" +
			"<td class=\"gridRow\">" + numCont + "</td> " +
			"<td class=\"gridRow\">" + owner + "</td> " +
			"<td style=\"width: 10px\"><input type=\"checkbox\" id =\"checkBank" +
			parseInt(rowBank.length) + "\" /></td></tr>";
	bankValues[bankValues.length]= bank;		
	AgencyValues[AgencyValues.length]= agency;
	acountValues[acountValues.length]= numCont;
	ownerValues[ownerValues.length]= owner;
	idBankValues[idBankValues.length]= id;
	if (! isEd) {
		includeHiddensBank();			
		linesBank++;
	} 		
}


addRowBank= function(size) {
	var newBank = ""; 
	var newAgency= "";
	var newNumCont= "";
	var newOwner= "";
	var newBankId= "";
	var isValid= true;
	var limit= rowBank.length;
	if (isEd){
		for (var i = limit; i < size; i++) {
			newBank = $('#edBank' + parseInt(i)).val();
			newAgency= $('#edAgency'+ parseInt(i)).val();
			newNumCont= $('#edCont' + parseInt(i)).val();
			newOwner= $('#edOwner' + parseInt(i)).val();
			newBankId= $('#acountId'+ parseInt(i)).val();
			setRowBank(newBank, newAgency, newNumCont, newOwner, newBankId);
		}
	} else {
		if (($.trim($('#agenciaIn').val()) != "") && ($('#banco').val() != "Selecione") &&
		($.trim($('#numeroContaIn').val()) != "")) {
			newBank = document.getElementById("banco").value;
			newAgency= $('#agenciaIn').val();
			newNumCont= $('#numeroContaIn').val();
			newOwner= $('#titularContaIn').val();
			setRowBank(newBank, newAgency, newNumCont, newOwner);
			document.getElementById("banco").selectedIndex= 0; 
			document.getElementById("agenciaIn").value= "";
			document.getElementById("numeroContaIn").value= "";
			document.getElementById("titularContaIn").value= "";	
		} else {
			isValid= false;
		}
	}
	if(isValid) {
		getTableBank();			
	} else {
		alert("Os campos da conta corrente devem ser preenchidos para que possa ocorrer a inserção!");
	}
}

removeRowBank= function() {
	var id = new Array();
	var aux= 0;
	var hiddens= ""
	setChange('c');	
	for (var i=0; i<rowBank.length; i++) {			
		aux= checkExists(i, "bank"); 
		if ( aux != -1){				  
			document.getElementById("checkBank" + parseInt(i)).checked= false;
			rowBank[i]= "";
			bankValues[i]= "";		
			AgencyValues[i]= "";
			acountValues[i]= "";
			ownerValues[i]= "";
			addDeletedBank(i);
			linesBank--;
		}
	}
	getTableBank();
}

addDeletedBank= function(index){
	var aux="";
	if (idBankValues[index]!= "") {
		aux= "<input id=\"delBank" + parseInt(countDeletedBank) + "\" name=\"delBank" +
			parseInt(countDeletedBank++) + "\" type=\"hidden\" value=\"" +
			idBankValues[index] +"\" />";
		$('#deleteds').append(aux);
		idBankValues[index] = "";
	}
}


setHiddensBank= function(id, idValue){
	var aux;
	if (countHiddens > id) {
		$('#rowBank'+ parseInt(id)).val(bankValues[idValue]);
		$('#rowAgency'+ parseInt(id)).val(AgencyValues[idValue]);
		$('#rowCont' + parseInt(id)).val(acountValues[idValue]);
		$('#rowPrincipal'+ parseInt(id)).val(ownerValues[idValue]);
		return "";
	} else if (idBankValues[idValue] == undefined)  {			
		aux= "<input id=\"rowBank" + parseInt(id) + "\" name=\"rowBank" +
			parseInt(id) + "\" type=\"hidden\" value=\"" + bankValues[idValue] +"\" />" +
			"<input id=\"rowAgency" + parseInt(id) + "\" name=\"rowAgency" +
			parseInt(id) + "\" type=\"hidden\" value=\"" + AgencyValues[idValue] +"\" />" +
			"<input id=\"rowCont" + parseInt(id) + "\" name=\"rowCont" +
			parseInt(id) + "\" type=\"hidden\" value=\"" + acountValues[idValue] +"\" />" +
			"<input id=\"rowPrincipal" + parseInt(id) + "\" name=\"rowPrincipal" +
			parseInt(id) + "\" type=\"hidden\" value=\"" + ownerValues[idValue] +"\" />";	
	} else {
		aux= "";
	}
	return aux;		
}

includeHiddensBank= function() {		
	var index= 0;	
	var aux= "";		
	for(var i=0; i<rowBank.length; i++){
		if ((rowBank[i]!= "") && (idBankValues[i] == undefined)){
			aux+= setHiddensBank(index++, i);
		}
	}
	countHiddens= index;
	$('#localBank').append(aux);
}
	
getTableBank= function() {		
	var table = headerBank;
	var index=0;
	var aux= "";		
	for (var i=0; i < rowBank.length ; i++) {
		table+= rowBank[i];
	}
	$('#tableBank').empty();		
	$('#tableBank').append(table + "</tbody></table></div></div>");
	if (linesBank < countHiddens) {
		$('#localBank').empty();
		countHiddens= 0;
		table= "";
		for(var i=0; i<rowBank.length; i++){
			if(rowBank[i] != "") {						
				aux= setHiddensBank(index++, i);
				table+= aux;
			}
		}				
		$('#localBank').append((aux == "")? "": table);				
		countHiddens= linesBank;
	}		
}

setheaderContact= function(){
	headerContact= "<div class=\"dataGrid\"><div id=\"gridContent\" class=\"dataGrid\">" +
					"	<table id=\"dgContato\" cellpadding=\"1\" cellspacing=\"0\" class=\"lstGrid\">" +
					"		<thead> " +
					"			<tr> " +
					"				<th style=\"width: 50%\"><div class=\"headerColum\" ><p>Tipo</p></div></th>" +
					"				<th style=\"width: 50%\"><div class=\"headerColum\"><p>Descrição</p></div></th>" +
					"				<th>Remover</th>" +
					"			</tr> " +
					"		</thead>" +
					"		<tbody id=\"dataContact\" > "; 
}

setRowContact= function(newType, newDescription, id) {
	rowContact[rowContact.length]= "<tr id=\"rowContact" + parseInt(rowContact.length) + "\" >"+
						"<td class=\"gridRow\">"+ newType + "</td>" +
						"<td class=\"gridRow\">" + newDescription + "</td>" +								
						"<td style=\"width: 10px\">" +
						"<input type=\"checkbox\" id =\"checkContact" + 
						parseInt(rowContact.length) + "\"/></td></tr>";
	typeValues[typeValues.length]= newType;
	descriptyValues[descriptyValues.length]= newDescription;
	idCountactValues[idCountactValues.length]= id;
	if (!isEd) {
		includeHiddensContact();
		linesContact++;
	}
}

addRowContact= function(size) {
	var type = ""; 
	var description= "";		
	var isValid= true;
	var idContact= "";
	var limit= rowContact.length; 
	if (isEd){
		for (var i = limit; i < size; i++) {
			type = $('#edType' + parseInt(i)).val();
			description= $('#edDescription'+ parseInt(i)).val();
			idContact= $('#contactId'+ parseInt(i)).val();
			setRowContact(type, description, idContact);
			}
	} else {
		if (($.trim($('#descricaoIn').val()) != "") && ($('#tipoContato').val() != "Selecione")) {
			type = $('#tipoContato').val();
			description= $('#descricaoIn').val();				
			setRowContact(type, description);
			document.getElementById("tipoContato").selectedIndex= 0;
			document.getElementById("descricaoIn").value= "";		
		} else {
			isValid= false;
		}
	}		
	if(isValid) {
		getTableContact();			
	} else {
		alert("Os campos de contato devem ser preenchidos para que possa ocorrer a inserção!");
	}
}
	
removeRowContact= function() {
	var id = new Array();
	var aux= 0;
	var hiddens= "";
	setChange('i');		
	for (var i=0; i<rowContact.length; i++) {			
		aux= checkExists(i, "contact"); 
		if ( aux != -1){				  
			document.getElementById("checkContact" + parseInt(i)).checked= false;
			rowContact[i]= "";
			typeValues[i]= "";		
			descriptyValues[i]= "";
			addDeletedContact(i);			
			linesContact--;
		}
	}
	getTableContact();
	//hiddens= "<input id=\"delId" +  + "\" name=\"rowBank" + 
		//	parseInt(id) + "\" type=\"hidden\" value=\"" + bankValues[idValue] +"\" />" +
}

addDeletedContact= function(index){
	var aux="";
	if (idCountactValues[index]!= "") {
		aux= "<input id=\"delContact" + parseInt(countDeletedContact) + 
			"\" name=\"delContact" + parseInt(countDeletedContact++) + 
			"\" type=\"hidden\" value=\"" + idCountactValues[index] +"\" />";
		$('#deleteds').append(aux);
		idCountactValues[index] = "";
	}
}

setHiddensContact= function(id, idValue){
	var aux;
	if (countHiddensContact > id) {
		$('#rowType'+ parseInt(id)).val(typeValues [idValue]);
		$('#rowDescript'+ parseInt(id)).val(descriptyValues[idValue]);		
		return "";
	} else if (idCountactValues[idValue] == undefined) {
		aux= "<input id=\"rowType" + parseInt(id) +	"\" name=\"rowType" + parseInt(id) +
			"\" type=\"hidden\" value=\"" + typeValues[idValue] + "\"/>" +
			"<input id=\"rowDescript" + parseInt(id) + "\" name=\"rowDescript" + 
			parseInt(id) + "\" type=\"hidden\" value=\"" + descriptyValues[idValue] + "\" /><tr>";				
	} else {
		aux= "";
	}
	return aux;		
}

includeHiddensContact= function() {		
	var index= 0;	
	var aux= "";		
	for(var i=0; i<rowContact.length; i++){
		if ((rowContact[i]!= "") && (idCountactValues[i] == undefined)){
			aux+= setHiddensContact(index++, i);
		}
	}				
	countHiddensContact = index;				
	$('#localContact').append(aux);
}

getTableContact= function() {
	var table = headerContact;
	var index=0;
	var aux= "";		
	for (var i=0; i < rowContact.length ; i++) {
		table+= rowContact[i];
	}
	$('#tableContact').empty();		
	$('#tableContact').append(table + "</tbody></table></div></div>");
	if (linesContact < countHiddensContact) {
		$('#localContact').empty();
		countHiddensContact= 0;
		table= "";
		for(var i=0; i<rowContact .length; i++){
			if(rowContact[i] != "") {					
				aux= setHiddensContact(index++, i);
				table+= aux;
			}
		}
		$('#localContact').append((aux == "")? "" : table);
		countHiddensContact = linesContact;
		
	}		 
}

checkExists= function(id, type) {
	if (type == "bank"){
		if (rowBank[id]== ""){
			return -1;				
		} else {
 			return (document.getElementById("checkBank" + parseInt(id)).checked)? id: -1;				
		}
	} else {
		if (rowContact[id]== "") {
			return - 1
		} else {
			return (document.getElementById("checkContact" + parseInt(id)).checked)? id: -1;				
		} 
	}
}