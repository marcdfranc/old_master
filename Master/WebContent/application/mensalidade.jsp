<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@page import="com.marcsoftware.database.Conta"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Usuario"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Mensalidade"%>
<%@page import="com.marcsoftware.database.Informacao"%>
<%@page import="com.marcsoftware.database.Conta"%>

<%@page import="java.util.Date"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.marcsoftware.database.FormaPagamento"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	String telefone = "";
	int atrasadas= 0;
	double totalAtraso = 0;
	ArrayList<String> gridValues = new ArrayList<String>();
	Query query;
	if (request.getParameter("id") == null) {
		query= sess.createQuery("select distinct(d.usuario) from  Dependente as d where d.codigo = :dependente");			
		query.setLong("dependente", Long.valueOf(request.getParameter("dep")));
	} else {
		query= sess.createQuery("from Usuario as u where u.codigo = :codigo");
		query.setLong("codigo", Long.valueOf(request.getParameter("id")));
	}
	
	Usuario usuario= (Usuario) query.uniqueResult();
	
	query = sess.createQuery("from Conta as c where c.pessoa.codigo = :unidade");
	query.setLong("unidade", usuario.getUnidade().getCodigo());
	List<Conta> contas = (List<Conta>) query.list();
	
	query = sess.createQuery("select distinct m.vigencia from Mensalidade as m where m.usuario= :usuario order by m.vigencia");
	query.setEntity("usuario", usuario);
	List<Long> vigencia = (List<Long>) query.list();	
	
	Long vigAtual = (vigencia.size() != 0)? vigencia.get(vigencia.size() -1): 0;
	
	query= sess.createQuery("from Mensalidade as m where m.usuario= :usuario and m.vigencia = :vigencia order by m.lancamento.vencimento");	
	query.setEntity("usuario", usuario);	
	query.setLong("vigencia", vigAtual);
	List<Mensalidade> mensalidade= (List<Mensalidade>) query.list();
	
	query = sess.getNamedQuery("infoPrincipalByCode").setLong("codigo", usuario.getCodigo());	
	telefone= (query.list().size() == 0)? "" : (String) query.uniqueResult();
	
	query = sess.createQuery("from FormaPagamento as f order by f.descricao");
	List<FormaPagamento> pagamentoList = (List<FormaPagamento>) query.list();
	String tpPagamento = "";
	String pagId = "2";
	if (pagamentoList.size() > 0) {
		for(int i = 0; i < pagamentoList.size(); i++) {
			tpPagamento+= (i == 0)? pagamentoList.get(i).getCodigo() + "@" +
					pagamentoList.get(i).getDescricao() + "@" + pagamentoList.get(i).getConcilia() 
					: "|" +	pagamentoList.get(i).getCodigo() + "@" + 
					pagamentoList.get(i).getDescricao() + "@" + 
					pagamentoList.get(i).getConcilia();
		}
	}
	
	%>

<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />	
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/comum/mensalidade.js" ></script>	
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>	
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	
	<title>Master - Mensalidades</title>
	
	
</head>
<body>
	<div id="obsWindow" class="removeBorda" title="Edição de observação" style="display: none;">
		<form id="formObs" onsubmit="return false;">
			<fieldset>
				<label for="obsw">Observações</label>
				<textarea name="obsw" id="obsw" rows="30" cols="60" class="textDialog ui-widget-content ui-corner-all"><%= (usuario.getObservacao() == null)? "" : usuario.getObservacao() %></textarea>
			</fieldset>
		</form>
	</div>
	<div id="conciliaWindow" class="removeBorda" title="Pagamento de Mensalidade" style="display: none;">			
		<form id="formPagamento" onsubmit="return false;">
			<fieldset>
				<input type="hidden" name="dtEmit" id="dtEmit" class="textDialog ui-widget-content ui-corner-all" readonly="readonly" value="<%= Util.getToday() %>" />
				<label for="vlrTotal">Valor Atual</label>
				<input type="text" name="vlrTotal" id="vlrTotal" class="textDialog ui-widget-content ui-corner-all" readonly="readonly" style="height: 35px; font-size: 30px; color: #007CC3" />
				<div id="paramBoxRd" style="float: left; margin-top: 10px; margin-right: 17px; margin-bottom: 15px;">
					<input type="checkbox" id="cobBoleto" name="cobBoleto" onchange="atualizaTotal()"/>
					<label for="cobBoleto">Cobrar Boleto</label>
				</div>
				<div id="paramJuros" style="float: left; margin-top: 10px; margin-right: 17px; margin-bottom: 15px;">					
					<input type="checkbox" id="lancJuros" name="lancJuros" checked="checked" onchange="atualizaTotal()"/>
					<label for="lancJuros">Cobrar Juros</label>
				</div>
				<div style="float: left; margin-top: 10px; margin-right: 17px; margin-bottom: 15px;">
					<input type="checkbox" id="impCupon" name="impCupon" checked="checked" onchange="atualizaTotal()"/>
					<label for="impCupon" >Emitir Cupom</label>
				</div>
				<div style="margin-top: 10px; margin-bottom: 15px;">
					<input type="checkbox" id="impNf" name="impNf" onchange="atualizaTotal()"/>
					<label for="impNf" >Emitir Nota Fiscal</label>
				</div><br />
				<label for="tpPagamento">Pagamento</label><br/>
				<select id="tpPagamento" style="width: 100%" onchange="adjustPagamento(this)">
					<%if (pagamentoList.size() > 0) {
						for(FormaPagamento pagamento : pagamentoList) {
							if (pagamento.getCodigo() == new Long(2)) {%>
								<option value="<%= pagamento.getCodigo() + "@" + pagamento.getConcilia()%>" selected="selected" ><%= pagamento.getDescricao()%> </option>
							<%} else {%>
								<option value="<%= pagamento.getCodigo() + "@" + pagamento.getConcilia()%>" ><%= pagamento.getDescricao()%> </option>
							<%}%>
						<%}						
					} else {%>
						<option value="">Selecione</option>
					<%}%>
				</select><br/>				
				<div id="blocoShow" class="cpEscondeWithHeight">
					<label for="numConcilio">Nº de controle</label>
					<input type="text" name="numConcilio" id="numConcilio" class="textDialog ui-widget-content ui-corner-all"  />
					<label for="dtVenc">Vencimento</label>
					<input type="text" name="dtVenc" id="dtVenc" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, dateType);" onblur="atualizaTotal()"/>
				</div>
				<label for="aPagar">Valor a Pagar</label>
				<input type="text" name="aPagar" id="aPagar" class="textDialog ui-widget-content ui-corner-all" readonly="readonly" value="0.00" style="height: 35px; font-size: 30px; color: #007CC3" />
				<label for="money">Dinheiro</label>
				<input type="text" name="money" id="money" class="textDialog ui-widget-content ui-corner-all" value="0.00" onkeydown="mask(this, decimalNumber);" onblur="getTroco()" style="height: 35px; font-size: 30px; color: #666666;"/>
				<label for="troco">Troco</label>
				<input type="text" name="troco" id="troco" class="textDialog ui-widget-content ui-corner-all" readonly="readonly" value="0.00" style="height: 35px; font-size: 30px; color: #007CC3"/>
			</fieldset>
		</form>
	</div>
	<div id="boletoWindow" class="removeBorda" title="Impressão de Faturas e boletos" style="display: none;">
		<form id="formPagamento" onsubmit="return false;">
			<label for="conta">Conta</label>
			<select id="conta" name="conta" style="width: 100%">
				<%for (Conta conta: contas) {
					out.println("<option value=\"" + conta.getCodigo() + "\">" + 
						conta.getBanco().getDescricao() + " - " + conta.getNumero() + "</option>");
				}%>
			</select><br /><br />
			<label for="getBoleto">Cobrar Boleto</label>
			<select id="getBoleto" name="getBoleto">
				<option value="s">Sim</option>
				<option value="n">Não</option>
			</select><br /><br />
			<label for="getJurosMais">Cobrar juros</label>
			<select id="getJurosMais" name="getJurosMais">
				<option value="s">Sim</option>
				<option value="n">Não</option>
			</select><br /><br />
			<label for="dtVencimento">Vencimento para o Agrupamento</label>
			<input type="text" name="dtVencimento" id="dtVencimento" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, typeDate)" />
		</form>
	</div>	
	<div id="negociaWindow" class="removeBorda" title="Negociação" style="display: none;">			
		<form id="formNegociacao" onsubmit="return false;">
			<fieldset>
				<label for="dtNegocio">Data</label>
				<input type="text" name="dtNegocio" id="dtNegocio" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, dateType);"/>
				<label for="jurosNegocio">Lançar Juros</label>
				<div id="paramBoxRd2" class="checkRadio ui-corner-all">
					<label class="labelCheck" >Sim</label>
					<input type="radio" id="jurosNegocio" name="jurosNegocio" value="s" checked="checked"/>
					<label class="labelCheck" >Não</label>
					<input type="radio" id="jurosNegocio" name="jurosNegocio" value="n"/>
				</div>
				<label for="desconto">Desconto</label>
				<input type="text" name="desconto" id="desconto" class="textDialog ui-widget-content ui-corner-all" value="0.00" onkeydown="mask(this, decimalNumber);"/>
			</fieldset>
		</form>
	</div>
	<div id="addMensalWindow" class="removeBorda" title="Adição de Parcelas" style="display: none;">			
		<form id="formAddMensal" onsubmit="return false;">
			<fieldset>
				<label for="inicioAdd">Início</label>
				<input type="text" name="inicioAdd" id="inicioAdd" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, dateType);"/>
				<label for="mora">% Mora</label>
				<input type="text" name="mora" id="mora" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, decimalNumber);"/>
				<label for="qtdeAdd">Quantidade</label>
				<input type="text" name="qtdeAdd" id="qtdeAdd" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, onlyInteger);"/>
				<label for="valMensalAdd">Valor</label>
				<input type="text" name="valMensalAdd" id="valMensalAdd" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, decimalNumber);"/>
				<label for="tpLancamento">Pagamento</label><br/>
				<select id="tpLancamento" style="width: 100%">				
					<option value="63">Adesão</option>					
					<option value="64">Renovação</option>
					<option value="61">Mensalidade</option>					
				</select><br/>
			</fieldset>
		</form>
	</div>
	<div id="renovaWindow" class="removeBorda" title="Renovação" style="display: none;">			
		<form id="formRenova" onsubmit="return false;">
			<fieldset>
				<label for="dtRenov">Vencimento Renovação</label>
				<input type="text" name="dtRenov" id="dtRenov" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, dateType);"/>
				<label for="vlrRenovacao">Valor Renovação</label>
				<input type="text" name="vlrRenovacao" id="vlrRenovacao" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, decimalNumber);"/>
				<label for="vencRenovacao">Dia de Vencimento</label><br/>
				<select id="vencRenovacao" style="width: 100%">
					<option value="1">Dia 01</option>
					<option value="5">Dia 05</option>
					<option value="10">Dia 10</option>
					<option value="15">Dia 15</option>
					<option value="20">Dia 20</option>
					<option value="25">Dia 25</option>
				</select><br/>
				<label for="vigRenovacao">Vigência</label><br/>
				<select id="vigRenovacao" style="width: 100%">
					<option value="0">Selecione</option>
					<option value="6">6 Meses</option>
					<option value="12">12 Meses</option>
					<option value="18">18 Meses</option>
					<option value="24">24 Meses</option>
				</select><br/>
				<label for="qtdeRenovacao">Quantidade</label>
				<input type="text" name="qtdeRenovacao" id="qtdeRenovacao" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, onlyInteger);"/>
				<label for="valRenov">Valor</label>
				<input type="text" name="valRenov" id="valRenov" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, decimalNumber);"/>
			</fieldset>
		</form>
	</div>
	<div id="cuponWindow" class="removeBorda" title="Impressão não Fiscal" style="display: none;">			
		<form id="formImpCupon" onsubmit="return false;">
			<fieldset>
				<p>Digite o valor em dinheiro pago pelo cliente.</p>
				<label for="moneyCupon">Dinheiro</label>
				<input type="text" name="moneyCupon" id="moneyCupon" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, decimalNumber)"/>
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="clienteF"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="clienteF"/>
		</jsp:include>
		<div id="formStyle">
			<form id="parc" method="get">
				<input type="hidden" id="cbFormaPag" name="cbFormaPag" value="<%= tpPagamento %>"/>
				<input type="hidden" id="pagId" name="pagId" value="<%= pagId %>"/>
				<div id="localEdTabela" ></div>
				<div id="localTabela"></div>
				<div id="deletedsServ"></div>
				<div>
					<input id="codUser" name="codUser" type="hidden" value="<%=usuario.getCodigo()%>" />
					<input id="unidadeId" name="unidadeId" type="hidden" value="<%=usuario.getUnidade().getCodigo()%>" />
					<input id="now" name="now" type="hidden" value="<%=Util.getToday()%>" />
					<input id="vigAtual" name="vigAtual" type="hidden" value="<%=vigAtual%>"/>
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Mensalidades"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="cadastro_cliente_fisico.jsp?state=1&id=<%= usuario.getCodigo()%>">Cadastro</a>
						</div>						
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="anexo_fisico.jsp?id=<%= usuario.getCodigo()%>">Anexo</a>
						</div>						
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Mensalidades</label>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="orcamento_empresa.jsp?id=<%= usuario.getCodigo()%>">Orçamentos de Empresas</a>
						</div>						
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="orcamento.jsp?id=<%= usuario.getCodigo()%>">Orçamentos de Profissionais</a>
						</div>
					</div>
					<div class="topContent">
						<div class="textBox" id="userRef" name="userRef" style="width: 75px;">
							<label>CTR</label><br/>
							<input id="userRefIn" name="userRefIn" type="text" style="width:75px" readonly="readonly" value="<%=usuario.getReferencia()%>"/>
						</div>
						<div id="nome" class="textBox" style="width: 225px;">
							<label>Nome</label><br/>
							<input id="nomeIn"  name="nomeIn" type="text" style="width: 225px;" value="<%=Util.initCap(usuario.getNome())%>" readonly="readonly" />
						</div>
						<div class="textBox" id="sexo" name="sexo" style="width: 65px;">
							<label>Sexo</label><br/>
							<input id="sexoIn" name="sexoIn" type="text" style="width:65px" readonly="readonly" value="<%=(usuario.getSexo().equals("m"))? "Masculino" : "Feminino"%>"/>
						</div>
						<div class="textBox" id="cpf" name="cpf" style="width: 100px;">
							<label>Cpf</label><br/>
							<input id="cpfIn" name="cpfIn" type="text" style="width:100px" readonly="readonly" value="<%=Util.mountCpf(usuario.getCpf()) %>"/>
						</div>
						<div class="textBox" id="nascimento" name="nascimento" style="width: 85px;">
							<label>Nascimento</label><br/>
							<input id="nascimentoIn" name="nascimentoIn" type="text" style="width:85px" readonly="readonly" value="<%=Util.parseDate(usuario.getNascimento(), "dd/MM/yyyy") %>"/>
						</div>
						<div class="textBox" id="rg" name="rg" style="width: 75px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" type="text" style="width:75px" readonly="readonly" value="<%=Util.parseDate(usuario.getCadastro(), "dd/MM/yyyy") %>"/>	
						</div>
						<div class="textBox" id="pag" name="pag" style="width: 225px;">
							<label>Status da Cobrança</label><br/>
							<input id="pagamentoIn" name="pagamentoIn" type="text" style="width:225px" readonly="readonly" value="<%= Util.statusLiteral(usuario.getCcobStatus()) %>"/>							
						</div>
						<div class="textBox" id="estadoCivil" name="estadoCivil" style="width: 180px;">
							<label>Contato</label><br/>
							<input id="fone" name="fone" type="text" style="width:180px" readonly="readonly" value="<%= (telefone == null)? "" : telefone %>"/>
						</div>
						<div class="textBox" style="width: 90px;">
							<label>Vigência</label><br/>
							<select id="vigencia" name="vigencia" style="width: 90px;" > 								
								<%for(Long vig: vigencia) {							
									if (vig.equals(vigAtual)) {
										out.print("<option selected=\"selected\" value=\"" + 
												vig + "\">" + vig + "ª vigencia</option>");										
									} else {
										out.print("<option value=\"" + vig + "\">" + 
												vig + "ª vigencia</option>");
									}								
								}
								%>
							</select>
						</div>
						<!--<div class="area" id="obs" name="obs" style="margin-bottom: 30px">
							<div class="ui-dialog-titlebar ui-widget-header ui-corner-all ui-helper-clearfix" style="height: 20px;">
								<span class="ui-dialog-title" style="margin-top: 15px !important;">Observações</span>
								<a id="btClose" class="ui-dialog-titlebar-close ui-corner-all" role="button" style="float: right;">
									<span class="ui-icon ui-icon-newwin" id="openObs">&nbsp;</span>
								</a>
							</div>
							<textarea cols="112" readonly="readonly" rows="5" id="obsIn" name="obsIn"><%=(usuario.getObservacao() == null)? "" : usuario.getObservacao() %></textarea>							
						</div>-->
						<div class="textBox" id="obs" name="obs" style="height: 140px;">
							<label>Observações</label><br/>
							<textarea cols="112" readonly="readonly" rows="5" id="obsIn" name="obsIn"><%=(usuario.getObservacao() == null)? "" : usuario.getObservacao() %></textarea>
						</div>
					</div>
				</div>
				<div class="buttonContent">
<!-- 					<div class="formGreenButton"> -->
<!-- 						<input id="saveObs" name="saveObs" disabled="disabled" class="grayButtonStyle" type="button" value="Salvar" onclick="makeObs()" /> -->
<!-- 					</div>				 -->
					<div class="formGreenButton">
						<input id="editObs" name="editObs" style="margin-bottom: 15px" class="greenButtonStyle" type="button" value="Editar Obs" onclick="makeObs()" />
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid" style="width: 1000px">
						<%
						int parcelas = -1;
						Date now = new Date();
						DataGrid dataGrid= new DataGrid("#");
						int gridLines= mensalidade.size();						
						//	dataGrid.addColum("10", "Mens.");
						dataGrid.addColum("10", "Descrição");
						dataGrid.addColum("10", "Vencimento");
						dataGrid.addColum("3", "Parc.");
						dataGrid.addColum("10", "Dt. Pagamento");
						dataGrid.addColum("23", "Usuário");
						dataGrid.addColum("10", "Valor");
						dataGrid.addColum("5", "Multa");
						dataGrid.addColum("5", "Mora");
						dataGrid.addColum("10", "Receb.");
						dataGrid.addColum("5", "Status");
						dataGrid.addColum("1", "St.");
						dataGrid.addColum("5", "Ck");
						atrasadas = 0;
						totalAtraso = 0;
						for(Mensalidade mes: mensalidade) {
							dataGrid.setId(String.valueOf(mes.getLancamento().getCodigo()));
							parcelas++;
							
							dataGrid.addData(Util.initCap(mes.getLancamento().getConta().getDescricao()));
							
							dataGrid.addData("vencMensGd",
									Util.parseDate(mes.getLancamento().getVencimento(),
									"dd/MM/yyyy"));
							
							dataGrid.addData(String.valueOf(parcelas));
							
							dataGrid.addData((mes.getLancamento().getDataQuitacao()== null)? "" :
								Util.parseDate(mes.getLancamento().getDataQuitacao(), "dd/MM/yyyy"));
							
							dataGrid.addData((mes.getLancamento().getRecebimento() == null) ? "" :
								mes.getLancamento().getRecebimento());
							
							dataGrid.addData("valSimplesGd", String.valueOf(Util.formatCurrency(mes.getLancamento().getValor())));
							dataGrid.addData(mes.getLancamento().getMulta() + "%");
							dataGrid.addData(mes.getLancamento().getTaxa() + "%");
							
							if (mes.getLancamento().getStatus().trim().equals("q")) {
								dataGrid.addData("valRecebGd", Util.formatCurrency(mes.getLancamento().getValorPago()));
								gridValues.add(Util.formatCurrency(mes.getLancamento().getValorPago()));
							} else {
								if (mes.getLancamento().getVencimento().before(now)
										&& (!mes.getLancamento().getStatus().trim().equals("c"))) {
									atrasadas++;
									totalAtraso+= Util.calculaAtraso(
											mes.getLancamento().getValor(), 
											mes.getLancamento().getTaxa(),
											mes.getLancamento().getMulta(),
											mes.getLancamento().getVencimento());
								}
								dataGrid.addData("valRecebGd",
										Util.formatCurrency(Util.calculaAtraso(
												mes.getLancamento().getValor(), 
												mes.getLancamento().getTaxa(),
												mes.getLancamento().getMulta(),
												mes.getLancamento().getVencimento()))
										);
								gridValues.add(Util.formatCurrency(Util.calculaAtraso(
										mes.getLancamento().getValor(), 
										mes.getLancamento().getTaxa(),
										mes.getLancamento().getMulta(),
										mes.getLancamento().getVencimento())));
							}
							
							dataGrid.addData(Util.getStatus(mes.getLancamento().getVencimento(),
									mes.getLancamento().getStatus()));
							
							if(mes.getLancamento().getStatus().equals("e")) {
								dataGrid.addImg("../image/estorno.png");
							} else {
								dataGrid.addImg(Util.getIcon(mes.getLancamento().getVencimento(), 
										mes.getLancamento().getStatus()));
							}
							dataGrid.addCheck(true, "data-status=\"" + mes.getLancamento().getStatus() + "\" ");
							
							dataGrid.addRow();
						}
						dataGrid.addTotalizador("Total", Util.formatCurrency(totalAtraso), true);
						dataGrid.addTotalizador("Parcelas em Atraso", String.valueOf(atrasadas), false);
						dataGrid.makeTotalizador();
						dataGrid.addTotalizadorRight("Total a Pagar", "0.00", "totalSoma");
						dataGrid.makeTotalizadorRight();
						out.print(dataGrid.getTable(gridLines));
						%>
					</div>
					<div id="somador">	
						<%for(int i=0 ; i < gridValues.size(); i++) {%>
							<input id="<%= "gridValue" + i %>" name="<%= "gridValue" + i %>" type="hidden"  value="<%=gridValues.get(i)%>"/>
						<%}%>
					</div>
				</div>
				<%if (session.getAttribute("caixaOpen").toString().trim().equals("t")) {%>					
					<div class="buttonContent">
						<div class="formGreenButton">
							<input id="selecione" name="selecione" class="greenButtonStyle" type="button" value="todos" onclick="selectAll()" />
						</div>
						<div class="formGreenButton">
							<input id="concilio" name="concilio" class="greenButtonStyle" type="button" value="Pagar" onclick="pagConcilia()" />
						</div>
						<div class="formGreenButton">
							<input id="estorno" name="estorno" class="greenButtonStyle" type="button" value="Estornar" onclick="estorne()" />
						</div>
						<div class="formGreenButton">
							<input id="negocie" name="negocie" class="greenButtonStyle" type="button" value="Negociar" onclick="negociar()"/>
						</div>
						<div class="formGreenButton">
							<input id="cancel" name="cancel" class="greenButtonStyle" type="button" value="Cancelar" onclick="cancela()"/>
						</div>
						<div class="formGreenButton">
							<input id="add" name="add" class="greenButtonStyle" type="button" value="Adicionar" onclick="addMensalidade()" />
						</div>
						<div class="formGreenButton">
							<input id="renova" name="renova" class="greenButtonStyle" type="button" value="Renovar" onclick="renovar()" />
						</div>
						<div class="formGreenButton">
							<input id="btcupon" name="btcupon" class="greenButtonStyle" type="button" value="Imp. Cupom" onclick="emitCupom(true)" />
						</div>
						<div class="formGreenButton">
							<input id="btBoleto" name="btBoleto" class="greenButtonStyle" type="button" value="Gerar Boleto" onclick="emitBoleto()" />
						</div>
						<% if (request.getSession().getAttribute("perfil").toString().trim().equals("a") ||
								request.getSession().getAttribute("perfil").toString().trim().equals("d") ||
								request.getSession().getAttribute("perfil").toString().trim().equals("f")) {%>
							<div class="formGreenButton">
								<input id="exc" name="exc" class="greenButtonStyle" type="button" value="Excluir" onclick="excluir()"/>
							</div>
						<%}%>
					</div>
				<%} else {%>
					<div class="buttonContent">
						<div class="formGreenButton">
							<input id="selecione" name="selecione" class="greenButtonStyle" type="button" value="todos" onclick="selectAll()" />
						</div>
						<div class="formGreenButton">
							<input id="concilio" name="concilio" class="greenButtonStyle" type="button" value="Pagar" onclick="noAccess()" />
						</div>
						<div class="formGreenButton">
							<input id="estorno" name="estorno" class="greenButtonStyle" type="button" value="Estornar" onclick="noAccess()" />
						</div>
						<div class="formGreenButton">
							<input id="negocie" name="negocie" class="greenButtonStyle" type="button" value="Negociar" onclick="noAccess()"/>
						</div>
						<div class="formGreenButton">
							<input id="cancel" name="cancel" class="greenButtonStyle" type="button" value="Cancelar" onclick="noAccess()"/>
						</div>
						<div class="formGreenButton">
							<input id="add" name="add" class="greenButtonStyle" type="button" value="Adicionar" onclick="noAccess()" />
						</div>
						<div class="formGreenButton">
							<input id="renova" name="renova" class="greenButtonStyle" type="button" value="Renovar" onclick="noAccess()" />
						</div>
						<% if (request.getSession().getAttribute("perfil").toString().trim().equals("a") 
								|| request.getSession().getAttribute("perfil").toString().trim().equals("d")
								|| request.getSession().getAttribute("perfil").toString().trim().equals("f")) {%>
							<div class="formGreenButton">
								<input id="btcupon" name="btcupon" class="greenButtonStyle" type="button" value="Imp. Cupom" onclick="emitCupom(true)" />
							</div>
						<%} else {%>
							<div class="formGreenButton">
								<input id="btcupon" name="btcupon" class="greenButtonStyle" type="button" value="Imp. Cupom" onclick="noAccess()" />
							</div>
						<%}%>
						<div class="formGreenButton">
							<input id="btBoleto" name="btBoleto" class="greenButtonStyle" type="button" value="Gerar Boleto" onclick="emitBoleto()" />
						</div>
						<% if (request.getSession().getAttribute("perfil").toString().trim().equals("a") 
								|| request.getSession().getAttribute("perfil").toString().trim().equals("d")
								|| request.getSession().getAttribute("perfil").toString().trim().equals("f")) {%>
							<div class="formGreenButton">
								<input id="exc" name="exc" class="greenButtonStyle" type="button" value="Excluir" onclick="excluir()"/>
							</div>
						<%}%>
					</div>				
				<%}%>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>