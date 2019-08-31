<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Query"%>
<%@page import="org.hibernate.Session"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Dependente"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/comum/dependente.js" ></script>
	
	<%!Query query; %>
	<%!Session sess; %>
	<%! List<Unidade> unidadeList; %>	
	<%sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	if (session.getAttribute("perfil").equals("a")) {
		query= sess.createQuery("from Unidade as u where u.deleted =\'n\'");		
	} else if (session.getAttribute("perfil").equals("f")) {
		query= sess.getNamedQuery("unidadeByUser");
		query.setString("username", (String) session.getAttribute("username"));
	} else {
		query = sess.createQuery("select p.unidade from Pessoa as p where p.login = :username");
		query.setString("username", (String) session.getAttribute("username"));
	}
	unidadeList= (List<Unidade>) query.list();
	%>	
	<title>Master - Dependentes</title>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>	
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="clienteF"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="clienteF"/>			
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="get" onsubmit="return search()">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Dependentes"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="empresa.jsp">Cliente Jurídico</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="cliente_fisico.jsp">Cliente Fisico</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Dependentes</label>
						</div>
					</div>
					<div class="topContent">
						<div>
							<input type="hidden" name="codUser" id="codUser" value="<%=(request.getParameter("id") == null)? "": request.getParameter("id")%>"/>
						</div>
						<div id="refTitular" class="textBox" style="width: 70px;">
							<label>CTR</label><br/>
							<input id="refTitularIn" name="refTitularIn" type="text" style="width: 70px;"/>												
						</div>
						<div id="referencia" class="textBox" style="width: 50px;">
							<label>Ref.</label><br/>
							<input id="referenciaIn" name="referenciaIn" type="text" style="width: 50px;"/>												
						</div>
						<div id="nome" class="textBox" style="width: 231px;">
							<label>Nome</label><br/>
							<input id="nomeIn" name="nomeIn" type="text" style="width: 100%"/>
						</div>
						<div id="cpf" class="textBox" style="width: 100px">
							<label>Cpf</label><br/>
							<input id="cpfIn" name="cpfIn" type="text" style="width: 100px" onkeydown="mask(this, cpf);"/>
						</div>
						<div id="nascimentoCalendar" class="textBox" style="width: 73px;">
							<label>Nascimento</label><br/>
							<input id="nascimentoIn" name="nascimentoIn" type="text" style="width: 73px;" onkeydown="mask(this, typeDate);"/>
						</div>
						<div id="referencia" class="textBox" style="width: 70px;">
							<label>Código</label><br/>
							<input id="codUserIn" name="codUserIn" type="text" style="width: 70px;"/>												
						</div>
						<div id="tel" class="textBox" style="width: 80px">
							<label>Telefone</label><br/>					
							<input id="telIn" name="telIn" type="text" style="width: 80px"/>
						</div>
						<div id="status" class="textBox" style="width: 90px">
							<label >Status</label><br />
							<select id="ativoChecked" name="ativoChecked">
								<option value="">Todos</option>
								<option value="a">Ativo</option>
								<option value="b">Bloqueado</option>
								<option value="c">Cancelado</option>
							</select>
						</div>
						<div id="unidadeIn" class="textBox" style="width: 303px;">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId" style="width: 100%">
								<option value="0@0">Selecione</option>
								<%if (unidadeList.size() == 1) {
									out.print("<option value=\"" + 
											unidadeList.get(0).getRazaoSocial() + "@" +
											unidadeList.get(0).getCodigo() + 
											"\" selected=\"selected\">" + 
											unidadeList.get(0).getReferencia() + " - " +
											unidadeList.get(0).getDescricao() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										out.print("<option value=\"" + un.getRazaoSocial() + "@" +
											un.getCodigo() + "\">" + un.getReferencia() + " - " + 
											un.getDescricao() +	"</option>");
									}									
								}
								%>
							</select>
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
						DataGrid dataGrid= new DataGrid(null);
						if (request.getParameter("id") != null) {
							if (session.getAttribute("perfil").toString().equals("a")
									|| session.getAttribute("perfil").toString().equals("d")) {
								query = sess.createQuery("from Dependente as d where d.usuario.codigo = :usuario order by d.usuario.nome");
								query.setLong("usuario", Long.valueOf(request.getParameter("id")));
							} else {
								query = sess.createQuery("from Dependente as d " +
										" where d.usuario.codigo = :usuario order by d.usuario.nome");
								query.setLong("usuario", Long.valueOf(request.getParameter("id")));
							}
						} else {
							if (session.getAttribute("perfil").toString().equals("a")
									|| session.getAttribute("perfil").toString().equals("d")) {								
								query = sess.createQuery("from Dependente as d order by d.nome");
							} else {
								query = sess.createQuery("from Dependente as d " +
									"where d.usuario.unidade.codigo = :unidade order by d.nome");
								query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
							}
						}
						int gridLines = query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(30);
						List<Dependente> dependente = (List<Dependente>) query.list();
						dataGrid.addColumWithOrder("5", "CTR", false);
						dataGrid.addColumWithOrder("5", "Ref.", false);
						dataGrid.addColumWithOrder("36", "Nome", true);
						dataGrid.addColum("20", "CPF");
						dataGrid.addColumWithOrder("5", "Nascimento", false);
						dataGrid.addColum("20", "Fone");
						dataGrid.addColum("7" ,"Trat.");
						for (Dependente dep: dependente) {
							dataGrid.setId(String.valueOf(dep.getCodigo()));
							dataGrid.addData(dep.getUsuario().getReferencia());
							dataGrid.addData(dep.getReferencia());
							dataGrid.addData(Util.initCap(Util.encodeString(dep.getNome(), "UTF8", "ISO-8859-1")));
							dataGrid.addData((dep.getCpf() == null)?
									"" : Util.mountCpf(dep.getCpf()));
							dataGrid.addData((dep.getNascimento() == null)? "" : Util.parseDate(dep.getNascimento(), "dd/MM/yyyy"));							
							dataGrid.addData(dep.getFone());
							
							query = sess.getNamedQuery("parcelaByDependente");							
							query.setEntity("usuario", dep.getUsuario());
							query.setEntity("dependente", dep);
							
							dataGrid.addImg((query.list().size() == 0)? "../image/ok_icon.png" : 
								Util.getIcon(query.list(), "orcamento"));			
							
							dataGrid.addRow();														
						}
						out.print(dataGrid.getTable(gridLines));
						sess.close();
						%>
						<div id="pagerGrid" class="pagerGrid"></div>					
					</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
	</div>
</body>
</html>