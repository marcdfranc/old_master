var item;
var isEdition= false;
var lastIndex= -1;

$(document).ready(function() {
	loadPage = function(isEd){		
		var aux = 0;
		item= new dtGrid("editedsItem", "deletedsItem", "delItem", "edItem", "editItem", true);
		item.setLocalHidden("localItem");		
		item.setLocalAppend("tableItem");		
		item.setIdHidden("rowItem");
		item.addCol("Descrição", "35", "rowDescricao");		
		item.addCol("tipo de Cobrança", "35", "rowCobranca");
		item.addCol("Valor", "10", "rowValor");
		//item.addCol("Conta", "20", "rowCont");
		item.setSequence(false);		
		item.mountHeader(isEd);
		if (isEd) {
			while ($('#itemId' + parseInt(aux)).val() != undefined) {
				item.addIds($('#itemId' + parseInt(aux)).val());
				item.addValue($('#edDescricao' + parseInt(aux)).val());				
				item.addValue($('#edTipo' + parseInt(aux)).val());
				item.addValue($('#edValor' + parseInt(aux++)).val());								
				item.appendTable();
			}
		}
	}
	
	addRowItem= function() {
		if ($('#conta').val() != "-1") {
			if (isEdition) {				
				item.editValue(document.getElementById("conta").value + "@" +
					document.getElementById("conta").text);
				switch ($('#tpCobranca').val()) {
					case 'f':
						item.editValue("Fixa");						
						break;

					case 'h':
						item.editValue("Por Hora");
						break;
						
					case 'q':
						item.editValue("Por Quantidade");
						break;
				}
				item.editValue($('#valorIn').val());
				item.setRowInPosition(lastIndex);
				isEdition= false;
				lastIndex= -1;
			} else {				
				item.addValue(document.getElementById("conta").value);
				switch ($('#tpCobranca').val()) {
					case 'f':
						item.addValue("Fixa");						
						break;

					case 'h':
						item.addValue("Por Hora");
						break;
						
					case 'q':
						item.addValue("Por Quantidade");
						break;
				}
				item.addValue($('#valorIn').val());
			}
			item.appendTable();
			$('#valorIn').val("0.00");
			document.getElementById("conta").selectedIndex= 0;
			document.getElementById("tpCobranca").selectedIndex = 0;			
		} else {
			showErrorMessage ({
				width: 360,
				mensagem: "O campo Conta deve ser preenchido para que possa ocorrer a inserção!",
				title: "Erro"
			});
		}
	}
	
	editItem = function(valueIn) {
		var aux= item.getRow(valueIn);
		var counter = -1;
		var arrayValue = getPart(aux[0], 2).toLowerCase();  
		while(document.getElementById("conta").options[++counter] != undefined) {
			selectValue = document.getElementById("conta").options[counter].text.toLowerCase();
			if (selectValue == arrayValue) {
				document.getElementById("conta").selectedIndex= counter;				
				break;
			}
		}
		counter = -1;
		arrayValue = aux[1]
		while(document.getElementById("tpCobranca").options[++counter] != undefined) {
			selectValue = document.getElementById("tpCobranca").options[counter].text;
			if (selectValue == arrayValue) {				
				document.getElementById("tpCobranca").selectedIndex = counter;
				break;
			}
		}
		
		$('#valorIn').val(aux[2]);
		isEdition= true;
		lastIndex= valueIn;
	}
	
	removeRowItem= function() {
		item.removeData();
	}	
});