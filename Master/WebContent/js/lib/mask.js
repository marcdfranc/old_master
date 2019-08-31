/**
 * @author: Marcelo de Oliveira Francisoco
 * @cliente: Master Odontologia & Saúde
 * @data 15/03/2008 
 */


$(document).ready(function() {
	/*$("input[type='text']").blur(function() {
		if ((this.getAttribute("onKeyDown")== "mask(this, decimalNumber);") && (this.value != "")) {			
			this.value = formatDecimal(this.value);			
		} else if (this.getAttribute("onKeyDown")== "mask(this, decimalNumber);") {
			this.value+= "0.00";	
		} 						
	});*/
	
	$("input[onKeyDown*='decimalNumber']").blur(function() {
		if (this.value != "") {			
			this.value = formatDecimal(this.value);			
		} else {
			this.value+= "0.00";	
		} 						
	});
	
	/*$("textArea").keydown(function() {				
		count = 0;		
		if (!$.browser.msie) {						
			for(var i= 0; i < this.value.length; i++) {
				if (this.value[i] == "\n") {
					count = 0;					
				} else {
					count++;
				}
			}
			if (this.cols - count == 0) {
				this.value+= "\n";
			}
		}
	});*/
	
	$("input[onKeyDown*='dateType']").datepicker({
		dayNamesMin: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'],
		monthNames: ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 
			'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'],
		dateFormat: 'dd/mm/yy',		
		yearRange: '1935:2050',
		onClose: function(dateText, inst) {
			if ($("#" + inst.id).hasClass("required")) {
				genericValid(inst.input[0]);
			}
		}
	});
	
	$("input[onKeyDown*='typeDate']").datepicker({
		dayNamesMin: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'],
		monthNames: ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 
			'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'],
		dateFormat: 'dd/mm/yy',
		changeYear: true,
		yearRange: '1935:2050',
		onClose: function(dateText, inst) {
			if ($("#" + inst.id).hasClass("required")) {
				genericValid(inst.input[0]);
			}
		}		 
	});	
	// 2 of 5
});

var objectMask;
var objectFunction;
var intPart= "";
var decPart= 0;


function mask(objectElement,functionElement){
	objectMask=objectElement;
	objectFunction=functionElement;
	setTimeout("execMask()",1);
	return functionElement;
}

function execMask(){
	objectMask.value=objectFunction(objectMask.value);
}

function onlyNumber(elementObject){	
	return elementObject.replace(/\D/g,"");
}

function onlyInteger(elementObject) {
	return elementObject.replace(/[^\d]/, "");
}

function decimalNumber(elementObject) {	
	var er= /\d\.?[\d]{0,2}/;
	var aux="";	
	elementObject= elementObject.replace(/[,]/, ".");
	elementObject = elementObject.replace(/^[^\d]/,"");
	elementObject= elementObject.replace(/(\d)([a-zA-Z])/, "$1");
	elementObject = elementObject.replace(/^[^\d|\.]/,"");
	elementObject= elementObject.replace(/(\.)(\.)/, ".");
	elementObject= elementObject.replace(/(\d\.)([a-zA-Z])/, "$1");
	elementObject= elementObject.replace(/(\d\.\d)(\.)/, "$1");
	elementObject = elementObject.replace(/(\d\.)(\d{2})(\d)/,"$1$2");
	elementObject = elementObject.replace(/(\d\.)(\d{2})(\.)/,"$1$2");
	if (!er.test(elementObject)) {
		elementObject= elementObject.substr(0, elementObject.length - 1);
	}	
	return elementObject;
}

function formatDecimal(elementObject) {
	var er2= /\d\.$/;
	var er3= /\d\.\d{2}/;
	var er4= /\d\.\d{1}/;
	var aux= "";
	if (!er3.test(elementObject)) {
		if (er2.test(elementObject)) {
			elementObject+= "00";
		} else if (er4.test(elementObject)) {
			elementObject+= "0";
		} else {
			elementObject+= ".00";
		}
	}	
	if (aux.length > 2) {
		aux= aux.substr(0,1);
	}	
	return elementObject;
} 

function removeMltiplePoints(elementObject) {
	aux= 0;
	strReturn= "";
	pointFinded= 3;
	startCount= false;
	for(i=0; i<elementObject.length; i++) {
		strReturn+= elementObject.charAt(i);
		if (elementObject.charAt(i)=="."){
			aux++;
			startCount= true;
			if(aux > 1) {
				pointFinded++;
				strReturn= strReturn.substr(0, strReturn.length-1);
			}
		}
		if(startCount){
			pointFinded--;
			if (pointFinded== 0){
				return strReturn;				
			}
		}
	}
	return strReturn;
}

function cpf(elementObject){	
	elementObject=elementObject.replace(/\D/g,"");	
	elementObject=elementObject.replace(/(\d{3})(\d)/,"$1.$2");	 
	elementObject=elementObject.replace(/(\d{3})(\d)/,"$1.$2");	
	elementObject=elementObject.replace(/(\d{3})(\d{1,2})$/,"$1-$2");	
	if(elementObject.length > 14)	{
		elementObject= elementObject.substr(0,14);
	}
	return elementObject;
}

function cep(elementObject){	
	elementObject=elementObject.replace(/D/g,"");	
	elementObject=elementObject.replace(/^(\d{5})(\d)/,"$1-$2"); 
	if(elementObject.length > 9) {
		elementObject= elementObject.substr(0,9);
	} 
	return elementObject;
}

function comboMask(object, element){
	switch (document.getElementById(element).value){		
		case "fone residencial":
		case "fone comercial":
		case "fone recado":
		case "fax":
		case "celular":
			mask(object, fone);
			break;			
		case "site":
			mask(object, site);
			break;
	}	
}

function clearNext(next) {
	document.getElementById(next).value= "";
}


function cnpj(elementObject){	
	elementObject=elementObject.replace(/\D/g,"");	
	elementObject=elementObject.replace(/^(\d{2})(\d)/,"$1.$2");	
	elementObject=elementObject.replace(/^(\d{2})\.(\d{3})(\d)/,"$1.$2.$3");	 
	elementObject=elementObject.replace(/\.(\d{3})(\d)/,".$1/$2");	
	elementObject=elementObject.replace(/(\d{4})(\d)/,"$1-$2");
	if(elementObject.length > 18) {
		elementObject= elementObject.substr(0,18);
	}
	return elementObject;
}

function onlyDate(elementObject) {
	er= /^\d{2}\/\d{2}\/\d{4}/;
	if (er.test(elementObject)) {
		return elementObject;
	}	
	elementObject=elementObject.replace(/\D/g,"");
	elementObject= elementObject.replace(/^[^0-3]/, "");
	elementObject= elementObject.replace(/^(3)([^0-1])/, "$1");	
	elementObject= elementObject.replace(/^(\d{2})(\d)/, "$1/$2");	
	elementObject= elementObject.replace(/^(\d{2})(\/[^0-1])/, "$1");
	elementObject= elementObject.replace(/^(\d{2})(\/1)([^0-2])/, "$1$2");
	elementObject= elementObject.replace(/^(\d{2})(\/0)([^1-9])/, "$1$2");
	elementObject= elementObject.replace(/^(\d{2})\/(\d{2})(\d)/, "$1/$2/$3");
	elementObject= elementObject.replace(/^(\d{2}\/)(\d{2})(\/[^1-2])/, "$1$2");
	elementObject= elementObject.replace(/^(\d{2}\/)(\d{2}\/2)([^0])/, "$1$2");
	elementObject= elementObject.replace(/^(\d{2}\/)(\d{2}\/1)([^9])/, "$1$2");
	elementObject= elementObject.replace(/^(\d{2}\/)(\d{2}\/20)([^0-2])/, "$1$2");
	elementObject= elementObject.replace(/^(\d{2}\/)(\d{2}\/19)([^2-9])/, "$1$2");
	if(elementObject.length > 10) {
		elementObject= elementObject.substr(0,10);
	}
	return elementObject;
}

function dateType(elementObject){
	er= /^\d{2}\/\d{2}\/\d{4}/;
	if (er.test(elementObject)) {
		return elementObject;
	}	
	elementObject=elementObject.replace(/\D/g,"");
	elementObject= elementObject.replace(/^[^0-3]/, "");
	elementObject= elementObject.replace(/^(3)([^0-1])/, "$1");	
	elementObject= elementObject.replace(/^(\d{2})(\d)/, "$1/$2");	
	elementObject= elementObject.replace(/^(\d{2})(\/[^0-1])/, "$1");
	elementObject= elementObject.replace(/^(\d{2})(\/1)([^0-2])/, "$1$2");
	elementObject= elementObject.replace(/^(\d{2})(\/0)([^1-9])/, "$1$2");
	elementObject= elementObject.replace(/^(\d{2})\/(\d{2})(\d)/, "$1/$2/$3");
	elementObject= elementObject.replace(/^(\d{2}\/)(\d{2})(\/[^1-2])/, "$1$2");
	elementObject= elementObject.replace(/^(\d{2}\/)(\d{2}\/2)([^0])/, "$1$2");
	elementObject= elementObject.replace(/^(\d{2}\/)(\d{2}\/1)([^9])/, "$1$2");
	elementObject= elementObject.replace(/^(\d{2}\/)(\d{2}\/20)([^0-2])/, "$1$2");
	elementObject= elementObject.replace(/^(\d{2}\/)(\d{2}\/19)([^2-9])/, "$1$2");
	if(elementObject.length > 10) {
		elementObject= elementObject.substr(0,10);
	}
	return elementObject;
}

function typeDate(elementObject) {
	return dateType(elementObject);
}

function tipoHora(elementObject) {
	elementObject=elementObject.replace(/\D/g,"");
	elementObject= elementObject.replace(/^[^0-2]/, "");
	elementObject= elementObject.replace(/^(2)([^0-3])/, "$1");
	elementObject= elementObject.replace(/^(0)(^0)/, "$1");
	elementObject= elementObject.replace(/^(\d{2})(\d)/, "$1:$2");
	elementObject= elementObject.replace(/^(\d{2})(:[^0-5])/, "$1");
	if (elementObject.length > 5) {
		elementObject = elementObject.substr(0,5);
	} 
	return elementObject;	
}

function fone(elementObject){
	elementObject=elementObject.replace(/\D/g,"");		
	elementObject=elementObject.replace(/^(\d\d)(\d)/g,"($1) $2");	
	elementObject=elementObject.replace(/(\d{4})(\d)/,"$1-$2");
	if(elementObject.length > 14) {
		elementObject= elementObject.substr(0,14);
	}
	return elementObject;
}

function site(elementObject){	
	elementObject=elementObject.replace(/^http:\/\/?/,"")
	dominio=elementObject
	caminho=""
	if(elementObject.indexOf("/")>-1){
		dominio=elementObject.split("/")[0];
		caminho=elementObject.replace(/[^\/]*/,"");
		dominio=dominio.replace(/[^\w\.\+-:@]/g,"");
		caminho=caminho.replace(/[^\w\d\+-@:\?&=%\(\)\.]/g,"");
		caminho=caminho.replace(/([\?&])=/,"$1");		
	}
	if(caminho!="") {
		dominio=dominio.replace(/\.+$/,"");
		elementObject="http://"+dominio+caminho
	}
	return elementObject
}


