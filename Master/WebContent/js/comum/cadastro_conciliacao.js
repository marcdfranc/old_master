var flag= false;
var dataGrid;
	
function appendMenu(value){
	dataGrid.expande(value, false);
}

function uploadPdf(value) {
	if (getPipeByIndex($('#pipeConfig' + value).val(), 1) == 'e') {
		showErrorMessage ({
			width: 400,
			mensagem: "Não é possível fazer upload de conciliações com datas anteriores!",
			title: "Erro"
		});
	} else {
		$("#conteinerUp" + value).uploadify({
			'uploader' : '../flash/uploadify.swf',
			'script' : '../ChequeUpload',
			'cancelImg' : '../image/cancel.png',
			'buttonImg' : '../image/upload.gif',								
			'folder' : 'upload/contratos_sociais',
			'queueID' : 'fileQueue',
			'fileDesc': 'Arquivos Adobe PDF(*.pdf)',
			'fileExt': '*.pdf',
			'width' : 320,
			'height': 200,
			'scriptData' : {
				'nome_arquivo': 'cq_lanc_' + value + "_conc_" + $('#codigoIn').val(),
				'idLancamento': value,
				'idConciliacao': $('#codigoIn').val()
			},
			'queueSizeLimit': 1,
			'sizeLimit': 250000,
			'onComplete' : function (event, queueID, fileObj, response, data) {
				location.href= response;
				return true;
			},
			'auto' : true,
			'multi' : false
		});
		$('#pop_id' + value).dialog({
	 		modal: true,
	 		width: 508,
	 		minWidth: 400,
	 		show: 'fade',
		 	hide: 'clip',
	 		buttons: {
	 			"Cancelar" : function () {
	 				$(this).dialog('close');
	 			}
	 		},
	 		close: function() {
	 			$(this).dialog('destroy');
	 		}
	 	});
	}
}

function goToDoc(value) {
	if (getPipeByIndex($('#pipeConfig' + value).val(), 0) == "s") {
		var url = "upload/cheques/cq_lanc_" + value + "_conc_" + $('#codigoIn').val() + ".pdf";
		var top = (screen.height - 600)/2;
		var left= (screen.width - 800)/2;
		window.open(url ,'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
	} else {
		showErrorMessage ({
			width: 300,
			mensagem: "Imagem não encontrada ou arquivo inexistente!",
			title: "Erro"
		});
	}
}


$(document).ready(function() {
	pager = new Pager($('#gridLines').val(), 30, "../CadastroClienteJuridico");
	pager.mountPager();
	dataGrid = new DataGrid();
	dataGrid.addOption("Upload", "uploadPdf(");
	dataGrid.addOption("Documento Digital", "goToDoc(");
});