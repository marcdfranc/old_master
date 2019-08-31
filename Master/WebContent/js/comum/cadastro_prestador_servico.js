var informacao;
var conta;
var isEdition;

$(document).ready(function(){
	loadPage= function(isEd){
		var aux = 0;
		conta= new dtGrid("editedsBank", "deletedsBank", "delBank", "edBank", "editBank", true);		
		conta.setLocalHidden("localBank");
		conta.setLocalAppend("tableBank");
		conta.setIdHidden("rowBank");
		conta.addCol("Titular", "35", "rowPrincipal");		
		conta.addCol("Banco", "35", "rowBank");
		conta.addCol("Agencia", "10", "rowAgency");
		conta.addCol("Conta", "20", "rowCont");
		conta.setSequence(false);
		conta.mountHeader(isEd);
		
		informacao= new dtGrid("editeds", "deleteds", "delContact", "edContact", "editContact", true);		
		informacao.setLocalHidden("localContact");
		informacao.setLocalAppend("tableContact");
		informacao.setIdHidden("rowContact");
		informacao.addCol("Tipo", "48", "rowType");
		informacao.addCol("Descrição", "48", "rowDescript");
		informacao.addCol("Principal", "14", "rowMain");
		informacao.setException();
		informacao.setSequence(false);		
		informacao.mountHeader(isEd);
		if (isEd) {
			while ($('#edBank' + parseInt(aux)).val() != undefined) {
				conta.addIds($('#acountId' + parseInt(aux)).val());
				conta.addValue($('#edOwner' + parseInt(aux)).val());				
				conta.addValue($('#edBank' + parseInt(aux)).val());
				conta.addValue($('#edAgency' + parseInt(aux)).val());
				conta.addValue($('#edCont' + parseInt(aux++)).val());				
				conta.appendTable();								
			}
			aux= 0;
			while ($('#edDescription' + parseInt(aux)).val() != undefined) {
				informacao.addIds($('#contactId' + parseInt(aux)).val());
				informacao.addValue($('#edType' + parseInt(aux)).val());
				informacao.addValue($('#edDescription' + parseInt(aux)).val());
				informacao.addValue($('#edPrincipal' + parseInt(aux++)).val());
				informacao.appendTable();
			}
		}		
	}
	
	addRowBank= function() {
		if (($('#numeroContaIn').val() != "") && ($('#banco').val() != "-1" && 
				($('#titularContaIn').val() != ""))) {
			if (isEdition) {				
				conta.editValue($('#titularContaIn').val());
				conta.editValue(document.getElementById("banco").value + "@" +
					document.getElementById("banco").text);
				conta.editValue($('#agenciaIn').val());
				conta.editValue($('#numeroContaIn').val());
				conta.setRowInPosition(lastIndex);
				isEdition= false;
				lastIndex= -1;
			} else {				
				conta.addValue($('#titularContaIn').val());
				conta.addValue(document.getElementById("banco").value);
				conta.addValue($('#agenciaIn').val());
				conta.addValue($('#numeroContaIn').val());1
			}
			conta.appendTable();
			$('#titularContaIn').val("");
			$('#agenciaIn').val("");
			$('#numeroContaIn').val("");
			document.getElementById("banco").selectedIndex= 0;
		} else {
			showErrorMessage("Os campos banco, número da conta e titular devem ser preenchidos para que possa ocorrer a inserção!", 
				"Erro", 180, 600, true);
		}
	}
	
	editBank = function(valueIn) {
		var aux= conta.getRow(valueIn);
		var counter = -1;
		var arrayValue = getPart(aux[1], 2).toLowerCase();
		while(document.getElementById("banco").options[++counter] != undefined) {
			selectValue = document.getElementById("banco").options[counter].text.toLowerCase();
			if (selectValue == arrayValue) {
				document.getElementById("banco").selectedIndex= counter;
				break;
			}
		}
		$('#agenciaIn').val(aux[2]);
		$('#numeroContaIn').val(aux[3]);
		$('#titularContaIn').val(aux[0]);
		isEdition= true;
		lastIndex= valueIn;
	}	
	
	removeRowBank= function() {
		conta.removeData();
	}
	
	addRowContact= function(){
		if (($('#descricaoIn').val() != "") && 
			(document.getElementById("tipoContato").selectedIndex > 0)) {
			if (isEdition) {
				informacao.editValue(document.getElementById("tipoContato").value);
				informacao.editValue($('#descricaoIn').val());
				informacao.editValue($('#principalIn').val());				
				informacao.setRowInPosition(lastIndex);
				isEdition= false;
				lastIndex= -1;
			} else {
				informacao.addValue(document.getElementById("tipoContato").value);
				informacao.addValue($('#descricaoIn').val());
				informacao.addValue($('#principalIn').val());				
			}
			informacao.appendTable();
			document.getElementById("tipoContato").selectedIndex= 0;
			document.getElementById("principalIn").selectedIndex= 1;
			$('#descricaoIn').val("");
		} else {
			showErrorMessage("Os campos de contato devem ser preenchidos para que possa ocorrer a inserção!", 
				"Erro", 180, 600, false);
		}
	}
	
	editContact = function(valueIn) {
		var aux = informacao.getRow(valueIn);
		var counter= -1;
		var arrayValue = aux[0].toLowerCase();
		while(document.getElementById("tipoContato").options[++counter] != undefined) {
			selectValue = document.getElementById("tipoContato").options[counter].text.toLowerCase();
			if ((selectValue == arrayValue) || (arrayValue == "site" && selectValue == "pagina web")) {				
				document.getElementById("tipoContato").selectedIndex = counter;
				break;
			}
		}
		$('#descricaoIn').val(aux[1]);
		if (aux[2].toLowerCase() == "sim") {
			document.getElementById("principalIn").selectedIndex = 0;
		} else {
			document.getElementById("principalIn").selectedIndex = 1;
		}
		isEdition= true;
		lastIndex= valueIn;
	}
	
	removeRowContact= function() {
		informacao.removeData();
	}
	
	$('#unidadeId').change(function(){
		if($('#unidadeId').val() == "Selecione") {
			$('#unidadeIn').val("");
		} else {
			$.get("../FuncionarioGet",{unidadeId: getPart($('#unidadeId').val(), 2), from: 0},
				function (response) {
					$('#unidadeIn').val(response);
				}
			);			
		}		
	});	
	
	$('#cepIn').change(function() {
		if ($('#cepIn').val() != "") {
			var req = init();
			var url = "../FuncionarioGet?from=15&cep=" + $('#cepIn').val();
			req.open("GET", url, true);
			req.send(null);
			req.onreadystatechange = function(){
				if (req.readyState == 4) {
					if (req.status == 200) {
						if (req.responseXML.getElementsByTagName("rua")[0].firstChild.nodeValue != "0") {
							
							$('#ruaIn').val(
								req.responseXML.getElementsByTagName("rua")[0].firstChild.nodeValue
							);
							
							$('#bairroIn').val(
								req.responseXML.getElementsByTagName("bairro")[0].firstChild.nodeValue
							);
							
							$('#cidadeIn').val(
								req.responseXML.getElementsByTagName("cidade")[0].firstChild.nodeValue
							);
							
							document.getElementById("ufIn").selectedIndex = getSelectIndex(
								document.getElementById("ufIn").options, 
								req.responseXML.getElementsByTagName("uf")[0].firstChild.nodeValue);
						}
					}
				}
			}
		}
	});
		
	function init() {
    	if (window.XMLHttpRequest) {
    		return new XMLHttpRequest();
    	} else if (window.ActiveXObject) {
    		return new ActiveXObject("Microsoft.XMLHTTP");
    	}
    }
});