<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Funcionario"%>
<%@page import="com.marcsoftware.database.FaturaVendedor"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.ItensVendedor"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
	List<ItensVendedor> itens;
	if (request.getParameter("id") != null) {
		query = sess.createQuery("from Funcionario as f where f.codigo = :funcionario");
		query.setLong("funcionario", Long.valueOf(request.getParameter("id")));
	} else {
		query = sess.createQuery("from Funcionario as f where f.unidade.codigo = :unidade");
		query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
	}
	List<Funcionario> funcionario = (List<Funcionario>) query.list();
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Fatura de Vendas de Contrato</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/comum/fatura_vendedor.js" ></script>
</head>
<body onload="load()">
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="rh"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="rh"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formPost" method="get" onsubmit= "return search()">
				<div>
					<input type="hidden" id="caixaOpen" name="caixaOpen" value="<%= session.getAttribute("caixaOpen").toString() %>" />
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Faturas"/>
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="cadastro_funcionario.jsp?state=1&id=<%= funcionario.get(0).getCodigo()%>">Cadastro</a>
						</div>						
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="anexo_rh.jsp?id=<%= funcionario.get(0).getCodigo()%>">Anexo</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="requisicao_contrato.jsp?id=<%= funcionario.get(0).getCodigo()%>">Requisição</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="contrato.jsp?state=1&id=<%= funcionario.get(0).getCodigo()%>">Contratos</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="bordero_funcionario.jsp?id=<%= funcionario.get(0).getCodigo()%>">Borderô</a>
						</div>						
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Histórico de Faturas</label>
						</div>
					</div>
					<div class="topContent">
						<div id="inicio" class="textBox" style="width: 90px;">
							<label>Data de Inicio</label><br/>
							<input id="inicioIn" name="inicioIn" type="text" style="width: 90px;" onkeydown="mask(this, dateType);"/>
						</div>
						<div id="fim" class="textBox" style="width: 90px;">
							<label>Data Final</label><br/>
							<input id="fimIn" name="fimIn" type="text" style="width: 90px;" onkeydown="mask(this, dateType);"/>
						</div>
						<div id="funcionario" class="textBox">
							<label>Funcionario</label><br />							
							<select id="funcionarioIn" name="status">
								<option value="">Selecione</option>								
								<%if (funcionario.size() == 1) {
									out.print("<option selected=\"selected\" value=\"" + 
											funcionario.get(0).getCodigo() + "\">" + 
											funcionario.get(0).getNome() + "</option>");
								} else {
									for(Funcionario func : funcionario) {
										out.print("<option value=\"" + func.getCodigo() + "\">" + func.getNome() + 
												"</option>");	
									}									
								}%>								
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
						<%if (funcionario.size() == 1) {
							query = sess.createQuery("select distinct i.id.faturaVendedor from ItensVendedor as i " +
										" where i.id.contrato.funcionario = :funcionario " +
										" order by i.id.faturaVendedor.cadastro desc");
							query.setEntity("funcionario", funcionario.get(0));
						} else {
							query = sess.createQuery("from FaturaVendedor as f order by f.cadastro desc");
						}
						int gridLines = query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(30);
						List<FaturaVendedor> faturaList = (List<FaturaVendedor>) query.list();
						DataGrid dataGrid = new DataGrid(null);						
						dataGrid.addColum("10", "Fatura");
						dataGrid.addColum("10", "Dt. Início");
						dataGrid.addColum("15", "Dt. Final");
						dataGrid.addColum("43", "Funcionario");
						dataGrid.addColum("10", "Dt. Fatura");
						dataGrid.addColum("10", "valor");
						dataGrid.addColum("2", "St.");
						for(FaturaVendedor fatura: faturaList) {
							query = sess.createQuery("from ItensVendedor as i where i.id.faturaVendedor = :fatura " +
									"order by i.id.faturaVendedor.fim");
							query.setEntity("fatura", fatura);
							itens = (List<ItensVendedor>) query.list();
							query = sess.getNamedQuery("totalVenda");
							query.setLong("fatura", fatura.getCodigo());
							dataGrid.setId(String.valueOf(fatura.getCodigo()));
							dataGrid.addData(String.valueOf(fatura.getCodigo()));
							dataGrid.addData(Util.parseDate(fatura.getInicio(), "dd/MM/yyyy"));
							dataGrid.addData(Util.parseDate(fatura.getFim(), "dd/MM/yyyy"));
							dataGrid.addData(Util.initCap(itens.get(0).getId().getContrato().getFuncionario().getNome()));
							dataGrid.addData(Util.parseDate(fatura.getCadastro(), "dd/MM/yyyy"));
							dataGrid.addData(Util.formatCurrency(query.uniqueResult().toString()));
							if (itens.get(0).getId().getContrato().getStatus().equals("a")) {
								dataGrid.addImg("../image/atraso.png");
							} else {
								dataGrid.addImg("../image/ok_icon.png");
							}
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