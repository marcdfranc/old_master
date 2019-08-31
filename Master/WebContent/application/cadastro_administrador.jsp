<%@page import="com.marcsoftware.database.Endereco"%>
<%@page import="com.marcsoftware.database.Fisica"%>
<%@page import="com.marcsoftware.database.Informacao"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
	<%!boolean isEdition= false;
	boolean haveAccsess = false;
	boolean liberacao = false;
	%>
	<%isEdition = (request.getParameter("state") != null)? true : false;
	
	int disponivel = 0;
	
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}
	List<Unidade> unidades = null;
	List<Unidade> unidadeFisica = null;
	List<Informacao> infoFisica = null;
	Fisica fisica = null;
	Endereco endereco = null;
	Session sess = HibernateUtil.getSession();
	String unidadeList = "";
	String infoList = "";		
	
	Informacao infoMain = null;
	try {
		Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
		Query query = sess.createQuery("from Unidade as u");
		unidades = (List<Unidade>) query.list();
		query = sess.createQuery("select distinct c.uf from Cep2005 as c");
		List<String> uf2005 = (List<String>) query.list();		
		if (isEdition) {
			fisica = (Fisica) sess.load(Fisica.class, Long.valueOf(request.getParameter("id")));
			
			if (fisica.getLogin() == null) {
				haveAccsess = false;
			} else {
				query = sess.createQuery("from CartaoAcesso as c where c.login = :login");
				query.setEntity("login", fisica.getLogin());
				haveAccsess = query.list().size() > 0;
			}
			
			if (haveAccsess) {
				query = sess.createQuery("from CartaoAcesso as c where c.login = :login and c.status = 'a'");
				query.setEntity("login", fisica.getLogin());
				disponivel = query.list().size();		
				liberacao = disponivel > 0;
			}
			
			query = sess.createQuery("from Informacao as i where i.pessoa = :fisica");
			query.setEntity("fisica", fisica);
			infoFisica = (List<Informacao>) query.list();
			for(Informacao info: infoFisica) {
				if (infoList == "") {
					infoList+= info.getCodigo();
				} else {
					infoList+= "|" + info.getCodigo();
				}
				infoList+= "@" + info.getTipo() + "@" + info.getDescricao() + "@";
				infoList+= (info.getPrincipal() == "s")? "Sim" : "Não";
			}		
			
			query = sess.createQuery("from Unidade as u where u.administrador = :fisica");
			query.setEntity("fisica", fisica);
			unidadeFisica = (List<Unidade>) query.list();
			for(Unidade unidade: unidadeFisica) {			
				query= sess.getNamedQuery("informacaoPrincipal").setEntity("pessoa", unidade);
				infoMain = (Informacao) query.uniqueResult();
				if (unidadeList == "") {
					unidadeList+= unidade.getCodigo();
				} else {
					unidadeList+= "|" + unidade.getCodigo();
				}
				unidadeList+= "@" + unidade.getReferencia() +
					"@" + unidade.getRazaoSocial() + "@" + unidade.getDescricao() + "@" + infoMain.getDescricao();
			}
			query = sess.createQuery("from Endereco as e where e.pessoa = :fisica");
			query.setEntity("fisica", fisica);
			endereco = (Endereco) query.uniqueResult();
		}%>
	
<html>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	
	<title>Master Cadastro de Administrador</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/jquery/formatacao.js"></script>
	<script type="text/javascript" src="../js/lib/validation.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/lib/pilot_grid.js" ></script>
	<script type="text/javascript" src="../js/comum/cadastro_administrador.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="adm"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="adm"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formPost" method="post" action="../CadastroAdministrador" onsubmit= "return validForm(this)">
				<div id="localEdUnidade"><%
					if (isEdition) {
						for(int i=0; i < unidadeFisica.size(); i++){
							query= sess.getNamedQuery("informacaoPrincipal").setEntity("pessoa", unidadeFisica.get(i));
							infoMain = (Informacao) query.uniqueResult();
							
							out.print("<input id=\"edReferencia" + String.valueOf(i) + "\" name=\"edReferencia" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +
									unidadeFisica.get(i).getReferencia() + "\" />");
							
							out.print("<input id=\"edRzSocial" + String.valueOf(i) + 
									"\" name=\"edRzSocial" + String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + 
									Util.initCap(unidadeFisica.get(i).getRazaoSocial()) + 
									"\" />");
							
							out.print("<input id=\"edDescricao" + String.valueOf(i) + 
									"\" name=\"edDescricao" +	String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" +	unidadeFisica.get(i).getDescricao() + "\" />");
							
							out.print("<input id=\"edFone" + String.valueOf(i) + 
									"\" name=\"edFone" + String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + infoMain.getDescricao() + "\" />");
							
							out.print("<input id=\"undFisicaId" + String.valueOf(i) + 
									"\" name=\"undFisicaId" + String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + 
									unidadeFisica.get(i).getCodigo() + "\" />");
						}
					}%>
				</div>
				<div id="localEdContact"><%
					if (isEdition) {
						for(int i=0; i < infoFisica.size() ; i++){
							out.print("<input id=\"edType" + String.valueOf(i) + "\" name=\"edBank" +
									String.valueOf(i) + "\" type=\"hidden\" value=\"" + 
									infoFisica.get(i).getTipo() + "\" />");
							
							out.print("<input id=\"edDescription" + String.valueOf(i) +
									"\" name=\"edDescription" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +
									Util.initCap(infoFisica.get(i).getDescricao())+ "\" />");
							
							out.print("<input id=\"edPrincipal" + String.valueOf(i) +
									"\" name=\"edPrincipal" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +									
									((infoFisica.get(i).getPrincipal().trim().equals("s"))? "Sim" : "Não") + "\" />");
							
							out.print("<input id=\"contactId" + String.valueOf(i) +
									"\" name=\"contactId" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +
									infoFisica.get(i).getCodigo()+ "\" />");
						}
					}%>
				</div>
				<div id="localContact"></div>
				<div id="localUnd"></div>
				<div id="deletedsUnd"></div>
				<div id="deletedsContact"></div>
				<div id="editedsUnd"></div>
				<div id="editedsContact"></div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Administrador"/>			
					</jsp:include>
					 <input type="hidden" id="edUnd" name="edUnd" value="n"/>
					 <input id="edInfo" name="edInfo" type="hidden" value="n"/>
					<input type="hidden" id="isEdition" name="isEdition" value="<%= (isEdition)? "s" : "n"%>">
					<input type="hidden" id="unidadeList" name="unidadeList" value="<%= unidadeList %>">
					<input type="hidden" id="infoList" name="infoList" value="<%= infoList %>" >
					<input type="hidden" id="codAdm" name="codAdm" value="<%= (isEdition)? fisica.getCodigo(): "" %>">
					<div class="topContent">
						<div id="fot" class="textBox" style="width: 103px; height: 137px">
							<img src="<%= (isEdition && fisica.getLogin().getFoto() != null)? fisica.getLogin().getFoto() : "../image/foto.gif"%>" width="103" height="137"/>
						</div>
						<div id="nome" class="textBox" style="width: 317px;">
							<label>Nome</label><br/>
							<input id="nomeIn" name="nomeIn" type="text" style="width: 317px;" class="required" onblur="genericValid(this);" value="<%= (isEdition)? Util.initCap(fisica.getNome()): "" %>" />
						</div>
						<div class="textBox" class="textBox" style="width: 200px;">
							<label>Sexo</label><br />
							<div class="checkRadio" >
								<label>Masculino</label>
								<input id="sexo" name="sexo" type="radio" value="m" <%if ((isEdition && fisica.getSexo().equals("m")) || !isEdition) {%> checked="checked" <%}%>/>
								<label>Feminino</label>
								<input id="sexo" name="sexo" type="radio" value="f" <%if (isEdition && fisica.getSexo().equals("f")) {%> checked="checked" <%}%>/>
							</div>
						</div>
						<div id="cpf" class="textBox" style="width: 107px">
							<label>Cpf</label><br/>
							<input id="cpfIn" name="cpfIn" type="text" style="width: 107px" class="required" onkeydown="mask(this, cpf);" onblur="cpfValidation(this)" value="<%= (isEdition)? Util.mountCpf(fisica.getCpf()) : "" %>" />
						</div>
						<div id="rg" class="textBox" style="width: 107px">
							<label>Rg</label><br/>
							<input id="rgIn" name="rgIn" type="text" style="width: 107px" value="<%= (isEdition)? fisica.getRg() : "" %>" />
						</div>
						<div id="nascimento" class="textBox" style="width: 80px;">
							<label>Nascimento</label><br/>
							<input id="nascimentoIn" name="nascimentoIn" type="text" class="required" style="width: 80px;" onkeydown="mask(this, typeDate);" onblur="genericValid(this)" value="<%= (isEdition)? Util.parseDate(fisica.getNascimento(), "dd/MM/yyyy") : ""%>"/>
						</div>
						<div id="estadoCivil" class="textBox" style="width: 94px">
							<label>Estado Cívil</label><br/>
							<select type="select-multiple" id="estadoCivilIn" name="estadoCivilIn" class="required" onblur="genericValid(this);" style="width: 94px;">
								<option value="c" <%if (isEdition && fisica.getEstadoCivil().equals("c")) {%> selected="selected" <%}%> >Casado(a)</option>
								<option value="s" <%if (isEdition && fisica.getEstadoCivil().equals("s")) {%> selected="selected" <%}%> >Solteiro(a)</option>
								<option value="o" <%if (isEdition && fisica.getEstadoCivil().equals("o")) {%> selected="selected" <%}%> >Outro</option>
							</select>
						</div>
						<div id="cadastro" class="textBox" style="width: 80px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" class="required" type="text" style="width: 80px;" onkeydown="mask(this, dateType);" value="<%= (isEdition)? Util.parseDate(fisica.getCadastro(), "dd/MM/yyyy") : "" %>" />
						</div>
						<div id="nacionalidade" class="textBox" style="width:204px">
							<label>Nacionalidade</label><br/>
							<input id="nacionalidadeIn" name="nacionalidadeIn" type="text" style="width:204px" class="required" onblur="genericValid(this)" value="<%= (isEdition)? fisica.getNacionalidade() : "" %>"/>
						</div>
						<div id="naturalidade" class="textBox" style="width:256px">
							<label>Naturalidade</label><br/>
							<input id="naturalidadeIn" name="naturalidadeIn" type="text" style="width:256px" class="required" onblur="genericValid(this)" value="<%= (isEdition)? fisica.getNaturalidade() : "" %>" />
						</div>
						<div id="naturalUf" class="textBox">
							<label>Uf</label><br/>
							<select type="select-multiple" id="naturalUfIn" name="naturalUfIn" >
								<%for(String uf: uf2005) {%>
									<option value="<%= uf.toLowerCase() %>" <%if (isEdition && fisica.getNaturalidadeUf().equals(uf.toLowerCase())) {%> selected="selected" <%}%> ><%= uf %></option>
								<%} %>
							</select>
						</div>
					</div>
				</div>
				<%if (isEdition) {%>
					<div class="topButtonContent">
						<div class="formGreenButton">
							<input id="fotoLoad" name="fotoLoad" class="greenButtonStyle" type="button" value="Editar Foto" onclick="loadFile()"/>
						</div>
					</div>
				<%}%>
				<div id="mainContent">
					<div id="acesso" class="bigBox" >
						<div class="indexTitle">
							<h4>Acessibilidade</h4>
							<div class="alignLine">
								<hr>
							</div>
							<input type="hidden" id="loginOld" name="loginOld" value="<%= (isEdition)? "n@" + fisica.getLogin().getUsername() : "" %>"/>
							<input type="hidden" id="senhaChange" name="senhaChange" value="n">
							<div id="login" class="textBox"style="width: 200px">
							<label>Login</label><br/>					
								<input id="loginIn" name="loginIn" type="text" style="width: 200px" <% if(isEdition) {%> readonly="readonly" <%}%> class="required" onblur="usernameValidation(this)" value="<%= (isEdition)? fisica.getLogin().getUsername() : "" %>" />
							</div>							
							<div id="senha" class="textBox"style="width: 200px">
								<label>Senha</label><br/>					
								<input id="senhaIn" name="senhaIn" type="password"  style="width: 200px" class="required" onblur="senhaValid(this, 'senhaConfirmIn')" <%if (isEdition) {%> readonly="readonly" <%}%> value="<%= (isEdition)? fisica.getRg(): "" %>" />
							</div>
							<div id="senhaConfirm" class="textBox" style="width: 200px">
								<label>Confirmar Senha</label><br/>
								<input id="senhaConfirmIn" name="senhaConfirmIn" type="password" class="required" style="width: 200px" onblur="senhaValid(this, 'senhaIn')" <%if (isEdition) {%> readonly="readonly" <%}%> value="<%= (isEdition)? fisica.getRg(): "" %>" />
							</div>
							<%if (isEdition) {%>
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
							<%}%>
						</div>	
					</div>
					<%if (isEdition) {%>
						<div class="buttonContent" >
							<div class="formGreenButton">
								<input name="editSenha" id="editSenha" class="greenButtonStyle" type="button" value="Editar Senha" onclick="editarSenha()" />
							</div>						
							<div class="formGreenButton"  >
								<input name="confirmSenha" id="confirmSenha" class="grayButtonStyle" type="button" value="Confirmar" onclick="confirmarSenha();" />
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
						</div>
					<%}%>
					<div id="EnderecoResponsavel" class="bigBox" >
						<div class="indexTitle">
							<h4>Endereço</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<input type="hidden" id="endId" name="endId" value="<%= (isEdition && endereco != null)? endereco.getCodigo() : "-1" %>">								
						<div id="cepResponsavel" class="textBox" style="width: 73px">
							<label>CEP</label><br/>					
							<input id="cepResponsavelIn" name="cepResponsavelIn" type="text" style="width: 73px" onkeydown="mask(this, cep);" value="<%= (isEdition && endereco != null)? Util.mountCep(endereco.getCep()) : "" %>" />
						</div>
						<div id="rua" class="textBox"style="width: 247px">
							<label>Endereço</label><br/>					
							<input id="ruaIn" name="ruaIn" type="text" style="width: 247px" onblur="genericValid(this)" value="<%= (isEdition && endereco != null)? Util.initCap(endereco.getRuaAv()) : "" %>"/>
						</div>
						<div id="numero" class="textBox" style="width: 45px">
							<label>Numero</label><br/>					
							<input id="numeroIn" name="numeroIn" type="text" style="width: 45px" value="<%= (isEdition && endereco != null)? endereco.getNumero() : "" %>" />
						</div>
						<div id="complemento" class="textBox" style="width:220px">
							<label>Complemento</label><br/>					
							<input id="complementoIn" name="complementoIn" type="text" style="width:220px" value="<%= (isEdition && endereco != null)? endereco.getComplemento() : "" %>" />
						</div>
						<div id="bairro" class="textBox" style="width: 200px">
							<label>Bairro</label><br/>					
							<input id="bairroIn" name="bairroIn" type="text" style="width: 200px" value="<%= (isEdition && endereco != null)? Util.initCap(endereco.getBairro()) : "" %>" />
						</div>
						<div id="cidade" class="textBox" style="width: 240px">
							<label>Cidade</label><br/>
							<input id="cidadeIn" name="cidadeIn" type="text" style="width: 240px"  class="required" value="<%= (isEdition && endereco != null)? Util.initCap(endereco.getCidade()) : "" %>"/>
						</div>
						<div id="ufResp" class="textBox">
							<label>Uf</label><br/>
							<select type="select-multiple" id="ufResponsavel" name="ufResponsavel">
								<%for(String uf: uf2005) { 
									if (endereco != null) {%>								
										<option value="<%= uf.toLowerCase() %>" <%if (isEdition && endereco.getUf().equals(uf.toLowerCase())) {%> selected="selected" <%}%> ><%= uf %></option>
								<% 	} else {%>
										<option value="<%= uf.toLowerCase() %>"><%= uf %></option>
									<%}
								}%>
							</select>
						</div>
					</div>
					<div id="contato" class="bigBox" style="bottom: 30px !important" >
						<div class="indexTitle">
							<h4>Informações de Contato</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>												
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
						<div id="descricao" class="textBox" style="width:300px;">
							<label>Descrição</label><br/>
							<input id="descricaoIn" name="descricao" type="text" style="width:300px;" onkeydown="comboMask(this, 'tipoContato')" />
						</div>
						<div class="textBox" id="principal">
							<label>Principal</label><br/>
							<select id="principalIn" name="principalIn" >								
								<option value="Sim">Sim</option>
								<option value="Não" selected="selected">Não</option>
							</select>
						</div>
						<div id="tableContact" class="multGrid"></div>
						<input type="hidden" id="infoData" name="infoData">
					</div>
					<div class="buttonContent" >
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Excluir" onclick="removeRowContato()" />
						</div>					
						<div class="formGreenButton" >
							<input class="greenButtonStyle" type="button" value="Inserir" onclick="addRowContato()" />
						</div>
					</div>					
					<div id="contato" class="bigBox" style="bottom: 30px !important" >
						<div class="indexTitle">
							<h4>Unidades</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div class="textBox" style="width: 135px">
							<label>Unidades</label><br/>
							<select id="unidade" name="unidade" onchange="clearNext('descricaoIn')" >
								<option value="">Selecione</option>
								<%for(Unidade unidade: unidades) {%>
									<option value="<%= unidade.getCodigo() %>"><%= unidade.getReferencia() + " - " + unidade.getDescricao() %></option>
								<%}%>
							</select>
						</div>
						<div id="tableUnidade" class="multGrid"></div>
						<input type="hidden" id="unidadeData" name="unidadeData" >
					</div>
					<div class="buttonContent" >
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Excluir" onclick="removeRowUnidade()" />
						</div>					
						<div class="formGreenButton" >
							<input class="greenButtonStyle" type="button" value="Inserir" onclick="addRowUnidade()" />
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
	</div>
</body>
</html>

<%} catch(Exception e) {
	e.printStackTrace();		
} finally {
	sess.close();
}%>