<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.database.Profissional"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<jsp:useBean id="profissional" class="com.marcsoftware.database.Profissional"></jsp:useBean>
	
	<%boolean haveAccsess = false;
	boolean liberacao = false;
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
	profissional= (Profissional) sess.get(Profissional.class, Long.valueOf(request.getParameter("id")));
	String atividade = "";
	switch (profissional.getEspecialidade().getSetor().charAt(0)) {
		case 'o':
			atividade = "Odontologica";
			break;
			
		case 'l':
			atividade = "Laboratorial";
			break;
			
		case 'm':
			atividade = "Médica";
			break;
			
		case 'h':
			atividade = "Hospitalar";
			break;
		
		case 'a':
			atividade = "Administrativa";
			break;
			
		case 'e':
			atividade = "Estética";
			break;
		
	}
	if (profissional.getLogin() == null) {
		haveAccsess = false;
	} else {
		query = sess.createQuery("from CartaoAcesso as c where c.login = :login");
		query.setEntity("login", profissional.getLogin());
		haveAccsess = query.list().size() > 0;
	}
	if (haveAccsess) {
		query = sess.createQuery("from CartaoAcesso as c where c.login = :login and c.status = 'a'");
		query.setEntity("login", profissional.getLogin());
		liberacao = query.list().size() > 0;
	}
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Anexo Profissional</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>	
	<script type="text/javascript" src="../js/lib/mask.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/comum/anexo_profissional.js"></script>	
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
</head>
<body>
	<div id="obsWindow" class="removeBorda" title="Edição de observação" style="display: none;">
		<form id="formObs" onsubmit="return false;">
			<fieldset>
				<label for="obsw">Observações</label>
				<textarea name="obsw" id="obsw" rows="30" cols="60" class="textDialog ui-widget-content ui-corner-all"><%=(profissional.getObservacao() != null)? profissional.getObservacao() : "" %></textarea>
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp"%>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="profissional"/>
	</jsp:include>
	<div id="centerAll" >
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="profissional"/>
		</jsp:include>
		<div id="formStyle">		
			<form id="formPost" method="post" action="../CadastroFuncionario" onsubmit= "return validForm(this)" >
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Anexo"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="cadastro_profissional.jsp?state=1&id=<%= profissional.getCodigo()%>">Cadastro</a>
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
					<div class="topContent">
						<div id="registro" class="textBox" style="width: 70px;">
							<label>Referência</label><br/>						
							<input id="registroIn" name="registroIn" type="text" style="width: 70px;" value="<%=String.valueOf(profissional.getCodigo())%>"  readonly="readonly" />
						</div>
						<div id="nome" class="textBox" style="width: 245px;">
							<label>Nome</label><br/>
							<input id="nomeIn" name="nomeIn" type="text" style="width: 245px;" value="<%=Util.initCap(profissional.getNome()) %>"  readonly="readonly"/>
						</div>
						<div id="sexo" class="textBox" style="width: 70px;">
							<label>Sexo</label><br/>						
							<input id="sexoIn" name="sexoIn" type="text" style="width: 70px;" value="<%=(profissional.getSexo().equals("f")) ? "Feminino" : "Masculino"%>"  readonly="readonly" />
						</div>
						<div id="cpf" class="textBox" style="width: 100px">
							<label>Cpf</label><br/>
							<input id="cpfIn" name="cpfIn" type="text" style="width: 100px" value="<%=Util.mountCpf(profissional.getCpf())%>"  readonly="readonly" />
						</div>
						<div id="rg" class="textBox" style="width: 100px">
							<label>Rg</label><br/>
							<input id="rgIn" name="rgIn" type="text" style="width: 100px" value="<%=(!profissional.getRg().trim().isEmpty())? profissional.getRg() : ""%>" readonly="readonly"/>
						</div>
						<div id="conselho" class="textBox" style="width: 100px">
							<label>Conselho</label><br/>
							<input id="conselhoIn" name="conselhoIn" type="text" style="width: 100px" value="<%=profissional.getConselho()%>" readonly="readonly" />
						</div>
						<div id="setor" class="textBox" style="width: 100px">
							<label>Atividade</label><br/>
							<input id="setorIn" name="setorIn" type="text" style="width: 100px" value="<%= atividade %>" readonly="readonly" />
						</div>
						<div id="especialidade" class="textBox" style="width:200px">
							<label>Especialidade</label><br/>
							<input id="especialidadeIn" name="especialidadeIn" type="text" style="width:200px" value="<%=profissional.getEspecialidade().getDescricao()%>" readonly="readonly"/>
						</div>
					</div>
				</div>
				<div id="mainContent">
					<%if (session.getAttribute("perfil").equals("a")
							|| session.getAttribute("perfil").equals("f")) {%>
						<div id="acesso" class="bigBox" >
							<div class="indexTitle">
								<h4>Acessibilidade</h4>
								<div class="alignLine">
									<hr>
								</div>
							</div>
							<%if (profissional.getLogin() == null) {%>
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
									<input id="loginIn" name="loginIn" type="text" style="width: 200px" value="<%= profissional.getLogin().getUsername()%>"/>
								</div>
								<div id="senha" class="textBox"style="width: 200px">
									<label>Senha</label><br/>					
									<input id="senhaIn" name="senhaIn" type="password" style="width: 200px" readonly="readonly" value="<%= profissional.getLogin().getUsername() + profissional.getLogin().getPorta()%>"/>
								</div>
								<div id="senhaConfirm" class="textBox"style="width: 200px">
									<label>Confirmar Senha</label><br/>					
									<input id="senhaConfirmIn" name="senhaConfirmIn" type="password" class="required" style="width: 200px" readonly="readonly" value="<%= profissional.getLogin().getUsername() + profissional.getLogin().getPorta()%>" />
								</div>							
							<%}%>
							<div id="status" class="textBox gridRow" style="width: 300px; border: none;">
								<span>Status</span><br/>
								<label ><% if (!haveAccsess) {
									out.print("Sem Cartão de autorização");   
								} else if (liberacao) {
									out.print("Login autorizado");
								} else {
									out.print("Cartão não Autorizado");
								}%></label>
							</div>
						</div>
						<div class="buttonContent" >
							<%if (profissional.getLogin() == null) {%>
								<div class="formGreenButton"  >
									<input name="confirmSenha" id="confirmSenha" class="greenButtonStyle" type="button" value="Salvar" onclick="novoLogin();" />
								</div>
							<%} else {%>
								<div class="formGreenButton"  >
									<input name="confirmSenha" id="confirmSenha" class="grayButtonStyle" type="button" value="Salvar" onclick="salvarSenha(this);" />
								</div>
								<div class="formGreenButton">
									<input name="editSenha" id="editSenha" class="greenButtonStyle" type="button" value="Editar Senha" onclick="editarSenha(this)" />
								</div>					
								<%if (!haveAccsess) {%>
									<div class="formGreenButton">
										<input name="createNew" id="createNew" class="greenButtonStyle" type="button" value="Gerar Acesso" onclick="generateAccess(this)" />
									</div>						
								<%} else if (liberacao) {%>
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
							<%}%>
						</div>
							
							
					<%}%>
					
					<div class="bigBox" >
						<div class="indexTitle">
							<h4>Configuração de Porta</h4>
							<div class="alignLine">
								<hr>
							</div>
							<div id="porta" class="textBox" style="width:150px">
								<label>Porta</label><br/>								
								<input id="portaIn" name="portaIn" type="text" style="width:150px" value="<%=(profissional.getLogin() == null)? "" : profissional.getLogin().getPorta()%>" readonly="readonly"/>
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
								<textarea cols="112" rows="5" id="obsIn" name="obsIn" readonly="readonly" ><%=(profissional.getObservacao() != null)? profissional.getObservacao() : "" %></textarea>							
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
		<%sess.close();%>
	</div>
</body>
</html>