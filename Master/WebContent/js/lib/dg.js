GridItem = function(param) {
	param.remove = (param.remove == undefined)? false : param.remove;
	var template = '<td><label id="%(name)s%(id)s"  name="%(name)s%(id)s">%(value)s</label></td>';
	var checkTemplate = '<input id="%(name)s%@(id)s" name="%(name)s%@(id)s" type="checkbox" value="%(value)s" />';
	
	this.getIten = function() {
		if (param.remove) {
			return $.sprintf(checkTemplate, {id: param.id, name: param.name, value: param.id});
		} else {
			return $.sprintf(template, {id: param.id, name: param.name, value: param.value});
		}
	};
	
	this.getParametros = function() {
		return param;		
	}
	
	this.getValue = function() {
		return param.value;
	}
	
	this.getParamByName = function(nome) {
		switch (nome) {
		case 'name':
			return param.name;
			break;
			
		case 'id':
			return param.id;
			break;
			
		case 'value':
			return param.value;
			break;

		default:
			return param;
			break;
		}
	}
}

GridRow = function(param) {
	param.remove = (param.remove == undefined)? false : param.remove;
	var template = '<tr class="gridRow">%(data)s</tr>';
	var data = new Array();
	var size = param.data.length - 1;
	var id;
	
	for ( var int = 0; int < param.data.length; int++) {
		if (int == 0) {
			id = param.data[int].id;
		}
		data.push(new GridItem({
			id: param.data[int].id,
			name: param.data[int].name,
			value: param.data[int].value
		}));
		//alert(param.data.length - 1);
		
		
		if (param.remove && (int == size) && id != undefined && id != "") {
			data.push(new GridItem({
				id: param.data[int].id,
				name: param.data[int].name,
				value: param.data[int].value,
				remove: true
			}));
		}
	}
	
	
	this.getRowHtm = function() {
		htm = '';
		for ( var i = 0; i < data.length; i++) {
			htm+= data[i].getIten();		
		}
		return $.sprintf(template, {data: htm});
	}
	
	this.getRowData = function() {
		return data;
	}
	
	this.getRowDataGrid = function() {
		valor = "";
		for ( var i = 0; i < data.length; i++) {
			valor+= (i == 0)? data[i].getValue() : "@" + data[i].getValue();
		}
		return valor;
	}
	
	this.getId = function() {
		return id;
	}
}

HeaderIten = function(param) {
	var template = '<th style="%(style)s"><div class="headerColum"><p>%(value)s</p></div></th>';
	
	this.getValue = function() {
		return param.value;
	}
	
	this.getParamByName = function(name) {
		if (name == 'style') {
			return param.style;			
		} else {
			return param.value;
		}
	}
	
	this.getParametros = function() {
		return param;
	}
	
	this.getIten = function() {
		return $.sprintf(template, {style: param.style, value: param.value});
	}
}

HeaderGrid = function(param) {
	var template = '<thead class="headerGrid"><tr>%(data)s</tr></thead>';
	var data = new Array();
	
	for ( var i = 0; i < param.data.length; i++) {
		data.push(new HeaderIten({
			style: param.data[i].style,
			value: param.data[i].value
		}));
	}
	
	this.getRowHtm = function() {
		htm = '';
		for ( var j = 0; j < data.length; j++) {
			htm+= data[j].getIten();
		}
		return $.sprintf(template, {data: htm});
	}
	
	this.getDataHtm = function() {
		return data;
	}
}


DataTable = function(param) {
	param.ajax = (param.ajax == undefined)? false : param.ajax; 
	param.remove = (param.remove == undefined)? false: param.remove;
	var template = '<div id="gridContent" class="dataGrid"><table id="%(idTable)s" cellpadding="0" cellspacing="0" class="lastGrid">' + 
		'%(header)s<tbody id="%(id)sConteiner" >%(body)s</tbody></div>';		
	
	var bodyConteiner = $.sprintf('%sConteiner', param.id);
	
	var header = new HeaderGrid({data: param.model});	
	var data;
	
	
	var processaData = function(dados, model) {
		//alert(dados);
		data = new Array();
		aux = new Array();
		for ( var i = 0; i < dados.length; i++) {
			if (param.remove) {
				for ( var j = 0; j < model.length - 1; j++) {				
					aux.push({
						id : dados[i].id,
						name : param.name,
						value: dados[i].data[j]
					});				
				}
			} else {
				for ( var j = 0; j < model.length; j++) {				
					aux.push({
						id : dados[i].id,
						name : param.name,
						value: dados[i].data[j]
					});				
				}
			}
			if (param.remove) {
				data.push(new GridRow({data: aux, remove: true}));
			} else {
				data.push(new GridRow({data: aux}));
			}
			aux = new Array();
		}
		
	}
	
	var processaRefresh = function(dado) {		
		aux = new Array();		
		if (param.remove) {
			for ( var j = 0; j < param.model.length - 1; j++) {
				aux.push({
					id : dado.id,
					name : param.name,
					value: dado.data[j]
				});
			}
			data.push(new GridRow({data: aux, remove: true}));
		} else {
			for ( var j = 0; j < param.model.length; j++) {
				aux.push({
					id : dado.id,
					name : param.name,
					value: dado.data[j]
				});
			}
			data.push(new GridRow({data: aux}));
		}
	}
	
	stringToXml = function(xmlData) {
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
	
	if (param.ajax) {
		$.ajax({
			type: "GET",
			url: param.url,
			dataType: 'json',
			success: function(response) {
				param.data = response;
				data = param.data;
				processaData(param.data, param.model);
			}, 
			error: function(response) {
				showErrorMessage({
					width: 400,
					mensagem: "Ocorreu um erro durante o processamento dos dados desta página!",
					title: "Erro de Processamento"
				});
			}
		});
	} else {
		processaData(param.data, param.model);
	}	
	
	
	var getDataHtm = function() {
		htm = '';
		for ( var i = 0; i < data.length; i++) {
			htm+= data[i].getRowHtm();
		}
		return htm;		
	}
	
	this.getData = function() {
		return data;
	}
	
	this.getDataGrid = function() {
		valor = "";
		for ( var i = 0; i < data.length; i++) {
			valor+= (i == 0)? data[i].getRowDataGrid() : "|" + data[i].getRowDataGrid();
		}
		return valor;
	}
	
	this.getTable = function() {
		return $.sprintf(template, {
			idTable: param.id,
			header: header.getRowHtm(),
			id: param.id,
			body: getDataHtm()
		});		
	}
	
	this.refresh = function() {
		//alert(param.id + 'Conteiner');		
		$('#' + param.id + 'Conteiner').empty();
		$('#' + param.id + 'Conteiner').append(getDataHtm());
	}
	
	this.addRow = function(dados) {
		processaRefresh(dados);
		this.refresh();
	}
	
	this.removeRow = function() {
		idRemoved = '';
		$('#' + bodyConteiner + ' input:checked').each(function() {
			for ( var i = 0; i < data.length; i++) {
				if ($(this).val() == data[i].getId()) {
					idRemoved = $(this).val();
					data.splice(i, 1);
					//alert(data[i].getId());
				}
			}
		});
		this.refresh();
		return idRemoved;
	}
	
	this.clearData = function() {
		data = new Array();
		this.refresh();
	}
}


/*var dataTable = new DataTable({
	id: 'teste',
	model: new Array(
		{style: '', value: 'nome'},
		{style: '', value: 'tel'},
		{style: '', value: 'cpf'}
	),
	data: new Array(
		{id: 'sap',	data: new Array('marcelo', '16 33320450','265.844.978-01')},
		{id: 'dep', data: new Array('Leonilda', '16 33320450', '265.844.978-01')}
	)
});*/