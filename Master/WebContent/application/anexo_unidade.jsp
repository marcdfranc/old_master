<%@page import="com.marcsoftware.database.Fisica"%>
<%@page import="com.marcsoftware.database.Login"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Session"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Anexo Unidade</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>	
	<script type="text/javascript" src="../js/lib/mask.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/comum/anexo_unidade.js"></script>	
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
</head>
<body>
<%
	Session sess = HibernateUtil.getSession();
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Unidade unidade = (Unidade) sess.get(Unidade.class, Long.valueOf(request.getParameter("id")));
	
	Query query = sess.createQuery("from Login as l where l = :login");
	Login login = null;
	if (unidade.getAdministrador().getLogin() != null) {
		query.setEntity("login", unidade.getAdministrador().getLogin());
		login = (Login) query.uniqueResult();
	} else {
		query = sess.createQuery("from Login as l where username = :usr" );
		query.setString("usr", "automático");
		login = (Login) query.uniqueResult();
	}
	query = sess.createQuery("from Fisica as f where f.login.perfil = 'f' ");
	
	List<Fisica> usuariosTrocar = (List<Fisica>) query.list();
		
	boolean haveLogo = false;
	boolean haveLogoReport = false;
	boolean haveLogoCarteirinha = false;
	boolean haveAccess = false;
	boolean isLliberacao = false;
	String logoHeader, logoReport, logoCarteirinha;
	logoHeader = logoReport = logoCarteirinha = "";
	logoReport = unidade.getThumbReport();
	if (unidade.getLogo() != null && !unidade.getLogo().isEmpty()) {
		haveLogo = true;		
		logoHeader = unidade.getThumb();
	}
	if (unidade.getReportLogo() != null && (!unidade.getReportLogo().isEmpty())) {
		haveLogoReport = true;
		logoReport = unidade.getThumbReport();
	}
	/* if (unidade.getLogoCarteirinha() != null && (!unidade.getLogoCarteirinha().isEmpty())) {
		haveLogoCarteirinha = true;
		logoCarteirinha = unidade.getThumbCarteirinha();
	} */
	
	if (unidade.getAdministrador() == null) {
		haveAccess = false;
	} else {
		query = sess.createQuery("from CartaoAcesso as c where c.login = :login");
		query.setEntity("login", login);
		haveAccess = query.list().size() > 0;
	}
	if (haveAccess) {
		query = sess.createQuery("from CartaoAcesso as c where c.login = :login and c.status = 'a'");
		query.setEntity("login", login);
		isLliberacao = query.list().size() > 0;
	}
	
	%>
	<div id="obsWindow" class="removeBorda" title="Edição de observação" style="display: none;">
		<form id="formObs" onsubmit="return false;">
			<fieldset>
				<label for="obsw">Observações</label>
				<textarea name="obsw" id="obsw" rows="30" cols="60" class="textDialog ui-widget-content ui-corner-all"><%= (unidade.getObservacao() == null)? "" : unidade.getObservacao() %></textarea>
			</fieldset>
		</form>
	</div>
	
	<div id="trocaWindow" class="removeBorda" title="Edição de observação" style="display: none;">
		<form id="formTroca" onsubmit="return false;">
			<label for="usuarioTroca">Selecione o usuario</label>
			<select id="usuarioTroca" name="usuarioTroca">
				<%for(Fisica adm: usuariosTrocar) {
					out.print("<option value=\"" + adm.getLogin().getUsername() + 
						"\">" + adm.getLogin().getUsername() + " - " + Util.initCap(adm.getNome())+
						"</option>");	
				}%>
			</select>
			
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
			<form id="formPost" method="post" action="../CadastroFuncionario" onsubmit= "return validForm(this)" >
				<input type="hidden" id="unidadeId" name="unidadeId" value="<%= unidade.getCodigo() %>" />				
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Anexo"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="<%= "cadastro_unidade.jsp?state=1&id=" + unidade.getCodigo() %>">Cadastro</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Anexo</label>
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
					<div class="topContent">
						<div id="registro" class="textBox" style="width: 70px;">
							<label>Referência</label><br/>						
							<input id="registroIn" name="registroIn" type="text" style="width: 70px;" value="<%=unidade.getReferencia()%>"  readonly="readonly" />
						</div>
						<div id="rzSocial" class="textBox" style="width: 245px;">
							<label>Razão Social</label><br/>
							<input id="rzSocialIn" name="rzSocialIn" type="text" style="width: 245px;" value="<%=Util.initCap(unidade.getRazaoSocial()) %>"  readonly="readonly"/>
						</div>
						<div id="descricao" class="textBox" style="width: 245px;">
							<label>Descrição</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 245px;" value="<%=Util.initCap(unidade.getDescricao()) %>"  readonly="readonly"/>
						</div>
						<div id="cnpj" class="textBox" style="width: 120px">
							<label>Cnpj</label><br/>
							<input id="cnpjIn" name="cnpjIn" type="text" style="width: 120px" value="<%=Util.mountCnpj(unidade.getCnpj())%>"  readonly="readonly" />
						</div>
						<div id="cadastro" class="textBox" style="width:75px">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" type="text" style="width:75px" value="<%=Util.parseDate(unidade.getCadastro(), "dd/MM/yyyy")%>" readonly="readonly"/>
						</div>
					</div>
				</div>
				<div id="mainContent">
					<div id="acesso" class="bigBox" >
						<div class="indexTitle">
							<h4>Acessibilidade</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<%if (login == null) {%>
							<div id="login" class="textBox"style="width: 200px">
								<label>Login</label><br/>
								<input id="loginIn" name="loginIn" type="text" style="width: 200px" />
							</div>
							<div id="senha" class="textBox"style="width: 200px">
								<label>Senha</label><br/>					
								<input id="senhaIn" name="senhaIn" type="password" style="width: 200px" />
							</div>
							<div id="senhaConfirm" class="textBox"style="width: 200px">
								<label>Confirmar Senha</label><br/>					
								<input id="senhaConfirmIn" name="senhaConfirmIn" type="password" style="width: 200px" />
							</div>
						<%} else {%>
							<div id="login" class="textBox"style="width: 200px">
								<label>Login</label><br/>
								<input id="loginIn" name="loginIn" readonly="readonly" type="text" style="width: 200px" value="<%= login.getUsername()%>"/>
							</div>
							<div id="senha" class="textBox"style="width: 200px">
								<label>Senha</label><br/>					
								<input id="senhaIn" name="senhaIn" type="password" style="width: 200px" readonly="readonly" value="<%= login.getUsername() + login.getPorta()%>"/>
							</div>
							<div id="senhaConfirm" class="textBox"style="width: 200px">
								<label>Confirmar Senha</label><br/>					
								<input id="senhaConfirmIn" name="senhaConfirmIn" type="password" class="required" style="width: 200px" readonly="readonly" value="<%= login.getUsername() + login.getPorta()%>" />
							</div>
						<%}%>
						<div id="status" class="textBox gridRow" style="width: 300px; border: none;">
							<span>Status</span><br/>
							<label ><% if (!haveAccess) {
								out.print("Sem Cartão de autorização");   
							} else if (isLliberacao) {
								out.print("Login autorizado");
							} else {
								out.print("Cartão não Autorizado");
							}%></label>
						</div>
					</div>
					<div class="buttonContent" >
						<%if (login == null) {%>
							<div class="formGreenButton"  >
								<input name="confirmSenha" id="confirmSenha" class="greenButtonStyle" type="button" value="Salvar" onclick="salvarSenha(this);" />
							</div>
						<%} else {%>
							<div class="formGreenButton"  >
								<input name="confirmSenha" id="confirmSenha" class="grayButtonStyle" type="button" value="Salvar" onclick="salvarSenha(this);" />
							</div>
							<div class="formGreenButton">
								<input name="editSenha" id="editSenha" class="greenButtonStyle" type="button" value="Editar Senha" onclick="editarSenha(this)" />
							</div>
							<%if (!haveAccess) {%>
								<div class="formGreenButton">
									<input name="createNew" id="createNew" class="greenButtonStyle" type="button" value="Gerar Acesso" onclick="generateAccess(this)" />
								</div>						
							<%} else if (isLliberacao) {%>
								<div class="formGreenButton">
									<input name="blockCrt" id="blockCrt" class="greenButtonStyle" type="button" value="Bloq. Acesso" onclick="BloquearCartao(this)" />
								</div>
								<div class="formGreenButton">
									<input name="delCart" id="delCart" class="greenButtonStyle" type="button" value="Excluir Acesso" onclick="delCartao(this)" />
								</div>
								<div class="formGreenButton">
									<input class="greenButtonStyle" type="button" value="Imp. Cartão" onclick="imprimeCartao()" />
								</div>
							<%} else {%>
								<div class="formGreenButton">
									<input name="liber" id="liber" class="greenButtonStyle" type="button" value="Liberar Acesso" onclick="liberarCartao(this)" />
								</div>
							<%}%>
							<div class="formGreenButton"  >
								<input class="greenButtonStyle" type="button" value="Criar Usuário" onclick="criarUsuario();" />
							</div>
							<div class="formGreenButton"  >
								<input class="greenButtonStyle" type="button" value="Trocar Admin" onclick="trocaAdm();" />
							</div>
						<%}%>
					</div>
					<div class="bigBox" >
						<div class="indexTitle">
							<h4>Upload De logotipos</h4>
							<div class="alignLine">
								<hr>
							</div>
							<div id="foto" class="textBox"style="width: 250px; height: 47px; background-color: white; border: 1px solid #E4E5E6;">
								<%if (haveLogo) {%>
									<img src="<%= logoHeader %>" />
								<%} else {%>
									<label>Logotipo da Tela</label>								
								<%}%>
							</div>
							
							<div id="fotRel" class="textBox"style="width: 250px; height: 47px; background-color: white; border: 1px solid #E4E5E6;">
								<%if (haveLogoReport) {%>
									<img src="<%= logoReport %>" />
								<%} else {%>								
									<label>Logotipo de Relatório</label>
								<%}%>
							</div>
							
							
							<div id="fotRel" class="textBox"style="width: 250px; height: 47px; background-color: white;">
								<%if (unidade.getLogoCarteirinha() != null && !unidade.getLogoCarteirinha().isEmpty()) {%>
									<img src="../report/<%= unidade.getLogoCarteirinha() %>" width="200" />
								<%} else {%>								
									<label>Logotipo de Carteirinha</label>
								<%}%>
							</div>
							<br clear="all">
							<div class="buttonContent" style="margin-top: 15px;" >
								<div class="formGreenButton"  >
									<input class="greenButtonStyle" type="button" value="Carteirinha" onclick="uploadCarteirinha()" />
								</div>
								<div class="formGreenButton">
									<input class="greenButtonStyle" type="button" value="Relatório" onclick="uploadReport()" />
								</div>						
								<div class="formGreenButton"  >
									<input class="greenButtonStyle" type="button" value="Tela" onclick="uploadHeader()" />
								</div>								
							</div>
						</div>
					</div>
					<div class="bigBox" >
						<div class="indexTitle">
							<h4>Configuração da Impressora de Cupoms</h4>
							<div class="alignLine">
								<hr>
							</div>
							<div id="porta" class="textBox" style="width:150px">
								<label>Porta</label><br/>
								<input id="portaIn" name="portaIn" type="text" style="width:150px" value="<%=(login == null || login.getPorta() == null)? "" : login.getPorta() %>" readonly="readonly"/>
							</div>
							<div id="colunas" class="textBox" style="width:50px">
								<label>Colunas</label><br/>
								<input id="colunasIn" name="colunasIn" type="text" style="width:50px" value="<%=(login == null || login.getColunas() == null)? "" : login.getColunas()%>" readonly="readonly"/>
							</div>
							<div id="headerCupom" class="textBox" style="width:333px">
								<label>Cabeçalho Cupom Linha 1</label><br/>
								<input id="headerCupomIn" name="headerCupomIn" type="text" style="width:333px" value="<%=(login == null || login.getHeaderCupom() == null)? "" : login.getHeaderCupom()%>" readonly="readonly"/>
							</div>
							<div id="subHeader" class="textBox" style="width:333px">
								<label>Cabeçalho Cupom Linha 2</label><br/>
								<input id="subHeaderIn" name="subHeaderIn" type="text" style="width:333px" value="<%=(login == null || login.getSubHeader() == null)? "" : login.getSubHeader()%>" readonly="readonly"/>
							</div>
							<div id="footerCupom" class="textBox" style="width:333px">
								<label>Rodapé Linha 1</label><br/>
								<input id="footerCupomIn" name="footerCupomIn" type="text" style="width:333px" value="<%=(login == null || login.getFooterCupom() == null)? "" : login.getFooterCupom()%>" readonly="readonly"/>
							</div>
							<div id="subFooter" class="textBox" style="width:300px">
								<label>Rodapé Linha 2</label><br/>
								<input id="subFooterIn" name="subFooterIn" type="text" style="width:300px" value="<%=(login == null ||  login.getSubFooter() == null)? "" : login.getSubFooter()%>" readonly="readonly"/>
							</div>
						</div>
					</div>
					<div class="buttonContent" >
						<div class="formGreenButton"  >
							<input name="salvePort" id="salvePort" class="grayButtonStyle" type="button" value="Salvar" onclick="salvarPorta(this);" />
						</div>
						<div class="formGreenButton">
							<input name="editPort" id="editPort" class="greenButtonStyle" type="button" value="Editar Porta" onclick="editarPorta(this)" />
						</div>						
					</div>
					<div class="bigBox" >
						<div class="indexTitle">
							<h4>Informações Adicionais</h4>
							<div class="alignLine">
								<hr>
							</div>
							<div class="area" id="obs" name="obs" style="margin-bottom: 30px">
								<label>Observações</label><br/>
								<textarea cols="112" rows="5" id="obsIn" name="obsIn" readonly="readonly" ><%=(unidade.getObservacao() != null)? unidade.getObservacao() : "" %></textarea>							
							</div>
						</div>
					</div>
					<div class="buttonContent" >
						<div class="formGreenButton">
							<input name="editObs" id="editObs" class="greenButtonStyle" type="button" value="Editar Obs" onclick="editarObs(this)" />
						</div>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
	</div>
</body>
</html>