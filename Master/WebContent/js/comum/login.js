var isShow= false;
$(document).ready(function() {
	$(window).unload( function () { 
		//showLoader('Carregando...', 'body', false);
	});
	
	
	/**
	 * ttDialog
	 * @param {type}  
	 */
	ttDialog = function() {
		if (isShow) {
			$("#dialog").show();
		} else {
		 	$("body").append("<div id=\"dialog\" title=\"Dialog Title\">I'm in a dialog</div>");
		 	$("#dialog").dialog({bgiframe: true,
				height: 140,
				modal: true
			});
		}

	}
});