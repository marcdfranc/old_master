<?xml version="1.0" encoding="ISO-8859-1"?>
<%@page import="com.marcsoftware.database.Concessionaria"%>
<%@page import="com.marcsoftware.database.Logradouro"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.database.Funcionario"%>
<%@page import="com.marcsoftware.database.Dependente"%>
<%@page import="com.marcsoftware.database.Empresa"%>
<%@page import="com.marcsoftware.database.Endereco"%>
<%@page import="com.marcsoftware.database.Filter"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Transaction"%>
<%@page import="org.hibernate.Session"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Usuario"%>
<%@page import="com.marcsoftware.database.Informacao"%>

<%@page import="com.marcsoftware.database.FormaPagamento"%>

<%@page import="com.marcsoftware.database.Plano"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.marcsoftware.database.Relatorio"%>
<%@page import="com.marcsoftware.database.Parametro"%><html xmlns="http://www.w3.org/1999/xhtml">
	
	<%boolean isEdition= false;
	boolean permissao = false;
	isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}%>
	
	<jsp:useBean id="unidade" class="com.marcsoftware.database.Unidade"></jsp:useBean>
	<jsp:useBean id="funcionarioOf" class="com.marcsoftware.database.Funcionario"></jsp:useBean>
	<jsp:useBean id="usuario" class="com.marcsoftware.database.Usuario"></jsp:useBean>		
	<jsp:useBean id="empresaOf" class="com.marcsoftware.database.Empresa"></jsp:useBean>	
	<jsp:useBean id="endereco" class="com.marcsoftware.database.Endereco"></jsp:useBean>	
	
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	permissao = (request.getSession().getAttribute("perfil").toString().trim().equals("f")) ||
		(request.getSession().getAttribute("perfil").toString().trim().equals("a")) ||
		(request.getSession().getAttribute("perfil").toString().trim().equals("d"));
	Query query;
	boolean haveMensalidade =  false;
	ArrayList<Funcionario> funcionario = new ArrayList<Funcionario>();
	ArrayList<Empresa> empresa = new ArrayList<Empresa>();
	List<Funcionario> funcionarioAux;
	List<Empresa> empresaAux;
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
	for(Unidade unid: unidadeList) {
		query= sess.createQuery("from Funcionario as f where f.unidade = :unidade");
		query.setEntity("unidade", unid);
		funcionarioAux = (List<Funcionario>) query.list();
		for(Funcionario func: funcionarioAux) {
			funcionario.add(func);
		}
		query= sess.createQuery("from Empresa as e where e.unidade = :unidade");
		query.setEntity("unidade", unid);
		empresaAux = (List<Empresa>) query.list();
		for(Empresa emp: empresaAux) {
			empresa.add(emp);
		}
	}	
	query = sess.createQuery("from FormaPagamento as f order by f.codigo");	
	List<FormaPagamento> pagamento= (List<FormaPagamento>) query.list();
	query = sess.createQuery("select distinct c.uf from Cep2005 as c");
	List<String> uf2005 = (List<String>) query.list();
	
	query = sess.createQuery("from Logradouro as l order by descricao");
	List<Logradouro> logradouros = (List<Logradouro>) query.list();
	
	query = sess.createQuery("from Concessionaria as c order by descricao");
	List<Concessionaria> concessionariaList = (List<Concessionaria>) query.list();
	
	String sql = "from Plano as p where p.unidade.codigo in(";
	for (int i = 0; i < unidadeList.size(); i++) {
		if (i == 0) {
			sql += unidadeList.get(i).getCodigo();
		} else {
			sql += ", " + unidadeList.get(i).getCodigo();
		}
	}
	query = sess.createQuery(sql + ") order by codigo");
	List<Plano> planoList = (List<Plano>) query.list();
	String relId = null;	
	List<Parametro> parametros = null;
	if (isEdition) {
		if (request.getParameter("id") == null) {
			query= sess.createQuery("select distinct(d.usuario) from  Dependente as d where d.codigo = :dependente");			
			query.setLong("dependente", Long.valueOf(request.getParameter("dep")));
		} else {
			query= sess.createQuery("from Usuario as u where u.codigo = :codigo");			
			query.setLong("codigo", Long.valueOf(request.getParameter("id")));
		}
		usuario= (Usuario) query.uniqueResult();		
		query= sess.getNamedQuery("enderecoOf").setEntity("pessoa", usuario);
		endereco= (Endereco) query.uniqueResult();
		query= sess.getNamedQuery("empresaContrato");
		query.setEntity("usuario", usuario);
		empresaOf= (Empresa) query.uniqueResult();
		query = sess.createQuery("from Mensalidade as m where m.usuario = :usuario and m.lancamento.status = 'a'");
		query.setEntity("usuario", usuario);
		haveMensalidade = (query.list().size() > 0);
		query = sess.createQuery("from Relatorio as r where r.nome = :relName");
		query.setString("relName", usuario.getUnidade().getCodigo() + "cad");		
		Relatorio relatorio = (Relatorio) query.uniqueResult();
		if (relatorio != null) {
			relId = String.valueOf(relatorio.getCodigo());
			query = sess.createQuery("from Parametro as p where p.relatorio = :rel");
			query.setEntity("rel", relatorio);
			parametros = (List<Parametro>) query.list();		
		}
	}%>
	
	
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<link rel="shortcut icon" href="../icone.ico">	
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link type="text/css" href="../js/jquery/uploaddif/uploadify.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->	
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/uploaddif/swfobject.js"></script>
	<script type="text/javascript" src="../js/jquery/uploaddif/jquery.uploadify.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/validation.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/comum/cadastro_cliente_fisico.js" ></script>
	<script type="text/javascript" src="../js/lib/pilot_grid.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>	
	<title>Master Cadastro de Clientes Físicos</title>
</head>
<body onload="loadPage(<%= isEdition %>)">
	<div id="uploadCtr" class="removeBorda" title="Upload da Imagem do Contrato" style="display: none">
		<form id="formUpload" onsubmit="return false;" action="../ContratoUpload" method="get" enctype="multipart/form-data">
			<div class="uploadContent" id="contUpload">
				<div id="msgUpload" style="margin-bottom: 20px;">Clique abaixo para selecionar o arquivo pdf a ser enviado.</div>
				<div id="fileQueue" style="width: 200px;"></div>
				<input type="file" name="uploadify" id="uploadify" />
				<!-- <p><a href="javascript:jQuery('#uploadify').uploadifyClearQueue()">Cancelar Todos os Anexos</a></p> -->
			</div>
			<input type="hidden" value="" id="uploadName" name="uploadName" />
			<input type="hidden" value="0" id="from" name="from" />
		</form>
	</div>
	<div id="impContrato" class="removeBorda" title="Parametros de Contrato" style="display: none;">			
		<form id="formImpresso" onsubmit="return false;">
			<fieldset>
				<label for="dataDoc">Digite a data do documento</label>
				<input type="text" name="dataDoc" id="dataDoc" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, dateType);"/>
				<label for="vencAdesao">Venc. Adesão/Renovação</label>				
				<input type="text" name="vencAdesao" id="vencAdesao" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, dateType);"/>
				<label for="vlrAdesao">Valor</label>
				<input type="text" name="vlrAdesao" id="vlrAdesao" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, decimalNumber);"/>
				<label for="vencMensalidade">Venc. Mensalidade</label>
				<input type="text" name="vencMensalidade" id="vencMensalidade" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, onlyInteger);"/>
				<label for="vlrMensalidade">Valor</label>
				<input type="text" name="vlrMensalidade" id="vlrMensalidade" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, decimalNumber);"/>
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
			<form id="formPost" method="post" action="../CadastroClienteFisico" onsubmit= "return getCampos(this, true)">
				<input type="hidden" id="haveMensalidade" name="haveMensalidade" value="<%= haveMensalidade %>"/>
				<div>
					<input type="hidden" name="relId" id="relId" value="<%= (isEdition && relId != null)? relId : "" %>" />
					<%if (isEdition && parametros != null) {
						for(Parametro parametro: parametros) {%>
							<input type="hidden" id="<%= parametro.getDescricao() %>" name="<%= parametro.getDescricao() %>" value="<%= parametro.getCodigo() %>" />
						<%}
					}
					%>				
				</div>
				<div id="localEdDependente"><%
					if (isEdition) {
						query= sess.getNamedQuery("dependenteOf").setEntity("usuario", usuario);
						List<Dependente> dependenteList = (List<Dependente>) query.list();						
						for(int i=0; i < dependenteList.size(); i++){
							out.print("<input id=\"edRef" + String.valueOf(i) + "\" name=\"edRef" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +
									dependenteList.get(i).getReferencia() + "\" />");
							
							out.print("<input id=\"edNome" + String.valueOf(i) + "\" name=\"edNome" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +
									Util.initCap(dependenteList.get(i).getNome()) + "\" />");
							
							out.print("<input id=\"edParentesco" + String.valueOf(i) + 
									"\" name=\"edParentesco" + String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + 
									Util.initCap(dependenteList.get(i).getParentesco()) + 
									"\" />");
							
							out.print("<input id=\"edCpf" + String.valueOf(i) + 
									"\" name=\"edCpf" +	String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" +
									((dependenteList.get(i).getCpf() == null || dependenteList.get(i).getCpf().isEmpty())? "" :
									Util.mountCpf(dependenteList.get(i).getCpf()))  + 
									"\" />");

							out.print("<input id=\"edNasciemnto" + String.valueOf(i) + 
									"\" name=\"edNasciemnto" +	String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + ((dependenteList.get(i).getNascimento() == null)? "" : 
										Util.parseDate(dependenteList.get(i).getNascimento(), "dd/MM/yyyy")) + "\" />");
							
							out.print("<input id=\"edFone" + String.valueOf(i) + 
									"\" name=\"edFone" + String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + 
									((dependenteList.get(i).getFone()== null)? "   ":
									dependenteList.get(i).getFone()) + "\" />");
							
							out.print("<input id=\"dependenteId" + String.valueOf(i) + 
									"\" name=\"dependenteId" + String.valueOf(i) + 
									"\" type=\"hidden\" value=\"" + 
									dependenteList.get(i).getCodigo() + "\" />");
						}
					}%>
				</div>
				<div id="localEdContact" ><%
					if (isEdition) {
						query= sess.getNamedQuery("informacaoOf").setEntity("pessoa", usuario);
						List<Informacao> info= (List<Informacao>) query.list();
						for(int i=0; i < info.size() ; i++){
							out.print("<input id=\"edType" + String.valueOf(i) + "\" name=\"edBank" +
									String.valueOf(i) + "\" type=\"hidden\" value=\"" + 
									info.get(i).getTipo() + "\" />");
							
							out.print("<input id=\"edDescription" + String.valueOf(i) +
									"\" name=\"edDescription" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +
									Util.initCap(info.get(i).getDescricao())+ "\" />");
							
							out.print("<input id=\"edPrincipal" + String.valueOf(i) +
									"\" name=\"edPrincipal" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +									
									((info.get(i).getPrincipal().trim().equals("s"))? "Sim" : "Não") + "\" />");
							
							out.print("<input id=\"contactId" + String.valueOf(i) +
									"\" name=\"contactId" +
									String.valueOf(i) + "\"	type=\"hidden\" value=\"" +
									info.get(i).getCodigo()+ "\" />");
						}
					}%>
				</div>				
				<div id="localContact"></div>
				<div id="localDependente"></div>
				<div id="deletedsDependente"></div>
				<div id="deletedsContact"></div>
				<div id="editedsDependente"></div>
				<div id="editedsContact"></div>
				<div>
					<input id="edUser" name="udUser" type="hidden" value="n"/>
					<input id="edAddress" name="edAddress" type="hidden" value="n"/>
					<input id="edDependente" name="edDependente" type="hidden" value="n"/>
					<input id="edInfo" name="edInfo" type="hidden" value="n"/>
					<input id="codUser" name="codUser" type="hidden" value="<%=(isEdition)? usuario.getCodigo(): "" %>" />
					<input id="codAddress" name="codAddress" type="hidden" value="<%=(isEdition)? endereco.getCodigo(): "" %>" />
					<input id="carteirinhaIn" name="carteirinhaIn" type="hidden"  value="<%=(isEdition)? usuario.getCarteirinha() : "0" %>" class="required" onblur="genericValid(this);" />
					<input id="haveDoc" name="haveDoc" type="hidden" value="<%=(isEdition)? usuario.getDocDigital() : "" %>"/>
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Cliente"/>			
					</jsp:include>
					<%if (isEdition) {%>
						<div id="abaMenu">							
							<div class="sectedAba2">
								<label>Cadastro</label>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>							
							<div class="aba2">
								<a href="anexo_fisico.jsp?id=<%= usuario.getCodigo()%>">Anexo</a>
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
					<%} else {%>
						<div id="abaMenu">
							<div class="aba2">
								<a href="cliente_fisico.jsp">Cliente Físico</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="sectedAba2">
								<label>Novo Cadastro</label>
							</div>								
						</div>
					<%}%>
					<div class="topContent">						
						<div class="textBox" style="width: 90px;">
							<label>Código Unid.</label><br/>
							<select id="unidadeId" name="unidadeId" style="width: 90px;">
 								<% if (isEdition) { %>							
									<option value="<%=Util.initCap(usuario.getUnidade().getDescricao()) + "@" + 
									usuario.getUnidade().getCodigo() %>" ><%=usuario.getUnidade().getReferencia() %></option><%
								} else {%>
									<option value="">Selecione</option><%
								}
								for(Unidade un: unidadeList) {
									if (isEdition) {
										if (!usuario.getUnidade().equals(un)) {
											out.print("<option value=\"" + Util.initCap(un.getDescricao()) + "@" +
													un.getCodigo() + "\">" + un.getReferencia() + "</option>");
										}
									} else {
										out.print("<option value=\"" + Util.initCap(un.getDescricao()) + "@" +
												un.getCodigo() + "\">" + un.getReferencia() + "</option>");
									}
								}
								%>
							</select>
						</div>
						<div id="unidade" class="textBox" style="width: 300px;" >
							<label>Unidade</label><br/>
							<input id="unidadeIn" name="unidadeIn" type="text" style="width: 300px;" value="<%=(isEdition)? Util.initCap(usuario.getUnidade().getDescricao()): "" %>" class="required" enable="false" onblur="genericValid(this);" readonly="readonly" />
						</div>
						<div id="plano" class="textBox" style="width: 230px">
							<label >Plano</label><br />
							<select id="planoIn" name="planoIn" style="width: 210px" class="required" onblur="genericValid(this);" >
								<%if (!isEdition) {%>
									<option value="">Selecione</option>
									<%for(Plano plano: planoList) {
										out.print("<option value=\"" + plano.getCodigo() + 
												"\">" + plano.getDescricao() + "</option>");
									}
								} else {
									out.print("<option value=\"" + 
											usuario.getPlano().getCodigo() + 
											"\">" + usuario.getPlano().getDescricao() +
											"</option>");
								}%>
							</select>
						</div>
						<div id="idVend" class="textBox" style="width: 85px;" >
							<label>Código Vend.</label><br/>
							<input id="idVendedor" name="idVendedor" type="text" style="width: 85px;" value="<%=(isEdition)? usuario.getContrato().getFuncionario().getCodigo(): "" %>" class="required" <%if (!isEdition)  out.print("onblur=\"getCampos(this)\"");%> onkeydown="mask(this, onlyInteger);"/>
						</div>
						<div id="vendedor" class="textBox" style="width: 240px;">
							<label>Vendedor</label><br/>
							<input id="vendedorIn" name="vendedorIn" type="text" style="width: 240px;" value="<%=(isEdition)? Util.initCap(usuario.getContrato().getFuncionario().getNome()): "" %>" class="required" readonly="readonly" onblur="genericValid(this);" />
						</div>
						<div class="textBox" style="width: 50px">
							<label>PLR</label><br/>
							<select>
								<option value="s" >Sim</option>
								<option value="n" selected="selected" >não</option>
							</select>
						</div>
						<div id="empresa" class="textBox" style="width: 210px">
							<label>Empresa</label><br/>
							<select id="idEmpresa" name="idEmpresa" style="width: 210px">
								<option value="">Plano Particular</option>
								<%for(Empresa emp: empresa) {
									if (isEdition) {
										if (emp.equals(empresaOf)) {
											out.print("<option value=\"" + emp.getCodigo() + "@" +
													emp.getVencimento() +  "\" selected=\"selected\" >" + 
													Util.initCap(emp.getFantasia()) + "</option>");
										}
										out.print("<option value=\"" + emp.getCodigo() + 
												"@" + emp.getVencimento() + "\">" + 
												Util.initCap(emp.getFantasia()) + "</option>");
									} else {
										out.print("<option value=\"" + emp.getCodigo() +
												"@" + emp.getVencimento() + "\">" + 
													Util.initCap(emp.getFantasia()) + "</option>");										
									}
								}%>
							</select>
						</div>
						<div id="cadastro" class="textBox" style="width: 73px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" type="text" class="required" <%if(isEdition
									&& (!request.getSession().getAttribute("perfil").equals("a"))
									&& (!request.getSession().getAttribute("perfil").equals("d"))) {%> "readonly="readonly" <%}%> style="width: 73px;" value="<%=(isEdition)? Util.parseDate(usuario.getCadastro(), "dd/MM/yyyy") : "" %>" <%if(!isEdition) {%> onkeydown="mask(this, dateType);" <%}%>/>
						</div>
						<div id="status" class="textBox" style="width: 280px">
							<label >Status do Cadastro</label><br />
							<div class="checkRadio">
								<label class="labelCheck" >Ativo</label><%
								if (isEdition) {%>
									<input id="ativoChecked" name="ativoChecked" type="radio"  <%if (usuario.getAtivo().equals("a")){ out.print(" checked=\"checked\""); }%> value="a" />									
								<label class="labelCheck" >Bloqueado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" <%if (usuario.getAtivo().equals("b")) { out.print("checked=\"checked\""); }%> value="b" />
								<label class="labelCheck" >Cancelado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" <%if (usuario.getAtivo().equals("c")) { out.print("checked=\"checked\""); }%> value="c" />
								<%} else {%>
									<input id="ativoChecked" name="ativoChecked" type="radio"  checked="checked" value="a" />
									<label class="labelCheck" >Bloqueado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" value="b" />
									<label class="labelCheck" >Cancelado</label>
									<input id="ativoChecked" name="ativoChecked" type="radio" value="c" />
								<%}%>
							</div>
						</div>
						<div id="cadastrador" class="textBox" style="width: 245px;">
							<label>Cadastramento</label><br/>
							<input id="cadastradorIn" name="cadastradorIn" type="text" style="width: 245px;" value="<%=((isEdition) && (usuario.getCadastrador() != null))? usuario.getCadastrador().getUsername() : "" %>" readonly="readonly" />
						</div>
					</div>
				</div>
				<%if (isEdition) {%>
					<div class="topButtonContent">						
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Imprimir" onclick="emitContrato()" />
						</div>
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Doc. Digital" onclick="loadDocDigital()" />
						</div>
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Upload" onclick="showUploadWd()" />
						</div>
					</div>
				<%}%>
				<div id="mainContent">
					<div id="dadosPessoais" class="bigBox" >
						<div class="indexTitle">
							<h4>Dados Pessoais</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div id="codigo" class="textBox" style="width: 80px;">
							<label>CTR</label><br/>
							<input id="codigoIn" name="codigoIn" type="text" <%if (isEdition && (!permissao)) out.print("readonly=\"readonly\"");%>  style="width: 80px;"value="<%=(isEdition)? usuario.getContrato().getCtr(): "" %>" class="required" onblur="genericValid(this);" />
						</div>
						<div id="nome" class="textBox" style="width: 285px;">
							<label>Nome</label><br/>
							<input id="nomeIn" name="nomeIn" type="text" style="width: 285px;" value="<%=(isEdition)? Util.initCap(usuario.getNome()): "" %>" class="required" enable="false" onblur="genericValid(this);" />
						</div>
						<div class="textBox" class="textBox" style="width: 200px;">
							<label>Sexo</label><br />
							<div class="checkRadio" >
								<label>Masculino</label><%
								if (isEdition) {%>
									<input id="sexo" name="sexo" type="radio" <%if (usuario.getSexo().equals("m")) { out.print("checked=\"checked\""); }%> value="m" />
									<label>Feminino</label>
									<input id="sexo" name="sexo" type="radio" <%if (usuario.getSexo().equals("f")) { out.print("checked=\"checked\""); }%> value="f"/>
								<%} else {%>
									<input id="sexo" name="sexo" type="radio" checked="checked" value="m" />
									<label>Feminino</label>
									<input id="sexo" name="sexo" type="radio" value="f"/>
								<%}%>		
							</div>
						</div>
						<div id="cpf" class="textBox" style="width: 100px">
							<label>Cpf</label><br/>
							<input id="cpfIn" name="cpfIn" type="text" style="width: 100px" value="<%=(isEdition)? Util.mountCpf(usuario.getCpf()): "" %>" class="required" onkeydown="mask(this, cpf);" onblur="cpfValidation(this)" />
						</div>
						<div id="rg" class="textBox" style="width: 89px">
							<label>Rg</label><br/>
							<input id="rgIn" name="rgIn" type="text" style="width: 89px" value="<%=(isEdition)? usuario.getRg(): "" %>" />
						</div>
						<div id="nascimento" class="textBox" style="width: 73px;">
							<label>Nascimento</label><br/>
							<input id="nascimentoIn" name="nascimentoIn" type="text" class="required" style="width: 73px;" value="<%=(isEdition)? Util.parseDate(usuario.getNascimento(), "dd/MM/yyyy") : "" %>" onkeydown="mask(this, typeDate);" onblur="genericValid(this)"/>
						</div>
						<div id="estadoCivil" class="textBox" style="width: 85px">
							<label>Estado Cívil</label><br/>
							<select type="select-multiple" id="estadoCivilIn" name="estadoCivilIn" class="required" onblur="genericValid(this);">
								<%if (isEdition) {
									switch (usuario.getEstadoCivil().charAt(0)) {
									case 'c':%>										
										<option value="c" selected="selected" >Casado(a)</option>										
										<option value="s">Solteiro(a)</option>
										<option value="o">Outro</option><%										
										break;
									case 's':%>
										<option value="c">Casado(a)</option>										
										<option value="s" selected="selected">Solteiro(a)</option>
										<option value="o">Outro</option><%
										break;
									case 'o':%>
										<option value="c">Casado(a)</option>										
										<option value="s">Solteiro(a)</option>
										<option value="o" selected="selected">Outro</option>
										<%
										break;
									}
								} else {%>								
									<option value="">Selecione</option>
									<option value="c">Casado(a)</option>
									<option value="s">Solteiro(a)</option>
									<option value="o">Outro</option>
								<%}%>
							</select>
						</div>
						<div id="profissao" class="textBox" style="width:240px">
							<label>Profissão</label><br/>
							<input id="profissaoIn" name="profissaoIn" type="text" style="width:240px" value="<%=(isEdition)? usuario.getProfissao(): "" %>" onblur="genericValid(this)"/>
						</div>
						<div id="nacionalidade" class="textBox" style="width:238px">
							<label>Nacionalidade</label><br/>
							<input id="nacionalidadeIn" name="nacionalidadeIn" type="text" style="width:238px" value="<%=(isEdition)? Util.initCap(usuario.getNacionalidade()): "Brasileira" %>" class="required" onblur="genericValid(this)"/>
						</div>
						<div id="naturalidade" class="textBox" style="width:238px">
							<label>Naturalidade</label><br/>
							<input id="naturalidadeIn" name="naturalidadeIn" type="text" style="width:238px" value="<%=(isEdition)? Util.initCap(usuario.getNaturalidade()): "" %>" class="required" onblur="genericValid(this)" />
						</div>
						<div id="naturalUf" class="textBox">
							<label>Uf</label><br/>
							<select type="select-multiple" id="naturalUfIn" name="naturalUfIn" >
								<%for(String uf: uf2005) {
									if (isEdition && usuario.getNaturalidadeUf().trim().equals(uf.toLowerCase())) {
										out.print("<option value=\"" + uf.toLowerCase() + 
												"\" selected=\"selected\">" + uf + "</option>");
									} else {
										out.print("<option value=\"" + uf.toLowerCase() + 
												"\">" + uf + "</option>");
									}
								}								
								%>
							</select>
						</div>						
						<div id="pai" class="textBox" style="width: 290px;">
							<label>Pai</label><br/>
							<input id="paiIn" name="paiIn" type="text" style="width: 290px;" value="<%=(isEdition && !usuario.getPai().trim().isEmpty())? Util.initCap(usuario.getPai()): "" %>" onblur="genericValid(this);" />
						</div>
						<div id="mae" class="textBox" style="width: 290px;">
							<label>mãe</label><br/>
							<input id="maeIn" name="maeIn" type="text" style="width: 290px;" value="<%=(isEdition && !usuario.getMae().trim().isEmpty())? Util.initCap(usuario.getMae()): "" %>" onblur="genericValid(this);" />
						</div>
					</div>
					<div id="endereco" class="bigBox">
						<div class="indexTitle">
							<h4>Endereço</h4>
							<div class="alignLine">
								<hr />
							</div>
						</div>
						<div id="cep" class="textBox" style="width: 73px">
							<label>CEP</label><br/>
							<input id="cepIn" name="cepIn" type="text" style="width: 73px" value="<%=(isEdition && !endereco.getCep().trim().isEmpty())? Util.mountCep(endereco.getCep()): "" %>" onkeydown="mask(this, cep);" />
						</div>
						
						<div id="ccobLogradouro" class="textBox" style="width: 220px">
							<label>Logradouro</label><br/>
							<select id="ccobLogradouroIn" name="ccobLogradouroIn" style="width: 220px">
								<option value="">Selecione</option>
								<%for(Logradouro lg: logradouros) {%>
									<option value="<% out.print(lg.getCodigo()); %>" <% if (lg.getCodigo().equals(usuario.getCcobLogradouro())) {out.print("selected=\"selected\""); } %> ><%= Util.initCap(lg.getDescricao().toLowerCase()) %></option>
								<%}%>
							</select>
						</div>
						
						<div id="rua" class="textBox" style="width: 270px">
							<label>Endereço</label><br/>
							<input id="ruaIn" name="ruaIn" type="text" style="width: 270px" value="<%=(isEdition)? Util.initCap(endereco.getRuaAv()): "" %>" class="required" onblur="genericValid(this)" />
						</div>
						<div id="numero" class="textBox" style="width: 50px">
							<label>Numero</label><br/>
							<input id="numeroIn" name="numeroIn" type="text" style="width: 50px" value="<%=(!isEdition || endereco.getNumero() == null)? "": endereco.getNumero() %>" />
						</div>
						<div id="complemento" class="textBox" style="width: 250px">
							<label>Complemento</label><br/>
							<input id="complementoIn" name="complementoIn" type="text" style="width: 250px" value="<%=(isEdition)? endereco.getComplemento(): "" %>" />
						</div>
						<div id="bairro" class="textBox" style="width: 260px">
							<label>Bairro</label><br/>
							<input id="bairroIn" name="bairroIn" type="text" style="width: 260px" value="<%=(isEdition && endereco.getBairro() != null)? Util.initCap(endereco.getBairro()): "" %>" />
						</div>
						<div id="cidade" class="textBox" style="width: 260px">
							<label>Cidade</label><br/>
							<input id="cidadeIn" name="cidadeIn" type="text" style="width: 260px" value="<%=(isEdition)? Util.initCap(endereco.getCidade()): "" %>" class="required" onblur="genericValid(this)" />
						</div>
						<div id="uf" class="textBox">
							<label>Uf</label><br/>
							<select type="select-multiple" id="ufIn" name="ufIn" class="required" onblur="genericValid(this);">
								<%for(String uf: uf2005) {
									if (isEdition && endereco.getUf().trim().equals(uf.toLowerCase())) {
										out.print("<option value=\"" + uf.toLowerCase() + 
												"\" selected=\"selected\">" + uf + "</option>");
									} else {
										out.print("<option value=\"" + uf.toLowerCase() + 
												"\">" + uf + "</option>");
									}
								}
								%>
							</select>
						</div>
					</div>
					<div id="dependente" class="bigBox" >
						<div class="indexTitle">
							<h4>Dependentes</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>						
						<div id="nomeDependente" class="textBox" style="width: 240px">
							<label>Nome</label><br/>
							<input id="nomeDependenteIn" name="nomeDependenteIn" type="text" style="width: 240px" onblur="genericValid(this)" />
						</div>
						<div id="cpfDependente" class="textBox" style="width: 100px">
							<label>Cpf</label><br/>
							<input id="cpfDependenteIn" name="cpfDependenteIn" type="text" style="width: 100px" onkeydown="mask(this, cpf);" />
						</div>
						<div id="nascimentoDependente" class="textBox" style="width: 73px;">
							<label>Nascimento</label><br/>
							<input id="nascimentoDependenteIn" name="nascimentoDependenteIn" type="text" style="width: 73px;" onkeydown="mask(this, typeDate);"/>
						</div>
						<div id="parentesco" class="textBox" style="width: 85px">
							<label>parentesco</label><br/>
							<select type="select-multiple" id="parentescoIn" name="parentescoIn">
								<option value="">Selecione</option>
								<option value="irmão(a)">Irmão(a)</option>
								<option value="conjuge">Conjuge</option>
								<option value="pai">Pai</option>
								<option value="mãe">Mãe</option>
								<option value="sogro(a)">Sogro(a)</option>
								<option value="filho(a)">Filho(a)</option>
								<option value="neto(a)">neto(a)</option>
								<option value="outro">Outro</option>								
							</select>
						</div>						
						<div id="foneDependente" class="textBox" style="width:98px">
							<label>Telefone</label><br/>
							<input id="foneDependenteIn" name="foneDependenteIn" type="text" style="width:98px" onblur="genericValid(this)" onkeydown="mask(this, fone);" />
						</div>
						<div id="tableDependente" class="multGrid"></div>
					</div>
					<div class="buttonContent" >
						<div class="formGreenButton">							
							<input name="removeDependente" class="greenButtonStyle" type="button" value="Excluir" onclick="removeRowDependente()" />
						</div>					
						<div class="formGreenButton" >
							<input id="specialButton" name="insertDependente" class="greenButtonStyle" type="button" value="Inserir" onclick="addRowDependente()" />
						</div>
					</div>
					<div id="contato" class="bigBox" style="bottom: 30px !important" >
						<div class="indexTitle">
							<h4>Informações de Contato</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>												
						<div class="textBox" style="width: 135px">
							<label>Tipo</label><br/>
							<select id="tipoContato" name="tipoContato" onchange="clearNext('descricaoIn')" >
								<option value="Selecione">Selecione</option>
								<option value="fone residencial">Fone Residencial</option>
								<option value="fone comercial">Fone Comercial</option>
								<option value="fone recado" >Fone Recado</option>
								<option value="fax">Fax</option>
								<option value="celular">Celular</option>
								<option value="email">email</option>
								<option value="msn">msn</option>
								<option value="skype">Skype</option>
								<option value="g talk">G Talk</option>
								<option value="icq">ICQ</option>
								<option value="site">Pagina Web</option>
								<option value="outro">Outro</option>
							</select>
						</div>
						<div id="descricao" class="textBox" style="width:300px;">
							<label>Descrição</label><br/>
							<input id="descricaoIn" name="descricao" type="text" style="width:300px;" onkeydown="comboMask(this, 'tipoContato')" />
						</div>
						<div class="textBox" id="principal">
							<label>Principal</label><br/>
							<select id="principalIn" name="principalIn" >								
								<option value="Sim">Sim</option>
								<option value="Não" selected="selected">Não</option>
							</select>
						</div>
						<div id="tableContact" class="multGrid" ></div>
					</div>
					<div class="buttonContent" style="margin-top: -40px;">					
						<div class="formGreenButton">
							<input name="removeContact" class="greenButtonStyle" type="button" value="Excluir" onclick="removeRowContact()" />
						</div>					
						<div class="formGreenButton" >
							<input id="specialButton" name="insertDependente" class="greenButtonStyle" type="button" value="Inserir" onclick="addRowContact()" />
						</div>
					</div>				
					
					<div id="situacaoFinanceira" class="bigBox" style="bottom: 30px !important" >
						<div class="indexTitle">
							<h4>Dados Financeiros</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div id="adesao" class="textBox" style="width: 91px;">
							<label>Adesão</label><br/>
							<input id="adesaoIn" name="adesaoIn" type="text" style="width: 91px;"  value="<%=(isEdition && usuario.getCcobAdesao() != null)? Util.formatCurrency(usuario.getCcobAdesao()) : "0.00" %>"  onkeydown="mask(this, decimalNumber);" class="required" onblur="genericValid(this);" />
						</div>												
						<div id="parcela" class="textBox" style="width: 91px;">
							<label>Mensalidade</label><br/>
							<input id="parcelaIn" name="parcelaIn" type="text" style="width: 91px;" value="<%=(isEdition && usuario.getCcobValor() != null)? Util.formatCurrency(usuario.getCcobValor()) : "0.00" %>" onkeydown="mask(this, decimalNumber);" class="required" onblur="genericValid(this);" />
						</div>
						<div class="textBox">
							<label>Parcelamento</label><br/>
							<select id="pagamentos" name="pagamentos" style="width: 100px" >
								<%if (isEdition) {%>
									<option value="1" <%if (usuario.getQtdeParcela()== 1) { out.print("selected=\"selected\""); } %>>A Vista</option>
									<option value="6" <%if (usuario.getQtdeParcela()== 6) { out.print("selected=\"selected\""); } %>>6 vezes</option>
									<option value="12" <%if (usuario.getQtdeParcela()== 12) { out.print("selected=\"selected\""); } %>>12 vezes</option>
									<option value="18" <%if (usuario.getQtdeParcela()== 18) { out.print("selected=\"selected\""); } %>>18 vezes</option>
									<option value="24" <%if (usuario.getQtdeParcela()== 24) { out.print("selected=\"selected\""); } %>>24 vezes</option>
								<%} else {%>
								<option value="1">A Vista</option>
								<option value="6">6 vezes</option>
								<option value="12">12 vezes</option>
								<option value="18" selected="selected">18 vezes</option>
								<option value="24" >24 vezes</option>
								<%}%>
							</select>
						</div>
						<div class="textBox" style="width: 65px">
							<label>Venc.</label><br/>
							<select id="vencimento" name="vencimento">
								<%if (isEdition) {%>
									<option value="01" <%if (usuario.getVencimento().trim().equals("01")) { out.print("selected=\"selected\""); }%>>Dia 01</option>
									<option value="05" <%if (usuario.getVencimento().trim().equals("05")) { out.print("selected=\"selected\""); }%>>Dia 05</option>
									<option value="10" <%if (usuario.getVencimento().trim().equals("10")) { out.print("selected=\"selected\""); }%>>Dia 10</option>
									<option value="15" <%if (usuario.getVencimento().trim().equals("15")) { out.print("selected=\"selected\""); }%>>Dia 15</option>
									<option value="20" <%if (usuario.getVencimento().trim().equals("20")) { out.print("selected=\"selected\""); }%>>Dia 20</option>
									<option value="25" <%if (usuario.getVencimento().trim().equals("25")) { out.print("selected=\"selected\""); }%>>Dia 25</option>																		
								<%} else {%>
									<option value="01">Dia 01</option>
									<option value="05">Dia 05</option>
									<option value="10">Dia 10</option>
									<option value="15">Dia 15</option>
									<option value="20">Dia 20</option>
									<option value="25">Dia 25</option>																	
								<%}%>
							</select>
						</div>
						<div class="textBox" style="width: 90px">
							<label>Vigência</label><br/>
							<select id="vigencia" name="vigencia">
								<%if(isEdition) {%>
									<option value="0">Selecione</option>
									<option value="6" <%if ((Util.diferencaMonth(usuario.getRenovacao(), usuario.getCadastro()) == 6) ||
											(Util.diferencaMonth(usuario.getRenovacao(), usuario.getCadastro()) == 5)) { out.print("selected=\"selected\""); }%>>6 meses</option>
									<option value="12" <%if ((Util.diferencaMonth(usuario.getRenovacao(), usuario.getCadastro()) == 12) ||
											(Util.diferencaMonth(usuario.getRenovacao(), usuario.getCadastro()) == 11)) { out.print("selected=\"selected\""); }%>>12 meses</option>
									<option value="18" <%if (Util.diferencaMonth(usuario.getRenovacao(), usuario.getCadastro()) == 18 ||
											(Util.diferencaMonth(usuario.getRenovacao(), usuario.getCadastro()) == 17)) { out.print("selected=\"selected\""); }%>>18 meses</option>
									<option value="24" <%if ((Util.diferencaMonth(usuario.getRenovacao(), usuario.getCadastro()) == 24) ||
											(Util.diferencaMonth(usuario.getRenovacao(), usuario.getCadastro())== 23)) { out.print("selected=\"selected\""); }%>>24 meses</option>
								<% } else { %>
								<option value="0">Selecione</option>
								<option value="6">6 meses</option>
								<option value="12">12 meses</option>
								<option value="18">18 meses</option>
									<option value="24">24 meses</option>
								<% } %>
							</select>
						</div>
						<div id="renovacao" class="textBox" style="width: 73px;">
							<label>Renovação</label><br/>
							<input id="renovacaoIn" name="renovacaoIn" type="text" style="width: 73px;" value="<%=(isEdition)? Util.parseDate(usuario.getRenovacao(), "dd/MM/yyyy") : "" %>" onkeydown="mask(this, typeDate);"/>
						</div>
						<div class="textBox" style="width: 150px">
							<label>Pagamento</label><br/>
							<select id="formaPagamento" name="formaPagamento" >
								<%for(FormaPagamento pag: pagamento) {
									if (isEdition && usuario.getPagamento().equals(pag)) {										
										out.println("<option value=\"" + pag.getCodigo() +
												"\" selected=\"selected\" >" + pag.getDescricao() + "</option>");
									} else {
										out.println("<option value=\"" + pag.getCodigo() +
												"\" >" + pag.getDescricao() + "</option>");
									}
								}%>								
							</select>
						</div>
						<div class="textBox" style="margin-left: 20px;">
							<label>Bloqueio</label><br/>
							<select id="formaPagamento" name="formaPagamento" >
								<option value="9999" >Não Bloquear</option>
								<option value="1" >01 Dia de Atraso</option>
								<option value="5" >05 Dias de Atraso</option>
								<option value="10" >10 Dias de Atraso</option>
								<option value="20" >20 Dias de Atraso</option>
								<option value="30" selected="selected">30 Dias de Atraso</option>
								<option value="60" >60 Dias de Atraso</option>
								<option value="90" >90 Dias de Atraso</option>
								<option value="120">120 Dias de Atraso</option>
							</select>
						</div>
						<div id="tableDebitos" style="width: 100%"></div>
					</div>
					
					<div id="situacaoFinanceira" class="bigBox" style="bottom: 30px !important" >
						<div class="indexTitle">
							<h4>Gestão e Tercerização de Cobranças</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div id="ccobStatus" class="textBox" style="width: 148px">
							<label>Empresa Tercerizada</label><br/>
							<select  style="width: 148px">
								<option value="">Selecione</option>
								<option value="" selected="selected">CENTERCOB</option>
								<option value="">GECOB</option>
								<option value="">Grupo Prever</option>																
							</select>
						</div>
						<div id="ccobConcessionaria" class="textBox" style="width: 135px">
							<label>Concessionária</label><br/>
							<select id="ccobConcessionariaIn" name="ccobConcessionariaIn" style="width: 135px">
								<option value="">Selecione</option>
								<%for(Concessionaria conc: concessionariaList) {%>
									<option value="<% out.print(conc.getNumero()); %>" <% if (conc.getNumero().equals(usuario.getCcobConcessionaria())) { out.print("selected=\"selected\""); } %> ><%= Util.initCap(conc.getDescricao()) %></option>
								<%}%>
							</select>
						</div>
						<div id="ccobStatus" class="textBox" style="width: 295px">
							<label>Status da Cobrança</label><br/>
							<select id="ccobStatusIn" name="ccobStatusIn" style="width: 295px">	
								<option value="">Selecione</option>										
								<option value="O" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("O")) { out.print("selected=\"selected\""); }%> >Não Enviar - Pagamento por Boleto</option>
								<option value="P" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("P")) { out.print("selected=\"selected\""); }%> >Não Enviar - Pagamento no Corporativo</option>
								<option value="N" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("N")) { out.print("selected=\"selected\""); }%> >Não Enviar - Pag. Esc.</option>
								<option value="I" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("I")) { out.print("selected=\"selected\""); }%> >Para Enviar</option>
								<option value="E" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("E")) { out.print("selected=\"selected\""); }%> >Enviado</option>
								<option value="A" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("A")) { out.print("selected=\"selected\""); }%> >Para Alterar - UC</option>
								<option value="C" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("C")) { out.print("selected=\"selected\""); }%> >Para Cancelar</option>
								<option value="L" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("L")) { out.print("selected=\"selected\""); }%> >Cancelado</option>
								<option value="R" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("R")) { out.print("selected=\"selected\""); }%> >Com Falta ou Erro de Dados</option>
								<option value="D" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("D")) { out.print("selected=\"selected\""); }%> >Com Contas em Atraso</option>
								<option value="S" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("S")) { out.print("selected=\"selected\""); }%> >Sem Conta de Energia Elétrica</option>
								<option value="B" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("B")) { out.print("selected=\"selected\""); }%> >Ocorrência de Erro na CPFL</option>
								<option value="T" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("T")) { out.print("selected=\"selected\""); }%> >Lista Negra da CPFL</option>
								<option value="G" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("G")) { out.print("selected=\"selected\""); }%> >Lista Negra do Plano</option>
								<option value="M" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("M")) { out.print("selected=\"selected\""); }%> >Houve troca de Titularidade</option>
								<option value="U" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("U")) { out.print("selected=\"selected\""); }%> >Duplicidade de Cobrança na mesma UC</option>
								<option value="F" <%if (isEdition && usuario.getCcobStatus() != null && usuario.getCcobStatus().trim().equals("F")) { out.print("selected=\"selected\""); }%> >Aguardando Definição</option>
							</select>
						</div>
						<div id="ccobStatus" class="textBox" style="width: 145px">
							<label>Debitar</label><br/>
							<select id="ccobCobrarIn" name="ccobCobrarIn" style="width: 145px">	
								<option value="">Selecione</option>										
								<option value="t" <%if (isEdition && usuario.getCcobCobrar() != null && usuario.getCcobCobrar().trim().equals("t")) { out.print("selected=\"selected\""); }%> >Adesão e Mensalidades</option>
								<option value="m" <%if (isEdition && usuario.getCcobCobrar() != null && usuario.getCcobCobrar().trim().equals("m")) { out.print("selected=\"selected\""); }%> >Somente Mensalidades</option>
								<option value="a" <%if (isEdition && usuario.getCcobCobrar() != null && usuario.getCcobCobrar().trim().equals("a")) { out.print("selected=\"selected\""); }%> >Somente Adesão</option>
							</select>
						</div>						
						<div id="ccobUndConsumidora" class="textBox" style="width: 141px;">
							<label>Cód. UC - (Seu Cód.)</label><br/>
							<input id="ccobUndConsumidoraIn" name="ccobUndConsumidoraIn" type="text" style="width: 141px;" value="<%=((isEdition) && (usuario.getCcobUndConsumidora() != null))? usuario.getCcobUndConsumidora() : "" %>" >
						</div>									
						<div id="ccobTitular" class="textBox" style="width: 297px;">
							<label>Nome do Titular da Conta de Energia Elétrica</label><br/>
							<input id="ccobTitularIn" name="ccobTitularIn" type="text" style="width: 297px;" maxlength="70" value="<%=((isEdition) && (usuario.getCcobTitular() != null))? usuario.getCcobTitular() : "" %>" >
						</div>		
											
						<div id="ccobTipo" class="textBox" style="width: 100px;">
							<label>Tipo Do Doc.</label><br/>
							<select id="ccobTipoIn" name="ccobTipoIn" style="width: 100px;">
								<option value="" >Selecione</option>
								<option value="f" <% out.print(usuario.getCcobTipo() != null && usuario.getCcobTipo().equals("f") ? "selected=\"selected\"" : ""); %> >CPF</option>
								<option value="j" <% out.print(usuario.getCcobTipo() != null && usuario.getCcobTipo().equals("j") ? "selected=\"selected\"" : ""); %>>CNPJ</option>
							</select>
						</div>	
						
						<div id="ccobDocumento" class="textBox" style="width: 178px;">
							<label>N&deg; Do Documento</label><br/>
							<input id="ccobDocumentoIn" name="ccobDocumentoIn" type="text" style="width: 178px;" onkeydown="mask(this, onlyNumber);" value="<%=((isEdition) && (usuario.getCcobDocumento() != null))? usuario.getCcobDocumento() : "" %>">
						</div>
						
						
						<div id="ccobDtLeitura" class="textBox" style="width: 143px;">
							<label>Data da Leitura Atual</label><br/>
							<input id="ccobDtLeituraIn" name="ccobDtLeituraIn" type="text" style="width: 143px;" onkeydown="mask(this, dateType);" value="<%=((isEdition) && (usuario.getCcobDtLeitura() != null))? Util.parseDate(usuario.getCcobDtLeitura(), "dd/MM/yyyy") : "" %>">
						</div>
						<div id="ccobDtVencimento" class="textBox " style="width: 143px;">
							<label>Data do Vencimento</label><br/>
							<input id="ccobDtVencimentoIn" name="ccobDtVencimentoIn" type="text" style="width: 143px;" onkeydown="mask(this, dateType);" value="<%=((isEdition) && (usuario.getCcobDtVencimento() != null))? Util.parseDate(usuario.getCcobDtVencimento(), "dd/MM/yyyy") : "" %>">
						</div>
						<input id="ccobDocEstadualIn" name="ccobDocEstadualIn" type="hidden"  value="<%=((isEdition) && (usuario.getCcobDocEstadual() != null))? usuario.getCcobDocEstadual() : "" %>">
						<div id="ccobDocEstadual" class="textBox" style="width: 297px; display: none;">
							<label>N&deg; RG ou Insc. Estadual do Titular</label><br/>
							<input id="ccobDocEstadualIn" name="ccobDocEstadualIn" type="text" style="width: 297px;"  value="<%=((isEdition) && (usuario.getCcobDocEstadual() != null))? usuario.getCcobDocEstadual() : "" %>">
						</div>
					</div>
					
					<div id="endPage" class="bigBox" >
						<div class="indexTitle">
							<h4>&nbsp;</h4>
						</div>
					</div>
					<div class="buttonContent" >
						<div class="formGreenButton">
							<input class="greenButtonStyle" type="button" value="Salvar" onclick="sendForm()" />
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