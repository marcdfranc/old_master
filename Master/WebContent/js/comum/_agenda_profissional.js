var date = new Date();
var d = date.getDate();
var m = date.getMonth();
var y = date.getFullYear();
var calendar;

$(document).ready(function() {
	calendar = $('#calendar').fullCalendar({
		timeFormat: 'h(:mm)',
		height: 500,
		theme: true,
		header: {
			left: 'prev,next today',
			center: 'title',
			right: 'month,agendaWeek,agendaDay'
		},
		selectable: true,
		selectHelper: true,
		select: function(start, end, allDay) {
			addEvento(start, end, allDay);
		},
		eventDrop: function(event, dayDelta, minuteDelta, allDay, revertFunc, view) {
			ediatarEvento(event, dayDelta, minuteDelta, revertFunc, view);
	    },
		eventResize: function(event, dayDelta, minuteDelta, revertFunc, jsEvent, ui, view ) { 
			ediatarEvento(event, dayDelta, minuteDelta, revertFunc, view);
		},
		eventClick: function( event, jsEvent, view ) { 
			visualizaEvento(event);
		},
		editable: true,
		//height: 400,
		from: "0",
		events: "../CadastroAgenda?id=" + $("#idProfissional").val()
	});	
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
	});
});


function addEvento(start, end, allDay) {
	var datas = formatDate(start.getDate() + "/" + (start.getMonth() + 1) + "/" + start.getFullYear());
	$('#inicio').val(datas);
	
	datas = formatDate(end.getDate() + "/" + (end.getMonth() + 1) + "/" + end.getFullYear());	
	$('#fim').val(datas);
	
	datas = zeroToLeft(start.getHours(), 2) + ":" + zeroToLeft(start.getMinutes(), 2);
	$('#horaInicio').val(datas);
	
	datas = zeroToLeft(end.getHours(), 2) + ":" + zeroToLeft(end.getMinutes(), 2);
	$('#horaFim').val(datas);	
	
	$("#windowAgenda").dialog({
 		modal: true,
 		width: 419,
 		minWidth: 300,
 		show: 'fade',
		hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close'); 				
 			},
 			"Salvar": function () {
				$.get("../CadastroAgenda", {
					from: '1',
					codigo: "-1",
					descricao: $('#descricao').val(),
					inicio: $('#inicio').val(),
					horaInicio: $('#horaInicio').val(),
					fim: formatDate($('#fim').val()),
					horaFim: $('#horaFim').val(),
					mudaObs: 's',
					obs: $('#obs').val(),
					id: $('#idProfissional').val()},
					function(response) {
						if (response == "0") {
							location.href = '../error_page.jsp?errorMsg=Evento cadastrado com sucesso!' + 
								'&lk=application/agenda_profissional.jsp?id=' + $('#idProfissional').val();
						} else {
							showErrorMessage({
								width: 400,
								mensagem: "Não foi possível cadastrar o evento devido a um erro interno!",
								title: "Erro de Cadastro"
							});
						}						
						$(this).dialog('close');
					}
				);
				//alert(formatDate($('#inicio').val()));
 			}
 		},
 		close: function() {
 			$(this).dialog('destroy');
 		}
 	});
}

function travaJanela() {
	//$('#descricao').attr({"readonly" : "readonly"});
	$('#inicio').attr({"readonly" : "readonly"});
	//$('#horaInicio').attr({"readonly" : "readonly"});
	$('#fim').attr({"readonly" : "readonly"});
	//$('#horaFim').attr({"readonly" : "readonly"});
	$('#diaTodo').attr({"readonly" : "readonly"});
}

function liberaJanela() {
	$('#descricao').removeAttr("readonly");
	$('#inicio').removeAttr("readonly");
	$('#horaInicio').removeAttr("readonly");
	$('#fim').removeAttr("readonly");
	$('#horaFim').removeAttr("readonly");
	$('#diaTodo').removeAttr("readonly");
}

function limparJanela() {
	$('#descricao').val("");
	$('#inicio').val("");
	$('#horaInicio').val("");
	$('#fim').val("");
	$('#horaFim').val("");
	
}

function carregarJamela(json) {
	id = json.id;
	descricao = json.title;	
	$('#descricao').val(json.title);
	$('#inicio').val(json.start);
	$('#horaInicio').val(trim(json.horaStart));
	$('#fim').val(json.end);
	$('#horaFim').val(trim(json.horaEnd));
	$('#obs').val(json.obs);
	travaJanela();
	//alert(json.id);
	$("#windowAgenda").dialog({
 		modal: true,
 		width: 419,
 		minWidth: 300,
 		show: 'fade',
		hide: 'clip',
 		buttons: {
 			"Fechar" : function () {
 				$(this).dialog('close');
 			},
 			"Editar": function() {
 				alert('em manutenção!!');
 				$(this).dialog('close');
				$.getJSON("../CadastroAgenda", {
					from: "2",
					id: id,
					descricao: $('#descricao').val(),
					inicio: $('#inicio').val(),
					horaInicio: $('#horaInicio').val(),
					fim: formatDate($('#fim').val()),
					horaFim: $('#horaFim').val(),
					mudaObs: 's',
					obs: $('#obs').val()
				}, function(response) {
					if (response == "0") {
						location.href = "../error_page.jsp?errorMsg=Evento editado com sucesso!" + 
						"&lk=application/agenda_profissional.jsp?id=" + $('#idProfissional').val();
					} else {
						location.href = "../error_page.jsp?errorMsg=Não foi possível editar este evento devido a um erro interno!" + 
						"&lk=application/agenda_profissional.jsp?id=" + $('#idProfissional').val();
					}
				});			
			}
 					
 		},
 		close: function() {
 			liberaJanela();
 			limparJanela();
 			$(this).dialog('destroy');
 		}
 	});
}

function visualizaEvento(evento) {
	$.get("../CadastroAgenda", {
		from: '3',
		id: evento.id},
		function(response) {
			carregarJamela(response);
		}
	);
}

function ediatarEvento(event, dayDelta, minuteDelta, revertFunc, view) {	
	showOption({
		title: "Bloqueio",
		mensagem: "Tem certeza que deseja mudar o evento \"" + event.title + "\"?",
		icone: "w",
		width: 400,
		show: 'fade',
		hide: 'clip',
		buttons: {
			"Não": function() {
				//revertFunc();
				$(this).dialog('close');
			},
			"Sim": function () {
				var inicio = formatDate(event.start.getDate() + "/" + 
					(event.start.getMonth() + 1) + "/" + event.start.getFullYear());
					
				var fim = (event.end == null)? "" : formatDate(event.end.getDate() + "/" + 
					(event.end.getMonth() + 1) + "/" + event.end.getFullYear());
				
				$.get("../CadastroAgenda", {
					from: '1',
					codigo: event.id,
					descricao: event.title,
					inicio: inicio,
					horaInicio: getTime(event.start),
					fim: (event.end == null)? "" : fim,
					horaFim: (event.end == null)? "" : getTime(event.end),
					mudaObs: 'n',
					id: $('#idProfissional').val(),
					dayDelta: dayDelta,
					minuteDelta: minuteDelta},
					function(response) {
						if (response == "0") {
							$('#descricao').val("");
							$('#inicio').val("");
							$('#horaInicio').val("");
							$('#fim').val("");
							$('#horaFim').val("");
						} else {
							showErrorMessage({
								width: 400,
								mensagem: "Não foi possível cadastrar o evento devido a um erro interno!",
								title: "Erro de Cadastro"
							});
						}
						$(this).dialog('close');
					}
				);
			}
		} 
	});
}

function renderizeCalendario(title, start, end, allDay) {
	calendar.fullCalendar('renderEvent', {
			title: title,
			start: start,
			end: end,
			allDay: allDay
		},
		true // make the event "stick"
	);
	calendar.fullCalendar('unselect');
}

/*function editBlocoNota() {
	var oldText = $('#blcNota').val();
	var isSave = false;
	$("#windowNota").dialog({
 		modal: true,
 		width: 800,
 		minWidth: 300,
 		show: 'fade',
		hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close');
 			},
 			"imprimir" : function() {
 				top = (screen.height - 600)/2;
				left= (screen.width - 800)/2;
				window.open("../GeradorRelatorio?rel=197&parametros=448@" + $('#usuario').val(), 
						'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
				$(this).dialog('close');
			},
 			"Salvar": function () {
 				isSave = true;
 				$.get("../CadastroCatalogo", {
 					from: '5',
 					blcNota: $('#blcNota').val() }, 
 					function(response) {
 						showMessage({
							mensagem: response,
							title: "Mensagem"
						});
 					}
 				);
				$(this).dialog('close');
 			}
 		},
 		close: function() {
 			$(this).dialog('destroy');
 			if (!isSave) {
 				$('#blcNota').val(oldText);
 			}
 		}
 	});
}

function imprimeAgenda() {	
	$('#dtInicio').val(getToday());
	$('#dtFim').val(getToday());
	$('#hrInicio').val('00:00');
	$('#hrFim').val('00:00');
	$("#windowReport").dialog({
 		modal: true,
 		width: 300,
 		minWidth: 150,
 		show: 'fade',
		hide: 'clip',
 		buttons: {
 			"Cancelar" : function () {
 				$(this).dialog('close');
 			},
 			"Imprimir": function () {
 				inicio = dataHifen($('#dtInicio').val()) + " " + $('#hrInicio').val();
 				fim = dataHifen($('#dtFim').val()) + " " + $('#hrFim').val(); 				
 				if (inicio.length < 16 || fim.length < 16) {
 					showErrorMessage({
						width: 400,
						mensagem: "Preencha os campos corretamente para que o relatório seja impresso!",
						title: "Erro de Impressão"
					});
 					$(this).dialog('close');
				} else {
					top = (screen.height - 600)/2;
					left= (screen.width - 800)/2;
					window.open("../GeradorRelatorio?rel=196&parametros=445@" + $('#usuario').val() +
							"|446@" + inicio + "|447@" + fim, 
							'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
					$(this).dialog('close');
				}
 				
 				
 			}
 		},
 		close: function() {
 			$(this).dialog('destroy');
 		}
 	});

}*/