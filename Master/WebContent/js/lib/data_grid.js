/**
 * @author Marcelo de Oliveira Francisco
 * @projeto Sistema administrativo Master Odontologia & Saúde
 * @data: 21/04/2008
 * @cliente: Master Odontologia & Saúde  
 */


$(document).ready( function(){
	var limitThis;
	var offsetThis;
	var oldOffset;
	var isloaded= false;
	var unit;	
	
	getTopLimits= function() {
		oldOffset= offsetThis;
		offsetThis+= limitThis;
	}
	
	getLowLimits= function() {
		offsetThis-= limitThis;
	}
	
	resetOffset= function(){
		offsetThis= oldOffset;
	}
	
	loadImput= function(){
		limitThis= parseInt(document.getElementById("gridLines").value);
		offsetThis= 0;
		oldOffset= offsetThis;
		isloaded= true;
	}	
	
	clearLimits= function(){
		isloaded= false;
	}
	
	getAtivo = function() {
		isAtivo= "";
		if ((document.getElementById("ativoCheckedTrue").checked) && 
			(document.getElementById("ativoCheckedFalse").checked)) {
			isAtivo= "t";
		} else if (document.getElementById("ativoCheckedFalse").checked) {
			isAtivo= "b";
		} else {
			isAtivo= "a";
		}
		return isAtivo; 
	}
	
	deleteData= function() {
		var elements= "";
		var table= document.getElementById("dataBank");
		var isFirst= true;
		var count= 0;
		for (var i=0; i< table.rows.length; i++) {
			count= i;
			if (document.getElementById("checkDel" + parseInt(i)).checked) {
				if (isFirst) {
					elements+= "checkDel" + parseInt(i) + "= " +
						 $('#checkDel' + parseInt(i)).val();
					isFirst= false;
				}else {
					elements+= "&checkDel" + parseInt(i) + "= " +
						 $('#checkDel' + parseInt(i)).val();
				}
			}
		}
		elements+= "&qtde=" + parseInt(count);
		if (! isFirst) {
			$.ajax({type: "GET", url: "../UnidadeDel", data: elements,
	  				success: function(msg){
								$('#gridContent').empty();
								$('#gridContent').append(msg);
	    						alert( "Registros deletados com sucesso!");
	  						}
				});
		}
	}	
	
	search= function() {
		clearLimits();		
		loadImput();
		var type= document.getElementById("tipoIn");
		if (type.value == "Selecione") {
			$('#type').val("");
		} else {
			$('#type').val(type.value);			
		}
		$.get("../UnidadeGet",{gridLines:limitThis, limit: limitThis, offset: offsetThis, 
				referenciaIn: $("#referenciaIn").val(), 
				tipoIn: $('#type').val() ,
				ativo: getAtivo(),cnpjIn: $("#cnpjIn").val(), isSearch: "s",				
				cidadeIn: $("#cidadeIn").val(), razaoSocialIn: $("#razaoSocialIn").val(), 
				cidadeIn: $("#cidadeIn").val(), cpfIn: $("#cpfIn").val(), 
				nomeIn: $("#nomeIn").val()},
			function (response) {				
				$('#gridContent').empty();
				$('#gridContent').append(response);
			}
		);	
	}
	
	getLimitThis= function() {
		return limitThis;
	}
	
	getOffsetThis= function(){
		return offsetThis
	}
	
	getOldOffset = function(){
		return oldOffset;
	}
	
	getIsloaded= function(){
		return isloaded;		
	}
	
	getUnit= function() {
		return unit;
	}
});