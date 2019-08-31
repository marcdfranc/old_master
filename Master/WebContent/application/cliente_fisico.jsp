<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="com.marcsoftware.database.Usuario"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="java.util.List"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Informacao"%>

<%@page import="com.marcsoftware.utilities.DataGr"%>
<%@page import="com.marcsoftware.database.Lancamento"%>
<%@page import="com.marcsoftware.database.ParcelaOrcamento"%>
<%@page import="com.marcsoftware.database.Mensalidade"%>
<%@page import="com.marcsoftware.database.Empresa"%>
<%@page import="com.marcsoftware.database.Plano"%><html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />	
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
    <script type="text/javascript" src="../js/jquery/interface.js"></script>	
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>	
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/comum/assistente_carteirinha_new.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
    <script type="text/javascript" src="../js/lib/componentes/item_selector.js"></script>
	<script type="text/javascript" src="../js/comum/cliente_fisico.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	
	<jsp:useBean id="informacao" class="com.marcsoftware.database.Informacao"></jsp:useBean>
	<jsp:useBean id="empresa" class="com.marcsoftware.database.Empresa"></jsp:useBean>
	<%!Query query; %>
	<%!Session sess; %>
	<%! boolean isEmDia= false; %>
	<%! List<Unidade> unidadeList; %>	
	<%sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	
	if (session.getAttribute("perfil").equals("a")) {
		query= sess.createQuery("from Unidade as u where u.deleted =\'n\'");		
	} else if (session.getAttribute("perfil").equals("f")) {
		query= sess.getNamedQuery("unidadeByUser");
		query.setString("username", (String) session.getAttribute("username"));
	} else {
		query = sess.createQuery("select p.unidade from Pessoa as p where p.login = :username");
		query.setString("username", (String) session.getAttribute("username"));
	}
	unidadeList= (List<Unidade>) query.list();
	
	String sql = "from Plano as p where p.unidade.codigo in(";
	for (int i = 0; i < unidadeList.size(); i++) {
		if (i == 0) {
			sql += unidadeList.get(i).getCodigo();
		} else {
			sql += ", " + unidadeList.get(i).getCodigo();
		}
	}
	query = sess.createQuery(sql + ")");
	List<Plano> planoList = (List<Plano>) query.list();
	boolean isEmpresa = false;
	if (request.getParameter("id") != null) {
		empresa = (Empresa) sess.get(Empresa.class, Long.valueOf(request.getParameter("id")));
		isEmpresa = true;
	}
	%>

<title>Master Usuários</title>
</head>
<body onload="load()">
	<div id="imprimeWindow" title="Imprimir" style="display: none;">
		<form onsubmit="return false;">			
			<label for="statusConta">Status</label>
			<select id="statusConta" name="statusConta" style="width: 100%">	
				<option value="">Selecione</option>										
				<option value="a">Ativo</option>
				<option value="b">Bloqueado</option>
				<option value="c">Cancelado</option>
			</select>			
		</form>
	</div>
	<div id="stage1" class="cpEscondeWithHeight removeBorda" title="Selecione a Impressão Que Deseja Executar">			
		<form id="formStage1" onsubmit="return false;">
			<fieldset>
				<label for="CarteiraUnd">Cod. Unid.</label>
				<select id="CarteiraUnd" name="CarteiraUnd" style="width: 100%">
					<option value="0">Selecione</option>
					<%if (unidadeList.size() == 1) {
						out.print("<option  value=\"" + unidadeList.get(0).getCodigo() + 
								"\" selected=\"selected\">" + unidadeList.get(0).getReferencia() + "</option>");
					} else {
						for(Unidade un: unidadeList) {
							out.print("<option value=\"" + un.getCodigo() + 
									"\">" + un.getReferencia() + "</option>");
						}									
					}
					%>
				</select>
				<label for="via">Vias</label>
				<div id="paramBoxRd" class="checkRadio ui-corner-all">
					<label class="labelCheck" >Todos</label>
					<input type="radio" id="via" name="via" value="t" checked="checked"/>
					<label class="labelCheck" >Somente Primeiras Vias</label>
					<input type="radio" id="via" name="via" value="p"/>					
				</div>
				<label for="selecao">Seleção</label>
				<div id="paramBoxRd" class="checkRadio ui-corner-all">
					<label class="labelCheck">Todos</label>
					<input type="radio" id="selecao" name="selecao" value="" checked="checked"/>
					<label class="labelCheck" >Por CTR</label>
					<input type="radio" id="selecao" name="selecao" value="c"/>
					<label class="labelCheck" >Por Empresa</label>
					<input type="radio" id="selecao" name="selecao" value="e"/>					
				</div>
				<label for="emissao">Emissão</label>
				<div id="paramBoxRd" class="checkRadio ui-corner-all">
					<label class="labelCheck" >Todos</label>
					<input type="radio" id="emissao" name="emissao" value="" checked="checked"/>
					<label class="labelCheck" >Titulares</label>
					<input type="radio" id="emissao" name="emissao" value="c"/>
					<label class="labelCheck" >Dependentes</label>
					<input type="radio" id="emissao" name="emissao" value="d"/>					
				</div>
				<label for="tipoImpressao">Tipo de Impressão</label>
				<div id="paramBoxRd" class="checkRadio ui-corner-all">
					<label class="labelCheck" >Jato de Tinta</label>
					<input type="radio" id="tipoImpressao" name="tipoImpressao" value="0" checked="checked"/>
					<label class="labelCheck" >Cartão PVC</label>
					<input type="radio" id="tipoImpressao" name="tipoImpressao" value="1"/>
					<label class="labelCheck" >Cartão PVC Único</label>
					<input type="radio" id="tipoImpressao" name="tipoImpressao" value="2"/>					
				</div>
				<label for="ctrCarteira">CTR's</label>
				<input type="text" name="ctrCarteira" id="ctrCarteira" class="textDialog ui-widget-content ui-corner-all" />			
			</fieldset>
		</form>
	</div>
	<div id="stage2" class="cpEscondeWithHeight removeBorda" title="Selecione a Impressão que Deseja Executar">			
		<form id="formStage2" onsubmit="return false;">
			<fieldset>
				<label for="userIds">Seleção de Nomes</label>
				<div class="itContent ui-corner-all" id="selectorNames" style="width: 700px; margin-bottom: 15px;">
					<div style="width: 330px; height: 100px; float:left; margin-bottom: 0 !important">
						<label class="ui-corner-all titleBar">Itens</label>
						<ul id="sortableLeft" class="connectedSortable ui-corner-all leftList" style="width: 330px; height: 250px;">
							
						</ul>
					</div>
					<div class="btContent" ></div>
					<div style="width: 330px; height: 80px; float:left; margin-bottom: 0 !important">
						<label class="ui-corner-all titleBar">Selecinados</label>
						<ul id="sortableRight" class="connectedSortable ui-corner-all leftList" style="width: 330px; height: 250px;">							
							
						</ul>
					</div>
				</div>
				<br />
				<div>
					<input type="checkbox" id="isTeste" name="isTeste" checked="checked" style="margin-top: 20px;" />
					<label for="isTeste">Impressão de Teste</label>
				</div>
			</fieldset>
		</form>
	</div>	
	<%@ include file="../inc/header.jsp" %>	
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="clienteF"/>
	</jsp:include>	
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="clienteF"/>			
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="get" onsubmit="return search()">
				<div>
					<input id="empresaId" name="empresaId" type="hidden" value="<%=(request.getParameter("id") == null)? "" : request.getParameter("id")%>" />
					<input type="hidden" name="diasCarteira" id="diasCarteira" value="0"/>
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Cliente"/>			
					</jsp:include>
					<%if (request.getParameter("id") == null) {%>
						<div id="abaMenu">
							<div class="aba2">
								<a href="empresa.jsp">Cliente Jurídico</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>						
							<div class="sectedAba2">
								<label>Cliente Físico</label>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="dependentes.jsp">Dependentes</a>
							</div>
						</div>
					<%} else {%>
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
							<div class="sectedAba2">
								<label>Funcionários</label>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="fatura_empresa.jsp?state=1&id=<%=empresa.getCodigo() %>">Histórico de Faturas</a>
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
						<div id="referencia" class="textBox" style="width: 70px;">
							<label>CTR</label><br/>
							<input id="referenciaIn" name="referenciaIn" type="text" style="width: 70px;"/>												
						</div>
						<div id="nome" class="textBox" style="width: 254px;">
							<label>Nome</label><br/>
							<input id="nomeIn" name="nomeIn" type="text" style="width: 254px;"/>
						</div>
						<div id="cpf" class="textBox" style="width: 100px">
							<label>Cpf</label><br/>
							<input id="cpfIn" name="cpfIn" type="text" style="width: 100px" onkeydown="mask(this, cpf);"/>
						</div>
						<div id="nascimentoCalendar" class="textBox" style="width: 73px;">
							<label>Nascimento</label><br/>
							<input id="nascimentoIn" name="nascimentoIn" type="text" style="width: 73px;" onkeydown="mask(this, typeDate);"/>
						</div>
						<div id="codigo_uc" class="textBox" style="width: 97px">
							<label>Cod. Uc</label><br/>
							<input id="ucIn" name="ucIn" type="text" style="width: 97px" />
						</div>
						<div id="referencia" class="textBox" style="width: 70px;">
							<label>Código</label><br/>
							<input id="codUserIn" name="codUserIn" type="text" style="width: 70px;"/>												
						</div>
						<div id="plano" class="textBox" style="width: 200px">
							<label >Plano</label><br />
							<select id="planoIn" name="planoIn" style="width: 100%">
								<option value="">Selecione</option>
								<%for(Plano plano: planoList) {
									out.print("<option value=\"" + plano.getCodigo() + 
										"\">" + plano.getDescricao() + "</option>");
									
								}%>
							</select>
						</div>
						<div id="status" class="textBox" style="width: 92px">
							<label >Status</label><br />
							<select id="ativoChecked" name="ativoChecked" style="width: 100%">
								<option value="">Todos</option>
								<option value="a">Ativo</option>
								<option value="b">Bloqueado</option>
								<option value="c">Cancelado</option>
							</select>
						</div>
						<div id="unidadeIn" class="textBox" style="width: 250px;">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId" style="width: 100%">
								<option value="0">Selecione</option>
								<%if (unidadeList.size() == 1) {
									out.print("<option value=\"" + unidadeList.get(0).getCodigo() + 
											"\" selected=\"selected\">" + unidadeList.get(0).getReferencia() + 
											" - " + unidadeList.get(0).getDescricao() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										out.print("<option value=\"" + un.getCodigo() + 
												"\">" + un.getReferencia() +  " - " + un.getDescricao() + "</option>");
									}									
								}
								%>
							</select>
						</div>
					</div>
				</div>
				<div class="topButtonContent">
					<%if (isEmpresa) { %>					
						<div class="formGreenButton">
							<input  class="greenButtonStyle" onclick="imprime();" type="button" value="Imprimir"/>
						</div>
					<%} %>
					<div class="formGreenButton">
						<input id="teste" name="teste" class="greenButtonStyle" onclick="showAssistente();" type="button" value="Carteirinha"/>
					</div>
					<div class="formGreenButton">
						<input id="buscar" name="insertConta" class="greenButtonStyle" type="submit" value="Buscar"/>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%
						DataGrid dataGrid= new DataGrid(null);
						/*if (session.getAttribute("perfil").equals("a")) {
							query = sess.createQuery("from Usuario as u order by u.nome");		
						} else if (session.getAttribute("perfil").equals("f") || unidadeList.size() == 1) {
							query= sess.getNamedQuery("usuarioByUser");
							query.setString("username", (String) session.getAttribute("username"));
						} else {
							query = sess.createQuery("from Username as u where (1<>1)");							
						}*/
						int gridLines = 0;
						if (request.getParameter("id") == null) {
							if (session.getAttribute("perfil").toString().equals("a")
									|| session.getAttribute("perfil").toString().equals("d")) {								
								query = sess.createQuery("select count(u.codigo) from Usuario as u");
								gridLines = Integer.parseInt(query.uniqueResult().toString());
								query = sess.createQuery("from Usuario as u order by u.nome");
							} else {
								query = sess.createQuery("select count(u.codigo) from Usuario as u where u.unidade.codigo = :unidade");
								query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
								
								gridLines = Integer.parseInt(query.uniqueResult().toString());
								
								query = sess.createQuery("from Usuario as u where u.unidade.codigo = :unidade order by u.nome");
								query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
							}
						} else {
							if (session.getAttribute("perfil").toString().equals("a")
									|| session.getAttribute("perfil").toString().equals("d")) {
								
								query = sess.createQuery("select count(u.codigo) from  Usuario as u where u in " +
										"(select c.id.usuario from ContratoEmpresa as c " +
										"where c.id.empresa.codigo = :empresa)");
								query.setLong("empresa", Long.valueOf(request.getParameter("id")));
								
								gridLines = Integer.parseInt(query.uniqueResult().toString());
								
								query = sess.createQuery("from  Usuario as u where u in " +
										"(select c.id.usuario from ContratoEmpresa as c " +
										"where c.id.empresa.codigo = :empresa)");
								query.setLong("empresa", Long.valueOf(request.getParameter("id")));
								
							} else {
								query = sess.createQuery("select count(u.codigo) from  Usuario as u " +
										" where u.unidade.codigo = :unidade " + 
										" and u in (select c.id.usuario from ContratoEmpresa as c " +
										" where c.id.empresa.codigo = :empresa)");
								query.setLong("unidade", 
										Long.valueOf(session.getAttribute("unidade").toString()));
								query.setLong("empresa", Long.valueOf(request.getParameter("id")));
								
								gridLines = Integer.parseInt(query.uniqueResult().toString());
								
								query = sess.createQuery("from  Usuario as u " +
										" where u.unidade.codigo = :unidade " + 
										" and u in (select c.id.usuario from ContratoEmpresa as c " +
										" where c.id.empresa.codigo = :empresa)");
								query.setLong("unidade", 
										Long.valueOf(session.getAttribute("unidade").toString()));
								query.setLong("empresa", Long.valueOf(request.getParameter("id")));								
							}
						}
						query.setFirstResult(0);
						query.setMaxResults(30);
						List<Usuario> usuario= (List<Usuario>) query.list();
						dataGrid.addColumWithOrder("5", "CTR", false);
						dataGrid.addColumWithOrder("36", "Nome", true);
						dataGrid.addColum("20", "CPF");
						dataGrid.addColumWithOrder("5", "Cadastro", false);						
						dataGrid.addColum("20", "Fone");
						dataGrid.addColum("7" ,"Trat.");						
						//dataGrid.addColum("7" ,"Atraso");
						dataGrid.addColum("7", "Mens.");
						for (Usuario us: usuario) {
							query = sess.getNamedQuery("informacaoPrincipal");
							query.setEntity("pessoa", us);
							query.setFirstResult(0);
							query.setMaxResults(1);
							informacao= (Informacao) query.uniqueResult();
							dataGrid.setId(String.valueOf(us.getCodigo()));
							dataGrid.addData(Util.zeroToLeft(us.getContrato().getCtr(), 4));
							dataGrid.addData(Util.initCap(us.getNome()));
							dataGrid.addData(Util.mountCpf(us.getCpf()));
							dataGrid.addData(Util.parseDate(us.getCadastro()						
									, "dd/MM/yyyy"));							
							dataGrid.addData((informacao== null)? "" : informacao.getDescricao());
							
							query = sess.getNamedQuery("parcelaByUsuario");
							query.setLong("usuario", us.getCodigo());
							dataGrid.addImg((query.list().size() == 0)? "../image/ok_icon.png" :
								Util.getIcon(query.list(), "orcamento"));
							
							/*query = sess.getNamedQuery("countMensalAtrasoOf");
							query.setLong("codigo", us.getCodigo());
							dataGrid.addData(query.uniqueResult().toString());
							dataGrid.addData("00");*/
							query = sess.getNamedQuery("mensalidadeByUsuario");
							query.setLong("usuario", us.getCodigo());
							dataGrid.addImg(Util.getIcon(query.list(), "mensalidade"));
						
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