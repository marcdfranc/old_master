var pager;
var flag= false;
var dataGrid;

$(document).ready(function() {
	pager = new Pager($('#gridLines').val(), 2, "../CadastroVideo");
	pager.mountPager();
	
	$(this).ajaxStart(function(){
		showLoader();
	});
	
	$(this).ajaxStop(function(){
		hideLoader();
		if (pager != undefined) {
			if (parseInt($('#gridLines').val()) != pager.recordCount) {
				pager.Search();
			}
		}
	});
	
	$("input[type='text']").change(function() {
		flag= true;
	});
	
	$("frame[name=ad_frame]").addClass("cpEsconde");	
	
	$('form').submit(function() {
		return false;
	});
});


function getNext(){
	if (flag) {
		flag= false;
		search();
	} else {
		if ((pager.limit * pager.currentPage) < pager.recordCount) {
			$.get("../CadastroVideo",{
				gridLines: pager.limit , 
				limit: pager.limit, 
				isFilter: "0", 
				offset: pager.offSet + pager.limit,
				from: '0',
				menu: $('#menuIn').val(),
				titulo: $('#tituloIn').val()
			}, function (response) {				
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.nextPage();
		}			
	}
}

function getPrevious(){
	if (flag) {
		flag= false;
		search();
	} else {
		if (pager.offSet > 0) {
			$.get("../CadastroVideo",{
				gridLines: pager.limit, 
				limit: pager.limit,
				isFilter: "0",
				offset: pager.offSet - pager.limit,
				from: '0',
				menu: $('#menuIn').val(),
				titulo: $('#tituloIn').val()
			}, function(response){
				$('#dataBank').empty();
				$('#dataBank').append(response);
			});
			pager.previousPage();
		}			
	}
}

function search() {
	$.get("../CadastroVideo",{
		gridLines: pager.limit, 
		limit: pager.limit,
		offset: 0, 
		isFilter: "1",
		from: '0',
		menu: $('#menuIn').val(),
		titulo: $('#tituloIn').val()
	}, function(response){
		$('#dataBank').empty();
		$('#dataBank').append(response);				
	});
	return false;
}

function renderize(value) {
	if (flag) {
		flag= false;
		search();
	} else {
		pager.sortOffSet(value);
		$.get("../CadastroVideo",{
			gridLines: pager.limit, 
			limit: pager.limit,
			offset: pager.offSet, 
			isFilter: "0",
			from: '0',
			menu: $('#menuIn').val(),
			titulo: $('#tituloIn').val()
		}, function(response) {
			$('#dataBank').empty();
			$('#dataBank').append(response);
		});
		pager.calculeCurrentPage(); 	
		pager.refreshPager();
	}
}
