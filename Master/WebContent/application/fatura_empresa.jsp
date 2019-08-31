<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Empresa"%>


<%@page import="com.marcsoftware.database.Informacao"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.FaturaEmpresa"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">

	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
	Empresa empresa = null;
	List<FaturaEmpresa> fatura;
	String informacao = "-1";
	String infoUnidade= "";
	if (!request.getParameter("id").equals("-1")) {
		query= sess.createQuery("from Empresa as e where e.codigo = :codigo");
		query.setLong("codigo", Long.valueOf(request.getParameter("id")));		
		empresa = (Empresa) query.uniqueResult();
	}
	if (empresa != null) {		
		query = sess.createQuery("from Informacao as i where i.principal = 's' and i.pessoa = :pessoa");
		query.setEntity("pessoa", empresa.getUnidade());
		if (query.list().size() == 1) {
			infoUnidade = ((Informacao) query.uniqueResult()).getDescricao();			
		}
	}
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
	
	if (empresa == null) {
		query = sess.createQuery("from FaturaEmpresa as f");
		fatura= (List<FaturaEmpresa>) query.list();
	} else {
		query = sess.getNamedQuery("faturaEmpOpen");
		query.setEntity("empresa", empresa);
		fatura = (List<FaturaEmpresa>) query.list();		
		query = sess.getNamedQuery("infoPrincipalByCode").setLong("codigo", empresa.getCodigo());
		informacao= String.valueOf(query.uniqueResult());
	}
	%>	
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<link rel="shortcut icon" href="../icone.ico">	
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
    
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/comum/fatura_empresa.js" ></script>	
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	
	<title>Master Faturamento para Empresas</title>
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
			<form id="parc" method="get">
				<div id="localEdTabela" ></div>
				<div id="localTabela"></div>
				<div id="deletedsServ"></div>
				<div>
					<input id="codEmpresa" name="codEmpresa" type="hidden" value="<%=(empresa == null)? "-1" : empresa.getCodigo()%>" />					
					<input id="now" name="now" type="hidden" value="<%=Util.getToday()%>" />
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Faturas"/>			
					</jsp:include>
					<%if (empresa != null) {%>
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
							<div class="sectedAba2">
								<label>Histórico de Faturas</label>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="bordero_empresa.jsp?&id=<%=empresa.getCodigo() %>">Borderô</a>
							</div>						
						</div>
					<%}%>
					<div class="topContent">
						<% if (empresa == null) {%>
							<div id="referencia" class="textBox" style="width: 85px;" >
								<label>CTR Empresa</label><br/>
								<input id="referenciaIn" name="referenciaIn" type="text" style="width: 85px;" />												
							</div>
							<div id="fantasia" class="textBox" style="width: 250px">
								<label>Nome Fantasia</label><br/>
								<input id="fantasiaIn" name="fantasiaIn" type="text" style="width: 250px" />
							</div>
							<div id="razaoSocial" class="textBox" style="width: 276px;">
								<label>Razão Social</label><br/>
								<input id="razaoSocialIn" name="razaoSocialIn" type="text" style="width: 276px;" />
							</div>
							<div id="nomeContato" class="textBox" style="width: 245px">
								<label>Nome do Contato</label><br/>					
								<input id="nomeContatoIn" name="nomeContatoIn" type="text" style="width: 245px" />
							</div>
							<div id="status" class="textBox">
								<label>Status</label><br/>
								<select id="statusIn" name="statusIn">
									<option value="">Selecione</option>
									<option value="a">Em Aberto</option>
									<option value="n">Em Atraso</option>
									<option value="q">Quitado</option>
									<option value="n">Negociado</option>
									<option value="c">Cancelado</option>
									<option value="f">Finalizado</option>
								</select>
							</div>
							<div id="referencia" class="textBox" style="width: 80px;" >
								<label>Data Inicial</label><br/>
								<input id="referenciaIn" name="referenciaIn" type="text" style="width: 80px;" />												
							</div>
							<div id="referencia" class="textBox" style="width: 85px;" >
								<label>Data Final</label><br/>
								<input id="referenciaIn" name="referenciaIn" type="text" style="width: 85px;" />												
							</div>							
							<div id="unidadeId" class="textBox">
								<label>Cod. Un.</label><br/>
								<select id="unidadeIdIn" name="unidadeIdIn">
									<option value="">Selecione</option>
									<%if (unidadeList.size() == 1) {
										out.print("<option value=\"" + unidadeList.get(0).getCodigo() +
												"\" selected=\"selected\">" + unidadeList.get(0).getReferencia() + "</option>");
									} else {
										for(Unidade un: unidadeList) {
											out.print("<option value=\"" + un.getCodigo() +
													"\">" + un.getReferencia() + "</option>");
										}
									}%>
								</select>
							</div>												
					<%} else {%>					
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
					<%}%>
					</div>
				</div>
				<div class="topButtonContent">
					<div class="formGreenButton">
						<input id="buscar" name="buscar" class="greenButtonStyle" type="button" value="Buscar" onclick="voltar()" />
					</div>
				</div>				
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid" >
						<%DataGrid dataGrid= new DataGrid("cadastro_fatura_empresa.jsp");
						int gridLines= fatura.size();
						dataGrid.addColum("10", "Fatura");	
						dataGrid.addColum("10", "Dt. Início");
						dataGrid.addColum("14", "Dt. Final");						
						dataGrid.addColum("50", "Empresa");
						dataGrid.addColum("10", "Valor Total");
						dataGrid.addColum("3", "St.");
						dataGrid.addColum("3", "Ck");
						for (FaturaEmpresa fat: fatura) {
							dataGrid.setId(String.valueOf(fat.getCodigo()));
							dataGrid.addData(String.valueOf(fat.getCodigo()));
							dataGrid.addData(Util.parseDate(fat.getDataInicio(), "dd/MM/yyyy"));
							dataGrid.addData(Util.parseDate(fat.getDataFim(), "dd/MM/yyyy"));
							dataGrid.addData(String.valueOf(fat.getEmpresa().getFantasia()));
							
							query = sess.getNamedQuery("totalFatura");
							query.setLong("fatura", fat.getCodigo());
							dataGrid.addData(Util.formatCurrency(query.uniqueResult().toString()));
							
							query = sess.getNamedQuery("lancamentoEmpresa");
							query.setEntity("fatura", fat);
							dataGrid.addImg(Util.getIcon(query.list(), "lancamento"));
							
							dataGrid.addCheck();
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));
						%>
						<div class="pagerGrid"></div>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>