<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.FormaPagamento"%>
<%@page import="com.marcsoftware.database.Conciliacao"%>
<%@page import="com.marcsoftware.database.ItensConciliacao"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<html xmlns="http://www.w3.org/1999/xhtml">
<jsp:useBean id="conciliacao" class="com.marcsoftware.pageBeans.ConciliacaoBean">
	
</jsp:useBean>

	<%!boolean isEdition= false;%>
	<%isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}%>		

	
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	conciliacao.setSessionPage(Long.valueOf(session.getAttribute("acessoId").toString()), request, sess);
	conciliacao.setId(Long.valueOf(request.getParameter("id")));
	conciliacao.bind();
	%>

<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<link type="text/css" href="../js/jquery/uploaddif/uploadify.css" rel="Stylesheet" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/uploaddif/swfobject.js"></script>
	<script type="text/javascript" src="../js/jquery/uploaddif/jquery.uploadify.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/comum/cadastro_conciliacao.js" ></script>
	
		
	<title>Master Cadastro Conciliação</title>
</head>
<body >
	<%for(String iten: conciliacao.getListHidden()) {%>
		<input type="hidden" id="pipeConfig<%= Util.getPipeById(iten, 0) %>" name="pipeConfig<%= Util.getPipeById(iten, 0) %>" value="<%= Util.getPipeById(iten, 1) + "@" + Util.getPipeById(iten, 2) %>" />
		<div id="pop_id<%= Util.getPipeById(iten, 0) %>" class="removeBorda" title="Upload da Imagem de Documentos de Conciliação" style="display: none">
			<form id="formUpload" onsubmit="return false;" action="../ContratoSocialUpload" method="post" enctype="multipart/form-data">
				<div class="uploadContent" id="contUpload">
					<div id="msgUpload" style="margin-bottom: 20px;">Clique abaixo para selecionar o arquivo pdf a ser enviado.</div>
					<div id="fileQueue" style="width: 200px;"></div>
					<input type="file" name="conteinerUp<%= Util.getPipeById(iten, 0) %>" id="conteinerUp<%= Util.getPipeById(iten, 0) %>" />
				</div>
				<input type="hidden" value="" id="uploadName" name="uploadName" />
			</form>
		</div>
	<%}%>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="financeiro"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="financeiro"/>			
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="get" onsubmit="return search()">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="<%=(conciliacao.getItensList().get(0).getId().getLancamento().getTipo().equals("c"))? "Crédito a Conciliar" : "Débito a Conciliar" %>"/>		
					</jsp:include>
					<div class="topContent">
						<div id="codigo" class="textBox" style="width: 70px;">
						<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 70px;" readonly="readonly" value="<%= conciliacao.getItensList().get(0).getId().getConciliacao().getCodigo() %>"/>
						</div>					
						<div id="numero" class="textBox" style="width: 130px;">
							<label>Número</label><br/>
							<input id="numeroIn" readonly="readonly" name="numeroIn" type="text" style="width: 130px;" onkeydown="mask(this, dateType);" value="<%= conciliacao.getItensList().get(0).getId().getConciliacao().getNumero() %>" />
						</div>
						<div id="emissao" class="textBox" style="width: 73px;">
							<label>Emissão</label><br/>
							<input id="emissaoIn" name="emissaoIn" type="text" readonly="readonly" class="required" style="width: 73px;"  value="<%= Util.parseDate(conciliacao.getItensList().get(0).getId().getConciliacao().getEmissao() , "dd/MM/yyyy")%>" />
						</div>
						<div class="textBox">
							<label>Pagamento</label><br/>
							<select id="tipoPagamento" style="width: 180px" name="tipoPagamento" disabled="disabled">
								<%for(FormaPagamento pag: conciliacao.getPagamento()) {
									if (isEdition) {
										if (conciliacao.getItensList().get(0).getId().getConciliacao().getFormaPagamento().equals(pag)) {
											out.println("<option value=\"" + pag.getCodigo() +
													"\" selected=\"selected\" >" + pag.getDescricao() + "</option>");
										} else {
											out.println("<option value=\"" + pag.getCodigo() +
													"\" >" + pag.getDescricao() + "</option>");
										}
									} else {
										out.println("<option value=\"" + pag.getCodigo() +
												"\" >" + pag.getDescricao() + "</option>");
									}
								}%>								
							</select>
						</div>						
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%int gridLines = conciliacao.getItensList().size();												
						DataGrid dataGrid = new DataGrid(null);
						dataGrid.addColum("15", "Lanç.");					
						dataGrid.addColum("40", "Documento");
						dataGrid.addColum("15", "Emissão");
						dataGrid.addColum("20", "Vencimento");
						dataGrid.addColum("10", "Valor");						
						for(ItensConciliacao iten: conciliacao.getItensList()) {							
							dataGrid.setId(String.valueOf(iten.getId().getLancamento().getCodigo()));
							dataGrid.addData(String.valueOf(iten.getId().getLancamento().getCodigo()));
							dataGrid.addData(iten.getId().getLancamento().getDocumento());
							dataGrid.addData(Util.parseDate(iten.getId().getLancamento().getEmissao(), "dd/MM/yyyy"));
							dataGrid.addData(Util.parseDate(iten.getId().getLancamento().getVencimento(), "dd/MM/yyyy"));
							dataGrid.addData(Util.formatCurrency(iten.getId().getLancamento().getValorPago()));
							conciliacao.setValTotal(conciliacao.getValTotal() + iten.getId().getLancamento().getValorPago());
							dataGrid.addRow();
						}
						dataGrid.addTotalizadorRight("Valor Total: ", String.valueOf(Util.round(conciliacao.getValTotal(), 2)));
						dataGrid.makeTotalizadorRight();
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