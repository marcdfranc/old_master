var pager;
var flag= false;
var statusLine;
var isOpenForPrint = false;

$(document).ready(function() {
	load= function () {		
		pager = new Pager($('#gridLines').val(), 30, "../CadastroServico");
		pager.mountPager();
		if ($("#gridLines").val() != "") {
			statusLine = "<span><label class=\"titleCounter\">Saldo em " + 
				getPipeByIndex($("#gridLines").val(), 0) + ": </label></span>" +
				"<span><label class=\"valueCounter\">" + 
				formatCurrency(getPipeByIndex($("#gridLines").val(), 1)) + "</label></span>";
			$("#counter").empty();
			$("#counter").append(statusLine);
			
			$("#labelSoma").empty();			
			$("#labelSoma").append("Saldo em " + getPipeByIndex($("#gridLines").val(), 2) + ": ");
			
			$("#totalSoma").empty();
			$("#totalSoma").append(formatCurrency(getPipeByIndex($("#gridLines").val(), 3)));
		}
	}
	
	search= function() {
		if ($("#dataInicialIn").val() == "" && $("#dataFinalIn").val() != "") {
			showErrorMessage ({
				width: 400,
				mensagem: "É necessário o preenchimento do campo \"Data Inicial\" para que a busca seja efetuada!",
				title: "Entrada inválida"
			});
		} else if ($("#dataInicialIn").val() != "" && $("#dataFinalIn").val() == "") {
			showErrorMessage ({
				width: 400,
				mensagem: "É necessário o preenchimento do campo \"Data Final\" para que a busca seja efetuada!",
				title: "Entrada inválida"
			});
		} else {
			$.get("../CadastroCc",{
				dataInicial: $("#dataInicialIn").val(),
				unidadeId: $("#unidadeId").val(),
				dataFim: $("#dataFinalIn").val()},
				function(response){
					$('#dataGrid').empty();
					$('#dataGrid').append(response);				
				}
			);
		}
		isOpenForPrint = true;
		return false;
	}
	
	setLiberacao = function() {
		isOpenForPrint = false;
	}
	
	alertVazio = function() {
		showWarning({
			width: 400,
			mensagem: "Não existe conta corrente cadastrada para unidade atual!",
			title: "Entrada inválida"
		});
	}
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
		if ($("#gridLines").val() != "") {
			statusLine = "<span><label class=\"titleCounter\">Saldo em " + 
				getPipeByIndex($("#gridLines").val(), 0) + ": </label></span>" +
				"<span><label class=\"valueCounter\">" + 
				getPipeByIndex($("#gridLines").val(), 1) + "</label></span>";
			$("#labelSoma").empty();
			$("#totalSoma").empty();
			$("#labelSoma").append("Saldo em " + getPipeByIndex($("#gridLines").val(), 2) + ": ");
			$("#totalSoma").append(formatCurrency(getPipeByIndex($("#gridLines").val(), 3)));
			
			$("#counter").empty();
			$("#counter").append(statusLine);
		}
	});
	
	/**
	 * printExtrato
	 * @param {type}  
	 */
	printExtrato = function() {
	 	if ($("#dataInicialIn").val() == "" || $("#dataFinalIn").val() == "") {
			showWarning({
				width: 400,
				mensagem: "É necessário o preenchimento das duas datas para que a busca seja efetuada!",
				title: "Entrada inválida"
			});
		} else if(!isOpenForPrint){
			showWarning({
				width: 400,
				mensagem: "É necessária a execução da busca para impressão!",
				title: "Entrada inválida"
			});
		} else {
			var vlrInicial = "";
			var top = (screen.height - 200)/2;
			var left= (screen.width - 600)/2;
			$("#counter > *").each(function(index, domEle) {
				if (domEle.firstChild.className == "valueCounter") {
					vlrInicial+= domEle.firstChild.textContent;
				}
			});			
			window.open("../GeradorRelatorio?rel=115&parametros=371@" +  $("#unidadeId").val() +
				 "|372@" + vlrInicial + "|373@" + $("#dataInicialIn").val() + "|374@" +
				  addDays($("#dataFinalIn").val(), 1), 'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
		}
	}
});

function editaConta() {
	$("#ccWindow").dialog({
 		modal: true,
 		width: 250,
 		minWidth: 250,
 		show: 'fade',
 		hide: 'clip',
 		buttons: {
 			"Cancelar": function() {
 				$(this).dialog('close');		
			},
 			"Editar" : function () {
 				location.href = 'cadastro_conta_corrente.jsp?state=1&id=' + $('#ccIdEdit').val();
 			}		 			
 		},
 		close: function() {
 			$(this).dialog('destroy');
 		}
 	});
}