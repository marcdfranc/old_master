<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%> 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.database.Fornecedor"%>
<%@page import="com.marcsoftware.database.PrestadorServico"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.LoteParcelaCompra"%>
<%@page import="com.marcsoftware.database.Lancamento"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.utilities.ControleErro"%><html xmlns="http://www.w3.org/1999/xhtml">
	<jsp:useBean id="fornecedor" class="com.marcsoftware.database.Fornecedor"></jsp:useBean>
	<jsp:useBean id="prestador" class="com.marcsoftware.database.PrestadorServico"></jsp:useBean>
	
	<%boolean isJuridica = request.getParameter("origem").equals("forn");
	ControleErro erro = (ControleErro) session.getAttribute("erro");
	erro.setLink("/application/agrupamento.jsp");
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
	if (!request.getParameter("idFornecedor").equals("0")) {
		if (isJuridica) {
			fornecedor = (Fornecedor) sess.get(Fornecedor.class, Long.valueOf(request.getParameter("idFornecedor")));
		} else {
			prestador = (PrestadorServico) sess.get(PrestadorServico.class, Long.valueOf(request.getParameter("idFornecedor")));
		}
	}
	List<Lancamento> lancamentoList;
	
	%>
	
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Agrupamento</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>	
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/comum/agrupamento.js" ></script>
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
			<form id="unit" method="post" action="../CadastroPosicao">
				<div id="geralDate" class="alignHeader">
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Faturas"/>			
					</jsp:include>
				</div>
				<%if(isJuridica && (!request.getParameter("idFornecedor").equals("0"))) { %>
					<div id="abaMenu">							
						<div class="aba2">
							<a href="cadastro_fornecedor.jsp?state=1&id=<%= fornecedor.getCodigo()%>">Cadastro</a>
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
						<div class="aba2">
							<a href="compra.jsp?origem=forn&idFornecedor=<%= fornecedor.getCodigo()%>">Histórico de Pedidos</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Histórico de Faturas</label>
						</div>
					</div>
				<%} else if((!isJuridica) && (!request.getParameter("idFornecedor").equals("0"))) {%>
					<div id="abaMenu">							
						<div class="aba2">
							<a href="cadastro_prestador_servico.jsp?state=1&id=<%= prestador.getCodigo()%>">Cadastro</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="bordero_fornecedor.jsp?origem=prest&idFornecedor=<%= prestador.getCodigo()%>">Borderô</a>
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
						<div class="sectedAba2">
							<label>Histórico de Faturas</label>
						</div>
					</div>
				<%}%>
				<div class="topContent">
					<%if (isJuridica && request.getParameter("idFornecedor").equals("0")) {%>
						<div class="textBox" style="width:70px">
							<label>Cód. Forn.</label><br/>
							<input id="fornecedorId" name="fornecedorId" type="text" style="width: 70px;" />
						</div>
						<div id="fantasia" class="textBox" style="width:270px">
							<label>Fantasia</label><br/>
							<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 270px"/>
						</div>
						<div id="rzSocial" class="textBox" style="width:270px">
							<label>Razão Social Fornecedor</label><br/>
							<input id="rzSocialIn" name="rzSocialIn" type="text" style="width: 270px"/>
						</div>
						<div id="cnpj" class="textBox" style="width:130px">
							<label>Cnpj Fornecedor</label><br/>
							<input id="cnpjIn" name="cnpjIn" type="text" style="width: 130px;" onkeydown="mask(this, cnpj);"/>
						</div>
						<div id="pedido" class="textBox" style="width:90px">
							<label>Cód. Pedido</label><br/>
							<input id="pedidoIn" name="pedidoIn" type="text" style="width: 90px;" onkeydown="mask(this, onlyInteger);"/>
						</div>
						<div id="cadastro" class="textBox" style="width: 73px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" type="text" style="width: 73px;" onkeydown="mask(this, dateType);" />
						</div>
						<div id="documento" class="textBox" style="width:206px">
							<label>Documento</label><br/>
							<input id="documentoIn" name="documentoIn" type="text" style="width: 206px;" />
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
					<%} else if(isJuridica && (!request.getParameter("idFornecedor").equals("0"))) {%>
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
					<%} else if((!isJuridica) && (!request.getParameter("idFornecedor").equals("0"))) {%>
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
					<%} %>				
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
								query = sess.createQuery("select distinct i.lote from ItensLote as i " +
									" where i.parcelaCompra.id.compra.fornecedor = :fornecedor");
								query.setLong("fornecedor", Long.valueOf(request.getParameter("idFornecedor")));
							} else {
								if (isJuridica) {
									query = sess.createQuery("select distinct i.lote from ItensLote as i " +
									" where i.parcelaCompra.id.compra.fornecedor in (from Fornecedor as f)");
								} else {
									query = sess.createQuery("select distinct i.lote from ItensLote as i " +
										" where i.parcelaCompra.id.compra.fornecedor in (from PrestadorServico as p)");
								}
							}							
						} else {
							if (!request.getParameter("idFornecedor").equals("0")) {
								query = sess.createQuery("select distinct i.lote from ItensLote as i " +
										" where i.parcelaCompra.id.compra.fornecedor = :fornecedor " +
										" and i.parcelaCompra.id.compra.unidade.codigo = :unidade");
								query.setLong("fornecedor", Long.valueOf(request.getParameter("idFornecedor")));
							} else {
								if (isJuridica) {
									query = sess.createQuery("select distinct i.lote from ItensLote as i " +
											" where i.parcelaCompra.id.compra.fornecedor in (from Fornecedor as f) " +
											" and i.parcelaCompra.id.compra.unidade.codigo = :unidade");
								} else {
									query = sess.createQuery("select distinct i.lote from ItensLote as i " + 
											" where i.parcelaCompra.id.compra.fornecedor in (from PrestadorServico as p) " +
											" and i.parcelaCompra.id.compra.unidade.codigo = :unidade");
								}
							}
							query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
						}
						
						List<LoteParcelaCompra> loteList = (List<LoteParcelaCompra>) query.list();
						int gridLines = loteList.size();						
						DataGrid dataGrid = new DataGrid("cadastro_agrupamento.jsp");
						dataGrid.addColum("15", "Código");
						dataGrid.addColum("42", "Mes Base");
						dataGrid.addColum("41", "Ano Base");
						dataGrid.addColum("2", "St");
						for (LoteParcelaCompra lote: loteList) {
							query = sess.createQuery("select i.parcelaCompra.id.lancamento from ItensLote as i where i.lote = :lote");
							query.setEntity("lote", lote);
							dataGrid.setId(String.valueOf(lote.getCodigo()));
							dataGrid.addData(String.valueOf(lote.getCodigo()));
							dataGrid.addData(Util.MES_LITERAL[lote.getMes() -1]);
							dataGrid.addData(lote.getAno());
							dataGrid.addImg(Util.getIcon(query.list(), "lancamento"));
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));
						%>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>1
</html>