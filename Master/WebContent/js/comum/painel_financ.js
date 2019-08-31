var soma = 0;

$(document).ready(function(){
	
	/**
	 * somatorio
	 * @param {type} obj 
	 */
	somatorio = function(obj) {
	 	if (obj.checked) {
	 		if (getPart(obj.value, 1) == "s") {
	 			soma-= parseFloat(getPart(obj.value, 2));	 				
	 		} else {
	 			soma+= parseFloat(getPart(obj.value, 2));
	 		}
	 	} else {
	 		if (getPart(obj.value, 1) == "s") {
	 			soma+= parseFloat(getPart(obj.value, 2));	 				
	 		} else {
	 			soma-= parseFloat(getPart(obj.value, 2));
	 		}
	 	}
	 	$("#totalSoma").text(formatCurrency(soma));
	}
});