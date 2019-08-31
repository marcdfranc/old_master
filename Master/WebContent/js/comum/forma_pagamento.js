var pager;
var flag= false;
var dataGrid;
var pagWindow;
var conciliaLabel;
var conciliaSim;
var conciliaNao;
var conciliaData;
var concilia;
var descricaoLabel;
var descricao;
var btEdicao;
var lastId;
var isShowed;


$(document).ready(function() {
	isShowed = false;
	pagWindow = new MsfWindow("formaPag", "Edição de Forma de Pagamento", 
		"body", 150, 485, "pagWindow", true, false);
	pagWindow.setVisible(false);
	
	conciliaLabel = new MsfLabel("lbConcilia", "Concilia", 320, 30, false);
	conciliaSim = new MsfLabel("lbConciliaSim", "Sim", 340, 48, false);
	conciliaNao = new MsfLabel("lbConciliaNao", "Não", 415, 48, false);
	descricaoLabel = new MsfLabel("lbDescricao", "Descrição", 20, 30, false);
	
	conciliaData = [[true, 450, 48, "n"], [false, 375, 48, "s"]];
	
	concilia = new MsfRadioGroup("rdConcilia", conciliaData, function(value){
		concilia.setValue(value);
	});
	
	descricao = new MsfPrompt("wdDeswcriTxt", "", 20, 45, 280);
	
	btEdicao = new MsfButton("btEditForma", "Editar", "d", 370, 100, "execEdicao");
	
	pagWindow.addConponent(descricaoLabel.getHtm());
	pagWindow.addConponent(descricao.getHtm());
	pagWindow.addConponent(conciliaLabel.getHtm());
	pagWindow.addConponent(conciliaSim.getHtm());
	pagWindow.addConponent(conciliaNao.getHtm());
	pagWindow.addConponent(concilia.getHtm());
	pagWindow.addConponent(btEdicao.getHtm())
	pagWindow.init();
	
	load= function () {		
		pager = new Pager($('#gridLines').val(), 10, "../CadastroBanco");
		pager.mountPager();
		dataGrid = new DataGrid();
		dataGrid.addOption("Editar", "editPagamento(");
		dataGrid.addOption("Excluir", "deletePagamento(");
	}
	
	appendMenu= function(value){
		dataGrid.expande(value, false);
	}
	
	getNext = function(){
		if (flag) {
			flag= false;
			$('#descricaoIn').val("");
		} else {
			if ((pager.limit * pager.currentPage) < pager.recordCount) {
				$.get("../CadastroFormaPagamento",{gridLines: pager.limit , limit: pager.limit, 
					isFilter: "0", offset: pager.offSet + pager.limit, isEdit : "n",					
					descricaoIn: $('#descricaoIn').val()},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.nextPage();			
			}			
		}
	}
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			$('#descricaoIn').val("");			
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroFormaPagamento",{gridLines: pager.limit, limit: pager.limit, 
					isFilter: "0", offset: pager.offSet - pager. limit,isEdit : "n", 
					descricaoIn: $('#descricaoIn').val()},
				function (response) {				
					$('#dataBank').empty();
					$('#dataBank').append(response);
				});
				pager.previousPage();
			}			
		}
	}
	
	renderize= function(value) {
		if (flag) {
			flag= false;
			$('#descricaoIn').val("");
		} else {
			pager.sortOffSet(value);
			$.get("../CadastroFormaPagamento",{gridLines: pager.limit, limit: pager.limit, 
				offset: pager.offSet, isFilter: "0", isEdit : "n", 
				descricaoIn: $('#descricaoIn').val()},
			function (response) {				
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.calculeCurrentPage(); 	
			pager.refreshPager();						
		}
	}	
	
	addRecord = function(){				
		if ($("#descricaoIn").val() == "") {
			showErrorMessage("É necessário o preenchimentop do campo \"descrição\"!", 
				"Entrada inválida", 145, 500, false);
		} else {
			pager.goToLastPage();
			$.get("../CadastroFormaPagamento", {
				gridLines: pager.limit, 
				limit: pager.limit, 
				isFilter: "1", 
				offset: pager.offSet, 
				isEdit : "f", 
				descricaoIn: $('#descricaoIn').val(),
				concilia: $('#conciliaIn').val()}, 
				function(response){
					$('#dataBank').empty();
					$('#dataBank').append(response);			
				}
			);
			pager.recordCount++;
			pager.calculePages();
			pager.calculeCurrentPage();
			pager.refreshPager();
			$('#descricaoIn').val("");
		}
	}
	
	editPagamento = function(value) {
		lastId = value;
		isShowed = true;		
		pagWindow.show();
		
		/*showPrompt("Digite a nova descrição para forma de pagamento.", 
			"Nova Forma de Pagamento", "Descrição", 180, 500, 300, 'd', OK, false,
			function(btn, text) {
				if (btn == 'o') {					
					$.get("../CadastroFormaPagamento", {gridLines: pager.limit, limit: pager.limit, 
						isFilter: "1", offset: pager.offSet, descricaoIn: text,
						id : value, isEdit : "t"
					}, function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);			
					});
				}
			});*/
	}
	
	/**
	 * execEdicao
	 * @param {type} 
	 */
	execEdicao = function() {
	 	$.get("../CadastroFormaPagamento", {
	 			gridLines: pager.limit, 
	 			limit: pager.limit, 
				isFilter: "1", 
				offset: pager.offSet, 
				descricaoIn: descricao.getValue(),
				concilia: concilia.getValue(),
				id : lastId, 
				isEdit : "t"
			}, function(response){
				isShowed = false;
				descricao.setValue("");
				pagWindow.hide();
				$('#dataBank').empty();
				$('#dataBank').append(response);
			}
		);
	}
	
	deletePagamento = function(value) {
		isShowed = true;
		showOption("Deseja realmente excluir este registro ?", 
			"Confirmação de Exclusão", 150, 450, 'w', SIM_NAO, false,
			function(btn) {
				if (btn == 's') {									
					$.get("../CadastroFormaPagamento", {gridLines: pager.limit, limit: pager.limit, 
						isFilter: "1", offset: pager.offSet, descricaoIn: $('#descricaoIn').val(),
						id : value, isEdit : "d"
						}, 
						function(response){
							isShowed = false;
							$('#dataBank').empty();
							$('#dataBank').append(response);
							showOkMessage("Registro excluido com sucesso!", 
								"Sucesso", 150, 450);											
					});					
				}
			}
		);		
	}
	
	$("#" + pagWindow.getInnerlId()).draggable({
		snapDistance: 10, 
		ghosting: false,
		opacity: 0.2,
		zindex: 1000,
		handle: 'div.cpDefaulWindowHeader'
	});
	
	$(this).ajaxStart(function(){
		if (!isShowed) {
			showLoader('Carregando...', 'body', false);			
		}
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
		if (pager != undefined) {
			if (parseInt($('#gridLines').val()) != pager.recordCount) {
				pager.Search();
			}
		}
	});	
});
