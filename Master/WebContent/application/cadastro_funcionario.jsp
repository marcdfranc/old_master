<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.database.Posicao"%>
<%@page import="java.util.List"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Funcionario"%>
<%@page import="com.marcsoftware.database.Endereco"%>
<%@page import="com.marcsoftware.database.Conta"%>
<%@page import="com.marcsoftware.database.Informacao"%>
<%@page import="com.marcsoftware.database.Banco"%>
<html xmlns="http://www.w3.org/1999/xhtml">
	<%! boolean isEdition= false; %>
	<% isEdition = false;
	isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}%>
	<jsp:useBean id="funcionario" class="com.marcsoftware.database.Funcionario"></jsp:useBean>
	<jsp:useBean id="unidade" class="com.marcsoftware.database.Unidade"></jsp:useBean>
	<jsp:useBean id="enderecoGeral" class="com.marcsoftware.database.Endereco"></jsp:useBean>
	<jsp:useBean id="enderecoResponsavel" class="com.marcsoftware.database.Endereco"></jsp:useBean>
	<%Session sess = (Session) session.getAttribute("hb");
		if (!sess.isOpen()) {
			sess = HibernateUtil.getSession();
		}
		Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
		Query query = null;
		String imageFoto = "";
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
		query= sess.createQuery("from Posicao");
		List<Posicao> posicao= (List<Posicao>) query.list();
		query= sess.createQuery("from Banco");
		List<Banco> banco= (List<Banco>) query.list();
		query = sess.createQuery("select distinct c.uf from Cep2005 as c");
		List<String> uf2005 = (List<String>) query.list();
		if (isEdition) {
			query= sess.createQuery("from Funcionario as f where f.codigo = :codigo");
			query.setLong("codigo", Long.valueOf(request.getParameter("id")));
			funcionario = (Funcionario) query.uniqueResult();
			query = sess.getNamedQuery("enderecoOf").setEntity("pessoa", funcionario);
			query.setFirstResult(0);
			query.setMaxResults(1);
			enderecoGeral= (Endereco) query.uniqueResult();
			if (funcionario.getLogin() == null) {
				imageFoto = "../image/foto.gif";				
			} else if (funcionario.getLogin().getFoto() == null) {
				imageFoto = "../image/foto.gif";
			} else {
				imageFoto = funcionario.getLogin().getFoto();
			}
		}%>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/validation.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/comum/cadastro_funcionario.js"></script>
	<script type="text/javascript" src="../js/lib/pilot_grid.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_window.js"></script>
	
	<title>Master Cadastro de Funcionarios</title>
</head>
<body onload="loadPage(<%=isEdition%>)">
	<%@ include file="../inc/header.jsp"%>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="rh"/>
	</jsp:include>
	<div id="centerAll" >
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="rh"/>
		</jsp:include>
		<div id="formStyle">		
			<form id="formPost" method="post" action="../CadastroFuncionario" onsubmit= "return validForm(this)" >
				<div id="localEdBank" ><%
					if (isEdition) {						
						query= sess.getNamedQuery("contaOf").setEntity("pessoa", funcionario);
						List<Conta> contaList= (List<Conta>) query.list();
						for(int i=0; i < contaList.size() ; i++){
							out.print("<input id=\"edBank" + String.valueOf(i) + "\" name=\"edBank" +
									String.valueOf(i) + "\" type=\"hidden\" value=\"" + 
									contaList.get(i).getBanco().getCodigo() + "@" +
									Util.initCap(contaList.get(i).getBanco().getDescricao()) + "\" />");
							
							out.print("<input id=\"edAgency" + String.valueOf(i) + "\" name=\"edAgency" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +
									contaList.get(i).getAgencia()+ "\" />");
							
							out.print("<input id=\"edCont" + String.valueOf(i) + "\" name=\"edCont" + String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + contaList.get(i).getNumero() + "\" />");
							
							out.print("<input id=\"edOwner" + String.valueOf(i) + "\" name=\"edOwner" + String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + 
									Util.initCap(contaList.get(i).getTitular()) + "\" />");
							
							out.print("<input id=\"acountId" + String.valueOf(i) + "\" name=\"acountId" + String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + contaList.get(i).getCodigo() + "\" />");							
						}
					}					
				%>			
				</div>
				<div id="localBank"></div>
				<div id="localEdContact" ><%
					if (isEdition) {						
						query= sess.getNamedQuery("informacaoOf").setEntity("pessoa", funcionario);
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
					}%>
				</div>
				<div id="localContact"></div>
				<div id="localConta"></div>
				<div id="deletedsContact"></div>				
				<div id="deletedsBank"></div>
				<div id="editedsBank"></div>
				<div id="editedsContact"></div>							
				<div id="geralDate" class="alignHeader" >				
					<div>
						<input id="edUnit" name="edUnit" type="hidden" value="<%=(isEdition)? "on": "off" %>" />
						<input id="codUnit" name="codUnit" type="hidden" value="<%=(isEdition)? String.valueOf(funcionario.getCodigo()) : "" %>" />
						<input id="codFuncionario" name="codFuncionario" type="hidden" value="<%=(isEdition)? String.valueOf(funcionario.getCodigo()) : "" %>" />
						<input id="codAddress" name="codAddress" type="hidden" value="<%=(isEdition)? String.valueOf(enderecoGeral.getCodigo()) : "" %>" />
						<input id="edBank" name="edBank" type="hidden" value="n"/>
						<input id="edContact" name="edContact" type="hidden" value="n"/> 
					</div>
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="RH"/>			
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
								<a href="anexo_rh.jsp?id=<%= funcionario.getCodigo()%>">Anexo</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="requisicao_contrato.jsp?id=<%= funcionario.getCodigo()%>">Requisição</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="contrato.jsp?state=1&id=<%= funcionario.getCodigo()%>">Contratos</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="bordero_funcionario.jsp?state=1&id=<%= funcionario.getCodigo()%>">Borderô</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
														
							<div class="aba2">
								<a href="fatura_vendedor.jsp?id=<%= funcionario.getCodigo()%>">Histórico de Faturas</a>
							</div>
						</div>
					<%} else {%>
						<div id="abaMenu">
							<div class="aba2">
								<a href="funcionario.jsp">RH</a>
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
						<div class="textBox" style="width: 85px">
							<label>Cód. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId">
								<option>selecione</option>
								<%for(Unidade un: unidadeList) {
									if (isEdition && funcionario.getUnidade().equals(un)) {
										out.print("<option value=\"" + un.getRazaoSocial() + "@" +
												un.getCodigo() + "\" selected=\"selected\" >" + 
												un.getReferencia() + "</option>");
									} else {
									out.print("<option value=\"" + un.getRazaoSocial() + "@" +
											un.getCodigo() + "\">" + un.getReferencia() + "</option>");
									}
								}%>
							</select>
						</div>
						<div id="unidade" class="textBox" style="width: 300px;">
							<label>Unidade</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" style="width: 300px;" value="<%
								if (isEdition) {
									out.print(funcionario.getUnidade().getDescricao());								
								} else {
									out.print("");								
								} %>" class="required" enable="false" onblur="genericValid(this);" />
						</div>
						<div id="cadastro" class="textBox" style="width:75px">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" type="text" style="width:75px" value="<%=(isEdition)? Util.parseDate(funcionario.getCadastro(), "dd/MM/yyyy") : Util.getToday()%>" class="required" onkeydown="mask(this, dateType);" onblur="genericValid(this)" />
						</div>
						<div id="ccobVendedor" class="textBox" style="width:150px">
							<label>Número Centercob</label><br/>
							<input id="ccobVendedorIn" name="ccobVendedorIn" type="text" style="width:150px" value="<%=(isEdition && funcionario.getCcobVendedor() != null)? funcionario.getCcobVendedor() : ""%>"  />
						</div>
						<div id="status" class="textBox" style="width: 280px">
							<label >Status</label><br />
							<div class="checkRadio">
								<label class="labelCheck" >Ativo</label><%
								if (isEdition) {%>
									<input id="ativoChecked" name="ativoChecked" type="radio"  <%if (funcionario.getAtivo().equals("a")){ out.print(" checked=\"checked\""); }%> value="a" />									
								<label class="labelCheck" >Bloqueado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" <%if (funcionario.getAtivo().equals("b")) { out.print("checked=\"checked\""); }%> value="b" />
								<label class="labelCheck" >Cancelado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" <%if (funcionario.getAtivo().equals("c")) { out.print("checked=\"checked\""); }%> value="c" />
								<%} else {%>
									<input id="ativoChecked" name="ativoChecked" type="radio"  checked="checked" value="a" />
									<label class="labelCheck" >Bloqueado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" value="b" />
									<label class="labelCheck" >Cancelado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" value="c" />
								<%}%>
							</div>
						</div>
					</div>
				</div>
				<div id="mainContent">
					<div id="dadosPessoais" class="bigBox" >
						<div class="indexTitle">
							<h4>Dados Pessoais</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div id="fot" class="textBox"style="width: 103px; height: 137px">
							<img src="<%=(isEdition)? imageFoto: "../image/foto.gif" %>" width="103" height="137"/>
						</div>
						<div id="registro" class="textBox" style="width: 70px;">
							<label>Referência</label><br/>						
							<input id="registroIn" name="registroIn" type="text" style="width: 70px;" value="<%=(isEdition)? String.valueOf(funcionario.getCodigo()) : "" %>" readonly="readonly" />
						</div>
						<div id="nome" class="textBox" style="width: 245px;">
							<label>Nome</label><br/>
							<input id="nomeIn" name="nomeIn" type="text" style="width: 245px;" value="<%=(isEdition)? Util.initCap(funcionario.getNome()): "" %>" class="required" onblur="genericValid(this);" />
						</div>
						<div class="textBox" style="width: 200px">
							<label>Sexo</label><br />
							<div class="checkRadio" >
								<label>Masculino</label><%
								if (isEdition) {%>
									<input id="sexo" name="sexo" type="radio" <%if (funcionario.getSexo().equals("m")) { out.print("checked=\"checked\""); }%> value="m" />
								<label>Feminino</label>
									<input id="sexo" name="sexo" type="radio" <%if (funcionario.getSexo().equals("f")) { out.print("checked=\"checked\""); }%> value="f"/>
								<%} else {%>
									<input id="sexo" name="sexo" type="radio" checked="checked" value="m"/>
									<label>Feminino</label>
									<input id="sexo" name="sexo" type="radio" value="f"/>
								<%}%>
							</div>
						</div>
						<div id="cpf" class="textBox" style="width: 100px">
							<label>Cpf</label><br/>
							<input id="cpfIn" name="cpfIn" type="text" style="width: 100px" value="<%=(isEdition)? Util.mountCpf(funcionario.getCpf()) : ""%>"  class="required" onkeydown="mask(this, cpf);" onblur="cpfValidation(this)" />
						</div>
						<div id="rg" class="textBox" style="width: 100px">
							<label>Rg</label><br/>
							<input id="rgIn" name="rgIn" type="text" style="width: 100px" value="<%=(isEdition && !funcionario.getRg().trim().isEmpty())? funcionario.getRg() : ""%>" onblur="genericValid(this);"/>
						</div>
						<div id="cnh" class="textBox" style="width: 100px">
							<label>Cnh</label><br/>
							<input id="cnhIn" name="cnhIn" type="text" style="width: 100px" value="<%=(isEdition)? funcionario.getCnh() : ""%>" onblur="genericValid(this);" />
						</div>
						<div id="ctps" class="textBox" style="width: 100px">
							<label>CTPS</label><br/>
							<input id="ctpsIn" name="ctpsIn" type="text" style="width: 100px" value="<%=(isEdition)? funcionario.getCtps() : ""%>" onblur="genericValid(this);" />
						</div>
						<div id="pis" class="textBox" style="width: 100px">
							<label>PIS</label><br/>
							<input id="pisIn" name="pisIn" type="text" style="width: 100px" value="<%=(isEdition)? funcionario.getPis() : ""%>" onblur="genericValid(this);" />
						</div>
						<div id="nascimento" class="textBox" style="width:75px">
							<label>Nascimento</label><br/>
							<input id="nascimentoIn" name="nascimentoIn" type="text" style="width:75px" value="<%=(isEdition)? Util.parseDate(funcionario.getNascimento(), "dd/MM/yyyy") : ""%>" class="required" onkeydown="mask(this, typeDate);" onblur="genericValid(this)" />
						</div>
						<div class="textBox">
							<label>Estado Cívil</label><br/>
							<select id="estadoCivilIn" name="estadoCivilIn">
								<option value="c" <%if (isEdition 
										&& funcionario.getEstadoCivil().equals("c")) {%> selected="selected" <%}%> >Casado(a)</option>
								<option value="s" <%if (isEdition 
										&& funcionario.getEstadoCivil().equals("s")) {%> selected="selected" <%}%>>Solteiro(a)</option>
								<option value="o" <%if (isEdition && funcionario.getEstadoCivil().equals("o")) {%> selected="selected" <%}%>>Outro</option>
							</select>
						</div>
						<div id="nacionalidade" class="textBox" style="width:235px">
							<label>Nacionalidade</label><br/>
							<input id="nacionalidadeIn" name="nacionalidadeIn" type="text" style="width:235px" value="<%=(isEdition)? Util.initCap(funcionario.getNacionalidade()) : ""%>" class="required" onblur="genericValid(this)"/>
						</div>
						<div id="naturalidade" class="textBox" style="width:250px">
							<label>Naturalidade</label><br/>
							<input id="naturalidadeIn" name="naturalidadeIn" type="text" style="width:250px" value="<%=(isEdition)? Util.initCap(funcionario.getNaturalidade()) : ""%>" class="required" onblur="genericValid(this)" />
						</div>
						<div id="naturalUf" class="textBox">
							<label>Uf</label><br/>
							<select type="select-multiple" id="naturalUfIn" name="naturalUfIn">
								<%for(String uf: uf2005) {
									if (isEdition && funcionario.getNaturalidadeUf().trim().equals(uf.toLowerCase())) {
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
					<%if (isEdition) {%>
						<div class="buttonContent">
							<div class="formGreenButton">
								<input id="fotoLoad" name="fotoLoad" class="greenButtonStyle" type="button" value="Editar Foto" onclick="loadFile()"/>
							</div>							
						</div>
					<% }%>
					<div id="endereco" class="bigBox" >
						<div class="indexTitle">
							<h4>Endereço</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div id="cep" class="textBox" style="width: 73px">
							<label>CEP</label><br/>
							<input id="cepIn" name="cepIn" type="text" style="width: 73px" value="<%=(isEdition)? Util.mountCep(enderecoGeral.getCep()) : ""%>" onkeydown="mask(this, cep);" />
						</div>
						<div id="rua" class="textBox" style="width: 220px">
							<label>Endereço</label><br/>
							<input id="ruaIn" name="ruaIn" type="text" style="width: 220px" value="<%=(isEdition)? Util.initCap(enderecoGeral.getRuaAv()) : ""%>" class="required" onblur="genericValid(this)" />
						</div>
						<div id="numero" class="textBox" style="width: 50px">
							<label>Numero</label><br/>
							<input id="numeroIn" name="numeroIn" type="text" style="width: 50px" value="<%=(isEdition)? enderecoGeral.getNumero() : ""%>" />
						</div>
						<div id="complemento" class="textBox" style="width: 220px">
							<label>Complemento</label><br/>
							<input id="complementoIn" name="complementoIn" type="text" style="width: 220px" value="<%=(isEdition)? enderecoGeral.getComplemento() : ""%>" />
						</div>
						<div id="bairro" class="textBox" style="width: 220px">
							<label>Bairro</label><br/>
							<input id="bairroIn" name="bairroIn" type="text" style="width: 220px" value="<%=(isEdition)? Util.initCap(enderecoGeral.getBairro()) : ""%>" />
						</div>
						<div id="cidade" class="textBox" style="width: 240px">
							<label>Cidade</label><br/>
							<input id="cidadeIn" name="cidadeIn" type="text" style="width: 240px" value="<%=(isEdition)? Util.initCap(enderecoGeral.getCidade()) : ""%>" class="required" onblur="genericValid(this)" />
						</div>
						<div id="uf" class="textBox">
							<label>Uf</label><br/>
							<select type="select-multiple" id="ufIn" name="ufIn">
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
					<div id="contato" class="bigBox" >
						<div class="indexTitle">
							<h4>Informações de Contato</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<input id="edInfo" name="edInfo" type="hidden"/>						
						<div class="textBox" style="width: 130px">
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
						<div id="descricao" class="textBox" style="width:300px;">
							<label>Descrição</label><br/>
							<input id="descricaoIn" name="descricao" type="text" style="width:300px;" onkeydown="comboMask(this, 'tipoContato')"/>
						</div>
						<div class="textBox" id="principal">
							<label>Principal</label><br/>
							<select id="principalIn" name="principalIn" >								
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
							<input id="specialButton" name="insertDependente" class="greenButtonStyle" type="button" value="Inserir" onclick="addRowContact()" />
						</div>
					</div>
					<div id="conta" class="bigBox">
						<div class="indexTitle">
							<h4>Conta Corrente</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div><input id="edAcount" name="edAcount" type="hidden"/></div>
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
						<div class="formGreenButton" >
							<input name="insertConta" class="greenButtonStyle" type="button" value="Inserir" onclick="addRowBank()" />				
						</div>
					</div>
					<div id="contrato" class="bigBox" >
						<div class="indexTitle">
							<h4>Informações Contratuais</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div class="textBox">
							<label>Cargo</label><br/>
							<select id="cargoId" name="cargoId">
								<option>selecione</option>
								<% for(Posicao pos: posicao) {
									if (isEdition && pos.equals(funcionario.getPosicao())) {
										out.print("<option value=\"" + pos.getCodigo() + 
												"\" selected=\"selected\">" + pos.getDescricao() + "</option>");										
									} else {
										out.print("<option value=\"" + pos.getCodigo() + 
												"\">" + pos.getDescricao() + "</option>");
									}
								}
								%>								
							</select>
						</div>
						<div id="salario" class="textBox" style="width:80px">
							<label>Salario</label><br/>
							<input id="salarioIn" name="salarioIn" type="text" style="width:80px" value="<%=(isEdition)? funcionario.getSalario() : "0.00"%>" onkeydown="mask(this, decimalNumber);" onblur="genericValid(this);"/>
						</div>
						<div id="comissao" class="textBox" style="width:80px">
							<label>%Adesão</label><br/>
							<input id="comissaoIn" name="comissaoIn" type="text" style="width:80px" value="<%=(isEdition)? funcionario.getComissao() : "0.00"%>" onkeydown="mask(this, decimalNumber);" onblur="genericValid(this)" />
						</div>
						<div id="meta" class="textBox" style="width:50px">
							<label>Meta</label><br/>
							<input id="metaIn" name="metaIn" type="text" style="width:50px" value="<%=(isEdition)? funcionario.getMeta() : "0"%>" onkeydown="mask(this, onlyNumber);" onblur="genericValid(this)" />
						</div>
						<div id="bonus" class="textBox" style="width:80px">
							<label>%Adesão</label><br/>
							<input id="bonusIn" name="bonusIn" type="text" style="width:80px" value="<%=(isEdition)? funcionario.getBonus() : "0.00"%>" onkeydown="mask(this, decimalNumber);" onblur="genericValid(this)" />
						</div>
						<div id="plr" class="textBox" style="width:80px">
							<label>PLR</label><br/>
							<input id="plrIn" name="plrIn" type="text" style="width:80px" value="0.00" onkeydown="mask(this, decimalNumber);" onblur="genericValid(this)" />
						</div>						
						<div class="textBox" style="width: 120px">
							<label>Pagamento</label><br/>
							<select id="tipoPagamento" name="tipoPagamento">
								<option value="1" >Conta Corrente</option>								
							</select>
						</div>
						<div class="textBox" style="width: 140px">
							<label>Vencimento</label><br/>
							<select id="vencimento" name="vencimento"  style="width: 80px">
								<option value="01">Dia 01</option>
								<option value="01">Dia 05</option>
								<option value="10">Dia 10</option>
								<option value="15">Dia 15</option>
								<option value="20">Dia 20</option>
								<option value="25">Dia 25</option>
								<option value="30">Dia 30</option>
							</select>
						</div>
					</div>
					<div id="endPage" class="bigBox" >
						<div class="indexTitle">
							<h4>&nbsp;</h4>
						</div>
					</div>
					<div class="buttonContent" >
						<div class="formGreenButton" >
							<input class="greenButtonStyle" type="submit" value="Salvar" />
						</div>
					</div>
				</div>
			</form>
			<%@ include file="../inc/footer.html" %>
			<%sess.close();%>
		</div>
	</div>
</body>
</html>