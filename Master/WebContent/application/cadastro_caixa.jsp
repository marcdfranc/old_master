<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Caixa"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Lancamento"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="java.util.Date"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
		
	<jsp:useBean id="caixa" class="com.marcsoftware.database.Caixa"></jsp:useBean>
	
	<%
	List<Lancamento> lancamento;
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query= sess.createQuery("from Caixa as c where c.codigo = :codigo");
	query.setLong("codigo", Long.valueOf(request.getParameter("id")));
	caixa = (Caixa) query.uniqueResult();
	Unidade unidade = (Unidade) sess.get(Unidade.class, Long.valueOf(session.getAttribute("unidade").toString()));
	Date now = new Date();
	double entradas, saidas;
	%>
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
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/comum/cadastro_caixa.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js"></script>
	
	<title>Master - Abertura de Caixa</title>
</head>
<body>
	<div id="fechaCaixa" class="removeBorda" title="Fechamento de Caixa" style="display: none">			
		<form id="formFim" onsubmit="return false;">
			<fieldset>				
				<label for="tpPagamento">Posição Atual</label><br/>
				<select id="tpPagamento" style="width: 100%" onchange="adjustPagamento(this)">
					<option value="c">Positivo (+)</option>
					<option value="d">Negativo (-)</option>
				</select>
				<label for="valorFechamento">Saldo Atual</label>
				<input type="text" name="valorFechamento" id="valorFechamento" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, decimalNumber)" />
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="financeiro"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="financeiro"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formPost" method="post" action="../CadastroCaixa" onsubmit= "return validForm(this)">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Caixa"/>
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="caixa.jsp">Início</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Cadastro</label>
						</div>
					</div>
					<div class="topContent">
						<div id="unidade" class="textBox" style="width: 70px;">
							<label>Cód. Unid.</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" style="width: 70px;" readonly="readonly" value="<%= (unidade == null)? "": unidade.getReferencia() %>"/>
						</div>
						<div id="codigo" class="textBox" style="width: 70px;">
							<label>Cód. Caixa</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 70px;" readonly="readonly" value="<%= caixa.getCodigo()  %>"/>
						</div>
						<div id="inicio" class="textBox" style="width: 90px;">
							<label>Data de Início</label><br/>
							<input id="inicioIn" name="inicioIn" type="text" style="width: 90px;" readonly="readonly" value="<%= Util.parseDate(caixa.getInicio(), "dd/MM/yyyy") %>"/>
						</div>
						<div id="hrInicio" class="textBox" style="width: 90px;">
							<label>Hora Início</label><br/>
							<input id="hrInicioIn" name="hrInicioIn" type="text" style="width: 90px;" readonly="readonly" value="<%= Util.getTime(caixa.getInicio()) %>"/>
						</div>
						<div id="fim" class="textBox" style="width: 90px;">
							<label>Data Final</label><br/>
							<input id="fimIn" name="fimIn" type="text" style="width: 90px;" readonly="readonly" value="<%=(caixa.getFim() == null)? "" : Util.parseDate(caixa.getFim(), "dd/MM/yyyy") %>"/>
						</div>
						<div id="hrFim" class="textBox" style="width: 90px;">
							<label>Hora Final</label><br/>
							<input id="hrFimIn" name="hrFimIn" type="text" style="width: 90px;" readonly="readonly" value="<%=(caixa.getFim() == null)? "" : Util.getTime(caixa.getFim()) %>"/>
						</div>						
						<div id="usuario" class="textBox" style="width: 200px;">
							<label>Usuário</label><br/>
							<input id="usuarioIn" name="usuarioIn" type="text" style="width: 200px;" readonly="readonly" value="<%= caixa.getLogin().getUsername() %>"/>
						</div>
						<div id="valorInicial" class="textBox" style="width: 110px;">
							<label>Valor Inicial</label><br/>
							<input id="valorInicialIn" name="valorInicialIn" type="text" style="width: 110px;" readonly="readonly" value="<%= Util.formatCurrency(caixa.getValorInicial()) %>" />
						</div>
						<div id="valorFinal" class="textBox" style="width: 110px;">
							<label>Valor Final</label><br/>
							<input id="valorFinalIn" name="valorFinalIn" type="text" style="width: 110px;" readonly="readonly" value="<%= Util.formatCurrency(caixa.getValorFinal()) %>" />
						</div>
						<div id="status" class="textBox" style="width: 110px;">
							<label>Status</label><br/>
							<input id="statusIn" name="statusIn" type="text" style="width: 110px;" readonly="readonly" value="<%= (caixa.getStatus().trim().equals("f"))? "Fechado" : "Aberto" %>" />
						</div>
					</div>					
				</div>
				<div id="mainContent">
					<div id="counter" class="counter">
						<span>
							<label class="titleCounter">Valor Inicial: </label>
						</span>
						<span>
							<label class="valueCounter"><%= Util.formatCurrency(caixa.getValorInicial()) %></label>
						</span>
					</div>					
					<div id="dataGrid">
						<%if (caixa.getStatus().trim().equals("a")) {
							query = sess.getNamedQuery("lancamentoCaixaOpen");
							query.setTimestamp("quitacao", caixa.getInicio());
							query.setString("username", caixa.getLogin().getUsername());
						} else {
							query = sess.getNamedQuery("lancamentoCaixaClose");
							query.setTimestamp("inicio", caixa.getInicio());
							query.setTimestamp("fim", caixa.getFim());
							query.setString("username", caixa.getLogin().getUsername());
						}
						lancamento = (List<Lancamento>) query.list();
						double saldo = entradas = caixa.getValorInicial();						 
						saidas = 0;
						String gridLines = saldo + "@";
						boolean isFirst = true;						
						DataGrid dataGrid = new DataGrid("");
						dataGrid.addColum("8", "Lanç.");
						dataGrid.addColum("27", "Documento");
						dataGrid.addColum("35", "Descrição");
						dataGrid.addColum("3", "Tp");
						dataGrid.addColum("9", "valor");
						dataGrid.addColum("9", "Valor Pago");
						dataGrid.addColum("9", "Saldo");						
						for(Lancamento lc: lancamento) {
							dataGrid.setId(String.valueOf(lc.getCodigo()));
							dataGrid.addData(String.valueOf(lc.getCodigo()));
							dataGrid.addData(lc.getDocumento());
							dataGrid.addData(lc.getConta().getDescricao());
							if ((lc.getTipo().trim().equals("c")
									&& (!lc.getConta().getDescricao().equals("fechamento de caixa"))) || isFirst) {
								dataGrid.addImg("../image/credito.gif");
								entradas+= lc.getValorPago();
							} else {								
								dataGrid.addImg("../image/debito.gif");
								saidas+= lc.getValorPago();
							}
							dataGrid.addData(Util.formatCurrency(lc.getValor()));
							dataGrid.addData(Util.formatCurrency(lc.getValorPago()));
							if (isFirst) {
								isFirst = false;								
							} else {
								if (lc.getTipo().trim().equals("c") 
										&& (!lc.getConta().getDescricao().equals("fechamento de caixa"))) {
									saldo+= lc.getValorPago();
									saldo = Util.round(saldo, 2);
								} else if (lc.getConta().getDescricao().equals("fechamento de caixa")){
									//saldo-= (saldo - caixa.getValorInicial()) + lc.getValorPago();
									saldo = caixa.getValorFinal() - saldo;
									//saldo = caixa.getValorFinal();
								} else {									
									saldo-= lc.getValorPago();
									saldo = Util.round(saldo, 2);
								}
							}
							dataGrid.addData(Util.formatCurrency(saldo));
							dataGrid.addRow();
						}
						gridLines+= saldo;
						dataGrid.addTotalizador("Total", Util.formatCurrency(entradas - saidas), true);
						dataGrid.addTotalizador("Saídas", Util.formatCurrency(saidas), true);
						dataGrid.addTotalizador("Entradas", Util.formatCurrency(entradas), false);
						dataGrid.makeTotalizador();
						if (caixa.getStatus().equals("a")) {
							dataGrid.addTotalizadorRight("Saldo Corrente", Util.formatCurrency(saldo), "totalSoma");							
						} else {
							dataGrid.addTotalizadorRight("Fechamento", Util.formatCurrency(saldo), "totalSoma");
						}
						dataGrid.makeTotalizadorRight();
						out.print(dataGrid.getTable(gridLines));
						%>
					</div>
				</div>
				 <div class="buttonContent">
					<%if ((session.getAttribute("caixaOpen").toString().trim().equals("t") 
							&& caixa.getStatus().equals("a"))
							|| ((session.getAttribute("perfil").toString().trim().equals("f")
									|| session.getAttribute("perfil").toString().trim().equals("a")
									|| session.getAttribute("perfil").toString().trim().equals("d")
									) && caixa.getStatus().equals("a"))) {%>
						<div class="formGreenButton">
							<input id="closeCaixa" name="closeCaixa" class="greenButtonStyle" type="button" value="Fechar" onclick="fecharCaixa()" />
						</div>
					<%} else if (!caixa.getStatus().equals("f")) {%>
						<div class="formGreenButton">
							<input id="closeCaixa" name="closeCaixa" class="greenButtonStyle" type="button" value="Fechar" onclick="bloquear('f')"/>
						</div> 
					<%}
					if (caixa.getStatus().equals("f")) {
						if (Math.abs(Util.diferencaDias(now, Util.getZeroDate(caixa.getInicio()))) > 0
								&& !session.getAttribute("perfil").toString().trim().equals("f")
								&& !session.getAttribute("perfil").toString().trim().equals("a")
								&& !session.getAttribute("perfil").toString().trim().equals("d")) {%>
							<div class="formGreenButton">
								<input id="geraPdf" name="geraPdf" class="greenButtonStyle" type="button" value="Imprimir" onclick="bloquear('p')"/>
							</div>
						<%} else {%>
							<div class="formGreenButton">
								<input id="geraPdf" name="geraPdf" class="greenButtonStyle" type="button" value="Imprimir" onclick="pdfGenerate()"/>
							</div>
						<%}
					}%>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close(); %>
	</div>
</body>
</html>