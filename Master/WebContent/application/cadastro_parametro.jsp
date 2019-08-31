<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>

<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Parametro"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Relatorio"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%!boolean isEdition= false;%>
	<%isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}%>
	
	<jsp:useBean id="parametro" class="com.marcsoftware.database.Parametro"></jsp:useBean>
	
	<%
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}	
	Query query = sess.createQuery("from Relatorio as r order by r.codigo");
	List<Relatorio> relatorio = (List<Relatorio>) query.list();	
	if (isEdition) {
		query= sess.createQuery("from Parametro as p where p.codigo = :codigo");
		query.setLong("codigo", Long.valueOf(request.getParameter("id")));
		parametro = (Parametro) query.uniqueResult();
	}	
	%>
	
<head>
	<link rel="shortcut icon" href="../icone.ico">	
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/comum/cadastro_Parametro.js" ></script>
<title>Master Cadastro Parametro</title>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="rel"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="rel"/>
		</jsp:include>
		<div id="formStyle">		
			<form id="formPost" method="post" action="../CadastroParametro" onsubmit= "return validForm(this)">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Relatórios"/>			
					</jsp:include>
					<div>
						<input id="codParam" name="codParam" type="hidden" value="<%=(isEdition)? parametro.getCodigo() : "" %>"/>
						<input id="codRel" name="codRel" type="hidden" value="<%=(isEdition)? parametro.getRelatorio().getCodigo() : request.getParameter("codRel") %>"/>
					</div>
					<div class="topContent">					
						<%if (isEdition) {%>
							<div id="codigo" class="textBox" style="width: 65px;" >
								<label>Código</label><br/>
								<input id="codigoIn" name="codigoIn" type="text" style="width: 65px;" value="<%= parametro.getCodigo() %>" enable="false" readonly="readonly"/>
							</div>
						<%}%>
						<div id="descricao" class="textBox" style="width: 280px;" >
							<label>Descrição</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 280px;" value="<%=(isEdition)? parametro.getDescricao() : "" %>" class="required" onblur="genericValid(this);"/>
						</div>
						<div class="textBox">
							<label>Componente</label><br/>
							<select id="componenteIn" name="componenteIn">																
								<option>Selecione</option>
								<option value="t" <% if (isEdition && parametro.getComponente() != null && parametro.getComponente().trim().equals("t")) {%> selected="selected" <%}%>>Prompt</option>
								<option value="r" <% if (isEdition && parametro.getComponente() != null && parametro.getComponente().trim().equals("r")) {%> selected="selected" <%}%>>Radio Button</option>
								<option value="i" <% if (isEdition && parametro.getComponente() != null && parametro.getComponente().trim().equals("i")) {%> selected="selected" <%}%>>Item Selector</option>
								<option value="c" <% if (isEdition && parametro.getComponente() != null && parametro.getComponente().trim().equals("c")) {%> selected="selected" <%}%>>Combo Box</option>
								<option value="k" <% if (isEdition && parametro.getComponente() != null && parametro.getComponente().trim().equals("k")) {%> selected="selected" <%}%>>Check Box</option>
								<option value="d" <% if (isEdition && parametro.getComponente() != null && parametro.getComponente().trim().equals("d")) {%> selected="selected" <%}%>>Duplo Prompt</option>
							</select>
						</div>
						<div class="textBox">
							<label>Máscara</label><br/>
							<select id="maskIn" name="maskIn">																
								<option value="">Selecione</option>
								<option value="onlyNumber" <% if (isEdition && parametro.getMascara() != null && parametro.getMascara().equals("onlyNumber")) {%> selected="selected" <%}%>>onlyNumber</option>
								<option value="onlyInteger" <% if (isEdition && parametro.getMascara() != null && parametro.getMascara().equals("onlyInteger")) {%> selected="selected" <%}%>>onlyInteger</option>
								<option value="decimalNumber" <% if (isEdition && parametro.getMascara() != null && parametro.getMascara().equals("decimalNumber")) {%> selected="selected" <%}%>>decimalNumber</option>
								<option value="formatDecimal" <% if (isEdition && parametro.getMascara() != null && parametro.getMascara().equals("formatDecimal")) {%> selected="selected" <%}%>>formatDecimal</option>
								<option value="removeMltiplePoints" <% if (isEdition && parametro.getMascara() != null && parametro.getMascara().equals("removeMltiplePoints")) {%> selected="selected" <%}%>>removeMltiplePoints</option>
								<option value="cpf" <% if (isEdition && parametro.getMascara() != null && parametro.getMascara().equals("cpf")) {%> selected="selected" <%}%>>cpf</option>
								<option value="cep" <% if (isEdition && parametro.getMascara() != null && parametro.getMascara().equals("cep")) {%> selected="selected" <%}%>>cep</option>
								<option value="comboMask" <% if (isEdition && parametro.getMascara() != null && parametro.getMascara().equals("comboMask")) {%> selected="selected" <%}%>>comboMask</option>
								<option value="cnpj" <% if (isEdition && parametro.getMascara() != null && parametro.getMascara().equals("cnpj")) {%> selected="selected" <%}%>>cnpj</option>
								<option value="dateType" <% if (isEdition && parametro.getMascara() != null && parametro.getMascara().equals("dateType")) {%> selected="selected" <%}%>>dateType</option>
								<option value="typeDate" <% if (isEdition && parametro.getMascara() != null && parametro.getMascara().equals("typeDate")) {%> selected="selected" <%}%>>typeDate</option>
								<option value="typeDate" <% if (isEdition && parametro.getMascara() != null && parametro.getMascara().equals("tipoHora")) {%> selected="selected" <%}%>>tipoHora</option>
								<option value="fone" <% if (isEdition && parametro.getMascara() != null && parametro.getMascara().equals("fone")) {%> selected="selected" <%}%>>fone</option>
								<option value="site" <% if (isEdition && parametro.getMascara() != null && parametro.getMascara().equals("site")) {%> selected="selected" <%}%>>site</option>
							</select>
						</div>
						<div class="textBox">
							<label>Tipo</label><br/>
							<select id="tipoIn" name="tipoIn">																
								<option value="">Selecione</option>								
								<option value="i" <%if(isEdition && parametro.getTipo().trim().equals("i")) { out.print("selected=\"selected\""); } %>>Integer</option>
								<option value="l" <%if(isEdition && parametro.getTipo().trim().equals("l")) { out.print("selected=\"selected\""); } %>>Long</option>
								<option value="s" <%if(isEdition && parametro.getTipo().trim().equals("s")) { out.print("selected=\"selected\""); } %>>String</option>
								<option value="f" <%if(isEdition && parametro.getTipo().trim().equals("f")) { out.print("selected=\"selected\""); } %>>Decimal</option>
								<option value="d" <%if(isEdition && parametro.getTipo().trim().equals("d")) { out.print("selected=\"selected\""); } %>>Date</option>
								<option value="cn" <%if(isEdition && parametro.getTipo().trim().equals("cn")) { out.print("selected=\"selected\""); } %>>Conexão</option>
							</select>
						</div>					
						<div class="textBox">
							<label>Requerido</label><br/>
							<select id="requeridoIn" name="requeridoIn">																
								<option>Selecione</option>
								<option value="t" <% if (isEdition && parametro.getRequerido().trim().equals("t")) {%> selected="selected" <%}%>>Sim</option>
								<option value="f" <% if (isEdition && parametro.getRequerido().trim().equals("f")) {%> selected="selected" <%}%>>Não</option>
							</select>
						</div>
						<div id="rotulo" class="textBox" style="width: 150px;" >
							<label>Rótulo</label><br/>
							<input id="rotuloIn" name="rotuloIn" type="text" style="width: 150px;" value="<%=(isEdition && parametro.getRotulo() != null)? parametro.getRotulo(): "" %>"/>
						</div>
						<div id="maskCombo" class="textBox" style="width: 150px;" >
							<label>Combo Config</label><br/>
							<input id="maskComboIn" name="maskComboIn" type="text" style="width: 150px;" value="<%=(isEdition && parametro.getComponente().trim().equals("c") && parametro.getRotulo() != null)? parametro.getRotulo(): "" %>"/>
						</div>
						<div class="textBox">
							<label>Operador</label><br/>
							<select id="operadorIn" name="operadorIn">																
								<option value="=" <%if(isEdition && parametro.getOperador().trim().equals("=")) { out.print("selected=\"selected\""); } %>>Igual</option>
								<option value="ls" <%if(isEdition && parametro.getOperador().trim().equals("ls")) { out.print("selected=\"selected\""); } %>>Inicia com...</option>
								<option value="le" <%if(isEdition && parametro.getOperador().trim().equals("le")) { out.print("selected=\"selected\""); } %>>Termina com...</option>
								<option value="la" <%if(isEdition && parametro.getOperador().trim().equals("la")) { out.print("selected=\"selected\""); } %>>Contém</option>
								<option value="<%="<"%>" <%if(isEdition && parametro.getOperador().trim().equals("<")) { out.print("selected=\"selected\""); } %>>menor</option>
								<option value="<%=">"%>" <%if(isEdition && parametro.getOperador().trim().equals(">")) { out.print("selected=\"selected\""); } %>>Maior</option>
								<option value="<%="<>"%>" <%if(isEdition && parametro.getOperador().trim().equals("<>")) { out.print("selected=\"selected\""); } %>>Diferente</option>
								<option value="in" <%if(isEdition && parametro.getOperador().trim().equals("in")) { out.print("selected=\"selected\""); } %>>In</option>
								<option value="b" <%if(isEdition && parametro.getOperador().trim().equals("b")) { out.print("selected=\"selected\""); } %>>Entre</option>
								<option value="cn" <%if(isEdition && parametro.getOperador().trim().equals("cn")) { out.print("selected=\"selected\""); } %>>Conexão</option>
							</select>
						</div>
						<div id="campo" class="textBox" style="width: 400px;" >
							<label>Campo</label><br/>
							<input id="campoIn" name="campoIn" type="text" style="width: 400px;" value="<%=(isEdition && parametro.getCampo() != null)? parametro.getCampo(): "" %>"/>
						</div>
						<div class="textBox">
							<label>Checa Und.</label><br/>
							<select id="chkUnidadeIn" name="chkUnidadeIn">																
								<option>Selecione</option>
								<%if (isEdition) {%>
									<option value="s" <% if (parametro.getRefUnidade().equals("s")) {%> selected="selected" <%}%>>Sim</option>
									<option value="n" <% if (parametro.getRequerido().trim().equals("f")) {%> selected="selected" <%}%>>Não</option>
								<% } else { %>								
									<option value="s">Sim</option>
									<option value="n" selected="selected">Não</option>
								<%} %>
							</select>
						</div>
						<div class="textBox" style="width: 60px">
							<label>Seq.</label><br />
							<input type="text" style="width: 60px" onkeydown="mask(this, onlyInteger)" id="seq" name="seq" value="<%= (isEdition)? parametro.getSequencial() : "" %>"/>
						</div>
					</div>					
				</div>
				<div id="mainContent">
					<div id="helpBox" class="bigBox" >
						<div class="indexTitle">
							<h4>Ajuda de Configuração</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div id="helper" class="textBox" style="width: 900px; height:300px;" >
							<div id="help" class="help">
								<ul>
									<li><p><strong>Prompt: </strong>posição x do prompt@posição y do prompt@width do prompt</p></li>
									<li><p><strong>Radio Button: </strong>texto da label@posição x da label@posição y da label@posição x da radio@posição y da radio@valor da radio<strong>|</strong>label@label Px@label Py@radio px@radio py@valor 1..n</p></li>									
									<li><p><strong>Check Box: </strong>True Value @ False Value</p></li>
									<li><p><strong>Duplo Prompt: </strong>posição x do 1° prompt@ posição y do 1° prompt@ width do 1° prompt@ rotulo do 2° prompt@ posição x da label do 2° prompt@ posição y da label do 2° prompt@ posição x do 2° prompt@ posição y do 2° prompt@ width do 2° prompt</p></li>
								</ul>														
							</div>							
							<div id="help" class="help" >							
								<p><strong>Item Selector: </strong>seleção dos dados da direita</p>
								<ul class="subhelp">
									<li><p><strong>configuração de mascara: </strong>width@height</p></li>
								</ul>
							</div>
							<div id="help" class="help" style="border-bottom: 3px #990066 solid;">							
								<p><strong>Combo Box: </strong>seleção dos dados ou valor do ítem@ rótulo do ítem<strong>|</strong>valor@rótulo 1..n</p>
								<ul>
									<li><p><strong>configuração de mascara: </strong>posição x da combo@posição y da combo@width da combo</p></li>
								</ul>
							</div>													
						</div>
					</div>
					<div id="caixasTexto" class="bigBox">
						<div class="area" id="dados" name="dados" style="margin-bottom: 30px">
							<label style="margin-top: 240px">Dados</label><br/>
							<textarea cols="112"  rows="5" id="dadosIn" name="dadosIn" id="obsIn"><%=(isEdition && parametro.getDados() != null)? parametro.getDados() : ""%></textarea>
						</div>
					</div>					
					<div id="endPage" class="bigBox" >
						<div class="indexTitle">
							<h4>&nbsp;</h4>
						</div>
					</div>
					<div class="buttonContent" >
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="submit" value="Salvar" />
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