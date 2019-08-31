<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Query"%>
<%@page import="org.hibernate.Session"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.database.Especialidade"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.EmpresaSaude"%>
<%@page import="com.marcsoftware.database.Informacao"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">

	<jsp:useBean id="informacao" class="com.marcsoftware.database.Informacao"></jsp:useBean>

	<%!Query query;%>
	<%!Session sess; %>
	<%!List<Unidade> unidadeList;%>
	<%!List<Especialidade> especialidade; %>
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
	query= sess.createQuery("from Especialidade");
	especialidade= (List<Especialidade>) query.list();
	%>

<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />	
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Empresas de Saúde</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/comum/empresa_saude.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_window.js"></script>
</head>
<body onload="load()">
	<%@ include file="../inc/header.jsp" %>	
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="empSaude"/>
	</jsp:include>	
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="empSaude"/>			
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="get" onsubmit="return search()">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Empresa Saúde"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="sectedAba2">
							<label>Empresa de Saúde</label>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="profissionais.jsp">Profissionais Liberais</a>
						</div>						
					</div>
					<div class="topContent">
						<div id="referencia" class="textBox" style="width: 70px;" >
							<label>Ref.</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 70px;" />												
						</div>
						<div id="razaoSocial" class="textBox" style="width: 270px;">
							<label>Razão Social</label><br/>
							<input id="razaoSocialIn" name="razaoSocialIn" type="text" style="width: 270px;" />
						</div>
						<div id="fantasia" class="textBox" style="width: 250px">
							<label>Fantasia</label><br/>
							<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 270px" />
						</div>
						<div id="reponsavel" class="textBox" style="width: 234px">
							<label>Nome do Responsavel</label><br/>					
							<input id="reponsavelIn" name="reponsavelIn" type="text" style="width: 234px" />
						</div>
						<div id="conselho" class="textBox" style="width: 143px">
							<label>Conselho Responsavel</label><br/>					
							<input id="conselhoIn" name="conselhoIn" type="text" style="width: 143px" />
						</div>
						<div id="nomeContato" class="textBox" style="width: 234px">
							<label>Nome do Contato</label><br/>					
							<input id="nomeContatoIn" name="nomeContatoIn" type="text" style="width: 234px" />
						</div>
						<div id="setor" class="textBox">
							<label>Atividade</label><br/>
							<select type="select-multiple" id="setorIn" name="setorIn">
								<option value="">Selecione</option>							
								<option value="o">Odontológica</option>								
								<option value="l">Laboratorial</option>
								<option value="m">Médica</option>
								<option value="h">Hospitalar</option>
								<option value="a">Administrativa</option>
								<option value="e">Estética</option>
							</select>
						</div>
						<div id="setor" class="textBox">
							<label>Setor</label><br/>
							<select type="select-multiple" style="width: 150px" id="especialidadeIn" name="especialidadeIn">
								<option value="">Selecione</option>
								<%for(Especialidade esp: especialidade) {
									out.print("<option value=\"" + esp.getCodigo() + 
										"\">" + esp.getDescricao() + "</option>");
								}								
								%>								
							</select>
						</div>												
						<div id="status" class="textBox">
							<label >Status</label><br />
							<select type="select-multiple" id="ativoChecked" name="ativoChecked">
								<option value="">Selecione</option>							
								<option value="a">Ativo</option>								
								<option value="l">Bloqueado</option>
								<option value="m">Cancelado</option>
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
						<input id="buscar" name="insertConta" class="greenButtonStyle" type="submit" value="Buscar"/>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%DataGrid dataGrid = new DataGrid(null);
						if (session.getAttribute("perfil").toString().equals("a")
								|| session.getAttribute("perfil").toString().equals("d")) {
							query= sess.createQuery("from EmpresaSaude as e order by e.fantasia");
						} else {
							query= sess.createQuery("from EmpresaSaude as e where e.unidade.codigo = :unidade order by e.fantasia");
							query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
						}
						int gridLines= query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(30);
						List<EmpresaSaude> empresaList= (List<EmpresaSaude>) query.list();
						dataGrid.addColum("5", "Ref.");
						dataGrid.addColum("28", "Fantasia");
						dataGrid.addColum("21", "Cnpj");
						dataGrid.addColum("27", "Contato");						
						dataGrid.addColum("17", "Fone");
						dataGrid.addColum("2", "St.");
						for (EmpresaSaude empresa : empresaList) {
							query = sess.getNamedQuery("informacaoPrincipal");
							query.setEntity("pessoa", empresa);
							query.setFirstResult(0);
							query.setMaxResults(1);
							informacao= (Informacao) query.uniqueResult();
							dataGrid.setId(String.valueOf(empresa.getCodigo()));
							dataGrid.addData(String.valueOf(empresa.getCodigo()));
							dataGrid.addData(Util.initCap(empresa.getFantasia()));
							dataGrid.addData(Util.mountCnpj(empresa.getCnpj()));
							dataGrid.addData(Util.initCap(empresa.getContato()));							
							dataGrid.addData(informacao.getDescricao());
							dataGrid.addImg(Util.getIcon(empresa.getAtivo()));
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
		<% sess.close(); %>
	</div>
</body>
</html>