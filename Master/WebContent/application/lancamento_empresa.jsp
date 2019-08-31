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
<%@page import="java.util.Date"%>
<%@page import="com.marcsoftware.database.Lancamento"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
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
	if (session.getAttribute("perfil").toString().equals("a")
			|| session.getAttribute("perfil").toString().equals("d")) {
		query = sess.createSQLQuery("SELECT COUNT(*) FROM contrato_empresa");		
	} else if(unidadeList.size() == 1) {
		query = sess.createSQLQuery("SELECT COUNT(c.*) FROM contrato_empresa AS c " +
				" INNER JOIN pessoa AS p ON(c.cod_empresa = p.codigo) " +
				" WHERE p.cod_unidade = :unidade");
		query.setLong("unidade", unidadeList.get(0).getCodigo());
	} else {
		query = sess.createSQLQuery("SELECT COUNT(c.*) FROM contrato_empresa AS c " +
				" INNER JOIN pessoa AS p ON(c.cod_empresa = p.codigo) " +
				" WHERE (1 <> 1)");
	}
	Long ctrs = Long.valueOf(query.uniqueResult().toString());
	List<Lancamento> lancamentoList;
	double vlrTotal= 0;
	Date now = new Date();	
	Date vencimento = Util.parseDate("2/" + (Util.getMonthDate(now) + 1) + "/" + Util.getYearDate(now));
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>	
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/comum/lancamento_empresa.js" ></script>
	
	<title>Master Bordero de Empresas</title>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="clienteJ"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="clienteJ"/>
		</jsp:include>
		<div id="formStyle">
			<form id="formEmpresa" method="get" onsubmit="return search();" >
				<div>
					<input type="hidden" id="now" name="now" value="<%=Util.getToday()%>" />
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Borderô"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="empresa.jsp">Jurídico</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="sectedAba2">
							<label>Bordero Geral</label>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="lancamento_empresa_mensalidade.jsp">Bordero de Mensalidades</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="lancamento_empresa_tratamento.jsp">Bordero de Tratamentos</a>
						</div>
					</div>
					<div class="topContent">
						<div id="referencia" class="textBox" style="width: 70px;" >
							<label>CTR</label><br/>
							<input id="referenciaIn" name="referenciaIn" type="text" style="width: 70px;" />												
						</div>
						<div id="razaoSocial" class="textBox" style="width: 270px;">
							<label>Razão Social</label><br/>
							<input id="razaoSocialIn" name="razaoSocialIn" type="text" style="width: 270px;" />
						</div>
						<div id="fantasia" class="textBox" style="width: 250px">
							<label>Fantasia</label><br/>
							<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 270px" />
						</div>
						<div id="nomeContato" class="textBox" style="width: 245px">
							<label>Nome do Contato</label><br/>					
							<input id="nomeContatoIn" name="nomeContatoIn" type="text" style="width: 245px" />
						</div>
						<div class="textBox" style="margin-right: 45px">
							<label>Unidade</label><br/>
							<select id="unidadeId" name="unidadeId">
								<option value="">selecione</option>
								<%for(Unidade un: unidadeList) {
									out.print("<option value=\"" + un.getRazaoSocial() + "@" +
											un.getCodigo() + "\">" + un.getReferencia() + "</option>");
								}
								%>
							</select>
						</div>
						<div id="status" class="textBox" style="width: 280px">
							<label >Status</label><br />
							<div class="checkRadio">
								<label class="labelCheck" >Ativo</label>
								<input id="ativoChecked" name="ativoChecked" onchange="setChange('u')" type="radio" checked="checked" value="a" />
								<label class="labelCheck" >Bloqueado</label>
								<input id="ativoChecked" name="ativoChecked" type="radio" onchange="setChange('u')" value="b" />
								<label class="labelCheck" >Cancelado</label>
								<input id="ativoChecked" name="ativoChecked" type="radio" onchange="setChange('u')" value="c" />
							</div>
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
						<%if (session.getAttribute("perfil").toString().equals("a")
								|| session.getAttribute("perfil").toString().equals("d")) {
							query = sess.getNamedQuery("mensalidadeBorderoHold");							
						} else if(unidadeList.size() == 1) {
							query = sess.getNamedQuery("mensalidadeBordero");
							query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
						} else {
							query = sess.createQuery("from Lancamento as l where l.vencimento = :vencimento and (1 <> 1)");
						}
						query.setDate("vencimento", vencimento);
						lancamentoList = (List<Lancamento>) query.list();
						DataGrid dataGrid = new DataGrid("#");
						dataGrid.addColum("10", "Lanç.");
						dataGrid.addColum("30", "Documento");
						dataGrid.addColum("30", "Descricao");						
						dataGrid.addColum("20", "Vencimento");
						dataGrid.addColum("10", "valor");							
						for(Lancamento lancamento: lancamentoList) {
							dataGrid.setId(String.valueOf(lancamento.getCodigo()));
							dataGrid.addData(String.valueOf(lancamento.getCodigo()));
							dataGrid.addData(lancamento.getDocumento());
							dataGrid.addData(lancamento.getConta().getDescricao());
							dataGrid.addData(Util.parseDate(lancamento.getEmissao(), "dd/MM/yyyy"));
							dataGrid.addData(Util.formatCurrency(lancamento.getValor()));
							vlrTotal+= lancamento.getValor();
							dataGrid.addRow();
						}
						if (session.getAttribute("perfil").toString().equals("a")
								|| session.getAttribute("perfil").toString().equals("d")) {
							query = sess.getNamedQuery("parcelaBorderoHold");							
						} else if(unidadeList.size() == 1) {
							query = sess.getNamedQuery("parcelaBordero");
							query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
						} else {
							query = sess.createQuery("from Lancamento as l where l.vencimento = :vencimento and (1 <> 1)");
						}
						query.setDate("vencimento", vencimento);
						lancamentoList = (List<Lancamento>) query.list();
						for(Lancamento lancamento: lancamentoList) {
							dataGrid.setId(String.valueOf(lancamento.getCodigo()));
							dataGrid.addData(String.valueOf(lancamento.getCodigo()));
							dataGrid.addData(lancamento.getDocumento());
							dataGrid.addData(lancamento.getConta().getDescricao());							
							dataGrid.addData(Util.parseDate(lancamento.getVencimento(), "dd/MM/yyyy"));
							dataGrid.addData(Util.formatCurrency(lancamento.getValor()));
							vlrTotal+= lancamento.getValor();
							dataGrid.addRow();
						}						
						out.print(dataGrid.getTable(1));
						%>
					</div>
					<div class="totalizador">
						<label id="total" name="total" style="margin-left: 15px"><%= Util.formatCurrency(vlrTotal) %></label>
						<label id="labelTotal" class="titleCounter">Número de CTR's: <%=ctrs%> - Valor Total do Borderô:</label>
					</div>
				</div>				
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<% sess.close(); %>
	</div>
</body>
</html>