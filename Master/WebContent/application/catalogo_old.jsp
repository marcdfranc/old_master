<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>


<%@page import="com.marcsoftware.database.Login"%>
<%@page import="com.marcsoftware.database.Grupo"%>
<%@page import="com.marcsoftware.database.ItensGrupo"%>
<%@page import="com.marcsoftware.database.InformacaoCatalogo"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query = sess.createQuery("from Login as l where l.username = :username");
	query.setString("username", session.getAttribute("username").toString());
	Login login = (Login) query.uniqueResult();	
	query = sess.createQuery("from Grupo as g where g.login = :login order by g.codigo");
	query.setEntity("login", login);
	List<Grupo> grupos = (List<Grupo>) query.list();
	query = sess.createQuery("from ItensGrupo as i " + 
			" where i.id.grupo.login = :login " +
			" order by i.id.grupo.codigo, i.id.catalogo.nome");
	query.setEntity("login", login);
	List<ItensGrupo> itensGrupo = (List<ItensGrupo>) query.list();
	query = sess.createQuery("select distinct c.uf from Cep2005 as c");
	List<String> uf2005 = (List<String>) query.list();
	List<InformacaoCatalogo> informacoes;
	
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<link type="text/css" href="../js/jquery/flex_grid/css/flexigrid/flexigrid.css" rel="Stylesheet" />	
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
    <script type="text/javascript" src="../js/jquery/jquery.js"></script>
    <script type="text/javascript" src="../js/jquery/interface.js"></script>
    <script type="text/javascript" src="../js/jquery/flex_grid/flexigrid.js"></script>
    <script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/comum/catalogo.js"></script>
	<script type="text/javascript" src="../js/comum/cadastro_grupo.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/validacao.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
			
	<title>Master Catalogo de Endereços</title>	
</head>
<body>
	<div id="windowGrupo" class="removeBorda" title="Grupo" style="display: none">
		<form id="formGrupo" onsubmit="return false;">
			<fieldset>
				<label for="descGrupo">Descrição</label>
				<input type="text" name="descGrupo" id="descGrupo" class="textDialog ui-widget-content ui-corner-all" value="" />
			</fieldset>
		</form>
	</div>
	<div id="windowContato" class="removeBorda" title="Contato" style="font-size: 12px; display: none;">
		<form id="formContato" onsubmit="return false;">
			<input type="hidden" id="catalogoId" name="catalogoId" value="-1"/>			
			<input type="hidden" id="idToProcess" name="idToProcess" value="-1"/>
			<input type="hidden" id="gridLines" name="gridLines" value="0"/>			
			<div id="tabsWindow">
				<ul>
					<li><a href="#abaGeral">Geral</a></li>					
					<li><a href="#abaPessoal">Pessoal</a></li>
					<li><a href="#abaContato">Informações de Contato</a></li>
					<li><a href="#abaTrabalho">Trabalho</a></li>
				</ul>
				<fieldset>
					<div id="abaGeral">
						<label for="primeiroNome">Primeiro Nome</label>
						<input type="text" name="primeiroNome" id="primeiroNome" class="textDialog ui-widget-content ui-corner-all" />
						<label for="ultimoNome">Último Nome</label>
						<input type="text" name="ultimoNome" id="ultimoNome" class="textDialog ui-widget-content ui-corner-all" value="" />
						<label for="apelido">Apelido</label>
						<input type="text" name="apelido" id="apelido" class="textDialog ui-widget-content ui-corner-all" value="" />
						<label for="usuario">Nome de Usuário</label>
						<input type="text" name="usuario" id="usuario" class="textDialog ui-widget-content ui-corner-all" value="" />
						<label for="aniverssario">Aniverssário</label>
						<input type="text" name="aniverssario" id="aniverssario" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, typeDate);" />
						<label for="grupoContato">Grupo</label>
						<select id="grupoContato" name="grupoContato" style="width: 100%">							
							<%for(Grupo grupo: grupos) {%>
								<option value="<%= grupo.getCodigo() %>" ><%= grupo.getDescricao() %></option>
							<%}%>
						</select>
					</div>
					<div id="abaPessoal">
						<label for="cepIn">CEP</label>
						<input type="text" name="cepIn" id="cepIn" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, cep);;"/>
						<label for="endereco">Endereço</label>
						<input type="text" name="endereco" id="endereco" class="textDialog ui-widget-content ui-corner-all"   />
						<label for="complemento">Complemento</label>
						<input type="text" name="complemento" id="complemento" class="textDialog ui-widget-content ui-corner-all" value="" />
						<label for="bairro">Bairro</label>
						<input type="text" name="bairro" id="bairro" class="textDialog ui-widget-content ui-corner-all" value="" />
						<label for="cidade">Cidade</label>
						<input type="text" name="cidade" id="cidade" class="textDialog ui-widget-content ui-corner-all" value="" />
						<label for="uf">UF</label>
						<select id="uf" name="uf" style="width: 100%">
							<option value="">Selecione</option>
							<%for(String uf: uf2005) {						
								out.print("<option value=\"" + uf.toLowerCase() + 
										"\">" + Util.ESTADO_LITERAL.get(uf) + "</option>");
							}%>
						</select>
					</div>
					<div id="abaContato">
						<label for="tipo">tipo</label>
						<select id="tipo" name="tipo" style="width: 100%">							
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
						<label for="descricaoInfo">Descrição</label>
						<input type="text" name="descricaoInfo" id="descricaoInfo" class="textDialog ui-widget-content ui-corner-all" onkeydown="comboMask(this, 'tipo')" />
						<label for="principal">Principal</label>
						<select id="principal" name="principal" style="width: 100%; margin-bottom: 20px;" >								
							<option value="Sim">Sim</option>
							<option value="Não" selected="selected">Não</option>
						</select>
						<table id="flex1" style="display:none"></table>
						
					</div>
					<div id="abaTrabalho">
						<label for="cargo">Cargo</label>
						<input type="text" name="cargo" id="cargo" class="textDialog ui-widget-content ui-corner-all" value="" />						
						<label for="setor">Setor</label>
						<input type="text" name="setor" id="setor" class="textDialog ui-widget-content ui-corner-all" value="" />
						<label for="empresa">Empresa</label>
						<input type="text" name="empresa" id="empresa" class="textDialog ui-widget-content ui-corner-all" value="" />
						<label for="cepEmp">CEP</label>
						<input type="text" name="cepEmp" id="cepEmp" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, cep);"/>
						<label for="enderecoEmp">Endereço</label>
						<input type="text" name="enderecoEmp" id="enderecoEmp" class="textDialog ui-widget-content ui-corner-all" value="" />
						<label for="complementoEmp">Complemento</label>
						<input type="text" name="complementoEmp" id="complementoEmp" class="textDialog ui-widget-content ui-corner-all" value="" />
						<label for="bairroEmp">Bairro</label>
						<input type="text" name="bairroEmp" id="bairroEmp" class="textDialog ui-widget-content ui-corner-all" value="" />
						<label for="cidadeEmp">Cidade</label>
						<input type="text" name="cidadeEmp" id="cidadeEmp" class="textDialog ui-widget-content ui-corner-all" value="" />
						<label for="ufEmp">UF</label>
						<select id="ufEmp" name="ufEmp" style="width: 100%">
							<option value="">Selecione</option>
							<%for(String uf: uf2005) {						
								out.print("<option value=\"" + uf.toLowerCase() + 
										"\">" + Util.ESTADO_LITERAL.get(uf) + "</option>");
							}%>
						</select>
						<label for="site">Site</label>
						<input type="text" name="site" id="site" class="textDialog ui-widget-content ui-corner-all" value="" />
						<label for="foneEmp">Fone</label>
						<input type="text" name="foneEmp" id="foneEmp" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, fone)" />
					</div>
				</fieldset>
			</div>
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="forum"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="forum"/>
		</jsp:include>
		<div id="formStyle">
			<form id="parc" method="get" onsubmit="return search()">							
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Contatos"/>
					</jsp:include>
					<div id="abaMenu">
						<div class="sectedAba2">
							<label>Agenda Telefônica</label>
						</div>								
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="agenda_pessoal.jsp">Agenda Pessoal</a>
						</div>						
					</div>
					<div class="topContent">
						<div class="indexTitle">
							<div id="fot" class="textBox"style="width: 103px; height: 137px;">
								<img src="<%=(login.getFoto() != null)? login.getFoto(): "../image/foto.gif" %>" width="103" height="137"/>
							</div>
							<h4 style="margin-left: 150px" >Usuario: <%= login.getUsername() %></h4>
							<h4 style="margin-left: 150px">Seja bem vindo a sua agenda.</h4>
							<h4 style="margin-left: 150px">Tenha um Bom dia!</h4>	
							<div class="textBox">
								<label>Aniverssário</label><br />
								<select id="mesNiver">
									<option value="">Selecione</option>
									<option value="1">Janeiro</option>
									<option value="2">Fevereiro</option>
									<option value="3">Março</option>
									<option value="4">Abril</option>
									<option value="5">Maio</option>
									<option value="6">Junho</option>
									<option value="7">Julho</option>
									<option value="8">Agosto</option>
									<option value="9">Setembro</option>
									<option value="10">Outubro</option>
									<option value="11">Novembro</option>
									<option value="12">Dezembro</option>
								</select>
							</div>
							<div class="textBox" >
								<label for="grupoContato">Grupo</label><br />
								<select id="grupoPesquisa" name="grupoPesquisa" style="width: 180px">
									<option value="-1@i">Selecione</option>															
									<%for(int i=0; i < grupos.size(); i++) {%>
										<option value="<%= i + "@" + grupos. get(i).getCodigo() %>" ><%= grupos.get(i).getDescricao() %></option>
									<%}%>
								</select>
							</div>							
							<div class="textBox">
								<label>Nome</label><br />
								<input type="text" id="nomeContato" name="nomeContato" style="width: 220px;" />
							</div>
						</div>
					</div>
				</div>
				<div class="topButtonContent">
					<%if (grupos.size() > 0) {%>
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Novo Grupo" onclick="cadastroGrupo('e')" />
						</div>
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Novo" onclick="cadastroContato('-1')" />
						</div>
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Buscar" onclick="pesquisaGrupo()" />
						</div>
					<%} else {%>
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Iniciar" onclick="cadastroGrupo('e')" />
						</div>
					<%}%>
				</div>
				<div id="mainContent">
					<div class="indexTitle" style="margin-top: 0 !important; margin-bottom: 15px !important;">
						<h4>Painel de Contatos</h4>
						<div class="alignLine">
							<hr>
						</div>
						<div class="accordionContent" style="height: 400px; width: 930px; margin-left: 1px" >
							<div id="accordiomGrupo" class="accordion" style="width: 930px">
								
								<%for(Grupo grupo: grupos) {%>
									<h3 id="grp<%= grupo.getCodigo() %>" class="headerOption">
										<a href="#" ondblclick="cadastroGrupo('<%= grupo.getCodigo() %>')"><%= grupo.getDescricao() %></a>
									</h3>
									<div>										
										<%if (itensGrupo.size() > 0) {%>
											<div class="accordionContent" style="height: 260px; width: 873px; padding-bottom: 43px !important;" >
												<div id="accordiomItem<%= grupo.getCodigo() %>" class="accordionItem" style="width: 873px;">
													<%for(ItensGrupo iten: itensGrupo) {
														if (iten.getId().getGrupo().equals(grupo)) {%>															
															<h3 class="headerOption">
																<a class="hdNiver<%=(iten.getId().getCatalogo().getAniverssario() == null)? "" : Util.getMonthDate(iten.getId().getCatalogo().getAniverssario()) %>" href="#"><%= iten.getId().getCatalogo().getNome()%></a>
																<input type="hidden" value="<%= iten.getId().getGrupo().getCodigo() %>"/>
															</h3>
															<div style="height: auto !important;">
																<div style="width: 200px; float: left;">
																	<h4>Geral</h4>
																	<div class="alignLine">
																		<hr>
																	</div>																	
																	<input type="hidden" id="nome<%= iten.getId().getCatalogo().getCodigo() %>" name="ultimoNome<%= iten.getId().getCatalogo().getCodigo() %>" value="<%= iten.getId().getCatalogo().getNome() %>" />
																	<input type="hidden" id="grupoContato<%= iten.getId().getCatalogo().getCodigo() %>" name="grupoContato<%= iten.getId().getCatalogo().getCodigo() %>" value="<%= grupo.getCodigo() %>" />
																	<strong>Apelido</strong><span id="apelido<%= iten.getId().getCatalogo().getCodigo() %>"><%= iten.getId().getCatalogo().getApelido() %> </span><br />
																	<strong>Usuário: </strong><span id="usuario<%= iten.getId().getCatalogo().getCodigo() %>"><%= (iten.getId().getCatalogo().getLogin() == null)? "" : iten.getId().getCatalogo().getLogin().getUsername() %> </span><br />
																	<strong>Aniverssário: </strong><span id="aniverssario<%= iten.getId().getCatalogo().getCodigo() %>"><%= (iten.getId().getCatalogo().getAniverssario() == null)? "" : Util.parseDate(iten.getId().getCatalogo().getAniverssario(), "dd/MM/yyyy")  %> </span><br />
																																	
																	<div class="formGreenButton" style="margin-top: 12px;">
																		<input class="greenButtonStyle" type="button" value="Editar" onclick="cadastroContato('<%= iten.getId().getCatalogo().getCodigo()%>')" />
																	</div>
																
																</div>
																<div style="width: 309px; float: left;">
																	<h4>Pessoal</h4>
																	<div class="alignLine">
																		<hr>
																	</div>																
																	<strong>CEP: </strong><span id="cep<%= iten.getId().getCatalogo().getCodigo() %>"><%= Util.mountCep(iten.getId().getCatalogo().getEndereco().getCep()) %> </span><br />
																	<strong>Endereço: </strong><span id="endereco<%= iten.getId().getCatalogo().getCodigo() %>"><%= iten.getId().getCatalogo().getEndereco().getEndereco() %> </span><br />
																	<strong>Complemento: </strong><span id="complemento<%= iten.getId().getCatalogo().getCodigo() %>"><%= iten.getId().getCatalogo().getEndereco().getComplemento()  %> </span><br />
																	<strong>Bairro: </strong><span id="bairro<%= iten.getId().getCatalogo().getCodigo() %>"><%= iten.getId().getCatalogo().getEndereco().getBairro() %> </span><br />
																	<strong>Cidade: </strong><span id="cidade<%= iten.getId().getCatalogo().getCodigo() %>"><%= iten.getId().getCatalogo().getEndereco().getCidade() + " - " + iten.getId().getCatalogo().getEndereco().getUf() %> </span><br />
																</div>
																<div style="width: 245px; float: left;">
																	<h4>Informações de Contato</h4>
																	<div class="alignLine">
																		<hr>
																	</div>																
																	<%query = sess.createQuery("from InformacaoCatalogo AS i where i.catalogo = :catalogo");
																	query.setEntity("catalogo", iten.getId().getCatalogo());
																	informacoes = (List<InformacaoCatalogo>) query.list();
																	for(InformacaoCatalogo info: informacoes) {%>
																		<strong><%= info.getTipo() %>: </strong><span><%= info.getDescricao() %></span><br />
																	<%}%>
																</div>
																<div style="width: 816px; float: left; margin-top: 10px; margin-right: 0 !important; padding-right: 0 !important">
																	<h4 style="width: 500px !important">Trabalho <%= (iten.getId().getCatalogo().getTrabalho() == null)? "" : "- " + iten.getId().getCatalogo().getTrabalho().getEmpresa() %></h4>
																	<div class="alignLine" style="width: 816px !important">
																		<hr>
																	</div>
																</div>
																<input type="hidden" name="empresa<%= iten.getId().getCatalogo().getCodigo() %>" id="empresa<%= iten.getId().getCatalogo().getCodigo() %>" value="<%= (iten.getId().getCatalogo().getTrabalho() == null)? "" : iten.getId().getCatalogo().getTrabalho().getEmpresa() %>" />
																<div style="width: 216px; float: left;">																	
																	<strong>Cargo: </strong><span id="cargo<%= iten.getId().getCatalogo().getCodigo() %>"><%= (iten.getId().getCatalogo().getTrabalho() == null)? "" : iten.getId().getCatalogo().getTrabalho().getCargo() %> </span><br />
																	<strong>Setor: </strong><span id="setor<%= iten.getId().getCatalogo().getCodigo() %>"><%= (iten.getId().getCatalogo().getTrabalho() == null)? "" : iten.getId().getCatalogo().getTrabalho().getSetor() %> </span><br />
																	<strong>CEP: </strong><span id="cepEmp<%= iten.getId().getCatalogo().getCodigo() %>"><%= (iten.getId().getCatalogo().getTrabalho() != null && iten.getId().getCatalogo().getTrabalho().getEndereco().getCep() != null)? iten.getId().getCatalogo().getTrabalho().getEndereco().getCep(): "" %> </span><br />
																</div>
																<div style="width: 328px; float: left;">
																	<strong>Endereço: </strong><span id="enderecoEmp<%= iten.getId().getCatalogo().getCodigo() %>"><%= (iten.getId().getCatalogo().getTrabalho() == null)? "" : iten.getId().getCatalogo().getTrabalho().getEndereco().getEndereco() %> </span><br />
																	<strong>Complemento: </strong><span id="complementoEmp<%= iten.getId().getCatalogo().getCodigo() %>"><%= (iten.getId().getCatalogo().getTrabalho() == null)? "" : iten.getId().getCatalogo().getTrabalho().getEndereco().getComplemento() %> </span><br />
																	<strong>Bairro: </strong><span id="bairroEmp<%= iten.getId().getCatalogo().getCodigo() %>"><%= (iten.getId().getCatalogo().getTrabalho() == null)? "" : iten.getId().getCatalogo().getTrabalho().getEndereco().getBairro() %> </span><br />
																</div>
																<div style="width: 245px; float: left;">
																	<strong>Cidade: </strong><span id="cidadeEmp<%= iten.getId().getCatalogo().getCodigo() %>"><%= (iten.getId().getCatalogo().getTrabalho() == null)? "" : iten.getId().getCatalogo().getTrabalho().getEndereco().getCidade() + " - " + iten.getId().getCatalogo().getTrabalho().getEndereco().getUf() %> </span><br />
																	<strong>Site: </strong><span id="site<%= iten.getId().getCatalogo().getCodigo() %>"><%= (iten.getId().getCatalogo().getTrabalho() == null)? "" : iten.getId().getCatalogo().getTrabalho().getWebsite() %> </span><br />
																	<strong>Fone: </strong><span id="fone<%= iten.getId().getCatalogo().getCodigo() %>"><%= (iten.getId().getCatalogo().getTrabalho() == null)? "" : iten.getId().getCatalogo().getTrabalho().getFone()%> </span><br />
																</div>
															</div>
														<%}
													}%>
												</div>
											</div>
										<%}%> 
									</div>
								<%}%>
							</div>
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