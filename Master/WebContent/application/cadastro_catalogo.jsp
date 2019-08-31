<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.database.Catalogo"%>
<%@page import="com.marcsoftware.database.Login"%>
<%@page import="com.marcsoftware.database.Grupo"%>
<%@page import="com.marcsoftware.database.ItensGrupo"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.InformacaoCatalogo"%><html>
	<jsp:useBean id="catalogo" class="com.marcsoftware.database.Catalogo"></jsp:useBean>
	<%!boolean isEdition= false;%>
	<%isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Query query = sess.createQuery("from Login as l where l.username = :username");
	query.setString("username", session.getAttribute("username").toString());
	Login login = (Login) query.uniqueResult();	
	query = sess.createQuery("from Grupo as g where g.login = :login order by g.codigo");
	query.setEntity("login", login);
	List<Grupo> grupos = (List<Grupo>) query.list();
	query = sess.createQuery("select distinct c.uf from Cep2005 as c");
	List<String> uf2005 = (List<String>) query.list();
	ItensGrupo itenGrupo = null;
	List<InformacaoCatalogo> itenList = null;
	if (isEdition) {
		catalogo = (Catalogo) sess.load(Catalogo.class, Long.valueOf(request.getParameter("id")));
		query = sess.createQuery("from ItensGrupo as i where i.id.catalogo = :catalogo");
		query.setEntity("catalogo", catalogo);
		itenGrupo = (ItensGrupo) query.list().get(0);
		query = sess.createQuery("from InformacaoCatalogo as i where i.catalogo = :catalogo");
		query.setEntity("catalogo", catalogo);
		itenList = (List<InformacaoCatalogo>) query.list();
	}
	
	%>	
<head>
	<link rel="shortcut icon" href="../icone.ico"/>
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Master - Cadastro Catalogo</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/validation.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/comum/cadastro_catalogo.js" ></script>
	<script type="text/javascript" src="../js/lib/pilot_grid.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
</head>
<body>
	<div id="windowNota" class="removeBorda" title="Bloco de Notas" style="display: none">
		<form id="formNota" onsubmit="return false;">
			<fieldset>
				<label for="blcNota">Notas</label>
				<textarea name="blcNota" id="blcNota" class="textDialog ui-widget-content ui-corner-all" rows="30" ><%=(login.getBlocoNotas() == null)? "" : login.getBlocoNotas() %></textarea>
			</fieldset>
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
			<form id="formPost" name="formPost" method="post" action="../CadastroCatalogo" onsubmit="return checaValidacao(this)">
				<input type="hidden" id="catalogoId" name="catalogoId" value="<%= (isEdition)? catalogo.getCodigo() : "-1" %>">
				<input type="hidden" id="usuario" name="usuario" value="<%= login.getUsername() %>" />
				<div id="localTabela"></div>
				<div id="deletedsServ"></div>				
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Agenda"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="catalogo.jsp">Agenda Telefônica</a>
						</div>														
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="agenda_pessoal.jsp">Agenda Pessoal</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="#" onclick="editBlocoNota()">Bloco de Notas</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Novo Contato</label>
						</div>
					</div>
					<div class="topContent">
						<div id="nome" class="textBox">
							<label>Nome</label><br/>
							<input id="nomeIn" name="nomeIn" class="required" type="text" style="width: 338px;" value="<%=(isEdition)? Util.initCap(catalogo.getNome()) : ""%>" onblur="genericValid(this);"/>
						</div>
						<div id="apelido" class="textBox" >
							<label>Apelido</label><br/>
							<input id="apelidoIn" name="apelidoIn" type="text" style="width: 238px;" value="<%=(isEdition)? catalogo.getApelido() : ""%>"/>
						</div>
						<div id="usuario" class="textBox">
							<label>Usuário</label><br/>
							<input id="usuarioIn" name="usuarioIn" type="text" style="width: 228px;" value="<%=(isEdition && catalogo.getLogin() != null)? catalogo.getLogin().getUsername() : ""%>"/>
						</div>
						<div id="nascimento" class="textBox" >
							<label>Nascimento</label><br/>
							<input id="nascimentoIn" name="nascimentoIn" type="text" style="width: 72px;" value="<%=(isEdition && catalogo.getAniverssario() != null)? Util.parseDate(catalogo.getAniverssario(), "dd/MM/yyyy") : ""%>" onkeydown="mask(this, typeDate)"/>
						</div>
						<div id="grupoId" class="textBox" style="width: 262px;">
							<label>Grupo</label><br/>
							<select id="grupoIdIn" name="grupoIdIn" style="width: 262px">
								<option value="" >Selecione</option>
								<%for(Grupo grupo: grupos) {%>								
									<option value="<%= grupo.getCodigo() %>" <%if (isEdition && grupo.equals(itenGrupo.getId().getGrupo())) {%> selected="selected" <%}%> ><%= grupo.getDescricao() %></option>
								<%}%>
							</select>
						</div>
					</div>					
				</div>
				<div id="mainContent">					
					<div class="bigBox" >
						<div class="indexTitle">
							<h4>Endereço</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div id="cep" class="textBox" >
							<label>CEP</label><br/>
							<input id="cepIn" name="cepIn" type="text" style="width: 70px;" value="<%=(catalogo.getEndereco() != null && isEdition)? Util.mountCep(catalogo.getEndereco().getCep()) : ""%>" onkeydown="mask(this, cep)"/>
						</div>
						<div id="rua" class="textBox" >
							<label>Endereço</label><br/>
							<input id="ruaIn" name="ruaIn" type="text" style="width: 264px;" value="<%=(catalogo.getEndereco() != null && isEdition)? catalogo.getEndereco().getEndereco() : ""%>" onblur="checkRequerido();"/>
						</div>
						<div id="complemento" class="textBox" >
							<label>Complemento</label><br/>
							<input id="complementoIn" name="complementoIn" type="text" style="width: 264px;" value="<%=(catalogo.getEndereco() != null && isEdition)? catalogo.getEndereco().getComplemento() : ""%>"/>
						</div>
						<div id="bairro" class="textBox" >
							<label>Bairro</label><br/>
							<input id="bairroIn" name="bairroIn" type="text" style="width: 250px;" value="<%=(catalogo.getEndereco() != null && isEdition)? catalogo.getEndereco().getBairro() : ""%>"/>
						</div>
						<div id="cidade" class="textBox" >
							<label>Cidade</label><br/>
							<input id="cidadeIn" name="cidadeIn" type="text" style="width: 274px;" value="<%=(catalogo.getEndereco() != null && isEdition)? catalogo.getEndereco().getCidade() : ""%>" onblur="checkRequerido();"/>
						</div>
						<div id="uf" class="textBox" >
							<label>Uf</label><br/>
							<select id="ufIn" name="ufIn" onblur="checkRequerido();">
								<option value="">Selecione</option>
								<%for(String uf: uf2005) {%>
									<option value="<%= uf.toLowerCase() %>" <%if (isEdition && catalogo.getEndereco() != null && uf.equals(catalogo.getEndereco().getUf().toUpperCase())){%> selected="selected" <%}%> ><%= uf.toUpperCase()%></option>
								<%}%>
							</select>
						</div>
					</div>
					<div id="itensOrcamento" class="bigBox" >
						<div class="indexTitle">
							<h4>Informações de Contato</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>												
						<div class="textBox" >
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
						<div id="descricao" class="textBox" >
							<label>Descrição</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width:300px;" onkeydown="comboMask(this, 'tipoContato')" />
						</div>
						<div class="textBox" id="principal">
							<label>Principal</label><br/>
							<select id="principalIn" name="principalIn" >								
								<option value="Sim">Sim</option>
								<option value="Não">Não</option>
							</select>
						</div>
						<div id="dataGrid">
							<%
							DataGrid dataGrid = new DataGrid("#");
							dataGrid.addColum("38", "Tipo");
							dataGrid.addColum("48", "Descrição");
							dataGrid.addColum("14", "Principal");
							dataGrid.addColum("2", "Ck");
							if (isEdition) {
								for(InformacaoCatalogo iten: itenList) {
									dataGrid.setId(iten.getCodigo().toString());
									dataGrid.addData("rowTipo", iten.getTipo(), "onClick", "editarLinha", "ckIndex");									
									dataGrid.addData("rowDescricao", iten.getDescricao(), "onClick", "editarLinha", "ckIndex");
									dataGrid.addData("rowPrincipal", (iten.getPrincipal().equals("s"))? "Sim" : "Nâo", "onClick", "editarLinha", "ckIndex");
									dataGrid.addCheck("checkrowTabela");
									dataGrid.addSimpleRow();
								}
							}
							if (isEdition) {
								out.print(dataGrid.getTable(itenList.size()));								
							} else {
								out.print(dataGrid.getTable(0));
							}
							%>
						</div>
					</div>
					<div class="buttonContent">					
						<div class="formGreenButton">
							<input name="removeTabela" class="greenButtonStyle" type="button" value="Excluir" onclick="removeRowInfo()" />
						</div>					
						<div class="formGreenButton" >
							<input id="specialButton" name="insertTabela" class="greenButtonStyle" type="button" value="Inserir" onclick="addRowInfo()" />
						</div>
					</div>
					<div class="bigBox" >
						<div class="indexTitle">
							<h4>Informações de Trabalho</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div id="empresa" class="textBox" >
							<label>Empresa</label><br/>
							<input id="empresaIn" name="empresaIn" type="text" style="width:322px;" value="<%= (isEdition && catalogo.getTrabalho() != null && catalogo.getTrabalho().getEmpresa() != null)? catalogo.getTrabalho().getEmpresa() : "" %>" onblur="checkRequerido();" />
						</div>
						<div id="setor" class="textBox" >
							<label>Ramo de Atividade</label><br/>
							<input id="setorIn" name="setorIn" type="text" style="width:274px;" value="<%= (isEdition && catalogo.getTrabalho() != null && catalogo.getTrabalho().getSetor() != null)? catalogo.getTrabalho().getSetor() : "" %>" />
						</div>
						<div id="cargo" class="textBox" >
							<label>Cargo</label><br/>
							<input id="cargoIn" name="cargoIn" type="text" style="width:274px;" value="<%=(isEdition && catalogo.getTrabalho() != null && catalogo.getTrabalho().getCargo()!= null)? catalogo.getTrabalho().getCargo() : "" %>" />
						</div>
						<div id="cepEmp" class="textBox" >
							<label>CEP</label><br/>
							<input id="cepEmpIn" name="cepEmpIn" type="text" style="width:72px;" value="<%= (isEdition && catalogo.getTrabalho() != null && catalogo.getTrabalho().getEndereco() != null && catalogo.getTrabalho().getEndereco().getCep() != null)? Util.mountCep(catalogo.getTrabalho().getEndereco().getCep()) : "" %>" onkeydown="mask(this, cep)" />
						</div>
						<div id="endereco" class="textBox" >
							<label>Endereço</label><br/>
							<input id="enderecoIn" name="enderecoIn" type="text" style="width:264px;" value="<%= (isEdition && catalogo.getTrabalho() != null && catalogo.getTrabalho().getEndereco() != null && catalogo.getTrabalho().getEndereco().getEndereco() != null)? catalogo.getTrabalho().getEndereco().getEndereco() : "" %>" onblur="checkRequerido();"/>
						</div>
						<div id="complementoEmp" class="textBox">
							<label>Complemento</label><br/>
							<input id="complementoEmpIn" name="complementoEmpIn" type="text" style="width:264px;" value="<%= (isEdition && catalogo.getTrabalho() != null && catalogo.getTrabalho().getEndereco() != null && catalogo.getTrabalho().getEndereco().getComplemento() != null)?  catalogo.getTrabalho().getEndereco().getComplemento() : "" %>" />
						</div>
						<div id="bairroEmp" class="textBox" >
							<label>Bairro</label><br/>
							<input id="bairroEmpIn" name="bairroEmpIn" type="text" style="width:250px;" value="<%= (isEdition && catalogo.getTrabalho() != null && catalogo.getTrabalho().getEndereco() != null && catalogo.getTrabalho().getEndereco().getBairro() != null)? catalogo.getTrabalho().getEndereco().getBairro() : "" %>" />
						</div>
						<div id="cidadeEmp" class="textBox" >
							<label>Cidade</label><br/>
							<input id="cidadeEmpIn" name="cidadeEmpIn" type="text" style="width:350px;" value="<%= (isEdition && catalogo.getTrabalho() != null && catalogo.getTrabalho().getEndereco() != null && catalogo.getTrabalho().getEndereco().getCidade() != null)? catalogo.getTrabalho().getEndereco().getCidade() : "" %>" onblur="checkRequerido();"/>
						</div>
						<div id="ufEmp" class="textBox" >
							<label>Uf</label><br/>
							<select id="ufEmpIn" name="ufEmpIn" onblur="checkRequerido();" >
								<option value="">Selecione</option>
								<%for(String uf: uf2005) {%>
									<option value="<%= uf.toLowerCase() %>" <%if (isEdition && catalogo.getTrabalho() != null && catalogo.getTrabalho().getEndereco() != null && uf.equals(catalogo.getTrabalho().getEndereco().getUf().toUpperCase())){%> selected="selected" <%}%> ><%= uf.toUpperCase() %></option>
								<%}%>
							</select>
						</div>
						<div id="site" class="textBox" >
							<label>Site</label><br/>
							<input id="siteIn" name="siteIn" type="text" style="width:313px;" value="<%= (isEdition && catalogo.getTrabalho() != null && catalogo.getTrabalho().getWebsite() != null)? catalogo.getTrabalho().getWebsite() : "" %>" />
						</div>
						<div id="telefoneEmp" class="textBox" >
							<label>Telefone</label><br/>
							<input id="telefoneEmpIn" name="telefoneEmpIn" type="text" style="width:107px;" value="<%= (isEdition && catalogo.getTrabalho() != null && catalogo.getTrabalho().getFone() != null)? catalogo.getTrabalho().getFone() : "" %>" onkeydown="mask(this, fone)" />
						</div>
					</div>
					<div class="buttonContent" >
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Salvar" onclick="enviarCatalogo()"/>
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