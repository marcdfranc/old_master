<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Banco"%>
<%@page import="com.marcsoftware.database.Cc"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%!boolean isEdition= false;%>
	<%isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}%>
	
	<jsp:useBean id="cc" class="com.marcsoftware.database.Cc"></jsp:useBean>
	
	<%
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query= sess.createQuery("from Banco as b order by b.codigo");
	List<Banco> banco= (List<Banco>) query.list();	
	ArrayList<Unidade> unidades = (ArrayList<Unidade>) session.getAttribute("unidades");
	String inUnidade = "";
	for (Unidade und: unidades) {
		inUnidade+= (inUnidade == "")? und.getCodigo() : ", " + und.getCodigo();
	}
	if(isEdition) {
		query= sess.createQuery("from Cc as c where c.codigo = :codigo");
		query.setLong("codigo", Long.valueOf(request.getParameter("id")));
		cc= (Cc) query.uniqueResult();
	} else {
		query = sess.createQuery("select c.unidade from Cc as c where c.unidade.codigo in("+ inUnidade +")");
		unidades = (ArrayList<Unidade>) query.list();
		inUnidade = "";
		if (unidades.size() > 0) {
			for (Unidade und: unidades) {
				inUnidade+= (inUnidade == "")? und.getCodigo() : ", " + und.getCodigo();
			}
			query = sess.createQuery("from Unidade as u where u.administrador.login.username = :username and u.codigo not in("+ inUnidade +")");			
		} else {
			query = sess.createQuery("from Unidade as u where u.administrador.login.username = :username");
		}
		query.setString("username", (String) session.getAttribute("username"));
		unidades = (ArrayList<Unidade>) query.list();
	}	
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/validation.js" ></script>
	
	<title>Master - Cadastro Conta Corrente</title>
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
			<form id="formPost" method="post" action="../CadastroCc" onsubmit= "return validForm(this)">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Conta Corrente"/>
					</jsp:include>
					<div class="topContent">
						<%if (isEdition) {%>
							<div id="codigo" class="textBox" style="width: 80px;">
								<label>Código</label><br/>
								<input id="codigoIn" name="codigoIn" type="text" style="width: 80px;" readonly="readonly"  value="<%= cc.getCodigo() %>"/>
							</div>
						<%}%>
						<div class="textBox" style="width: 170px">
							<label>Unidade</label><br/>
							<select id="unidade" name="unidade" style="width: 170px" >
								<%if (isEdition) {%>
									<option value="<%= cc.getUnidade().getCodigo()%>" ><%= cc.getUnidade().getReferencia() + " - " + cc.getUnidade().getDescricao() %></option>
								<%} else {%>
									<option value="">Selecione</option>
									<%for(Unidade unid : unidades) {%>
										<option value="<%= unid.getCodigo()%>" ><%= unid.getReferencia() + " - " + unid.getDescricao() %></option>
									<%}
								}%>
							</select>
						</div>
						<div class="textBox" style="width: 170px">
							<label>Banco</label><br/>
							<select id="banco" name="banco" style="width: 170px;">
								<option value="" >Selecione</option>
								<%for(Banco bc: banco){
									if (isEdition && bc.equals(cc.getBanco())) {
										out.println("<option value=\"" + String.valueOf(bc.getCodigo()) + "\" selected=\"selected\" >" +
											Util.initCap(bc.getDescricao()) + "</option>");
									} else {
										out.println("<option value=\"" + String.valueOf(bc.getCodigo()) + "\" >" +
											Util.initCap(bc.getDescricao()) + "</option>");
									}
								}%>								
							</select>	
						</div>
						<div id="agencia" class="textBox" style="width: 80px;">
							<label>Agência</label><br/>
							<input id="agenciaIn" name="agenciaIn" type="text" style="width: 80px;" value="<%=(isEdition)? cc.getAgencia() : "" %>" class="required" onblur="genericValid(this);"/>
						</div>
						<div id="numero" class="textBox" style="width: 80px;">
							<label>Numero</label><br/>
							<input id="numeroIn" name="numeroIn" type="text" style="width: 80px;" value="<%=(isEdition)? cc.getNumero() : "" %>" class="required" onblur="genericValid(this);"  onkeydown="mask(this, onlyNumber);"/>
						</div>
						<div id="valor" class="textBox" style="width: 80px;">
							<label>Valor Inicial</label><br/>
							<input id="valorIn" name="valorIn" type="text" style="width: 80px;" value="<%=(isEdition)? Util.formatCurrency(cc.getValor()) : "0.00" %>" class="required" onblur="genericValid(this);"  onkeydown="mask(this, decimalNumber);"/>
						</div>
						<div id="cadastro" class="textBox" style="width: 80px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" type="text" style="width: 80px;" value="<%=(isEdition)? Util.parseDate(cc.getCadastro(), "dd/MM/yyyy") : "" %>" class="required" onblur="genericValid(this);"  onkeydown="mask(this, dateType);"/>
						</div>
					</div>
				</div>
				<div id="mainContent">
					<div class="topButtonContent" >
						<div class="formGreenButton">
							<input class="greenButtonStyle" style="margin-top: 70px;" type="submit" value="Salvar" />
						</div>
					</div>
				</div>				
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>	
	</div>
</body>
</html>