
<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Plano"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%List<Unidade> unidadeList;
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
	
	unidadeList= (List<Unidade>) query.list();%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->

	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master - Planos</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<%if ((session.getAttribute("perfil").equals("a")) 
			|| (session.getAttribute("perfil").equals("f"))) {%>
		<script type="text/javascript" src="../js/comum/plano.js" ></script>
	<%}%>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>	
	<script type="text/javascript" src="../js/lib/mask.js"></script>
</head>
<body onload="load();" >
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="servico"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="servico"/>
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="post" action="../CadastroPosicao">
				<div id="geralDate" class="alignHeader">
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Planos"/>			
					</jsp:include>
					<div class="topContent">
						<div id="unidadeIn" class="textBox">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId">
								<option value="0">Selecione</option>
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
						<div id="codigo" class="textBox" style="width: 75px;">
							<label>Cód. Plano</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 75px;" />
						</div>
						<div id="descricao" class="textBox" style="width: 230px;">
							<label>Descrição</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 230px;" class="required" />
						</div>
						<div id="tipo" class="textBox">
							<label>Modalidade</label><br/>
							<select id="tipoIn" name="tipoIn">
								<option value="">Selecione</option>
								<option value="i">Sem Cobertura</option>
								<option value="l">Com Cobertura</option>
							</select>							
						</div>
						<div id="cadastro" class="textBox" style="width: 73px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" type="text" class="required" style="width: 73px;" onkeydown="mask(this, dateType);"/>
						</div>
					</div>
				</div>
				<div class="topButtonContent">					
					<div class="formGreenButton">
						<input id="buscar" name="buscar" class="greenButtonStyle" onclick="addPlano();" type="button" value="Salvar"/>
					</div>
					<div class="formGreenButton">
						<input id="insercao" name="insercao" class="greenButtonStyle" type="button" value="Buscar" onclick="search();"/>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%if (unidadeList.size() == 1) {
							query = sess.createQuery("from Plano as p where p.unidade = :unidade");
							query.setEntity("unidade", unidadeList.get(0));
						} else {
							String sql = "from Plano as p where unidade in(";
							for(int i = 0; i < unidadeList.size(); i++) {
								if (i == 0) {
									sql+= "?";
								} else {
									sql+= ", ?";
								}
							}
							query = sess.createQuery(sql + ")");
							for(int i = 0; i < unidadeList.size(); i++) {
								query.setEntity(i, unidadeList.get(i)); 
							}
						}
						int gridLines = query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(10);
						List<Plano> planoList = (List<Plano>) query.list();
						DataGrid dataGrid = new DataGrid(null);
						dataGrid.addColum("10", "Código");
						dataGrid.addColum("30" ,"Descrição");
						dataGrid.addColum("30" ,"Modalidade");
						dataGrid.addColum("25" ,"Cadastro");
						dataGrid.addColum("5" ,"Unidade");
						for(Plano plano: planoList) {							
							dataGrid.setId(String.valueOf(plano.getCodigo()));
							dataGrid.addData("codigo" + plano.getCodigo(), 
									String.valueOf(plano.getCodigo()), false);
							dataGrid.addData("descricao" + plano.getCodigo(), plano.getDescricao(), false);
							if(plano.getTipo().trim().equals("i")) {
								dataGrid.addData("tipo" + plano.getCodigo(), "Sem Cobertura", false);
							} else {
								dataGrid.addData("tipo" + plano.getCodigo(), "Com Cobertura", false);
							}
							dataGrid.addData("cadastro" + plano.getCodigo(), Util.parseDate(
									plano.getCadastro(), "dd/MM/yyyy"), false);
							dataGrid.addData("unidade" + plano.getCodigo(), 
									plano.getUnidade().getReferencia(), false);
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));
						%>
						<div id="pagerGrid" class="pagerGrid"></div>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>



