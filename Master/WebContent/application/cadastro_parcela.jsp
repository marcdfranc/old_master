<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@page import="com.marcsoftware.database.Conta"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.ItensOrcamento"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.ParcelaOrcamento"%>

<%@page import="java.util.Date"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.marcsoftware.database.Score"%>
<%@page import="com.marcsoftware.database.PlanoServico"%>
<%@page import="com.marcsoftware.database.Profissional"%>
<%@page import="com.marcsoftware.database.EmpresaSaude"%>
<%@page import="com.marcsoftware.database.FormaPagamento"%><html xmlns="http://www.w3.org/1999/xhtml">
	<jsp:useBean id="profissional" class="com.marcsoftware.database.Profissional"></jsp:useBean>
	<jsp:useBean id="empresaSaude" class="com.marcsoftware.database.EmpresaSaude"></jsp:useBean>
	<%int atrasadas= 0;
	double totalAtraso = 0;
	double desconto = 0;
	double valor = 0;
	Score score;
	PlanoServico planoServico = null;
	boolean isProfissional = true;
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query= sess.createQuery("from ItensOrcamento as i where i.id.orcamento= :codigo");
	query.setLong("codigo", Long.valueOf(request.getParameter("id")));
	List<ItensOrcamento> orcamentoIten = (List<ItensOrcamento>) query.list();
	
	query = sess.createQuery("from Conta as c where c.pessoa = :unidade");
	query.setEntity("unidade", orcamentoIten.get(0).getTabela().getUnidade());
	List<Conta> contas = (List<Conta>) query.list();
	
	query= sess.getNamedQuery("parcelamento");
	query.setEntity("orcamento", orcamentoIten.get(0).getId().getOrcamento());
	List<ParcelaOrcamento> parcela = (List<ParcelaOrcamento>) query.list();
	
	
	for (ItensOrcamento iten: orcamentoIten) {
		if (parcela.size() > 0) {
			if (desconto == 0) {
				query = sess.createSQLQuery("SELECT SUM(l.valor) FROM parcela_orcamento AS p " +
						" INNER JOIN lancamento AS l ON(p.cod_lancamento = l.codigo) " +
						" WHERE p.cod_orcamento = :orcamento");
				query.setLong("orcamento", iten.getId().getOrcamento().getCodigo());
				desconto = Double.parseDouble(query.uniqueResult().toString());
			}
		} else {
			query = sess.createQuery("from PlanoServico as p " + 
					" where p.id.plano = :plano " +
					" and p.id.servico = :servico");
			query.setEntity("plano", iten.getId().getOrcamento().getUsuario().getPlano());
			query.setEntity("servico", iten.getTabela().getServico());
			if (query.list().size() > 0) {
				planoServico = (PlanoServico) query.uniqueResult();
				if (iten.getId().getOrcamento().getDependente() == null) {
					query = sess.createQuery("from Score as s " + 
							" where s.validade > current_date " + 
							" and s.usuario = :usuario " + 
							" and s.servico = :servico");
				} else {
					query = sess.createQuery("from Score as s " + 
							" where s.validade > current_date " + 
							" and s.usuario = :usuario " + 
							" and s.servico = :servico " +
							" and s.dependente = :dependente");
					query.setEntity("dependente", iten.getId().getOrcamento().getDependente());
				}
				query.setEntity("usuario", iten.getId().getOrcamento().getUsuario());
				query.setEntity("servico", iten.getTabela().getServico());
			}
			if (query.list().size() > 0) {
				score = (Score) query.uniqueResult();
				if ((planoServico.getQtde() - score.getQtde()) >= iten.getQtde()) {
					desconto += iten.getQtde() * iten.getTabela().getValorCliente();
				} else {
					desconto+= (planoServico.getQtde() - iten.getQtde()) * iten.getTabela().getValorCliente();
				}
			}
		}
		valor+= (iten.getQtde() * iten.getTabela().getValorCliente());
	}
	
	
	if (parcela.size() > 0 && orcamentoIten.get(0).getId().getOrcamento().getUsuario().getPlano().getTipo().equals("l")) {
		desconto = valor - desconto;
	} else if (parcela.size() > 0  && orcamentoIten.get(0).getId().getOrcamento().getUsuario().getPlano().getTipo().equals("i")) {
		desconto = 0;
	}
	
	
	String operacional;
	if (session.getAttribute("perfil").equals("a")
			|| session.getAttribute("perfil").equals("f")
			|| session.getAttribute("perfil").equals("d")) {
		query= sess.getNamedQuery("totalDentista");
		query.setLong("unidade", orcamentoIten.get(0).getTabela().getUnidade().getCodigo());
		query.setLong("orcamento", orcamentoIten.get(0).getId().getOrcamento().getCodigo());		
		operacional= Util.formatCurrency(String.valueOf(query.uniqueResult()));
	} else {
		operacional= "0.00";
	}
	query = sess.createQuery("from FormaPagamento as f order by f.descricao");
	List<FormaPagamento> pagamento = (List<FormaPagamento>) query.list();
	String tpPagamento = "";
	String pagId = "2";
	if (pagamento.size() > 0) {
		for(int i = 0; i < pagamento.size(); i++) {
			tpPagamento+= (i == 0)? pagamento.get(i).getCodigo() + "@" +
					pagamento.get(i).getDescricao() + "@" + pagamento.get(i).getConcilia() 
					: "|" +	pagamento.get(i).getCodigo() + "@" + 
					pagamento.get(i).getDescricao() + "@" + 
					pagamento.get(i).getConcilia();
		}
	}	
	
	String formaList = "";
	
	for(FormaPagamento pag: pagamento) {
		if (formaList == "") {
			formaList+= pag.getCodigo() + "@" + pag.getDescricao();			
		} else {
			formaList+= "|" + pag.getCodigo() + "@" + pag.getDescricao();
		}
	}		
	ArrayList<String> gridValues = new ArrayList<String>();
	query = sess.createQuery("from Profissional as p where p.codigo = :profissional");
	query.setLong("profissional", orcamentoIten.get(0).getId().getOrcamento().getPessoa().getCodigo());
	isProfissional = query.list().size() > 0;
	if (isProfissional) {
		profissional = (Profissional) query.uniqueResult();	
	} else {
		empresaSaude = (EmpresaSaude) sess.get(EmpresaSaude.class, orcamentoIten.get(0).getId().getOrcamento().getPessoa().getCodigo());
	}
	query = sess.createQuery("from ContratoEmpresa as c where c.id.usuario = :usuario");
	query.setEntity("usuario", orcamentoIten.get(0).getId().getOrcamento().getUsuario());
	boolean isPlanoEmpresa = query.list().size() > 0;
	%>
<head>	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link type="text/css" href="../js/jquery/uploaddif/uploadify.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/uploaddif/swfobject.js"></script>
	<script type="text/javascript" src="../js/jquery/uploaddif/jquery.uploadify.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/comum/cadastro_parcela.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	
	<title>Master - Parcelas Orçamentos</title>
</head>
<body>
	<div id="uploadOrcamento" class="cpEscondeWithHeight removeBorda" title="Upload da Imagem do Orçamento">
		<form id="formUpload" onsubmit="return false;" action="../OrcamentoUpload" method="post" enctype="multipart/form-data">
			<div class="uploadContent" id="contUpload">
				<div id="msgUpload" style="margin-bottom: 20px;">Clique abaixo para selecionar o arquivo pdf a ser enviado.</div>
				<div id="fileQueue" style="width: 200px;"></div>
				<input type="file" name="uploadify" id="uploadify" />
				<!-- <p><a href="javascript:jQuery('#uploadify').uploadifyClearQueue()">Cancelar Todos os Anexos</a></p> -->
			</div>
			<input type="hidden" value="" id="uploadName" name="uploadName" />
		</form>
	</div>
	<div id="obsWindow" class="cpEscondeWithHeight removeBorda" title="Edição de observação">
		<form id="formObs" onsubmit="return false;">
			<fieldset>
				<label for="obsw">Observações</label>
				<textarea name="obsw" id="obsw" rows="30" cols="60" class="textDialog ui-widget-content ui-corner-all" 
					<%if (parcela.size() < 0) {	
							out.print("readonly=\"readonly\"");
						}
					%>><%if(parcela.size() > 0 ){
						if (orcamentoIten.get(0).getId().getOrcamento().getObservacao() != null) {
							out.print(orcamentoIten.get(0).getId().getOrcamento().getObservacao());										
						}
					}%></textarea>
			</fieldset>
		</form>
	</div>
	<div id="reloadWindow" class="cpEscondeWithHeight removeBorda" title="Reparcelamento">
		<form id="formRelo" onsubmit="return false;">
			<fieldset>
				<label id="msgReparcela"></label>
			</fieldset>
		</form>
	</div>
	<div id="boletoWindow" class="removeBorda" title="Impressão de Faturas e boletos" style="display: none">
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
			<label for="dtVencimento">Vencimento para o Agrupamento</label>
			<input type="text" name="dtVencimento" id="dtVencimento" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, typeDate)" />
		</form>
	</div>
	<div id="reparcelaWindow" class="cpEscondeWithHeight removeBorda" title="Reparcelamento de Lançamento">
		<form id="formReparcela" onsubmit="return false;">
			<fieldset>
				<label for="vencimentoParcela">Digite o vencimento do valor a receber.</label>
				<input type="text" name="vencimentoParcela" id="vencimentoParcela" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, typeDate)" value="<%= Util.getToday()%>" />
				<label for="valorAdicional">Digite o valor a receber.</label>
				<input type="text" name="valorAdicional" id="valorAdicional" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, decimalNumber)" value="0.00" />				
			</fieldset>
		</form>
	</div>
	<div id="conciliaWindow" class="removeBorda" title="Pagamento de Tratamentos" style="display: none">			
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
				<label for="tpPagamento">Forma de Pagamento</label><br/>
				<select id="tpPagamento" style="width: 100%;" onchange="adjustPagamento(this)">
					<%if (pagamento.size() > 0) {
						for(FormaPagamento pag : pagamento) {
							if (isPlanoEmpresa){
								if (pag.getCodigo() == new Long(2)) {%>
									<option value="<%= pag.getCodigo() + "@" + pag.getConcilia()%>" selected="selected" ><%= pag.getDescricao()%> </option>
								<%} else {%>
									<option value="<%= pag.getCodigo() + "@" + pag.getConcilia()%>" ><%= pag.getDescricao()%> </option>
								<%}
							} else {
								if (pag.getCodigo() == new Long(2)) {%>
									<option value="<%= pag.getCodigo() + "@" + pag.getConcilia()%>" selected="selected" ><%= pag.getDescricao()%> </option>
								<%} else if( pag.getCodigo() != new Long(5)) {%>
									<option value="<%= pag.getCodigo() + "@" + pag.getConcilia()%>" ><%= pag.getDescricao()%> </option>
								<%}
							}
						}						
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
				<input type="text" name="troco" id="troco" class="textDialog ui-widget-content ui-corner-all" readonly="readonly" value="0.00" style="height: 35px; font-size: 30px; color: #007CC3" />
			</fieldset>
		</form>		
	</div>
	<div id="cuponWindow" class="removeBorda" title="Impressão não Fiscal" style="display: none;">			
		<form id="formImpCupon" onsubmit="return false;">
			<fieldset>
				<p>Digite o valor em dinheiro pago pelo cliente.</p>
				<label for="moneyCupon">Dinheiro</label>
				<input type="text" name="moneyCupon" id="moneyCupon" class="textDialog ui-widget-content ui-corner-all" value="0.00" onkeydown="mask(this, decimalNumber)"/>
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="orcamento"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="orcamento"/>			
		</jsp:include>
		<div id="formStyle">
			<form id="parc" method="get">
				<input name="codUser" id="codUser" type="hidden" value="<%= orcamentoIten.get(0).getId().getOrcamento().getUsuario().getCodigo() %>"/>					
				<input type="hidden" id="pagamentoList" name="pagamentoList" value="<%=formaList%>" />
				<input type="hidden" id="cbFormaPag" name="cbFormaPag" value="<%= tpPagamento %>"/>
				<input type="hidden" id="aprovacao" name="aprovacao" value="<%= orcamentoIten.get(0).getTabela().getVigencia().getAprovacao() %>"/>
				<input type="hidden" name="isProfissional" id="isProfissional" value="<%= (isProfissional)? "t" : "f" %>" />
				<input id="haveDoc" name="haveDoc" type="hidden" value="<%= orcamentoIten.get(0).getId().getOrcamento().getDocParcelaDigital() %>"/>
				<div id="localEdTabela" ></div>
				<div id="localTabela"></div>
				<div id="deletedsServ"></div>
				<div>
					<input id="unidadeId" name="unidadeId" type="hidden" value="<%=orcamentoIten.get(0).getTabela().getUnidade().getCodigo()%>" />
					<input id="now" name="now" type="hidden" value="<%=Util.getToday()%>" />
					<input id="firstParcel" name="firstParcel" type="hidden" value="<%=(parcela.size() == 0)? "0": parcela.get(0).getId().getLancamento().getCodigo()%>" />
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Parcelamento"/>
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="cadastro_cliente_fisico.jsp?state=1&id=<%= orcamentoIten.get(0).getId().getOrcamento().getUsuario().getCodigo()%>">Cadastro</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="anexo_fisico.jsp?id=<%= orcamentoIten.get(0).getId().getOrcamento().getUsuario().getCodigo()%>">Anexo</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="mensalidade.jsp?id=<%= orcamentoIten.get(0).getId().getOrcamento().getUsuario().getCodigo()%>">Mensalidades</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="orcamento_empresa.jsp?id=<%= orcamentoIten.get(0).getId().getOrcamento().getUsuario().getCodigo()%>">Orçamentos de Empresas</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="orcamento.jsp?id=<%= orcamentoIten.get(0).getId().getOrcamento().getUsuario().getCodigo()%>">Orçamentos de Profissionais</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<%if (isProfissional) {%>
							<div class="aba2">
								<a href="cadastro_orcamento.jsp?state=1&id=<%= orcamentoIten.get(0).getId().getOrcamento().getCodigo()%>">Orçamento</a>	
							</div>							
						<%} else {%>
							<div class="aba2">
								<a href="cadastro_orcamento_emp.jsp?state=1&id=<%= orcamentoIten.get(0).getId().getOrcamento().getCodigo()%>">Orçamento</a>	
							</div>
						<%}%>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<%if (request.getParameter("state") == null) {%>
							<div class="sectedAba2">
								<label>Parcelamento</label>	
							</div>
						<%} else {%>
							<div class="aba2">
								<a href="cadastro_parcela.jsp?id=<%= orcamentoIten.get(0).getId().getOrcamento().getCodigo()%>">Parcelamento</a>	
							</div>
						<%}%>
						<%if (session.getAttribute("perfil").toString().trim().equals("a")
								|| session.getAttribute("perfil").toString().trim().equals("d")
								|| session.getAttribute("perfil").toString().trim().equals("f")) {%>
							<div class="sectedAba2">
								<label>></label>
							</div>
							<%if (request.getParameter("state") == null) {%>
								<div class="aba2">
									<a href="cadastro_parcela.jsp?id=<%= orcamentoIten.get(0).getId().getOrcamento().getCodigo()%>&state=o">Parcelamento Prof.</a>	
								</div>
							<%} else {%>
								<div class="sectedAba2">
									<label>Parcelamento Prof.</label>	
								</div>
							<%}%>
						<%}%>
					</div>
					<div class="topContent">
						<div class="textBox" id="unidadeRef" name="unidadeRef" style="width: 65px;">
							<label>Cód. Unid.</label><br/>
							<input id="unidadeRefIn" name="unidadeRefIn" type="text" style="width:65px" readonly="readonly" value="<%=orcamentoIten.get(0).getTabela().getUnidade().getReferencia()%>"/>
						</div>
						<div id="unidade" class="textBox" style="width: 200px;" >
							<label>Unidade</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" style="width: 200px;" value="<%= Util.initCap(orcamentoIten.get(0).getTabela().getUnidade().getFantasia())%>" readonly="readonly" />
						</div>
						<div id="cadastro" class="textBox" style="width:75px">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" type="text" style="width:75px" readonly="readonly" value="<%=Util.parseDate(orcamentoIten.get(0).getId().getOrcamento().getData(), "dd/MM/yyyy")%>"/>						
						</div>							
						<div class="textBox" id="valorTratamento" name="valorTratamento" style="width: 77px;">
							<label>Vlr. Cliente</label><br/>
							<input id="tratamentoIn" name="tratamentoIn" type="text" style="width:77px" readonly="readonly" value="<%= Util.formatCurrency(valor) %>"/>
						</div>
						<div class="textBox" id="valorCoberto" name="valorCoberto" style="width: 75px;">
							<label>Cobertura</label><br/>
							<input id="descontoIn" name="descontoIn" type="text" style="width:77px" readonly="readonly" value="<%= Util.formatCurrency(desconto) %>"/>
						</div>
						<div class="textBox" id="valorTratamento" name="valorTratamento" style="width: 77px;">
							<label>Vlr. Total</label><br/>
							<input id="valorIn" name="valorIn" type="text" style="width:77px" readonly="readonly" value="<%= Util.formatCurrency(valor - desconto) %>"/>
						</div>
						<%if (isProfissional) {%>
							<div class="textBox" id="profId" name="profId" style="width: 75px;">
								<label>Ref. Prof.</label><br/>
								<input id="profIdIn" name="profIdIn" type="text" style="width:75px" readonly="readonly" value="<%= profissional.getCodigo()%>"/>
							</div>
							<div id="profissional" class="textBox" style="width: 299px;" >
								<label>Profissional</label><br/>
								<input id="profissionalIn" name="profissionalIn" type="text" style="width: 299px;" value="<%=Util.initCap(profissional.getNome())%>" readonly="readonly" />
							</div>
							<div id="conselho" class="textBox" style="width: 125px;" >
								<label>Nro. Conselho</label><br/>
								<input id="conselhoIn" name="conselhoIn" type="text" style="width: 125px;" value="<%=Util.initCap(profissional.getConselho())%>" readonly="readonly" />
							</div>
						<%} else {%>
							<div class="textBox" id="empId" name="empId" style="width: 75px;">
								<label>Ref. Emp.</label><br/>
								<input id="empIdIn" name="empIdIn" type="text" style="width:75px" readonly="readonly" value="<%= empresaSaude.getCodigo()%>"/>
							</div>
							<div id="profissional" class="textBox" style="width: 299px;" >
								<label>Empresa de Saúde</label><br/>
								<input id="empresaSaudeIn" name="empresaSaudeIn" type="text" style="width: 299px;" value="<%=Util.initCap(empresaSaude.getFantasia())%>" readonly="readonly" />
							</div>
							<div id="conselho" class="textBox" style="width: 125px;" >
								<label>Nro. Conselho</label><br/>
								<input id="conselhoIn" name="conselhoIn" type="text" style="width: 125px;" value="<%=empresaSaude.getConselhoResponsavel()%>" readonly="readonly" />
							</div>
						<%}%>
						<div class="textBox" id="valorOperacional" name="valorOperacional" style="width: 100px;">
							<label>Vlr. Profissional</label><br/>
							<input id="operacionalIn" name="operacionalIn" type="text" style="width:100px" readonly="readonly" value="<%= operacional %>"/>
						</div>
						<div class="textBox" id="userId" name="userId" style="width: 74px;">
							<label>CTR</label><br/>
							<input id="userIdIn" name="userIdIn" type="text" style="width:74px" readonly="readonly" value="<%=orcamentoIten.get(0).getId().getOrcamento().getUsuario().getReferencia()%>"/>
						</div>
						<div id="usuario" class="textBox" style="width: 269px;" >
							<label>Titular</label><br/>
							<input id="usuarioIn" name="usuarioIn" type="text" style="width: 269px;" value="<%=Util.initCap(orcamentoIten.get(0).getId().getOrcamento().getUsuario().getNome())%>" readonly="readonly" />
						</div>						
						<div id="dependente" class="textBox" style="width: 269px;" >
							<label>Dependente</label><br/>
							<input id="dependenteIn" name="dependenteIn" type="text" style="width: 269px;" value="<%=(orcamentoIten.get(0).getId().getOrcamento().getDependente() != null)? Util.initCap(orcamentoIten.get(0).getId().getOrcamento().getDependente().getNome()) : ""%>" readonly="readonly" />
						</div>
					</div>				
				</div>
				<% if (parcela.size() > 0) {%>
					<div class="topButtonContent">
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Imprimir" onclick="<%=(request.getParameter("state") != null)? "generateProfPdf()" : "generatePdf()" %>"/>
						</div>
						<%if (request.getParameter("state") == null) {%>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Doc. Digital" onclick="loadDocDigital()" />
							</div>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Upload" onclick="showUploadWd()" />
							</div>	
						<%}%>
					</div>
				<%}%>
				<div id="mainContent">					
					<div id="itensOrcamento" class="bigBox" >
						<div class="indexTitle">
							<h4>Forma de pagamento</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div id="orcamento" class="textBox" style="width: 70px;" >
							<label>Orçamento</label><br/>
							<input id="codOrcamento" name="codOrcamento" type="text" style="width: 70px;" readonly="readonly" value="<%=orcamentoIten.get(0).getId().getOrcamento().getCodigo()%>" />
						</div>
						<div id="tabela" class="textBox" style="width: 322px;" >
							<label>Tabela</label><br/>
							<input id="tabelaIn" name="tabelaIn" type="text" style="width: 322px;" readonly="readonly" value="<%=orcamentoIten.get(0).getTabela().getVigencia().getDescricao()%>" />
						</div>
						<div class="textBox">
							<label>Vencimento</label><br/>
							<select style="width: 80px" id="vencimento" name="vencimento" <%
								if (parcela.size() > 0) {
									out.print("disabled=\"disabled\"");
								}
							%>>
								<option value="01">Dia 01</option>
								<option value="05">Dia 05</option>
								<option value="10">Dia 10</option>
								<option value="15">Dia 15</option>
								<option value="20">Dia 20</option>
								<option value="25">Dia 25</option>									
							</select>
						</div>
						<div class="textBox" id="qtdeParcela" name="qtdeParcela" style="width: 30px;">
							<label>Qtde</label><br/>
							<input id="parcelaIn" name="parcelaIn" type="text" style="width:30px" onkeydown="mask(this, onlyInteger);" <%
									if (parcela.size() > 0) {
										out.print("readonly=\"readonly\"");
									}
								%> value="<%=(parcela.size() > 0)? parcela.size() : "1" %>"/>
						</div>
						<div class="textBox" id="txAtraso" name="txAtraso" style="width: 48px;">
							<label>%Multa</label><br/>
							<input id="multaIn" name="multaIn" type="text" style="width:45px" onkeydown="mask(this, decimalNumber);" <%
									if (parcela.size() > 0) {
										out.print("readonly=\"readonly\"");
									}
								%> value="<%=(parcela.size() > 0)? parcela.get(0).getId().getLancamento().getTaxa() : "0.00"%>"/>
						</div>
						<div class="textBox" id="txAtraso" name="txAtraso" style="width: 45px;">
							<label>%Mora</label><br/>
							<input id="txAtrasoIn" name="txAtrasoIn" type="text" style="width:45px" onkeydown="mask(this, decimalNumber);" <%
									if (parcela.size() > 0) {
										out.print("readonly=\"readonly\"");
									}
								%> value="<%=(parcela.size() > 0)? parcela.get(0).getId().getLancamento().getTaxa() : "0.00"%>"/>
						</div>
						<div class="textBox" id="juros" name="juros" style="width: 48px;">
							<label>%Juros</label><br/>
							<input id="jurosIn" name="jurosIn" type="text" style="width:45px" onkeydown="mask(this, decimalNumber);" <%
									if (parcela.size() > 0) {
										out.print("readonly=\"readonly\"");
									}
								%> value="<%=(parcela.size() > 0)? parcela.get(0).getId().getLancamento().getJuros() : "0.00" %>" />
						</div>
						<div class="textBox" id="valorEntrada" name="valorEntrada" style="width: 75px;">
							<label>Entrada</label><br/>
							<%if((parcela.size() > 0)
									&& (request.getParameter("state") == null)) {%>
								<input id="entradaIn" name="entradaIn" type="text" style="width:75px" onkeydown="mask(this, decimalNumber);" readonly="readonly" value="<%=Util.formatCurrency(parcela.get(0).getId().getLancamento().getValor())%>"/>								
							<%} else if(request.getParameter("state") != null) {%>
								<input id="entradaIn" name="entradaIn" type="text" style="width:75px" onkeydown="mask(this, decimalNumber);" readonly="readonly" value="<%=Util.formatCurrency(Util.getOperacional(Double.parseDouble(operacional), valor, parcela.get(0).getId().getLancamento().getValor()))%>"/>
							<%} else if(parcela.size() == 0) {%>
								<input id="entradaIn" name="entradaIn" type="text" style="width:75px" onkeydown="mask(this, decimalNumber);" value="0.00"/>
							<%} else {%>
								<input id="entradaIn" name="entradaIn" type="text" style="width:75px" onkeydown="mask(this, decimalNumber);" readonly="readonly" value="<%=Util.formatCurrency(parcela.get(0).getId().getLancamento().getValor())%>"/>
							<%}%>
						</div>
						<div id="vlrParcela" class="textBox" style="width: 75px;" >
							<label>Parcelas</label><br/>
							<%if((parcela.size() > 1)
									&& (request.getParameter("state") == null)) {%>
								<input id="vlrParcelaIn" name="vlrParcelaIn" type="text" style="width: 75px;" readonly="readonly" value="<%=Util.formatCurrency(parcela.get(1).getId().getLancamento().getValor())%>" />
							<%} else if((parcela.size() == 1)
									&& (request.getParameter("state") == null)) {%>
								<input id="vlrParcelaIn" name="vlrParcelaIn" type="text" style="width: 75px;" readonly="readonly" value="<%=Util.formatCurrency(parcela.get(0).getId().getLancamento().getValor())%>" />
							<%} else if ((parcela.size() == 1)
									&& (request.getParameter("state") != null)){%>
								<input id="vlrParcelaIn" name="vlrParcelaIn" type="text" style="width: 75px" onkeydown="mask(this, decimalNumber);" readonly="readonly" value="<%=Util.formatCurrency(Util.getOperacional(Double.parseDouble(operacional), valor, parcela.get(0).getId().getLancamento().getValor()))%>"/>
							<%} else if((parcela.size() > 1)
									&& (request.getParameter("state") != null)) {%>
								<input id="vlrParcelaIn" name="vlrParcelaIn" type="text" style="width: 75px" onkeydown="mask(this, decimalNumber);" readonly="readonly" value="<%=Util.formatCurrency(Util.getOperacional(Double.parseDouble(operacional), valor, parcela.get(1).getId().getLancamento().getValor()))%>"/>
							<%} else {%> 
								<input id="vlrParcelaIn" name="vlrParcelaIn" type="text" style="width: 75px" onkeydown="mask(this, decimalNumber);" readonly="readonly" value="0.00"/>
							<%}%>
						</div>
						<!--  <div class="area" id="obs" name="obs" style="margin-bottom: 30px">
							<div class="headerText">
								<label>Observações</label><span class="ui-widget-content ui-corner-all" id="openObs">&nbsp;</span>							
							</div>
							<textarea cols="112"  rows="5" id="obsIn" name="obsIn" id="obsIn" <%
									if (parcela.size() > 0) {	
										out.print("readonly=\"readonly\"");
									}
								%>><%if(parcela.size() > 0 ){
									if (orcamentoIten.get(0).getId().getOrcamento().getObservacao() != null) {
										out.print(orcamentoIten.get(0).getId().getOrcamento().getObservacao());										
									}
								}%></textarea>								
						</div>-->
						<div class="textBox" id="obs" name="obs" style="height: 140px;">
							<label>Observações</label><br/>
							<textarea cols="112"  rows="5" id="obsIn" name="obsIn" id="obsIn" <%
								if (parcela.size() > 0) {	
									out.print("readonly=\"readonly\"");
								}
							%>><%if(parcela.size() > 0 ){
								if (orcamentoIten.get(0).getId().getOrcamento().getObservacao() != null) {
									out.print(orcamentoIten.get(0).getId().getOrcamento().getObservacao());										
								}
							}%></textarea>
						</div>
						<%if (parcela.size() > 0) {%>
							<div class="buttonContent" >
								<div class="formGreenButton">
									<input name="editObs" id="editObs" class="greenButtonStyle" type="button" value="Editar Obs" onclick="makeObs()" />
								</div>
							</div>
						<%}%>
					</div>
					<div id="<%= (parcela.size() > 0)? "counter": "counterEmpty"%>" class="<%= (parcela.size() > 0)? "counter": "counterEmpty"%>"></div>
					<div id="dataGrid" >
						<%
						if (parcela.size() > 0) {
							DataGrid dataGrid= new DataGrid("#");
							Date now = new Date();							
							int gridLines= parcela.size();
							dataGrid.addColum("10", "Guia");
							//dataGrid.addColum("2", "Descrição");
							dataGrid.addColum("10", "Vencimento");
							dataGrid.addColum("10", "Parcela");
							dataGrid.addColum("13", "Dt. Pagamento");
							dataGrid.addColum("23", "Usuário");
							dataGrid.addColum("10", "Valor");
							dataGrid.addColum("10", "Multa");
							dataGrid.addColum("10", "Mora");
							if (request.getParameter("state") == null) {
								dataGrid.addColum("10", "Receb.");							
							} else {
								dataGrid.addColum("10", "Operac.");
							}
							dataGrid.addColum("2", "St.");
							dataGrid.addColum("2", "Ck.");
							atrasadas = 0;
							totalAtraso = 0;
							for(int i=0; i < parcela.size(); i++) {
								dataGrid.setId(
									String.valueOf(parcela.get(i).getId().getLancamento().getCodigo()));
								
								dataGrid.addData(String.valueOf(parcela.get(i).getId().getLancamento().getCodigo()));
								
								dataGrid.addData("vencMensGd", Util.parseDate(
									parcela.get(i).getId().getLancamento().getVencimento(), "dd/MM/yyyy"));
								
								dataGrid.addData(parcela.get(i).getSequencial() + "/" + 
									String.valueOf(parcela.size()));
								
								dataGrid.addData((parcela.get(i).getId().getLancamento().getDataQuitacao()== null)?
										"" : Util.parseDate(
										parcela.get(i).getId().getLancamento().getDataQuitacao(), "dd/MM/yyyy"));
								
								dataGrid.addData((parcela.get(i).getId().getLancamento().getRecebimento() == null)?
										"" : parcela.get(i).getId().getLancamento().getRecebimento());
								
								dataGrid.addData("valSimplesGd", Util.formatCurrency(parcela.get(i).getId().getLancamento().getValor()));
								dataGrid.addData(parcela.get(i).getId().getLancamento().getMulta() + "%");
								dataGrid.addData(parcela.get(i).getId().getLancamento().getTaxa() + "%");
								
								if (request.getParameter("state") != null) {
									dataGrid.addData(Util.formatCurrency(Util.getOperacional(
										Double.parseDouble(operacional), valor, 
										parcela.get(i).getId().getLancamento().getValor())));									
									gridValues.add(Util.formatCurrency(Util.getOperacional(
										Double.parseDouble(operacional), valor, 
										parcela.get(i).getId().getLancamento().getValor())));
								} else if (parcela.get(i).getId().getLancamento().getStatus().trim().equals("q") || 
										parcela.get(i).getId().getLancamento().getStatus().trim().equals("f")) {
									dataGrid.addData(
										Util.formatCurrency(parcela.get(i).getId().getLancamento().getValorPago()));
									gridValues.add(Util.formatCurrency(
											parcela.get(i).getId().getLancamento().getValorPago()));
								} else {
									if (parcela.get(i).getId().getLancamento().getVencimento().before(now)
											&& (!parcela.get(i).getId().getLancamento().getStatus().trim().equals("c"))) {
										atrasadas++;
										totalAtraso+= Util.calculaAtraso(
												parcela.get(i).getId().getLancamento().getValor(), 
												parcela.get(i).getId().getLancamento().getTaxa(), 
												parcela.get(i).getId().getLancamento().getVencimento());
									}
									dataGrid.addData(Util.formatCurrency(Util.calculaAtraso(
										parcela.get(i).getId().getLancamento().getValor(), 
										parcela.get(i).getId().getLancamento().getTaxa(),
										parcela.get(i).getId().getLancamento().getVencimento()))
									);
									gridValues.add(Util.formatCurrency(Util.calculaAtraso(
											parcela.get(i).getId().getLancamento().getValor(), 
											parcela.get(i).getId().getLancamento().getTaxa(),
											parcela.get(i).getId().getLancamento().getVencimento())));
								}
								
								dataGrid.addImg(Util.getIcon(parcela.get(i).getId().getLancamento().getVencimento(),
										parcela.get(i).getId().getLancamento().getStatus()));
								
								dataGrid.addCheck(true, "data-status=\"" + parcela.get(i).getId().getLancamento().getStatus() + "\" ");
								
								dataGrid.addRow();
							}
							out.print(dataGrid.getTable(gridLines));
						}						
						%>
					</div>
					<div class="totalizador">
						<label id="total" name="total" style="margin-left: 15px"><%= Util.formatCurrency(totalAtraso) %></label>
						<label id="labelTotal" class="titleCounter">Parcelas em atraso <%=atrasadas %> total:</label>
					</div>
					<div class="totalizadorRight">
						<label id="labelSoma" class="titleCounter" style="margin-right: 5px;">total a pagar:</label>
						<label id="totalSoma" name="totalSoma" style="margin-right: 85px">0.00</label>
					</div>
					<div id="somador">
						<%for(int i=0 ; i < gridValues.size(); i++) {%>
							<input id="<%= "gridValue" + i %>" name="<%= "gridValue" + i %>" type="hidden"  value="<%=gridValues.get(i)%>"/>
						<%}%>
					</div>
					<%if (parcela.size() > 0 ) {
						if (session.getAttribute("caixaOpen").toString().trim().equals("t")) {%>
							<div class="buttonContent">
								<div class="formGreenButton" >
									<input id="selecAll" name="selecAll" class="greenButtonStyle" type="button" value="Todos" onclick="selectAll()"/>
								</div>
								<div class="formGreenButton">
									<input id="concilio" name="concilio" class="greenButtonStyle" type="button" value="Pagar" onclick="pagConcilia()" />
								</div>
								<div class="formGreenButton" >
									<input id="estorno" name="estorno" class="greenButtonStyle" type="button" value="Estornar" onclick="estorne()" />
								</div>
								<div class="formGreenButton" >
									<input id="renegocioIn" name="renegocioIn" class="greenButtonStyle" type="button" value="Reparcelar" onclick="reparcela()" />
								</div>
								<div class="formGreenButton" >
									<input id="cancelRenegocio" name="cancelRenegocio" class="greenButtonStyle" type="button" value="Cancelar" onclick="cancelParc()"/>
								</div>
								<div class="formGreenButton" >
									<input id="restituicao" name="restituicao" class="greenButtonStyle" type="button" value="Restituir" onclick="restitui()" />
								</div>
								<div class="formGreenButton" >
									<input id="impressao" name="impressao" class="greenButtonStyle" type="button" value="Imp. Guia" onclick="impressaoGuia()" />
								</div>
								<div class="formGreenButton">
									<input id="btcupon" name="btcupon" class="greenButtonStyle" type="button" value="Imp. Cupom" onclick="emitCupom(true)" />
								</div>
								<div class="formGreenButton">
									<input id="btBoleto" name="btBoleto" class="greenButtonStyle" type="button" value="Gerar Boleto" onclick="emitBoleto()" />
								</div>		
								<%if (session.getAttribute("perfil").equals("a") || session.getAttribute("perfil").equals("f")) {%>
									<div class="formGreenButton">
										<input id="exc" name="exc" class="greenButtonStyle" type="button" value="Excluir" onclick="excluir()"/>
									</div>								
								<% }%>
							</div>					
						<%} else {%>
							<div class="buttonContent">
								<div class="formGreenButton" >
									<input id="selecAll" name="selecAll" class="greenButtonStyle" type="button" value="Todos" onclick="selectAll()"/>
								</div>
								<div class="formGreenButton">
									<input id="concilio" name="concilio" class="greenButtonStyle" type="button" value="Pagar" onclick="noAccess()" />
								</div>
								<div class="formGreenButton" >
									<input id="estorno" name="estorno" class="greenButtonStyle" type="button" value="Estornar" onclick="noAccess()" />
								</div>
								<div class="formGreenButton" >
									<input id="renegocioIn" name="renegocioIn" class="greenButtonStyle" type="button" value="Reparcelar" onclick="noAccess()" />
								</div>
								<div class="formGreenButton" >
									<input id="cancelRenegocio" name="cancelRenegocio" class="greenButtonStyle" type="button" value="Cancelar" onclick="noAccess()"/>
								</div>
								<div class="formGreenButton" >
									<input id="restituicao" name="restituicao" class="greenButtonStyle" type="button" value="Restituir" onclick="noAccess()" />
								</div>
								<% if (request.getSession().getAttribute("perfil").toString().trim().equals("a") 
										|| request.getSession().getAttribute("perfil").toString().trim().equals("d")
										|| request.getSession().getAttribute("perfil").toString().trim().equals("f")) {%>
									<div class="formGreenButton" >
										<input id="impressao" name="impressao" class="greenButtonStyle" type="button" value="Imp. Guia" onclick="impressaoGuia()" />
									</div>
									<div class="formGreenButton">
										<input id="btcupon" name="btcupon" class="greenButtonStyle" type="button" value="Imp. Cupom" onclick="emitCupom(true)" />
									</div>
								<%} else {%>
									<div class="formGreenButton" >
										<input id="impressao" name="impressao" class="greenButtonStyle" type="button" value="Imp. Guia" onclick="noAccess()" />
									</div>
									<div class="formGreenButton">
										<input id="btcupon" name="btcupon" class="greenButtonStyle" type="button" value="Imp. Cupom" onclick="noAccess()" />
									</div>								
								<%}
								if (session.getAttribute("perfil").equals("a") || session.getAttribute("perfil").equals("f")) {%>
									<div class="formGreenButton">
										<input id="exc" name="exc" class="greenButtonStyle" type="button" value="Excluir" onclick="excluir()"/>
									</div>
								<%} %>
								<div class="formGreenButton">
									<input id="btBoleto" name="btBoleto" class="greenButtonStyle" type="button" value="Gerar Boleto" onclick="emitBoleto()" />
								</div>
							</div>
						<%}%>
					<%} else {%>
						<div class="buttonContent">
							<div class="formGreenButton" >
								<input id="insertInfo" name="insertInfo" class="greenButtonStyle" type="button" value="Gerar Parcela" onclick="generate()" />
							</div>
						</div>
					<%}%>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>	
</body>
</html>