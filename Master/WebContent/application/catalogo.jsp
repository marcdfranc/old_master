<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>


<%@page import="com.marcsoftware.database.Login"%>
<%@page import="com.marcsoftware.database.Grupo"%>
<%@page import="com.marcsoftware.database.ItensGrupo"%>
<%@page import="com.marcsoftware.database.InformacaoCatalogo"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%><html xmlns="http://www.w3.org/1999/xhtml">
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
	query = sess.createQuery("select distinct c.uf from Cep2005 as c");
	List<String> uf2005 = (List<String>) query.list();
	List<InformacaoCatalogo> informacoes;
	query = sess.createQuery("from ItensGrupo as i " + 
			" where i.id.grupo.login = :login " +
			" order by i.id.grupo.codigo, i.id.catalogo.nome");
	query.setEntity("login", login);
	int gridLines = query.list().size();
	query.setFirstResult(0);
	query.setMaxResults(30);
	List<ItensGrupo> itensGrupo = (List<ItensGrupo>) query.list();
	query = sess.createQuery("select count(*) from ItensGrupo as i " +
			"where month(i.id.catalogo.aniverssario) = :mesCorrente " +
			"and i.id.grupo.login = :login");
	query.setInteger("mesCorrente", Util.getMonthDate(new Date()));
	query.setEntity("login", login);
	int aniverssariantes = Integer.parseInt(query.uniqueResult().toString()); 
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<link type="text/css" href="../js/jquery/flex_grid/css/flexigrid/flexigrid.css" rel="Stylesheet" />
	<script type="text/javascript" src="../js/lib/componentes/item_selector.js"></script>	
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<style>
		.selctedGrp{
			color: #666666;
		}
				
		a.sair:HOVER {
			color: #990066;
		}
	</style>	
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
    <script type="text/javascript" src="../js/jquery/jquery.js"></script>
    <script type="text/javascript" src="../js/jquery/formatacao.js"></script>
    <script type="text/javascript" src="../js/jquery/interface.js"></script>    
    <script type="text/javascript" src="../js/lib/util.js"></script>
    <script type="text/javascript" src="../js/lib/new_datagrid.js"></script>	
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/comum/grupo.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
			
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
	<div id="windowNota" class="removeBorda" title="Bloco de Notas" style="display: none">
		<form id="formNota" onsubmit="return false;">
			<fieldset>
				<label for="blcNota">Notas</label>
				<textarea name="blcNota" id="blcNota" class="textDialog ui-widget-content ui-corner-all" rows="30" ><%=(login.getBlocoNotas() == null)? "" : login.getBlocoNotas() %></textarea>
			</fieldset>
		</form>
	</div>
	
	<div id="windowRel" class="removeBorda" title="Relatório de Contatos" style="display: none">
		<form id="formContatos" onsubmit="return false;">
			<fieldset>
				<input type="hidden" id="login" name="login" value="<%=  login.getUsername() %>" />
				<label for="nomeRel">Nome</label>
				<input type="text" name="nomeRel" id="nomeRel" class="textDialog ui-widget-content ui-corner-all" value="" />
				<label for="mesAniversario">Nascimento</label>
				<select id="mesAniversario" name="mesAniversario" style="width: 100%">
					<option value="">Selecione</option>
					<option value="01">Janeiro</option>
					<option value="02">Fevereiro</option>
					<option value="03">Março</option>
					<option value="04">Abril</option>
					<option value="05">Maio</option>
					<option value="06">Junho</option>
					<option value="07">Julho</option>
					<option value="08">Agosto</option>
					<option value="09">Setembro</option>
					<option value="10">Outubro</option>
					<option value="11">Novembro</option>
					<option value="12">Dezembro</option>					
				</select>
				<label for="descInfo">Informação</label>
				<input type="text" name="descInfo" id="descInfo" class="textDialog ui-widget-content ui-corner-all" value="" />
				<div class="itContent ui-corner-all" id="selectorTable" style="margin-top: 10px;">
					<div style="width: 300px; height: 350px; float:left; margin-bottom: 0 !important">
						<label class="ui-corner-all titleBar">Grupos</label>
						<ul id="sortable1" class="connectedSortable ui-corner-all leftList" style="width: 300px; height: 300px;">
							<%for(int i = 0; i < grupos.size(); i++) {
								out.print("<li style=\"height: 20px\" title=\"" + grupos.get(i).getCodigo() + 
										"\">" +	grupos.get(i).getDescricao() + "</li>");
							}%>								
						</ul>
					</div>
					<div class="btContent" ></div>
					<div style="width: 300px; height: 350px; float:left; margin-bottom: 0 !important">
						<label class="ui-corner-all titleBar">Selecionados</label>
						<ul id="sortable2" class="connectedSortable ui-corner-all leftList" style="width: 300px; height: 300px;">
							
						</ul>
					</div>
				</div>
			</fieldset>
		</form>
	</div>
	
	<div id="windowView" class="removeBorda" title="Contato" style="display: none">
		<div style="height: auto !important;">
			<div style="width: 250px; float: left;">
				<h4>Informações Pessoais</h4>
				<div class="alignLine">
					<hr>
				</div>
				<strong>Nome: </strong><span id="viewNome"></span><br />
				<strong>Apelido: </strong><span id="viewApelido"></span><br />
				<strong>Usuário: </strong><span id="viewUsuario"></span><br />
				<strong>Aniverssário: </strong><span id="viewAniverssario"></span><br />
			</div>
			<div style="width: 250px; float: left;">
				<h4>Informações de Contato</h4>
				<div class="alignLine">
					<hr>
				</div>																
				<div id="viewInfo">
					<!--MODELO DE INFORMACAO 
						<strong>aqui o tipo</strong><span>aqui a descricao</span><br />
					-->
				</div>
			</div>			
			<div style="width: 250px; float: left;">
				<h4>Endereço</h4>
				<div class="alignLine">
					<hr>
				</div>																
				<strong>CEP: </strong><span id="viewCep"></span><br />
				<strong>Endereço: </strong><span id="viewEndereco"></span><br />
				<strong>Complemento: </strong><span id="viewComplemento"></span><br />
				<strong>Bairro: </strong><span id="viewBairro"></span><br />
				<strong>Cidade: </strong><span id="viewCidade"></span><br />
			</div>
			<div style="float: left; margin-top: 10px; margin-right: 0 !important; padding-right: 0 !important">
				<h4 style="width: 500px !important">Informações de Trabalho</h4>
				<div class="alignLine" style="width: 733px">
					<hr>
				</div>
			</div>			
			<div style="width: 375px; float: left;">																	
				<strong>Empresa: </strong><span id="viewTrabalho"></span><br />
				<strong>Cargo: </strong><span id="viewCargo"></span><br />
				<strong>Ramo: </strong><span id="viewSetor"></span> </span><br />
				<strong>Web-site: </strong><span id="viewSite"></span><br />
				<strong>Fone: </strong><span id="viewFone"></span><br />
			</div>
			<div style="width: 375px; float: left;">
				<strong>CEP: </strong><span id="viewCepEmp"></span><br />
				<strong>Endereço: </strong><span id="viewEnderecoEmp"></span><br />
				<strong>Complemento: </strong><span id="viewComplementoEmp"></span><br />
				<strong>Bairro: </strong><span id="viewBairroEmp"></span><br />
				<strong>Cidade: </strong><span id="viewCidadeEmp"></span><br />
			</div>
		</div>
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
						<jsp:param name="currPage" value="Agenda Telefonica"/>
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
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="#" onclick="editBlocoNota()">Bloco de Notas</a>
						</div>						
					</div>
					<div class="topContent">
						<div class="indexTitle">
							<div id="fot" class="textBox"style="width: 103px; height: 137px;">
								<img src="<%=(login.getFoto() != null)? login.getFoto(): "../image/foto.gif" %>" width="103" height="137"/>
							</div>
							<h4 style="margin-left: 150px" >Usuario: <%= login.getUsername() %></h4>
							<input type="hidden" id="usuario" name="usuario" value="<%= login.getUsername() %>" />
							<h4 style="margin-left: 150px">Seja bem vindo a sua agenda.</h4>
							<h4 style="margin-left: 150px">Tenha um Bom dia!</h4>
							<div class="textBox" style="margin-left: 19px;" >
								<label class="titleCounter" style="float: left; position: absolute;">Grupos: <%= grupos.size() %></label>
							</div><br />
							<div class="textBox" style="margin-left: -16px;" >
								<label class="titleCounter" style="float: left; margin-top: 3px; position: absolute;">Contatos: <%= gridLines %></label>
							</div>
							<div class="textBox" style="margin-left: -16px;" >
								<label class="titleCounter" style="float: left; margin-top: 19px; position: absolute;">Aniverssariantes do mês: <%= aniverssariantes %></label>
							</div>
						</div>
					</div>
				</div>
				<div id="mainContent">
					<div class="indexTitle">
						<div class="textBox">
							<label>Nome</label><br />
							<input type="text" id="nomeContato" name="nomeContato" style="width: 400px;" />
						</div>
						<div class="textBox">
							<label>Mês de Aniverssário</label><br />
							<select id="mesNiver" style="width: 180px">
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
					</div>
					<div class="buttonContent">
						<%if (grupos.size() > 0) {%>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Novo Contato" onclick="location.href = 'cadastro_catalogo.jsp'" />
							</div>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Editar Grupo" onclick="cadastroGrupo('e')" />
							</div>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="submit" value="Buscar"/>
							</div>
						<%} else {%>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Iniciar" onclick="cadastroGrupo('e')" />
							</div>
						<%}%>
					</div>
					<div class="indexTitle bordaBurra" style="margin-top: 0 !important; width: 248px;">
						<h4>Grupos</h4>
						<div class="alignLine">
							<hr>
						</div>										
						<%for(Grupo grupo: grupos) {
							query = sess.createQuery("select count(*) from ItensGrupo as i where i.id.grupo = :grupo");
							query.setEntity("grupo", grupo);%>
							<div style="width: 100%; margin-bottom: 15px; ">
								<a href="#" class="sair" style="margin-left: 0; bottom: 0;" onclick="setSelected(this); setGrp(<%= grupo.getCodigo() %>)" ondblclick="setSelected(this); setGrp(''); cadastroGrupo(true);"><%= grupo.getDescricao() + " - " + query.uniqueResult().toString() %></a>
							</div>
						<%}%>
						<div style="width: 100%; margin-bottom: 15px; ">
							<a href="#" class="sair selctedGrp" style="margin-left: 0; bottom: 0;" onclick="setSelected(this); setGrp('')">Todos - <%=  gridLines %></a>							
						</div>
						<div class="alignLine">
							<hr>
						</div>
						<input type="hidden" id="grp" name="grp" />
					</div>
					<div class="indexTitle" style="margin-top: 0 !important; width: 735px;">
						<h4>Lista de Contatos</h4>
						<div class="alignLine">
							<hr>
						</div>
						<div id="counter" class="counter"></div>
						<div id="dataGrid" style="width: 685px;">
							<%InformacaoCatalogo informacaoCatalogo = null;
							DataGrid dataGrid = new DataGrid(null);
							dataGrid.addColum("60", "Nome");
							dataGrid.addColum("20", "tipo");
							dataGrid.addColum("20", "Contato");
							for(ItensGrupo iten: itensGrupo) {
								dataGrid.setId(String.valueOf(iten.getId().getCatalogo().getCodigo()));
								dataGrid.addData(Util.initCap(iten.getId().getCatalogo().getNome()));
								query = sess.createQuery("from InformacaoCatalogo as i where i.catalogo = :catalogo and i.principal = 's'");
								query.setEntity("catalogo", iten.getId().getCatalogo());
								if (query.list().size() > 0) {
									informacaoCatalogo = (InformacaoCatalogo) query.list().get(0);
									dataGrid.addData(informacaoCatalogo.getTipo());
									dataGrid.addData(informacaoCatalogo.getDescricao());
								} else {
									dataGrid.addData("--------");
									dataGrid.addData("--------");
								}
								dataGrid.addRow();
							}
							out.print(dataGrid.getTable(gridLines));
							%>
							<div id="pagerGrid" class="pagerGrid"></div>
						</div>
					</div>
					<div class="buttonContent" style="margin-top: 20px;">
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Imp. Simples" onclick="printContato()" />
						</div>
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Imp. Detalhes" onclick="printCompleto()" />
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