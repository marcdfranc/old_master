<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Funcionario"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Usuario"%>
<%@page import="com.marcsoftware.database.Lancamento"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
	Lancamento lancamento;
	int consolidados;
	double vlrTotal;
	ArrayList<String> gridValues = new ArrayList<String>();
	Funcionario funcionario = (Funcionario) sess.get(Funcionario.class, Long.valueOf(request.getParameter("id")));	
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
	<script type="text/javascript" src="../js/comum/bordero_funcionario.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_window.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	
	<title>Master Borderô Fucionario</title>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="rh"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="rh"/>
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="get">
				<div id="geralDate" class="alignHeader">
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Borderô"/>			
					</jsp:include>
					<div>
						<input id="funcionarioId" name="funcionarioId" type="hidden" value="<%= funcionario.getCodigo() %>" />
					</div>
					<div id="abaMenu">
						<div class="aba2">
							<a href="cadastro_funcionario.jsp?state=1&id=<%= funcionario.getCodigo()%>">Cadastro</a>
						</div>						
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="anexo_rh.jsp?id=<%= funcionario.getCodigo()%>">Anexo</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="requisicao_contrato.jsp?id=<%= funcionario.getCodigo()%>">Requisição</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="contrato.jsp?state=1&id=<%= funcionario.getCodigo()%>">Contratos</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>						
						<div class="sectedAba2">
							<label>Borderô</label>
						</div>					
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="fatura_vendedor.jsp?id=<%= funcionario.getCodigo()%>">Histórico de Faturas</a>
						</div>
					</div>
					<div class="topContent">
						<div class="textBox" id="unidadeRef" name="unidadeRef" style="width: 65px;">
							<label>Cód. Unid.</label><br/>
							<input id="unidadeRefIn" name="unidadeRefIn" type="text" style="width:65px" readonly="readonly" value="<%=funcionario.getUnidade().getReferencia()%>"/>
						</div>
						<div id="unidade" class="textBox" style="width: 200px;" >
							<label>Unidade</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" style="width: 200px;" value="<%= Util.initCap(funcionario.getUnidade().getFantasia()) %>" readonly="readonly" />
						</div>
						<div id="requisicao" class="textBox" style="width: 73px;">
							<label>Requisição</label><br/>
							<input id="requisicaoIn" name="requisicaoIn" type="text" style="width: 73px;" onkeydown="mask(this, typeDate);" value="<%= Util.getToday() %>" />
						</div>
						<div id="" class="textBox" style="width:45px;">
							<label>Ref.</label><br/>
							<input id="referenciaIn" name="referenciaIn" readonly="readonly" type="text" style="width: 45px" value="<%= funcionario.getCodigo() %>" />
						</div>
						<div id="funcionario" class="textBox" style="width: 200px;" >
							<label>Funcionario</label><br/>
							<input id="funcionarioIn" name="funcionarioIn" type="text" style="width: 200px;" value="<%=Util.initCap(funcionario.getNome())%>" readonly="readonly" />
						</div>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">					
					<%query = sess.createQuery("from Usuario as u " +
							"where u.contrato not in(select i.id.contrato from ItensVendedor as i) " +
							"and u.contrato.funcionario = :funcionario order by u.cadastro desc");
					query.setEntity("funcionario", funcionario);
					List<Usuario> usuarioList = (List<Usuario>) query.list();
					int gridLines = usuarioList.size();
					query.setFirstResult(0);
					query.setMaxResults(5);
					DataGrid dataGrid = new DataGrid("#");
					double adesao = 0;
					dataGrid.addColum("5", "CTR");
					dataGrid.addColum("59", "Titular");
					dataGrid.addColum("10", "Requisição");
					dataGrid.addColum("10", "Cadastro");															
					dataGrid.addColum("10", "valor");
					dataGrid.addColum("3", "St");
					dataGrid.addColum("3", "Ck");
					consolidados = 0;
					vlrTotal = 0;
					for(Usuario user: usuarioList) {
						try {
							query = sess.getNamedQuery("adesaoByCtr");
							query.setLong("codigo", user.getContrato().getCodigo());
							lancamento = (Lancamento) query.uniqueResult();
							adesao = (lancamento.equals(null))? 0 : lancamento.getValor();						
							
							dataGrid.setId(String.valueOf(user.getContrato().getCodigo()));
							dataGrid.addData(Util.zeroToLeft(user.getContrato().getCtr(), 4));
							dataGrid.addData(Util.initCap(user.getNome()));
							dataGrid.addData(Util.parseDate(user.getContrato().getRequisicao(), "dd/MM/yyyy"));
							dataGrid.addData(Util.parseDate(user.getCadastro(), "dd/MM/yyyy"));
							if (gridLines >= user.getContrato().getFuncionario().getMeta()) {
								adesao = adesao * (user.getContrato().getFuncionario().getBonus() / 100);
							} else {
								adesao = adesao * (user.getContrato().getFuncionario().getComissao() / 100);
							}
							gridValues.add(Util.formatCurrency(adesao));
							dataGrid.addData(Util.formatCurrency(adesao));						
							dataGrid.addImg(Util.getRealIcon(lancamento.getVencimento(), lancamento.getStatus()));
							dataGrid.addCheck(true);
							dataGrid.addRow();
							
							if (lancamento.getStatus().equals("q")) {
								vlrTotal+= adesao;
								consolidados++;
							}
							
						} catch (Exception e) {
							//out.print(user.getCodigo() + '@');
							
						}
					}
					out.print(dataGrid.getTable(gridLines));
					%>
					</div>
					<div class="totalizador">
						<label id="total" name="total" style="margin-left: 15px"><%= Util.formatCurrency(vlrTotal) %></label>
						<label id="labelTotal" class="titleCounter">CTR's Vendidos: <%=gridLines%> - Consolidados: <%=consolidados%> - Total:</label>
					</div>
					<div class="totalizadorRight">
						<label id="labelSoma" class="titleCounter" style="margin-right: 5px;">total a pagar:</label>
						<label id="totalSoma" name="totalSoma" style="margin-right: 70px">0.00</label>
					</div>
					<div id="somador">	
						<%for(int i=0 ; i < gridValues.size(); i++) {%>
							<input id="<%= "gridValue" + i %>" name="<%= "gridValue" + i %>" type="hidden"  value="<%=gridValues.get(i)%>"/>
						<%}%>
					</div>
				</div>
				<div class="buttonContent">
					<div class="formGreenButton">
						<input id="selecione" name="selecione" class="greenButtonStyle" type="button" value="todos" onclick="selectAll()" />
					</div>
					<div class="formGreenButton">
						<input id="pagamento" name="pagamento" class="greenButtonStyle" type="button" value="Gerar Fatura" onclick="generate()" />
					</div>				
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>