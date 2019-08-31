<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.database.Plano"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.PlanoServico"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
	Plano plano = (Plano) sess.get(Plano.class, Long.valueOf(request.getParameter("id")));
	query = sess.createQuery("from PlanoServico as p where p.id.plano = :plano");
	query.setEntity("plano", plano);
	List<PlanoServico> planoServico = (List<PlanoServico>) query.list();
	boolean isEdition = planoServico.size() > 0;
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master - Configuração de Plano</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/comum/plano_config.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js"></script>
</head>
<body <%if (isEdition) out.print("onload=\"load()\""); %>>
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
				<div>
					<input id="startIndex" name="startIndex" type="hidden" value="<%= planoServico.size()%>"/>
				</div>
				<div id="deletedsContent"></div>
				<div id="geralDate" class="alignHeader">
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Planos"/>			
					</jsp:include>
					<div class="topContent">
						<div id="unidadeIn" class="textBox" style="width: 65px;">
							<label>Cod. Unid.</label><br/>
							<input id="unidade" name="unidade" type="text" readonly="readonly" style="width: 65px;" value="<%= plano.getUnidade().getReferencia() %>" />
						</div>
						<div id="codigo" class="textBox" style="width: 75px;">
							<label>Cód. Plano</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" readonly="readonly" style="width: 75px;" value="<%= plano.getCodigo() %>" />
						</div>
						<div id="descricao" class="textBox" style="width: 250px;">
							<label>Descrição</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 250px;" class="required" readonly="readonly" value="<%= Util.initCap(plano.getDescricao()) %>" />
						</div>
						<div id="tipo" class="textBox" style="width: 100px">
							<label>Modalidade</label><br/>
							<input id="tipoIn" name="tipoIn" type="text" readonly="readonly" style="width: 100px;" value="<%= (plano.getTipo().equals("i"))? "Sem Cobertura" : "Com Cobertura" %>" />
						</div>
						<div id="cadastro" class="textBox" style="width: 73px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" type="text" class="required" style="width: 73px;" readonly="readonly" value="<%= Util.parseDate(plano.getCadastro(), "dd/MM/yyyy") %>" />
						</div>
					</div>
				</div>
				<div id="mainContent">					
					<div id="itensOrcamento" class="bigBox" >
						<div class="indexTitle">
							<h4>Procedimentos da Cobertura</h4>							
							<div class="alignLine">
								<hr>
							</div>
							<div id="setor" class="textBox" style="width: 105px">
								<label>Atividade</label><br/>
								<select type="select-multiple" id="setorIn" name="setorIn" onchange="loadDescription()" >
									<option value="">Selecione</option>
									<option value="o">Odontológica</option>
									<option value="l">Laboratorial</option>
									<option value="m">Médica</option>
									<option value="h">Hospitalar</option>
								</select>
							</div>
							<div id="servicoRef" class="textBox" style="width: 80px;" >
								<label>Cod. Proc.</label><br/>
								<input id="servicoRefIn" name="servicoRefIn" type="text" style="width: 80px;" onblur="loadDescription(); $('#qtdeIn').focus()" />
								<input id="especialidade" name="especialidade" type="hidden"/>
							</div>						
							<div id="servico" class="textBox" style="width: 335px;" >
								<label>Procedimento</label><br/>
								<input id="servicoIn" name="servicoIn" type="text" style="width: 335px;" readonly="readonly"/>
							</div>
							<div id="qtde" class="textBox" style="width: 30px;" >
								<label>Qtde</label><br/>
								<input id="qtdeIn" name="qtdeIn" type="text" style="width: 30px;" value="1" class="required" onkeydown="mask(this, onlyInteger);" />
							</div>							
						</div>
					</div>
					<div id="dataGrid">
						<%
						int gridLines = planoServico.size();
						DataGrid dataGrid = new DataGrid("");
						dataGrid.addColum("10", "Código");
						dataGrid.addColum("15" ,"Atividade");
						dataGrid.addColum("23" ,"Setor");
						dataGrid.addColum("45" ,"Descrição");
						dataGrid.addColum("5" ,"Qtde");
						dataGrid.addColum("2" ,"Ck");
						for(PlanoServico planServ: planoServico) {
							dataGrid.setId("");
							dataGrid.addData("rowCodigo", planServ.getId().getServico().getReferencia());
							switch (planServ.getId().getServico().getEspecialidade().getSetor().charAt(0)) {
								case 'o':
									dataGrid.addData("rowSetor", "Odontológica");
									break;
								
								case 'm':
									dataGrid.addData("rowSetor", "Médica");
									break;
									
								case 'h':
									dataGrid.addData("rowSetor", "Hospitalar");
									break;
									
								case 'l':
									dataGrid.addData("rowSetor", "Laboratorial");
									break;
							}
							dataGrid.addData("rowEspecialidade", planServ.getId().getServico().getEspecialidade().getDescricao());
							dataGrid.addData("rowServico", planServ.getId().getServico().getDescricao());
							dataGrid.addData("rowQtde", String.valueOf(planServ.getQtde()));
							dataGrid.addCheck("checkrowTabela");
							dataGrid.addRow();
						}						
						out.print(dataGrid.getTable(gridLines));
						
						%>
					</div>
					<div class="buttonContent">					
						<%if (isEdition) {%>
							<div class="formGreenButton">
								<input name="removeTabela" class="greenButtonStyle" type="button" value="Excluir" onclick="removeRowForEdit()" />
							</div>								
						<%} else {%>
							<div class="formGreenButton">
								<input name="removeTabela" class="greenButtonStyle" type="button" value="Excluir" onclick="removeRowServico()" />
							</div>					
						<%}%>
						<div class="formGreenButton" >
							<input id="specialButton" name="insertTabela" class="greenButtonStyle" type="button" value="Inserir" onclick="addRowServico()" />
						</div>								
					</div>						
					<div class="buttonContent" style="margin-top: 15px;">
						<%if (isEdition) {%>
							<div class="formGreenButton">						
								<input class="greenButtonStyle" type="button" value="Salvar" onclick="saveEdition()" />
							</div>
						<%} else {%>
							<div class="formGreenButton">						
								<input class="greenButtonStyle" type="button" value="Salvar" onclick="saveConfig()" />
							</div>							
						<%}%>
					</div>					
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>