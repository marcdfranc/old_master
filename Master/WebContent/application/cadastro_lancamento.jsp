<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Lancamento"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.database.TipoConta"%>
<%@page import="com.marcsoftware.database.FormaPagamento"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%!boolean isEdition= false;%>
	<%isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {		
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}%>
	
	<jsp:useBean id="lancamento" class="com.marcsoftware.database.Lancamento"></jsp:useBean>
	
	<%	
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
	
	List<Unidade> unidadeList = (List<Unidade>) query.list();
	
	query = sess.createQuery("from TipoConta as t where t.codigo not in(61, 62) order by t.codigo");
	List<TipoConta> conta = (List<TipoConta>) query.list();
	
	query = sess.createQuery("from FormaPagamento as f");
	List<FormaPagamento> formaPagamento = (List<FormaPagamento>) query.list(); 
	
	if(isEdition) {
		query= sess.createQuery("from Lancamento as l where l.codigo = :codigo");
		query.setLong("codigo", Long.valueOf(request.getParameter("id")));
		lancamento= (Lancamento) query.uniqueResult();
	}
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
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/validation.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/comum/cadastro_lancamento.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_window.js"></script>
	
	<title>Master - Cadastro de Lançamento</title>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="financeiro"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="financeiro"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formPost" name="formPost" method="post" action="../CadastroLancamento">
				<div>
					<input name="numTitulo" id="numTitulo" type="hidden" value="" />
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Lanç. Conta"/>
					</jsp:include>
					<div class="topContent">
						<%if (isEdition) {%>
							<div id="codigo" class="textBox" style="width: 80px;">
								<label>Código</label><br/>
								<input id="codigoIn" name="codigoIn" type="text" style="width: 80px;" readonly="readonly"  value="<%= lancamento.getCodigo() %>"/>
							</div>
						<%}%>
						<div class="textBox" id="unidadeId" name="unidadeId" style="width: 90px;">
							<label>Código Un.</label><br/>
							<select id="unidadeIdIn" name="unidadeIdIn"  
								<% if (isEdition) {
									out.print("disabled=\"disabled\"");
								}						
								%>>
								<option value="" >Selecione</option> 								
								<%if (!isEdition && unidadeList.size()== 1) {
									out.print("<option selected=\"selected\" value=\"" +											
											unidadeList.get(0).getCodigo() + "\">" + 
											unidadeList.get(0).getReferencia() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										if (isEdition && lancamento.getUnidade().equals(un)) {
											out.print("<option selected=\"selected\" value=\"" +													 
													un.getCodigo() + "\">" + 
													un.getReferencia() + "</option>");
										} else {
											out.print("<option value=\"" + un.getCodigo() + 
													"\">" + un.getReferencia() + "</option>");
										}
									}									
								}%>
							</select>
						</div>
						<div id="conta" class="textBox">
							<label>Descrição</label><br/>
							<select type="select-multiple" id="contaIn" name="contaIn" class="required" onblur="genericValid(this);">
								<option value="" >Selecione</option> 								
								<%for(TipoConta ct: conta) {
									if (isEdition && lancamento.getConta().equals(ct)) {
										out.print("<option selected=\"selected\" value=\"" + 
												ct.getCodigo() + "\">" + 
												Util.initCap(ct.getDescricao()) + "</option>");
									} else {
										out.print("<option value=\"" + ct.getCodigo() + "\">" + 
												Util.initCap(ct.getDescricao()) + "</option>");
									}
								}%>
							</select>
						</div>
						<div id="documento" class="textBox" style="width: 200px;">
							<label>Documento</label><br/>
							<input id="documentoIn" name="documentoIn" type="text" style="width: 200px;" value="<%=(isEdition)? lancamento.getDocumento() : "" %>" class="required" onblur="genericValid(this);"/>
						</div>
						<div class="textBox">
							<label>Pagamento</label><br/>
							<select id="tipoPagamento" style="width: 180px" name="tipoPagamento" >
								<%for(FormaPagamento pag: formaPagamento) {
									if (String.valueOf(pag.getCodigo()).equals("2")) {
										out.println("<option value=\"" + pag.getCodigo() + "@" + pag.getConcilia() +
											"\" selected=\"selected\" >" + pag.getDescricao() + "</option>");
									} else {
										out.println("<option value=\"" + pag.getCodigo() + "@" + pag.getConcilia() +
												"\">" + pag.getDescricao() + "</option>");
									}
								}%>
							</select>
						</div>
						<div id="emissao" class="textBox" style="width: 80px;">
							<label>Emissao</label><br/>
							<input id="emissaoIn" name="emissaoIn" type="text" style="width: 80px;" value="<%=(isEdition)? Util.parseDate(lancamento.getEmissao(), "dd/MM/yyyy") : "" %>" class="required" onblur="genericValid(this);" onkeydown="mask(this, dateType);"/>
						</div>
						<div id="vencimento" class="textBox" style="width: 80px;">
							<label>Vencimento</label><br/>
							<input id="vencimentoIn" name="vencimentoIn" type="text" style="width: 80px;" value="<%=(isEdition)? Util.parseDate(lancamento.getVencimento(), "dd/MM/yyyy") : "" %>" class="required" onblur="genericValid(this);" onkeydown="mask(this, dateType);"/>
						</div>
						<div id="valor" class="textBox" style="width: 110px;">
							<label>Valor Nominal</label><br/>
							<input id="valorIn" name="valorIn" type="text" style="width: 110px;" value="<%=(isEdition)? Util.formatCurrency(lancamento.getValor()) : "0.00" %>" onkeydown="mask(this, decimalNumber);"/>
						</div>
						<div id="valorPago" class="textBox" style="width: 110px;">
							<label>Valor Efetivo</label><br/>
							<input id="valorPagoIn" name="valorPagoIn" type="text" style="width: 110px;" value="<%= (isEdition)? Util.formatCurrency(lancamento.getValorPago()) : "0.00" %>" onkeydown="mask(this, decimalNumber);"/>
						</div>
						<div id="tipo" class="textBox">
							<label>Tipo</label><br/>
							<select type="select-multiple" id="tipoIn" name="tipoIn" class="required" onblur="genericValid(this);">
								<option value="" >Selecione</option>
								<option value="c" <% if(isEdition && lancamento.getTipo().trim().equals("c")) { out.print("selected=\"selected\""); }%>>Crédito</option>
								<option value="d" <% if(isEdition && lancamento.getTipo().trim().equals("d")) { out.print("selected=\"selected\""); }%>>Débito</option>
							</select>
						</div>						
					</div>
				</div>
				<div id="mainContent">
					<div class="topButtonContent" >
						<%if (session.getAttribute("caixaOpen").toString().trim().equals("t")) {%>
							<div class="formGreenButton">
								<input class="greenButtonStyle" style="margin-top: 70px;" type="button" value="Salvar" onclick="saveLanc()" />
							</div>
						<%} else { %>
							<div class="formGreenButton">
								<input class="greenButtonStyle" style="margin-top: 70px;" type="button" value="Salvar" onclick="noAccess()" />
							</div>
						<%}%>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>	
	</div>
</body>
</html>