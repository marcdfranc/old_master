DataGrid = function (param) {
	var seletor = param.seletor;
	var tabela = $(seletor);
	var header = $(tabela).find("thead");
	var isAjax = (param.tipo == "ajax");
	var data = (isAjax)? undefined : new Array();
	var urlRequest = param.urlRequest;
	var dataHtm = "";
	var dataArray= new Array();
	var colNumber = 0;
	var fieldName = param.field;
	var colunas = param.nomeColunas; 
	
	var tbody = $(tabela).find("tbody");
	
	$(tabela).css({
		"border-botton": "2px solid #42929D",
		"width": "100%",
		"z-index": "10"
	});
	
	$(thead).find("th").each(function (i) {
		var aux = param.widthColuna[i];		
		$(this).css({"width": aux + "%"});
		colNumber++;
	});
	
	if (isAjax) {
		loadAjax();		
	}
	
	loadAjax = function () {		
		$.ajax({
			type: "GET",
			url: urlRequest,
			success: function(response) {				
				loadData(response);				
			}, 
			error: function(xhr, ajaxOptions, thrownError) {
				var xml = stringToXml(xhr);
				loadData(xml);
			}
		});
	}
	
	loadData = function (xml) {
		var aux;
		var cout = 0;
		renderizeXmlData(xml);
		$(xml).find("linha").each(function() {
			aux = $(this).find("coluna");
			cout = aux.length;
			aux = new Array();
			$(this).find("coluna").each(function(i) {
				aux.push($(this).text());
				if (i == cout) {
					data.push(aux);
				}
			});
		});
	}
	
	
	
	insere = function (valores) {
		if (isAjax) {
			
		} else {
			data.push(valores);
			for(var i=0; i<data.length; i++) {
				
			}
		}
	}
	
	remove = function(id) {
		
	}
	
	
	if (isAjax) {
		renderizeXmlData();	
	} else {
		renderizeArrayData();
	}
	
	renderizeXmlData = function (xml) {
		var htm = "";
		var nome = "";
		var valorColuna = "";
		$(xml).find("linha").each(function(i) {
			if ($(this).attr("idReal") == "s") {
				htm+= "<tr class=\"gridRowEmpty\"><input type=\"hidden\" name=\"id" + i + "\" " +
			 		" name=\"id" + i + "\" value=\"" + $(this).attr("id") + "\" />";
			
			} else {
				htm+= "<tr class=\"gridRowEmpty\"><input type=\"hidden\" name=\"id" + i + "\" " +
			 		" name=\"id" + i + "\" value=\"-" + i + "\" />";
			}
			$(this).find("coluna").each(function(j) {
				nome = $(this).attr("nome");
				valorColuna = $(this).text();
				htm += "<td><label>" + valorColuna + "</label></td>";
				htm += "<input type=\"hidden\" id=\"" + nome + i + "\" name=\"" + nome + i + "\" " +
						" value=\"" + valorColuna + "\"\>";
			});
			htm += "</tr>";
		});
	}
	
	
	renderizeArrayData = function () {
		var htm = "";
		for(var i=0; i<data.length; i++) {
			htm+= "<tr class=\"gridRowEmpty\"><input type=\"hidden\" name=\"id" + i + "\" " +
			 		" name=\"id" + i + "\" value=\"-" + i + "\" />";
			for(var j=0; j<nomeColunas.length; j++) {
				htm+= "<td><label>" + data[i][j] + "</label></td>";
				htm += "<input type=\"hidden\" id=\"" + nomeColunas[j] + i + "\" name=\"" + 
					nomeColunas[j] + i + "\" value=\"" + data[i][j] + "\"\>";
			}
		}
		$(tbody).slideUp("slow");
		$(tbody).empty();
		$(tbody).append(htm);
		$(tbody).slideDown("slow");
	}
	
	
	stringToXml = function (xmlData) {
		if (window.ActiveXObject) {
			//for IE
			xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
			xmlDoc.async="false";
			xmlDoc.loadXML(xmlData);
			return xmlDoc;
		} else if (document.implementation && document.implementation.createDocument) {
			//for Mozila
			parser=new DOMParser();
			xmlDoc=parser.parseFromString(xmlData,"text/xml");
			return xmlDoc;
		}
	}
}