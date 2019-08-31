<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="com.marcsoftware.database.FaturaFranchising"%>
<%@page import="com.marcsoftware.database.ItensTabelaFranchising"%>
<%@page import="com.marcsoftware.database.ItensFaturaFranchising"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%><html xmlns="http://www.w3.org/1999/xhtml">
	
	<% Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	FaturaFranchising fatura = (FaturaFranchising) sess.load(FaturaFranchising.class, Long.valueOf(request.getParameter("id")));
	Query query = sess.createQuery("from ItensTabelaFranchising as i where i.tabela = :tabela");
	query.setEntity("tabela", fatura.getUnidade().getTabelaFranchising());
	List<ItensTabelaFranchising> itensTabela = (List<ItensTabelaFranchising>) query.list();
	%>
	
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/validation.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/lib/pilot_grid.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/comum/cadastro_fatura_franchising.js"></script>
	
	<title>Master Cadastro Tabela Franchising</title>
	
</head>
<body>
	<div id="obsWindow" class="removeBorda" title="Edição de observação" style="display: none;">
		<form id="formObs" onsubmit="return false;">
			<fieldset>
				<label for="obsw">Observações</label>
				<textarea readonly="readonly" name="obsw" id="obsw" rows="15" cols="60" class="textDialog ui-widget-content ui-corner-all"><%= (fatura.getObs() == null)? "" : fatura.getObs() %></textarea>
			</fieldset>
		</form>
	</div>
	<div id="novoWindow" class="removeBorda" title="Edição de observação" style="display: none;">
		<form id="formObs" onsubmit="return false;">
			<fieldset>				
				<label for="itTabela" style="font-weight: normal;">Itens</label>
				<select id="itTabela" style="width: 100%">
					<option value="">Selecione</option>					
					<%for(ItensTabelaFranchising iten: itensTabela) {%>
						<option value="<%= iten.getCodigo() + "@" + iten.getTipoCobranca() %>" ><%= iten.getTipoConta().getDescricao() %></option>
					<%}%>
				</select><br/>
				<div id="itenHora" class="cpEscondeWithHeight">
					<label for="itInicio">Hora Início</label>
					<input id="itInicio" name="itInicio" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, tipoHora)"/>
					<label for="itFim">Hora Fim</label>
					<input id="itFim" name="itFim" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, tipoHora)"/>
				</div>
				<div id="itenQtde" class="cpEscondeWithHeight">
					<label for="itQtde">Quantidade</label>
					<input id="itQtde" name="itQtde" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, onlyInteger);"/>
				</div>
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp"%>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="unidade"/>
	</jsp:include>
	<div id="centerAll" >
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="unidade"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formPost" name="formPost" method="post" action="../CadastroTabelaFranchising"  onsubmit= "return validForm(this)" >
				<input type="hidden" id="unidadeId" name="unidadeId" value="<%= fatura.getUnidade().getCodigo() %>" />
				<div id="localEdItens" ></div>
				<div id="localItem"></div>
				<div id="deletedsItem"></div>
				<div id="editedsItem"></div>				
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Tabela Franchising"/>			
					</jsp:include>
					<div class="topContent">
						<div id="codigo" class="textBox" style="width: 70px;">
							<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 70px;" readonly="readonly"  value="<%= Util.zeroToLeft(fatura.getCodigo(), 4) %>"/>
						</div>
						<div id="unidade" class="textBox" style="width: 70px;">
							<label>Unidade</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" style="width: 70px;" readonly="readonly"  value="<%= fatura.getUnidade().getReferencia() %>"/>
						</div>
						<div id="inicio" class="textBox" style="width: 70px;">
							<label>Início</label><br/>
							<input id="inicioIn" name="inicioIn" type="text" style="width: 70px;" readonly="readonly"  value="<%= Util.parseDate(fatura.getDataInicio(), "dd/MM/yyyy") %>"/>
						</div>
						<div id="fim" class="textBox" style="width: 70px;">
							<label>Fim</label><br/>
							<input id="fimIn" name="fimIn" type="text" style="width: 70px;" readonly="readonly"  value="<%= (fatura.getDataFim() == null)? "" : Util.parseDate(fatura.getDataFim(), "dd/MM/yyyy") %>"/>
						</div>
						<div id="vencimento" class="textBox" style="width: 70px;">
							<label>Vencimento</label><br/>
							<input id="vencimentoIn" name="vencimentoIn" type="text" style="width: 70px;" readonly="readonly"  value="<%= (fatura.getVencimento() == null)? "" : Util.parseDate(fatura.getVencimento(), "dd/MM/yyyy") %>"/>
						</div>
						<div id="pagamento" class="textBox" style="width: 240px;">
							<label>Forma de Pagamento</label><br/>
							<input id="pagamentoIn" name="pagamentoIn" type="text" style="width: 240px;" readonly="readonly"  value="<%= (fatura.getFormaPagamento() == null)? "" : fatura.getFormaPagamento().getDescricao() %>"/>
						</div>
						<div id="status" class="textBox" style="width: 70px;">
							<label>Status</label><br/>
							<input id="statusIn" name="statusIn" type="text" style="width: 70px;" readonly="readonly"  value="<%= (fatura.getStatus().equals("a"))? "Em Aberto" : "Finalizada" %>"/>
						</div>
						<div class="area" id="obs" name="obs" style="margin-bottom: 30px">
							<div class="headerText">
								<label>Observações</label><span class="ui-widget-content ui-corner-all" id="openObs">&nbsp;</span>							
							</div>
							<textarea cols="112" readonly="readonly" rows="5" id="obsIn" name="obsIn"><%=(fatura.getObs() == null)? "" : fatura.getObs() %></textarea>							
						</div>
					</div>
				</div>
				<div class="buttonContent">
					<div class="formGreenButton">
						<input id="saveObs" name="saveObs" disabled="disabled" class="grayButtonStyle" type="button" value="Salvar" onclick="makeObs()" />
					</div>				
					<div class="formGreenButton">
						<input id="editObs" name="editObs" style="margin-bottom: 15px" class="greenButtonStyle" type="button" value="Editar Obs" onclick="makeObs()" />
					</div>
					<div class="formGreenButton">
						<input class="greenButtonStyle" type="button" value="Nova Cob." onclick="showNovoWd()"/>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid" >
						<%query = sess.createQuery("from ItensFaturaFranchising as i where i.id.fatura = :fatura");
						query.setEntity("fatura", fatura);
						List<ItensFaturaFranchising> itensFatura = (List<ItensFaturaFranchising>) query.list();
						int gridLines = itensFatura.size();
						DataGrid dataGrid = new DataGrid("");
						dataGrid.addColum("8", "Lanç");
						dataGrid.addColum("22", "Documento");
						dataGrid.addColum("13", "Emissão");
						dataGrid.addColum("47", "Descrição");
						dataGrid.addColum("10", "Valor");
						for(ItensFaturaFranchising iten: itensFatura) {
							dataGrid.setId(String.valueOf(iten.getId().getLancamento().getCodigo()));
							dataGrid.addData(String.valueOf(iten.getId().getLancamento().getCodigo()));
							dataGrid.addData(iten.getId().getLancamento().getDocumento());
							dataGrid.addData(Util.parseDate(iten.getId().getLancamento().getEmissao(), "dd/MM/yyyy"));
							dataGrid.addData(iten.getId().getLancamento().getConta().getDescricao());
							dataGrid.addData(Util.formatCurrency(iten.getId().getLancamento().getValor()));
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));
						%>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<% sess.close(); %>
	</div>
</body>
</html>