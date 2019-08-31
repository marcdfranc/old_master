<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Especialidade"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.database.Tabela"%>

<%@page import="java.util.ArrayList"%>
<%@page import="com.marcsoftware.database.Vigencia"%><html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" /> 
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />

	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/comum/tabela.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>	
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query= sess.createQuery("from Especialidade");
	List<Especialidade> especialidade = (List<Especialidade>) query.list();
	ArrayList<Vigencia> tabelasVig = null;
	String sqlAx = null;
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
	for(Unidade und: unidadeList) {
		if (sqlAx == null) {
			sqlAx = String.valueOf(und.getCodigo());
		} else {
			sqlAx += ", " + und.getCodigo();
		}
	}
	
	// aqui necessita as criação de um for para unidfades com intuito de fazer um select com in
	query = sess.createQuery("from Vigencia as v where v.unidade.codigo in(" + sqlAx + ")");	
	//query = sess.createQuery("select distinct t.vigencia from Tabela as t where t.unidade = :unidade");
	//query.setEntity("unidade", unidadeList.get(0));
	tabelasVig = (ArrayList<Vigencia>) query.list();
	
	%>
	
	<title>Master - Serviço</title>
</head>
<body onload="load()" >
	<div id="tabelaWindow" class="removeBorda" title="Impressão de Tabelas" style="display: none;">			
		<form id="formTabela" onsubmit="return false;">
			<fieldset>
				<label for="unidadeWin">Selecione a unidade</label><br/>
				<select id="unidadeWin" style="width: 100%">
					<%for(Unidade un: unidadeList) {
						out.print("<option value=\"" + un.getCodigo() + "\">" + 
								un.getReferencia() + "</option>");									
					}%>
				</select><br />
				<label for="tipo">Selecione a impressão</label><br/>
				<select id="tipo" style="width: 100%">
					<option value="0">Tabela de Procedimentos</option>
					<%if (session.getAttribute("perfil").toString().equals("f")
							|| session.getAttribute("perfil").toString().equals("a")
							|| session.getAttribute("perfil").toString().equals("d")) {%>
						<option value="1">Tabela Cliente e Profissional</option>
					<%}%>
					<option value="2">Tabela Cliente</option>
					<%if (session.getAttribute("perfil").toString().equals("f")
							|| session.getAttribute("perfil").toString().equals("a")
							|| session.getAttribute("perfil").toString().equals("d")) {%>
						<option value="3">Tabela Profissional</option>
					<%}%>
				</select><br/>				
				<label for="tabelaWin">Selecione a Tabela</label><br/>
				<select id="tabelaWin" name="tabelaIn" style="width: 100%">
					<%for(Vigencia tab: tabelasVig) {
						out.print("<option value=\"" + tab.getCodigo() + "\" >" + tab.getDescricao() + "</option>");
					}%>
				</select>
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="servico"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="servico"/>			
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="get" onsubmit="return search()">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Tabela Valores"/>			
					</jsp:include>
					<div class="topContent">					
						<div id="codigo" class="textBox" style="width: 70px;">
							<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 70px;" class="required" />
						</div>						
						<div id="descricao" class="textBox" style="width: 230px;">
							<label>Descrição</label><br/>
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 230px;" class="required" enable="false"  />
						</div>
						<div id="setor" class="textBox" style="width: 130px">
							<label>Atividade</label><br/>
							<select type="select-multiple" id="setorIn" name="setorIn" class="required" style="width: 130px;" >
								<option value="">Selecione</option>
								<option value="o">Odontológico</option>								
								<option value="l">Laboratorial</option>
								<option value="m">Médico</option>
								<option value="h">Hospitalar</option>		
								<option value="a">Administrativa</option>
								<option value="e">Estética</option>						
								<option value="n">Ensino</option>						
								<option value="p">Prest. de Serviços</option>						
								<option value="j">Jurídica</option>						
								<option value="u">Automobilistica</option>						
								<option value="c">Construção Cívil</option>									
							</select>
						</div>
						<div id="especialidade" class="textBox" style="width: 150px;">
							<label>Setor</label><br/>
							<select type="select-multiple" id="especialidadeIn" name="especialidadeIn" class="required" >
								<option value="">Selecione</option>
								<%for(Especialidade esp: especialidade) {
									out.print("<option value=\"" + esp.getCodigo() +
										"\">" + esp.getDescricao() + "</option>");
								}%>
							</select>
						</div>
						<div id="tabela" class="textBox">
							<label>Tabela</label><br/>
							<select id="tabelaIn" name="tabelaIn">
								<option value="">Selecione</option>
								<%for(Vigencia tab: tabelasVig) {
									out.print("<option value=\"" + tab.getCodigo() + "\" >" + tab.getDescricao() + "</option>");
								}%>
							</select>
						</div>
						<div id="unidadeId" name="unidadeId" class="textBox">
							<label>Cód. Unid.</label><br/>
							<select type="select-multiple" id="unidadeIdIn" name="unidadeIdIn" class="required" >
								<option value="">Selecione</option>
								<%if (unidadeList.size() == 1) {
									out.print("<option value=\"" + unidadeList.get(0).getTabela2() + "@" +
											unidadeList.get(0).getCodigo() + "\" selected=\"selected\" >" + 
											unidadeList.get(0).getReferencia() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										out.print("<option value=\"" + un.getTabela2() + "@" +
												un.getCodigo() + "\">" + un.getReferencia() + "</option>");									
									}
								}%>
							</select>
						</div>
					</div>
				</div>
				<div class="topButtonContent">
					<div class="formGreenButton">
						<input class="greenButtonStyle" type="button" value="Imprimir" onclick="generateTabela()" />
					</div>
					<div class="formGreenButton">
						<input class="greenButtonStyle" type="submit" value="Buscar"  />
					</div>
				</div>
				<div id="mainContent">										
					<div id="counter" class="counter"></div>
					<div id="dataGrid" >
						<%DataGrid dataGrid;
						if (session.getAttribute("perfil").toString().trim().equals("a")
								|| session.getAttribute("perfil").toString().trim().equals("d")
								|| session.getAttribute("perfil").toString().trim().equals("f")){
							dataGrid = new DataGrid("cadastro_tabela.jsp");
						} else {
							dataGrid = new DataGrid("#");
						}
						query = sess.createQuery("from Tabela as t where (1 <> 1) order by t.servico.especialidade.descricao, t.servico.descricao");						
						//	query = sess.getNamedQuery("tabelaUnidade");
						//query.setEntity("unidade", unidadeList.get(0));
						int gridLines = query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(30);
						List<Tabela> tabela= (List<Tabela>) query.list();
						dataGrid.addColum("5", "Código");
						dataGrid.addColum("10", "Atividade");
						dataGrid.addColum("20", "Setor");
						dataGrid.addColum("45", "Descrição");
						dataGrid.addColum("10", "Cliente");
						dataGrid.addColum("10", "Operac.");
						for(Tabela tab: tabela) {
							//dataGrid.setId(String.valueOf(tab.getServico().getCodigo()) + 
								//	"&unidadeId=" + String.valueOf(tab.getUnidade().getCodigo()));
							dataGrid.setId(String.valueOf(tab.getCodigo()));
							dataGrid.addData(tab.getServico().getReferencia());
							if (tab.getServico().getEspecialidade().getSetor().equals("o")) {
								dataGrid.addData("Odontológica");
							} else if (tab.getServico().getEspecialidade().getSetor().equals("a")){
								dataGrid.addData("Administrativa");
							} else if (tab.getServico().getEspecialidade().getSetor().equals("e")){
								dataGrid.addData("Estética");
							} else if (tab.getServico().getEspecialidade().getSetor().equals("m")){
								dataGrid.addData("Médica");
							} else if (tab.getServico().getEspecialidade().getSetor().equals("l")){
								dataGrid.addData("Laboratorial");
							} else {
								dataGrid.addData("Hospitalar");
							}
							dataGrid.addData(Util.initCap(
									tab.getServico().getEspecialidade().getDescricao()));
							dataGrid.addData(Util.initCap(tab.getServico().getDescricao()));
							if (unidadeList.size() == 1) {
								if (session.getAttribute("perfil").equals("a") 
										|| session.getAttribute("perfil").equals("d")
										|| session.getAttribute("perfil").equals("f")) {
									dataGrid.addData(Util.formatCurrency(String.valueOf(tab.getValorCliente())));							
									dataGrid.addData(Util.formatCurrency(String.valueOf(tab.getOperacional())));
								} else if (session.getAttribute("perfil").equals("r")) {
									dataGrid.addData(Util.formatCurrency(String.valueOf(tab.getValorCliente())));
									dataGrid.addData("----------");									
								} else if (session.getAttribute("perfil").equals("p")) {
									dataGrid.addData("----------");
									dataGrid.addData(Util.formatCurrency(String.valueOf(tab.getOperacional())));
								}
							} else {
								dataGrid.addData("----------");
								dataGrid.addData("----------");
							}							
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
