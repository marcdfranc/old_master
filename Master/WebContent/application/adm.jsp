<%@page import="com.marcsoftware.database.Informacao"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Fisica"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Session"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page errorPage="/exception.jsp" %>
<%	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	String errorMessagePop = "";
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
%> 

<html>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
    <script type="text/javascript" src="../js/jquery/interface.js"></script>	
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>	
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>    
	<script type="text/javascript" src="../js/comum/adm.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	
	<title>Maste Administradores</title>
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
			<form id="unit" method="get" onsubmit="return search()">
				<input type="hidden" name="msgError" id="msgError" value="<%= errorMessagePop %>" />
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Administradores"/>			
					</jsp:include>
					<div class="topContent">
						<div id="codigo" class="textBox" style="width: 70px;">
							<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 70px;"/>												
						</div>
						<div id="nome" class="textBox" style="width: 254px;">
							<label>Nome</label><br/>
							<input id="nomeIn" name="nomeIn" type="text" style="width: 254px;"/>
						</div>
						<div id="cpf" class="textBox" style="width: 100px">
							<label>Cpf</label><br/>
							<input id="cpfIn" name="cpfIn" type="text" style="width: 100px" onkeydown="mask(this, cpf);"/>
						</div>
						
					</div>
				</div>
				<div class="topButtonContent">
					<div class="formGreenButton">
						<input id="buscar" name="insertConta" class="greenButtonStyle" type="submit" value="Buscar"/>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<% 
						try {							
							Query query = sess.createQuery("from Fisica as f where f.isAdm = 't' order by f.codigo");
							int gridLines= query.list().size();
							query.setFirstResult(0);
							query.setMaxResults(30);
							List<Fisica> fisicaList = (List<Fisica>) query.list();
							
							Informacao informacao = null;
							
							DataGrid dataGrid = new DataGrid("cadastro_administrador.jsp");
							dataGrid.addColum("10", "Código");
							dataGrid.addColum("50", "Nome");
							dataGrid.addColum("15", "CPF");
							dataGrid.addColum("10", "Usuario");
							dataGrid.addColum("5", "Fone");
							dataGrid.addColum("10", "Cadastro");
							for(Fisica fisica: fisicaList) {
								query = sess.getNamedQuery("informacaoPrincipal");
								query.setEntity("pessoa", fisica);
								query.setFirstResult(0);
								query.setMaxResults(1);
								informacao = (Informacao) query.uniqueResult();
								dataGrid.setId(String.valueOf(fisica.getCodigo()));
								dataGrid.addData(String.valueOf(fisica.getCodigo()));
								dataGrid.addData(Util.initCap(fisica.getNome()));
								dataGrid.addData(Util.mountCpf(fisica.getCpf()));
								dataGrid.addData((fisica.getLogin() == null)? "" :
										fisica.getLogin().getUsername());
								dataGrid.addData((informacao== null)? "" : informacao.getDescricao());
								dataGrid.addData(Util.parseDate(fisica.getCadastro(), "dd/MM/yyyy"));
								dataGrid.addRow();
							}
							out.print(dataGrid.getTable(gridLines));
						} catch (Exception e) {
							e.printStackTrace();
							errorMessagePop = "Esta página não pode ser visualizada corretamente devido a um erro interno!";
						} finally {
							sess.close();
						}%>
						<div id="pagerGrid" class="pagerGrid"></div>
					</div>					
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
	</div>
</body>
</html>