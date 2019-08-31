$(document).ready(function() {
	getCounter();
	
	$("#unidadeId").change(function() {
		getCounter();
	});
	
});

function getCounter() {
	$.get("../Centercob", {
		from: 0,
		unidade: $("#unidadeId").val()
	}, function(response) {
		response = response.split("|");
		var aux = undefined;
		for ( var i = 0; i < response.length; i++) {
			aux = response[i].split("=");			
			$("#" + aux[0]).text(aux[1]);			
		}
	});
}

function geraArquivo() {
	$.get("../Centercob",{
		unidade: $("#unidadeId").val(),
		from : "2"},
		function (response) {
			showOption({
				title: "Geração de Arquivo",
				mensagem: response,
				icone: "w",
				width: 400,
				show: 'fade',
			 	hide: 'clip',
				buttons: {
					"Ok": function() {
						$(this).dialog('close');
					}
				} 
			});
		}
	);
}

function imprimir() {
	$("#imprimeWindow").dialog({
 		modal: true,
 		width: 250,
 		minWidth: 250,
 		show: 'fade',
	 	hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close');
 			},
 			"Imprimir" : function() {
 				showRelatorio();
 				$(this).dialog('close');
 			}
 		},
 		close: function() {
 			$(this).dialog('destroy'); 			
 		}
	 });
}

function showRelatorio() {
	var top = (window.height - 600)/2;
	var left= (window.width - 700)/2;
	left-= 350;
	top-= 300;
	
	var url = "../GeradorRelatorio?rel=216&parametros=505@"
		+ $("#unidadeId").val() + "|506@" + $("#ccobStatusIn").val();	
	window.open(url, 'nova', 'width= 700, height= 600, top= ' + top + ', left= ' + left);
}