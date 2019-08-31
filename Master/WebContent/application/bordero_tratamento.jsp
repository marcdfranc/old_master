<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Empresa"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.ParcelaOrcamento"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="java.util.Date"%>
<%@page import="com.marcsoftware.database.Profissional"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">

	<jsp:useBean id="profissional" class="com.marcsoftware.database.Profissional"></jsp:useBean>

	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);	
	Query query= sess.createQuery("from Empresa as e where e.codigo = :codigo");
	query.setLong("codigo", Long.valueOf(request.getParameter("id")));		
	Empresa empresa = (Empresa) query.uniqueResult();
	query = sess.createQuery("select i.descricao from Informacao as i where i.pessoa = :empresa and i.principal = 's'");
	query.setEntity("empresa", empresa);
	String informacao = (query.list().size() == 1)? (String) query.uniqueResult() : "1"; 
	query = sess.createQuery("select i.descricao from Informacao as i where i.pessoa = :unidade and i.principal = 's'");
	query.setEntity("unidade", empresa.getUnidade());
	String infoUnidade = (String) query.uniqueResult();
	double vlrTotal = 0;
	Date now = new Date();	
	Date vencimento = Util.parseDate("2/" + (Util.getMonthDate(now) + 1) + "/" + Util.getYearDate(now));
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
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/comum/bordero_tratamento.js" ></script>
	
	<title>Master Borderô de Tratamentos de Empresa</title>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="clienteJ"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="clienteJ"/>
		</jsp:include>		
		<div id="formStyle">
			<form id="unit" method="post" action="../CadastroPosicao">
				<div id="geralDate" class="alignHeader">
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Borderô"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="cadastro_cliente_juridico.jsp?state=1&id=<%=empresa.getCodigo() %>">Cadastro</a>
						</div>						
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="#">Anexo</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="cliente_fisico.jsp?&id=<%=empresa.getCodigo() %>">Funcionários</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="fatura_empresa.jsp?&id=<%=empresa.getCodigo() %>">Histórico de Faturas</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="bordero_empresa.jsp?&id=<%=empresa.getCodigo() %>">Borderô</a>
						</div>						
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="bordero_mensalidade.jsp?&id=<%=empresa.getCodigo() %>">Borderô de Mensalidades</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Borderô de Tratamentos</label>
						</div>
					</div>
					<div class="topContent">
						<div id="refUnidade" class="textBox" style="width: 85px;">
							<label>Cod. Unidade</label><br/>
							<input id="refUnidadeIn" name="refUnidadeIn" type="text" style="width: 85px;" value="<%=empresa.getUnidade().getReferencia()%>" readonly="readonly" />
						</div>
						<div id="unidade" class="textBox" style="width: 300px;">
							<label>Unidade</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" style="width: 300px;" value="<%=Util.initCap(empresa.getUnidade().getRazaoSocial())%>" readonly="readonly" />
						</div>
						<div id="telUnidade" class="textBox" style="width: 210px;">
							<label>Telefone</label><br/>
							<input id="telUnidadeIn" name="telUnidadeIn" type="text" style="width: 210px;" value="<%= infoUnidade %>" readonly="readonly" />
						</div>
						<div id="refEmpresa" class="textBox" style="width: 85px;">
							<label>CTR Empresa</label><br/>
							<input id="refEmpresaIn" name="refEmpresaIn" type="text" style="width: 85px;" value="<%=empresa.getReferencia()%>" readonly="readonly" />
						</div>
						<div id="fantasia" class="textBox" style="width: 380px;">
							<label>Empresa</label><br/>
							<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 380px;" value="<%=Util.initCap(empresa.getFantasia())%>" readonly="readonly" />
						</div>
						<div id="cnpj" class="textBox" style="width: 130px;">
							<label>CNPJ</label><br/>
							<input id="cnpjIn" name="cnpjIn" type="text" style="width: 130px;" value="<%=Util.mountCnpj(empresa.getCnpj())%>" readonly="readonly" />
						</div>
						<div id="contato" class="textBox" style="width: 300px;">
							<label>Contato</label><br/>
							<input id="contatoIn" name="contatoIn" type="text" style="width: 300px;" value="<%=Util.initCap(empresa.getContato())%>" readonly="readonly" />
						</div>
						<div id="informacao" class="textBox" style="width: 310px;">
							<label>Telefone</label><br/>
							<input id="informacaoIn" name="informacaoIn" type="text" style="width: 310px;" value="<%=(informacao.equals("-1"))? "" : informacao %>" readonly="readonly" />
						</div>						
					</div>					
				</div>
				<div id="mainContent">				
					<div id="dataGrid" style="" >
						<div id="centerGrid">
							<div id="counter"></div>
							<%query = sess.getNamedQuery("parcelaEmpresa");
							query.setDate("vencimento", vencimento);
							query.setEntity("empresa", empresa);							
							List<ParcelaOrcamento> parcelaList = (List<ParcelaOrcamento>) query.list();
							int gridLines = parcelaList.size();
							DataGrid dataGrid = new DataGrid("#");
							dataGrid.addColum("5", "CTR");
							dataGrid.addColum("32", "Cliente");
							dataGrid.addColum("10", "Orç.");
							dataGrid.addColum("10", "Guia");
							dataGrid.addColum("32", "Profissional");
							dataGrid.addColum("11", "Valor");
							for(ParcelaOrcamento parcela: parcelaList) {
								profissional = (Profissional) sess.get(Profissional.class, parcela.getId().getOrcamento().getPessoa().getCodigo());
								dataGrid.setId(String.valueOf(parcela.getId().getLancamento().getCodigo()));
								dataGrid.addData(String.valueOf(parcela.getId().getOrcamento().getUsuario().getContrato().getCtr()));
								dataGrid.addData(Util.initCap(parcela.getId().getOrcamento().getUsuario().getNome()));
								dataGrid.addData(String.valueOf(parcela.getId().getOrcamento().getCodigo()));
								dataGrid.addData(String.valueOf(parcela.getId().getLancamento().getCodigo()));
								dataGrid.addData(Util.initCap(profissional.getNome()));
								dataGrid.addData(Util.formatCurrency(parcela.getId().getLancamento().getValor()));
								vlrTotal+= parcela.getId().getLancamento().getValor();
								dataGrid.addRow();								
							}
							dataGrid.addTotalizador("Número de Tratamentos", String.valueOf(gridLines), "totalTrat", false);
							dataGrid.makeTotalizador();
							dataGrid.addTotalizadorRight("Valor Total", Util.formatCurrency(vlrTotal));
							dataGrid.makeTotalizadorRight();
							out.print(dataGrid.getTable(gridLines));
							%>
						</div>						
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close(); %>
	</div>
</body>
</html>