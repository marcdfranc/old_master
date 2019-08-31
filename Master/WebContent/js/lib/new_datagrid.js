Pager = function(count, limit, from) {
	this.limit= limit;
	this.from = from;
	this.recordCount = parseInt(count);
	this.offSet= 0;
	this.currentPage = 1;
	this.lastPage;	
	this.next;
	this.previous;
	this.filter;
	this.isChange;	
	
	this.mountPager= function() {
		this.previous= "<a id=\"previous\" onClick=\"getPrevious()\" name=\"previous\" ><< anterior</a>";									
		this.next= "<a id=\"next\" onClick=\"getNext()\" name=\"next\">próximo >></a>";
		this.calculePages();
		this.refreshPager();
	}
	
	this.sortOffSet = function(page) {
		this.offSet = (parseInt(page) - 1) * this.limit;
	}
	
	this.calculePages= function() {
		if (this.recordCount%this.limit == 0) {
			this.lastPage= parseInt(this.recordCount/this.limit);			
		} else {
			this.lastPage= parseInt(this.recordCount/this.limit) + 1;
		}		
	}
	
	this.goToLastPage= function() {
		this.offSet= parseInt((this.recordCount) /this.limit) * this.limit;
	}
	
	
	this.calculeCurrentPage= function() {
		this.currentPage= parseInt(this.offSet / this.limit) + 1;		
	}
	 
	this.getLimit= function() {
		this.limit
	}
	 
	this.getOffSet= function() {
		this.offSet;
	}	 
	 
	this.refreshPager= function() {
	 	if (this.lastPage > 1) {
			var aux= this.previous;
			var mim= 0;
			var max= 0;
			if (this.currentPage < 5) {			
				max= 5;
			} else {
				mim = this.currentPage;
				while (mim%5 != 0) { mim--;	}
				max= mim + 5;
			}
			mim++;
			for(var i= mim; i<= max; i++) {
				aux+= "<label onClick=\"renderize(" + i + ");\">" + i + "</label>";
				if (i == this.lastPage) {
					break;
				}
			}
			aux+= this.next;
			$('#pagerGrid').empty();
			$('#pagerGrid').append(aux);			
		}
		this.renderizeCounter();
	}
	 
	this.refreshCounter= function(isNext) {
	 	if (parseInt($('#gridLines').val()) != this.recordCount) {
			this.recordCount= parseInt($('#gridLines').val());
			this.offSet= 0;
			return true;
		} else if (isNext) {
			this.offSet+= this.limit;			
		} else {
			this.offSet-= this.limit;
		}
		return false;		
	 }
	 
	this.renderizeCounter= function() {
		var aux = "<span><label class=\"titleCounter\">Pág: </label></span>" +
			"<span><label class=\"valueCounter\">" + this.currentPage +  "</label></span>" +
			"<span><label class=\"titleCounter\"> de </label></span>" +
			"<span><label class=\"valueCounter\">" + this.lastPage + "</label></span>" +
			"<span><label style=\"margin-left: 30px;\" class=\"titleCounter\">Total:</label></span>" +
			"<span><label class=\"valueCounter\">" + this.recordCount + "</label></span>" +
			"<span><label class=\"titleCounter\">Registros</label></span>";	
	 	$('#counter').empty();
		$('#counter').append(aux);
	}
	 
	this.Search= function() {4	 	
	 	if (this.refreshCounter()) {
			this.calculePages();				
		}
		this.calculeCurrentPage();
		this.refreshPager();
	}
	 
	this.nextPage= function() {	 	
	 	if ((this.currentPage * this.limit) < this.recordCount) {
			if (this.refreshCounter(true)) {
				this.calculePages();				
			}
			this.calculeCurrentPage();
			this.refreshPager();
		}
	 }
	 
	this.previousPage= function() {
	 	if (this.limit > 0) {
			if (this.refreshCounter(false)) {
				this.calculePages();				
			}			
			this.calculeCurrentPage();
			this.refreshPager();
		}
	}
}

DataGrid = function(){	
	this.options= new Array();
	this.hrefs= new Array();
	this.uls= new Array();
	this.isAppended	= new Array();
	this.limit;
	this.offSet;	
	
	this.addOption= function(opt, href) {
		this.options[this.options.length]= opt;
		this.hrefs[this.hrefs.length] = href;
	}
		
	this.setLineNumber= function(value) {
		this.offSet= 0;
		this.limit = value;
	}	
	
	this.nextPage = function() {
		this.offSet+= this.limit;
	}
	
	this.previowsPage= function() {
		this.offSet-= this.limit;
	}
	
	this.findKey= function(value) {
		for(var i= 0; i< this.uls.length; i++) {
			if (this.uls[i] == value){
				return i; 
			}			
		}
		return -1;
	} 

	this.expande= function(local, isHref){
		var id = this.getId(local);
		var ul= "retroMenu" + id;
		var key = this.findKey(ul) 
		var aux = "<td class=\"gridMenuContent\" colspan=\"4\"><ul id=\"" + ul + 
			"\" style=\"display: none;\">";
		if (key == -1) {
			this.uls[this.uls.length] = ul;
			this.isAppended[this.isAppended.length] = false;
			key= this.isAppended.length -1;
			for (var i = 0; i < this.options.length; i++) {
				aux += "<li><div class=\"gridMenu\"> ";
				if (isHref) {
					aux += "<a class=\"menuExpandido\" href=\"" + this.hrefs[i] + id +
						"\">" + this.options[i] + 
						"</a></div></li>";					
				} else {
					aux += "<a class=\"menuExpandido\" href=\"#\" onclick=\"" + this.hrefs[i] + id +
						")\">" + this.options[i] + "</a></div></li>";
				}
			}
			$("#" + local).append(aux + "</ul></td>");
		}
		if (this.isAppended[key]){
			$('#' + ul).slideUp("fast");
			this.isAppended[key]= ! this.isAppended[key];
		} else {
			$('#' + ul).slideDown("fast");
			this.isAppended[key]= ! this.isAppended[key];
		}		
	}	
	
	this.getId= function(local){
		local= local.replace(/^(rowMenu)(\d)/, "$2");
		return local;
	}
}

$(document).ready(function() {
	var od = $("#orderGd").val();
	
	changeOrderGrid = function(value) {		
		var newOrder = value.id;
		if (getPart(od, 1) != newOrder) {
			$("#" + getPart(od, 1) + "Od").empty();
			$("#" + newOrder + "Od").append("<img src=\"../image/order.gif\"/>");
			od = newOrder + "@asc";
		} else {
			if (getPart(od, 2) == "asc") {
				$("#" + newOrder + "Od").empty();
				$("#" + newOrder + "Od").append("<img src=\"../image/order_desc.gif\"/>");
				od = newOrder + "@desc";
			} else {
				$("#" + newOrder + "Od").empty();
				$("#" + newOrder + "Od").append("<img src=\"../image/order.gif\"/>");
				od = newOrder + "@asc";
			}
		}
		$("#orderGd").val(od);
		orderModify();
	}
	
	getOrderGd = function() {
		return od;
	}
});