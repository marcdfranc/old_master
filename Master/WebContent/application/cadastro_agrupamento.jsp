<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.database.LoteParcelaCompra"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.ItensLote"%>
<%@page import="com.marcsoftware.database.Fornecedor"%>
<%@page import="com.marcsoftware.database.PrestadorServico"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<jsp:useBean id="lote" class="com.marcsoftware.database.LoteParcelaCompra"></jsp:useBean>
	<jsp:useBean id="fornecedor" class="com.marcsoftware.database.Fornecedor"></jsp:useBean>
	<jsp:useBean id="prestador" class="com.marcsoftware.database.PrestadorServico"></jsp:useBean>
		
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
	lote = (LoteParcelaCompra) sess.get(LoteParcelaCompra.class, Long.valueOf(request.getParameter("id")));
	query = sess.createQuery("from ItensLote as i where i.lote = :lote");
	query.setEntity("lote", lote);	
	List<ItensLote> itensLote = (List<ItensLote>) query.list();
	query = sess.createQuery("from Fornecedor as f where f.codigo = :fornecedor");
	query.setLong("fornecedor", itensLote.get(0).getParcelaCompra().getId().getCompra().getFornecedor().getCodigo());
	boolean isJuridica = query.list().size() > 0;
	if (isJuridica) {
		fornecedor = (Fornecedor) sess.get(Fornecedor.class, itensLote.get(0).getParcelaCompra().getId().getCompra().getFornecedor().getCodigo());
	} else {
		prestador = (PrestadorServico) sess.get(PrestadorServico.class, itensLote.get(0).getParcelaCompra().getId().getCompra().getFornecedor().getCodigo());
	}
	%>

<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Agrupamentos</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>	
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/comum/cadastro_agrupamento.js" ></script>
</head>
<body>
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
						<jsp:param name="currPage" value="Fatura"/>			
					</jsp:include>
				</div>
				<div class="topContent">
					<%if (isJuridica) {%>
						<div id="codigo" class="textBox" style="width: 80px;">
							<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 80px;" value="<%= fornecedor.getCodigo()%>" onchange="setChange('u')"  readonly="readonly"/>
						</div>
						<div id="razaoSocial" class="textBox" style="width: 277px;">
							<label>Razão Social</label><br/>						
							<input id="razaoSocialIn" name="razaoSocialIn" type="text" style="width: 277px;" value="<%= Util.initCap(fornecedor.getRazaoSocial())%>" readonly="readonly" />						
						</div>
						<div id="fantasia" class="textBox" style="width: 277px">
							<label>Fantasia</label><br/>					
							<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 277px" value="<%= Util.initCap(fornecedor.getFantasia())%>" readonly="readonly" />
						</div>
						<div id="cnpj" class="textBox" style="width: 116px">
							<label>Cnpj</label><br/>					
							<input id="cnpjIn" name="cnpjIn" type="text" style="width: 116px" class="required" value="<%= Util.mountCnpj(fornecedor.getCnpj())%>" readonly="readonly" />
						</div>
						<div id="ramo" class="textBox" style="width: 260px">
							<label>Ramo</label><br/>
							<input id="ramoIn" name="ramoIn" type="text" style="width: 260px" class="required" value="<%= fornecedor.getRamo().getDescricao()%>" readonly="readonly" />
						</div>
						<div id="nomeContato" class="textBox" style="width: 258px;">
							<label>Nome do Contato</label><br/>					
							<input id="nomeContatoIn" name="nomeContatoIn" type="text" style="width: 258px" value="<%= Util.initCap(fornecedor.getContato()) %>" readonly="readonly"/>
						</div>
					<%} else {%>
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
					<div id="codGrupo" class="textBox" style="width: 89px">
						<label>Código Grp.</label><br/>
						<input id="codGrupoIn" name="codGrupoIn" type="text" style="width: 89px" value="<%= lote.getCodigo() %>" readonly="readonly" />
					</div>
					<div id="mesId" class="textBox" style="width: 89px">
						<label>Mês Base</label><br/>
						<input id="mesIdIn" name="mesIdIn" type="text" style="width: 89px" class="required" value="<%= Util.MES_LITERAL[lote.getMes() - 1]%>" readonly="readonly" />
					</div>
					<div id="anoId" class="textBox" style="width: 89px">
						<label>Ano Base</label><br/>
						<input id="anoIdIn" name="anoIdIn" type="text" style="width: 89px" class="required" value="<%= lote.getAno() %>" readonly="readonly" />
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%int gridLines = itensLote.size();
						DataGrid dataGrid = new DataGrid("#");
						dataGrid.addColum("10", "Lanç.");
						dataGrid.addColum("26", "Documento");
						dataGrid.addColum("15", "Emissão");
						dataGrid.addColum("15", "Vencimento");
						dataGrid.addColum("15", "Valor");
						dataGrid.addColum("15", "Valor Pago");
						dataGrid.addColum("2", "St");
						dataGrid.addColum("2", "Ck");
						for(ItensLote iten: itensLote) {
							dataGrid.setId(String.valueOf(iten.getParcelaCompra().getId().getLancamento().getCodigo()));
							dataGrid.addData(String.valueOf(iten.getParcelaCompra().getId().getLancamento().getCodigo()));
							dataGrid.addData(iten.getParcelaCompra().getId().getLancamento().getDocumento());
							dataGrid.addData(Util.parseDate(iten.getParcelaCompra().getId().getLancamento().getEmissao(), "dd/MM/yyyy"));
							dataGrid.addData(Util.parseDate(iten.getParcelaCompra().getId().getLancamento().getVencimento(), "dd/MM/yyyy"));
							dataGrid.addData(Util.formatCurrency(iten.getParcelaCompra().getId().getLancamento().getValor()));
							dataGrid.addData(Util.formatCurrency(iten.getParcelaCompra().getId().getLancamento().getValorPago()));
							dataGrid.addImg(Util.getIcon(iten.getParcelaCompra().getId().getLancamento().getVencimento(),
									iten.getParcelaCompra().getId().getLancamento().getStatus()));
							dataGrid.addCheck(true);
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
</body>
</html>