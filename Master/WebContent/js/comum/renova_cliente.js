
Ext.onReady(function() {
 	var dataBase;
	var gdEdit;
	var diaVencimento;
	var vigencia;
	var colModel;
	var finalRecord = "";
	var boxSelect;	
	var helpLabel;
	var helpLabelA;
	var helpLabelB;
	var dgStore;
	var assistente;
	var stagio = 0;	
	var avancarBtn;
	var retornarBtn;
	var cancelBtnR;
	var selectData;
	var dataToPost = "";
	var INTRO = "Você esta prestes a fazer renovação de contratos que se encontram com renovação " +
		"vencida. Este assistente irá guia-lo passo a passo nesta tarefa bastando para isto " +
		" somente seguir as instruçoes que lhe serão apresentadas a seguir."		
		
	var COMPLEMENTO_INTRO= "Para continuar, selecione o mês e click em avançar."
	
	var PRIMEIRO_PASSO = "Selecione o mês base para renovação, lembre-se que para ter acesso a " + 
		"todos os contratos passíveis de renovação é necessária a escolha da opçõa \"Todos\", " +
		"caso contrário só serão renovados os contratos do mês escolhido."
	
	var SEGUNDO_PASSO = "Existem duas caixas de Texto, sendo que a caixa da esquerda contém os contratos " +
		"que nessecitam ser renovados."
	
	var SEGUNDO_COMPLEMENTO= "Para selecionar os contratos que deseja renovar, basta selecionalos " +
		"na caixa da esquerda e clicar na seta de navegação entre as caixas de texto. Lembre-se "
		"que só serão renovados os contratos na caixa da direita"
		
	var TERCEIRO_PASSO = "Agora devem ser selecionados as datas de renovação, os dias de vencimento, " +
		"os periodos de vigência, bem como os valores para as mensalidades dos devidos contratos " + 
		"a serem renovados.";		
	
	var TERCEIRO_COMPLEMENTO = "Lembre-se que abaixo estão os contratos carregados com seus antigos valores. " +	
		"portanto se clicar em avançar, os contratos serão renovados como estão apresentados."
		
	var PODRE = "O sitema já computou os contratos que você selecionou, clique em avançar para " +
		"ocontinuar com a renovação de contratos";
		
	var QUARTO_PASSO = "Todas as configurações foram selecionados e o sistema agora está pronto " +
		"para fazer a renovação dos contratos."
		
	var QUARTO_COMPLEMENTO= "Tenha certeza de que as informações fornecidas a este assistente " +
		"estão corretas, pois a  renovação de contratos é irreversível,  se tiver " +
		"duvidas clique en voltar e verfique os dados a fim de que não haja erros."		
	
	var valuesSel = [];
	
	function formatDate(value){
		return Ext.util.Format.date(value, 'd M, Y');
    };

	
	diaVencimento = new Ext.form.ComboBox({
		id: 'vencRn',
		store: [
			['01', '01'], ['05', '05'], ['10', '10'], ['15', '15'], ['20', '20'], ['25', '25'],
		],	    
	    typeAhead: true,
		width: 100,
	    mode: 'local',
	    triggerAction: 'all',	    
	    lazyRender:true,
        listClass: 'x-combo-list-small'	
		
	});
	
	vigencia = new Ext.form.ComboBox({
		id: 'vigRn',		
		store: [
			['06', '06'], ['12', '12'], ['18', '18'], ['24', '24']
		],	    
	    typeAhead: true,
		width: 100,
	    mode: 'local',
	    triggerAction: 'all',	    
	    lazyRender:true,
        listClass: 'x-combo-list-small'	
		
	});
	
	colModel = new Ext.grid.ColumnModel([{
           id:'ctr',
           header: "CTR",
           width: 310,           		   
           dataIndex: 'ctr',
		   sortable: false
        },{
           header: "Renovação",
		   renderer: formatDate,
		   sortable: false,
           dataIndex: 'renov',
		   editor: new Ext.form.DateField({
		   		format: 'd/m/Y',
				validationEvent: false,
				validateOnBlur: false,
				enableKeyEvents: true,
				rendered: false,
				listeners: {
					'keyup': function() {
						var aux = this.getRawValue();
						aux= dateType(aux);
						this.setRawValue(aux);
					}
				}
            })
        },{
           header: "Vencimento",
		   sortable: false,
           dataIndex: 'venc',
		   width: 70,
           editor: diaVencimento
        },{
           header: "Vigência",
		   sortable: false,
           dataIndex: 'vig',
           width:55,           
           editor: vigencia
        },{
           header: "Valor",
		   sortable: false,
           dataIndex: 'val',
           width: 75,
		   align: 'right',
           renderer: 'usMoney',
           editor: new Ext.form.NumberField({
               allowBlank: false,
               allowNegative: false               
           })
        }		
    ]);
	
	dgStore = new Ext.data.SimpleStore({
		fields: ['ctr', 'renov', 'venc', 'vig', 'val'],
		data: valuesSel
	});
	
	gdEdit = new Ext.grid.EditorGridPanel({
        store: dgStore,
        cm: colModel,       
        height:200,        
        title:'Edição de renovação',
        frame:true,        
        clicksToEdit:1,
		enableHdMenu: false,
		maskDisabled: false,
		x: 10,
		y: 90
    });
	
	boxSelect = new Ext.form.FormPanel({
		labelWidth: 55,
		width:600,		
		items: [{
			xtype: 'itemselector',
			name: 'itemselector',
			fieldLabel: 'Contratos',
			dataFields: ['cod', 'ctrDesc'],
			fromData: [],
			toData: [],
			msWidth:266,
			msHeight:180,
			valueField:"cod",
			displayField:"ctrDesc",
			toLegend:"Selecionados",
			fromLegend:"Disponíveis",
			toTBar:[{
				text:"Limpar Todos",
				width: 300,
				handler:function(){
					var i = boxSelect.getForm().findField("itemselector");
					i.reset.call(i);
				}
			}],
			fromTBar: [{
				text:"Selecionar Todos",
				width: 300,
				handler:function(){
					var i = boxSelect.getForm().findField("itemselector");
					i.turnSelect.call(i);
				}
			}]
		}],		
		x: 20,
		y: 100		
	});	
	
	helpLabel = new Ext.form.Label({
		text: COMPLEMENTO_INTRO,
		width: 500,
		x: 20,
		y: 180
	});	
	
	helpLabelA = new Ext.form.Label({
		text: INTRO,
		width: 500,
		x: 20,
		y: 30
	});
	
	helpLabelB= new Ext.form.Label({
		text: PRIMEIRO_PASSO,
		width: 500,
		x: 20,
		y: 100
	});	
	
	dataBase = new Ext.form.ComboBox({
		store: [['', 'Todos'], ['01/01/@01/02/', 'Janeiro'], ['01/02/@01/03/', 'Fevereiro'],
			['01/03/@01/04/', 'Março'], ['01/04/@01/05/', 'Abril'], ['01/05/@01/06/', 'Maio'],
			['01/06/@01/07/', 'Junho'], ['01/07/@01/08/', 'Julho'], ['01/08/@01/09/', 'Agosto'],
			['01/09/@01/10/', 'Setembro'], ['01/10/@01/11/', 'Outubro'], 
			['01/11/@01/12/', 'Novembro'], ['01/12/@01/01/', 'Dezembro'],
		],
	    displayField: 'mesInR',
	    typeAhead: true,
	    mode: 'local',
	    triggerAction: 'all',	    
	    selectOnFocus: true,
		x: 350,
		y: 175,
		listeners: {
			"select" : function(fd, vl, xt) {
				getContrato();
			}
		}
	});
		
	cancelBtnR = new Ext.Button({
		text: 'Cancelar',
		style: 'position: relative; left: 530px; top: 319px;',
		minWidth: 80
	});
	
	avancarBtn = new Ext.Button({
		text: 'Avançar >>',
		style: 'position: relative; left: 400px; top: 340px;',
		minWidth: 80
	});
	
	retornarBtn = new Ext.Button({
		text: '<< Voltar',
		style: 'position: relative; left: 300px; top: 298px;',
		minWidth: 80
	});
	
	avancarBtn.on('click', function(){
		if (stagio <= 5) {
			stagio++;		
			mountLayout(stagio);
		}
	});
	
	retornarBtn.on('click', function(){
		if(stagio > 0) {
			stagio--;
			mountLayout(stagio);			
		}
	});
	
	cancelBtnR.on('click', function() {
		stagio = 0;
		mountLayout(stagio);
		boxSelect.hide();
		gdEdit.hide();
		assistente.hide();		
	});
	
	assistente = new Ext.Window({
		title: 'Assistente de Renovação de Contrato',
		id: "renovaForm",
		height: 400,
		width: 655,
		items: [helpLabelB, helpLabelA, helpLabel, dataBase, avancarBtn, cancelBtnR, retornarBtn, boxSelect, gdEdit],
		cls: 'x-window x-window-plain x-window-dlg',
		hidden: true,
		modal: true,
		closeAction: 'hide',
		resizable: false,
		onEsc: function() {
			this.hide();
		},
		layout: 'absolute',
		listeners: {
			'show': function() {
				boxSelect.hide();
				gdEdit.hide();
			}
		}
	});
	
	$('#ext-gen301').change(function() {
		alert('bosta');
	});	
	
	getAssistente = function() {		
		assistente.show();
	}
	
	mountLayout= function(stg) {
		switch (stg) {
			case 0:
				helpLabelA.setPosition(20, 30);
				helpLabelB.setPosition(20, 100);
				helpLabel.setPosition(20, 180);
				helpLabelA.setText(INTRO);
				helpLabelB.setText(PRIMEIRO_PASSO);
				helpLabel.setText(COMPLEMENTO_INTRO);
				dataBase.show();
				boxSelect.hide();
				break
			
			case 1:
				mountSelectBox(selectData);
				assistente.add(boxSelect);
				boxSelect.show();				
				dataBase.hide();
				helpLabelA.setPosition(20, 20);
				helpLabelB.setPosition(20, 60);
				helpLabel.setPosition(20, 300);				
				helpLabelA.setText(SEGUNDO_PASSO);
				helpLabelB.setText(SEGUNDO_COMPLEMENTO);
				helpLabel.setText("Selecione os contratos e clique em avançar.");
				assistente.render();
				break;
				
			case 2:
				getFinishRecord();
				boxSelect.hide();
				helpLabelA.setText(PODRE);
				helpLabelA.setPosition(20, 150);
				helpLabelB.hide();
				helpLabel.hide();
				gdEdit.hide();
				break;
				
			case 3:
				helpLabelA.setText(TERCEIRO_PASSO);				
				helpLabelB.setText(TERCEIRO_COMPLEMENTO);				
				helpLabel.setText("Edite os contratos e clique em avançar para finalizar a renovação.");
				helpLabelA.setPosition(20, 20);
				helpLabelB.show();
				helpLabel.show();
				gdEdit.reconfigure(mountStore(), colModel);
				gdEdit.show();
				break;
			
			case 4:
				prepareToPost();
				gdEdit.hide();
				helpLabelA.setText(QUARTO_PASSO);
				helpLabelB.setText(QUARTO_COMPLEMENTO);
				helpLabel.setText("Se tiver certo de que os dados estão crretos " + 
					"clique em terminar para finalizar a renovação de contratos.");
				avancarBtn.setText("Terminar");				
				break;
				
			case 5:
				stagio = 0;
				mountLayout(stagio);
				avancarBtn.setText("Avançar >>");
				assistente.hide();
				postRenovacao();
				break;
		}
	}
	
	getContrato = function() {
		selectData= [];
		var count = 0;				
		var oldPipe;
		$.get("../Renovacao", {
			from: "0",
			database: dataBase.getValue()},
		function(response) {
			if (response != "0") {
				oldPipe = unmountPipe(response);
				count= oldPipe.length;
				for (var i= 0; i < count; i++) {
					selectData[selectData.length] = [getPart(oldPipe[i], 1), getPart(oldPipe[i], 2)];					
				}
			} else {
				stagio = 0;
				mountLayout();
				assistente.hide();
				Ext.Msg.show({
					title: 'Erro de Renovação',
					msg: "Ocorreu um erro durante a renovação dos contratos!",
					width: 400,
					buttons: Ext.Msg.OK,
					icon: Ext.MessageBox.ERROR,
					modal: true
				});
			}
		});
	}
	
	getFinishRecord= function() {
		valuesSel = [];
		var oldPipe;
		$.get("../Renovacao", {
			from: "1",
			users: virgulaToPipe(boxSelect.getForm().findField("itemselector").getValue())},
		function(response) {
			if (response != "0") {
				oldPipe = unmountPipe(response);
				for(var i = 0; i < oldPipe.length; i++) {
					valuesSel[valuesSel.length] = [
						getPipeByIndex(oldPipe[i], 0),
						getPipeByIndex(oldPipe[i], 1),
						getPipeByIndex(oldPipe[i], 2),
						getPipeByIndex(oldPipe[i], 3),
						getPipeByIndex(oldPipe[i], 4),
					]
				}
			} else {
				stagio = 0;
				mountLayout();
				assistente.hide();
				Ext.Msg.show({
					title: 'Erro de Renovação',
					msg: "Ocorreu um erro durante a renovação dos contratos!",
					width: 400,
					buttons: Ext.Msg.OK,
					icon: Ext.MessageBox.ERROR,
					modal: true
				});
			}
		});
	}
	
	mountStore = function() {
		return new Ext.data.SimpleStore({
			fields: ['ctr', 'renov', 'venc', 'vig', 'val'],
			data: valuesSel
		});
	}
	
	mountRecord = function() {
		finalRecord = "";
		for(var i = 0; i < gdEdit.getStore().getTotalCount(); i++){
			if (i == 0) {
				finalRecord += gdEdit.getStore().getAt(i).get()				
			} else {
				
			}
		}
	}
	
	mountSelectBox = function(dataIn) {
		boxSelect = new Ext.form.FormPanel({
			labelWidth: 55,
			width:600,		
			items: [{
				xtype: 'itemselector',
				name: 'itemselector',
				fieldLabel: 'Contratos',
				dataFields: ['cod', 'ctrDesc'],
				fromData: dataIn,				
				toData: [],
				msWidth:266,				
				msHeight:180,
				valueField:"cod",
				displayField:"ctrDesc",
				toLegend:"Selecionados",
				fromLegend:"Disponíveis",
				toTBar:[{
					text:"Limpar Todos",
					width: 300,
					handler:function(){
						var i = boxSelect.getForm().findField("itemselector");
						i.reset.call(i);
					}
				}],
				fromTBar: [{
					text:"Selecionar Todos",
					width: 300,
					handler:function(){
						var i = boxSelect.getForm().findField("itemselector");
						i.turnSelect.call(i);
					}
				}]
				
			}],		
			x: 20,
			y: 100			
		});
	}
	
	prepareToPost = function() {
		dataToPost = "";
		var aux = virgulaToPipe(boxSelect.getForm().findField("itemselector").getValue());
		for (var i = 0; i < gdEdit.getStore().getTotalCount(); i++) {
			if (i == 0) {
				dataToPost+= getPipeByIndex(aux, i) + "@" + 
					formatDataPost(gdEdit.getStore().getAt(i).get('renov')) + "@" + 
					gdEdit.getStore().getAt(i).get('venc') + "@" + 
					gdEdit.getStore().getAt(i).get('vig') + "@" +
					gdEdit.getStore().getAt(i).get('val');
			} else {
				dataToPost+= "|" + getPipeByIndex(aux, i) + "@" + 
					formatDataPost(gdEdit.getStore().getAt(i).get('renov')) + "@" + 
					gdEdit.getStore().getAt(i).get('venc') + "@" + 
					gdEdit.getStore().getAt(i).get('vig') + "@" +
					gdEdit.getStore().getAt(i).get('val');
			}			
		}				
	}
	
	formatDataPost = function(text) {
		return Ext.util.Format.date(text, 'd/m/Y');
	}
	
	postRenovacao = function() {
		if (dataToPost != "") {
			$.get("../Renovacao", {
				from: "2",
				pipe: dataToPost},
			function(response) {
				if (response != "0") {						
					Ext.Msg.show({
						title: 'Erro de Renovação',
						msg: "Renovação de contrato efetuada com sucesso!",
						width: 400,
						buttons: Ext.Msg.OK,
						icon: Ext.MessageBox.INFO,
						modal: true
					});						
				} else {
					stagio = 0;
					mountLayout();
					assistente.hide();
					Ext.Msg.show({
						title: 'Erro de Renovação',
						msg: "Ocorreu um erro durante a renovação dos contratos!",
						width: 400,
						buttons: Ext.Msg.OK,
						icon: Ext.MessageBox.ERROR,
						modal: true
					});
				}
			});			
		} else {
			stagio = 0;
			mountLayout();
			assistente.hide();
			Ext.Msg.show({
				title: 'Erro de Renovação',
				msg: "Ocorreu um erro durante a escolha das opções do assistente contratos!",
				width: 400,
				buttons: Ext.Msg.OK,
				icon: Ext.MessageBox.ERROR,
				modal: true
			});
		}
	}
});