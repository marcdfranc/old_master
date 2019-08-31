<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.ItensCompra"%>
<%@page import="com.marcsoftware.database.Fornecedor"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.PrestadorServico"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.database.Compra"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.database.Insumo"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.ParcelaCompra"%>
<%@page import="com.marcsoftware.database.Ramo"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%boolean isJuridica = request.getParameter("origem").equals("forn");
	boolean haveParcela = false;
	boolean isEdition = (request.getParameter("state") != null)? true : false;
	long idPessoa = 0;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
	String infoFornecedor = "";
	List<ItensCompra> itensCompra = null;
	Fornecedor fornecedor = null;
	PrestadorServico prestadorServico = null;
	Compra compra = null;
	Unidade unidade = null;
	List<ItensCompra> itenList= null;
	double vlrTotal = 0;
	int startIndex = 0;
	String documento = "";
	if (isEdition) {
		compra = (Compra) sess.get(Compra.class, Long.valueOf(request.getParameter("id")));
		idPessoa = compra.getFornecedor().getCodigo();
		unidade = compra.getUnidade();
		query = sess.createQuery("select descricao from Informacao as i where i.pessoa = :pessoa and i.principal = 's'");
		query.setEntity("pessoa", compra.getFornecedor());
		infoFornecedor = query.uniqueResult().toString();
		if (isJuridica) {
			fornecedor = (Fornecedor) sess.get(Fornecedor.class, compra.getFornecedor().getCodigo());
		} else {
			prestadorServico = (PrestadorServico) sess.get(PrestadorServico.class, compra.getFornecedor().getCodigo());
		}
		query = sess.createQuery("from ItensCompra as i where i.id.compra = :compra");
		query.setEntity("compra", compra);
		itensCompra = (List<ItensCompra>) query.list();
		startIndex = itensCompra.size();
		query = sess.createQuery("from ParcelaCompra as p where p.id.compra = :compra");
		query.setEntity("compra", compra);
		if (query.list().size() > 0) {
			List<ParcelaCompra> lista = (List<ParcelaCompra>) query.list();
			documento = lista.get(0).getId().getLancamento().getDocumento();
			haveParcela = true;
		}
	} else {
		idPessoa = Long.valueOf(request.getParameter("idFornecedor"));
		query = sess.createQuery("select descricao from Informacao as i where i.pessoa = :pessoa and i.principal = 's'");
		if (isJuridica) {
			fornecedor = (Fornecedor) sess.get(Fornecedor.class, Long.valueOf(request.getParameter("idFornecedor"))); 
			query.setEntity("pessoa", fornecedor);
		} else {
			prestadorServico = (PrestadorServico) sess.get(PrestadorServico.class, Long.valueOf(request.getParameter("idFornecedor")));
			query.setEntity("pessoa", prestadorServico);
		}
		infoFornecedor = query.uniqueResult().toString();		
		unidade = (Unidade) sess.get(Unidade.class, Long.valueOf(session.getAttribute("unidade").toString()));
	}
	query = sess.createQuery("from Insumo as i where ativo = 'a' and i.ramo = :ramo");
	if (isJuridica) {
		query.setEntity("ramo", fornecedor.getRamo());
	} else {
		query.setEntity("ramo", prestadorServico.getRamo());
	}
	List<Insumo> insumoList = (List<Insumo>) query.list();
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Pedidos</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>	
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/default.js" ></script>
	<script type="text/javascript" src="../js/comum/pedido.js" ></script>
</head>
<body>
	<jsp:include page="../inc/pdv.jsp"></jsp:include>
	<div id="geracaoWindow" class="removeBorda" title="Geração de Parcelas" style="display: none;">			
		<form id="geraWindow" onsubmit="return false;">
			<fieldset>
				<label for="emitDoc">Dt. Emissão da Nota</label>
				<input type="text" name="emitDoc" id="emitDoc" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, onlyDate);"/>
				<label for="entrada">Vlr. Entrada</label>
				<input type="text" name="entrada" value="0.00" id="entrada" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, decimalNumber);"/>
				<label for="qtdeParcela">Número de Parelas</label>
				<input type="text" name="qtdeParcela" id="qtdeParcela" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, onlyInteger);"/>
				<label for="iniParcela">Dt. 1ª Parcela</label>
				<input type="text" name="iniParcela" id="iniParcela" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, onlyDate);" />
				<label for="docParcela">N° Documento</label>
				<input type="text" name="docParcela" id="docParcela" class="textDialog ui-widget-content ui-corner-all" />
			</fieldset>
		</form>
	</div>
	<div id="novoInsumoWindow" class="removeBorda" title="Geração de Parcelas" style="display: none;">			
		<form id="insumoWindow" onsubmit="return false;">
			<fieldset>
				<label for="descInsumo">Descrição Insumo</label>
				<input type="text" name="descInsumo" id="descInsumo" class="textDialog ui-widget-content ui-corner-all"/>
				<label for="tipoInsumo">Tipo</label><br/>
				<select id="tipoInsumo" name="tipoInsumo" style="width: 100%">
					<option value="p">Produto</option>
					<option value="s">Serviço</option>
				</select>
				<label for="statusInsumo">Status</label><br/>
				<select id="statusInsumo" name="statusInsumo" style="width: 100%">
					<option value="a">Ativo</option>								
					<option value="d">Descontinuado</option>
				</select>
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>	
	<%if (isJuridica) {%>
		<jsp:include page="../inc/menu.jsp">
			<jsp:param name="currentPage" value="fornecedor"/>
		</jsp:include>	
	<%} else {%>
		<jsp:include page="../inc/menu.jsp">
			<jsp:param name="currentPage" value="prestador"/>
		</jsp:include>
	<%}%>	
	<div id="centerAll">
		<%if (isJuridica) {%>
			<jsp:include page="../inc/submenu.jsp">
				<jsp:param name="currentPage" value="fornecedor"/>
			</jsp:include>
		<%} else {%>
			<jsp:include page="../inc/submenu.jsp">
				<jsp:param name="currentPage" value="prestador"/>
			</jsp:include>
		<%}%>
		<div id="formStyle">
			<form id="unit" method="post" action="../CadastroPosicao">
				<input type="hidden" id="origem" name="origem" value="<%= (isJuridica) ? "forn" : "prest" %>" />
				<input type="hidden" id="unidadeId" name="unidadeId" value="<%= unidade.getCodigo() %>" />
				<input id="startIndex" name="startIndex" type="hidden" value="<%= startIndex %>"/>
				<div id="deletedsContent"></div>
				<div id="geralDate" class="alignHeader">
					<%if (isJuridica) {%>
						<input type="hidden" id="ramoId" name="ramoId" value="<%= fornecedor.getRamo().getCodigo() %>" />
						<jsp:include page="../inc/feedback.jsp">
							<jsp:param name="currPage" value="Ped.Produtos"/>			
						</jsp:include>
						<div id="abaMenu">
							<div class="aba2">
								<a href="<%="cadastro_fornecedor.jsp?state=1&id=" + idPessoa %>">Cadastro</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="<%="bordero_fornecedor.jsp?origem=" + request.getParameter("origem") + "&idFornecedor=" + idPessoa%>">Borderô</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>							
							<%if (isEdition) {%>
								<div class="aba2">
									<a href="<%="pedido.jsp?idFornecedor=" + idPessoa + "&origem=" +  request.getParameter("origem")%>">Gerar Pedido</a>
								</div>
							<%} else {%>
								<div class="sectedAba2">
									<label>Pedido</label>
								</div>
							<%}%>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="<%="compra.jsp?idFornecedor=" + idPessoa + "&origem=" +  request.getParameter("origem")%>">Histórico de Pedidos</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>					
							<div class="aba2">
								<a href="<%="agrupamento.jsp?idFornecedor=" + idPessoa + "&origem=" +  request.getParameter("origem")%>">Histórico de Faturas</a>
							</div>
							<%if (isEdition) {%>
								<div class="sectedAba2">
									<label>></label>	
								</div>
								<div class="sectedAba2">
									<label>Pedido</label>
								</div>
								<div class="sectedAba2">
									<label>></label>	
								</div>
								<div class="aba2">
									<a href="<%="parcela_compra.jsp?id=" + compra.getCodigo() + "&origem=" +  request.getParameter("origem")%>">Parcelamento</a>
								</div>
							<%}%>
						</div>
					<%} else {%>
						<input type="hidden" id="ramoId" name="ramoId" value="<%= prestadorServico.getRamo().getCodigo() %>" />
						<jsp:include page="../inc/feedback.jsp">
							<jsp:param name="currPage" value="Ped. Serviços"/>			
						</jsp:include>
						<div id="abaMenu">
							<div class="aba2">
								<a href="<%="cadastro_prestador_servico.jsp?state=1&id=" + prestadorServico.getCodigo()%>">Cadastro</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="<%="bordero_fornecedor.jsp?origem=" + request.getParameter("origem") + "&idFornecedor=" + idPessoa%>">Borderô</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<%if (isEdition) {%>
								<div class="aba2">
									<a href="<%="pedido.jsp?idFornecedor=" + prestadorServico.getCodigo() + "&origem=" +  request.getParameter("origem")%>">Gerar Pedido</a>
								</div>
							<%} else {%>
								<div class="sectedAba2">
									<label>Pedido</label>
								</div>
							<%}%>
							<div class="sectedAba2">
								<label>></label>	
							</div>					
							<div class="aba2">
								<a href="<%="compra.jsp?idFornecedor=" + prestadorServico.getCodigo() + "&origem=" +  request.getParameter("origem")%>">Histórico de Pedidos</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="<%="agrupamento.jsp?idFornecedor=" + idPessoa + "&origem=" +  request.getParameter("origem")%>">Histórico de Faturas</a>
							</div>
							<%if (isEdition) {%>
								<div class="sectedAba2">
									<label>></label>	
								</div>
								<div class="sectedAba2">
									<label>Pedido</label>
								</div>
								<div class="sectedAba2">
									<label>></label>	
								</div>
								<div class="aba2">
									<a href="<%="parcela_compra.jsp?id=" + compra.getCodigo() + "&origem=" +  request.getParameter("origem")%>">Parcelamento</a>
								</div>
							<%}%>
						</div>
					<%}%>
					<div class="topContent">
						<div class="textBox" id="unidadeRef" name="unidadeRef" style="width: 65px;">
							<label>Cód. Unid.</label><br/>
							<input id="unidadeRefIn" name="unidadeRefIn" type="text" style="width:65px" readonly="readonly" value="<%= unidade.getReferencia() %>"/>
						</div>
						<div id="unidade" class="textBox" style="width: 265px;" >
							<label>Unidade</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" style="width: 265px;" value="<%= Util.initCap(unidade.getDescricao())%>" readonly="readonly" />
						</div>
						<div id="cadastro" class="textBox" style="width:70px">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" type="text" style="width:70px" onkeydown="mask(this, dateType)" value="<%=(isEdition)? Util.parseDate(compra.getCadastro(), "dd/MM/yyyy") : Util.getToday() %>"/>						
						</div>
						<div id="documento" class="textBox" style="width: 200px;" >
							<label>Documento</label><br/>
							<input id="documentoIn" name="documentoIn" type="text" style="width: 200px;" value="<%= documento %>" readonly="readonly" />
						</div>
						<div id="codigo" class="textBox" style="width: 70px;">
							<label>Cód. Ped.</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 70px;" readonly="readonly" value="<%=(isEdition)? compra.getCodigo() : "" %>" />
						</div>					
						<%if (isJuridica) {%>						
							<div id="idFornecedor" class="textBox" style="width: 70px;" >
								<label>Ref. Forn.</label><br/>
								<input id="idFornecedorIn" name="idFornecedorIn" type="text" style="width: 70px;" readonly="readonly" value="<%=fornecedor.getCodigo()%>" />
							</div>
							<div id="fantasia" class="textBox" style="width: 330px">
								<label>Nome Fantasia</label><br/>					
								<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 330px" value="<%=Util.initCap(fornecedor.getFantasia())%>" readonly="readonly" />
							</div>
							
							<div id="cnpj" class="textBox" style="width: 130px">
								<label>Cnpj</label><br/>					
								<input id="cnpjIn" name="cnpjIn" type="text" style="width: 130px" class="required" value="<%=Util.mountCnpj(fornecedor.getCnpj())%>" readonly="readonly" />
							</div>
							<div id="ramo" class="textBox" style="width: 287px">
								<label>Ramo</label><br/>					
								<input id="ramoIn" name="ramoIn" type="text" style="width: 287px" value="<%=Util.initCap(fornecedor.getRamo().getDescricao())%>" readonly="readonly" />
							</div>
							<div id="nomeContato" class="textBox" style="width: 260px;">
								<label>Nome do Contato</label><br/>					
								<input id="nomeContatoIn" name="nomeContatoIn" type="text" style="width: 260px" value="<%=Util.initCap(fornecedor.getContato())%>" readonly="readonly" />
							</div>
							<div id="infoFornecedor" class="textBox" style="width: 85px">
								<label>Telefone</label><br/>					
								<input id="infoFornecedorIn" name="infoFornecedorIn" type="text" style="width: 85px" class="required" value="<%=infoFornecedor%>" readonly="readonly" />
							</div>
						<%} else {%>
							<div id="codigo" class="textBox" style="width: 80px;">
								<label>Ref. Prest.</label><br/>
								<input id="idFornecedorIn" name="idFornecedorIn" type="text" style="width: 80px;" value="<%= prestadorServico.getCodigo() %>" class="required" readonly="readonly"/>
							</div>
							<div id="nome" class="textBox" style="width: 250px;">
								<label>Nome</label><br/>
								<input id="nomeIn" name="nomeIn" type="text" style="width: 250px;" value="<%=Util.initCap(prestadorServico.getNome())%>"  readonly="readonly" />
							</div>
							<div id="cpf" class="textBox" style="width: 105px;">
								<label>Cpf</label><br/>
								<input id="cpfIn" name="cpfIn" type="text" style="width: 100px" value="<%=Util.mountCpf(prestadorServico.getCpf())%>" readonly="readonly" />
							</div>							
							<div id="nascimento" class="textBox" style="width: 78px;">
								<label>Telefone</label><br/>
								<input id="nascimentoIn" name="nascimentoIn" type="text" style="width: 78px;" value="(16)333-5398" readonly="readonly"/>
							</div>
						<%}%>
					</div>					
				</div>
				<%if (isEdition && (!haveParcela)) {%>
					<div class="buttonContent" style="margin-right: 320px;" >
						<div class="formGreenButton">						
							<input id="gera" name="gera" class="greenButtonStyle" type="button" value="Gerar Parcela" onclick="generate()"/>
						</div>
					</div>
				<%}%>
				<div id="mainContent">
					<div id="fornec" class="bigBox" >
						<div class="indexTitle">
							<h4>Itens do Pedido</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div class="textBox">
							<label>Código</label><br/>
							<select id="insumoId" name="insumoId" <% 
								if (isEdition) {
									out.print("disabled=\"disabled\"");
								}
								%> onchange="changeDesc(this)">	
								<option value="">Selecione</option>							
								<%for(Insumo insumo: insumoList) {
									out.print("<option value=\"" + 
											insumo.getCodigo() + "\">" + 
										insumo.getCodigo() + "</option>");
								}%>
							</select>
						</div>
						<div class="textBox">
							<label>Descrição</label><br/>
							<select id="insumoDesc" name="insumoDesc" <% 
								if (isEdition) {
									out.print("disabled=\"disabled\"");
								}
								%> onchange="changeCod(this)">
								<option value="">Selecione</option>
								<%for(Insumo insumo: insumoList) {
									out.print("<option value=\"" + 
											insumo.getTipo() + "\">" + 
										insumo.getDescricao() + "</option>");
								}%>
							</select>
						</div>
						<div class="textBox" style="width: 100px;" >
							<label>Custo Unit.</label><br/>
							<input id="custoIn" name="custoIn" type="text" style="width: 100px;" value="0.00" onkeydown="mask(this, decimalNumber );" />
						</div>
						<div id="qtde" class="textBox" style="width: 30px;" >
							<label>Qtde</label><br/>
							<input id="qtdeIn" name="qtdeIn" type="text" style="width: 30px;" value="1" onkeydown="mask(this, onlyInteger);" />
						</div>						
					</div>
					<%if (!isEdition) {%>
						<div class="buttonContent" style="margin-bottom: 20px;" >
							<div class="formGreenButton">						
								<input id="cadInsumo" name="cadInsumo" class="greenButtonStyle" type="button" value="Novo" onclick="addInsumo()"/>
							</div>
						</div>
					<%}%>
					<div id="dataGrid">
						<%DataGrid dataGrid = new DataGrid("#");
						dataGrid.addColum("10", "Codigo");
						dataGrid.addColum("45", "Descricao");
						dataGrid.addColum("10", "Tipo");
						dataGrid.addColum("10", "Vlr. Unit.");
						dataGrid.addColum("10", "Qtde");
						dataGrid.addColum("10", "valor");
						dataGrid.addColum("5", "Ck");
						int gridLines = 0;
						if (isEdition) {
							query = sess.createQuery("from ItensCompra as i where i.id.compra = :compra");
							query.setEntity("compra", compra);
							itenList = (List<ItensCompra>) query.list();
							vlrTotal = 0;
							gridLines = itenList.size();
							for(ItensCompra iten: itenList) {
								dataGrid.setId("");
								dataGrid.addData(String.valueOf(iten.getId().getInsumo().getCodigo()));
								dataGrid.addData(iten.getId().getInsumo().getDescricao());
								if (iten.getId().getInsumo().getTipo().equals("s")) {
									dataGrid.addData("Serviço");
								} else {
									dataGrid.addData("Produto");
								}
								dataGrid.addData(Util.formatCurrency(iten.getCusto()));
								dataGrid.addData(String.valueOf(iten.getQuantidade()));
								dataGrid.addData(Util.formatCurrency(iten.getCusto() * iten.getQuantidade()));
								vlrTotal+= iten.getCusto() * iten.getQuantidade();
								dataGrid.addCheck("checkrowTabela");
								dataGrid.addRow();
							}
						}
						if (isEdition) {
							dataGrid.addTotalizadorRight("Total a pagar", Util.formatCurrency(vlrTotal));
						} else {
							dataGrid.addTotalizadorRight("Total a pagar", "0.00");
						}
						dataGrid.makeTotalizadorRight();
						out.print(dataGrid.getTable(gridLines));						
						%>
					</div>
					<div class="buttonContent">
						<div class="formGreenButton">
							<input name="removeTabela" class="greenButtonStyle" type="button" 
								<%if (isEdition) {
									out.print("disabled=\"disabled\"");
								}%>
							 value="Excluir" onclick="removeRowInsumo()" />
						</div>					
						<div class="formGreenButton" >
							<input id="specialButton" name="insertTabela" class="greenButtonStyle" type="button"  
								<%if (isEdition) {
									out.print("disabled=\"disabled\"");
								}%>	value="Inserir" onclick="addRowInsumo()" />
						</div>
					</div>
					<div class="buttonContent" style="margin-top: 50px;">
						<%if (isEdition) {%>
							<div class="formGreenButton">						
								<input class="greenButtonStyle" type="button" value="Salvar" />
							</div>
						<%} else {%>
							<div class="formGreenButton">						
								<input class="greenButtonStyle" type="button" value="Salvar" onclick="savePedido()" />
							</div>							
						<%}%>
					</div>	
				</div>		
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>