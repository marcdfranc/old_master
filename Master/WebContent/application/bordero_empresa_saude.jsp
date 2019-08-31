<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.EmpresaSaude"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.FormaPagamento"%>
<%@page import="com.marcsoftware.database.ParcelaOrcamento"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	
	<jsp:useBean id="empresaSaude" class="com.marcsoftware.database.EmpresaSaude"></jsp:useBean>
	
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);	
	Query query;
	double total = 0;
	empresaSaude = (EmpresaSaude) sess.get(EmpresaSaude.class, Long.valueOf(request.getParameter("id")));
	ArrayList<String> gridValues = new ArrayList<String>();
	query = sess.createQuery("from FormaPagamento as f where f.concilia = 'n'");
	List<FormaPagamento> pagList = (List<FormaPagamento>) query.list();
	String formaPag = "";
	for(FormaPagamento pag: pagList) {
		if(formaPag.equals("")) {
			formaPag += pag.getCodigo() + "@" + pag.getDescricao();
		} else {
			formaPag += "|" + pag.getCodigo() + "@" + pag.getDescricao(); 
		}
	}
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />	
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Bordero Empresa de Saúde</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>	
	<script type="text/javascript" src="../js/comum/bordero_empresa_saude.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
</head>
<body onload="load()">
	<div id="geraWindow" class="removeBorda" title="Forma de Pagamento" style="display: none;">			
		<form id="formPagamento" onsubmit="return false;">
			<fieldset>
				<label for="tpPagamento">Selecione a forma de pagamento</label><br/>
				<select id="tpPagamento" style="width: 100%" onchange="adjustPagamento(this)">
					<%if (pagList.size() > 0) {
						for(FormaPagamento pagamento : pagList) {
							if (pagamento.getCodigo() == new Long(2)) {%>
								<option value="<%= pagamento.getCodigo()%>" selected="selected" ><%= pagamento.getDescricao()%> </option>
							<%} else {%>
								<option value="<%= pagamento.getCodigo()%>" ><%= pagamento.getDescricao()%> </option>
							<%}%>
						<%}						
					} else {%>
						<option value="">Selecione</option>
					<%}%>
				</select><br/>
			</fieldset>
		</form>		
	</div>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="empSaude"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="empSaude"/>
		</jsp:include>
		<div id="formStyle">
			<form id="parc" method="get" onsubmit="return search()">
				<div>
					<input type="hidden" id="formasPag" name="formasPag" value="<%= formaPag %>" />
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Borderô"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="cadastro_empresa_saude.jsp?state=1&id=<%= empresaSaude.getCodigo()%>">Cadastro</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="anexo_empresa_saude.jsp?state=1&id=<%= empresaSaude.getCodigo()%>">Anexo</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Borderô</label>
						</div>						
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="cadastro_bordero.jsp?id=<%= empresaSaude.getCodigo()%>">Cadastro de Fatura</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="fatura_bordero_profissional.jsp?id=<%= empresaSaude.getCodigo()%>">Histórico de Faturas</a>
						</div>
					</div>					
					<div class="topContent">
						<div class="textBox" id="unidadeRef" name="unidadeRef" style="width: 75px;">
							<label>Cód. Unid.</label><br/>
							<input id="unidadeRefIn" name="unidadeRefIn" type="text" style="width:75px" readonly="readonly" value="<%=empresaSaude.getUnidade().getReferencia()%>"/>
						</div>
						<div id="unidade" class="textBox" style="width: 330px;" >
							<label>Unidade</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" style="width: 330px;" value="<%= Util.initCap(empresaSaude.getUnidade().getFantasia()) %>" readonly="readonly" />
						</div>
						<div id="cadastroCalendar" class="textBox" style="width: 180px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" type="text" style="width: 73px;" value="<%= Util.getToday() %>"  onkeydown="mask(this, dateType);"/>
						</div>
						<div id="referencia" class="textBox" style="width: 75px;" >
							<label>Ref. Emp.</label><br/>
							<input id="referenciaIn" name="referenciaIn" type="text" style="width: 75px;" value="<%= empresaSaude.getCodigo() %>" readonly="readonly" />
						</div>
						<div id="profissional" class="textBox" style="width: 280px;" >
							<label>Empresa de Saúde</label><br/>
							<input id="profissionalIn" name="profissionalIn" type="text" style="width: 280px;" value="<%=Util.initCap(empresaSaude.getFantasia())%>" readonly="readonly" />
						</div>
						<div id="conselho" class="textBox" style="width: 125px;" >
							<label>Nro. Conselho</label><br/>
							<input id="conselhoIn" name="conselhoIn" type="text" style="width: 125px;" value="<%=empresaSaude.getConselhoResponsavel()%>" readonly="readonly" />
						</div>						
					</div>
				</div>
				<div id="mainContent">
					<div id="dataGrid">
						<%query = sess.getNamedQuery("pagEmpSaudeAll");
						query.setLong("empresa", Long.valueOf(request.getParameter("id")));				
						int gridLines = query.list().size();						
						List<ParcelaOrcamento> parcela= (List<ParcelaOrcamento>) query.list();
						double operacional= 0;
						double cliente = 0;
						int qtde = 0;
						DataGrid dataGrid = new DataGrid("#");
						dataGrid.addColum("5", "CTR");
						dataGrid.addColum("50", "Cliente");
						dataGrid.addColum("5", "orç.");
						dataGrid.addColum("5", "Guia");
						dataGrid.addColum("5", "Emissão");
						dataGrid.addColum("10", "vencimento");
						dataGrid.addColum("5", "Empresa");
						dataGrid.addColum("10", "valor");
						dataGrid.addColum("5", "Ck");
						for (ParcelaOrcamento parc: parcela) {							
							query = sess.getNamedQuery("operacionalOrcamento");
							query.setLong("orcamento", parc.getId().getOrcamento().getCodigo());
							query.setLong("unidade", parc.getId().getLancamento().getUnidade().getCodigo());
							operacional = Double.parseDouble(query.uniqueResult().toString());
							
							query = sess.getNamedQuery("clienteOrcamento");
							query.setLong("orcamento", parc.getId().getOrcamento().getCodigo());
							query.setLong("unidade", parc.getId().getLancamento().getUnidade().getCodigo());
							cliente = Double.parseDouble(query.uniqueResult().toString());
							
							dataGrid.setId(String.valueOf(parc.getId().getLancamento().getCodigo()));
							if (parc.getId().getOrcamento().getDependente() == null) {
								dataGrid.addData(parc.getId().getOrcamento().getUsuario().getReferencia() +	"-0");
								dataGrid.addData(parc.getId().getOrcamento().getUsuario().getNome());
							} else {
								dataGrid.addData(parc.getId().getOrcamento().getUsuario().getReferencia() + 
									"-" + parc.getId().getOrcamento().getDependente().getReferencia());
								dataGrid.addData(parc.getId().getOrcamento().getDependente().getNome());
							}
							dataGrid.addData(String.valueOf(parc.getId().getOrcamento().getCodigo()));
							dataGrid.addData(String.valueOf(parc.getId().getLancamento().getCodigo()));
							dataGrid.addData((parc.getId().getLancamento().getEmissao() == null) ? "" :									
									Util.parseDate(parc.getId().getLancamento().getEmissao() , "dd/MM/yyyy"));
							
							if (Util.getDayDate(parc.getId().getLancamento().getDataQuitacao()) > 25) {
								if (Util.getMonthDate(parc.getId().getLancamento().getDataQuitacao()) == 12) {
									dataGrid.addData("25/01/" + (Util.getYearDate(parc.getId().getLancamento().getDataQuitacao()) + 1));
								} else {
									dataGrid.addData("25/" + (Util.getMonthDate(parc.getId().getLancamento().getDataQuitacao()) + 1) +
											"/" + Util.getYearDate(parc.getId().getLancamento().getDataQuitacao()));
								}
							} else {
								dataGrid.addData("25/" + Util.getMonthDate(parc.getId().getLancamento().getDataQuitacao())+
										"/" + Util.getYearDate(parc.getId().getLancamento().getDataQuitacao()));
							}
							dataGrid.addData(String.valueOf(parc.getId().getOrcamento().getPessoa().getCodigo()));
							
							if (session.getAttribute("perfil").toString().equals("a")
									|| session.getAttribute("perfil").toString().equals("d")
									|| session.getAttribute("perfil").toString().equals("f")) {
								dataGrid.addData(Util.formatCurrency(Util.getOperacional(
										operacional, cliente, parc.getId().getLancamento().getValor())));
							} else {
								dataGrid.addData("---------");
							}
							
							
							gridValues.add(Util.formatCurrency(Util.getOperacional(
									operacional, cliente, parc.getId().getLancamento().getValor())));
							
							total+= Util.trunc(Util.getOperacional(operacional, cliente, 
									parc.getId().getLancamento().getValor()), 2);
							dataGrid.addCheck(true);
							dataGrid.addRow();							
						}
						
						if (session.getAttribute("perfil").toString().equals("a")
								|| session.getAttribute("perfil").toString().equals("d")
								|| session.getAttribute("perfil").toString().equals("f")) {
							dataGrid.addTotalizador("Valor Total", Util.formatCurrency(total), true);
						} else {
							dataGrid.addTotalizador("Valor Total", "0.00", true);
						}
						dataGrid.addTotalizador("Guias emitidas", String.valueOf(gridLines), false);							
						dataGrid.makeTotalizador();
						dataGrid.addTotalizadorRight("Total a Pagar", "0.00", "totalSoma");
						dataGrid.makeTotalizadorRight();
						out.print(dataGrid.getTable(gridLines));
						%>												
					</div>
				</div>
				<div class="buttonContent">
					<div class="formGreenButton">
						<input id="selecione" name="selecione" class="greenButtonStyle" type="button" value="todos" onclick="selectAll()" />
					</div>
					<div class="formGreenButton">
						<input id="pagamento" name="pagamento" class="greenButtonStyle" type="button" value="Gerar Fatura" onclick="generate()" />
					</div>				
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close(); %>
	</div>
</body>
</html>