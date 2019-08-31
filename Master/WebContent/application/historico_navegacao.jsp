<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.HistoricoNavegacao"%>
<%@page import="com.marcsoftware.database.Acesso"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%><html>
	<%Session sess = (Session) session.getAttribute("hb");
		if (!sess.isOpen()) {
			sess = HibernateUtil.getSession();
		}
		Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
		Query query = null;
		List<HistoricoNavegacao> historicoNavegacao= null;
		Acesso acesso = (Acesso) sess.load(Acesso.class, Long.valueOf(request.getParameter("id")));
	%>
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
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/comum/historico_navegacao.js" ></script>
		
	<title>Master - Historico de navegacao</title>
</head>
<body onload="load()">
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="forum"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="forum"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formPost" method="get" onsubmit= "return search()">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Hist. Navegação"/>
					</jsp:include>
					<div class="topContent">
						<div id="unidade" class="textBox" style="width: 107px;">
							<label>Cód. Unid.</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" style="width: 107px;" readonly="readonly" value="<%= (acesso.getUnidade() == null)? "Várias" : acesso.getUnidade().getReferencia() %>"/>
						</div>
						<div id="codigo" class="textBox" style="width: 117px;">
							<label>Cód. Acesso</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 117px;" readonly="readonly" value="<%= acesso.getCodigo()  %>"/>
						</div>
						<div id="inicio" class="textBox" style="width: 90px;">
							<label>Data Etrada</label><br/>
							<input id="inicioIn" name="inicioIn" type="text" style="width: 90px;" readonly="readonly" value="<%= Util.parseDate(acesso.getEntrada(), "dd/MM/yyyy") %>"/>
						</div>
						<div id="hrInicio" class="textBox" style="width: 90px;">
							<label>Hora Entrada</label><br/>
							<input id="hrInicioIn" name="hrInicioIn" type="text" style="width: 90px;" readonly="readonly" value="<%= Util.getTime(acesso.getEntrada()) %>"/>
						</div>
						<div id="fim" class="textBox" style="width: 90px;">
							<label>Data Saída</label><br/>
							<input id="fimIn" name="fimIn" type="text" style="width: 90px;" readonly="readonly" value="<%=(acesso.getSaida() == null)? "" : Util.parseDate(acesso.getSaida(), "dd/MM/yyyy") %>"/>
						</div>
						<div id="hrFim" class="textBox" style="width: 90px;">
							<label>Hora Saída</label><br/>
							<input id="hrFimIn" name="hrFimIn" type="text" style="width: 90px;" readonly="readonly" value="<%=(acesso.getSaida() == null)? "" : Util.getTime(acesso.getSaida()) %>"/>
						</div>						
						<div id="usuario" class="textBox" style="width: 322px;">
							<label>Usuário</label><br/>
							<input id="usuarioIn" name="usuarioIn" type="text" style="width: 322px;" readonly="readonly" value="<%= acesso.getLogin().getUsername() %>"/>
						</div>
						<div id="ip" class="textBox" style="width: 322px;">
							<label>Número IP</label><br/>
							<input id="ipIn" name="ipIn" type="text" style="width: 322px;" readonly="readonly" value="<%= acesso.getIp() %>"/>
						</div>
					</div>
				</div>
				<div id="mainContent">
					<div id="dadosPessoais" class="bigBox" >
						<div class="indexTitle">
							<h4>Histórico de navegação</h4>
							<div class="alignLine">
								<hr>
							</div>
							<div id="counter" class="counter"></div>
							<div id="dataGrid">						
								<%query = sess.createQuery("from HistoricoNavegacao as h where h.acesso = :acesso order by h.codigo desc");
								query.setEntity("acesso", acesso);
								int gridLines = query.list().size();
								query.setFirstResult(0);
								query.setMaxResults(30);
								historicoNavegacao = (List<HistoricoNavegacao>) query.list();
								DataGrid dataGrid = new DataGrid("");
								dataGrid.addColum("8", "Código");
								dataGrid.addColum("12", "Data");
								dataGrid.addColum("10", "Hora");
								dataGrid.addColum("70", "Endereço - URL");															
								for(HistoricoNavegacao historico : historicoNavegacao) {
									dataGrid.setId(String.valueOf(historico.getCodigo()));
									dataGrid.addData(String.valueOf(historico.getCodigo()));
									dataGrid.addData(Util.parseDate(historico.getData(), "dd/MM/yyyy"));
									dataGrid.addData(Util.getTime(historico.getData()));
									dataGrid.addData(historico.getUrl());
									dataGrid.addRow();
								}
								out.print(dataGrid.getTable(gridLines));
								%>
							</div>
							<div id="pagerGrid" class="pagerGrid"></div>
						</div>
					</div>					
				</div>			
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close(); %>
	</div>
</body>
</html>