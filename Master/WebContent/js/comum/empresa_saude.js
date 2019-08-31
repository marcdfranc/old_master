var pager;
var flag= false;
var dataGrid;

$(document).ready(function() {
	load= function () {		
		pager = new Pager($('#gridLines').val(), 30, "../CadastroEmpresaSaude");
		dataGrid = new DataGrid();
		dataGrid.addOption("Cadastro", "goToCadastro(");
		dataGrid.addOption("Anêxo", "goToAnexo(");
		dataGrid.addOption("Borderô", "goToLancamentos(");
		dataGrid.addOption("Cadastro de Fatura", "goToGeracao(");
		dataGrid.addOption("Histórico de Faturas", "goToFaturas(");
		pager.mountPager();	
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
				$.get("../CadastroEmpresaSaude",{
					gridLines: pager.limit ,
					limit: pager.limit,
					isFilter: "0",
					offset: pager.offSet + pager.limit,
					codigoIn: $('#codigoIn').val(),
					razaoSocialIn: $('#razaoSocialIn').val(),
					fantasiaIn: $('#fantasiaIn').val(),
					reponsavelIn: $('#reponsavelIn').val(),
					conselhoIn: $('#conselhoIn').val(),
					nomeContatoIn: $('#nomeContatoIn').val(),
					setorIn: $('#setorIn').val(), 
					especialidadeIn: $('#especialidadeIn').val(),
					unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
						$('#unidadeId').val(),									
					ativoChecked: $('#ativoChecked').val()},
					function (response) {				
						$('#dataBank').empty();
						$('#dataBank').append(response);
					}
				);
				pager.nextPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");
				dataGrid.addOption("Anêxo", "goToAnexo(");
				dataGrid.addOption("Borderô", "goToLancamentos(");
				dataGrid.addOption("Gerar Fatura", "goToGeracao(");
				dataGrid.addOption("Faturas", "goToFaturas(");
			}			
		}
	}
	
	
	getPrevious= function(){
		if (flag) {
			flag= false;
			search();
		} else {
			if (pager.offSet > 0) {
				$.get("../CadastroEmpresaSaude",{
					gridLines: pager.limit, 
					limit: pager.limit,
					isFilter: "0",
					offset: pager.offSet - pager.limit,	
					codigoIn: $('#codigoIn').val(),
					razaoSocialIn: $('#razaoSocialIn').val(),
					fantasiaIn: $('#fantasiaIn').val(),
					reponsavelIn: $('#reponsavelIn').val(),
					conselhoIn: $('#conselhoIn').val(),
					nomeContatoIn: $('#nomeContatoIn').val(),
					setorIn: $('#setorIn').val(), 
					especialidadeIn: $('#especialidadeIn').val(),
					unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
						$('#unidadeId').val(),									
					ativoChecked: $('#ativoChecked').val()},
					function(response){
						$('#dataBank').empty();
						$('#dataBank').append(response);
					}
				);
				pager.previousPage();
				dataGrid = new DataGrid();
				dataGrid.addOption("Cadastro", "goToCadastro(");
				dataGrid.addOption("Anêxo", "goToAnexo(");
				dataGrid.addOption("Borderô", "goToLancamentos(");
				dataGrid.addOption("Gerar Fatura", "goToGeracao(");
				dataGrid.addOption("Faturas", "goToFaturas(");
			}
		}
	}
	
	search= function() {
		$.get("../CadastroEmpresaSaude",{
			gridLines: pager.limit,
			limit: pager.limit,
			offset: 0,
			isFilter: "1", 
			codigoIn: $('#codigoIn').val(),
			razaoSocialIn: $('#razaoSocialIn').val(),
			fantasiaIn: $('#fantasiaIn').val(),
			reponsavelIn: $('#reponsavelIn').val(),
			conselhoIn: $('#conselhoIn').val(),
			nomeContatoIn: $('#nomeContatoIn').val(),
			setorIn: $('#setorIn').val(), 
			especialidadeIn: $('#especialidadeIn').val(),
			unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
				$('#unidadeId').val(),									
			ativoChecked: $('#ativoChecked').val()},
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
			$.get("../CadastroEmpresaSaude",{
				gridLines: pager.limit,
				limit: pager.limit,
				offset: pager.offSet,
				isFilter: "0", 
				codigoIn: $('#codigoIn').val(),
				razaoSocialIn: $('#razaoSocialIn').val(),
				fantasiaIn: $('#fantasiaIn').val(),
				reponsavelIn: $('#reponsavelIn').val(),
				conselhoIn: $('#conselhoIn').val(),
				nomeContatoIn: $('#nomeContatoIn').val(),
				setorIn: $('#setorIn').val(), 
				especialidadeIn: $('#especialidadeIn').val(),
				unidadeId: ($('#unidadeId').val() == "Selecione")? "" :
					$('#unidadeId').val(),									
				ativoChecked: $('#ativoChecked').val()},
				function(response) {
					$('#dataBank').empty();
					$('#dataBank').append(response);
				}
			);
			pager.calculeCurrentPage(); 	
			pager.refreshPager();
			dataGrid = new DataGrid();
			dataGrid.addOption("Cadastro", "goToCadastro(");
			dataGrid.addOption("Anêxo", "goToAnexo(");
			dataGrid.addOption("Borderô", "goToLancamentos(");
			dataGrid.addOption("Gerar Fatura", "goToGeracao(");
			dataGrid.addOption("Faturas", "goToFaturas(");						
		}
	}
	
	$('#setorIn').change(function() {
		if($('#setorIn').val() != "") {
			$.get("../FuncionarioGet",{setorIn: $('#setorIn').val(), 
				from: "4"},
				function (response) {
					$('#especialidadeIn').empty();
					$('#especialidadeIn').append(response);
					document.getElementById("especialidadeIn").selectedIndex= 0;					
			});
		}
	});
	
	goToCadastro = function (value) {
		location.href = "cadastro_empresa_saude.jsp?state=1&id=" + value;	
	}
	
	goToGeracao = function (value){
		location.href = "cadastro_bordero.jsp?id=" + value;	
	}
	
	goToFaturas = function (value) {
		location.href = "fatura_bordero_profissional.jsp?id=" + value;
	}
		
	goToLancamentos = function (value) {
		location.href = "bordero_empresa_saude.jsp?id=" + value;
	}
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	/**
	 * goToAnexo
	 * @param {type}  
	 */
	goToAnexo = function (value) {
	 	location.href = "anexo_empresa_saude.jsp?id=" + value;
	}
	
	$(this).ajaxStop(function(){
		hideLoader();
		if (condition) {
			if (parseInt($('#gridLines').val()) != pager.recordCount) {
				pager.Search();
			}
		}
	});
	
	$("input[type='text']").change(function() {
		flag= true;
	});
});