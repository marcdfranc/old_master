<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@page import="com.marcsoftware.database.ParcelaOrcamento"%>
<%@page import="com.marcsoftware.database.Mensalidade"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Empresa"%>
<%@page import="com.marcsoftware.database.Lancamento"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Usuario"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query= sess.createQuery("from Empresa as e where e.codigo = :codigo");
	query.setLong("codigo", Long.valueOf(request.getParameter("id")));		
	Empresa empresa = (Empresa) query.uniqueResult();
	query = sess.createQuery("select i.descricao from Informacao as i where i.pessoa = :empresa and i.principal = 's'");
	query.setEntity("empresa", empresa);
	String informacao = (query.list().size() == 1)? (String) query.uniqueResult() : "1"; 
	query = sess.createQuery("select i.descricao from Informacao as i where i.pessoa = :unidade and i.principal = 's'");
	query.setEntity("unidade", empresa.getUnidade());
	String infoUnidade = (String) query.uniqueResult();
	List<Lancamento> lancamentoList;
	query = sess.getNamedQuery("ctrsEmpresa");
	query.setLong("empresa", empresa.getCodigo());	
	Long ctrs = Long.valueOf(query.uniqueResult().toString());
	ArrayList<String> gridValues = new ArrayList<String>();
	double vlrTotal= 0;
	Date now = new Date();
	Date vencimento = Util.parseDate("2/" + (Util.getMonthDate(now) + 1) + "/" + Util.getYearDate(now));
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />	
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/comum/bordero_empresa.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	
	<title>Master Borderô Empresa</title>
</head>
<body onload="load()">
	<div id="geracao" class="removeBorda" title="Geração de Fatura" style="display: none">			
		<form id="formGeracao" onsubmit="return false;">
			<fieldset>
				<label for="mesBase">Mês Base</label>
				<select id="mesBase" name="mesBase" style="width: 100%" onchange="adjustPagamento(this)">
					<option value="1">Janeiro</option>
					<option value="2">Fevereiro</option>
					<option value="3">Março</option>
					<option value="4">Abril</option>
					<option value="5">Maio</option>
					<option value="6">Junho</option>
					<option value="7">Julho</option>
					<option value="8">Agosto</option>
					<option value="9">Setembro</option>
					<option value="10">Outubro</option>
					<option value="11">Novembro</option>
					<option value="12">Dezembro</option>
				</select>				
				<label for="anoBase">Ano Base</label>
				<input type="text" name="anoBase" id="anoBase" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, onlyInteger)" value="<%= Util.getYearDate(Util.getToday()) %>"  />
				<label for="vencFatura">Vencimento</label>
				<input type="text" name="vencFatura" id="vencFatura" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, dateType)" />
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="clienteJ"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="clienteJ"/>
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="post" action="../CadastroPosicao">
				<div>
					<input id="empresaId" name="empresaId" value="<%= empresa.getCodigo() %>" type="hidden"/>
					<input id="diaVencEmpresa" name="diaVencEmpresa" value="<%= empresa.getVencimento() %>" type="hidden"/>
				</div>
				<div id="geralDate" class="alignHeader">
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Borderô"/>			
					</jsp:include>
					<div id="abaMenu">
						<div class="aba2">
							<a href="cadastro_cliente_juridico.jsp?state=1&id=<%=empresa.getCodigo() %>">Cadastro</a>
						</div>						
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="#">Anexo</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="cliente_fisico.jsp?&id=<%=empresa.getCodigo() %>">Funcionários</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="fatura_empresa.jsp?&id=<%=empresa.getCodigo() %>">Histórico de Faturas</a>
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
							<a href="bordero_mensalidade.jsp?&id=<%=empresa.getCodigo() %>">Borderô de Mensalidades</a>
						</div>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<div class="aba2">
							<a href="bordero_tratamento.jsp?&id=<%=empresa.getCodigo() %>">Borderô de Tratamentos</a>
						</div>
					</div>
					<div class="topContent">					
						<div id="refUnidade" class="textBox" style="width: 85px;">
							<label>Cod. Unidade</label><br/>
							<input id="refUnidadeIn" name="refUnidadeIn" type="text" style="width: 85px;" value="<%=empresa.getUnidade().getReferencia()%>" readonly="readonly" />
						</div>
						<div id="unidade" class="textBox" style="width: 300px;">
							<label>Unidade</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" style="width: 300px;" value="<%=Util.initCap(empresa.getUnidade().getRazaoSocial())%>" readonly="readonly" />
						</div>
						<div id="telUnidade" class="textBox" style="width: 210px;">
							<label>Telefone</label><br/>
							<input id="telUnidadeIn" name="telUnidadeIn" type="text" style="width: 210px;" value="<%= infoUnidade %>" readonly="readonly" />
						</div>
						<div id="refEmpresa" class="textBox" style="width: 85px;">
							<label>CTR Empresa</label><br/>
							<input id="refEmpresaIn" name="refEmpresaIn" type="text" style="width: 85px;" value="<%=empresa.getReferencia()%>" readonly="readonly" />
						</div>
						<div id="fantasia" class="textBox" style="width: 380px;">
							<label>Empresa</label><br/>
							<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 380px;" value="<%=Util.initCap(empresa.getFantasia())%>" readonly="readonly" />
						</div>
						<div id="cnpj" class="textBox" style="width: 130px;">
							<label>CNPJ</label><br/>
							<input id="cnpjIn" name="cnpjIn" type="text" style="width: 130px;" value="<%=Util.mountCnpj(empresa.getCnpj())%>" readonly="readonly" />
						</div>
						<div id="contato" class="textBox" style="width: 300px;">
							<label>Contato</label><br/>
							<input id="contatoIn" name="contatoIn" type="text" style="width: 300px;" value="<%=Util.initCap(empresa.getContato())%>" readonly="readonly" />
						</div>
						<div id="informacao" class="textBox" style="width: 310px;">
							<label>Telefone</label><br/>
							<input id="informacaoIn" name="informacaoIn" type="text" style="width: 310px;" value="<%=(informacao.equals("-1"))? "" : informacao %>" readonly="readonly" />
						</div>						
					</div>					
				</div>
				<div id="mainContent">				
					<div id="dataGrid" style="" >
						<div id="centerGrid">
							<div id="counter"></div>
							<%query = sess.getNamedQuery("mensalidadeBorderoEmp");
							query.setDate("vencimento", vencimento);
							query.setEntity("empresa", empresa);
							lancamentoList = (List<Lancamento>) query.list();
							Usuario userAux = null;
							DataGrid dataGrid = new DataGrid("#");
							dataGrid.addColum("8", "Lanç.");
							dataGrid.addColum("30", "CTR");
							dataGrid.addColum("30", "Descricao");
							dataGrid.addColum("10", "Emissão");
							dataGrid.addColum("10", "Vencimento");
							dataGrid.addColum("10", "valor");
							dataGrid.addColum("2", "Ck");
							for(Lancamento lancamento: lancamentoList) {
								query = sess.createQuery("select m.usuario from Mensalidade m where m.lancamento = :lancamento");
								query.setEntity("lancamento", lancamento);
								userAux = (Usuario) query.uniqueResult();
								dataGrid.setId(String.valueOf(lancamento.getCodigo()));
								dataGrid.addData(String.valueOf(lancamento.getCodigo()));
								dataGrid.addData(String.valueOf(userAux.getContrato().getCtr()));
								dataGrid.addData(lancamento.getConta().getDescricao());
								dataGrid.addData(Util.parseDate(lancamento.getEmissao(), "dd/MM/yyyy"));
								dataGrid.addData(Util.parseDate(lancamento.getVencimento(), "dd/MM/yyyy"));
								dataGrid.addData(Util.formatCurrency(lancamento.getValor()));
								dataGrid.addCheck(true);
								gridValues.add(Util.formatCurrency(lancamento.getValor()));
								vlrTotal+= lancamento.getValor();
								dataGrid.addRow();
							}
							query = sess.getNamedQuery("parcelaBorderoEmp");							
							query.setDate("vencimento", vencimento);
							query.setEntity("empresa", empresa);
							lancamentoList = (List<Lancamento>) query.list();
							 
							for(Lancamento lancamento: lancamentoList) {
								query = sess.createQuery("select p.id.orcamento.usuario from ParcelaOrcamento p where p.id.lancamento = :lancamento");
								query.setEntity("lancamento", lancamento);								
								userAux = (Usuario) query.uniqueResult();
								dataGrid.setId(String.valueOf(lancamento.getCodigo()));
								dataGrid.addData(String.valueOf(lancamento.getCodigo()));
								dataGrid.addData(String.valueOf(userAux.getContrato().getCtr()));
								dataGrid.addData(lancamento.getConta().getDescricao());
								dataGrid.addData(Util.parseDate(lancamento.getEmissao(), "dd/MM/yyyy"));
								dataGrid.addData(Util.parseDate(lancamento.getVencimento(), "dd/MM/yyyy"));
								dataGrid.addData(Util.formatCurrency(lancamento.getValor()));
								dataGrid.addCheck(true);
								gridValues.add(Util.formatCurrency(lancamento.getValor()));
								vlrTotal+= lancamento.getValor();
								dataGrid.addRow();
							}						
							out.print(dataGrid.getTable(1));                                       
							%>
						</div>						
					</div>
					<div class="totalizador">
						<label id="total" name="total" style="margin-left: 15px"><%= Util.formatCurrency(vlrTotal) %></label>
						<label id="labelTotal" class="titleCounter">Número de CTR's: <%=ctrs%> - Valor Total do Borderô:</label>
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
		<%sess.close(); %>
	</div>
</body>
</html>