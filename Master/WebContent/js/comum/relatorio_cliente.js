var flag= false;
var dataGrid;

$(document).ready(function() {
	load= function () {		
		pager = new Pager($('#gridLines').val(), 40, "../Carteirinha");		
		dataGrid = new DataGrid();
	}
	
	appendMenu= function(value){		
		switch (getNumber(value)) {
			case "11":									
				/*$.get("../Carteirinha", {
					codUsuario: ""
				}, function(response){
					if (response != "0") {
						alert("ok")
					} else {
						alert("erro");
					}
				});*/
				var top = (screen.height - 450)/2;
				var left= (screen.width - 600)/2;
				window.open('carteirinha.jsp', 'nova', 'width= 600, height= 450, top= ' + top + ', left= ' + left);
				break;
		}		
	}
	
	showReport = function() {
		var top = (screen.height - 600)/2;
		var left= (screen.width - 800)/2;
		window.open(BIRT_FRAMESET + "tt_cobranca.rptdesign", 'nova', 'width= 800, height= 600, top= ' + top + ', left= ' + left);
	}
	
});