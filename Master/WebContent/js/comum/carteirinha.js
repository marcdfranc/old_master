
$(document).ready(function() {
	var primeiraVia = false;
	var isLoaded = false;
	var stagio = 0;
	var data;
	var selec;
	loader = new Ext.LoadMask(Ext.getBody(), {msg:"<p>Carregando Dados...</p>", msgCls: "loader"});
	var PRIMEIRO_STAGIO =  "<p>Este assistente irá auxilia-lo na impressão de carteirinhas.</p>" +
		"<p>Siga corretamente as intruções a fim de que sejam geradas as carteirinhas desejadas.</p><br />" +			
		"<blockquote>Primeiramente escolha se deseja que a seleção seja feita somente entre carteirinhas que estejam em sua primeira via.</blockquote>" +
		"<br />";
		
	var CHECK_OLD = "<label >Vias</label><br /><div class=\"checkRadio\">" +
		"<label class=\"labelCheck\">Todas as Carteirinhas</label>" +					
		"<input id=\"viaT\" name=\"via\" type=\"radio\" checked=\"checked\" value=\"t\" />" +
		"<label class=\"labelCheck\" >Primeiras Vias</label>" +
		"<input id=\"viaP\" name=\"via\" type=\"radio\" value=\"p\" /></div>"
		
	var SEGUNDO_STAGIO = "<p>Para finalizar a impressão de carteirinhas é necesário que você selecione os contratos que deseja imprimir</p>"
	
	load = function() {				
		$.get("../Carteirinha",{
				from: "0",
				via: (document.getElementById("viaT").checked)? "t": "p"
			},
			function (response) {
				aux = unmountPipe(response);
				sufixo = "";				
				data = new Array();
				for(var i = 0; i < aux.length; i++) {
					sufixo = getPart(aux[i], 1);
					sufixo = virgulaToRealPipe(sufixo);										
					data.push([sufixo, getPart(aux[i], 2)]);
				}
				$('#cpStore').empty();
				$('#cpStore').removeClass("textBox");
				$('#texto').empty();
				$('#texto').append(SEGUNDO_STAGIO);
				if (isLoaded) {
					selec.popular(data);
					selec.repaint();
				} else {
					selec = new ItemSelector("carteirinha", "Seleção de nomes", "Selecionados",
							"valores", "cpStore", 270, 560);
					selec.init(data);
					isLoaded = true;
				}				
			});
	}

	paraDireita = function() {
		selec.paraDireita();				
	}

	paraEsquerda = function() {
		selec.paraEsquerda();				
	}

	itSelecione = function(value) {
		selec.selecioneItem(value);
	}

	tudoADireita = function() {
		selec.tudoADireita();
	}

	tudoAEsquerda = function() {
		selec.tudoAEsquerda();
	}
		
	avancar = function() {
		if(stagio == 0) {
			stagio = 1;		
			$('#avante').val("Terminar");
			load();
		} else {
			//alert(selec.getValue());
			$.get("../Carteirinha",{
				from: "1",
				usuario: selec.getValue() 
			},
			function (response) {
				if (response == "0") {
					var top = (screen.height - 600)/2;
					var left= (screen.width - 800)/2;
					window.close();
					window.open(BIRT_RUN + "carteirinha.rptdesign" + BIRT_PDF, 'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);					
				} else {
					alert("Ocorreu um erro durante a geração do relatorio");
				}
			});
		}
	}
	
	voltar = function() {
		$('#cpStore').empty();
		$('#cpStore').addClass("textBox");
		$('#cpStore').append(CHECK_OLD);
		$('#texto').empty();
		$('#texto').append(PRIMEIRO_STAGIO);
		$('#avante').val("Avançar >");
		stagio = 0;
	}
	
	$(this).ajaxStart(function(){  
		loader.show();   		  
 	});	

	$(this).ajaxStop(function(){  
		loader.hide();   		  
 	});	
	
	cancelar = function() {
		window.close();
	}
});

