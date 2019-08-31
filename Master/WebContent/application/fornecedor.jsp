<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Query"%>
<%@page import="org.hibernate.Session"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Fornecedor"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.database.Lancamento"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Informacao"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%!Query query; %>
	<%!Session sess; %>
	<%! List<Fornecedor> fornecedorList; %>
	<%! List<Unidade> unidadeList;%>
	<% Informacao informacao;
	Session sess = (Session) session.getAttribute("hb");
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
	int mesAtual = Util.getMonthDate(Util.getToday());
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master - Fornecedores</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>	
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/comum/fornecedor.js" ></script>	
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/default.js" ></script>
</head>
<body onload="load()">
	<jsp:include page="../inc/pdv.jsp"></jsp:include>
	<div id="geracaoWindow" class="removeBorda" title="Geração de Agrupamento" style="display: none;">			
		<form id="geraWindow" onsubmit="return false;">
			<fieldset>
				<label for="mesId">Mês de identificação</label>
				<select id="mesId" name="mesId" style="width: 100%">
					<%for(int i = 0; i <  Util.MES_LITERAL.length; i++) {
						if ((i + 1) == mesAtual) {%>
							<option value="<%= (i + 1)%>" selected="selected" ><%= Util.MES_LITERAL[i] %></option>							
						<%} else {%>
							<option value="<%= (i + 1)%>" ><%= Util.MES_LITERAL[i] %></option>
						<%}
					}%>
				</select><br/>
				<label for="anoId">Ano de identificação</label>
				<input type="text" name="anoId" value="<%= Util.getYearDate(Util.getToday())%>" id="anoId" class="textDialog ui-widget-content ui-corner-all" />
			</fieldset>
		</form>
	</div>	
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="fornecedor"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="fornecedor"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formEmpresa" method="get" onsubmit="return search();" >
				<div>
					<input type="hidden" id="now" name="now" value="<%=Util.getToday()%>" />
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Fornecedores"/>			
					</jsp:include>
					<!--<div id="abaMenu">
						<div class="aba2">
							<a href="prestador_servico.jsp">Prest. Serviços</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Produtos e Materiais</label>
						</div>												
					</div>-->
					<div class="topContent">
						<div id="referencia" class="textBox" style="width: 70px;" >
							<label>Referencia</label><br/>
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
						<div id="cnpj" class="textBox" style="width:130px">
							<label>Cnpj</label><br/>
							<input id="cnpjIn" name="cnpjIn" type="text" style="width: 130px;" onkeydown="mask(this, cnpj);"/>
						</div>
						<div id="fone" class="textBox" style="width: 89px">
							<label>Telefone</label><br/>
							<input id="foneIn" name="foneIn" type="text" style="width: 89px" />
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
							query= sess.createQuery("from Fornecedor as f where (1 <> 1) order by f.fantasia");							
						} else {
							query= sess.createQuery("from Fornecedor as f where f.unidade.codigo = :unidade order by f.fantasia");
							query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
						}
						int gridLines= query.list().size(); 
						query.setFirstResult(0);
						query.setMaxResults(30);
						fornecedorList = (List<Fornecedor>) query.list();
						dataGrid.addColumWithOrder("5", "Ref.", "ref", false);
						dataGrid.addColumWithOrder("39", "Fantasia", true);
						dataGrid.addColumWithOrder("38", "Ramo", false);						
						dataGrid.addColum("18", "Fone");
						for(Fornecedor fornecedor: fornecedorList) {						
							query = sess.getNamedQuery("informacaoPrincipal");
							query.setEntity("pessoa", fornecedor);
							query.setFirstResult(0);
							query.setMaxResults(1);
							informacao = (Informacao) query.uniqueResult();
							dataGrid.setId(String.valueOf(fornecedor.getCodigo()));
							dataGrid.addData(String.valueOf(fornecedor.getCodigo()));
							//dataGrid.addData(Util.initCap(fornecedor.getRazaoSocial()));
							dataGrid.addData(Util.initCap(fornecedor.getFantasia()));
							dataGrid.addData(Util.initCap(fornecedor.getRamo().getDescricao()));
							dataGrid.addData((informacao== null)? "" : informacao.getDescricao());							
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