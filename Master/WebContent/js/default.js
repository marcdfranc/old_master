function mostraPDV() {
	$("#conciliaWindow").dialog({
 		modal: true,
 		width: 800,
 		minWidth: 800,
 		show: 'fade',
 		hide: 'clip',
 		buttons: {
 			"Cancelar": function() {
 				$(this).dialog('close');
			},
 			"Pagar" : function () {
 				alert('Em Manutenção!!!');						
				$(this).dialog('close');
 			}		 			
 		},
 		close: function() {
 			$(this).dialog('destroy');
 		}
 	});
}