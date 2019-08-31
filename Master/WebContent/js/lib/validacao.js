var objChecar;
var funcaoValidacao;
var defaultErroMsg;
var isFomCheck = false;
var isValido = true;

checar = function (objectElement,functionElement){
	objChecar = objectElement;	
	funcaoValidacao = functionElement;
	var requeridoOk = true;
	var id = objChecar.id;
	if ($(objChecar).hasClass("requerido") && objChecar.value == "") {
		$('#' + id + "requeridovalidMsg").remove();
		$(objChecar).after("<div class=\"erroConteiner\"> " +
			"<p class=\"validMsg\" id=\"" + id + "requeridovalidMsg\">"+
			"Campo Requerido!</p></div>");
		if (isFomCheck) {
			isValido = false;
		}
		requeridoOk = false;
	} else if($(objChecar).hasClass("requerido")) {
		$('#' + id + "requeridovalidMsg").remove();
	} 
	if (requeridoOk) {
		if (!funcaoValidacao(objChecar)) {
			$('#' + id + "validMsg").remove();		
			$(objChecar).after("<div class=\"erroConteiner\"> " +
				"<p class=\"validMsg\" id=\"" + id + "validMsg\">"+
				defaultErroMsg + "</p></div>");
			if (isFomCheck) {
				isValido = false;
			}		
		} else {
			//$('#' + id + "validMsg").remove();
			$('#' + id + "validMsg").parent().remove();
		}
	} 

}

checaForm =  function (form) {
	var field;
	var fieldPassword;
	var fieldCheck;
	var formulario = form;
	isFomCheck = true;
	permitirSubmit = true;
	for(var i = 0; i < formulario.length; i++) {
		field = formulario.elements[i];
		//alert(field.onblur);
		if (field.onblur != undefined) {
			if (field.type != "password") {
				field.onblur();
				if (permitirSubmit && !isValido) {
					permitirSubmit = false;
				}				
			} else {
				if (fieldPassword == undefined) {
					fieldPassword = field;
				} else if (fieldCheck == undefined) {
					fieldCheck = field;
				}				
			}
		} 
	}
	if (fieldCheck != undefined && fieldPassword != undefined) {
		permitirSubmit = checaSubmitPassword(fieldPassword, fieldCheck);	
	}	
	isFomCheck = false;
	return permitirSubmit;
}

checaSubmitPassword= function(senha, confirmId) {
	$('#' + senha.id + "validMsg").remove();
	$('#' + confirmId.id + "validMsg").remove();
	if (senha.value == confirmId.value 
			&& jQuery.trim(senha.value) != "" 
			&& jQuery.trim(confirmId.value) != "") {
		return true;
	} else {
		if (jQuery.trim(senha.value) == "" && jQuery.trim(confirmId.value) == "") {
			defaultErroMsg = "Senha requerida!"
		} else {
			defaultErroMsg = "Senhas diferentes!"			
		}

		$(senha).parent().append("<div class=\"erroConteiner\"> " +
				"<p class=\"validMsg\" id=\"" + senha.id + "validMsg\">"+
				defaultErroMsg + "</p></div>");
		$(confirmId).parent().append("<div class=\"erroConteiner\"> " +
				"<p class=\"validMsg\" id=\"" + confirmId.id + "validMsg\">"+
				defaultErroMsg + "</p></div>")
		return false;
	}
}

checaPassword= function(senha, confirmId) {
	$('#' + senha.id + "validMsg").remove();
	$('#' + confirmId + "validMsg").remove();
	if (senha.value != "" && $('#' + confirmId).val() != "") {
		if (senha.value == $('#' + confirmId).val()) {
			return true;
		} else {
			defaultErroMsg = "Senhas diferentes!"
			$(senha).parent().append("<div class=\"erroConteiner\"> " +
					"<p class=\"validMsg\" id=\"" + senha.id + "validMsg\">"+
					defaultErroMsg + "</p></div>");
			$('#' + confirmId).parent().append("<div class=\"erroConteiner\"> " +
					"<p class=\"validMsg\" id=\"" + confirmId + "validMsg\">"+
					defaultErroMsg + "</p></div>")
			return false;
		}		
	}
}

requerido = function (obj) {
	if (obj.value == "") {
		defaultErroMsg = "Campo Requerido!";
		return false;
	} else {
		return true;
	}
}

CNPJ = function(obj){	
	var position= 0;
	var firstValue= 0;
	var secondValue= 0;
	var oldText = obj.value;	
	var textValue= oldText.slice(0 ,textValue.length - 2);
	if (obj.value != "") {
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
		if (oldText != textValue) {
			defaultErroMsg = "Cnpj Inválido!";
			return false;
		} else {
			return true;			
		}		
	} else {
		return true;
	}
	
}

CPF = function(obj) {
	var position= 0;
	var firstValue= 0;
	var secondValue= 0;
	var oldText = obj.value;
	textValue = oldText.slice(0, textValue.length - 2);
	if (obj.value != "") {
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
		if (oldText != textValue) {
			defaultErroMsg = "Cpf Inválido!";		
			return false;
		} else {
			return true;
		}		
	} else {
		return true;
	}
}

webSite =  function (obj) {	
	var regra = /^([a-zA-Z0-9]-?){2}([a-zA-Z0-9-]){0,23}[a-zA-Z0-9]?\.aero|arpa|asia|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel([.a-zA-z]{2})?$/;
	if (obj.value != "") {
		if (regra.test(obj.value)) {
			return true;
		} else {
			defaultErroMsg = "Site Inválido!";
			return false;
		}		
	} else {
		return true;
	}
}

eMail =  function (obj) {
 	var regra = /^[a-zA-Z0-9!#$%&'*+\-\/=?\`{|}~.^]+@([a-zA-Z0-9]-?){2}([a-zA-Z0-9-]){0,23}[a-zA-Z0-9]?\.aero|arpa|asia|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel([.a-zA-z]{2})?$/;
 	if (obj.value != "") {
		if (regra.test(obj.value)) {
			return true;
		} else {
			defaultErroMsg = "E-mail Inválido!";
			return false;
		}
 	} else {
 		return true; 		
 	}
}

validaLimite =function (objectElement, limite) {
	 texto = objectElement.value;
	 if (texto.length > limite) {
	 	texto = texto.substr(0, texto.length - 1);
	 	objectElement.value = texto;
	 }
	 
}