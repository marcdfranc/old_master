<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.database.Notificacao"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Login"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.AcessoNotificacao"%>
<%@page import="com.marcsoftware.database.Unidade"%><html>
<jsp:useBean id="notificacao" class="com.marcsoftware.database.Notificacao"></jsp:useBean>
<%!boolean isEdition= false;%>		
	<%isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}	
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
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
	query = sess.createQuery("from Login as l where l.perfil = 'r' order by l.username");
	List<Login> loginAtendenteList = (List<Login>) query.list(); 
	query = sess.createQuery("from Login as l where l.perfil = 'f' order by l.username");
	List<Login> loginAdmList = (List<Login>) query.list();
	List<AcessoNotificacao> acessoList = null;
	query = sess.createQuery("from Login as l where l.username = :username");
	query.setString("username", session.getAttribute("username").toString());
	Login loginUsuario = (Login) query.uniqueResult();
	boolean haveGrid = true;
	boolean isRead = false;
	if (isEdition) {
		notificacao = (Notificacao) sess.load(Notificacao.class, Long.valueOf(request.getParameter("id")));		
		query = sess.createQuery("from AcessoNotificacao as a where a.id.notificacao = :notificacao");
		query.setEntity("notificacao", notificacao);		
		acessoList = (List<AcessoNotificacao>) query.list();
		haveGrid = session.getAttribute("username").toString().equals(notificacao.getRemetente().getUsername());
		if (!haveGrid) {
			query = sess.createQuery("from AcessoNotificacao as a where a.id.notificacao = :notificacao " +
				" and a.id.login.username = :username");
			query.setEntity("notificacao", notificacao);
			query.setString("username", session.getAttribute("username").toString());
			if (query.list().size() == 1) {
				isRead = ((AcessoNotificacao) query.uniqueResult()).getVisualizada().equals("s");
			}
		}
	}
%>	
<head>
	<link rel="shortcut icon" href="../icone.ico"/>
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	
	<title>Master - Cadastro de Notificação</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/validation.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/comum/cadastro_notificacao.js" ></script>
	<script type="text/javascript" src="../js/lib/pilot_grid.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
</head>
<body onload="loadPage(<%= isEdition %>)">
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="forum"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="forum"/>			
		</jsp:include>
		<div id="formStyle">
			<form id="formPost" name="formPost" method="post" action="../CadastroNotificacao" onsubmit="return false;">
				<div id="localContato"></div>
				<div id="deletedsContato"></div>
				<input type="hidden" name="codNotificacao" id="codNotificacao" value="<%=(isEdition)? notificacao.getCodigo() : "" %>">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Nova Notificação"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="notificacao.jsp">Todas</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="notificacao.jsp?tipo=l">Lidas</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="notificacao.jsp?tipo=n">Não lidas</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="notificacao.jsp?tipo=e">Enviadas</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Nova Notificação</label>
						</div>						
					</div>
					<div class="topContent">
						<div class="indexTitle">
							<div id="fot" class="textBox"style="width: 103px; height: 137px;">
								<img src="<%=(loginUsuario.getFoto() != null)? loginUsuario.getFoto(): "../image/foto.gif" %>" width="103" height="137"/>
							</div>
							<h4 style="margin-left: 150px" >Usuario: <%= loginUsuario.getUsername() %></h4>
							<h4 style="margin-left: 150px">Seja bem vindo a sua area de notificações.</h4>
							<h4 style="margin-left: 150px">Tenha um Bom dia!</h4>
						</div>				
					</div>
				</div>
				<div id="mainContent">
					<div id="itensOrcamento" class="bigBox" >
						<div class="indexTitle">
							<h4>Nova Mensagem</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>						
						<%if (isEdition) {%>
							<div id="data" class="textBox" style="width: 275px;" >
								<label>Data</label><br/>
								<input id="dataIn" name="dataIn" readonly="readonly" type="text" style="width: 270px;" value="<%=(isEdition)? Util.parseDate(notificacao.getData(), "dd/MM/yyyy") : "" %>" />
							</div>
						<%}%>
						<div class="area" id="descricao" name="descricao" style="margin-bottom: 30px">
							<label>Texto</label><br/>
							<textarea cols="112" rows="15" <%if (!haveGrid) {%> readonly="readonly" <%}%> id="descricaoIn" name="descricaoIn"><%=(isEdition)? notificacao.getDescricao() : "" %></textarea>							
						</div>
					</div>
					<%if (haveGrid) {%>
						<div id="itensOrcamento" class="bigBox" >
							<div class="indexTitle">
								<h4>Destinatários</h4>
								<div class="alignLine">
									<hr>
								</div>
							</div>
							<div id="unidade" class="textBox">
								<label>Cod. Unid.</label><br/>
								<select id="unidadeIn" name="unidadeIn" type="select-multiple">
									<option value="">Selecione</option>
									<%if (unidadeList.size() == 1) {
										out.print("<option value=\"" + unidadeList.get(0).getCodigo() + 
												"\" selected=\"selected\">" + unidadeList.get(0).getReferencia() + "</option>");
									} else {
										for(Unidade un: unidadeList) {
											out.print("<option value=\"" + un.getCodigo() + 
													"\">" + un.getReferencia() + "</option>");
										}									
									}
									%>
								</select>
							</div>
							<div id="contato" class="textBox">
								<label>Usuário ADM</label><br/>
								<select type="select-multiple" id="contatoIn" name="contatoIn" onblur="genericValid(this);" style="width: 200px" >
									<option value="">Selecione</option>
									<option value="allCombo">Todos</option>
									<%
									for(Login login: loginAdmList) {
										out.print("<option value=\"" + login.getUsername() + "@" + login.getFoto() +
												"@" + login.getPerfil() + "\">" + login.getUsername() + "</option>");
									}%>
								</select>
							</div>
							<div id="contatoAtendente" class="textBox">
								<label>Usuário Atendente</label><br/>
								<select type="select-multiple" id="contatoAtendenteIn" name="contatoAtendenteIn" onblur="genericValid(this);" style="width: 200px" >
									<option value="">Selecione</option>
									<option value="allCombo">Todos</option>
									<%
									for(Login login: loginAtendenteList) {
										out.print("<option value=\"" + login.getUsername() + "@" + login.getFoto() +
												"@" + login.getPerfil() + "\">" + login.getUsername() + "</option>");
									}%>
								</select>
							</div>
							<div id="assunto" class="textBox" style="width: 380px;" >
								<label>Assunto</label><br/>
								<input id="assuntoIn" name="assuntoIn" <%if (!haveGrid) {%> readonly="readonly" <%}%> type="text" style="width: 380px;" value="<%=(isEdition)? notificacao.getAssunto() : "" %>" />
							</div>
							<div id="prioridade" class="textBox" style="width: 105px">
								<label>Prioridade</label><br/>
								<select class="required" onblur="genericValid(this);" style="width: 105px;" type="select-multiple" id="prioridadeIn" name="prioridadeIn" <%if (!haveGrid) {%> disabled="disabled" <%}%>>
									<option value="">Selecione</option>
									<option value="b" <%if (isEdition && notificacao.getPrioridade().equals("b")){%> selected="selected" <%}%> >Baixa</option>									
									<option value="m" <%if (isEdition && notificacao.getPrioridade().equals("m")){%> selected="selected" <%}%>>Média</option>
									<option value="a" <%if (isEdition && notificacao.getPrioridade().equals("a")){%> selected="selected" <%}%>>Alta</option>
								</select>
							</div>
							<div id="status" class="textBox" style="width: 105px">
								<label>Banner</label><br/>
								<select class="required" onblur="genericValid(this);" style="width: 105px;" type="select-multiple" id="statusIn" name="statusIn" <%if (!haveGrid) {%> disabled="disabled" <%}%>>
									<option value="">Selecione</option>
									<option value="a" <%if (isEdition && notificacao.getStatus().equals("a")){%> selected="selected" <%}%> >Exibir</option>									
									<option value="i" <%if (isEdition && notificacao.getStatus().equals("i")){%> selected="selected" <%}%>>Não Exibir</option>								
								</select>
							</div>
							<div class="buttonContent" style="margin-bottom: 30px;">					
								<div class="formGreenButton">
									<input class="greenButtonStyle" type="button" value="Excluir" onclick="removeRowServico()" />
								</div>
								<div class="formGreenButton" >
									<input id="specialButton" name="insertTabela" class="greenButtonStyle" type="button" value="Inserir" onclick="addRowServico()" />
								</div>
							</div>
							<div id="dataGrid">
								<%DataGrid dataGrid = new DataGrid("#");
								dataGrid.addColum("15", "foto");
								dataGrid.addColum("20", "Usuário");
								dataGrid.addColum("45", "Perfil");
								dataGrid.addColum("3", "Visualizada");
								dataGrid.addColum("2", "Ck");
								//totalServico = 0;
								if (isEdition) {
									for (AcessoNotificacao acesso: acessoList) {								
										dataGrid.setId("");
										dataGrid.addImg(acesso.getId().getLogin().getFoto(), "rowFoto", "style=\"height:60px;width:55px;");
										dataGrid.addData("rowUser", acesso.getId().getLogin().getUsername());
										switch (acesso.getId().getLogin().getPerfil().charAt(0)) {
											case 'f':									
										
											case 'a':
												dataGrid.addData("rowPerfil", "Administrador");
												break;
												
											case 'd':
												dataGrid.addData("rowPerfil", "Desenvolvedor");
												break;
												
											case 'r':
												dataGrid.addData("rowPerfil", "Atendente");
												break;
										}								
										dataGrid.addData("rowVista", (acesso.getVisualizada().equals("s"))? "Sim" : "Não");
										dataGrid.addCheck(true);
										dataGrid.addRow();
									}
								}
								out.print(dataGrid.getTable(0));						
								%>
							</div>						
						</div>
						<div class="buttonContent" style="margin-top: 100px;">
							<div class="formGreenButton">						
								<input class="greenButtonStyle" type="button" value="Enviar" onclick="enviarNotificacao()" />
							</div>
						</div>
					<%} else if(!isRead) {%>
						<div class="buttonContent" style="margin-top: 100px;">
							<div class="formGreenButton">						
								<input class="greenButtonStyle" type="button" value="Marcar Lida" onclick="marcarLida()" />
							</div>
						</div>
					<%}%>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>