<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Cc"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="java.util.Date"%>
<%@page import="com.marcsoftware.database.Lancamento"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Date now = new Date();
	Date tomorow = Util.addDays(now, 1);
	Date yesterday;
	double saldo = 0;
	double creditos = 0;
	double debitos = 0;
	List<Lancamento> lancamento;
	Query query;
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	if (session.getAttribute("perfil").equals("a")) {
		query= sess.createQuery("from Unidade as u");		
	} else if (session.getAttribute("perfil").equals("f")) {
		//query= sess.getNamedQuery("unidadeByUser");
		query = sess.createQuery("from Unidade as u where u.administrador.login.username = :username and u.deleted = \'n\'");
		query.setString("username", (String) session.getAttribute("username"));
	} else {
		query = sess.createQuery("select p.unidade from Pessoa as p where p.login = :username");
		query.setString("username", (String) session.getAttribute("username"));
	}
	List<Unidade> unidadeList= (List<Unidade>) query.list();
	String sql = "from Cc where unidade.codigo in(";
	if (unidadeList.size() > 0) {
		for(int i = 0; i < unidadeList.size(); i++) {
			if (i == 0) {
				sql+= unidadeList.get(i).getCodigo();
			} else {
				sql+= ", " + unidadeList.get(i).getCodigo();
			}
		}
		sql+= ")";
		query = sess.createQuery(sql);		
	} else {
		query = sess.createQuery("from Cc where (1 <> 1)");
	}
	List<Cc> contaCorrente = (List<Cc>) query.list();
	
	%>
<head>
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<link rel="shortcut icon" href="../icone.ico">
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>	
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/comum/cc.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>	
	
	<title>Master - Conta Corrente</title>
</head>
<body onload="load()">
	<div id="ccWindow" class="removeBorda" title="Edição de CC" style="display: none;">
		<form id="formObs" onsubmit="return false;">			
			<label for="obsw">Selecione a CC</label>
			<select id="ccIdEdit" name="ccIdEdit" style="width: 75px;">						
				<%for(Cc cc: contaCorrente) {
					if (session.getAttribute("perfil").toString().equals("a")
						&& cc.getUnidade().getTipo().equals("h")) {
						out.print("<option value=\"" + cc.getCodigo() + 
								"\" selected=\"selected\">" + cc.getUnidade().getReferencia() + "</option>");
					} else {
						out.print("<option value=\"" + cc.getCodigo() + 
							"\">" + cc.getUnidade().getReferencia() + "</option>");
					}
				}%>
			</select>
			
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
			<form id="unit" method="get" onsubmit="return search()">
				<input type="hidden" id="nextDay" name="nextDay" value="<%=Util.parseDate(tomorow, "dd/MM/yyyy") %>" />
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Conta Corrente"/>			
					</jsp:include>
					<div class="topContent">
						<div id="unidadeIn" class="textBox">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId" style="width: 75px;" onchange="setLiberacao()">								
								<%if (unidadeList.size() == 1) {
									out.print("<option value=\"" + unidadeList.get(0).getCodigo() + 
											"\" selected=\"selected\">" + unidadeList.get(0).getReferencia() + "</option>");
								} else {
									for(Cc cc: contaCorrente) {
										if (session.getAttribute("perfil").toString().equals("a")
												&& cc.getUnidade().getTipo().equals("h")) {
											out.print("<option value=\"" + cc.getUnidade().getCodigo() + 
													"\" selected=\"selected\">" + cc.getUnidade().getReferencia() + "</option>");
										} else {
											out.print("<option value=\"" + cc.getUnidade().getCodigo() + 
												"\">" + cc.getUnidade().getReferencia() + "</option>");
										}
									}
								}
								%>
							</select>
						</div>						
						<div id="dataInicial" class="textBox" style="width: 75px;">
							<label>Data Inicial</label><br/>
							<input id="dataInicialIn" name="dataInicialIn" type="text" style="width: 75px;" onkeydown="mask(this, dateType);" onchange="setLiberacao()"/>												
						</div>
						<div id="dataFinal" class="textBox" style="width: 75px;">
							<label>Data Final</label><br/>
							<input id="dataFinalIn" name="dataFinalIn" type="text" style="width: 75px;" onkeydown="mask(this, dateType);" onchange="setLiberacao()"/>												
						</div>
					</div>					
				</div>				
				<div class="topButtonContent">
					<%if (contaCorrente.size() > 0) {%>
						<div class="formGreenButton">
							<input id="cadastroConta" name="cadastroConta" class="greenButtonStyle" type="button" value="Conta" onclick="editaConta()"/>
						</div>
						<div class="formGreenButton">
							<input id="extrato" name="extrato" class="greenButtonStyle" type="button" value="Imp. Extrato" onclick="printExtrato()"/>
						</div>
						<div class="formGreenButton">
							<input id="buscar" name="buscar" class="greenButtonStyle" type="submit" value="Buscar"/>
						</div>
						<% if (contaCorrente.size() < unidadeList.size()) {%>
							<div class="formGreenButton">
								<input id="insereConta" name="insereConta" class="greenButtonStyle" type="button" value="Inserir" onclick="location.href = 'cadastro_conta_corrente.jsp'"/>
							</div>
						
						<%} %>
					<%} else {%>
						<div class="formGreenButton">
							<input id="insereConta" name="insereConta" class="greenButtonStyle" type="button" value="Inserir" onclick="location.href = 'cadastro_conta_corrente.jsp'"/>
						</div>
						<div class="formGreenButton">
							<input id="extrato" name="extrato" class="greenButtonStyle" type="button" value="Imp. Extrato" onclick="alertVazio()"/>
						</div>
						<div class="formGreenButton">
							<input id="buscar" name="buscar" class="greenButtonStyle" type="button" value="Buscar" onclick="alertVazio()"/>
						</div>
					<%}%>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>					
					<div id="dataGrid">
						<%DataGrid dataGrid = new DataGrid("");
						dataGrid.addColum("6", "Lanç.");
						dataGrid.addColum("24", "Documento");
						dataGrid.addColum("31", "Descrição");						
						dataGrid.addColum("10", "Emissão");
						dataGrid.addColum("10", "Data Pag.");
						dataGrid.addColum("2", "Tp");
						dataGrid.addColum("8", "valor");
						dataGrid.addColum("8", "Saldo");
						String gridLines = "";
						if (contaCorrente.size() > 0) {
							yesterday = Util.parseDate((Util.getDayDate(now) -1) +
									"/" + Util.getMonthDate(now) + "/" + Util.getYearDate(now) + " 00:00:59", "HH:mm:ss");
							
							tomorow = Util.parseDate((Util.getDayDate(now) + 1) +
									"/" + Util.getMonthDate(now) + "/" + Util.getYearDate(now) + " 00:01:00", "HH:mm:ss");
							
							if (session.getAttribute("perfil").toString().equals("a")) {
								query = sess.getNamedQuery("contaCreditoHold");
							} else {
								query = sess.getNamedQuery("contaCredito");
								query.setLong("unidade", contaCorrente.get(0).getUnidade().getCodigo());
							}							
							query.setTimestamp("dataInicio", contaCorrente.get(0).getCadastro());
							query.setTimestamp("dataFim", yesterday);
							saldo = contaCorrente.get(0).getValor() + ((query.uniqueResult() != null)?
									Double.parseDouble(query.uniqueResult().toString()) : 0);
							
							if (session.getAttribute("perfil").toString().equals("a")) {
								query = sess.getNamedQuery("contaDebitoHold");
							} else {
								query = sess.getNamedQuery("contaDebito");
								query.setLong("unidade", contaCorrente.get(0).getUnidade().getCodigo());
							}
							query.setTimestamp("dataInicio", contaCorrente.get(0).getCadastro());
							query.setTimestamp("dataFim", yesterday);							
							saldo-= (query.uniqueResult() != null)?
									Double.parseDouble(query.uniqueResult().toString()) : 0;
							
							if (session.getAttribute("perfil").toString().equals("a")) {
								query = sess.getNamedQuery("ccLancamentoHold");
							} else {
								query = sess.getNamedQuery("ccLancamento");
								query.setLong("unidade", contaCorrente.get(0).getUnidade().getCodigo());
							}
							query.setTimestamp("dataInicio", yesterday);							
							query.setTimestamp("dataFim", tomorow);
							lancamento = (List<Lancamento>) query.list();
							
							saldo = Util.round(saldo, 2);
							
							gridLines = Util.parseDate(yesterday, "dd/MM/yyyy") + "@" + saldo + "@" +  
								Util.parseDate(now, "dd/MM/yyyy") + "@";
							//gridLines = lancamento.size();
							
							for(Lancamento lanc: lancamento) {
								dataGrid.setId(String.valueOf(lanc.getCodigo()));
								dataGrid.addData(String.valueOf(lanc.getCodigo()));
								dataGrid.addData(lanc.getDocumento());
								dataGrid.addData(lanc.getConta().getDescricao());
								dataGrid.addData((lanc.getEmissao() == null)? "" 
										: Util.parseDate(lanc.getEmissao(), "dd/MM/yyyy"));
								dataGrid.addData(Util.parseDate(lanc.getDataQuitacao(), "dd/MM/yyyy"));
								if (lanc.getTipo().trim().equals("c")) {
									saldo+= lanc.getValorPago();
									creditos+= lanc.getValorPago();
									dataGrid.addImg("../image/credito.gif");
								} else {
									saldo-= lanc.getValorPago();
									debitos+= lanc.getValorPago();
									dataGrid.addImg("../image/debito.gif");
								}							
								dataGrid.addData(Util.formatCurrency(lanc.getValorPago()));
								dataGrid.addData(Util.formatCurrency(saldo));
								dataGrid.addRow();
							}
						}
						dataGrid.addTotalizador("Débitos", Util.formatCurrency(debitos), true);
						dataGrid.addTotalizador("Créditos", Util.formatCurrency(creditos), false);
						dataGrid.addTotalizadorRight("Saldo em" + Util.parseDate(now, "dd/MM/yyyy"), Util.formatCurrency(saldo));						
						dataGrid.makeTotalizador();	
						gridLines+= Util.formatCurrency(saldo);
						out.print(dataGrid.getTable(gridLines));						
						%>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>