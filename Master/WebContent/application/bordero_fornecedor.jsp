<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Session"%>

<%@page import="com.marcsoftware.database.Fornecedor"%>
<%@page import="com.marcsoftware.database.PrestadorServico"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.ParcelaCompra"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="java.util.Date"%><html xmlns="http://www.w3.org/1999/xhtml">
	<jsp:useBean id="fornecedor" class="com.marcsoftware.database.Fornecedor"></jsp:useBean>
	<jsp:useBean id="prestador" class="com.marcsoftware.database.PrestadorServico"></jsp:useBean>

	<%boolean isJuridica = request.getParameter("origem").equals("forn");
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
	if (!request.getParameter("idFornecedor").equals("0")) {
		if (isJuridica) {
			fornecedor = (Fornecedor) sess.get(Fornecedor.class, Long.valueOf(request.getParameter("idFornecedor")));
		} else {
			prestador = (PrestadorServico) sess.get(PrestadorServico.class, Long.valueOf(request.getParameter("idFornecedor")));
		}
	}
	%>
<head>
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	<link rel="shortcut icon" href="../icone.ico">
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Bordero de Fornecedores</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/comum/bordero_fornecedor.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/default.js" ></script>
</head>
<body>
	<jsp:include page="../inc/pdv.jsp"></jsp:include>
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
			<form id="orc" method="get" onsubmit="return search()" >
				<input type="hidden" id="origem" name="origem" value="<%= request.getParameter("origem") %>" />				
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Borderô"/>
					</jsp:include>
					<%if (isJuridica && !request.getParameter("idFornecedor").equals("0")) {%>
						<div id="abaMenu">							
							<div class="aba2">
								<a href="cadastro_fornecedor.jsp?state=1&id=<%= fornecedor.getCodigo()%>">Cadastro</a>
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
								<a href="pedido.jsp?origem=forn&idFornecedor=<%= fornecedor.getCodigo()%>">Gerar Pedido</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="compra.jsp?origem=forn&idFornecedor=<%= fornecedor.getCodigo()%>">Histórico de Pedidos</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="agrupamento.jsp?origem=forn&idFornecedor=<%= fornecedor.getCodigo()%>">Histórico de Faturas</a>
							</div>
						</div>
					<%} else if (!request.getParameter("idFornecedor").equals("0")) {%>
						<div id="abaMenu">							
							<div class="aba2">
								<a href="cadastro_prestador_servico.jsp?state=1&id=<%= prestador.getCodigo()%>">Cadastro</a>
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
								<a href="pedido.jsp?origem=prest&idFornecedor=<%= prestador.getCodigo()%>">Gerar Pedido</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="compra.jsp?origem=prest&idFornecedor=<%= prestador.getCodigo()%>">Histórico de Pedidos</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="agrupamento.jsp?origem=prest&idFornecedor=<%= prestador.getCodigo()%>">Histórico de Faturas</a>
							</div>
						</div>
					<%}%>				
					<div class="topContent">
						<%if (isJuridica && !request.getParameter("idFornecedor").equals("0")) {%>
							<div id="codigo" class="textBox" style="width: 70px;">
								<label>Código</label><br/>
								<input id="codigoIn" name="codigoIn" type="text" style="width: 70px;" value="<%= fornecedor.getCodigo()%>" onchange="setChange('u')"  readonly="readonly"/>
							</div>
							<div id="razaoSocial" class="textBox" style="width: 270px;">
								<label>Razão Social</label><br/>						
								<input id="razaoSocialIn" name="razaoSocialIn" type="text" style="width: 270px;" value="<%= Util.initCap(fornecedor.getRazaoSocial())%>" readonly="readonly" />						
							</div>
							<div id="fantasia" class="textBox" style="width: 270px">
								<label>Fantasia</label><br/>					
								<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 270px" value="<%= Util.initCap(fornecedor.getFantasia())%>" readonly="readonly" />
							</div>
							<div id="cnpj" class="textBox" style="width: 116px">
								<label>Cnpj</label><br/>					
								<input id="cnpjIn" name="cnpjIn" type="text" style="width: 116px" class="required" value="<%= Util.mountCnpj(fornecedor.getCnpj())%>" readonly="readonly" />
							</div>
							<div id="ramo" class="textBox" style="width: 248px">
								<label>Ramo</label><br/>
								<input id="ramoIn" name="ramoIn" type="text" style="width: 248px" class="required" value="<%= fornecedor.getRamo().getDescricao()%>" readonly="readonly" />
							</div>
							<div id="nomeContato" class="textBox" style="width: 246px;">
								<label>Nome do Contato</label><br/>					
								<input id="nomeContatoIn" name="nomeContatoIn" type="text" style="width: 246px" value="<%= Util.initCap(fornecedor.getContato()) %>" readonly="readonly"/>
							</div>
						<%} else if (!request.getParameter("idFornecedor").equals("0")) { %>
							<div id="codigo" class="textBox" style="width: 80px;">
								<label>Código</label><br/>
								<input id="codigoIn" name="codigoIn" type="text" style="width: 80px;" value="<%= prestador.getCodigo()%>" readonly="readonly"/>
							</div>
							<div id="nome" class="textBox" style="width: 285px;">
								<label>Nome</label><br/>
								<input id="nomeIn" name="nomeIn" type="text" style="width: 285px;" value="<%= Util.initCap(prestador.getNome()) %>" readonly="readonly" />
							</div>
							<div id="cpf" class="textBox" style="width: 100px">
								<label>Cpf</label><br/>
								<input id="cpfIn" name="cpfIn" type="text" style="width: 100px" value="<%= Util.mountCpf(prestador.getCpf()) %>" readonly="readonly" />
							</div>
							<div id="rg" class="textBox" style="width: 89px">
								<label>Rg</label><br/>
								<input id="rgIn" name="rgIn" type="text" style="width: 89px" value="<%= prestador.getRg()%>" readonly="readonly" />
							</div>
							<div id="ramo" class="textBox" style="width: 260px">
								<label>Ramo</label><br/>
								<input id="ramoIn" name="ramoIn" type="text" style="width: 260px" class="required" value="<%= prestador.getRamo().getDescricao()%>" readonly="readonly" />
							</div>
						<%}%>
					</div>
				</div>				
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%if (session.getAttribute("perfil").toString().equals("a")
								|| session.getAttribute("perfil").toString().equals("d")) {
							if (request.getParameter("idFornecedor").equals("0")) {
								query = sess.createQuery("from ParcelaCompra as p " +
										" where p.id.lancamento.status in ('a', 'n') " +
										" and p.id.lancamento.vencimento < :vencimento");
								query.setDate("vencimento", Util.getLastDateOfMonth(new Date()));
							} else {
								query = sess.createQuery("from ParcelaCompra as p " +
										" where p.id.lancamento.status in ('a', 'n') " +
										" and p.id.compra.fornecedor.codigo = :fornecedor " +
										" and p.id.lancamento.vencimento < :vencimento");
								query.setLong("fornecedor", Long.valueOf(request.getParameter("idFornecedor")));
								query.setDate("vencimento", Util.getLastDateOfMonth(new Date()));
							}
						} else {
							if (request.getParameter("idFornecedor").equals("0")) {
								query = sess.createQuery("from ParcelaCompra as p " +
										" where p.id.lancamento.status in ('a', 'n') " +
										" and p.id.compra.unidade.codigo = :unidade " +
										" and p.id.lancamento.vencimento < :vencimento");
								query.setDate("vencimento", Util.getLastDateOfMonth(new Date()));
							} else {
								query = sess.createQuery("from ParcelaCompra as p " +
										" where p.id.lancamento.status in ('a', 'n') " +
										" and p.id.compra.unidade.codigo = :unidade " +
										" and p.id.compra.fornecedor.codigo = :fornecedor " +
										" and p.id.lancamento.vencimento < :vencimento");
								query.setLong("fornecedor", Long.valueOf(request.getParameter("idFornecedor")));
								query.setDate("vencimento", Util.getLastDateOfMonth(new Date()));
							}
							query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
						}
						List<ParcelaCompra> parcelaList = (List<ParcelaCompra>) query.list();
						int gridLines = parcelaList.size();
						DataGrid dataGrid = new DataGrid("#");
						dataGrid.addColum("10", "Cod. Ped.");
						dataGrid.addColum("10", "Lanç.");
						dataGrid.addColum("26", "Documento");
						dataGrid.addColum("15", "Emissão");
						dataGrid.addColum("15", "Vencimento");
						dataGrid.addColum("15", "Valor");
						for (ParcelaCompra parcela: parcelaList) {
							dataGrid.setId(String.valueOf(parcela.getId()));
							dataGrid.addData(String.valueOf(parcela.getId().getCompra().getCodigo()));
							dataGrid.addData(String.valueOf(parcela.getId().getLancamento().getCodigo()));							
							if (parcela.getId().getLancamento().getDocumento() == null) {
								dataGrid.addData("--------");
							} else {
								dataGrid.addData(parcela.getId().getLancamento().getDocumento());
							}
							dataGrid.addData(Util.parseDate(parcela.getId().getLancamento().getEmissao(), "dd/MM/yyyy"));
							dataGrid.addData(Util.parseDate(parcela.getId().getLancamento().getVencimento(), "dd/MM/yyyy"));
							dataGrid.addData(Util.formatCurrency(parcela.getId().getLancamento().getValor()));
							
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));
						%>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close(); %>
	</div>
</body>
</html>