<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="java.util.ArrayList"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.database.Endereco"%>
<%@page import="com.marcsoftware.database.Fisica"%>
<%@page import="com.marcsoftware.database.Conta"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Informacao"%>

	<%! boolean isEdition= false; %>
	<% isEdition = false;
	isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}%>
	<jsp:useBean id="unidade" class="com.marcsoftware.database.Unidade"></jsp:useBean>	
	<jsp:useBean id="enderecoGeral" class="com.marcsoftware.database.Endereco"></jsp:useBean>
	<jsp:useBean id="enderecoResponsavel" class="com.marcsoftware.database.Endereco"></jsp:useBean>			
	<jsp:useBean id="conta" class="com.marcsoftware.database.Conta"></jsp:useBean>	
	<jsp:useBean id="login" class="com.marcsoftware.database.Login"></jsp:useBean>
	<% boolean haveHold = false;
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query= sess.createQuery("from Banco as b order by b.codigo");
	List<Banco> banco= (List<Banco>) query.list();
	query = sess.getNamedQuery("administrador");
	List<Fisica> administrador= (List<Fisica>) query.list();
	query = sess.createQuery("select distinct c.uf from Cep2005 as c");
	List<String> uf2005 = (List<String>) query.list();
	query = sess.createQuery("from Unidade as u where u.tipo = 'h'");
	haveHold = query.list().size() > 0;
	query = sess.createQuery("from TabelaFranchising as t");
	List<TabelaFranchising> tabelaFranchisings = (List<TabelaFranchising>) query.list();
	boolean isAdm = session.getAttribute("perfil").equals("a");
	Login administradorLogin = null;
	if (isEdition) {
		query= sess.createQuery("from Unidade as u where u.codigo= :codigo");
		query.setLong("codigo", Long.valueOf(request.getParameter("id")));
		unidade= (Unidade) query.uniqueResult();
		administradorLogin = unidade.getAdministrador().getLogin();
		if (unidade.getAdministrador() != null) {
			query= sess.getNamedQuery("enderecoOf").setEntity("pessoa", unidade);		
			enderecoGeral= (Endereco) query.uniqueResult();
			query.setEntity("pessoa", unidade.getAdministrador());
			enderecoResponsavel= (Endereco) query.uniqueResult();			
		}
	}%>
<%@page import="com.marcsoftware.database.Banco"%>
<%@page import="com.marcsoftware.database.Login"%>

<%@page import="com.marcsoftware.database.TabelaFranchising"%><html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />	
	
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link type="text/css" href="../js/jquery/uploaddif/uploadify.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/uploaddif/swfobject.js"></script>
	<script type="text/javascript" src="../js/jquery/uploaddif/jquery.uploadify.v2.1.4.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/validation.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/comum/cadastro_unidade.js"></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/lib/pilot_grid.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>	
	
	<title>Master Cadastro de Unidade</title>
</head>
<body onload="loadPage(<%= isEdition %>)">
	<div id="uploadCtrSocial" class="removeBorda" title="Upload da Imagem do Contrato Social" style="display: none;">
		<form id="formUpload" onsubmit="return false;" action="../ContratoSocialUpload" method="post" enctype="multipart/form-data">
			<div class="uploadContent" id="contUpload">
				<div id="msgUpload" style="margin-bottom: 20px;">Clique abaixo para selecionar o arquivo pdf a ser enviado.</div>
				<div id="fileQueue" style="width: 200px;"></div>
				<input type="file" name="uploadify" id="uploadify" />
				<!-- <p><a href="javascript:jQuery('#uploadify').uploadifyClearQueue()">Cancelar Todos os Anexos</a></p> -->
			</div>
			<input type="hidden" value="" id="uploadName" name="uploadName" />
		</form>
	</div>
	<%@ include file="../inc/header.jsp"%>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="unidade"/>
	</jsp:include>
	<div id="centerAll" >
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="unidade"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formPost" name="formPost" method="post" action="../CadastroUnidade"  onsubmit= "return validForm(this)" >
				<div id="localEdBank" ><%
					if (isEdition) {
						query= sess.getNamedQuery("contaOfByCode");
						query.setLong("codigo", unidade.getCodigo());
						List<Conta> contaList= (List<Conta>) query.list();;
						for(int i=0; i < contaList.size(); i++){
							//out.println("<h1>passou: " + i + "</h1>");
							out.print("<input id=\"edBank" + String.valueOf(i) + "\" name=\"edBank" +
									String.valueOf(i) + "\" type=\"hidden\" value=\"" + 
									contaList.get(i).getBanco().getCodigo() + "@" +
									Util.initCap(contaList.get(i).getBanco().getDescricao()) + "\" />");

							out.print("<input id=\"edAgency" + String.valueOf(i) + "\" name=\"edAgency" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +
									contaList.get(i).getAgencia()+ "\" />");
							
							out.print("<input id=\"edCont" + String.valueOf(i) + "\" name=\"edCont" + String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + contaList.get(i).getNumero() + "\" />");
							
							out.print("<input id=\"edCarteira" + String.valueOf(i) + "\" name=\"edCarteira" + String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + ((contaList.get(i).getCarteira() == null)? ""
											: contaList.get(i).getCarteira()) + "\" />");
							
							out.print("<input id=\"edBoleto" + String.valueOf(i) + "\" name=\"edBoleto" + String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + contaList.get(i).getVlrBoleto() + "\" />");
							
							out.print("<input id=\"edOwner" + String.valueOf(i) + "\" name=\"edOwner" + String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + contaList.get(i).getTitular() + "\" />");
							
							out.print("<input id=\"acountId" + String.valueOf(i) + "\" name=\"acountId" + String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + contaList.get(i).getCodigo() + "\" />");							
						}
					}					
				%>			
				</div>				
				<div id="localEdContact" ><%
					if (isEdition) {
						query= sess.getNamedQuery("informacaoOf");
						query.setEntity("pessoa", unidade);
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
				<div id="localBank"></div>
				<div id="localContact"></div>
				<div id="deletedsBank"></div>
				<div id="deletedsContact"></div>
				<div id="editedsBank"></div>
				<div id="editedsContact"></div>
				<div>
					<input id="edBank" name="edBank" type="hidden" value="n"/>
					<input id="edContact" name="edContact" type="hidden" value="n"/>
				</div>
				<div id="geralDate" class="alignHeader" >
					<div>
						<input id="edUnit" name="edUnit" type="hidden" value="<%=(isEdition)? "on": "off" %>" />
						<input id="codUnit" name="codUnit" type="hidden" value="<%=(isEdition)? String.valueOf(unidade.getCodigo()) : "" %>" />
						<input id="codFisica" name="codFisica" type="hidden" value="<%=(isEdition && unidade.getAdministrador() != null)? String.valueOf(unidade.getAdministrador().getCodigo()) : "" %>" />
						<input id="loginOld" name="loginOld" type="hidden" value="<%=(isEdition && administradorLogin != null)? String.valueOf(administradorLogin.getUsername()) : "" %>" />
						<input id="isDel" name="isDel" type="hidden" value="0"/>
						<input id="haveDoc" name="haveDoc" type="hidden" value="<%=(isEdition)? unidade.getDocDigital() : "" %>" />
					</div>
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="unidade"/>			
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
								<a href="<%= "anexo_unidade.jsp?id=" + unidade.getCodigo() %>">Anexo</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="#">Requisição</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="#">Borderô</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="#">Histórico de Faturas</a>
							</div>
						</div>
					<%} else {%>
						<div id="abaMenu">
							<div class="aba2">
								<a href="unidade.jsp">Unidades</a>
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
						<div id="codigo" class="textBox" style="width: 70px;">
							<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 70px;" <%if(isEdition
									&& (!request.getSession().getAttribute("perfil").equals("a"))
									&& (!request.getSession().getAttribute("perfil").equals("d"))) {%> "readonly="readonly" <%}%> value="<%=(isEdition)? unidade.getReferencia(): "" %>" class="required" onblur="genericValid(this);" />
						</div>
						<div id="razaoSocial" class="textBox" style="width: 258px;">
							<label>Razão Social</label><br/>						
							<input id="razaoSocialIn" name="razaoSocialIn" type="text" style="width: 258px;" value="<%=(isEdition)? Util.initCap(unidade.getRazaoSocial()): "" %>" class="required" onblur="genericValid(this);" />
						</div>
						<div id="fantasia" class="textBox" style="width: 258px;">
							<label>Fantasia</label><br/>					
							<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 258px" value="<%=(isEdition)? unidade.getFantasia() : ""%>" class="required" onblur="genericValid(this);" />
						</div>
						<div id="decricao" class="textBox" style="width: 271px;">
							<label>Unidade</label><br/>					
							<input id="descricaoUndIn" name="descricaoUndIn" type="text" style="width: 271px" value="<%=(isEdition)? unidade.getDescricao() : "Master Odontologia & Saúde"%>" class="required" onblur="genericValid(this);" />
						</div>
						<div id="cnpj" class="textBox" style="width: 150px">
							<label>Cnpj</label><br/>					
							<input id="cnpjIn" name="cnpjIn" type="text" style="width: 150px" value="<%=(isEdition)? Util.mountCnpj(unidade.getCnpj()) : "" %>" class="required" onkeydown="mask(this, cnpj);" onblur="cnpjValidation(this)" />
						</div>
						<div id="Franquia" class="textBox" >
							<label>Tipo</label><br />
							<select id="tipo" name="tipo">
								<%if (isEdition && haveHold) {%>
									<option value="h" <%if (isEdition && unidade.getTipo().trim().equals("h")) out.print("selected=\"selected\""); %>>Matriz</option>	
								<%} else if ((!isEdition) && (!haveHold)){%>
									<option value="h">Matriz</option>
								<%}%>
								<option value="u" <%if (isEdition && unidade.getTipo().trim().equals("u")) out.print("selected=\"selected\""); %>>Filial</option>
								<option value="f" <%if (isEdition && unidade.getTipo().trim().equals("f")) out.print("selected=\"selected\""); %>>Franquia</option>
							</select>
						</div>
						<div id="cadastro" class="textBox" style="width: 73px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" class="required" type="text" <%if(isEdition
									&& (!request.getSession().getAttribute("perfil").equals("a"))
									&& (!request.getSession().getAttribute("perfil").equals("d"))) {%> "readonly="readonly" <%}%> style="width: 73px;" value="<%=(isEdition)? Util.parseDate(unidade.getCadastro(), "dd/MM/yyyy") : ""%>"" <%if(!isEdition) {%> onkeydown="mask(this, dateType);" <%}%>/>
						</div>
						<div id="status" class="textBox" style="width: 280px">
							<label >Status</label><br />
							<div class="checkRadio">
								<label class="labelCheck" >Ativo</label><%
								if (isEdition) {%>
									<input id="ativoChecked" name="ativoChecked" type="radio"  <%if (unidade.getAtivo().equals("a")){ out.print(" checked=\"checked\""); }%> value="a" />								
								<label class="labelCheck" >Bloqueado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" <%if (unidade.getAtivo().equals("b")) { out.print("checked=\"checked\""); }%> value="b" />
								<label class="labelCheck" >Cancelado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" <%if (unidade.getAtivo().equals("c")) { out.print("checked=\"checked\""); }%> value="c" />
								<%} else {%>
									<input id="ativoChecked" name="ativoChecked" type="radio" checked="checked" value="a" />
									<label class="labelCheck" >Bloqueado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" value="b" />
									<label class="labelCheck" >Cancelado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" value="c" />
								<%}%>
							</div>
						</div>
						<div id="site" class="textBox" style="width: 320px">
							<label>Site</label><br/>					
							<input id="siteIn" name="siteIn" type="text" style="width: 100%" value="<%=(isEdition)? unidade.getSite() : "www.sacmaster.com.br" %>" class="required" onblur="genericValid(this)" />
						</div>
					</div>
				</div>
				<%if (isEdition) {%>
					<div class="topButtonContent">
						<div class="formGreenButton">
							<input class="grayButtonStyle" type="button" value="Cadastro" onclick="alert('em manutenção')" />
						</div>
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Doc. Digital" onclick="loadDocDigital()" />
						</div>
						<%if (session.getAttribute("perfil").equals("a")) {%>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Upload" onclick="showUploadWd()" />
							</div>
						<%} else {%>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Upload" onclick="notAtorize()" />
							</div>
						<%}%>
					</div>
				<%}%>
				<div id="mainContent">
					<%if (isEdition && unidade.getAdministrador() != null) {%>
						<div id="responsavel" class="bigBox" >
							<div class="indexTitle">
								<h4>Responsável</h4>
								<div class="alignLine">
									<hr>
								</div>
							</div>
							<div>
								<input id="edAdmin" name="edAdmin" type="hidden" value="<%=(isEdition)? "on": "off" %>" />
								<input id="codAdmin" name="codAdmin" type="hidden" value="<%=(isEdition)? String.valueOf(unidade.getAdministrador().getCodigo()) : "" %>" />
								<input id="refAdmin" name="refAdmin" type="hidden" value="<%=(isEdition)? String.valueOf(unidade.getAdministrador().getReferencia()) : "" %>" />
								<input id="edAdminAddress" name="edAdminAddress" type="hidden" value="<%=(isEdition)? "on": "off" %>" />
								<%-- <input id="codAdmimAddress" name="codAdmimAddress" type="hidden" value="<%=(isEdition)? String.valueOf(enderecoResponsavel.getCodigo()) : "" %>" /> --%>
								<input id="codUnit"  name="codUnit" type="hidden" value="<%=(isEdition)? String.valueOf(unidade.getCodigo()) : "" %>" />
								<input id="ccobSequencialIn"  name="ccobSequencialIn" type="hidden" value="<%=(isEdition)? String.valueOf(unidade.getCcobSequencial()) : "" %>" />
								 
							</div>
							<div id="fot" class="textBox" style="width: 103px; height: 137px">
							
								<img src="<%=(unidade.getAdministrador().getLogin() != null && isEdition && unidade.getAdministrador().getLogin().getFoto() != null)? unidade.getAdministrador().getLogin().getFoto(): "../image/foto.gif" %>" width="103" height="137"/>
							</div>							
							<div id="nome" class="textBox" style="width: 270px; height: 20px">
								<strong>Nome: </strong><label><%= Util.initCap(unidade.getAdministrador().getNome()) %></label>
							</div>
							<div class="textBox" style="width:105px; height: 20px">
								<strong>Sexo: </strong><label><%= (unidade.getAdministrador().getSexo().equals("m"))? "Masculino"	: "Feminino" %></label>
							</div>
							<div id="cpf" class="textBox" style="width: 137px; height: 20px">
								<strong>Cpf: </strong><label><%= Util.mountCpf(unidade.getAdministrador().getCpf()) %></label>
							</div>
							<div id="rg" class="textBox" style="width:111px; height: 20px">
								<strong>Rg: </strong><label><%=(unidade.getAdministrador().getRg() != null)? unidade.getAdministrador().getRg() : ""%></label>								
							</div>
							
							<div id="nascimento" class="textBox" style="width: 167px; height: 20px">
								<strong>Nasc.: </strong><label><%= Util.parseDate(unidade.getAdministrador().getNascimento(), "dd/MM/yyyy") %></label>								
							</div>
							<div class="textBox" style="width: 160px; height: 20px">
								<strong>Estado Cívil: </strong><label>
								<%if (unidade.getAdministrador().getEstadoCivil().equals("c")) {
									out.print("Casado(a)");									 
								} else if (unidade.getAdministrador().getEstadoCivil().equals("s")) {
									out.print("Solteiro(a)");
								} else if (isEdition && unidade.getAdministrador().getEstadoCivil().equals("o")) {
									out.print("Outros");
								}%>
								</label>									
							</div>
							<div id="nacionalidade" class="textBox" style="width:300px; height: 20px">
								<strong>Nacionalidade: </strong><label><%=Util.initCap(unidade.getAdministrador().getNacionalidade())%></label>
							</div>	
							<div id="naturalidade" class="textBox" style="width:258px; height: 20px">
								<strong>Naturalidade: </strong><label><%=Util.initCap(unidade.getAdministrador().getNaturalidade())%></label>
							</div>
							<div id="naturalUf" class="textBox" style="width: 45px; height: 20px">
								<strong>Uf: </strong><label><%= unidade.getAdministrador().getNaturalidadeUf().toUpperCase() %></label>
							</div>
							<div class="textBox" style="width: 776px; height: 30px">							
								<strong style="color: #42929D; font-style: italic; font-size: 15px; font-weight: bolder;">Endereço</strong>
							</div>
							<% if (enderecoResponsavel != null) {%>
								<div id="cepResponsavel" class="textBox" style="width: 109px; height: 20px">
									<strong>CEP: </strong><label><%= Util.mountCep(enderecoResponsavel.getCep()) %></label>
								</div>
								<div id="ruaResponsavel" class="textBox"style="width: 280px; height: 20px">
									<strong>Endereço: </strong><label><%= Util.initCap(enderecoResponsavel.getRuaAv()) %></label>
								</div>
								<div id="numeroResponsavel" class="textBox" style="width: 105px; height: 20px">
									<strong>Num.: </strong><label><%=(enderecoResponsavel.getNumero() != null)? enderecoResponsavel.getNumero(): "" %></label>							
								</div>
								<div id="complementoResponsavel" class="textBox" style="width:267px; height: 20px">
									<strong>Complemento: </strong><label><%=(enderecoResponsavel.getComplemento() != null)? enderecoResponsavel.getComplemento() : "" %></label>
								</div>
								<div id="bairroResponsavel" class="textBox" style="width: 402px; height: 20px">
									<strong>Bairro: </strong><label><%=(enderecoResponsavel.getBairro() != null)? Util.initCap(enderecoResponsavel.getBairro()) : "" %></label>
								</div>
								<div id="cidadeResponsavel" class="textBox" style="width: 332px; height: 20px">
									<strong>Cidade: </strong><label><%= Util.initCap(enderecoResponsavel.getCidade()) %></label>
								</div>
								<div id="ufResp" class="textBox" style="height: 20px">
									<strong>Uf: </strong><label><%= enderecoResponsavel.getUf().toUpperCase() %></label>										
								</div>												
								
							<% }%>
						</div>					
					<%}
					if (isEdition) {%>
						<div class="buttonContent" >
							<div class="formGreenButton">
								<input id="fotoLoad" name="fotoLoad" class="greenButtonStyle" type="button" value="Editar Foto" onclick="loadFile()"/>
							</div>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Cartão" onclick="pdfCartao()" />
							</div>
						</div>						
					<%}%>
					<div id="endereco" class="bigBox" >
						<div class="indexTitle">
							<h4>Endereço Unidade</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>		
						<div>
							<input id="edMainAddress" name="edMainAddress" type="hidden" value="<%=(isEdition)? "on": "off" %>" />
							<input id="codMainAddress" name="codMainAddress" type="hidden" value="<%= (isEdition && enderecoGeral != null)? String.valueOf(enderecoGeral.getCodigo()) : "" %>" />
						</div>						
						<div id="cep" class="textBox" style="width: 73px">
							<label>CEP</label><br/>					
							<input id="cepIn" name="cepIn" type="text" style="width: 73px" value="<%= (enderecoGeral != null && enderecoGeral.getCep() != null && isEdition)? Util.mountCep(enderecoGeral.getCep()) : "" %>" onkeydown="mask(this, cep);" />						
						</div>
						<div id="rua" class="textBox" style="width: 200px">
							<label>Endereço</label><br/>					
							<input id="ruaIn" name="ruaIn" type="text" style="width: 200px" value="<%= (enderecoGeral != null && enderecoGeral.getRuaAv() != null && isEdition)? Util.initCap(enderecoGeral.getRuaAv()) : ""%>" class="required" onblur="genericValid(this)" />						
						</div>
						<div id="numero" class="textBox" style="width: 45px">
							<label>Numero</label><br/>					
							<input id="numeroIn" name="numeroIn" type="text" style="width: 45px" value="<%= (enderecoGeral != null &&  (enderecoGeral.getNumero() != null) && (isEdition ))? enderecoGeral.getNumero() : ""%>"/>
						</div>
						<div id="complemento" class="textBox" style="width: 220px">
							<label>Complemento</label><br/>					
							<input id="complementoIn" name="complementoIn" type="text" style="width: 220px"  value="<%=(enderecoGeral != null && (enderecoGeral.getComplemento() != null) && (isEdition))? enderecoGeral.getComplemento() : ""%>"/>
						</div>
						<div id="bairro" class="textBox" style="width: 200px">
							<label>Bairro</label><br/>					
							<input id="bairroIn" name="bairroIn" type="text" style="width: 200px" value="<%=(enderecoGeral != null && (enderecoGeral.getBairro() != null) && (isEdition))? Util.initCap(enderecoGeral.getBairro()) : ""%>"/>
						</div>
						<div id="cidade" class="textBox" style="width: 240px">
							<label>Cidade</label><br/>					
							<input id="cidadeIn" name="cidadeIn" type="text" style="width: 240px" value="<%= (enderecoGeral != null && enderecoGeral.getCidade() != null && isEdition)? Util.initCap(enderecoGeral.getCidade()) : ""%>" class="required" onblur="genericValid(this)" />
						</div>
						<div id="uf" class="textBox">
							<label>Uf</label><br/>
							<select type="select-multiple" id="ufIn" name="ufIn">
								<%for(String uf: uf2005) {
									if (enderecoGeral != null && enderecoGeral.getUf() != null && isEdition && enderecoGeral.getUf().trim().equals(uf.toLowerCase())) {
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
					<div id="contato" class="bigBox" >
						<div class="indexTitle">
							<h4>Informações de Contato</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div><input id="edInfo" name="edInfo" type="hidden" value="<%=(isEdition)? "on": "off" %>" /></div>												
						<div class="textBox" style="width: 135px">
							<label>Tipo</label><br/>
							<select id="tipoContato" name="tipoContato" onchange="clearNext('descricaoIn')" >
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
						<div id="descricao" class="textBox" style="width: 300px">
							<label>Descrição</label><br/>					
							<input id="descricaoIn" name="descricao" type="text" style="width:300px;" onkeydown="comboMask(this, 'tipoContato')"/>						
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
						<div class="formGreenButton" >
							<input name="removeConta" class="greenButtonStyle" type="button" value="Excluir" onclick="removeRowContact()" />
						</div>					
						<div class="formGreenButton">
							<input id="insertInfo" name="insertInfo" class="greenButtonStyle" type="button" value="Inserir" onclick="addRowContact()" />
						</div>
					</div>
					<div id="conta" class="bigBox">
						<div class="indexTitle">
							<h4>Centercob</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div id="ccobId" class="textBox" style="width: 150px">
							<label>Número Centercob</label><br/>					
							<input id="ccobIdIn" name="ccobIdIn" type="text" maxlength="30" style="width: 150px" value="<%= (isEdition && unidade.getCcobId() != null)? unidade.getCcobId() : ""%>"/>
						</div>
						<div id="ccobVerssao" class="textBox" style="width: 150px">
							<label>Verssão do layout</label><br/>					
							<input id="ccobVerssaoIn" name="ccobVerssaoIn" type="text" maxlength="30" style="width: 150px" value="<%= (isEdition && unidade.getCcobVerssao() != null)? unidade.getCcobVerssao() : ""%>"/>
						</div>
					</div>				
					<div id="conta" class="bigBox">
						<div class="indexTitle">
							<h4>Conta Corrente</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div><input id="edAcount" name="edAcount" type="hidden" value="<%=(isEdition)? "on": "off" %>" /></div>
						<div class="textBox" style="width: 210px">
							<label>Banco</label><br/>
							<select id="banco" name="banco">
								<option value="-1" >Selecione</option>
								<%for(Banco bc: banco){
									out.println("<option value=\"" + String.valueOf(bc.getCodigo()) + "@" +
											Util.initCap(bc.getDescricao()) + "\" >" +
										 Util.initCap(bc.getDescricao()) + "</option>");
								}%>								
							</select>	
						</div>	
						<div id="agencia" class="textBox" style="width: 50px">
							<label>Agencia</label><br/>					
							<input id="agenciaIn" name="agenciaIn" type="text" style="width: 50px"/>
						</div>
						<div id="numeroConta" class="textBox" style="width: 100px">
							<label>Numero</label><br/>					
							<input id="numeroContaIn" name="numero" type="text" style="width: 100px"/>
						</div>
						<div id="carteira" class="textBox" style="width: 100px">
							<label>Carteira</label><br/>					
							<input id="carteiraIn" name="carteiraIn" type="text" style="width: 100px"/>
						</div>
						<div id="carteira" class="textBox" style="width: 70px">
							<label>Vlr. Boleto</label><br/>					
							<input id="boletoIn" name="boletoIn" type="text" style="width: 70px" value="0.00" onkeydown="mask(this, decimalNumber);"/>
						</div>
						<div id="titularConta" class="textBox" style="width: 300px">
							<label>Titular</label><br/>					
							<input id="titularContaIn" name="titularContaIn" type="text" style="width: 300px"/>
						</div>								
						<div id="tableBank" style="margin-right: 68px"></div>
					</div>
					<div class="buttonContent" >
						<div class="formGreenButton">
							<input name="removeConta" class="greenButtonStyle" type="button" value="Excluir" onclick="removeRowBank()" />
						</div>
						<div class="formGreenButton"  >
							<input name="insertConta" class="greenButtonStyle" type="button" value="Inserir" onclick="addRowBank()" />				
						</div>
					</div>
					<div id="taxas" class="bigBox" >
						<div class="indexTitle">
							<h4>Taxas Sobre Serviços</h4>
							<div class="alignLine">
								<hr>
							</div>
							<div id="adesao" class="textBox" style="width: 115px">
								<label>Vlr. Adesão</label><br/>					
								<input id="adesaoIn" name="adesaoIn" type="text" style="width: 115px" value="<%= (isEdition)? unidade.getAdesao() : "0.00" %>" class="required" onkeydown="mask(this, decimalNumber);" onblur="genericValid(this)" />
							</div>
							<div id="taxa" class="textBox" style="width: 107px">
								<label>Vlr. Mensalidade</label><br/>					
								<input id="taxaIn" name="taxaIn" type="text" style="width: 107px" value="<%=(isEdition)? unidade.getTaxa() : "0.00" %>" class="required" onkeydown="mask(this, decimalNumber);" onblur="genericValid(this)" />
							</div>
							<div id="tabela2" class="textBox" style="width: 95px">
								<label>%Carteira ADM</label><br/>					
								<input id="tabela2In" name="tabela2In" type="text" style="width: 93px" value="<%=(isEdition)? unidade.getTabela2(): "0.00" %>" class="required" onkeydown="mask(this, decimalNumber);" onblur="genericValid(this)" <% if (!isAdm) {%> readonly="readonly" <%}%>/>
							</div>
							<div id="tratamento" class="textBox" style="width: 93px">
								<label>%Tratamento</label><br/>					
								<input id="tratamentoIn" name="tratamentoIn" type="text" style="width: 93px" value="<%=(isEdition)? unidade.getTabela2(): "0.00" %>" class="required" onkeydown="mask(this, decimalNumber);" onblur="genericValid(this)" <% if (!isAdm) {%> readonly="readonly" <%}%> />
							</div>
							<div id="mensalidade" class="textBox" style="width: 93px">
								<label>%Mensalidade</label><br/>					
								<input id="mensalidadeIn" name="mensalidadeIn" type="text" style="width: 93px" value="<%=(isEdition)? unidade.getTabela2(): "0.00" %>" class="required" onkeydown="mask(this, decimalNumber);" onblur="genericValid(this)" <% if (!isAdm) {%> readonly="readonly" <%}%> />
							</div>
							<div class="textBox" style="width: 87px">
								<label>Vencimento</label><br/>
								<select id="vencimento" name="vencimento" style="width: 87px" <% if (!isAdm) {%> disabled="disabled" <%}%>>
									<option value="01" 
									<%if (isEdition && unidade.getVencimento().equals("01")) {
										out.print("selected=\"selected\"");
									}%>>Dia 01</option>
									<option value="05"
									<%if (isEdition && unidade.getVencimento().equals("05")) {
										out.print("selected=\"selected\"");
									}%>>Dia 05</option>
									<option value="10"
									<%if (isEdition && unidade.getVencimento().equals("10")) {
										out.print("selected=\"selected\"");								
									}%>>Dia 10</option>
									<option value="15"
									<%if (isEdition && unidade.getVencimento().equals("15")) {
										out.print("selected=\"selected\"");
									}%>>Dia 15</option>
									<option value="20"
									<%if (isEdition && unidade.getVencimento().equals("20")) {
										out.print("selected=\"selected\"");
									}%>>Dia 20</option>
									<option value="25"
									<%if (isEdition && unidade.getVencimento().equals("25")) {
										out.print("selected=\"selected\"");
									}%>>Dia 25</option>
									<option value="30"
									<%if (isEdition && unidade.getVencimento().equals("30")) {
										out.print("selected=\"selected\"");
									}%>>Dia 30</option>
								</select>
							</div>
							<div class="textBox" style="width: 241px">
								<label>Tabela Franchising</label><br/>
								<select id="tabelaId" name="tabelaId" style="width: 241px" <% if (!isAdm) {%> disabled="disabled" <%}%>>
									<option value="">Selecione</option>
									<%for(TabelaFranchising tabela: tabelaFranchisings) {
										if (unidade.getTabelaFranchising()!= null && isEdition 
												&& unidade.getTabelaFranchising().equals(tabela)) {%>
											<option selected="selected" value="<%= tabela.getCodigo() %>"><%= tabela.getDescricao() %></option>
										<%} else {%>
											<option value="<%= tabela.getCodigo() %>"><%= tabela.getDescricao() %></option>
										<%}
									}%>
								</select>
							</div>
						</div>
					</div>					
					<div class="buttonContent" >
						<div class="formGreenButton">
							<%if (session.getAttribute("perfil").toString().equals("a")
									|| session.getAttribute("perfil").toString().equals("d")) {%>
								 <input class="greenButtonStyle" style="margin-top: 10px;" type="submit" value="Salvar" />
							<%} else {%>
								<input class="greenButtonStyle" style="margin-top: 10px;" type="button" value="Salvar" onclick="noAccess()" />
							<%}%>
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