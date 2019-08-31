<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Empresa"%>
<%@page import="com.marcsoftware.database.Endereco"%>
<%@page import="com.marcsoftware.database.Informacao"%>

<%@page import="com.marcsoftware.database.Ramo"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%! boolean isEdition= false; %>
	<% isEdition = false;
	isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}%>
	
	<jsp:useBean id="unidade" class="com.marcsoftware.database.Unidade"></jsp:useBean>	
	<jsp:useBean id="enderecoGeral" class="com.marcsoftware.database.Endereco"></jsp:useBean>
	<jsp:useBean id="empresa" class="com.marcsoftware.database.Empresa"></jsp:useBean>
			
	<%Session sess = (Session) session.getAttribute("hb");
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
	query= sess.createQuery("from Ramo");
	List<Ramo> ramoList = (List<Ramo>) query.list();
	query = sess.createQuery("select distinct c.uf from Cep2005 as c");
	List<String> uf2005 = (List<String>) query.list();
	if (isEdition) {
		query= sess.createQuery("from Empresa as e where e.codigo = :codigo");
		query.setLong("codigo", Long.valueOf(request.getParameter("id")));
		empresa = (Empresa) query.uniqueResult();
		query= sess.getNamedQuery("enderecoOf").setEntity("pessoa", empresa);
		enderecoGeral= (Endereco) query.uniqueResult();
		query= sess.getNamedQuery("informacaoOf").setEntity("pessoa", empresa);
		List<Informacao> info= (List<Informacao>) query.list();
	}
	%>
<head>	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->		

	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/validation.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/lib/pilot_grid.js" ></script>
	<script type="text/javascript" src="../js/comum/cadastro_cliente_juridico.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_window.js"></script>

<title>Master Cadastro de Clientes Jurídicos</title>
</head>
<body onload="loadPage(<%= isEdition %>)" >
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="clienteJ"/>
	</jsp:include>
	<div id="centerAll" >
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="clienteJ"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formPost" method="post" action="../CadastroClienteJuridico" >
				<div id="localEdContact" ><%
					if (isEdition) {
						query= sess.getNamedQuery("informacaoOf").setEntity("pessoa", empresa);
						List<Informacao> info= (List<Informacao>) query.list();
						for(int i=0; i < info.size() ; i++){
							out.print("<input id=\"edType" + String.valueOf(i) + "\" name=\"edType" +
									String.valueOf(i) + "\" type=\"hidden\" value=\"" + 
									info.get(i).getTipo() + "\" />");
							
							out.print("<input id=\"edDescription" + String.valueOf(i) +
									"\" name=\"edDescription" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +
									info.get(i).getDescricao()+ "\" />");
							
							out.print("<input id=\"edPrincipal" + String.valueOf(i) +
									"\" name=\"edPrincipal" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +									
									((info.get(i).getPrincipal().trim().equals("s"))? "Sim" : "Não") + "\" />");
							
							out.print("<input id=\"contactId" + String.valueOf(i) + "\" name=\"contactId" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" + 
									info.get(i).getCodigo()+ "\" />");
						}
					}
				%>
				</div>
				<div id="localContact"></div>
				<div id="editeds"></div>
				<div>
					<input id="codEmpresa" name="codEmpresa" type="hidden" value="<%=(isEdition)? empresa.getCodigo(): "" %>" />
					<input id="codAddress" name="codAddress" type="hidden" value="<%=(isEdition)? enderecoGeral.getCodigo(): "" %>" />
					<input id="edContact" name="edContact" type="hidden" value="n"/>
				</div>				
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Cliente"/>			
					</jsp:include>
					<%if (isEdition) {%>
						<div id="abaMenu">
							<div class="sectedAba2">
								<label>Cadastro</label>
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
								<a href="fatura_empresa.jsp?state=1&id=<%=empresa.getCodigo() %>">Histórico de Faturas</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="bordero_empresa.jsp?&id=<%=empresa.getCodigo() %>">Borderô</a>
							</div>						
						</div>
					<%} else {%>
						<div id="abaMenu">
							<div class="aba2">
								<a href="empresa.jsp">Cliente Jurídico</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="sectedAba2">
								<label>Novo Cadastro</label>
							</div>
						</div>
					<%}%>
					<div class="topContent">
						<div class="textBox" style="width: 80px">
							<label>Código Unid.</label><br/>
							<select id="unidadeId" name="unidadeId">
								<%if (isEdition) { %>
									<option value="">Selecione</option>							
									<option value="<%=Util.initCap(empresa.getUnidade().getDescricao()) + "@" + 
									empresa.getUnidade().getCodigo()%>" selected="selected" ><%=empresa.getUnidade().getReferencia()%></option><%
								} else {%>
									<option value="">Selecione</option><%
								}%>
								<%for(Unidade un: unidadeList) {
									if (isEdition) {
										if (!empresa.getUnidade().equals(un)) {									
											out.print("<option value=\"" + Util.initCap(un.getDescricao()) + "@" +
												un.getCodigo() + "\">" + un.getReferencia() + "</option>");									
										}										
									} else {
										out.print("<option value=\"" + Util.initCap(un.getDescricao()) + "@" +
												un.getCodigo() + "\">" + un.getReferencia() + "</option>");
									}
								}
								%>
							</select>
						</div>
						<div id="unidade" class="textBox" style="width: 350px;">
							<label>Unidade</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" style="width: 350px;" value="<%=(isEdition)? empresa.getUnidade().getDescricao(): "" %>" class="required" readonly="readonly"  onblur="genericValid(this);" />
						</div>
						<div id="cadastro" class="textBox" style="width: 73px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" class="required" type="text" <%if(isEdition
									&& (!request.getSession().getAttribute("perfil").equals("a"))
									&& (!request.getSession().getAttribute("perfil").equals("d"))) {%> "readonly="readonly" <%}%> style="width: 73px;" value="<%=(isEdition)? Util.parseDate(empresa.getCadastro(), "dd/MM/yyyy") : "" %>" <%if(!isEdition) {%> onkeydown="mask(this, dateType);" <%}%>/>
						</div>
						<div class="textBox">
							<label>Venc.</label><br/>
							<select id="vencimento" name="vencimento" onchange="setChange('u')">
								<%if (isEdition) {%>
									<option value="10" <% 
									if (empresa.getVencimento().trim().equals("10")) {%>
										selected="selected"
									<% } %>>Dia 10</option>
									<option value="15" <% 
									if (empresa.getVencimento().trim().equals("15")) {%>
										selected="selected"
									<% } %>>Dia 15</option>
									<option value="20" <% 
									if (empresa.getVencimento().trim().equals("20")) {%>
										selected="selected"
									<% } %>>Dia 20</option>
									<option value="25" <% 
									if (empresa.getVencimento().trim().equals("25")) {%>
										selected="selected"
									<% } %>>Dia 25</option>									
								<%} else {%>
									<option value="10">Dia 10</option>
									<option value="15">Dia 15</option>
									<option value="20">Dia 20</option>
									<option value="25">Dia 25</option>																		
								<%}%>
							</select>
						</div>
						<div id="status" class="textBox" style="width: 280px">
							<label >Status</label><br />
							<div class="checkRadio">
								<label class="labelCheck" >Ativo</label><%
								if (isEdition) {%>
									<input id="ativoChecked" name="ativoChecked" onchange="setChange('u')" type="radio"  <%if (empresa.getAtivo().equals("a")){ out.print(" checked=\"checked\""); }%> value="a" />								
								<label class="labelCheck" >Bloqueado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" onchange="setChange('u')" <%if (empresa.getAtivo().equals("b")) { out.print("checked=\"checked\""); }%> value="b" />
								<label class="labelCheck" >Cancelado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" onchange="setChange('u')" <%if (empresa.getAtivo().equals("c")) { out.print("checked=\"checked\""); }%> value="c" />
								<%} else {%>
								<input id="ativoChecked" name="ativoChecked" onchange="setChange('u')" type="radio" checked="checked" value="a" />
									<label class="labelCheck" >Bloqueado</label>
								<input id="ativoChecked" name="ativoChecked" type="radio" onchange="setChange('u')"  value="b" />
									<label class="labelCheck" >Cancelado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" onchange="setChange('u')" value="c" />
								<%}%>
							</div>
						</div>
					</div>
				</div>
				<div id="mainContent">				
					<div id="contrato" class="bigBox">
						<div class="indexTitle">
							<h4>Dados Contratuais</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<%if (isEdition) {%>
							<div id="codigo" class="textBox" style="width: 80px;">
								<label>Referência</label><br/>
								<input id="codigoIn" name="codigoIn" type="text" style="width: 80px;" value="<%=(isEdition)? empresa.getCodigo(): "" %>" onchange="setChange('u')" readonly="readonly" class="required" onblur="genericValid(this);" />
							</div>
						<%}%>
						<div id="razaoSocial" class="textBox" style="width: 292px;">
							<label>Razão Social</label><br/>						
							<input id="razaoSocialIn" name="razaoSocialIn" type="text" style="width: 292px;" value="<%=(isEdition)? Util.initCap(empresa.getRazaoSocial()): "" %>" onchange="setChange('u')" class="required" onblur="genericValid(this);" />						
						</div>
						<div id="fantasia" class="textBox" style="width: 292px">
							<label>Fantasia</label><br/>					
							<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 292px" value="<%=(isEdition)? Util.initCap(empresa.getFantasia()): "" %>" onchange="setChange('u')" class="required" onblur="genericValid(this);" />
						</div>
						<div id="cnpj" class="textBox" style="width: 130px">
							<label>Cnpj</label><br/>					
							<input id="cnpjIn" name="cnpjIn" type="text" style="width: 130px" class="required" value="<%=(isEdition)? Util.mountCnpj(empresa.getCnpj()): "" %>" onchange="setChange('u')" onkeydown="mask(this, cnpj);" onblur="cnpjValidation(this)" />
						</div>
						<div id="ramo" class="textBox" style="width: 285px">
							<label>Ramo</label><br/>
							<select id="ramoIn" name="ramoIn">
								<option value="">Selecione</option>
								<%for(Ramo rm: ramoList) {
									if (isEdition) {
										if (empresa.getRamo().equals(rm)) {
											out.print("<option value=\"" + rm.getCodigo() + 
													"\" selected=\"selected\" >" + 
													Util.initCap(rm.getDescricao()) + "</option>");
										}
										out.print("<option value=\"" + rm.getCodigo() + "\">" + 
												Util.initCap(rm.getDescricao()) + "</option>");
									} else {
										out.print("<option value=\"" + rm.getCodigo() + "\">" + 
													Util.initCap(rm.getDescricao()) + "</option>");										
									}
								}%>
							</select>
						</div>
						<div id="nomeContato" class="textBox" style="width: 245px;">
							<label>Nome do Contato</label><br/>					
							<input id="nomeContatoIn" name="nomeContatoIn" type="text" style="width: 245px" value="<%=(isEdition)? Util.initCap(empresa.getContato()) : "" %>" onchange="setChange('u')" onblur="genericValid(this);" />
						</div>
						<div id="cargoContato" class="textBox" style="width: 280px">
							<label>Cargo do Contato</label><br/>					
							<input id="cargoContatoIn" name="cargoContatoIn" type="text" style="width: 280px" value="<%=(isEdition)? empresa.getCargoContato(): "" %>" onchange="setChange('u')" class="required" onblur="genericValid(this);" />
						</div>					
					</div>
					<div id="endereco" class="bigBox">
						<div class="indexTitle">
							<h4>Endereços</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div id="cep" class="textBox" style="width: 73px">
							<label>CEP</label><br/>
							<input id="cepIn" name="cepIn" type="text" style="width: 73px" value="<%=(isEdition)? Util.mountCep(enderecoGeral.getCep()): "" %>" onkeydown="mask(this, cep);" />
						</div>
						<div id="rua" class="textBox" style="width: 230px">
							<label>Rua/Av</label><br/>
							<input id="ruaIn" name="ruaIn" type="text" style="width: 230px" class="required" value="<%=(isEdition)? Util.initCap(enderecoGeral.getRuaAv()): "" %>" onchange="setChange('e')" onblur="genericValid(this)" />
						</div>
						<div id="numero" class="textBox" style="width: 50px">
							<label>Numero</label><br/>
							<input id="numeroIn" name="numeroIn" type="text" style="width: 50px" value="<%=(isEdition)? enderecoGeral.getNumero(): "" %>" onchange="setChange('e')" />
						</div>
						<div id="complemento" class="textBox" style="width: 250px">
							<label>Complemento</label><br/>
							<input id="complementoIn" name="complementoIn" type="text" style="width: 250px" value="<%=(isEdition)? enderecoGeral.getComplemento(): "" %>" onchange="setChange('e')" />
						</div>
						<div id="bairro" class="textBox" style="width: 225px">
							<label>Bairro</label><br/>
							<input id="bairroIn" name="bairroIn" type="text" style="width: 225px" value="<%=(isEdition)? Util.initCap(enderecoGeral.getBairro()) : "" %>" onchange="setChange('e')" />
						</div>
						<div id="cidade" class="textBox" style="width: 220px">
							<label>Cidade</label><br/>
							<input id="cidadeIn" name="cidadeIn" type="text" style="width: 220px" class="required" value="<%=(isEdition)? Util.initCap(enderecoGeral.getCidade()) : "" %>" onchange="setChange('e')" onblur="genericValid(this)" />
						</div>
						<div id="uf" class="textBox">
							<label>Uf</label><br/>
							<select type="select-multiple" id="ufIn" name="ufIn" onchange="setChange('e')" >
								<%for(String uf: uf2005) {
									if (isEdition && enderecoGeral.getUf().trim().equals(uf.toLowerCase())) {
										out.print("<option value=\"" + uf.toLowerCase() + 
												"\" selected=\"selected\">" + uf + "</option>");
									} else {
										out.print("<option value=\"" + uf.toLowerCase() + 
												"\">" + uf + "</option>");
									}
								}								
								%>
							</select>
						</div>
					</div>
					<div id="contato" class="bigBox">
						<div class="indexTitle">
							<h4>Informações de Contato</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<input id="edInfo" name="edInfo" type="hidden"/>						
						<div class="textBox" style="width: 135px">
							<label>Tipo</label><br/>
							<select id="tipoContato" name="tipoContato" onchange="setChange('i'); clearNext('descricaoIn')" >
								<option value="Selecione">Selecione</option>
								<option value="fone residencial">Fone Residencial</option>
								<option value="fone comercial">Fone Comercial</option>
								<option value="fone recado" >Fone Recado</option>
								<option value="fax">Fax</option>
								<option value="celular">Celular</option>
								<option value="email">email</option>
								<option value="msn">msn</option>
								<option value="skype">Skype</option>
								<option value="g talk">G Talk</option>
								<option value="icq">ICQ</option>
								<option value="site">Pagina Web</option>
								<option value="outro">Outro</option>
							</select>
						</div>
						<div id="descricao" class="textBox" style="width:300px;">
							<label>Descrição</label><br/>
							<input id="descricaoIn" name="descricao" type="text" style="width:300px;" onkeydown="comboMask(this, 'tipoContato')"  onchange="setChange('i')" />
						</div>
						<div class="textBox" id="principal">
							<label>Principal</label><br/>
							<select id="principalIn" name="principalIn">								
								<option value="Sim">Sim</option>
								<option value="Não" selected="selected">Não</option>
							</select>
						</div>
						<div id="tableContact" style="margin-right: 68px"></div>
					</div>
					<div class="buttonContent" >
						<div class="formGreenButton">
							<input name="removeContauct" class="greenButtonStyle" type="button" value="Excluir" onclick="removeRowContact()" />							
						</div>					
						<div class="formGreenButton" >
							<input id="specialButton" name="insertContact" class="greenButtonStyle" type="button" value="Inserir" onclick="addRowContact()" />
						</div>
					</div>					
					<div id="endPage" class="bigBox" >
						<div class="indexTitle">
							<h4>&nbsp;</h4>
						</div>
					</div>
					<div class="buttonContent" >
						<div class="formGreenButton">
							<input class="greenButtonStyle" style="margin-top: 10px;" type="submit" value="Salvar" />
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