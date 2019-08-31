var pager;
var flag= false;
var dataGrid;

$(document).ready(function() {
	load= function () {		
		pager = new Pager($('#gridLines').val(), 30, "../CadastroNotificacao");
		pager.mountPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Visualizar", "viewMsg(");
		dataGrid.addOption("Responder", "responderMsg(");
		dataGrid.addOption("Marcar como Lida", "marcarLida(");	
		dataGrid.addOption("visualizar Envio", "goToCompleto(");
		dataGrid.addOption("Excluir", "excluiMsg(");
	}
	
	appendMenu= function(value){
		dataGrid.expande(value, false);		
	}
	
	getNext = function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if ((pager.limit * pager.currentPage) < pager.recordCount) {
				$.get("../CadastroNotificacao",{
					gridLines: pager.limit , 
					limit: pager.limit, 
					isFilter: "0",
					from: "2", 
					offset: pager.offSet + pager.limit,
					order: getOrderGd(),
					tipoTela: $('#tipoTela').val()},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.nextPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Visualizar", "viewMsg(");
				dataGrid.addOption("Responder", "responderMsg(");
				dataGrid.addOption("Marcar como Lida", "marcarLida(");	
				dataGrid.addOption("visualizar Envio", "goToCompleto(");
				dataGrid.addOption("Excluir", "excluiMsg(");
			}			
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroNotificacao",{
					gridLines: pager.limit, 
					limit: pager.limit,
					isFilter: "0",
					from: "2",
					offset: pager.offSet - pager.limit,
					order: getOrderGd(),
					tipoTela: $('#tipoTela').val()},
					function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);
				});
				pager.previousPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Visualizar", "viewMsg(");
				dataGrid.addOption("Responder", "responderMsg(");
				dataGrid.addOption("Marcar como Lida", "marcarLida(");	
				dataGrid.addOption("visualizar Envio", "goToCompleto(");
				dataGrid.addOption("Excluir", "excluiMsg(");
			}			
		}
	}
	
	search= function() {		
		$.get("../CadastroNotificacao",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1",
			from: "2",
			order: getOrderGd(),
			tipoTela: $('#tipoTela').val()},
			function(response){
				$('#dataBank').empty();
				$('#dataBank').append(response);				
			}
		);
		return false;
	}
	
	renderize= function(value) {
		if (flag) {
			flag= false;
			search();
		} else {
			pager.sortOffSet(value);
			$.get("../CadastroNotificacao",{
				gridLines: pager.limit, 
				limit: pager.limit,
				offset: pager.offSet, 
				isFilter: "0",
				from: "2",
				order: getOrderGd(),
				tipoTela: $('#tipoTela').val()},
			function(response) {
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
			dataGrid = new DataGrid();
			dataGrid.addOption("Visualizar", "viewMsg(");
			dataGrid.addOption("Responder", "responderMsg(");
			dataGrid.addOption("Marcar como Lida", "marcarLida(");	
			dataGrid.addOption("visualizar Envio", "goToCompleto(");			
			dataGrid.addOption("Excluir", "excluiMsg(");
		}
	}
	
	orderModify = function() {
		$.get("../CadastroNotificacao",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: 0, 
			isFilter: "1",
			from: "2",
			order: getOrderGd(),
			tipoTela: $('#tipoTela').val()},
			function(response){
				$('#dataBank').empty();
				$('#dataBank').append(response);				
			});			
		return false;
	}
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
	});	
	
	
	$("input[type='text']").change(function() {
		flag= true;
	});
	
	viewMsg= function(value) {
		$.get("../CadastroNotificacao",{		 
			msgId: value,
			from: "3"},
			function(response) {
				var aux = $(response).find("isOk");
				if (aux == "n") {
					showErrorMessage ({
						mensagem: "Ocorreu um erro durante o processamento da mensagem!",
						title: "Erro"
					});
				} else {					
					aux = "<b>Remetente: </b>" + $(response).find("remetente").text(); 
					$('#visuRemetente').empty();
					$('#visuRemetente').append(aux);
					aux = "<b>Assunto: </b>" + $(response).find("assunto").text();
					$('#visuAssunto').empty();
					$('#visuAssunto').append(aux);
					aux = "<b>Data: </b>" + $(response).find("data").text();
					$('#visuData').empty();
					$('#visuData').append(aux);
					aux = "<b>Hora: </b>" + $(response).find("hora").text(); 
					$('#visuHora').empty();
					$('#visuHora').append(aux);
					$('#visuMsg').val($(response).find("msg").text());
					$("#visualizaWindow").dialog({
				 		modal: true,
				 		width: 789,
				 		heigth: 479,
				 		show: 'fade',
						hide: 'clip',
				 		buttons: {
				 			"Fechar" : function () {
				 				$(this).dialog('close');
				 			},
				 			"Marcar Como Lida" : function (param) {
				 				setLida(value);	
				 				$(this).dialog('close');
							}
						},
				 		close: function() {
				 			$(this).dialog('destroy');
				 		}
					 });
				}
			}
		);	
	}
		
	responderMsg = function (value) {
		$("#responseWindow").dialog({
	 		modal: true,
	 		width: 789,
	 		heigth: 479,
	 		show: 'fade',
			hide: 'clip',
	 		buttons: {
	 			"Enviar" : function () {
	 				$.get("../CadastroNotificacao",{		 
						msgId: value,
						msg: $('#respMsg').val(),
						prioridade: $('#prioridade').val(),
						status: $('#setBaner').val(),
						from: "4"}, 
						function (response) {
							location.href = response;
						}
					);
	 			},
	 			"Cancelar": function () {
	 				$(this).dialog('close');
	 			}
			},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
		 });
	}

	marcarLida = function(value) {
		setLida(value);
	}
	
	goToCompleto = function (value) {
 		location.href = "cadastro_notificacao.jsp?state=1&id=" + value;
	}
	
	excluiMsg= function(value) {
		showOption({
			title: "Exclusão",
			mensagem: "Tem certeza que deseja excluir esta mensagem?",
			icone: "w",
			width: 400,
			show: 'fade',
			hide: 'clip',
			buttons: {
				"Não": function() {
					$(this).dialog('close');
				},
				"Sim": function () {
				 	$.get("../CadastroNotificacao",{
			 			idNotificacao: value,
						from: "6"},
						function (response) {
							location.href = response;
						}
					);
					$(this).dialog('close');
				}
			} 
		});	
	}
		
	$("frame[name=ad_frame]").addClass("cpEsconde");
});