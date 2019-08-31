var index;
$(document).ready(function() {
	index = $("#startIndex").val();
	
	load = function () {
		var htm = "";
		var indexNew = 0;
		$("#dataBank >*").each(function(ind, domEle) {
			if (ind % 2 != 0) {				
				htm+= getRowForDel(indexNew , indexNew);
				indexNew++;
			}		
		});
		$("#dataBank").empty();
		$("#dataBank").append(htm);
		$("#setorIn").focus();
	}
	
	loadDescription = function () {
		if ($("#servicoRefIn").val() != "" && $("#setorIn").val()) {
			$.get("../CadastroPlano",{			
				referencia: $("#servicoRefIn").val(),
				setor: $("#setorIn").val(),
				from : "3"},
				function (response) {				
					$("#servicoIn").val(getPart(response, 1));
					$("#especialidade").val(getPart(response, 2));
				}
			);
		}
	}
	
	addRowServico = function () {
		$("#gridLines").remove();
		var last = $("#dataBank").html();
		var htm = getRowMonted(index);
		if (htm != "") {
			htm = last + htm;
			$("#dataBank").empty();
			$("#dataBank").append(htm);
			
			$("#servicoRefIn").val("");		
			$("#especialidade").val("");
			$("#servicoIn").val("");
			$("#qtdeIn").val("1");
			$("#servicoRefIn").focus();
			index++;
		}
	}
	
	removeRowServico = function () {
		var htm = "";
		var indexNew = 0;
		$("#dataBank >*").each(function(ind, domEle) {
			if (document.getElementById("checkrowTabela" + ind).checked) {
				index--;
				indexNew++;
			} else {
				htm+= getRowForDel(ind - indexNew , ind);
			}
		});
		$("#dataBank").empty();
		$("#dataBank").append(htm);
		$("#servicoRefIn").focus();
	}
	
	$("input").keypress(function (e) {
		if (e.which == 13) {
			addRowServico();
		}
	});
	
	getRowMonted = function (value) {
		var seletor = document.getElementById("setorIn");
		if ((seletor.value == "") || ($("#servicoRefIn").val() == "") 
				|| ($("#especialidade").val() == "") || ($("#servicoIn").val() == "")
				|| ($("#qtdeIn").val() == "")) {
			return "";
		}
		var htm = "<tr class=\"gridRow\" id=\"line" + value + "\" name=\"line" + value +
			"\" ><td><label id=\"rowCodigo" + value + "\" name=\"rowCodigo" + 
			value + "\" >" + $("#servicoRefIn").val() + "</label></td>";
			
		htm += "<td><label id=\"rowSetor" + value + "\" name=\"rowSetor" + value + "\" >";
		switch (seletor.value) {
			case 'o':
				htm += "Odontológica</label></td>";
				break;

			case 'l':
				htm += "Laboratorial</label></td>";
				break;
				
			case 'm':
				htm += "Médica</label></td>";
				break;
				
			case 'h':
				htm += "Hospitalar</label></td>";
				break;
		}	  
		htm += "<td><label id=\"rowEspecialidade" + value + "\" name=\"rowEspecialidade" + value + 
			"\" >" + $("#especialidade").val() + "</label></td>";
			
		htm += "<td><label id=\"rowServico" + value + "\" name=\"rowServico" + value + "\" >" + 
			$("#servicoIn").val() +	"</label></td>";
		
		htm += "<td><label id=\"rowQtde" + value + "\" name=\"rowQtde" + value + "\" >" + 
			$("#qtdeIn").val() + "</label></td>";
			
		htm += "<td style=\"width: 10px;\"><input id=\"checkrowTabela" + value + 
			"\" name=\"checkrowTabela" + value + "\" type=\"checkbox\"/></td></tr>";
		
		return htm;
	} 
	
	getRowForDel = function (value, indexRow) {
		var htm = "<tr class=\"gridRow\" id=\"line" + value + "\" name=\"line" + value +
			"\" ><td><label id=\"rowCodigo" + value + "\" name=\"rowCodigo" + 
			value + "\" >" + $("#rowCodigo" + indexRow).text() + "</label></td>";
			
		htm += "<td><label id=\"rowSetor" + value + "\" name=\"rowSetor" + value + "\" >" +
			$("#rowSetor" + indexRow).text() + "</label></td>";
			
		htm += "<td><label id=\"rowEspecialidade" + value + "\" name=\"rowEspecialidade" + value + 
			"\" >" + $("#rowEspecialidade" + indexRow).text() + "</label></td>";
			
		htm += "<td><label id=\"rowServico" + value + "\" name=\"rowServico" + value + "\" >" + 
			$("#rowServico" + indexRow).text() + "</label></td>";
		
		htm += "<td><label id=\"rowQtde" + value + "\" name=\"rowQtde" + value + "\" >" + 
			$("#rowQtde" + indexRow).text() + "</label></td>";
			
		htm += "<td style=\"width: 10px;\"><input id=\"checkrowTabela" + value + 
			"\" name=\"checkrowTabela" + value + "\" type=\"checkbox\"/></td></tr>";
		
		return htm;
	}
	
	removeRowForEdit = function () {
		var htm = "";
		var indexNew = 0;
		var delAppend = "";
		$("#gridLines").remove();
		$("#dataBank >*").each(function(ind, domEle) {
			if (document.getElementById("checkrowTabela" + ind).checked) {
				index--;
				delAppend = "<input id=\"delConfig" + indexNew + "\" name=\"delConfig" +
					indexNew + "\" type=\"hidden\" value=\"" + 
					$("#rowCodigo" + ind).text() + "\"/>";
				$("#deletedsContent").append(delAppend);
				indexNew++;
			} else {
				htm+= getRowForDel(ind - indexNew , ind);
			}
		});
		$("#dataBank").empty();
		$("#dataBank").append(htm);
		$("#servicoRefIn").focus();
	}
	
	/**
	 * saveConfig
	 * @param {type}  
	 */
	saveConfig = function() {
		var pipe = "";
	 	$('#dataBank >*').each(function (ind, domEle) {
	 		if (ind == 0) {
	 			pipe += $("#rowCodigo" + ind).text() + "@" + $("#rowQtde" + ind).text();
	 		} else {
	 			pipe += "|" + $("#rowCodigo" + ind).text() + "@" + $("#rowQtde" + ind).text();
	 		}
	 	});
	 	
	 	$.get("../CadastroPlano",{
	 		codigo: $("#codigoIn").val(),
			pipe: pipe,
			from : "4"},
			function (response) {				
				location.href = '../error_page.jsp?errorMsg=' + response +  
				'&lk=application/plano.jsp';
			}
		);
	}
	
	saveEdition = function () {
		var delPipe = "";
		var pipe = "";
		$('#deletedsContent >*').each(function (ind, domEle) {
			if (ind == 0) {
				delPipe+= domEle.value;
			} else {
				delPipe+= "|" + domEle.value;
			}
		});
		
		$('#dataBank >*').each(function (ind, domEle) {
	 		if (ind == 0) {
	 			pipe += $("#rowCodigo" + ind).text() + "@" + $("#rowQtde" + ind).text();
	 		} else {
	 			pipe += "|" + $("#rowCodigo" + ind).text() + "@" + $("#rowQtde" + ind).text();
	 		}
	 	});
		
		$.get("../CadastroPlano",{
	 		codigo: $("#codigoIn").val(),
	 		delPipe: delPipe,
			pipe: pipe,
			from : "5"},
			function (response) {				
				location.href = '../error_page.jsp?errorMsg=' + response +  
				'&lk=application/plano.jsp';
			}
		);
	}
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
	});
});