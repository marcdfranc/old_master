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
<%@page import="com.marcsoftware.database.Lancamento"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>	
	<script type="text/javascript" src="../js/comum/conta_receber.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_window.js"></script>
	
	<%!Query query; %>
	<%!Session sess; %>
	<%! List <Unidade> unidadeList; %>
	<%	sess = (Session) session.getAttribute("hb");
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
	<title>Master Contas a Receber</title>
</head>
<body onload="load()">
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="financeiro"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="financeiro"/>
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="get" onsubmit="return search()">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Contas a Receber"/>			
					</jsp:include>
					<div class="topContent">
						<div id="lanc" class="textBox" style="width: 70px;">
							<label>Código</label><br/>
							<input id="lancamentoIn" name="lancamentoIn" type="text" style="width: 70px;"/>												
						</div>
						<div id="documento" class="textBox" style="width: 220px;">
							<label>Documento</label><br/>
							<input id="documentoIn" name="documentoIn" type="text" style="width: 220px;"/>												
						</div>
						<div id="descricao" class="textBox" style="width: 260px;">
							<label>Descrição</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 260px;"/>
						</div>
						<div id="unidadeIn" class="textBox">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId">
								<%if (session.getAttribute("perfil").toString().equals("a")
										|| session.getAttribute("perfil").toString().equals("d")) {%>
									<option value="">Selecione</option>
								<%} else {%>
									<option value="0@0">Selecione</option>
								<%}%>
								<%if (unidadeList.size() == 1) {
									out.print("<option value=\"" + unidadeList.get(0).getRazaoSocial() + "@" + 
											unidadeList.get(0).getCodigo() + 
											"\" selected=\"selected\">" + unidadeList.get(0).getReferencia() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										out.print("<option value=\"" + un.getRazaoSocial() + "@" +
												un.getCodigo() + "\">" + un.getReferencia() + "</option>");
									}
								}
								%>
							</select>
						</div>
						<div class="textBox" style="width:50px">
							<label>Status</label><br />
							<select id="status" name="status">
								<option value="">Selecione</option>
								<option value="a">Aberto</option>
								<option value="q">Quitado</option>
								<option value="v">Em Atraso</option>
							</select>
						</div>
					</div>					
				</div>
				<div class="topButtonContent">
					<div class="formGreenButton">
						<input id="buscar" name="buscar" class="greenButtonStyle" type="submit" value="Buscar" />
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%DataGrid dataGrid= new DataGrid("#");
						if (session.getAttribute("perfil").toString().equals("a")
								|| session.getAttribute("perfil").toString().equals("d")){
							query= sess.createQuery("from Lancamento as l where l.tipo = 'c' " +
									" and l.status = 'a' " +  
									"order by l.vencimento desc, l.conta.descricao");							
						} else {
							query= sess.createQuery("from Lancamento as l where l.tipo = 'c' " +
									" and l.status = 'a' and l.unidade.codigo = :unidade " +  
									"order by l.vencimento desc, l.conta.descricao");
							query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
						}
						int gridLines= query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(30);
						List<Lancamento> lancamento= (List<Lancamento>) query.list();
						dataGrid.addColum("10", "Código");
						dataGrid.addColum("20", "Documento");
						dataGrid.addColum("30", "Descrição");
						dataGrid.addColum("10", "Unidade");
						dataGrid.addColum("5", "tipo");
						dataGrid.addColum("5", "Status");
						dataGrid.addColum("10", "Vencimento");
						dataGrid.addColum("10", "valor");
						for(Lancamento lc: lancamento) {
							dataGrid.setId(String.valueOf(lc.getCodigo()));
							dataGrid.addData(String.valueOf(lc.getCodigo()));
							dataGrid.addData((lc.getDocumento() == null)? "---------------": lc.getDocumento());
							dataGrid.addData(Util.initCap(lc.getConta().getDescricao()));
							dataGrid.addData(lc.getUnidade().getReferencia());
							dataGrid.addData((lc.getTipo().trim().equals("c"))? "Crédito" : "Débito");
							switch (lc.getStatus().charAt(0)) {
								case 'a':
									dataGrid.addData("aberto");
									break;
								
								case 'q':
									dataGrid.addData("quitado");
									break;
									
								case 'v':
									dataGrid.addData("Atrasado");
									break;
									
								default:
									dataGrid.addData("");
								break;
							}
							dataGrid.addData(Util.parseDate(lc.getVencimento(), "dd/MM/yyyy"));
							dataGrid.addData(Util.formatCurrency(String.valueOf(lc.getValor())));
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));
						sess.close();						
						%>
						<div id="pagerGrid" class="pagerGrid"></div>						
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
	</div>
</body>
</html>