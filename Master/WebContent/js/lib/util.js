var BIRT_FRAMESET = "http://localhost:8080/birt-viewer/frameset?__report=";
var BIRT_RUN = "http://localhost:8080/birt-viewer/run?__report=";
var BIRT_PDF = "&__format=pdf";
var BIRT_HTML = "&__format=html";


/**
 * getBirtFrameset
 * @param {type} report, tipo 
 */
getBirtFrameset = function(report, tipo) {
 	return "http://" + window.location.host + "/birt-viewer/frameset?__report="  + report + tipo;
}

/**
 * getBirtRun
 * @param {type} report, tipo 
 */
getBirtRun = function(report, tipo) {
 	return "http://" + window.location.host + "/birt-viewer/run?__report=" + report + tipo;
} 

/**
 * getBirtRun
 * @param {type} valor, posição
 */
function getPart(valor, position) {
	var aux= "";
	var count= 1;
	for (i = 0; i < valor.length ; i++) {
		if (count < position) {
			if (valor.charAt(i)== '@') {
				count++;
			}
		} else {
			count = i;
			break;
		}
	}
	for (i = count ; i < valor.length; i++) {
		if ((valor.charAt(i) != '@')) {
			 aux+= valor.charAt(i);
		} else {
			break;
		}
	}
	return aux;
};


function isEmpty(value) {	
	return (value.length == 0);
}



function getNumber(value) {
	return value.replace(/\D/g,"");
}

function formatCurrency(valor) {
	valor = valor + "";
	var isNegative = valor.substr(0, 1) == "-";
	var er= /\d\.?[\d]{0,2}/;
	var aux = valor.replace(/[,]/, ".");
	var intPart = "";
	var decPart = "";
	aux = aux.replace(/^[^\d]/,"");
	aux = aux.replace(/(\d)([a-zA-Z]*)/, "$1");
	aux = aux.replace(/^[^\d|\.]/,"");
	aux = aux.replace(/(\.)(\.)/, ".");
	aux = aux.replace(/(\d\.)([a-zA-Z]*)/, "$1");
	aux = aux.replace(/(\d\.\d)(\.)/, "$1");
	aux = aux.replace(/(\d\.)(\d{2})(\d*)/,"$1$2");
	aux = aux.replace(/(\d\.)(\d{2})(\.)/,"$1$2");	
	if (!er.test(aux)) {
		aux= aux.substr(0, aux.length - 1);
	}
	intPart = aux.substr(0, aux.indexOf("."));
	intPart = (intPart == "")? aux : intPart;
	if ($.browser.msie) {
		decPart = (aux.indexOf(".") == -1)? "0" : aux.substr(aux.indexOf("."), aux.length -1);
	} else {
		decPart = aux.substr(aux.indexOf("."), aux.length -1);
	}
	decPart = (decPart.length <= 1) ? ".0" : decPart;
	aux= (decPart.length < 3)? intPart + decPart + "0" : intPart + decPart;		 	
	return (isNegative)? "-" + aux : aux;
}

function getStringDate(data){
	return data.getDate() + "/" + (data.getMonth() + 1) + "/" +
		data.getFullYear();		
}

function getToday(){
	var data= new Date();
	var dia = (data.getDate() > 9)? data.getDate() : "0" + data.getDate();	
	var mes = (data.getMonth() > 8)? (parseInt(data.getMonth()) + 1): "0" + 
		(parseInt(data.getMonth()) + 1);
	var ano = data.getFullYear();
	return dia + "/" + mes + "/" + ano;
}

function getHoraAtual() {
	var data = new Date();
	var hora = (data.getHours() > 9)? data.getHours() : "0" + data.getHours();
	var minuto = (data.getMinutes() > 9)? data.getMinutes() : "0" + data.getMinutes();
	return hora + ":" + minuto;
}

function getTime(data) {
	data = new Date(data);
	return zeroToLeft(data.getHours(), 2) + ":" + zeroToLeft(data.getMinutes(), 2);
}

function getDay(data) {
	return data.substr(0, 2);
}

function getMonth(data) {
	data= data.replace(/^(\d{1,2}\/)(\d{1,2})(\/\d{4})/, "$2");
	data = data.replace(/^(0)(\d)/, "$2");
	return data;
}

function getYear(data) {
	data= data.replace(/^(\d{1,2}\/)(\d{1,2}\/)(\d{4})/, "$3");	
	return data;
}

function getMonthYear(){
	data= new Date();
	return parseInt(data.getMonth() + 1) + 
		"/" + parseInt(data.getFullYear());
}

function getIntDay(data) {	
	return parseInt(data.substr(0, 2));
}

function getIntMonth(data) {
	data= data.replace(/^(\d{1,2}\/)(\d{1,2})(\/\d{4})/, "$2");
	if (data.substr(0, 1) == "0") {
		data = data.substr(1, data.length);
	}	 
	return parseInt(data);
}

function getIntYear(data) {
	data= data.replace(/^(\d{1,2}\/)(\d{1,2}\/)(\d{4})/, "$3");
	return  parseInt(data);
}

function addDays(data, days){	
	var ndiasmes="";
	var ldDia = parseInt(getDay(data));
	var ldMes = parseInt(getMonth(data));
	var ldAno = parseInt(getYear(data));
	var ltDia = ldDia;
	var ltMes = ldMes;
	var ltAno = ldAno;

	//31 dias
	if ((ldMes==01)||(ldMes==03)||(ldMes==05)||(ldMes==07)||(ldMes==08)||(ldMes==10)||(ldMes==12)) {
		ndiasmes=31
	} else if ((ldMes==04)||(ldMes==06)||(ldMes==09)||(ldMes==11)) { //30 dias
		ndiasmes=30
	} else { //fevereiro
		//Calcula ano bissexto
		if (((ldAno % 4) == 0) && ((ldAno % 100) == 0)) {
			ndiasmes=29;	
		} else if ((ldAno % 400) == 0){
			ndiasmes=29;		
		} else {
			ndiasmes=28;		
		}
	}
	//incrementa dias
	if ((ldDia + days) <= ndiasmes) {
		ltDia= ldDia + days;
	} else {
		ltDia = parseInt((ldDia+days)%ndiasmes);
		if (parseInt(ldMes +((ldDia+days)/ndiasmes))<=12)	{
			ltMes = parseInt(ldMes +((ldDia+days)/ndiasmes))
		} else{
			ltMes = parseInt((ldMes +((ldDia+days)/ndiasmes)) %12)
			ltAno = parseInt(ldAno + ((ldMes + ((ldDia+days)/ndiasmes))/12))
		}
	}
	return ltDia + "/" + ltMes + "/" + ltAno;
}

/**
 * diferencaDays
 * @param {type} inicio, fim 
 */
function diferencaDays(inicio, fim) {
	var dia = getIntDay(inicio);
	var mes = getIntMonth(inicio) - 1;
	var ano = getIntYear(inicio);
	var dataInicio = new Date(ano, mes, dia);
	dia = getIntDay(fim);
	mes = getIntMonth(fim) - 1;
	ano = getIntYear(fim);
	var dataFim = new Date(ano, mes, dia);	
	var dif = Date.UTC(dataFim.getYear(), dataFim.getMonth(), dataFim.getDate(), 0, 0, 0) - 
		Date.UTC(dataInicio.getYear(), dataInicio.getMonth(), dataInicio.getDate(), 0, 0, 0);
    return trunc(dif / 1000 / 60 / 60 / 24);
}

/**
 * diferencaMonths
 * @param {type} inicio, fim 
 */
function diferencaMonths(inicio, fim) {	
 	return trunc(diferencaDays(inicio, fim)/30, 0);
} 

/**
 * diferencaYear
 * @param {type} inicio, fim 
 */
function diferencaYear(inicio, fim) {
 	return trunc(diferencaMonths(inicio, fim)/12, 0);
}

function addMonths(data, months) {
	var newDay = getIntDay(data);
	var newMonth= getIntMonth(data);
	var newYear= getIntYear(data);
	var aux= "";
	if (months > 12) {
		newYear+= parseInt(months/12);
		months= months%12;
	}	
	if ((newMonth + months) > 12) {		
		newYear++;		
		months-= (12 - newMonth);						
		newMonth= months;		
	} else {
		newMonth+= months;
	}
	aux = formatDate(newDay + "/" + newMonth + "/" + newYear);
	return aux;
}

function formatDate(data) {
	var aux= (getIntDay(data) >= 10)? getIntDay(data) + "/" : "0" + getIntDay(data) + "/";
	aux+= (getIntMonth(data) >= 10)? getIntMonth(data) + "/" + getIntYear(data) : 
		"0" + getIntMonth(data) + "/" + getIntYear(data); 
	return aux; 
}

/**
 * trunc
 * @param {type} valor, aproximacao 
 */
function trunc(valor, aproximacao) {
	var er= /\./;
 	var strAux= valor.toString();
	var intPart = parseInt(strAux.replace(/(\.)(\d)*/, ""));
	var decPart = "";
	if (er.test(valor)){
		decPart = strAux.replace(/(\d*)(\.)(\d*)/, "$3");		
	}
	if (aproximacao == 0) {
		return intPart;		
	} else if(decPart.length < aproximacao) {
		while (decPart.length < aproximacao) {
			decPart+= "0";
		}
		return intPart + "." + decPart;
	} else if (decPart.length == aproximacao) {
		return valor;
	} else {
		strAux = "";
		for(var i = 0; i < aproximacao; i++) {
			strAux+= decPart.charAt(i);
		}
		return intPart + "." + strAux;
	}
}

function round(valor, aproximacao){
	var er= /\./;	
	var strAux= valor.toString();
	var intPart = parseInt(strAux.replace(/(\.)(\d)*/, ""));
	var decPart = "";
	if (er.test(valor)){
		decPart = strAux.replace(/(\d*)(\.)(\d*)/, "$3");		
	}
	var aux = 0;
	strAux= "";
	if (aproximacao == 0 && decPart != "") {
		if (parseInt(decPart.charAt(0)) <= 5) {
			return intPart;			
		} else {
			return ++intPart;
		}
	} else if(decPart.length < aproximacao) {
		while (decPart.length < aproximacao) {
			decPart+= "0";
		}
		return intPart + "." + decPart;
	} else if (decPart.length == aproximacao){
		return valor;
	} else {
		if (parseInt(decPart.charAt(aproximacao)) <= 5) {
			for(var i = 0; i < aproximacao; i++) {
				strAux+= decPart.charAt(i);
			}
			return intPart + "." + strAux;
		} else {			
			for(var i = 0; i < aproximacao; i++) {
				if (i == aproximacao -1) {
					aux= parseInt(decPart.charAt(i));					
					if (++aux == 10) {
						aux= 0;
					}
					strAux+= aux; 
				} else {
					strAux+= decPart.charAt(i);					
				}
			}
			return intPart + "." + strAux;		
		}
	}
}

/**
 * getOperacional
 * @param {float} operacional, cliente, parcela 
 */
function getOperacional(operacional, cliente, parcela) {
 	return parseFloat(operacional) * (parseFloat(parcela) / parseFloat(cliente));
}

function isBissexto(year) {
	var aux= false;
	if ((year%4 == 0) && (year%100 != 0)) {
		aux = true;
	} else if ((year%4 == 0) && (year%100 == 0)) {
		if (year%400== 0) {
			aux= true;
		}
	} 	
	return aux;
}


function getSelectIndex(option, value) {
	for (var i = 0; i < option.length; i++) {
		if (option[i].value == value) {
			return i;
		}
	}
	return 0;
}

function dataHifen(text) {
	ano = "";
	mes = "";
	dia = "";
	if (text != undefined) {
		for(var i=0; i < text.length; i++) {
			if (text.substr(i, 1) != "/") {
				if (dia.length < 2) {
					dia+= text.substr(i, 1);
				} else if(mes.length < 2) {
					mes+= text.substr(i, 1);
				} else if (ano.length < 4) {
					ano+= text.substr(i, 1);
				}
			}
		}		
	}
	return ano + "-" + mes + "-" + dia;
}

function pipeToVirgula(text) {
	var aux = "";
	if (text != undefined) {
		for(var i=0; i<text.length; i++) {
			if (text.substr(i, 1) == "@") {
				aux+= ",";
			} else {
				aux+= text.substr(i, 1);
			}
		}
	}
	return aux;
}

function virgulaToPipe(text) {
	var aux= "";
	for (var i = 0; i < text.length; i++) {
		if (text.substr(i, 1) == ",") {
			aux+= "@";
		} else {
			aux+= text.substr(i, 1); 
		}
	}	
	return aux;
}

function ptVirgulaToPipe(text) {
	return text.replace(";", "@");
}

function ptVirgulaToRealPipe(text) {
	var aux= "";
	for (var i = 0; i < text.length; i++) {
		if (text.substr(i, 1) == ";") {
			aux+= "|";
		} else {
			aux+= text.substr(i, 1); 
		}
	}	
	return aux;
}

function ptVirgulaToVirgula(text) {
	return text.replace(";", ",");
}

function realPipeToPtVirgula(text) {
	var aux= "";
	for (var i = 0; i < text.length; i++) {
		if (text.substr(i, 1) == "|") {
			aux+= ";";
		} else {
			aux+= text.substr(i, 1); 
		}
	}	
	return aux;
}

function toRealPipe(text) {
	text+= "";
	var aux = "";
	for(var i = 0; i < text.length; i++) {
		if (text.charAt(i) != "@") {
			aux+= text.charAt(i) 
		} else {
			aux+= "|";
		}
	}
	return aux;
}

function virgulaToRealPipe(text) {
	text = text + "";
	aux = ""
	for(var i = 0; i < text.length; i++) {
		if (text.charAt(i) != ",") {
			aux+= text.charAt(i);
		} else {
			aux+= "|";
		}
	}
	return aux;
}


function unmountPipe(pipe) {
	aux = new Array();	
	text = "";
	for (var i = 0; i < pipe.length; i++) {		
		if (pipe.substr(i, 1) != "|") {
			text += pipe.substr(i, 1);			
		} else {
			aux.push(text);
			text = "";
		}
	}
	aux.push(text);
	return aux;
}

function getPipeByIndex(pipe, idx) {
	var count = 0;
	var start = 0;
	var text = "";
	if (idx == 0) {
		start = 0;
	} else {
		for(var i = 0; i < pipe.length; i++) {
			if (pipe.charAt(i) == "@") {
				count++;
				if (count == idx) {
					start = i + 1;
					break;
				}
			}
		}		
	}
	for (var i = start; i < pipe.length; i++) {
		if (pipe.charAt(i) != "@") {
			text+= pipe.charAt(i);
		} else {
			break;
		}
	}
	return text;
}

function removeZeroToLeft(text) {
	var aux = "";
	var start = false
	for (var i = 0; i < text.length; i++) {
		if ((text.substr(i, 1) != "0") && (!start)) {
			start = true;
		}
		if (start) {
			aux+= text.substr(i, 1);
		}
	}
	return aux;
}

function zeroToLeft(text, casas) {
	var aux = "";
	text+= "";
	zeroComplete = 0;
	if (text.length < casas) {
		zeroComplete = casas - text.length;		
	}
	for (var i = 0; i < zeroComplete; i++){
		aux+= "0";
	}
	return aux + text;
}

/**
 * calculaAtraso
 * @param {type} valor, aproximacao, taxa, vencimento 
 */
function calculaAtraso(valor, aproximacao, taxa, vencimento) {
 	var aprox = new Date(getIntYear(aproximacao), getIntMonth(aproximacao), getIntDay(aproximacao) - 1);
 	var venc = new Date(getIntYear(vencimento) , getIntMonth(vencimento), getIntDay(vencimento) - 1);
 	var months;
 	if (aprox > venc) {
 		months = parseInt(diferencaMonths(vencimento, aproximacao));
 		if (months > 0) {
 			valor = valor * Math.pow((1 + taxa/100), months);
 		}
 	}
 	return valor;
}

/**
 * calculaAtrasoMora
 * @param {type} valor, aproximacao, mora, taxa, vencimento  
 */
function calculaAtrasoMora(valor, aproximacao, mora, taxa, vencimento ) {
 	var aprox = new Date(getIntYear(aproximacao), getIntMonth(aproximacao), getIntDay(aproximacao) - 1);
 	var venc = new Date(getIntYear(vencimento) , getIntMonth(vencimento), getIntDay(vencimento) - 1);
 	var months;
 	var result = 0;
 	if (aprox > venc) {
 		months = parseInt(diferencaMonths(vencimento, aproximacao));
 		if (months > 0) {
 			result = valor * Math.pow((1 + mora/100), months);
 			valor = result + (valor * (taxa/100));  
 		}
 	}
 	return valor;
}

/**
 * trim
 * @param {type} valor 
 */
function trim(value) {
	var aux = "";
	value = value + aux;	
	for(var i = 0; i < value.length; i++) {
		if (value.charAt(i) != " ") {
			aux+= value.charAt(i);
		}
	}
	return aux;
}

/**
 * lTrim
 * @param {type} valor 
 */
function lTrim(valor) {
 	var aux = "";
 	valor = valor + aux;
 	for(var i = 0; i < valor.length; i++) {
		if (valor.charAt(i) != " ") {
			aux = value.substr(i, valor.length);
			break;
		}
	}
	return aux;
}

/**
 * rTrim
 * @param {type} valor 
 */
function rTrim(valor) {
 	var aux = "";
 	valor+= aux;
 	for(var i = valor.length; i >= 0; i--) {
 		if (valor.charAt(i) != " ") {
 			aux = valor.substr(0, i);
 			break;
 		}
 	}
 	return aux;
}

function getIeVersion() {
	var version = navigator.appVersion;
	version = version.replace("(", "@");
	version = version.replace(")", "@");
	version = version.replace(";", "@");
	version = version.replace(";", "@");
	version = getPipeByIndex(version, 2);
	version = version.replace("MSIE", "");	
	return trim(version);	
}