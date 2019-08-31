/**
 * 
 */

function excluiVideo() {
	showOption({
		mensagem: "Tem certeza que deseja apagar este video?",
		title: "Estorno de Mensalidades",
		width: 350,
		show: 'fade',
		hide: 'clip',
		buttons: {
			"Não": function () {
				$(this).dialog('close');
			},
			"Sim": function() {
				$.get("../CadastroVideo",{					
					from: "1",
					codVideo: $("#codVideo").val()
				}, function (response) {
					if (response == "0") {
						location.href= '../error_page.jsp?errorMsg=Vídeo excluido com sucesso!&lk=' +
							'application/videos_edit.jsp';
					} else {
						location.href= '../error_page.jsp?errorMsg=Ocorreu um erro durante a exclusao!&lk=' +
							'application/videos_edit.jsp';
					}
				});
			}
		}
	});	
}