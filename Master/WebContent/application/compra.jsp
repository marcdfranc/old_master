<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@page import="com.marcsoftware.database.FormaPagamento"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Compra"%>
<%@page import="com.marcsoftware.database.ParcelaCompra"%>


<%@page import="com.marcsoftware.database.Fornecedor"%>
<%@page import="com.marcsoftware.database.PrestadorServico"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	
	<jsp:useBean id="prestadorServico" class="com.marcsoftware.database.PrestadorServico"></jsp:useBean>
	<jsp:useBean id="fornecedor" class="com.marcsoftware.database.Fornecedor"></jsp:useBean>
	
	
	<%boolean isJuridica = request.getParameter("origem").equals("forn");
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
	if (session.getAttribute("perfil").equals("a")) {
		query= sess.createQuery("from Unidade as u where u.deleted =\'n\'");		
	} else if (session.getAttribute("perfil").equals("f")) {
		query= sess.getNamedQuery("unidadeByUser");
		query.setString("username", (String) session.getAttribute("username"));
	} else {
		query = sess.createQuery("select p.unidade from Pessoa as p where p.login = :username");
		query.setString("username", (String) session.getAttribute("username"));
	}
	
	List<Unidade> unidadeList= (List<Unidade>) query.list();
	List<ParcelaCompra> parcelaList = null;
	if (isJuridica && (!request.getParameter("idFornecedor").equals("0"))) {
		fornecedor = (Fornecedor) sess.get(Fornecedor.class, Long.valueOf(request.getParameter("idFornecedor")));
	} else if ((!isJuridica) && (!request.getParameter("idFornecedor").equals("0"))) {
		prestadorServico = (PrestadorServico) sess.get(PrestadorServico.class, Long.valueOf(request.getParameter("idFornecedor")));
	}
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
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	<link rel="shortcut icon" href="../icone.ico">
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Pedidos</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/comum/compra.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/default.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
</head>
<body onload="load()" >	
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
						<jsp:param name="currPage" value="Ped. Serviços"/>
					</jsp:include>
					<%if (isJuridica && (!request.getParameter("idFornecedor").equals("0"))) {%>
						<div id="abaMenu">
							<div class="aba2">
								<a href="<%="cadastro_fornecedor.jsp?state=1&id=" + fornecedor.getCodigo() %>">Cadastro</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="bordero_fornecedor.jsp?origem=forn&idFornecedor=<%= fornecedor.getCodigo()%>">Borderô</a>
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
							<div class="sectedAba2">
								<label>Histórico de Pedidos</label>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="agrupamento.jsp?origem=forn&idFornecedor=<%= fornecedor.getCodigo()%>">Histórico de Faturas</a>
							</div>
						</div>
					<%} else if ((!isJuridica) && (!request.getParameter("idFornecedor").equals("0"))) {%>
						<div id="abaMenu">
							<div class="aba2">
								<a href="<%="cadastro_prestador_servico.jsp?state=1&id=" + prestadorServico.getCodigo()%>">Cadastro</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="bordero_fornecedor.jsp?origem=prest&idFornecedor=<%= prestadorServico.getCodigo()%>">Borderô</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>							
							<div class="aba2">
								<a href="pedido.jsp?origem=prest&idFornecedor=<%= prestadorServico.getCodigo()%>">Gerar Pedido</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>					
							<div class="sectedAba2">
								<label>Histórico de Pedidos</label>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="agrupamento.jsp?origem=prest&idFornecedor=<%= prestadorServico.getCodigo()%>">Histórico de Faturas</a>
							</div>
						</div>
					<%}%>
					<div class="topContent">
						<%if (isJuridica && request.getParameter("idFornecedor").equals("0")) {%>
							<div class="textBox" style="width:70px">
								<label>Cód. Forn.</label><br/>
								<input id="fornecedorId" name="fornecedorId" type="text" style="width: 70px;" />
							</div>
							<div id="fantasia" class="textBox" style="width:280px">
								<label>Fantasia</label><br/>
								<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 280px"/>
							</div>
							<div id="rzSocial" class="textBox" style="width:280px">
								<label>Razão Social Fornecedor</label><br/>
								<input id="rzSocialIn" name="rzSocialIn" type="text" style="width: 280px"/>
							</div>
							<div id="cnpj" class="textBox" style="width:130px">
								<label>Cnpj Fornecedor</label><br/>
								<input id="cnpjIn" name="cnpjIn" type="text" style="width: 130px;" onkeydown="mask(this, cnpj);"/>
							</div>
						<%} else if(isJuridica && (!request.getParameter("idFornecedor").equals("0"))) {%>
							<div id="codigo" class="textBox" style="width: 80px;">
								<label>Código</label><br/>
								<input id="codigoIn" name="codigoIn" type="text" style="width: 80px;" value="<%= fornecedor.getCodigo()%>" onchange="setChange('u')"  readonly="readonly"/>
							</div>
							<div id="razaoSocial" class="textBox" style="width: 277px;">
								<label>Razão Social</label><br/>						
								<input id="razaoSocialIn" name="razaoSocialIn" type="text" style="width: 277px;" value="<%= Util.initCap(fornecedor.getRazaoSocial())%>" readonly="readonly" />						
							</div>
							<div id="fantasia" class="textBox" style="width: 250px">
								<label>Fantasia</label><br/>					
								<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 250px" value="<%= Util.initCap(fornecedor.getFantasia())%>" readonly="readonly" />
							</div>
							<div id="cnpj" class="textBox" style="width: 116px">
								<label>Cnpj</label><br/>					
								<input id="cnpjIn" name="cnpjIn" type="text" style="width: 116px" class="required" value="<%= Util.mountCnpj(fornecedor.getCnpj())%>" readonly="readonly" />
							</div>
							<div id="ramo" class="textBox" style="width: 250px">
								<label>Ramo</label><br/>
								<input id="ramoIn" name="ramoIn" type="text" style="width: 250px" class="required" value="<%= fornecedor.getRamo().getDescricao()%>" readonly="readonly" />
							</div>
							<div id="nomeContato" class="textBox" style="width: 240px;">
								<label>Nome do Contato</label><br/>					
								<input id="nomeContatoIn" name="nomeContatoIn" type="text" style="width: 240px" value="<%= Util.initCap(fornecedor.getContato()) %>" readonly="readonly"/>
							</div>
						<%} else if((!isJuridica) && request.getParameter("idFornecedor").equals("0")) {%>
							<div class="textBox" style="width:70px">
								<label>Cód. Prest.</label><br/>
								<input id="fornecedorId" name="fornecedorId" type="text" style="width: 70px;"/>
							</div>
							<div id="nome" class="textBox" style="width: 278px;">
								<label>Nome</label><br/>
								<input id="nomeIn" name="nomeIn" type="text" style="width: 278px;"/>
							</div>
							<div id="cpf" class="textBox" style="width: 105px;">
								<label>Cpf</label><br/>
								<input id="cpfIn" name="cpfIn" type="text" style="width: 100px" onkeydown="mask(this, cpf);" />
							</div>
							<div id="rg" class="textBox" style="width: 90px">
								<label>Rg</label><br/>
								<input id="rgIn" name="rgIn" type="text" style="width: 90px" />
							</div>
							<div id="nascimento" class="textBox" style="width: 73px;">
								<label>Nascimento</label><br/>
								<input id="nascimentoIn" name="nascimentoIn" type="text" style="width: 73px;" onkeydown="mask(this, cpf);" />
							</div>
						<%} else if((!isJuridica) && (!request.getParameter("idFornecedor").equals("0"))) {%>
							<div id="codigo" class="textBox" style="width: 80px;">
								<label>Código</label><br/>
								<input id="codigoIn" name="codigoIn" type="text" style="width: 80px;" value="<%= prestadorServico.getCodigo()%>" readonly="readonly"/>
							</div>
							<div id="nome" class="textBox" style="width: 285px;">
								<label>Nome</label><br/>
								<input id="nomeIn" name="nomeIn" type="text" style="width: 285px;" value="<%= Util.initCap(prestadorServico.getNome()) %>" readonly="readonly" />
							</div>
							<div id="cpf" class="textBox" style="width: 100px">
								<label>Cpf</label><br/>
								<input id="cpfIn" name="cpfIn" type="text" style="width: 100px" value="<%= Util.mountCpf(prestadorServico.getCpf()) %>" readonly="readonly" />
							</div>
							<div id="rg" class="textBox" style="width: 89px">
								<label>Rg</label><br/>
								<input id="rgIn" name="rgIn" type="text" style="width: 89px" value="<%= prestadorServico.getRg()%>" readonly="readonly" />
							</div>
							<div id="ramo" class="textBox" style="width: 260px">
								<label>Ramo</label><br/>
								<input id="ramoIn" name="ramoIn" type="text" style="width: 260px" class="required" value="<%= prestadorServico.getRamo().getDescricao()%>" readonly="readonly" />
							</div>
						<%} %>
						<div id="pedido" class="textBox" style="width:90px">
							<label>Cód. Pedido</label><br/>
							<input id="pedidoIn" name="pedidoIn" type="text" style="width: 90px;" onkeydown="mask(this, onlyInteger);"/>
						</div>
						<div id="cadastro" class="textBox" style="width: 73px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" type="text" style="width: 73px;" onkeydown="mask(this, dateType);" />
						</div>
						<div id="documento" class="textBox" style="width:120px">
							<label>Documento</label><br/>
							<input id="documentoIn" name="documentoIn" type="text" style="width: 120px;" />
						</div>
						<div id="unidadeIn" class="textBox">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId">
								<% if (session.getAttribute("perfil").toString().equals("a")) {%>
									<option value="">Selecione</option>									
								<%} else {%>
									<option value="0">Selecione</option>
								<%}%>							
								<%if (unidadeList.size() == 1) {
									out.print("<option value=\"" + unidadeList.get(0).getCodigo() + 
											"\" selected=\"selected\">" + unidadeList.get(0).getReferencia() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										out.print("<option value=\"" + un.getCodigo() + "\">" + 
												un.getReferencia() + "</option>");
									}
								}
								%>
							</select>
						</div>
					</div>
				</div>
				<div class="topButtonContent">
					<div class="leftButtonContent">
						<input type="submit" id="buscar" name="buscar" class="greenButtonStyle"  value="Buscar"/>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%if (session.getAttribute("perfil").toString().equals("a")
								|| session.getAttribute("perfil").toString().equals("d")) {
							if (!request.getParameter("idFornecedor").equals("0")) {
								query = sess.createQuery("from Compra as c where c.fornecedor.codigo = :fornecedor order by c.cadastro desc");
								query.setLong("fornecedor", Long.valueOf(request.getParameter("idFornecedor")));
							} else {
								if (isJuridica) {
									query = sess.createQuery("from Compra as c where c.fornecedor in( " +
											"from Fornecedor as f) order by c.cadastro desc");
								} else {							
									query = sess.createQuery("from Compra as c where c.fornecedor in( " +
										"from PrestadorServico as p) order by c.cadastro desc");
								}
							}							
						} else {
							if (!request.getParameter("idFornecedor").equals("0")) {
								query = sess.createQuery("from Compra as c " + 
										" where c.fornecedor.codigo = :fornecedor " + 
										" and c.unidade.codigo = :unidade " +
										" order by c.cadastro desc");
								query.setLong("fornecedor", Long.valueOf(request.getParameter("idFornecedor")));
							} else {
								if (isJuridica) {
									query = sess.createQuery("from Compra as c " + 
											" where c.fornecedor in( from Fornecedor as f) " +
											" and c.unidade.codigo = :unidade " +
											" order by c.cadastro desc");
								} else {							
									query = sess.createQuery("from Compra as c " +
											" where c.fornecedor in(from PrestadorServico as p) " +
											" and c.unidade.codigo = :unidade " +
											" order by c.cadastro desc");
								}
							}
							query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
						}
						
						
						int gridLines= query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(30);
						List<Compra> compraList = (List<Compra>) query.list();
						DataGrid dataGrid = new DataGrid(null);
						dataGrid.addColum("10", "Código");
						if (isJuridica) {
							dataGrid.addColum("38", "Fornecedor");							
						} else {
							dataGrid.addColum("38", "Prestador");
						}
						dataGrid.addColum("25", "Documento");
						dataGrid.addColum("10", "Cadastro");																		
						dataGrid.addColum("15", "Valor");
						dataGrid.addColum("2", "St.");
						for (Compra compra: compraList) {
							if (isJuridica) {
								query = sess.createQuery("select f.fantasia from Fornecedor as f where f.codigo = :codigo");
							} else {
								query = sess.createQuery("select p.nome from PrestadorServico as p where p.codigo = :codigo");
							}
							query.setLong("codigo", compra.getFornecedor().getCodigo());
							dataGrid.setId(String.valueOf(compra.getCodigo()));							
							dataGrid.addData(String.valueOf(compra.getCodigo()));							
							dataGrid.addData(Util.initCap(query.uniqueResult().toString()));
							
							query = sess.createQuery("from ParcelaCompra as p where p.id.compra = :compra");
							query.setEntity("compra", compra);
							parcelaList = (List<ParcelaCompra>) query.list();
							if (parcelaList.size() == 0) {
								dataGrid.addData("--------");
							} else {
								dataGrid.addData(parcelaList.get(0).getId().getLancamento().getDocumento());
							}
							dataGrid.addData(Util.parseDate(compra.getCadastro(), "dd/MM/yyyy"));
							query = sess.createSQLQuery("SELECT SUM(i.quantidade * i.custo) " + 
									" FROM itens_compra AS i " +
									" WHERE i.cod_compra = :compra");
							query.setLong("compra", compra.getCodigo());							
							dataGrid.addData(Util.formatCurrency(query.uniqueResult().toString()));
							
							if (parcelaList.size() == 0) {
								dataGrid.addImg("../image/em_aberto.png");
							} else {
								dataGrid.addImg(Util.getIcon(parcelaList, "compra"));
							}
							
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