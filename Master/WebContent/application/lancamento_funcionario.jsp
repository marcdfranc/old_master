<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Usuario"%>
<%@page import="com.marcsoftware.database.Lancamento"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query, queryList;
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
	Lancamento lancamento;
	double vlrTotal;
	int consolidados;
	
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />	
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->

	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/comum/lancamento_funcionario.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_window.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	
	<title>Master Borderô Funcionário</title>
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
			<form id="parc" method="get" onsubmit="return search()">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Borderô"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="funcionario.jsp">RH</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Borderô Geral</label>
						</div>						
					</div>
					<div class="topContent">						
						<div id="ref" class="textBox" style="width:65px">
							<label>Ref.</label><br/>
							<input id="refIn" name="refIn" type="text" style="width: 65px;" value=""/>
						</div>
						<div id="nome" class="textBox" style="width:250px">
							<label>Funcionario</label><br/>
							<input id="nomeIn" name="nomeIn" type="text" style="width: 250px;" value=""/>
						</div>
						<div id="cpf" class="textBox" style="width: 100px">
							<label>Cpf</label><br/>
							<input id="cpfIn" name="cpfIn" type="text" style="width: 100px" onkeydown="mask(this, cpf);"/>
						</div>
						<div id="nascimentoCalendar" class="textBox" style="width: 73px;">
							<label>Nascimento</label><br/>
							<input id="nascimentoIn" name="nascimentoIn" type="text" style="width: 73px;" onkeydown="mask(this, typeDate);"/>
						</div>
						<div id="unidadeId" class="textBox">
							<label>Cod. Un.</label><br/>
							<select id="unidadeIdIn" name="unidadeIdIn">
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
						<div id="cargo" class="textBox" style="width:250px">
							<label>Cargo</label><br/>
							<input id="cargoIn" name="cargoIn" type="text" style="width: 250px;" value=""/>
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
						<%queryList = sess.createQuery("from Usuario as u " + 
								"where u.contrato not in(select i.id.contrato from ItensVendedor as i) " +
								"and u.unidade.codigo = :unidade order by u.cadastro desc"); 
						queryList.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
						
						List<Usuario> usuarioList = (List<Usuario>) queryList.list();						
						int gridLines = usuarioList.size();
						double adesao = 0;
						vlrTotal = 0;
						consolidados = 0;
						for(Usuario usuario: usuarioList) {
							query = sess.getNamedQuery("adesaoByCtr");
							query.setLong("codigo", usuario.getContrato().getCodigo());
							lancamento = (Lancamento) query.uniqueResult();
							adesao = (lancamento.equals(null))? 0 : lancamento.getValor();
							if (gridLines >= usuario.getContrato().getFuncionario().getMeta()) {
								adesao = adesao * (usuario.getContrato().getFuncionario().getBonus() / 100);
							} else {
								adesao = adesao * (usuario.getContrato().getFuncionario().getComissao() / 100);
							}							
							if (lancamento.getStatus().equals("q")) {
								vlrTotal+= adesao;
								consolidados++;
							}
						}
						queryList.setFirstResult(0);
						queryList.setMaxResults(30);
						usuarioList = (List<Usuario>) queryList.list();
						DataGrid dataGrid = new DataGrid("#");
						dataGrid.addColum("5", "CTR");
						dataGrid.addColum("36", "Titular");						
						dataGrid.addColum("10", "Cadastro");
						dataGrid.addColum("36", "Funcionario");
						dataGrid.addColum("10", "valor");
						dataGrid.addColum("3", "St");
						for(Usuario usuario: usuarioList) {
							query = sess.getNamedQuery("adesaoByCtr");
							query.setLong("codigo", usuario.getContrato().getCodigo());
							lancamento = (Lancamento) query.uniqueResult();
							adesao = (lancamento.equals(null))? 0 : lancamento.getValor();						
							if (gridLines >= usuario.getContrato().getFuncionario().getMeta()) {
								adesao = adesao * (usuario.getContrato().getFuncionario().getBonus() / 100);
							} else {
								adesao = adesao * (usuario.getContrato().getFuncionario().getComissao() / 100);
							}
							dataGrid.setId(String.valueOf(usuario.getContrato().getCodigo()));
							dataGrid.addData(Util.zeroToLeft(usuario.getContrato().getCodigo(), 4));
							dataGrid.addData(Util.initCap(usuario.getNome()));
							dataGrid.addData(Util.parseDate(usuario.getCadastro(), "dd/MM/yyyy"));
							dataGrid.addData(Util.initCap(usuario.getContrato().getFuncionario().getNome()));														
							dataGrid.addData(Util.formatCurrency(adesao));						
							dataGrid.addImg(Util.getRealIcon(lancamento.getVencimento(), lancamento.getStatus()));
							dataGrid.addRow();							
						}
						dataGrid.addTotalizador("Total", Util.formatCurrency(vlrTotal), true);
						dataGrid.addTotalizador("Consolidados", String.valueOf(consolidados), true);
						dataGrid.addTotalizador("CTR's Vendidos", String.valueOf(gridLines), false);
						dataGrid.makeTotalizador();
						out.print(dataGrid.getTable(gridLines));
						%>
					</div>
					<div id="pagerGrid" class="pagerGrid"></div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close(); %>
	</div>	
</body>
</html>