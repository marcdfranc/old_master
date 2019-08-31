/**;
 * @author Marcelo de Oliveira Francisco
 */
var requiredStr= "required"
var cnpjStr= "validCnpj"
var cpfStr= "validCpf";
var usernameStr= "validUsername";
var lenghtPage;
var lastId;
var elementShowed;
var elments;
var isFirstValidation= true;
var isShow= false;

function ElementShowedClass (newElement, NewState, appended) {
	this.element= newElement;
	this.state= NewState;
	this.isAppendedNow = appended;
	
	this.getElement= function() {
		return this.element;
	};
	
	this.isAppended= function() {
		return this.isAppendedNow;
	}
	
	this.setAppendIndication= function(indication) {
		isAppendedNow= indication;
	}
	
	this.setElement = function(newElementValue){
		this.element= newElementValue;
	};
	
	this.getState= function(){
		return this.state;
	};	
	
	this.setState = function(newStateValue){
		this.state= newStateValue;
	};	
}

startValidation= function(formElement){	
	elementShowed= new Array(formElement.elements.length);
	lenghtPage= formElement.elements.length;
	lastId= -1;
}

isRealObject = function(textValue){
	var aux= false;
	for(i=0; i < lenghtPage; i++ ) {
		if (elementShowed[i]!= null) {
			if (elementShowed[i].getElement() == textValue){
				aux= true;
				break;
			}			
		}
	}	
	return aux;
}

getId = function(textValue) {
	var i;
	var aux= -1;		
	for(i=0; i<= lastId; i++) 
		if(elementShowed[i].getElement() == textValue) {
			aux= i;
			break;			
		} 
	return aux;
}

addId = function(textValue){
	elementShowed[++lastId] = new ElementShowedClass(textValue, false, true); 
}


validInteger = function(textValue) {
	var aux= /^\d+$/;
	return aux.test(textValue.value);		
}

requiredValidation= function (object) {
	var aux = $.trim(object.value);	
	var classe = object.className;
	classe = classe.replace(/(.*)(required)(.*)/, "$2");
	if ((classe == "required") && (aux== "")) {
		showError(object, "Requerido!", requiredStr );
		return false;
	} else {
		removeError(object, requiredStr);
		return true;		
	}
}

requiredDecimalValidation = function(object) {	
	var aux = $.trim(object.value);
	if ((object.className == "requiredDec") && (aux== "0.00")) {			
		showError(object, "Requerido!", requiredStr );
		return false;
	} else {
		removeError(object, requiredStr);
		return true;
	}
}

validCnpj = function(textValue){
	var position= 0;
	var firstValue= 0;
	var secondValue= 0;
	var oldText = textValue;	
	textValue= textValue.slice(0 ,textValue.length - 2);	
	for(i=5; i>= 1; i--) {
		if (i >= 2)
			firstValue+= parseInt(textValue.charAt(position)) * i;
		secondValue+= parseInt(textValue.charAt((i >= 2)? position++ : position))* (i + 1);		
	}
	for(i=9; i>= 2; i--) {
		if (i >= 2)
			firstValue+= parseInt(textValue.charAt(position)) * i;
		if (i == 2) {
			if (firstValue%11 < 2)
				textValue+= "0";
			else
				textValue+= (11 - (firstValue%11)).toString();
		}
		secondValue+= parseInt(textValue.charAt(++position)) * i;
	}
	textValue+= ((secondValue%11) < 2)? "0" : (11 - (secondValue%11)).toString();
	return ( oldText != textValue) ? false : true;
}

validCpf = function(textValue) {
	var position= 0;
	var firstValue= 0;
	var secondValue= 0;
	var oldText = textValue;
	textValue = textValue.slice(0, textValue.length - 2);
	for(i=10; i>= 1; i--) {
		if (i > 1) {
			firstValue+= parseInt(textValue.charAt(position)) * i;
			secondValue+= parseInt(textValue.charAt(position++)) * (i + 1);			
		} else if (firstValue%11 < 2){
			textValue+="0"; 
			secondValue+= parseInt(textValue.charAt(position++)) * (i + 1);
		} else {
			textValue+= (11 - (firstValue%11)).toString();
			secondValue+= parseInt(textValue.charAt(position++)) * (i + 1);
		}	
	}
	if (secondValue%11 < 2)
		textValue+= "0";
	else {
		textValue+= (11 - (secondValue % 11)).toString();
	}
	
	return ( oldText != textValue) ? false : true;
}

clearPessoa = function(cnpjObject) {
	var aux = cnpjObject.value;	
	aux= aux.replace("/", "");
	aux= aux.replace(".", "");
	aux= aux.replace(".", "");
	aux= aux.replace("-", "");
	return aux;
}


getValid= function(){
	if (isFirstValidation) {
		startValidation(document.getElementById("formPost"));
		isFirstValidation= false;
	}		
}

validForm = function(formElement) {	
	aux= true;
	for (j=0 ; j< formElement.elements.length; j++) {
		switch (formElement.elements[j].id){
			case "cnpjIn": 
				cnpjValidation(formElement.elements[j]);
				teste= j;
				break;
			case "cpfIn": 
				cpfValidation(formElement.elements[j]);
				teste= j;
				break;
			case "loginIn":
				//senhaValid(formElement.elements[j], "senhaConfirmIn");
				//teste= j;
				break;
			case "senhaConfirmIn":
				senhaValid(formElement.elements[j], "senhaIn");
				teste= j;
				break;			
			default: 
				if (formElement.elements[j].className == "required") {
					genericValid(formElement.elements[j]);
					teste= j;				
				} else if(formElement.elements[j].className == "requiredDec") {
					genericDecimalValid(formElement.elements[j]);
					teste= j;
				}
		}		
	}
	aux= getSubmit();
	
	return aux;	
}

validUsername= function(textValue) {
	$.get("../FuncionarioGet",{name: textValue.value , from: 6},
		function (response) {			
			if (response == 1) {
				removeError(textValue, usernameStr);
			} else {
				showError(textValue, "Nome de usuáio já existente!", usernameStr);
			}						
		}
	);	
}

validSenha= function(senha, confirmSenha) {
	return (senha.value == confirmSenha.value);
}

getSubmit = function(){	
	for(i=0; i < elementShowed.length; i++) {
		if (elementShowed[i] != undefined) {
			if (elementShowed[i].getState()){			
				return !elementShowed[i].getState();
			}
		}
	}
	return true;
}



$(document).ready(function() {	

	genericValid = function(object) {
		getValid();
		requiredValidation(object);
	}
	
	genericDecimalValid= function(object) {
		getValid()		
		requiredDecimalValidation(object);
	}
	
	cnpjValidation= function (object) {
		getValid();
		if (object != undefined){
			if (requiredValidation(object)) {
				if (! validCnpj(clearPessoa(object))) {
					showError(object, "Cnpj Inválido!", cnpjStr );
				} else {
					removeError(object, cnpjStr);
				}			
			}			
		}
	}
	
	cpfValidation= function(object) {
		getValid();
		if(object != undefined) {
			if(requiredValidation(object)) {
				if( validCpf(clearPessoa(object))) {
					removeError(object, cpfStr);
				} else {
					showError(object, "Cpf Inválido!", cpfStr );
				}
			}
		}
	}
	
	usernameValidation= function(object) {
		getValid();
		if (object != undefined) {
			if (requiredValidation(object)) {
				validUsername(object);				
			}
		}
	}
	
	senhaValid= function(object, objectCompare) {
		getValid();
		if (object != undefined) {
			if (requiredValidation(object)) {
				var senha= document.getElementById(objectCompare);
				if (object.value != "" && senha.value!= "") {
					if (validSenha(senha, object)) {
						removeError(object, "senha");
						removeError(senha, "senhaConf");
						isShow= false;
					} else {
						if (!isShow) {
							showError(object, "Senhas diferentes!", "senha");
							showError(senha, "Senhas diferentes!", "senhaConf");
							isShow= true;							
						}
					}					
				}				
			}
		}
	}	
	
	requiredTest = function(textValue) {
		return (textValue.className == "required")? true : false;		
	}
	
	formValidation= function(nextPageIten) {
		getValid();
		if (validPage()) {	
			$("form").attr({action: nextPageIten});
		}		
	}
	
	showError = function (object, msg, errorType) {
		var thisId= object.id.replace("In", "");
		var newId= errorType + thisId;
		var pos;
		if (! isRealObject(newId)){
			var bodyError= "<div id=\""+ newId +"\" class=\"errorMsg\"><p>" + msg + "</p></div>";		
			
			$('#'+thisId).append(bodyError);
			
			$('#'+newId).hide();
			addId(newId);
		}
		pos= getId(newId);
		
		if (! elementShowed[pos].getState()) {
			$('#'+newId).slideDown("slow");
			elementShowed[pos].setState(true);			
		} 
	}
	
	removeError = function (object, errorType) {
		var aux= errorType + object.id.replace("In", "");
		var pos= getId(aux);
		if (pos != -1) {		
			if (elementShowed[pos].getState() && (pos != -1)){
				$('#'+aux).slideUp("slow");
				elementShowed[pos].setState(false);			
			}
			
		}	 
	}	
});