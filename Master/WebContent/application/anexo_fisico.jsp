<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.database.Usuario"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.views.ViewClienteCompleto"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Dependente"%>
<%@page import="com.marcsoftware.utilities.ControleErro"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%ControleErro erro = (ControleErro) session.getAttribute("erro");
	erro.setLink("/application/anexo_fisico.jsp");
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Usuario usuario = (Usuario) sess.load(Usuario.class, Long.valueOf(request.getParameter("id")));
	Query query = sess.createSQLQuery("SELECT COUNT(*) FROM boleto WHERE cod_pessoa = :pessoa");
	query.setLong("pessoa", usuario.getCodigo());
	String boletos = query.uniqueResult().toString();
	query = sess.createQuery("from ViewClienteCompleto as v " + 
			"where v.unidade = :unidade and v.usuario = :usuario");
	query.setEntity("unidade", usuario.getUnidade());
	query.setEntity("usuario", usuario);
	ViewClienteCompleto complemento = (ViewClienteCompleto) query.uniqueResult();
	//ViewClienteCompleto complemento = (ViewClienteCompleto) sess.load(ViewClienteCompleto.class, usuario.getContrato().getCtr());
	query = sess.createQuery("from Dependente as d where d.usuario = :usuario order by d.referencia");
	query.setEntity("usuario", usuario);
	List<Dependente> dependenteList = (List<Dependente>) query.list();
	query = sess.createQuery("select c.id.empresa.fantasia from ContratoEmpresa as c " +
			"where c.id.usuario = :usuario");
	query.setEntity("usuario", usuario);
	String empresa = (query.uniqueResult() == null)? "" : query.uniqueResult().toString();
	query = sess.createQuery("select count(*) from Orcamento as o " + 
			"where o.pessoa.codigo in(select p.codigo from Profissional as p) " + 
			"and o.usuario = :usuario");
	query.setEntity("usuario", usuario);
	int orcProfissional = Integer.parseInt(query.uniqueResult().toString());
	query = sess.createQuery("select count(*) from Orcamento as o " + 
			"where o.pessoa.codigo in(select e.codigo from EmpresaSaude as e) " + 
			"and o.usuario = :usuario");
	query.setEntity("usuario", usuario);
	int orcEmpresa = Integer.parseInt(query.uniqueResult().toString());
	query = sess.createQuery("select i.descricao from Informacao as i where i.principal = 's' and i.pessoa = :usuario");
	query.setEntity("usuario", usuario);
	String informacaoPrincipal = "";
	if (query.list().size() == 1) {
		informacaoPrincipal = query.uniqueResult().toString();
	}
	query = sess.getNamedQuery("parcelaByUsuario");
	query.setLong("usuario", usuario.getCodigo());
	String statusTratamento = (query.list().size() == 0)? "../image/ok_icon.png" :
		Util.getIcon(query.list(), "orcamento");
	query = sess.getNamedQuery("mensalidadeByUsuario");
	query.setLong("usuario", usuario.getCodigo());
	String statusMensalidade = Util.getIcon(query.list(), "mensalidade");
	%>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<title>Master Anexo Cliente Fisico</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>	
	<script type="text/javascript" src="../js/lib/mask.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>
	<script type="text/javascript" src="../js/comum/anexo_fisico.js"></script>	
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/componentes/item_selector.js"></script>	
</head>
<body>
	<div id="obsWindow" class="removeBorda" title="Edição de observação" style="display: none;">
		<form id="formObs" onsubmit="return false;">
			<fieldset>
				<label for="obsw">Observações</label>
				<textarea name="obsw" id="obsw" rows="30" cols="60" class="textDialog ui-widget-content ui-corner-all"><%= (usuario.getObservacao() == null)? "" : usuario.getObservacao() %></textarea>
			</fieldset>
		</form>
	</div>
	<div id="viasWindow" class="removeBorda" title="Atualização de Vias" style="display: none;">
		<form id="formVia" onsubmit="return false;">
			<fieldset>
				<label for="viasW">Vias</label>
				<input type="text" name="viasW" id="viasW" class="textDialog ui-widget-content ui-corner-all" value="<%= usuario.getCarteirinha() %>" />
			</fieldset>
		</form>
	</div>
	<div id="consultaWindow" class="removeBorda" title="Atualizar Situação Cadastral"" style="display: none;">
		<form id="formNegativar" onsubmit="return false;">
			<fieldset>
				<label for="spcWd">Registros de SPC</label>				
				<input type="text" name="spcWd" id="spcWd" class="textDialog ui-widget-content ui-corner-all"/>
				<label for="devolucaoWd">Cheques Devolvidos</label>				
				<input type="text" name="devolucaoWd" id="devolucaoWd" class="textDialog ui-widget-content ui-corner-all"/>
				<label for="protestosWd">Protestos de Cartórios</label>				
				<input type="text" name="protestosWd" id="protestosWd" class="textDialog ui-widget-content ui-corner-all"/>
				<label for="consultaWd">Data da Última Consulta</label>				
				<input type="text" name="consultaWd" id="consultaWd" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, dateType)"/>
			</fieldset>
		</form>
	</div>
	<div id="carteirinhaWindow" class="removeBorda" title="Selecione a Impressão que Deseja Executar" style="display: none;">			
		<form id="formCarteirinha" onsubmit="return false;">
			<fieldset>
				<label for="userIds">Seleção de Nomes</label>
				<div class="itContent ui-corner-all" id="selectorNames" style="width: 700px; margin-bottom: 15px; ">
					<div style="width: 330px; height: 100px; float:left; margin-bottom: 0 !important">
						<label class="ui-corner-all titleBar">Itens</label>
						<ul id="sortableLeft" class="connectedSortable ui-corner-all leftList" style="width: 330px; height: 250px;">
							<li style="height: 20px" title="<%= usuario.getContrato().getCtr() + "-0" %>" ><%= Util.initCap(usuario.getNome())%></li>
							<%for(Dependente dep: dependenteList) {%>
								<li style="height: 20px" title="<%= usuario.getContrato().getCtr() + "-" + dep.getReferencia() %>" ><%= dep.getNome() %></li>
							<%}%>
						</ul>
					</div>
					<div class="btContent" ></div>
					<div style="width: 330px; height: 80px; float:left; margin-bottom: 0 !important">
						<label class="ui-corner-all titleBar">Selecinados</label>
						<ul id="sortableRight" class="connectedSortable ui-corner-all leftList" style="width: 330px; height: 250px;">							
							
						</ul>
					</div>
				</div>
				<div>
					<input type="checkbox" id="isTeste" name="isTeste" style="margin-top: 20px;" />
					<label for="isTeste">Impressão de Teste</label>
				</div>
			</fieldset>
		</form>
	</div>
	<%@ include file="../inc/header.jsp"%>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="clienteF"/>
	</jsp:include>
	<div id="centerAll" >
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="clienteF"/>
		</jsp:include>
		<div id="formStyle">		
			<form id="formPost" method="post" action="../CadastroClienteFisico" onsubmit= "return validForm(this)" >
				<input id="codUser" name="codUser" type="hidden" value="<%=usuario.getCodigo()%>" />
				<input id="unidadeId" name="unidadeId" type="hidden" value="<%=usuario.getUnidade().getCodigo()%>" />				
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Anexo"/>			
					</jsp:include>
					<div id="abaMenu">
							<div class="aba2">
								<a href="cadastro_cliente_fisico.jsp?state=1&id=<%= usuario.getCodigo()%>">Cadastro</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="sectedAba2">
								<label>Anexo</label>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>							
							<div class="aba2">
								<a href="mensalidade.jsp?id=<%= usuario.getCodigo()%>">Mensalidades</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="orcamento_empresa.jsp?id=<%= usuario.getCodigo()%>">Orçamentos de Empresas</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="orcamento.jsp?id=<%= usuario.getCodigo()%>">Orçamentos de Profissionais</a>
							</div>
						</div>
					<div class="topContent">
						<div class="textBox" id="undRef" name="undRef" style="width: 75px;">
							<label>Cod.</label><br/>
							<input id="undRefIn" name="undRefIn" type="text" style="width:75px" readonly="readonly" value="<%=usuario.getUnidade().getReferencia()%>"/>
						</div>
						<div id="descUnd" class="textBox" style="width: 380px;">
							<label>Unidade</label><br/>
							<input id="descUndIn"  name="descUndIn" type="text" style="width: 380px;" value="<%=usuario.getUnidade().getDescricao()%>" readonly="readonly" />
						</div>
						<div class="textBox" id="cadastro" name="cadastro" style="width: 75px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn"  name="cadastroIn" type="text" style="width:75px" readonly="readonly" value="<%=Util.parseDate(usuario.getCadastro(), "dd/MM/yyyy") %>"/>	
						</div>
						<div class="textBox" id="renovacao" name="renovacao" style="width: 75px;">
							<label>Renovação</label><br/>
							<input id="renovacaoIn"  name="renovacaoIn" type="text" style="width:75px" readonly="readonly" value="<%=Util.parseDate(usuario.getRenovacao(), "dd/MM/yyyy") %>"/>	
						</div>
						<div id="plano" class="textBox" style="width: 318px;">
							<label>Plano Contratado</label><br/>
							<input id="planoIn"  name="planoIn" type="text" style="width: 318px;" value="<%=usuario.getPlano().getDescricao()%>" readonly="readonly" />
						</div>
						<div id="empresa" class="textBox" style="width: 318px;">
							<label>Empresa</label><br/>
							<input id="empresaIn"  name="empresaIn" type="text" style="width: 318px;" value="<%= empresa %>" readonly="readonly" />
						</div>
						<div class="textBox" id="totalEmp" name="totalEmp" style="width: 100px;">
							<label>Total Orc Emp.</label><br/>
							<input id="totalEmpIn" name="totalEmpIn" type="text" style="width:100px" readonly="readonly" value="<%= orcEmpresa %>"/>
						</div>
						<div class="textBox" id="totalProf" name="totalProf" style="width: 100px;">
							<label>Total Orc Emp.</label><br/>
							<input id="totalProfIn" name="totalProfIn" type="text" style="width:100px" readonly="readonly" value="<%= orcProfissional %>"/>
						</div>
						<div class="textBox" id="boleto" name="boleto" style="width: auto;">
							<label>Total de Boletos</label><br/>
							<input id="boletoIn" name="boletoIn" type="text" style="width:110px" readonly="readonly" value="<%= boletos %>"/>
							<a style="color: #FFFFFF" href="boleto.jsp?origem=f&id=<%= usuario.getCodigo() %>" ><img src="../image/lupa.png"></img></a>
						</div>
						<div class="textBox" id="boleto" name="boleto" style="width: auto;">
							<label>Status</label><br/>							
							<strong>Tratamento:</strong><img src="<%= statusTratamento %>" style="margin-right: 15px;" height="18px" width="20px"></img><strong>Mensalidade:</strong><img height="18px" width="20px" src="<%= statusMensalidade %>" alt="" />
						</div>
						<div class="textBox" id="obs" name="obs" style="height: 140px;">
							<label>Observações</label><br/>
							<textarea cols="112" readonly="readonly" rows="5" id="obsIn" name="obsIn"><%=(usuario.getObservacao() == null)? "" : usuario.getObservacao() %></textarea>
						</div>
					</div>
				</div>
				<div class="buttonContent" style="margin-top: 15px; margin-bottom:  15px;">
					<div class="formGreenButton">
						<input class="greenButtonStyle" type="button" value="Editar Obs" onclick="editObs()" />
					</div>
				</div>
				<div id="mainContent">
					<div id="dadosPessoais" class="bigBox" >
						<div class="indexTitle">
							<h4><%= Util.initCap(usuario.getNome()) + ": " + usuario.getContrato().getCtr() + "-0" %></h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div class="textBox" id="cpf" name="cpf" style="width: 100px;">
							<label>Cpf</label><br/>
							<input id="cpfIn" name="cpfIn" type="text" style="width:100px" readonly="readonly" value="<%=Util.mountCpf(usuario.getCpf()) %>"/>
						</div>
						<div class="textBox" id="nascimento" name="nascimento" style="width: 75px;">
							<label>Nascimento</label><br/>
							<input id="nascimentoIn" name="nascimentoIn" type="text" style="width:75px" readonly="readonly" value="<%=Util.parseDate(usuario.getNascimento(), "dd/MM/yyyy") %>"/>
						</div>
						<div class="textBox" id="telefone" name="telefone" style="width: 200px;">
							<label>Contato</label><br/>
							<input id="telefoneIn" name="telefoneIn" type="text" style="width:237px" readonly="readonly" value="<%= informacaoPrincipal%>"/>
					 	</div>
						<div class="textBox" id="via" name="sexo" style="width: auto;">
							<label>Vias Carteirinha</label><br/>
							<input id="viaIn" name="viaIn" type="text" style="width:110px" readonly="readonly" value="<%= usuario.getCarteirinha() %>"/>
							<a style="color: #FFFFFF; margin-right: 2px" href="#" onclick="editVias('-1')" ><img src="../image/edit.gif"></img></a>
					 	</div>
						<div class="textBox" id="tontera" name="sexo" style="width: auto;">
							<label>Chamados</label><br/>
							<input id="tonteraIn" name="tonteraIn" type="text" style="width:110px" readonly="readonly" value="0"/>
							<a style="color: #FFFFFF" href="#" ><img src="../image/lupa.png"></img></a>
					 	</div>					 	
					 	<div class="textBox" style="width: 125px;">						 	
						</div>
						<div class="textBox" style="width: 100%; height: 21px">
							<strong>Situação Cadastral</strong>
						</div>	
						<div class="textBox" style="width: auto;">
							<label>Registros de SPC</label><br />
							<input id="spcIn" name="spcIn" type="text" style="width:154px; margin-right: 15px;" readonly="readonly" value="<%= (usuario.getSpc() == null)? 0 : usuario.getSpc() %>"/>
						</div>
						<div class="textBox" style="width: auto;">
							<label>Cheques Devolvidos</label><br />							
							<input id="chequeIn" name="chequeIn" type="text" style="width:154px; margin-right: 15px" readonly="readonly" value="<%= (usuario.getDevolucaoCheques() == null)? 0 : usuario.getDevolucaoCheques() %>"/>
						</div>
						<div class="textBox" style="width: auto;">
							<label>Protestos de Cartórios</label><br />
							<input id="protrestoIn" name="protrestoIn" type="text" style="width:154px; margin-right: 15px" readonly="readonly" value="<%= (usuario.getProtestos() == null)? 0 : usuario.getProtestos() %>"/>
						</div>
						<div class="textBox" style="width: auto;">
							<label>Data da Última Consulta</label><br />
							<input id="consultaIn" name="consultaIn" type="text" style="width:154px; margin-right: 15px" readonly="readonly" value="<%= (usuario.getConsultaCredito() == null)? "" : Util.parseDate(usuario.getConsultaCredito(), "dd/MM/yyyy")%>"/>
						</div>
					 	<div class="buttonContent">
							<div class="formGreenButton"  >
								<input class="greenButtonStyle" type="button" value="Editar" onclick="editCredito(-1);" />
							</div>
						</div>
					</div>
					<%for(Dependente dependente: dependenteList) {%>
						<div class="bigBox" >
							<div class="indexTitle">
								<h4><%= Util.initCap(dependente.getNome()) + ": " + usuario.getContrato().getCtr() + "-" + dependente.getReferencia() %></h4>
								<div class="alignLine">
									<hr>
								</div>
							</div>
							<div class="textBox" style="width: 100px;">
								<label>Cpf</label><br/>
								<input type="text" style="width:100px" readonly="readonly" value="<%=(dependente.getCpf() == null || dependente.getCpf().equals(""))? "" : Util.mountCpf(usuario.getCpf()) %>"/>
							</div>
							<div class="textBox" style="width: 75px;">
								<label>Nascimento</label><br/>
								<input type="text" style="width:75px" readonly="readonly" value="<%=(dependente.getNascimento() == null || dependente.getNascimento().equals(""))? "" : Util.parseDate(usuario.getNascimento(), "dd/MM/yyyy") %>"/>
							</div>
							<div class="textBox" style="width: 237px;">
								<label>Contato</label><br/>
								<input type="text" style="width:237px" readonly="readonly" value="<%= (dependente.getFone() == null)? "" : dependente.getFone()%>"/>
						 	</div>
							<div class="textBox" style="width: auto;">
								<label>Vias Carteirinha</label><br/>
								<input id="carteira_<%= dependente.getCodigo() %>" type="text" style="width:110px" readonly="readonly" value="<%= dependente.getCarteirinha() %>"/>
								<a style="color: #FFFFFF; margin-right: 2px" href="#" onclick="editVias('<%= dependente.getCodigo() %>')" ><img src="../image/edit.gif"></img></a>
						 	</div>
							<div class="textBox" style="width: auto;">
								<label>Chamados</label><br/>
								<input type="text" style="width:110px" readonly="readonly" value="0"/>
								<a style="color: #FFFFFF" href="#" ><img src="../image/lupa.png"></img></a>
						 	</div>
						 	<div class="textBox" style="width: 125px;">						 	
						 	</div>
						 	<div class="textBox" style="width: 100%; height: 21px !important">
						 		<strong>Situação Cadastral</strong><br />
						 		
						 	</div>
						 	<div class="textBox" style="width: auto;">
						 		<label>Registros de SPC</label><br/>
						 		<input type="text" id="spc_<%= dependente.getCodigo() %>"  name="spc_<%= dependente.getCodigo() %>" style="width:154px; margin-right: 15px;" readonly="readonly" value="<%= (dependente.getSpc() == null)? 0 : dependente.getSpc() %>"/>
						 	</div>
						 	<div class="textBox" style="width: auto;">
						 		<label>Cheques Devolvidos</label><br/>
						 		<input type="text" id="devolucao_<%= dependente.getCodigo() %>" name="devolucao_<%= dependente.getCodigo() %>" style="width:154px; margin-right: 15px" readonly="readonly" value="<%= (dependente.getDevolucaoCheques() == null)? 0 : dependente.getDevolucaoCheques() %>"/>
						 	</div>
						 	<div class="textBox" style="width: auto;">
						 		<label>Protestos de Cartórios</label><br/>
						 		<input type="text" id="Protesto_<%= dependente.getCodigo() %>" name="Protesto_<%= dependente.getCodigo() %>" style="width:154px; margin-right: 15px" readonly="readonly" value="<%= (dependente.getProtestos() == null)? 0 : dependente.getProtestos() %>"/>
						 	</div>
						 	<div class="textBox" style="width: auto;">
						 		<label>Data da Última Consulta</label><br/>
						 		<input type="text" id="dataConsulta_<%= dependente.getCodigo() %>" name="dataConsulta_<%= dependente.getCodigo() %>" style="width:154px; margin-right: 15px" readonly="readonly" value="<%= (dependente.getConsultaCredito() == null)? "" : Util.parseDate(dependente.getConsultaCredito(), "dd/MM/yyyy") %>"/>
						 	</div>
							<div class="buttonContent">
								<div class="formGreenButton"  >
									<input class="greenButtonStyle" type="button" value="Editar" onclick="editCredito(<%= dependente.getCodigo() %>);" />
								</div>
							</div>
						</div>
					<%}%>					
					<div class="buttonContent" style="margin-top: 40px">
						<div class="formGreenButton"  >
							<input class="greenButtonStyle" type="button" value="Consulta SPC" onclick="MM_openBrWindow();" />
						</div>
						<div class="formGreenButton"  >
							<input class="greenButtonStyle" type="button" value="Carteirinhas" onclick="showReport();" />
						</div>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>