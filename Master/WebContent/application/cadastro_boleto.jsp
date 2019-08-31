<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.database.Boleto"%>
<%@page import="org.hibernate.Query"%>
<%@page import="javax.xml.crypto.Data"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.ItensBoleto"%><html xmlns="http://www.w3.org/1999/xhtml">
	<jsp:useBean id="boleto" class="com.marcsoftware.database.Boleto"></jsp:useBean>
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query = null;
	boleto = (Boleto) sess.load(Boleto.class, Long.valueOf(request.getParameter("id")));
	String status = "";
	switch (boleto.getStatus().charAt(0)) {
		case 'a':
			status = "Em Aberto";
			break;
			
		case 'c':
			status = "Cancelado";
			break;
			
		default:
			status = "Quitado";
			break;
	}
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" /> 
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Cadastro de boleto</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="clienteF"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="clienteF"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formPost" method="post" action="../CadastroCaixa" onsubmit= "return validForm(this)">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Boleto"/>
					</jsp:include>
					<div class="topContent">
						<div id="codigo" class="textBox" style="width: 70px;">
							<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 70px;" readonly="readonly" value="<%= boleto.getCodigo() %>"/>
						</div>
						<div id="emissao" class="textBox" style="width: 70px;">
							<label>Emissão</label><br/>
							<input id="emissaoIn" name="emissaoIn" type="text" style="width: 70px;" readonly="readonly" value="<%= Util.parseDate(boleto.getEmissao(), "dd/MM/yyyy") %>"/>
						</div>
						<div id="vencimento" class="textBox" style="width: 70px;">
							<label>Vencimento</label><br/>
							<input id="vencimentoIn" name="vencimentoIn" type="text" style="width: 70px;" readonly="readonly" value="<%= Util.parseDate(boleto.getVencimento(), "dd/MM/yyyy") %>"/>
						</div>
						<div id="status" class="textBox" style="width: 70px;">
							<label>Status</label><br/>
							<input id="statusIn" name="statusIn" type="text" style="width: 70px;" readonly="readonly" value="<%= status %>"/>
						</div>						
						<div id="valor" class="textBox" style="width: 70px;">
							<label>Valor</label><br/>
							<input id="valorIn" name="valorIn" type="text" style="width: 70px;" readonly="readonly" value="<%= Util.formatCurrency(boleto.getValor()) %>"/>
						</div>						
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%query = sess.createQuery("from ItensBoleto as i where i.id.boleto = :boleto");
						query.setEntity("boleto", boleto);
						List<ItensBoleto> itens = (List<ItensBoleto>) query.list();						
						DataGrid dataGrid = new DataGrid(null);
						dataGrid.addColum("8", "Lanç.");
						dataGrid.addColum("27", "Documento");
						dataGrid.addColum("35", "Recebimento");						
						dataGrid.addColum("9", "valor");
						dataGrid.addColum("9", "Valor Pago");
						for(ItensBoleto iten: itens) {
							dataGrid.setId(String.valueOf(iten.getId().getLancamento().getCodigo()));
							dataGrid.addData(String.valueOf(iten.getId().getLancamento().getCodigo()));
							dataGrid.addData(iten.getId().getLancamento().getDocumento());
							dataGrid.addData(iten.getId().getLancamento().getRecebimento());
							dataGrid.addData(Util.formatCurrency(iten.getId().getLancamento().getValor()));
							dataGrid.addData(Util.formatCurrency(iten.getValorResidente()));
							
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(100000));
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