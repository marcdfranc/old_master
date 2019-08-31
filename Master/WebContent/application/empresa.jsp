<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="com.marcsoftware.database.Empresa"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="org.hibernate.Query"%>
<%@page import="org.hibernate.Session"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.database.Informacao"%>

<%@page import="com.marcsoftware.database.Lancamento"%><html xmlns="http://www.w3.org/1999/xhtml">
	<jsp:useBean id="informacao" class="com.marcsoftware.database.Informacao"></jsp:useBean>
	
	<%!Query query; %>
	<%!Session sess; %>
	<%! List<Empresa> empresa; %>
	<%! List<Unidade> unidadeList;%>
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
	List<Lancamento> lancamentos;
	%>
	
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
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/comum/cliente_juridico.js" ></script>	
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>		
	
<title>Master Clientes Jurídicos</title>
</head>
<body onload="load()">
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="clienteJ"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="clienteJ"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formEmpresa" method="get" onsubmit="return search();" >
				<div>
					<input type="hidden" id="now" name="now" value="<%=Util.getToday()%>" />
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Cliente"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="sectedAba2">
							<label>Cliente Jurídico</label>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="cliente_fisico.jsp">Cliente Físico</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="dependentes.jsp">Dependentes</a>
						</div>
					</div>
					<div class="topContent">
						<div id="referencia" class="textBox" style="width: 70px;" >
							<label>CTR</label><br/>
							<input id="referenciaIn" name="referenciaIn" type="text" style="width: 70px;" />												
						</div>
						<div id="razaoSocial" class="textBox" style="width: 270px;">
							<label>Razão Social</label><br/>
							<input id="razaoSocialIn" name="razaoSocialIn" type="text" style="width: 270px;" />
						</div>
						<div id="fantasia" class="textBox" style="width: 250px">
							<label>Fantasia</label><br/>
							<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 270px" />
						</div>
						<div id="nomeContato" class="textBox" style="width: 245px">
							<label>Nome do Contato</label><br/>					
							<input id="nomeContatoIn" name="nomeContatoIn" type="text" style="width: 245px" />
						</div>
						<div id="unidadeIn" class="textBox">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId">
								<option value="0@0">Selecione</option>
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
						<div id="status" class="textBox" style="width: 280px">
							<label >Status</label><br />
							<div class="checkRadio">
								<label class="labelCheck" >Ativo</label>
								<input id="ativoChecked" name="ativoChecked" onchange="setChange('u')" type="radio" checked="checked" value="a" />
								<label class="labelCheck" >Bloqueado</label>
								<input id="ativoChecked" name="ativoChecked" type="radio" onchange="setChange('u')" value="b" />
								<label class="labelCheck" >Cancelado</label>
								<input id="ativoChecked" name="ativoChecked" type="radio" onchange="setChange('u')" value="c" />
							</div>
						</div>
					</div>												
				</div>
				<div class="topButtonContent">
					<div class="formGreenButton">
						<input id="buscar" name="buscar" class="greenButtonStyle" type="submit" value="Buscar"/>								
					</div>
				</div>
				<div id="mainContent">										
					<div id="counter" class="counter"></div>
					<div id="dataGrid">						
						<% DataGrid dataGrid = new DataGrid(null);
						if (session.getAttribute("perfil").toString().equals("a")
								|| session.getAttribute("perfil").toString().equals("d")) {
							query= sess.createQuery("from Empresa as e order by e.fantasia");							
						} else {
							query= sess.createQuery("from Empresa as e where e.unidade.codigo = :unidade order by e.fantasia");
							query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
						}
						int gridLines= query.list().size(); 
						query.setFirstResult(0);
						query.setMaxResults(30);
						empresa = (List<Empresa>) query.list();
						dataGrid.addColumWithOrder("5", "Ref.", false);
						dataGrid.addColumWithOrder("40", "Fantasia", true);						
						dataGrid.addColumWithOrder("33", "Contato", false);
						//dataGrid.addColumWithOrder("8", "Crédito", false);
						dataGrid.addColum("20", "Fone");
						dataGrid.addColum("2", "St");
						for(Empresa em: empresa) {
							query = sess.createQuery("select l.id.lancamento from LancamentoFaturaEmp as l " + 
								"where l.id.faturaEmpresa.empresa = :empresa");
							query.setEntity("empresa", em);
							lancamentos = (List<Lancamento>) query.list();
							
							query = sess.getNamedQuery("informacaoPrincipal");
							query.setEntity("pessoa", em);
							query.setFirstResult(0);
							query.setMaxResults(1);
							informacao= (Informacao) query.uniqueResult();
							dataGrid.setId(String.valueOf(em.getCodigo()));
							dataGrid.addData(String.valueOf(em.getCodigo()));
							dataGrid.addData(Util.initCap(em.getFantasia()));							
							dataGrid.addData(Util.initCap(em.getContato()));
							//dataGrid.addData(Util.formatCurrency(em.getSaldoAcumulado()));
							dataGrid.addData((informacao== null)? "" : informacao.getDescricao());
							dataGrid.addImg(Util.getIcon(lancamentos, "lancamento"));
							dataGrid.addRow(); 
						}
						out.print(dataGrid.getTable(gridLines));
						%>						
						<div class="pagerGrid"></div>						
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>