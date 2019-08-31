var grupo;
var item;
function pesquisaGrupo() {
	var index = parseInt(getPart($('#grupoPesquisa').val(), 1));
	var showGrup = true;
	var aux;
	if (index < 0 && $('#nomeContato').val() == "" && $('#mesNiver').val() == "") {
		showAll();
	} else {
		hideAll();
		var filtro = "";
		var aux
		if (index < 0) {		
			if ($('#nomeContato').val().toLowerCase() != "") {
				filtro+= "a:contains('" + $('#nomeContato').val() + "')";
			}
			if ($('#mesNiver').val() != "") {
				filtro+= (filtro == "")? "a.hdNiver" + $('#mesNiver').val() : ",a.hdNiver" + $('#mesNiver').val();
			}
			$('div[id^=accordiomItem]').find(filtro).each(function () {
				$('#grp' + $(this).next().val()).show();
				$(this).parent().show();
			});
		} else {
			$('#grp' + getPart($('#grupoPesquisa').val(), 2)).show();
			$('#accordiomGrupo').accordion('activate', index);
			if ($('#nomeContato').val() != "") {
				filtro+= "a:contains('" + $('#nomeContato').val().toLowerCase() + "')";
				showGrup = false;
			}
			if ($('#mesNiver').val() != "") {
				filtro+= (filtro == "")? "a.hdNiver" + $('#mesNiver').val() : ",a.hdNiver" + $('#mesNiver').val();
				showGrup = false;
			}
			if (showGrup) {				
				$('#accordiomItem' + getPart($('#grupoPesquisa').val(), 2)).find("a").each(function () {
					$(this).parent().show();
				});
			} else {
				$('#accordiomItem' + getPart($('#grupoPesquisa').val(), 2)).find(filtro).each(function () {
					$(this).parent().show();
				});
			}
		}
	}

}

function hideAll() {
	$('#accordiomGrupo').accordion('activate', false);
	$('#accordiomItem').accordion('activate', false);	
	$('.headerOption').hide();
}

function showAll() {
	$('.headerOption').show();
}