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
<%@page import="com.marcsoftware.database.Especialidade"%>
<%@page import="com.marcsoftware.database.Tabela"%>
<%@page import="com.marcsoftware.database.Servico"%>
<%@page import="com.marcsoftware.utilities.Util"%>

<%@page import="java.util.ArrayList"%>
<%@page import="com.marcsoftware.database.Vigencia"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%!boolean isEdition= false;%>
	<%isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}%>		
	
	<jsp:useBean id="servico" class="com.marcsoftware.database.Servico"></jsp:useBean>
	<jsp:useBean id="tabela" class="com.marcsoftware.database.Tabela"></jsp:useBean>
	
	<%
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query= sess.createQuery("from Especialidade");
	List<Especialidade> especialidade = (List<Especialidade>) query.list();
	ArrayList<Vigencia> tabelasVig = new ArrayList<Vigencia>() ; 
	if (session.getAttribute("perfil").equals("f")) {
		query= sess.getNamedQuery("unidadeByUser");
		query.setString("username", (String) session.getAttribute("username"));
	} else {
		query= sess.createQuery("from Unidade as u where u.deleted =\'n\'");		
	}	
	List<Unidade> unidadeList= (List<Unidade>) query.list();
	String aprovada = "";
	if (unidadeList.size() == 1) {
		query = sess.createQuery("from Vigencia as v where v.unidade = :unidade");
		query.setEntity("unidade", unidadeList.get(0));
		tabelasVig = (ArrayList<Vigencia>) query.list();
	}
	
	query= sess.createQuery("from Servico");
	List<Servico> servicoList= (List<Servico>) query.list();
	if(isEdition) {		
		//query= sess.getNamedQuery("precoUnidade");
		//query.setLong("servico", Long.valueOf(request.getParameter("id")));
		//query.setLong("unidade", Long.valueOf(request.getParameter("unidadeId")));
		//tabela= (Tabela) query.uniqueResult();
		tabela = (Tabela) sess.get(Tabela.class, Long.valueOf(request.getParameter("id")));
		
	}	
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/validation.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js" ></script>
	<script type="text/javascript" src="../js/comum/cadastro_tabela.js" ></script>
	
	<title>Master - Cadastro Serviços</title>
</head>
<body onload="load(<%= isEdition %>)">
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="servico"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="servico"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formPost" name="formPost" method="post" action="../CadastroTabela" onsubmit= "return validForm(this)">
				<input type="hidden" id="tipoSubmit" name="tipoSubmit"/>				
				<div>
					<input id="codServico" name="codServico" type="hidden" value="<%=(isEdition)? tabela.getServico().getCodigo(): "" %>" />
					<input id="tabelaId" name="tabelaId" type="hidden" value="<%=(isEdition)? request.getParameter("id") : "" %>" />
					<input id="perfil" name="perfil" type="hidden" value="<%= session.getAttribute("perfil").toString() %>" />
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Edição de Valores"/>			
					</jsp:include>
					<div class="topContent">						
						<div id="unidadeId" name="unidadeId" class="textBox" style="width: 85px">
							<label>Cód. Unid.</label><br/>
							<select type="select-multiple" id="unidadeIdIn" name="unidadeIdIn" class="required" onblur="genericValid(this);" <%if(isEdition) out.print("disabled=\"disabled\""); %> >
								<option value="">Selecione</option>
								<%if (unidadeList.size() == 1) {
									out.print("<option value=\"" + unidadeList.get(0).getTabela2() + "@" +
											unidadeList.get(0).getCodigo() + "\" selected=\"selected\" >" + 
											unidadeList.get(0).getReferencia() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										if (isEdition && tabela.getUnidade().equals(un)) {
											out.print("<option value=\"" + un.getTabela2() + "@" +
													un.getCodigo() + "\" selected=\"selected\" >" + 
													un.getReferencia() + "</option>");
										} else {
										out.print("<option value=\"" + un.getTabela2() + "@" +
												un.getCodigo() + "\">" + un.getReferencia() + "</option>");
										}
									}
								}%>
							</select>
						</div>
						<div id="unidade" class="textBox" style="width: 235px;">
							<label>Unidade</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" style="width: 235px;" value="<%
								if ((unidadeList.size() == 1) && (!isEdition)) {
									out.print(Util.initCap(unidadeList.get(0).getFantasia()));
								} else if (isEdition) {
									out.print(Util.initCap(tabela.getUnidade().getFantasia()));								
								} else {
									out.print("");								
								} %>" class="required" readonly="readonly" onchange="loadAprovada()" onblur="genericValid(this);" />
						</div>
						<div id="setor" class="textBox" style="width: 105px">
							<label>Atividade</label><br/>
							<select type="select-multiple" id="setorIn" name="setorIn" class="required" onblur="genericValid(this);" <%if(isEdition) out.print("disabled=\"disabled\""); %>>
								<option value="">Selecione</option>
								<option <%if (isEdition && tabela.getServico().getEspecialidade().getSetor().equals("o")) {
									out.print("selected=\"selected\"");
								}%> value="o">Odontológica</option>								
								<option <%if (isEdition && tabela.getServico().getEspecialidade().getSetor().equals("l")) {
									out.print("selected=\"selected\"");
								}%> value="l">Laboratorial</option>
								<option <%if (isEdition && tabela.getServico().getEspecialidade().getSetor().equals("m")) {
									out.print("selected=\"selected\"");
								}%> value="m">Médica</option>
								<option <%if (isEdition && tabela.getServico().getEspecialidade().getSetor().equals("h")) {
									out.print("selected=\"selected\"");
								}%> value="h">Hospitalar</option>								
							</select>
						</div>
						<div id="especialidade" class="textBox" style="width: 185px">
							<label>Setor</label><br/>
							<select type="select-multiple" id="especialidadeIn" style="width: 185px" name="especialidadeIn" class="required" onblur="genericValid(this);" <%if(isEdition) out.print("disabled=\"disabled\""); %>>
								<option value="">Selecione</option>
								<%for(Especialidade esp: especialidade) {
									if (isEdition && tabela.getServico().getEspecialidade().equals(esp)) {
										out.print("<option value=\"" + esp.getCodigo() +
												"\" selected=\"selected\">" + esp.getDescricao() + "</option>");
									} else {
										out.print("<option value=\"" + esp.getCodigo() +
												"\">" + esp.getDescricao() + "</option>");
									}
								}%>
							</select>
						</div>
						<div id="refServico" class="textBox" style="width: 89px;">
							<label>Cod. Proc.</label><br/>
							<input id="refServicoIn" name="refServicoIn" type="text" style="width: 89px;" value="<%=(isEdition)? tabela.getServico().getReferencia() : "" %>" class="required" onblur="genericValid(this);" />
						</div>
						<div id="servico" class="textBox" style="width: 311px">
							<label>Procedimento</label><br/>
							<select type="select-multiple" style="width: 311px" id="servicoIn" name="servicoIn" class="required" onchange="especialidadeComp()" onblur="genericValid(this);" <%if(isEdition) out.print("disabled=\"disabled\""); %>>
								<option value="">Selecione</option>
								<%for(Servico serv: servicoList) {
									if (isEdition && serv.equals(tabela.getServico())) {
										out.print("<option value=\"" + serv.getCodigo() + "@" + serv.getReferencia() + "@" +
												serv.getEspecialidade().getCodigo() + "\" selected=\"selected\">" + 
												serv.getDescricao() + "</option>");
									} else {
										out.print("<option value=\"" + serv.getCodigo() + "@" + serv.getReferencia() + "@" +
												serv.getEspecialidade().getCodigo() + "\">" + serv.getDescricao() + "</option>");
									}
								}%>
							</select>
						</div>
						<div id="tabela" class="textBox" style="width: 225px;">
							<label>Tabela</label><br/>
							<select type="select-multiple" style="width: 225px" id="tabelaIn" name="tabelaIn" class="required" onblur="genericValid(this);" <%if(isEdition) out.print("disabled=\"disabled\""); %>>
								<option value="">Selecione</option>
								<%if(isEdition) {
									out.print("<option value=\"" + tabela.getVigencia().getCodigo() +
										"\" selected=\"selected\">" + 
										tabela.getVigencia().getDescricao() + "</option>");
								}
								for(Vigencia tab: tabelasVig) {
									if ((!isEdition) && tab.equals(aprovada)){
										out.print("<option value=\"" + tab.getCodigo() +
												"\" selected=\"selected\">" + tab.getDescricao() + "</option>");
									} else {
										out.print("<option value=\"" + tab.getCodigo() +
												"\">" + tab.getDescricao() + "</option>");										
									}
								}%>
							</select>
						</div>
					</div>
				</div>
				<div id="mainContent">
					<div id="financas" class="bigBox" >
						<div class="indexTitle">
							<h4>Cadastramento Edição e Exclusão</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div id="vlrCliente" class="textBox" style="width: 100px;">
							<label>Valor Cliente</label><br/>
							<input id="vlrClienteIn" name="vlrClienteIn" type="text" style="width: 100px;" value="<%=(isEdition)? tabela.getValorCliente(): "0.00" %>" onkeydown="mask(this, decimalNumber);" class="required" onblur="genericValid(this);" />
						</div>
						<div id="operacional" class="textBox" style="width: 120px;">
							<label>Valor Profissional</label><br/>
							<input id="operacionalIn" name="operacionalIn" type="text" style="width: 110px;" value="<%=(isEdition)? tabela.getOperacional(): "0.00" %>" onkeydown="mask(this, decimalNumber);" class="required" onblur="genericValid(this);" />
						</div>
						<div id="hold" class="textBox" style="width: 100px;">
							<label>Valor Hold</label><br/>
							<input id="holdIn" name="holdIn" type="text" style="width: 100px;" value="0.00" readonly="readonly" onkeydown="mask(this, decimalNumber);"/>
						</div>
						<div id="vlrUnidade" class="textBox" style="width: 100px;">
							<label>Valor Unidade</label><br/>
							<input id="vlrUnidadeIn" name="vlrUnidadeIn" type="text" style="width: 100px;" value="0.00" readonly="readonly" onkeydown="mask(this, decimalNumber);" />
						</div>
					</div>
					<div id="endPage" class="bigBox" >
						<div class="indexTitle">
							<h4>&nbsp;</h4>
						</div>
					</div>
					<div class="buttonContent" >					
						<div class="formGreenButton" style="bottom: 20px" >
							<%if (session.getAttribute("perfil").equals("a")
									|| session.getAttribute("perfil").equals("f")) {%>
								<input class="greenButtonStyle" type="button" value="Salvar" onclick="processar('s')" />
								<%if (isEdition) {%>
									<input class="greenButtonStyle" type="button" value="Excluir" onclick="processar('e')" />
								<%}%>
							<%} else {%>
								<input class="greenButtonStyle" type="button" value="Salvar" onclick="noAccess()" />
								<%if (isEdition) {%>
									<input class="greenButtonStyle" type="button" value="Excluir" onclick="noAccess()" />
								<%}%>
							<%}%>
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