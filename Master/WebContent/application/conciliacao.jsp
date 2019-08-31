<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.FormaPagamento"%>
<%@page import="com.marcsoftware.database.Conciliacao"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.marcsoftware.database.ItensConciliacao"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">

	<%List<ItensConciliacao> itConcilio;
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query = sess.createQuery("from FormaPagamento as f where f.concilia = 's'");
	List<FormaPagamento> pagamento = (List<FormaPagamento>) query.list();
	
	ArrayList<String> gridValues = new ArrayList<String>();
	
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
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Conciliação</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>	
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/comum/conciliacao.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
</head>
<body onload="load()">
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
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Conciliação"/>			
					</jsp:include>
					<div class="topContent">												
						<div id="codigo" class="textBox" style="width: 70px;">
							<label>Código</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" style="width: 70px;"/>
						</div>
						<div id="numero" class="textBox" style="width: 130px;">
							<label>Número</label><br/>
							<input id="numeroIn" name="numeroIn" type="text" style="width: 130px;" />
						</div>
						<div class="textBox">
							<label>Tipo</label><br/>
							<select id="tipoLancamento" name="tipoLancamento" >
								<option value="">Todas Conciliações</option>
								<option value="d">Débito a Conciliar</option>
								<option value="c">Crédito a Conciliar</option>
							</select>
						</div>						
						<div class="textBox">
							<label>Pagamento</label><br/>
							<select id="tipoPagamento" name="tipoPagamento" >
								<option value="">Todos</option>
								<%for(FormaPagamento pag: pagamento) {
									out.println("<option value=\"" + pag.getCodigo() +
										"\" >" + pag.getDescricao() + "</option>");
								}%>								
							</select>
						</div>
						<div class="textBox">
							<label>Tipo</label><br/>
							<select id="status" name="status" >
								<option value="">Todos</option>
								<option selected="selected" value="a">Conciliados</option>
								<option value="q">Baixados</option>
							</select>
						</div>
						<div id="inicio" class="textBox" style="width: 73px;">
							<label>Dt. Inicial</label><br/>
							<input id="inicioIn" name="inicioIn" type="text" style="width: 73px;"  onkeydown="mask(this, dateType);"/>
						</div>
						<div id="fim" class="textBox" style="width: 73px;">
							<label>Dt. final</label><br/>
							<input id="fimIn" name="fimIn" type="text" style="width: 73px;"  onkeydown="mask(this, dateType);"/>
						</div>					
						<div class="textBox" style="width:85px">
							<label>Unidade</label><br/>
							<select id="unidadeId" name="unidadeId">
								<option>Selecione</option>
								<%for(Unidade un: unidadeList) {
									if (session.getAttribute("unidade").toString().trim().equals("-1")
											|| session.getAttribute("unidade").toString().trim().equals("0")) {
										out.print("<option value=\"" + un.getCodigo() + "\">" + 
												un.getReferencia() + "</option>");										
									} else {
										if (un.getCodigo() == (Long) session.getAttribute("unidade")) {
											out.print("<option value=\"" + un.getCodigo() + 
													"\" selected=\"selected\">" + un.getReferencia() + 
													"</option>");
										} else {
											out.print("<option value=\"" + un.getCodigo() + "\">" + 
													un.getReferencia() + "</option>");
										}
									}
								}
								%>
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
						<%Date now = new Date();
						query = sess.getNamedQuery("conciliacaoByUnidade");
						if (session.getAttribute("unidade").toString().trim().equals("-1")
								|| session.getAttribute("unidade").toString().trim().equals("0")) {
							query.setLong("unidade", new Long(0));
						} else {
							query.setLong("unidade", (Long) session.getAttribute("unidade"));
						}
						List<Conciliacao> conciliaList = (List<Conciliacao>) query.list();
						int gridLines = conciliaList.size();
						String valor = "";
						DataGrid dataGrid = new DataGrid("cadastro_conciliacao.jsp");
						dataGrid.addColum("10", "Código");
						dataGrid.addColum("32", "Título");
						dataGrid.addColum("10", "Emissão");
						dataGrid.addColum("18", "Vencimento");
						dataGrid.addColum("10", "tp.");
						dataGrid.addColum("15", "Valor");
						dataGrid.addColum("3", "St.");
						dataGrid.addColum("2", "Ck");
						for(Conciliacao conciliacao: conciliaList) {
							query = sess.getNamedQuery("totalConcilio");
							query.setLong("conciliacao", conciliacao.getCodigo());
							valor = Util.formatCurrency(query.uniqueResult().toString());
							query = sess.createQuery("from ItensConciliacao as i where i.id.conciliacao = :conciliacao");
							query.setEntity("conciliacao", conciliacao);
							itConcilio = (List<ItensConciliacao>) query.list();
							dataGrid.setId(String.valueOf(conciliacao.getCodigo()));
							dataGrid.addData(String.valueOf(conciliacao.getCodigo()));
							dataGrid.addData(conciliacao.getNumero());
							dataGrid.addData(Util.parseDate(conciliacao.getEmissao(), "dd/MM/yyyy"));
							dataGrid.addData(Util.parseDate(conciliacao.getVencimento(), "dd/MM/yyyy"));
							if (itConcilio.get(0).getId().getLancamento().getTipo().trim().equals("c")) {
								dataGrid.addImg("../image/credito.gif");
							} else {
								dataGrid.addImg("../image/debito.gif");
							}
							dataGrid.addData("valTot", valor);
							gridValues.add(valor);							
							if (conciliacao.getVencimento().before(now)
									&& conciliacao.getStatus().equals("a")) {
								dataGrid.addImg("../image/atraso.png");
							} else {
								dataGrid.addImg("../image/ok_icon.png");
							}
							dataGrid.addCheck(true);
							dataGrid.addRow();
						}
						dataGrid.addTotalizadorRight("Total", "0.00", "totalSoma");
						dataGrid.makeTotalizadorRight();
						out.print(dataGrid.getTable(gridLines));
						%>
					</div>					
					<div id="somador">
						<%for(int i=0 ; i < gridValues.size(); i++) {%>
							<input id="<%= "gridValue" + i %>" name="<%= "gridValue" + i %>" type="hidden"  value="<%=gridValues.get(i)%>"/>
						<%}%>
					</div>
					<div class="buttonContent">
						<div class="formGreenButton" >
							<input id="selecAll" name="selecAll" class="greenButtonStyle" type="button" value="Todos" onclick="selectAll()"/>
						</div>
						<%if (session.getAttribute("perfil").toString().trim().equals("a")
								|| session.getAttribute("perfil").toString().trim().equals("d")
								|| session.getAttribute("perfil").toString().trim().equals("f")) {%>
							<div class="formGreenButton" >
								<input id="pagamento" name="pagamento" class="greenButtonStyle" type="button" value="Baixar" onclick="execBaixa()"/>
							</div>
						<%}%>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close(); %>
	</div>
</body>
</html>