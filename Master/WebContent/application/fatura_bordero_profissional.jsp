<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>

<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.BorderoProfissional"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Profissional"%>
<%@page import="com.marcsoftware.database.EmpresaSaude"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">

	<jsp:useBean id="profissional" class="com.marcsoftware.database.Profissional"></jsp:useBean>
	<jsp:useBean id="empresaSaude" class="com.marcsoftware.database.EmpresaSaude"></jsp:useBean>
		
	<%double valor = 0;
	int gridLines = 0;
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query = sess.createQuery("from Profissional as p where p.codigo = :pessoa");
	query.setLong("pessoa", Long.valueOf(request.getParameter("id")));
	boolean isProfissional = true;
	
	if (query.list().size() == 0) {
		empresaSaude = (EmpresaSaude) sess.get(EmpresaSaude.class, Long.valueOf(request.getParameter("id")));
		isProfissional = false;
	} else {
		profissional= (Profissional) query.uniqueResult();
	}
	String parametro = (isProfissional)? "profissional" : "empSaude";
	int operacionalQuit = 0;
	int clienteQuit = 0;
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/comum/fatura_bordero.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	
<title>Master - Faturas de Repasse</title>
</head>
<body onload="load()">
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="<%= parametro %>"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="<%= parametro %>"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formPost" method="get" onsubmit= "return search()">
				<div>
					<input id="caixaOpen" name="caixaOpen" type="hidden" value="<%=(session.getAttribute("caixaOpen").toString().trim().equals("t"))? "t" : "f" %>"/>
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Faturas"/>
					</jsp:include>	
					<div id="abaMenu">
						<%if (isProfissional) {%>
							<div class="aba2">
								<a href="cadastro_profissional.jsp?state=1&id=<%= profissional.getCodigo()%>">Cadastro</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="anexo_profissional.jsp?id=<%= profissional.getCodigo()%>">Anexo</a>
							</div>
							
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="agenda_profissional.jsp?id=<%= profissional.getCodigo()%>">Agenda</a>
							</div>
													
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="bordero_profissional.jsp?id=<%= profissional.getCodigo()%>">Borderô</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="cadastro_bordero.jsp?id=<%= profissional.getCodigo()%>">Cadastro de Fatura</a>
							</div>						
						<%} else {%>
							<div class="aba2">
								<a href="cadastro_empresa_saude.jsp?state=1&id=<%= empresaSaude.getCodigo()%>">Cadastro</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="anexo_empresa_saude.jsp?state=1&id=<%= empresaSaude.getCodigo()%>">Anexo</a>
							</div>						
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="bordero_empresa_saude.jsp?id=<%= empresaSaude.getCodigo()%>">Borderô</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="cadastro_bordero.jsp?id=<%= empresaSaude.getCodigo()%>">Cadastro de Fatura</a>
							</div>
						<%}%>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Histórico de Faturas</label>
						</div>	
					</div>									
					<div class="topContent">
						<%if (isProfissional) {%>
							<div id="referencia" class="textBox" style="width: 75px;" >
								<label>Ref. Prof.</label><br/>
								<input id="referenciaIn" name="referenciaIn" type="text" style="width: 75px;" value="<%= profissional.getCodigo() %>" readonly="readonly" />
							</div>
							<div id="profissional" class="textBox" style="width: 320px;" >
								<label>Profissional</label><br/>
								<input id="profissionalIn" name="profissionalIn" type="text" style="width: 320px;" value="<%=Util.initCap(profissional.getNome())%>" readonly="readonly" />
							</div>
							<div id="conselho" class="textBox" style="width: 150px;" >
								<label>Nro. Conselho</label><br/>
								<input id="conselhoIn" name="conselhoIn" type="text" style="width: 150px;" value="<%=profissional.getConselho().toUpperCase()%>" readonly="readonly" />
							</div>
						<%} else {%>
							<div id="referencia" class="textBox" style="width: 75px;" >
								<label>Ref. Emp.</label><br/>
								<input id="referenciaIn" name="referenciaIn" type="text" style="width: 75px;" value="<%= empresaSaude.getCodigo() %>" readonly="readonly" />
							</div>
							<div id="empSaude" class="textBox" style="width: 320px;" >
								<label>Empresa de Saúde</label><br/>
								<input id="empSaudeIn" name="empSaudeIn" type="text" style="width: 320px;" value="<%=Util.initCap(empresaSaude.getFantasia())%>" readonly="readonly" />
							</div>
							<div id="conselho" class="textBox" style="width: 150px;" >
								<label>Nro. Conselho</label><br/>
								<input id="conselhoIn" name="conselhoIn" type="text" style="width: 150px;" value="<%=empresaSaude.getConselhoResponsavel()%>" readonly="readonly" />
							</div>
						<%}%>
						<div id="inicio" class="textBox" style="width: 90px;">
							<label>Data de Inicio</label><br/>
							<input id="inicioIn" name="inicioIn" type="text" style="width: 90px;" onkeydown="mask(this, dateType);"/>
						</div>
						<div id="fim" class="textBox" style="width: 90px;">
							<label>Data Final</label><br/>
							<input id="fimIn" name="fimIn" type="text" style="width: 90px;" onkeydown="mask(this, dateType);"/>
						</div>
						<div id="plano" class="textBox">
							<label >Status</label><br />							
							<select id="status" name="status">
								<option value="">Selecione</option>
								<option value="a">Aberto</option>
								<option value="q">Quitado</option>								
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
						<%DataGrid dataGrid;
						dataGrid = new DataGrid(null);
						//dataGrid = new DataGrid("cadastro_bordero.jsp");
						/*if (session.getAttribute("perfil").toString().equals("a")
								|| session.getAttribute("perfil").toString().equals("d")
								|| session.getAttribute("perfil").toString().equals("f")) {
							dataGrid = new DataGrid("cadastro_bordero.jsp");							
						} else {
							dataGrid = new DataGrid("#");
						}*/
						dataGrid.addColum("9", "Fatura");
						dataGrid.addColum("10", "Dt. Início");
						dataGrid.addColum("10", "Dt. Final");
						if (isProfissional) {
							dataGrid.addColum("50", "Profissional");							
						} else {
							dataGrid.addColum("50", "Empresa de Saúde");
						}
						dataGrid.addColum("9", "Cadastro");
						dataGrid.addColum("10", "Valor");
						dataGrid.addColum("2", "St");
						valor = 0;
						query = sess.createQuery("select distinct i.id.borderoProfissional from ItensBordero as i " +
								"where i.id.borderoProfissional.pessoa.codigo = :profissional " +
								" order by i.id.borderoProfissional.fim desc");
						if (isProfissional) {
							query.setLong("profissional", profissional.getCodigo());							
						} else {
							query.setLong("profissional", empresaSaude.getCodigo());
						}
						gridLines = query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(30);
						List<BorderoProfissional> borderoProfissional = (List<BorderoProfissional>) query.list();
						for(BorderoProfissional bordero: borderoProfissional) {
							query = sess.getNamedQuery("totalRepasse");
							query.setLong("bordero", bordero.getCodigo());							
							valor = Double.parseDouble(query.uniqueResult().toString());
							
							if (isProfissional) {
								profissional = (Profissional) sess.get(Profissional.class, bordero.getPessoa().getCodigo());
							} else {
								empresaSaude = (EmpresaSaude) sess.get(EmpresaSaude.class, bordero.getPessoa().getCodigo());
							}
							
							dataGrid.setId(String.valueOf(bordero.getCodigo()));
							dataGrid.addData(String.valueOf(bordero.getCodigo()));
							dataGrid.addData(Util.parseDate(bordero.getInicio(), "dd/MM/yyyy"));
							dataGrid.addData(Util.parseDate(bordero.getFim(), "dd/MM/yyyy"));
							if (isProfissional) {
								dataGrid.addData(Util.initCap(profissional.getNome()));								
							} else {
								dataGrid.addData(Util.initCap(empresaSaude.getFantasia()));
							}
							dataGrid.addData(Util.parseDate(bordero.getCadastro(), "dd/MM/yyyy"));
							if (session.getAttribute("perfil").toString().equals("a")
									|| session.getAttribute("perfil").toString().equals("d")
									|| session.getAttribute("perfil").toString().equals("f")) {
								dataGrid.addData(Util.formatCurrency(valor));								
							} else {
								dataGrid.addData("---------");
							}
							query = sess.getNamedQuery("clienteQuit");
							query.setLong("bordero", bordero.getCodigo());
							clienteQuit = Integer.parseInt(query.uniqueResult().toString());
							
							query = sess.getNamedQuery("operacionalQuit");
							query.setLong("bordero", bordero.getCodigo());
							operacionalQuit = Integer.parseInt(query.uniqueResult().toString());
							if (operacionalQuit == 0) {
								dataGrid.addImg("../image/atraso.png");
							} else {
								if (clienteQuit == 0) {
									dataGrid.addImg("../image/estorno.gif");
								} else {
									dataGrid.addImg("../image/ok_icon.png");
								}
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
