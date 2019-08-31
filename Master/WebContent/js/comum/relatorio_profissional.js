var sufix = "http://localhost:8080/birt-viewer/frameset?__report=";
var dataGrid;

$(document).ready(function() {
	load = function() {
		pager = new Pager($('#gridLines').val(), 10, "../CadastroBanco");
		pager.mountPager();
		dataGrid = new DataGrid();
	}
	
	appendMenu= function(value){
		value= value.replace("rowMenu", "");
		window.open(sufix + value, "", "");
	}
		
});