<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="java.util.Date"%>
<%@page import="com.marcsoftware.database.Mensalidade"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query = sess.createQuery("from Unidade as u");
	List<Unidade> unidadeList = (List<Unidade>) query.list();
	double vlrTotal = 0;
	int countMensalidade = 0;
	int countAdesao = 0;
	int countRenovacao = 0;
	Date now = new Date();	
	Date vencimento = Util.parseDate("2/" + (Util.getMonthDate(now) + 1) + "/" + Util.getYearDate(now));
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />	
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Borderô Empresa</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/comum/bordero_mensalidade.js" ></script>
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
			<form id="formEmpresa" method="get" onsubmit="return search();" >
				<div>
					<input type="hidden" id="now" name="now" value="<%=Util.getToday()%>" />
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Borderô"/>
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="empresa.jsp">Jurídico</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="lancamento_empresa.jsp">Bordero Geral</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Bordero de Mensalidades</label>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="lancamento_empresa_tratamento.jsp">Bordero de Tratamentos</a>
						</div>
					</div>
					<div class="topContent">
						<div id="referencia" class="textBox" style="width: 70px;" >
							<label>CTR</label><br/>
							<input id="referenciaIn" name="referenciaIn" type="text" style="width: 70px;" />												
						</div>
						<div id="razaoSocial" class="textBox" style="width: 270px;">
							<label>Razão Social</label><br/>
							<input id="razaoSocialIn" name="razaoSocialIn" type="text" style="width: 270px;" />
						</div>
						<div id="fantasia" class="textBox" style="width: 250px">
							<label>Fantasia</label><br/>
							<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 270px" />
						</div>
						<div id="nomeContato" class="textBox" style="width: 245px">
							<label>Nome do Contato</label><br/>					
							<input id="nomeContatoIn" name="nomeContatoIn" type="text" style="width: 245px" />
						</div>
						<div class="textBox" style="margin-right: 45px">
							<label>Unidade</label><br/>
							<select id="unidadeId" name="unidadeId">
								<option value="">selecione</option>
								<%for(Unidade un: unidadeList) {
									out.print("<option value=\"" + un.getRazaoSocial() + "@" +
											un.getCodigo() + "\">" + un.getReferencia() + "</option>");
								}
								%>
							</select>
						</div>
						<div id="status" class="textBox" style="width: 280px">
							<label >Status</label><br />
							<div class="checkRadio">
								<label class="labelCheck" >Ativo</label>
								<input id="ativoChecked" name="ativoChecked" onchange="setChange('u')" type="radio" checked="checked" value="a" />
								<label class="labelCheck" >Bloqueado</label>
								<input id="ativoChecked" name="ativoChecked" type="radio" onchange="setChange('u')" value="b" />
								<label class="labelCheck" >Cancelado</label>
								<input id="ativoChecked" name="ativoChecked" type="radio" onchange="setChange('u')" value="c" />
							</div>
						</div>
					</div>												
				</div>
				<div class="topButtonContent">
					<div class="formGreenButton">
						<input id="buscar" name="buscar" class="greenButtonStyle" type="submit" value="Buscar"/>								
					</div>
				</div>
				<div id="mainContent">										
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%query = sess.getNamedQuery("mensalidadeEmp");					
						query.setDate("vencimento", vencimento);							
						List<Mensalidade> mensalidadeList = (List<Mensalidade>) query.list();
						int gridLines = mensalidadeList.size();
						DataGrid dataGrid = new DataGrid("#");
						dataGrid.addColum("5", "CTR");
						dataGrid.addColum("50", "Cliente");
						dataGrid.addColum("25", "Descrição");
						dataGrid.addColum("10", "Vencimento");
						dataGrid.addColum("10", "Valor");
						for(Mensalidade mensalidade: mensalidadeList) {
							dataGrid.setId(String.valueOf(mensalidade.getCodigo()));
							dataGrid.addData(Util.zeroToLeft(mensalidade.getUsuario().getContrato().getCodigo(), 4));
							dataGrid.addData(Util.initCap(mensalidade.getUsuario().getNome()));
							dataGrid.addData(mensalidade.getLancamento().getConta().getDescricao());
							dataGrid.addData(Util.parseDate(mensalidade.getLancamento().getVencimento(), "dd/MM/yyyy"));
							dataGrid.addData(Util.formatCurrency(mensalidade.getLancamento().getValor()));
							if (mensalidade.getLancamento().getConta().getDescricao().trim().equals("adesão")) {
								countAdesao++;
							} else if(mensalidade.getLancamento().getConta().getDescricao().trim().equals("renovação")) {
								countRenovacao++;
							} else {
								countMensalidade++;
							}
							vlrTotal+= mensalidade.getLancamento().getValor();
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));
						%>
					</div>
					<div class="totalizador">
						<label id="total" name="total" style="margin-left: 15px"><%= Util.formatCurrency(vlrTotal) %></label>
						<label id="labelTotal" class="titleCounter">Adesões: <%=countAdesao%> - Renovações: <%=countRenovacao%> - Mensalidades: <%= countMensalidade %> - Valor Total: </label>
					</div>
				</div>				
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close(); %>
	</div>
</body>
</html>