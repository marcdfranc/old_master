<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.database.TabelaFranchising"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.ItensTabelaFranchising"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.TipoConta"%><html xmlns="http://www.w3.org/1999/xhtml">
	
	<%!boolean isEdition= false; %>
	<%isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}%>
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query = null;
	boolean haveHold = false;
	TabelaFranchising tabela = null;
	List<ItensTabelaFranchising> itensTabela = null;
	query = sess.createQuery("from TipoConta as t");
	List<TipoConta> contas = (List<TipoConta>) query.list();
	String adesao, mensalidade, tabelaCliente, carteiraAdm, operacional;
	adesao = mensalidade = tabelaCliente = carteiraAdm = operacional = "0.00";
	if (isEdition) {
		tabela = (TabelaFranchising) sess.load(TabelaFranchising.class, Long.valueOf(request.getParameter("id")));
		query = sess.createQuery("from ItensTabelaFranchising as i where i.tabela = :tabela");
		query.setEntity("tabela", tabela);
		itensTabela = (List<ItensTabelaFranchising>) query.list();
		for(ItensTabelaFranchising it: itensTabela) {
			switch (Integer.parseInt(it.getTipoConta().getCodigo().toString())) {
				case 61:
					mensalidade = Util.formatCurrency(it.getValor());
					break;
				
				case 63:
					adesao = Util.formatCurrency(it.getValor());
					break;
					
				case 76:
					carteiraAdm = Util.formatCurrency(it.getValor());
					break;
			}
		}
	}	
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Tabela Franchising</title>
	
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/validation.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/lib/pilot_grid.js" ></script>
	<script type="text/javascript" src="../js/comum/tabela_franchising.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	
</head>
<body onload="loadPage(<%= isEdition %>)">		
	<%@ include file="../inc/header.jsp"%>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="unidade"/>
	</jsp:include>
	<div id="centerAll" >
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="unidade"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formPost" name="formPost" method="post" action="../CadastroTabelaFranchising"  onsubmit= "return validForm(this)" >
				<div id="localEdItens" ><%
					if (isEdition) {												
						for(int i=0; i < itensTabela.size(); i++){
							out.print("<input id=\"edDescricao" + String.valueOf(i) + "\" name=\"edDescricao" +
									String.valueOf(i) + "\" type=\"hidden\" value=\"" + 
									itensTabela.get(i).getTipoConta().getCodigo() + "@" +
									itensTabela.get(i).getTipoConta().getDescricao() + "\" />");
							
							switch (itensTabela.get(i).getTipoCobranca().charAt(0)) {
								case 'f':
									out.print("<input id=\"edTipo" + String.valueOf(i) + "\" name=\"edTipo" + 
											String.valueOf(i) +	"\" type=\"hidden\" value=\"Fixa\" />");						
									break;
								
								case 'h':
									out.print("<input id=\"edTipo" + String.valueOf(i) + "\" name=\"edTipo" + 
											String.valueOf(i) +	"\" type=\"hidden\" value=\"Por Hora\" />");						
									break;
									
								case 'q':
									out.print("<input id=\"edTipo" + String.valueOf(i) + "\" name=\"edTipo" + 
											String.valueOf(i) +	"\" type=\"hidden\" value=\"Por Quantidade\" />");						
									break;
							}
							

							out.print("<input id=\"edValor" + String.valueOf(i) + "\" name=\"edValor" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +
									Util.formatCurrency(itensTabela.get(i).getValor()) + "\" />");							
							
							out.print("<input id=\"itemId" + String.valueOf(i) + "\" name=\"itemId" + String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + itensTabela.get(i).getCodigo() + "\" />");							
						}
					}%>
								
				</div>				
				<div id="localItem"></div>
				<div id="deletedsItem"></div>
				<div id="editedsItem"></div>
				<div>
					<input id="edItem" name="edItem" type="hidden" value="n"/>
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Tabela Franchising"/>			
					</jsp:include>
					<div class="topContent">
						<div id="codigo" class="textBox" style="width: 70px;">
							<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 70px;" readonly="readonly"  value="<%=(isEdition)? tabela .getCodigo(): "" %>"/>
						</div>
						<div id="descricao" class="textBox" style="width: 258px;">
							<label>Descrição</label><br/>						
							<input id="descricaoIn" name="descricaoIn" type="text" style="width: 258px;" value="<%=(isEdition)? Util.initCap(tabela.getDescricao()): "" %>" class="required" onblur="genericValid(this);" />
						</div>
						<div id="cadastro" class="textBox" style="width: 73px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" class="required" type="text" style="width: 73px;" value="<%=(isEdition)? Util.parseDate(tabela.getCadastro(), "dd/MM/yyyy") : Util.getToday() %>" onkeydown="mask(this, dateType);" />
						</div>
					</div>
				</div>
				<div id="mainContent">
					<div id="responsavel" class="bigBox" >
						<div class="indexTitle">
							<h4>Serviços Contratados</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div><input id="edItens" name="edItens" type="hidden" value="<%=(isEdition)? "on": "off" %>" /></div>
						<div class="textBox" style="width: 300px">
							<label>Conta</label><br/>
							<select id="conta" name="conta" style="width: 300px;">
								<option value="-1" >Selecione</option>
								<%for(TipoConta conta: contas){
									out.println("<option value=\"" + conta.getCodigo() + "@" +
											conta.getDescricao() + "\" >" + conta.getDescricao() + "</option>");
								}%>
							</select>
						</div>
						<div class="textBox" style="width: 145px">
							<label>Tipo de Cobrança</label><br/>
							<select id="tpCobranca" name="tpCobranca" style="width: 145px;">
								<option value="f" >Fixa</option>
								<option value="p" >Percentagem</option>
								<option value="h" >Por Hora</option>
								<option value="q" >Por Quantidade</option>
							</select>
						</div>
						<div id="valor" class="textBox" style="width: 115px">
							<label>Valor</label><br/>					
							<input id="valorIn" name="valorIn" type="text" style="width: 115px" value="0.00" onkeydown="mask(this, decimalNumber);"/>
						</div>
						<div id="tableItem" style="margin-right: 68px"></div>						
					</div>
					<div class="buttonContent" >
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Excluir" onclick="removeRowItem()" />						
						</div>					
						<div class="formGreenButton"  >
							<input class="greenButtonStyle" type="button" value="Inserir" onclick="addRowItem()" />				
						</div>
					</div>
					<div class="buttonContent" style="margin-top: 40px;">
						<div class="formGreenButton">
							<input class="greenButtonStyle" style="margin-top: 10px;" type="submit" value="Salvar"/>
						</div>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close(); %>
	</div>
</body>
</html>