<% if (request.getSession().getAttribute("perfil").toString().trim().equals("a")) { %>
<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

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
<%@page import="com.marcsoftware.database.Plano"%>

<%@page import="com.marcsoftware.database.views.ViewClienteCompleto"%><html xmlns="http://www.w3.org/1999/xhtml">
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
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>	
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/comum/cobranca.js" ></script>
	
	
	<jsp:useBean id="informacao" class="com.marcsoftware.database.Informacao"></jsp:useBean>
	<jsp:useBean id="empresa" class="com.marcsoftware.database.Empresa"></jsp:useBean>
	<%!Query query; %>
	<%!Session sess; %>
	<%!boolean isEmDia= false; %>
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
	
	int baseDias = Integer.parseInt(request.getParameter("dias"));
	
	String dias = "";
	switch (baseDias) {
		case 30:
			dias = "Carteira 1";
			break;
			
		case 60:
			dias = "Carteira 2";
			break;
			
		case 90:
			dias = "Carteira 3";
			break;
			
		case 120:
			dias = "Carteira 4";
			break;
			
		case 150:
			dias = "Carteira 5";
			break;
		
		default:
			dias = "mais de 150";
			break;
	}%>

<title>Master Usuários</title>
</head>
<body onload="load()">
	<div id="relWindow" class="removeBorda" title="Impressão Cobrança" style="display: none;">
		<form id="formPagamento" onsubmit="return false;">
			<fieldset>
				<label for="modalidade">Selecione o Relatório</label><br/>
				<select id="modalidade" name="modalidade" style="width: 100%" >		
					<option value="m">Mensalidades</option>
					<option value="o">Tratamentos</option>
				</select>
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>
	<%if (request.getParameter("origem").equals("cli")) { %>
		<jsp:include page="../inc/menu.jsp">
			<jsp:param name="currentPage" value="clienteF"/>
		</jsp:include>
	<%} else {%>
		<jsp:include page="../inc/menu.jsp">
			<jsp:param name="currentPage" value="financeiro"/>
		</jsp:include>
	<%}%>
	<div id="centerAll">
		<%if (request.getParameter("origem").equals("cli")) { %>
			<jsp:include page="../inc/submenu.jsp">
				<jsp:param name="currentPage" value="clienteF"/>			
			</jsp:include>
		<%} else {%>
			<jsp:include page="../inc/submenu.jsp">
				<jsp:param name="currentPage" value="financeiro"/>			
			</jsp:include>
		<%}%>
		<div id="formStyle">
			<form id="unit" method="get" onsubmit="return search()">
				<input type="hidden" name="diasCarteira" id="diasCarteira" value="<%= request.getParameter("dias") %>"/>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="<%= dias %>"/>
					</jsp:include>
					<div id="abaMenu">
						<%if (session.getAttribute("perfil").equals("a")
								|| session.getAttribute("perfil").equals("f")) {%>
							<div class="aba2">
								<a href="painel_cobranca.jsp?origem=<%= request.getParameter("origem") %>">Painel</a>
							</div>								
							<div class="sectedAba2">
								<label>></label>	
							</div>
						<%}%>
						<%if (baseDias == 30) {%>
							<div class="sectedAba2">
								<label>Carteira 1</label>
							</div>
						<%} else {%>
							<div class="aba2">
								<a href="cobranca_c1.jsp?dias=30&origem=<%= request.getParameter("origem") %>">Carteira 1</a>
							</div>
						<%}%>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<%if (baseDias == 60) {%>
							<div class="sectedAba2">
								<label>Carteira 2</label>
							</div>
						<%} else {%>
							<div class="aba2">
								<a href="cobranca_c1.jsp?dias=60&origem=<%= request.getParameter("origem") %>">Carteira 2</a>
							</div>
						<%}%>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<%if (baseDias == 90) {%>
							<div class="sectedAba2">
								<label>Carteira 3</label>
							</div>
						<%} else {%>
							<div class="aba2">
								<a href="cobranca_c1.jsp?dias=90&origem=<%= request.getParameter("origem") %>">Carteira 3</a>
							</div>
						<%}%>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<%if (baseDias == 120) {%>
							<div class="sectedAba2">
								<label>Carteira 4</label>
							</div>
						<%} else {%>
							<div class="aba2">
								<a href="cobranca_c1.jsp?dias=120&origem=<%= request.getParameter("origem") %>">Carteira 4</a>
							</div>
						<%}%>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<%if (baseDias == 150) {%>
							<div class="sectedAba2">
								<label>Carteira 5</label>
							</div>
						<%} else {%>
							<div class="aba2">
								<a href="cobranca_c1.jsp?dias=150&origem=<%= request.getParameter("origem") %>">Carteira 5</a>
							</div>
						<%}%>
						<div class="sectedAba2">
							<label>></label>	
						</div>
						<%if (baseDias > 150) {%>
							<div class="sectedAba2">
								<label>6 meses ou mais</label>
							</div>
						<%} else {%>
							<div class="aba2">
								<a href="cobranca_c1.jsp?dias=180&origem=<%= request.getParameter("origem") %>">6 meses ou mais</a>
							</div>
						<%}%>
					</div>
					<div class="topContent">						
						<div id="referencia" class="textBox" style="width: 70px;">
							<label>CTR</label><br/>
							<input id="referenciaIn" name="referenciaIn" type="text" style="width: 70px;"/>												
						</div>
						<div id="nome" class="textBox" style="width: 225px;">
							<label>Nome</label><br/>
							<input id="nomeIn" name="nomeIn" type="text" style="width: 225px;"/>
						</div>
						<div id="cpf" class="textBox" style="width: 100px">
							<label>Cpf</label><br/>
							<input id="cpfIn" name="cpfIn" type="text" style="width: 100px" onkeydown="mask(this, cpf);"/>
						</div>
						<div id="nascimentoCalendar" class="textBox" style="width: 73px;">
							<label>Nascimento</label><br/>
							<input id="nascimentoIn" name="nascimentoIn" type="text" style="width: 73px;" onkeydown="mask(this, typeDate);"/>
						</div>
						<div id="tel" class="textBox" style="width: 80px">
							<label>Telefone</label><br/>					
							<input id="telIn" name="telIn" type="text" style="width: 80px" onkeydown="mask(this, fone)"/>
						</div>						
						<div id="plano" class="textBox">
							<label >Plano</label><br />
							<select id="planoIn" name="planoIn">
								<option value="">Selecione</option>
								<%for(Plano plano: planoList) {
									out.print("<option value=\"" + plano.getCodigo() + 
										"\">" + plano.getDescricao() + "</option>");
									
								}%>
							</select>
						</div>
						<div id="status" class="textBox" style="width: 90px">
							<label >Status</label><br />
							<select id="ativoChecked" name="ativoChecked">
								<option value="">Todos</option>
								<option value="a">Ativo</option>
								<option value="b">Bloqueado</option>
								<option value="c">Cancelado</option>
							</select>
						</div>
						<div id="unidadeIn" class="textBox">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId">
								<option value="">Selecione</option>
								<%if (unidadeList.size() == 1) {
									out.print("<option value=\"" + unidadeList.get(0).getCodigo() + 
											"\" selected=\"selected\">" + unidadeList.get(0).getReferencia() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										out.print("<option value=\"" + un.getCodigo() + 
												"\">" + un.getReferencia() + "</option>");
									}									
								}
								%>
							</select>
						</div>
					</div>
				</div>
				<div class="topButtonContent">
					<div id="btImp" class="formGreenButton">
						<input class="greenButtonStyle" type="button" value="Imprimir" onclick="pdfGenerate(<%= baseDias %>)" />
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
						if (session.getAttribute("perfil").toString().equals("a")
								|| session.getAttribute("perfil").toString().equals("d")) {
							if (unidadeList.size() == 1) {
								if (request.getParameter("dias").equals("180")) {
									query = sess.createQuery("from ViewClienteCompleto as v " + 
											" where v.diasMensalidade > :inicioMensal " + 
											" or v.diasTratamento > :inicioTratamento order by v.usuario.nome");
									query.setInteger("inicioMensal", 150);
									query.setInteger("inicioTratamento", 150);
								} else {
									query = sess.createQuery("from ViewClienteCompleto as v " + 
											" where (v.diasMensalidade between :inicioMensal and :fimMensal )" +
											" or (v.diasTratamento between :inicioTratamento and :fimTratamento ) " +
											" order by v.usuario.nome");
									query.setInteger("inicioMensal", baseDias - 30);
									query.setInteger("fimMensal", baseDias);
									query.setInteger("inicioTratamento", baseDias - 30);
									query.setInteger("fimTratamento", baseDias);
								}								
							} else {
								query = sess.createQuery("from ViewClienteCompleto as v " + 
								" where (1 <> 1)");
							}
						} else {
							if (request.getParameter("dias").equals("180")) {
								query = sess.createQuery("from ViewClienteCompleto as v " +
										" where (v.diasMensalidade > :inicioMensal " +
										" or v.diasTratamento > :inicioTratamento )" +
										" and v.usuario.unidade.codigo = :unidade " + 
										" order by v.usuario.nome");								
								query.setInteger("inicioMensal", 150);
								query.setInteger("inicioTratamento", 150);
							} else {
								query = sess.createQuery("from ViewClienteCompleto as v " +
										" where ((v.diasMensalidade between :inicioMensal and :fimMensal) " +
										" or (v.diasTratamento between :inicioTratamento and :fimTratamento)) " +
										" and v.usuario.unidade.codigo = :unidade " + 
										" order by v.usuario.nome");
								query.setInteger("inicioMensal", baseDias - 30);
								query.setInteger("fimMensal", baseDias);
								query.setInteger("inicioTratamento", baseDias - 30);
								query.setInteger("fimTratamento", baseDias);
							}
							query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
						}
						int gridLines= query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(30);
						List<ViewClienteCompleto> debitoMensalidade= (List<ViewClienteCompleto>) query.list();						
						dataGrid.addColumWithOrder("5", "CTR", false);
						dataGrid.addColumWithOrder("36", "Nome", true);
						dataGrid.addColum("20", "CPF");
						dataGrid.addColumWithOrder("5", "Nascimento", false);						
						dataGrid.addColum("20", "Fone");
						dataGrid.addColum("7" ,"Trat.");
						//dataGrid.addColum("7" ,"Atraso");
						dataGrid.addColum("7", "Mens.");
						for (ViewClienteCompleto db: debitoMensalidade) {
							query = sess.getNamedQuery("informacaoPrincipal");
							query.setEntity("pessoa", db.getUsuario());
							query.setFirstResult(0);
							query.setMaxResults(1);
							informacao= (Informacao) query.uniqueResult();
							dataGrid.setId(String.valueOf(db.getUsuario().getCodigo()));
							dataGrid.addData(Util.zeroToLeft(db.getUsuario().getContrato().getCtr(), 4));
							dataGrid.addData(Util.initCap(db.getUsuario().getNome()));
							dataGrid.addData(Util.mountCpf(db.getUsuario().getCpf()));
							dataGrid.addData(Util.parseDate(db.getUsuario().getNascimento(), "dd/MM/yyyy"));							
							dataGrid.addData((informacao== null)? "" : informacao.getDescricao());
							
							query = sess.getNamedQuery("parcelaByUsuario");
							query.setLong("usuario", db.getUsuario().getCodigo());
							dataGrid.addImg((query.list().size() == 0)? "../image/ok_icon.png" :
								Util.getIcon(query.list(), "orcamento"));							
							
							query = sess.getNamedQuery("mensalidadeByUsuario");
							query.setLong("usuario", db.getUsuario().getCodigo());
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
<%} else {%>
	out.print("Ops, voce não tem privilégios suficientes para acessar esta tela!");
<%} %>