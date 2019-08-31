<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@page import="java.util.ArrayList"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="java.util.List" %>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.database.Funcionario"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<jsp:useBean id="funcionario" class="com.marcsoftware.database.Funcionario"></jsp:useBean>
	<%boolean haveAccsess = false;
	boolean liberacao = false;
	int disponivel = 0;
	Query query;
	List<Unidade> unidades = new ArrayList<Unidade>();
	
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	funcionario = (Funcionario) sess.get(Funcionario.class, Long.valueOf(request.getParameter("id")));
	if (funcionario.getLogin() == null) {
		haveAccsess = false;
	} else {
		query = sess.createQuery("from CartaoAcesso as c where c.login = :login");
		query.setEntity("login", funcionario.getLogin());
		haveAccsess = query.list().size() > 0;
	}
	if (haveAccsess) {
		query = sess.createQuery("from CartaoAcesso as c where c.login = :login and c.status = 'a'");
		query.setEntity("login", funcionario.getLogin());
		disponivel = query.list().size();		
		liberacao = disponivel > 0;
	} else {
		query = sess.createQuery("from Unidade u where u.administrador is null");
		unidades = (List<Unidade>) query.list();
	}
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Anexo RH</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>	
	<script type="text/javascript" src="../js/lib/mask.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/comum/anexo_rh.js"></script>	
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
</head>
<body>
	<div id="obsWindow" class="removeBorda" title="Edição de observação" style="display: none;">
		<form id="formObs" onsubmit="return false;">
			<fieldset>
				<label for="obsw">Observações</label>
				<textarea name="obsw" id="obsw" rows="30" cols="60" class="textDialog ui-widget-content ui-corner-all"><%=(funcionario.getObservacao() != null)? funcionario.getObservacao() : "" %></textarea>
			</fieldset>
		</form>
	</div>
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
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Anexo"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="cadastro_funcionario.jsp?state=1&id=<%= funcionario.getCodigo()%>">Cadastro</a>
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
					<div class="topContent">
						<div id="registro" class="textBox" style="width: 70px;">
							<label>Referência</label><br/>						
							<input id="registroIn" name="registroIn" type="text" style="width: 70px;" value="<%=String.valueOf(funcionario.getCodigo())%>"  readonly="readonly" />
						</div>
						<div id="nome" class="textBox" style="width: 245px;">
							<label>Nome</label><br/>
							<input id="nomeIn" name="nomeIn" type="text" style="width: 245px;" value="<%=Util.initCap(funcionario.getNome()) %>"  readonly="readonly"/>
						</div>
						<div id="sexo" class="textBox" style="width: 70px;">
							<label>Sexo</label><br/>						
							<input id="sexoIn" name="sexoIn" type="text" style="width: 70px;" value="<%=(funcionario.getSexo().equals("f")) ? "Feminino" : "Masculino"%>"  readonly="readonly" />
						</div>
						<div id="cpf" class="textBox" style="width: 100px">
							<label>Cpf</label><br/>
							<input id="cpfIn" name="cpfIn" type="text" style="width: 100px" value="<%=Util.mountCpf(funcionario.getCpf())%>"  readonly="readonly" />
						</div>
						<div id="rg" class="textBox" style="width: 100px">
							<label>Rg</label><br/>
							<input id="rgIn" name="rgIn" type="text" style="width: 100px" value="<%=(!funcionario.getRg().trim().isEmpty())? funcionario.getRg() : ""%>" readonly="readonly"/>
						</div>
						<div id="cnh" class="textBox" style="width: 100px">
							<label>Cnh</label><br/>
							<input id="cnhIn" name="cnhIn" type="text" style="width: 100px" value="<%=funcionario.getCnh()%>" readonly="readonly" />
						</div>
						<div id="ctps" class="textBox" style="width: 100px">
							<label>CTPS</label><br/>
							<input id="ctpsIn" name="ctpsIn" type="text" style="width: 100px" value="<%=funcionario.getCtps()%>" readonly="readonly" />
						</div>
						<div id="nascimento" class="textBox" style="width:75px">
							<label>Nascimento</label><br/>
							<input id="nascimentoIn" name="nascimentoIn" type="text" style="width:75px" value="<%=Util.parseDate(funcionario.getNascimento(), "dd/MM/yyyy")%>" readonly="readonly"/>
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
							<%if (funcionario.getLogin() == null) {%>
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
									<input id="loginIn" name="loginIn" type="text" style="width: 200px" value="<%= funcionario.getLogin().getUsername()%>"/>
								</div>
								<div id="senha" class="textBox"style="width: 200px">
									<label>Senha</label><br/>					
									<input id="senhaIn" name="senhaIn" type="password" style="width: 200px" readonly="readonly" value="<%= funcionario.getLogin().getUsername() + funcionario.getLogin().getPorta()%>"/>
								</div>
								<div id="senhaConfirm" class="textBox"style="width: 200px">
									<label>Confirmar Senha</label><br/>					
									<input id="senhaConfirmIn" name="senhaConfirmIn" type="password" class="required" style="width: 200px" readonly="readonly" value="<%= funcionario.getLogin().getUsername() + funcionario.getLogin().getPorta()%>" />
								</div>
							<%}%>
							<%if (!haveAccsess && session.getAttribute("perfil").toString().trim().equals("a") && funcionario.getLogin() == null) { %>
								<div id="adm" class="textBox gridRow" style="width: 92px; border: none;">
									<span>Administrador</span><br/>
									<select id="isAdm" name="isAdm" style="width: 90px">
										<option value="false">Não</option>
										<option value="true">Sim</option>
									</select>
								</div>
								
								<div id="unidades" class="textBox gridRow" style="width: 92px; border: none;">
									<span>Unidades</span><br/>
									<select id="idUnidade" name="idUnidade" style="width: 166px">
										<%for (Unidade unidade: unidades) {%>
											<option value="<%= unidade.getCodigo()%>"><%= unidade.getReferencia() %> - <%= unidade.getDescricao() %></option>										
										<%}%>
									</select>
								</div>
								
								
							<% } %>
							
							<div id="status" class="textBox gridRow" style="width: 300px; border: none;">
								<span>Status</span><br/>
								<label ><% if (!haveAccsess) {
									out.print("Sem Cartão de autorização");   
								} else if (liberacao) {
									out.print("Login autorizado - " + disponivel + " Acessos disponíveis");
								} else {
									out.print("Cartão não Autorizado");
								}%></label>
							</div>
						</div>
						<div class="buttonContent" >
							<%if (funcionario.getLogin() == null) {%>
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
								<%if (!haveAccsess) {%>
									<div class="formGreenButton">
										<input name="createNew" id="createNew" class="greenButtonStyle" type="button" value="Gerar Acesso" onclick="generateAccess(this)" />
									</div>						
								<%} else if (liberacao) {%>
									<div class="formGreenButton">
										<input class="greenButtonStyle" type="button" value="Bloq. Acesso" onclick="BloquearCartao(this)" />
									</div>
									<div class="formGreenButton">
										<input class="greenButtonStyle" type="button" value="Excluir Acesso" onclick="delCartao(this)" />
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
							<h4>Configuração da Impressora de Cupoms</h4>
							<div class="alignLine">
								<hr>
							</div>
							<div id="porta" class="textBox" style="width:150px">
								<label>Porta</label><br/>
								<input id="portaIn" name="portaIn" type="text" style="width:150px" value="<%=(funcionario.getLogin() == null || funcionario.getLogin().getPorta() == null)? "" : funcionario.getLogin().getPorta()%>" readonly="readonly"/>
							</div>
							<div id="colunas" class="textBox" style="width:50px">
								<label>Colunas</label><br/>
								<input id="colunasIn" name="colunasIn" type="text" style="width:50px" value="<%=(funcionario.getLogin() == null || funcionario.getLogin().getColunas() == null)? "" : funcionario.getLogin().getColunas()%>" readonly="readonly"/>
							</div>
							<div id="headerCupom" class="textBox" style="width:333px">
								<label>Cabeçalho Cupom Linha 1</label><br/>
								<input id="headerCupomIn" name="headerCupomIn" type="text" style="width:333px" value="<%=(funcionario.getLogin() == null || funcionario.getLogin().getHeaderCupom() == null)? "" : funcionario.getLogin().getHeaderCupom()%>" readonly="readonly"/>
							</div>
							<div id="subHeader" class="textBox" style="width:333px">
								<label>Cabeçalho Cupom Linha 2</label><br/>
								<input id="subHeaderIn" name="subHeaderIn" type="text" style="width:333px" value="<%=(funcionario.getLogin() == null ||  funcionario.getLogin().getSubHeader() == null)? "" : funcionario.getLogin().getSubHeader()%>" readonly="readonly"/>
							</div>
							<div id="footerCupom" class="textBox" style="width:333px">
								<label>Rodapé Linha 1</label><br/>
								<input id="footerCupomIn" name="footerCupomIn" type="text" style="width:333px" value="<%=(funcionario.getLogin() == null || funcionario.getLogin().getFooterCupom() == null)? "" : funcionario.getLogin().getFooterCupom()%>" readonly="readonly"/>
							</div>
							<div id="subFooter" class="textBox" style="width:300px">
								<label>Rodapé Linha 2</label><br/>
								<input id="subFooterIn" name="subFooterIn" type="text" style="width:300px" value="<%=(funcionario.getLogin() == null ||  funcionario.getLogin().getSubFooter() == null)? "" : funcionario.getLogin().getSubFooter()%>" readonly="readonly"/>
							</div>							
						</div>
					</div>
					<div class="buttonContent" >
						<div class="formGreenButton"  >
							<input name="salvePort" id="salvePort" class="grayButtonStyle" type="button" value="Salvar" onclick="salvarPorta(this);" />
						</div>
						<div class="formGreenButton">
							<input name="editPort" id="editPort" class="greenButtonStyle" type="button" value="Editar" onclick="editarPorta(this)" />
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
								<textarea cols="112" rows="5" id="obsIn" name="obsIn" readonly="readonly" ><%=(funcionario.getObservacao() != null)? funcionario.getObservacao() : "" %></textarea>							
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