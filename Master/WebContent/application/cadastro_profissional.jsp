<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Query"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.database.Banco"%>
<%@page import="com.marcsoftware.database.Profissional"%>
<%@page import="com.marcsoftware.database.Endereco"%>
<%@page import="com.marcsoftware.database.Informacao"%>
<%@page import="com.marcsoftware.database.Conta"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.database.Especialidade"%>
<html xmlns="http://www.w3.org/1999/xhtml">

	<%!boolean isEdition= false;%>
	<%isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}%>
	
	<jsp:useBean id="profissional" class="com.marcsoftware.database.Profissional"></jsp:useBean>
	<jsp:useBean id="endereco" class="com.marcsoftware.database.Endereco"></jsp:useBean>
	
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
	String foto = "";
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
	query= sess.createQuery("from Banco");
	List<Banco> banco= (List<Banco>) query.list();
	query= sess.createQuery("from Especialidade");
	List<Especialidade> especialidade = (List<Especialidade>) query.list();
	query = sess.createQuery("select distinct c.uf from Cep2005 as c");
	List<String> uf2005 = (List<String>) query.list();
	if (isEdition) {
		query= sess.createQuery("from Profissional as p where p.codigo = :codigo");
		query.setLong("codigo", Long.valueOf(request.getParameter("id")));
		profissional= (Profissional) query.uniqueResult();
		if (profissional.getLogin() == null) {
			foto = null;
		} else if(profissional.getLogin().getFoto() == null) {
			foto = null;
		} else {
			foto = profissional.getLogin().getFoto();
		}
		query= sess.getNamedQuery("enderecoOf").setEntity("pessoa", profissional);
		endereco= (Endereco) query.uniqueResult();
	}
	%>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link type="text/css" href="../js/jquery/uploaddif/uploadify.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/uploaddif/swfobject.js"></script>
	<script type="text/javascript" src="../js/jquery/uploaddif/jquery.uploadify.v2.1.4.min.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/validation.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/comum/cadastro_profissional.js" ></script>
	<script type="text/javascript" src="../js/lib/pilot_grid.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
		
	<title>Master Profissionais</title>	
</head>
<body>
	<div id="uploadCadastro" class="removeBorda" title="Upload da Imagem do Cadastro" style="display: none">
		<form id="formUpload" onsubmit="return false;" action="../ProfissionalUpload" method="post" enctype="multipart/form-data">
			<div class="uploadContent" id="contUpload">
				<div id="msgUpload" style="margin-bottom: 20px;">Clique abaixo para selecionar a imagem do profissional.</div>
				<div id="fileQueue" name="fileQueue" style="width: 200px;"></div>
				<input type="file" name="uploadify" id="uploadify" />
				<!-- <p><a href="javascript:jQuery('#uploadify').uploadifyClearQueue()">Cancelar Todos os Anexos</a></p> -->
			</div>
			<input type="hidden" value="" id="uploadName" name="uploadName" />
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="profissional"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="profissional"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formPost" name="formPost" method="post" action="../CadastroProfissional"  onsubmit="return validForm(this)" >
				<div id="localEdBank" ><%
					if (isEdition) {
						query= sess.getNamedQuery("contaOfByCode");
						query.setLong("codigo", profissional.getCodigo());
						List<Conta> contaList= (List<Conta>) query.list();;
						for(int i=0; i < contaList.size(); i++){
														
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
									"\" type=\"hidden\" value=\"" + Util.initCap(contaList.get(i).getTitular()) + "\" />");
							
							out.print("<input id=\"acountId" + String.valueOf(i) + "\" name=\"acountId" + String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + contaList.get(i).getCodigo() + "\" />");							
						}
					}					
				%>
				</div>
				<div id="localEdContact" ><%
					if (isEdition) {
						query= sess.getNamedQuery("informacaoOf").setEntity("pessoa", profissional);
						List<Informacao> info= (List<Informacao>) query.list();
						String principal= ""; 
						for(int i=0; i < info.size() ; i++){
							principal= (info.get(i).getPrincipal().trim().equals("s"))? "Sim" : "Não";
							out.print("<input id=\"edType" + String.valueOf(i) + "\" name=\"edBank" +
									String.valueOf(i) + "\" type=\"hidden\" value=\"" + 
									info.get(i).getTipo() + "\" />");
							
							out.print("<input id=\"edDescription" + String.valueOf(i) +
									"\" name=\"edDescription" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +
									info.get(i).getDescricao()+ "\" />");
							
							out.print("<input id=\"edPrincipal" + String.valueOf(i) +
									"\" name=\"edPrincipal" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +									
									principal + "\" />");
							
							out.print("<input id=\"contactId" + String.valueOf(i) +
									"\" name=\"contactId" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +
									info.get(i).getCodigo()+ "\" />");
						}
					}%>
				</div>				
				<div id="localContact"></div>
				<div id="localBank"></div>
				<div id="deletedsBank"></div>
				<div id="deletedsContact"></div>
				<div id="editedsBank"></div>
				<div id="editedsContact"></div>				
				<div>
					<input id="edProfissional" name="udUser" type="hidden" value="n"/>
					<input id="edAddress" name="edAddress" type="hidden" value="n"/>
					<input id="edBank" name="edDependente" type="hidden" value="n"/>
					<input id="edInfo" name="edInfo" type="hidden" value="n"/>
					<input id="isEdition" name="isEdition" type="hidden" value="<%=(isEdition)? "t" : "f"%>" />
					<input id="codProfissional" name="codProfissional" type="hidden" value="<%=(isEdition)? profissional.getCodigo() : "" %>" />
					<input id="codAddress" name="codAddress" type="hidden" value="<%=(isEdition)? endereco.getCodigo(): "" %>" />
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Profissionais"/>			
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
								<a href="anexo_profissional.jsp?id=<%= profissional.getCodigo()%>">Anexo</a>
							</div>
							
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="agenda_profissional.jsp?id=<%= profissional.getCodigo()%>">Agenda</a>
							</div>
							
														
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="bordero_profissional.jsp?id=<%= profissional.getCodigo()%>">Borderô</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="cadastro_bordero.jsp?id=<%= profissional.getCodigo()%>">Cadastro de Fatura</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="fatura_bordero_profissional.jsp?id=<%= profissional.getCodigo()%>">Histórico de Faturas</a>
							</div>
						</div>
					<%} else {%>
						<div id="abaMenu">
							<div class="aba2">
								<a href="profissionais.jsp">Profissionais</a>
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
						<div class="textBox" style="width: 90px;">
							<label>Código</label><br/>
							<select id="unidadeId" name="unidadeId" style="width: 90px;" onchange="setChange('u')" >
 								<% if (isEdition) { %>							
									<option value="<%=profissional.getUnidade().getRazaoSocial() + "@" + 
									profissional.getUnidade().getCodigo() %>" ><%=profissional.getUnidade().getReferencia() %></option><%
								} else {%>
									<option value="">Selecione</option><%
								}%>
								<%for(Unidade un: unidadeList) {
									if (isEdition) {
										if (!profissional.getUnidade().equals(un)) {
											out.print("<option value=\"" + un.getRazaoSocial() + "@" +
													un.getCodigo() + "\">" + un.getReferencia() + "</option>");
										}
									} else {
										out.print("<option value=\"" + un.getRazaoSocial() + "@" +
												un.getCodigo() + "\">" + un.getReferencia() + "</option>");
									}
								}
								%>
							</select>
						</div>
						<div id="unidade" class="textBox" style="width: 220px;" >
							<label>Unidade</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" style="width: 220px;" value="<%=(isEdition)? Util.initCap(profissional.getUnidade().getDescricao()): "" %>" class="required" enable="false" onblur="genericValid(this);" readonly="readonly" />
						</div>
						<div id="setor" class="textBox" style="width: 130px">
							<label>Atividade</label><br/>
							<select type="select-multiple" id="setorIn" name="setorIn" onchange="setChange('u')" >
								<option value="">Selecione</option>							
								<option value="o" 
									<%if (isEdition && profissional.getEspecialidade().getSetor().trim().equals("o")) {
										out.print("selected=\"selected\"");
									}%> >Odontológica</option>								
								<option value="l" 
									<%if (isEdition && profissional.getEspecialidade().getSetor().trim().equals("l")) {
										out.print("selected=\"selected\"");
									}%>>Laboratorial</option>
								<option value="m" 
									<%if (isEdition && profissional.getEspecialidade().getSetor().trim().equals("m")) {
										out.print("selected=\"selected\"");
									}%>>Médica</option>									
								<option value="h" 
									<%if (isEdition && profissional.getEspecialidade().getSetor().trim().equals("h")) {
										out.print("selected=\"selected\"");
									}%>>Hospitalar</option>									
								<option value="a" 
									<%if (isEdition && profissional.getEspecialidade().getSetor().trim().equals("a")) {
										out.print("selected=\"selected\"");
									}%>>Administrativa</option>									
								<option value="e" 
									<%if (isEdition && profissional.getEspecialidade().getSetor().trim().equals("e")) {
										out.print("selected=\"selected\"");
									}%>>Estética</option>
									
								<option value="n" <%if (isEdition && profissional.getEspecialidade().getSetor().trim().equals("n")) {
										out.print("selected=\"selected\"");
									}%>>Ensino</option>						
								<option value="p"
									<%if (isEdition && profissional.getEspecialidade().getSetor().trim().equals("p")) {
										out.print("selected=\"selected\"");
									}%>>Prest. de Serviços</option>						
								<option value="j" 
									<%if (isEdition && profissional.getEspecialidade().getSetor().trim().equals("j")) {
										out.print("selected=\"selected\"");
									}%> >Jurídica</option>						
								<option value="u"
									<%if (isEdition && profissional.getEspecialidade().getSetor().trim().equals("u")) {
										out.print("selected=\"selected\"");
									}%>>Automobilistica</option>
								<option value="c" 
									<%if (isEdition && profissional.getEspecialidade().getSetor().trim().equals("c")) {
										out.print("selected=\"selected\"");
									}%>>Construção Cívil</option>
							</select>
						</div>
						<div id="especialidade" class="textBox" style="width: 130px">
							<label>Setor</label><br/>
							<select type="select-multiple" id="especialidadeIn" name="especialidadeIn" onchange="setChange('u')" >
								<option value="">Selecione</option>
								<%for(Especialidade esp: especialidade) {
									if (isEdition && profissional.getEspecialidade().equals(esp)) {
										out.print("<option value=\"" + esp.getCodigo() + 
												"\" selected=\"selected\">" + esp.getDescricao() + "</option>");
									} else {
										out.print("<option value=\"" + esp.getCodigo() + 
												"\">" + esp.getDescricao() + "</option>");
									}
								}								
								%>								
							</select>
						</div>
						<div id="cadastro" class="textBox" style="width: 73px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" type="text" class="required" value="<%=(isEdition)? Util.parseDate(profissional.getCadastro(), "dd/MM/yyyy") : "" %>" <%if(isEdition
									&& (!request.getSession().getAttribute("perfil").equals("a"))
									&& (!request.getSession().getAttribute("perfil").equals("d"))) {%> "readonly="readonly" <%}%> style="width: 73px;" value="<%=(isEdition)? Util.parseDate(profissional.getCadastro(), "dd/MM/yyyy") : "" %>" <%if(!isEdition) {%> onkeydown="mask(this, dateType);" <%}%>/>
						</div>
						<div class="textBox" style="width: 65px">
							<label>Pag.</label><br/>
							<select id="vencimento" name="vencimento" onchange="setChange('u')">
								<%if (isEdition) {%>
									<option value="01" <%if (profissional.getVencimento().trim().equals("01")) { out.print("selected=\"selected\""); }%>>Dia 01</option>
									<option value="05" <%if (profissional.getVencimento().trim().equals("05")) { out.print("selected=\"selected\""); }%>>Dia 05</option>
									<option value="10" <%if (profissional.getVencimento().trim().equals("10")) { out.print("selected=\"selected\""); }%>>Dia 10</option>
									<option value="15" <%if (profissional.getVencimento().trim().equals("15")) { out.print("selected=\"selected\""); }%>>Dia 15</option>
									<option value="20" <%if (profissional.getVencimento().trim().equals("20")) { out.print("selected=\"selected\""); }%>>Dia 20</option>
									<option value="25" <%if (profissional.getVencimento().trim().equals("25")) { out.print("selected=\"selected\""); }%>>Dia 25</option>																		
								<%} else {%>
									<option value="01">Dia 01</option>
									<option value="05">Dia 05</option>
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
									<input id="ativoChecked" name="ativoChecked" onchange="setChange('u')" type="radio"  <%if (profissional.getAtivo().equals("a")){ out.print(" checked=\"checked\""); }%> value="a" />									
								<label class="labelCheck" >Bloqueado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" onchange="setChange('u')" <%if (profissional.getAtivo().equals("b")) { out.print("checked=\"checked\""); }%> value="b" />
								<label class="labelCheck" >Cancelado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" onchange="setChange('u')" <%if (profissional.getAtivo().equals("c")) { out.print("checked=\"checked\""); }%> value="c" />
								<%} else {%>
									<input id="ativoChecked" name="ativoChecked" onchange="setChange('u')" type="radio"  checked="checked" value="a" />
									<label class="labelCheck" >Bloqueado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" onchange="setChange('u')"  value="b" />
									<label class="labelCheck" >Cancelado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" onchange="setChange('u')" value="c" />
								<%}%>
							</div>
						</div>
					</div>
				</div>
				<%if (isEdition) {%>
					<div class="topButtonContent">
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Cadastro" onclick="imprimeCadastro()" />
						</div>						
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Doc. Digital" onclick="loadDocDigital()" />
						</div>
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Upload" onclick="showUploadWd()" />
						</div>
					</div>
				<%}%>
				<div id="mainContent">
					<div id="dadosPessoais" class="bigBox" >
						<div class="indexTitle">
							<h4>Dados Pessoais</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div id="fot" class="textBox" style="width: 103px; height: 137px">
							<img src="<%=(isEdition && foto != null)? foto: "../image/foto.gif" %>" width="103" height="137"/>
						</div>
						
						<div id="nome" class="textBox" style="width: 391px;">
							<label>Nome</label><br/>
							<input id="nomeIn" name="nomeIn" type="text" style="width: 391px;" value="<%=(isEdition)? Util.initCap(profissional.getNome()): "" %>" class="required" enable="false" onchange="setChange('u')" onblur="genericValid(this);" />
						</div>
						<div id="conselho" class="textBox" style="width: 135px;">
							<label>Nro. Conselho</label><br/>
							<input id="conselhoIn" name="conselhoIn" type="text" <%if (isEdition
									&& (!request.getSession().getAttribute("perfil").equals("a"))
									&& (!request.getSession().getAttribute("perfil").equals("d"))) out.print("readonly=\"readonly\"");%> style="width: 128px;" value="<%=(isEdition)? profissional.getConselho() : "" %>" onchange="setChange('u')" class="required" onblur="genericValid(this);" />
						</div>
						<div class="textBox" class="textBox" style="width: 200px;">
							<label>Sexo</label><br />
							<div class="checkRadio" >
								<label>Masculino</label><%
								if (isEdition) {%>
									<input id="sexo" name="sexo" type="radio" <%if (profissional.getSexo().equals("m")) { out.print("checked=\"checked\""); }%> value="m" />
									<label>Feminino</label>
									<input id="sexo" name="sexo" type="radio" <%if (profissional.getSexo().equals("f")) { out.print("checked=\"checked\""); }%> value="f" onchange="setChange('u')"/>
								<%} else {%>
									<input id="sexo" name="sexo" type="radio" checked="checked" value="m" onchange="setChange('u')"/>
									<label>Feminino</label>
									<input id="sexo" name="sexo" type="radio" value="f" onchange="setChange('u')"/>
								<%}%>
							</div>
						</div>
						<div id="cpf" class="textBox" style="width: 105px;">
							<label>Cpf</label><br/>
							<input id="cpfIn" name="cpfIn" type="text" style="width: 100px" value="<%=(isEdition)? Util.mountCpf(profissional.getCpf()): "" %>" class="required" onchange="setChange('u')" onkeydown="mask(this, cpf);" onblur="cpfValidation(this)" />
						</div>
						<div id="rg" class="textBox" style="width: 90px">
							<label>Rg</label><br/>
							<input id="rgIn" name="rgIn" type="text" style="width: 90px" value="<%=(isEdition)? profissional.getRg(): "" %>" onchange="setChange('u')"/>
						</div>
						<div id="nascimento" class="textBox" style="width: 73px;">
							<label>Nascimento</label><br/>
							<input id="nascimentoIn" name="nascimentoIn" type="text" style="width: 73px;" value="<%=(isEdition)? Util.parseDate(profissional.getNascimento(), "dd/MM/yyyy") : "" %>" onkeydown="mask(this, typeDate);"/>
						</div>
						<div class="textBox" style="width: 90px">
							<label>Estado Cívil</label><br/>
							<select id="estadoCivilIn" name="estadoCivilIn" onchange="setChange('u')"><%
								if (isEdition) {
									switch (profissional.getEstadoCivil().charAt(0)) {
									case 'c':
										out.print("<option value=\"c\">Casado(a)</option>");
										break;
									case 's':
										out.print("<option value=\"s\">Solteiro(a)</option>");
										break;
									case 'o':
										out.print("<option value=\"o\">Outro</option>");
										break;
									}
								} else {%>								
									<option>Selecione</option>
									<option value="c">Casado(a)</option>
									<option value="s">Solteiro(a)</option>
									<option value="o">Outro</option>
								<%}%>
							</select>
						</div>
						<div id="nacionalidade" class="textBox" style="width:332px">
							<label>Nacionalidade</label><br/>
							<input id="nacionalidadeIn" name="nacionalidadeIn" type="text" style="width:332px" value="<%=(isEdition)? Util.initCap(profissional.getNacionalidade()): "Brasileira" %>" class="required" onchange="setChange('u')" onblur="genericValid(this)"/>
						</div>
						<div id="naturalidade" class="textBox" style="width:258px;">
							<label>Naturalidade</label><br/>
							<input id="naturalidadeIn" name="naturalidadeIn" type="text" style="width:258px" value="<%=(isEdition)? Util.initCap(profissional.getNaturalidade()): "" %>" class="required" onchange="setChange('u')" onblur="genericValid(this)" />
						</div>
						<div id="naturalUf" class="textBox" style="width: 45px">
							<label>Uf</label><br/>
							<select type="select-multiple" id="naturalUfIn" name="naturalUfIn" onchange="setChange('u')" >
								<%for(String uf: uf2005) {
									if (isEdition && profissional.getNaturalidadeUf().trim().equals(uf.toLowerCase())) {
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
						<div class="buttonContent" >
							<div class="formGreenButton">
								<input id="fotoLoad" name="fotoLoad" class="greenButtonStyle" type="button" value="Editar Foto" onclick="loadFile()"/>
							</div>
						</div>						
					<%}%>					
					<div id="endereco" class="bigBox">
						<div class="indexTitle">
							<h4>Endereço</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div id="cep" class="textBox" style="width: 73px">
							<label>CEP</label><br/>
							<input id="cepIn" name="cepIn" type="text" style="width: 73px" value="<%=(isEdition && !endereco.getCep().trim().isEmpty())? Util.mountCep(endereco.getCep()): "" %>" onchange="setChange('e')" onkeydown="mask(this, cep);" />
						</div>
						<div id="rua" class="textBox" style="width: 230px">
							<label>Endereço</label><br/>
							<input id="ruaIn" name="ruaIn" type="text" style="width: 230px" value="<%=(isEdition)? Util.initCap(endereco.getRuaAv()): "" %>" class="required" onchange="setChange('e')" onblur="genericValid(this)" />
						</div>
						<div id="numero" class="textBox" style="width: 50px">
							<label>Numero</label><br/>
							<input id="numeroIn" name="numeroIn" type="text" style="width: 50px" value="<%=(isEdition)? endereco.getNumero(): "" %>" onchange="setChange('e')" />
						</div>
						<div id="complemento" class="textBox" style="width: 250px">
							<label>Complemento</label><br/>
							<input id="complementoIn" name="complementoIn" type="text" style="width: 250px" value="<%=(isEdition)? endereco.getComplemento(): "" %>" onchange="setChange('e')" />
						</div>
						<div id="bairro" class="textBox" style="width: 225px">
							<label>Bairro</label><br/>
							<input id="bairroIn" name="bairroIn" type="text" style="width: 225px" value="<%=(isEdition)? Util.initCap(endereco.getBairro()): "" %>" onchange="setChange('e')" />
						</div>
						<div id="cidade" class="textBox" style="width: 220px">
							<label>Cidade</label><br/>
							<input id="cidadeIn" name="cidadeIn" type="text" style="width: 220px" value="<%=(isEdition)? Util.initCap(endereco.getCidade()): "" %>" class="required" onchange="setChange('e')" onblur="genericValid(this)" />
						</div>
						<div id="uf" class="textBox">
							<label>Uf</label><br/>
							<select type="select-multiple" id="ufIn" name="ufIn" onchange="setChange('e')" >
								<%for(String uf: uf2005) {
									if (isEdition && endereco.getUf().trim().equals(uf.toLowerCase())) {
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
					<div id="conta" class="bigBox">
						<div class="indexTitle">
							<h4>Conta Corrente</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div><input id="edAcount" name="edAcount" type="hidden" value="<%=(isEdition)? "on": "off" %>" /></div>
						<div class="textBox" style="width: 215px">
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
							<input id="agenciaIn" name="agenciaIn" type="text" style="width: 50px" onchange="setChange('c')" />
						</div>
						<div id="numeroConta" class="textBox" style="width: 100px">
							<label>Numero</label><br/>					
							<input id="numeroContaIn" name="numero" type="text" style="width: 100px" onchange="setChange('c')" />
						</div>
						<div id="titularConta" class="textBox" style="width: 300px">
							<label>Titular</label><br/>					
							<input id="titularContaIn" name="titularContaIn" type="text" style="width: 300px" onchange="setChange('c')" />
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
					<div id="contato" class="bigBox" style="bottom: 30px !important" >
						<div class="indexTitle">
							<h4>Informações de Contato</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div><input id="edInfo" name="edInfo" type="hidden" value="<%=(isEdition)? "on": "off" %>" /></div>												
						<div class="textBox" style="width: 130px">
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
						<div id="descricao" class="textBox" style="width:300px;" >
							<label>Descrição</label><br/>					
							<input id="descricaoIn" name="descricao" type="text" style="width:300px;" onkeydown="comboMask(this, 'tipoContato')" onchange="setChange('i')" />						
						</div>
						<div class="textBox" id="principal">
							<label>Principal</label><br/>
							<select id="principalIn" name="principalIn" onchange="setChange('i')" >								
								<option value="Sim">Sim</option>
								<option value="Não" selected="selected">Não</option>
							</select>
						</div>
						<div id="tableContact" style="margin-right: 68px"></div>					
					</div>
				</div>
				<div class="buttonContent" >					
					<div class="formGreenButton">
						<input name="removeContact" class="greenButtonStyle" type="button" value="Excluir" onclick="removeRowContact()" />
					</div>				
					<div class="formGreenButton" >
						<input id="specialButton" name="insertDependente" class="greenButtonStyle" type="button" value="Inserir" onclick="addRowContact()" />
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
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>	
	</div>
</body>
</html>