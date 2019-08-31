<% if (request.getSession().getAttribute("perfil").toString().trim().equals("a")) { %>
<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query = null;
	List<Unidade> unidadeList = null;
	int cadastrados = 0;
	int ativos = 0;
	int bloqueados = 0;
	int cancelados = 0;
	int adimplentes = 0;
	int c1 = 0;
	int c2 = 0;
	int c3 = 0;
	int c4 = 0;
	int c5 = 0;
	int cMais = 0;	
	if (session.getAttribute("perfil").equals("a")) {
		query = sess.createQuery("from Unidade as u where u.deleted =\'n\'");
		unidadeList = (List<Unidade>) query.list();
		query = sess.createSQLQuery("SELECT COUNT(*) FROM usuario");
		cadastrados = Integer.parseInt(query.uniqueResult().toString());
		query = sess.createSQLQuery("SELECT COUNT(*) FROM usuario AS u " + 
				" INNER JOIN pessoa AS p USING(codigo) WHERE p.ativo = 'a'");
		ativos = Integer.parseInt(query.uniqueResult().toString());
		query = sess.createSQLQuery("SELECT COUNT(*) FROM usuario AS u " + 
				" INNER JOIN pessoa AS p USING(codigo) WHERE p.ativo = 'b'");
		bloqueados = Integer.parseInt(query.uniqueResult().toString());		
		cancelados = cadastrados - (ativos + bloqueados);
		query = sess.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " + 
				" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
				" WHERE p.ativo = 'a' AND (d.atraso BETWEEN 0 AND 30)");
		c1 = Integer.parseInt(query.uniqueResult().toString());
		query = sess.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " + 
				" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
				" WHERE p.ativo = 'a' AND (d.atraso BETWEEN 30 AND 60)");
		c2 = Integer.parseInt(query.uniqueResult().toString());
		query = sess.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " + 
				" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
				" WHERE p.ativo = 'a' AND (d.atraso BETWEEN 60 AND 90)");
		c3 = Integer.parseInt(query.uniqueResult().toString());
		query = sess.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " + 
				" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
				" WHERE p.ativo = 'a' AND (d.atraso BETWEEN 90 AND 120)");
		c4 = Integer.parseInt(query.uniqueResult().toString());
		query = sess.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " + 
				" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
				" WHERE p.ativo = 'a' AND (d.atraso BETWEEN 120 AND 150)");
		c5 = Integer.parseInt(query.uniqueResult().toString());
		query = sess.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " +
				" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
				" WHERE p.ativo = 'a' AND (d.atraso > 150)");
		cMais = Integer.parseInt(query.uniqueResult().toString());
		adimplentes = ativos - (c1 + c2 + c3 + c4 + c5 + cMais);
	} else {
		query= sess.getNamedQuery("unidadeByUser");
		query.setString("username", (String) session.getAttribute("username"));
		unidadeList = (List<Unidade>) query.list();
		query = sess.createSQLQuery("SELECT COUNT(*) FROM usuario AS u " +
				" INNER JOIN pessoa AS p USING(codigo) " +
				" INNER JOIN unidade AS n ON(n.codigo = p.cod_unidade) " +				
				" INNER JOIN pessoa AS e ON(e.codigo = n.administrador) " +
				" WHERE e.username = :admnistrador");
		query.setString("admnistrador", (String) session.getAttribute("username"));
		cadastrados = Integer.parseInt(query.uniqueResult().toString());		
		query = sess.createSQLQuery("SELECT COUNT(*) FROM usuario AS u " + 
				" INNER JOIN pessoa AS p USING(codigo) " +
				" INNER JOIN unidade AS n ON(n.codigo = p.cod_unidade) " +				
				" INNER JOIN pessoa AS e ON(e.codigo = n.administrador) " +
				" WHERE e.username = :admnistrador " + 
				" AND p.ativo = 'a' ");
		query.setString("admnistrador", (String) session.getAttribute("username"));
		ativos = Integer.parseInt(query.uniqueResult().toString());
		query = sess.createSQLQuery("SELECT COUNT(*) FROM usuario AS u " + 
				" INNER JOIN pessoa AS p USING(codigo) " +
				" INNER JOIN unidade AS n ON(n.codigo = p.cod_unidade) " +				
				" INNER JOIN pessoa AS e ON(e.codigo = n.administrador) " +
				" WHERE e.username = :admnistrador " + 
				" AND p.ativo = 'b' ");
		query.setString("admnistrador", (String) session.getAttribute("username"));
		bloqueados = Integer.parseInt(query.uniqueResult().toString());		
		cancelados = cadastrados - (ativos + bloqueados);
		query = sess.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " + 
				" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
				" INNER JOIN unidade AS n ON(n.codigo = p.cod_unidade) " +
				" INNER JOIN pessoa AS e ON(e.codigo = n.administrador) " +
				" WHERE p.ativo = 'a' AND e.username = :admnistrador " +
				" AND (d.atraso BETWEEN 0 AND 30)");
		query.setString("admnistrador", (String) session.getAttribute("username"));
		c1 = Integer.parseInt(query.uniqueResult().toString());
		query = sess.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " + 
				" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
				" INNER JOIN unidade AS n ON(n.codigo = p.cod_unidade) " +
				" INNER JOIN pessoa AS e ON(e.codigo = n.administrador) " +
				" WHERE p.ativo = 'a' AND e.username = :admnistrador " +
				" AND (d.atraso BETWEEN 30 AND 60)");
		query.setString("admnistrador", (String) session.getAttribute("username"));
		c2 = Integer.parseInt(query.uniqueResult().toString());		
		query = sess.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " + 
				" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
				" INNER JOIN unidade AS n ON(n.codigo = p.cod_unidade) " +
				" INNER JOIN pessoa AS e ON(e.codigo = n.administrador) " +
				" WHERE p.ativo = 'a' AND e.username = :admnistrador " +
				" AND (d.atraso BETWEEN 60 AND 90)");
		query.setString("admnistrador", (String) session.getAttribute("username"));
		c3 = Integer.parseInt(query.uniqueResult().toString());		
		query = sess.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " + 
				" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
				" INNER JOIN unidade AS n ON(n.codigo = p.cod_unidade) " +
				" INNER JOIN pessoa AS e ON(e.codigo = n.administrador) " +
				" WHERE p.ativo = 'a' AND e.username = :admnistrador " +
				" AND (d.atraso BETWEEN 90 AND 120)");
		query.setString("admnistrador", (String) session.getAttribute("username"));
		c4 = Integer.parseInt(query.uniqueResult().toString());
		query = sess.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " + 
				" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
				" INNER JOIN unidade AS n ON(n.codigo = p.cod_unidade) " +
				" INNER JOIN pessoa AS e ON(e.codigo = n.administrador) " +
				" WHERE p.ativo = 'a' AND e.username = :admnistrador " +
				" AND (d.atraso BETWEEN 120 AND 150)");
		query.setString("admnistrador", (String) session.getAttribute("username"));
		c5 = Integer.parseInt(query.uniqueResult().toString());
		query = sess.createSQLQuery("SELECT COUNT(*) FROM vw_debito_mensalidade AS d " +
				" INNER JOIN pessoa AS p ON(d.usuario = p.codigo) " +
				" INNER JOIN unidade AS n ON(n.codigo = p.cod_unidade) " +
				" INNER JOIN pessoa AS e ON(e.codigo = n.administrador) " +
				" WHERE p.ativo = 'a' AND e.username = :admnistrador " +
				" AND (d.atraso > 150)");
		query.setString("admnistrador", (String) session.getAttribute("username"));
		cMais = Integer.parseInt(query.uniqueResult().toString());
		adimplentes = ativos - (c1 + c2 + c3 + c4 + c5 + cMais);
	}%>

<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />	
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Painel de Cobrança</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/comum/painel_cobranca.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>
	<%if (request.getParameter("origem").equals("cli")) { %>
		<jsp:include page="../inc/menu.jsp">
			<jsp:param name="currentPage" value="clienteF"/>
		</jsp:include>
	<%} else {%>
		<jsp:include page="../inc/menu.jsp">
			<jsp:param name="currentPage" value="financeiro"/>
		</jsp:include>
	<%}%>
	<div id="centerAll">
		<%if (request.getParameter("origem").equals("cli")) { %>
			<jsp:include page="../inc/submenu.jsp">
				<jsp:param name="currentPage" value="clienteF"/>			
			</jsp:include>
		<%} else {%>
			<jsp:include page="../inc/submenu.jsp">
				<jsp:param name="currentPage" value="financeiro"/>			
			</jsp:include>
		<%}%>
		<div id="formStyle">
			<form id="parc" method="get">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Cobrança"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="sectedAba2">
							<label>Painel</label>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="cobranca_c1.jsp?dias=30&origem=<%= request.getParameter("origem") %>">Carteira 1</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="cobranca_c1.jsp?dias=60&origem=<%= request.getParameter("origem") %>">Carteira 2</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="cobranca_c1.jsp?dias=90&origem=<%= request.getParameter("origem") %>">Carteira 3</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="cobranca_c1.jsp?dias=120&origem=<%= request.getParameter("origem") %>">Carteira 4</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="cobranca_c1.jsp?dias=150&origem=<%= request.getParameter("origem") %>">Carteira 5</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="cobranca_c1.jsp?dias=180&origem=<%= request.getParameter("origem") %>">6 meses ou mais</a>
						</div>
					</div>
					<div class="topContent">
						<div id="unidadeIn" class="textBox">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId">
								<option value="0">Selecione</option>
								<%if (unidadeList.size() == 1) {
									out.print("<option value=\"" + unidadeList.get(0).getCodigo() + 
											"\" selected=\"selected\">" + 
											unidadeList.get(0).getReferencia() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										out.print("<option value=\"" + un.getCodigo() + "\">" + 
												un.getReferencia() + "</option>");
									}
								}
								%>
							</select>
						</div>
					</div>
					<div id="mainContent">
						<div id="responsavel" class="bigBox" >
							<div class="indexTitle" style="margin-bottom: 20px;">
								<h4>Painel de Cobrança</h4>
								<div class="alignLine">
									<hr>
								</div>
								<div style="width: 1000px;">
									<div id="dataGrid" >
										<div class="panelLines" style="width: 600px; background: url('../image/back_check.png') repeat-x top left; border-bottom: none !important;">
											<label id="headerLabel"  style="float: left;">Descrição</label>
										</div>								
										<div class="panelLines" style="width: 280px; background: url('../image/back_check.png') repeat-x top left; border-bottom: none !important;">
											<label id="headerResult" style="float: right;" >Qtde.</label>
										</div>								
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="cadastradosLabel" name="cadastradosLabel" href="#" style="float: left;">Clientes Cadastrados</a>
										</div>
										<div class="panelLines" style="width: 280px;">
											<a id="cadastrados" name="cadastrados" href="#" style="float: right;"><%= cadastrados%></a>
										</div>
									</div>								
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="ativosLabel" name="ativosLabel" href="#" style="float: left;">Clientes Ativos</a>
										</div>
										<div class="panelLines" style="width: 280px;">
											<a id="ativos" name="ativos" href="#" style="float: right;"><%= ativos %></a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="bloquadosLabel" name="bloquadosLabel" href="#" style="float: left;">Clientes Bloqueados</a>
										</div>
										<div class="panelLines" style="width: 280px;">
											<a id="bloqueados" name="bloqueados" href="#" style="float: right;"><%= bloqueados %></a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="canceladosLabel" name="canceladosLabel" href="#" style="float: left;">Clientes Cancelados</a>
										</div>
										<div class="panelLines" style="width: 280px;">
											<a id="cancelados" name="cancelados" href="#" style="float: right;"><%= cancelados %></a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="adimplentesLabel" name="adimplentesLabel" href="#" style="float: left;">Clientes em Dia</a>
										</div>
										<div class="panelLines" style="width: 280px;">
											<a id="adimplentes" name="adimplentes" href="#" style="float: right;"><%= adimplentes %></a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="c1Label" name="c1Label" href="#" style="float: left;">Clientes Carteira 1</a>
										</div>
										<div class="panelLines" style="width: 280px;">
											<a id="c1" name="c1" href="#" style="float: right;"><%= c1 %></a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="c2Label" name="c2Label" href="#" style="float: left;">Clientes Carteira 2</a>
										</div>
										<div class="panelLines" style="width: 280px;">
											<a id="c2" name="c2" href="#" style="float: right;"><%= c2 %></a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="c3Label" name="c3Label" href="#" style="float: left;">Clientes Carteira 3</a>
										</div>
										<div class="panelLines" style="width: 280px;">
											<a id="c3" name="c3" href="#" style="float: right;"><%= c3 %></a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="c4Label" name="c4Label" href="#" style="float: left;">Clientes Carteira 4</a>
										</div>
										<div class="panelLines" style="width: 280px;">
											<a id="c4" name="c4" href="#" style="float: right;"><%= c4 %></a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="c5Label" name="c5Label" href="#" style="float: left;">Clientes Carteira 5</a>
										</div>
										<div class="panelLines" style="width: 280px;">
											<a id="c5" name="c5" href="#" style="float: right;"><%= c5 %></a>
										</div>
									</div>
									<div id="dataGrid">
										<div class="panelLines" style="width: 600px;">										
											<a id="cMaisLabel" name="cMaisLabel" href="#" style="float: left;">Clientes com 6 meses ou mais atrasada</a>
										</div>
										<div class="panelLines" style="width: 280px;">
											<a id="c6" name="c6" href="#" style="float: right;"><%= cMais %></a>
										</div>
									</div>									
								</div>
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
<%} else {%>
	out.print("Ops, voce não tem privilégios suficientes para acessar esta tela!");
<%} %>