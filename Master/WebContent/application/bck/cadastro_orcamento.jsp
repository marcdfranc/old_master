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
<%@page import="com.marcsoftware.database.Profissional"%>
<%@page import="com.marcsoftware.database.Especialidade"%>
<%@page import="com.marcsoftware.database.Usuario"%>
<%@page import="com.marcsoftware.database.Tabela"%>
<%@page import="com.marcsoftware.database.ItensOrcamento"%>
<%@page import="com.marcsoftware.utilities.Util"%>

<%@page import="java.util.ArrayList"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Score"%>
<%@page import="com.marcsoftware.database.PlanoServico"%>
<%@page import="com.marcsoftware.database.Vigencia"%><html xmlns="http://www.w3.org/1999/xhtml">
	<jsp:useBean id="profissional" class="com.marcsoftware.database.Profissional"></jsp:useBean>
	<%!List<ItensOrcamento> orcamentoIten= null; %>
	<%!boolean isEdition= false;%>
	<%!Query query; %>	
	<%isEdition = (request.getParameter("state") != null)? true : false;
	if (isEdition) {
		isEdition = (request.getParameter("state").equals("1"))? true : false;
	}%>	
	<%
	String haveParcela = "n";
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	ArrayList<Vigencia> tabelasVig = new ArrayList<Vigencia>();
	if (session.getAttribute("perfil").equals("a")) {
		query= sess.createQuery("from Unidade as u where u.deleted =\'n\'");		
	} else if (session.getAttribute("perfil").equals("f")) {
		query= sess.getNamedQuery("unidadeByUser");
		query.setString("username", (String) session.getAttribute("username"));
	} else {
		query = sess.createQuery("select p.unidade from Pessoa as p where p.login = :username");
		query.setString("username", (String) session.getAttribute("username"));
	}	
	List<Unidade> unidadeList = (List<Unidade>) query.list();
	
	String aprovada = "";
	if (unidadeList.size() == 1) {
		query = sess.createQuery("from Vigencia as v " +
				" where v.unidade = :unidade " +
				" and v.aprovacao = 's'");
		query.setEntity("unidade", unidadeList.get(0));
		tabelasVig = (ArrayList<Vigencia>) query.list();
	}	
	
	double total = 0;
	double desconto = 0;
	int totalServico = 0;
	PlanoServico planoServico;
	Score score;
	String descSetor = "";
	if (isEdition) {
		query= sess.createQuery("from ItensOrcamento as i where i.id.orcamento= :codigo");
		query.setLong("codigo", Long.valueOf(request.getParameter("id")));
		orcamentoIten = (List<ItensOrcamento>) query.list();
		
		profissional = (Profissional) sess.get(Profissional.class, orcamentoIten.get(0).getId().getOrcamento().getPessoa().getCodigo());
		switch (profissional.getEspecialidade().getSetor().charAt(0)) {
			case 'o':
					descSetor = "Odontológica";
				break;
				
			case 'l':
				descSetor = "Laboratorial";
				break;
				
			case 'm':
				descSetor = "Médica";
				break;
		
			case 'h':
				descSetor = "Hospitalar";
			break;
		}
		
		
		aprovada = (orcamentoIten.get(0).getTabela().getVigencia().getAprovacao().trim().equals("s"))
			? orcamentoIten.get(0).getTabela().getVigencia().getDescricao() : "";
		
		query = sess.createQuery("from ParcelaOrcamento as p where p.id.orcamento = :orcamento");
		query.setEntity("orcamento", orcamentoIten.get(0).getId().getOrcamento());
		haveParcela = (query.list().size() > 0)? "s" : "n";
		if (haveParcela.equals("s")) {
			query = sess.createSQLQuery("SELECT SUM(l.valor) FROM parcela_orcamento AS p " +
					" INNER JOIN lancamento AS l ON(p.cod_lancamento = l.codigo) " +
					" WHERE p.cod_orcamento = :orcamento");
			query.setLong("orcamento", orcamentoIten.get(0).getId().getOrcamento().getCodigo());
			desconto = Double.parseDouble(query.uniqueResult().toString());
		}
	}
	%>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<link rel="shortcut icon" href="../icone.ico"/>
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
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/comum/cadastro_orcamento.js" ></script>
	<script type="text/javascript" src="../js/lib/pilot_grid.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>

	<title>Master Orçamentos</title>
</head>
<body onload="loadPage(<%= isEdition %>)">
	<div id="uploadOrcamento" class="removeBorda" title="Upload da Imagem da Guia" style="display: none;">
		<form id="formUpload" onsubmit="return false;" action="../GuiaUpload" method="post" enctype="multipart/form-data">
			<div class="uploadContent" id="contUpload">
				<div id="msgUpload" style="margin-bottom: 20px;">Clique abaixo para selecionar o arquivo pdf a ser enviado.</div>
				<div id="fileQueue" style="width: 200px;"></div>
				<input type="file" name="uploadify" id="uploadify" />
				<!-- <p><a href="javascript:jQuery('#uploadify').uploadifyClearQueue()">Cancelar Todos os Anexos</a></p> -->
			</div>
			<input type="hidden" value="" id="uploadName" name="uploadName" />
		</form>
	</div>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="orcamento"/>
	</jsp:include>
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="orcamento"/>
		</jsp:include>
		<div id="formStyle">
			<input id="haveDoc" name="haveDoc" type="hidden" value="<%=(isEdition)? orcamentoIten.get(0).getId().getOrcamento().getDocDigital() : "" %>"/>
			<form id="formPost" name="formPost" method="post" action="../CadastroOrcamento" onsubmit="return validForm(this)">
				<div id="localTabela"></div>
				<div id="deletedsServ"></div>				
				<div>
					<input id="codOrcamento" name="codOrcamento" type="hidden" value="<%=(isEdition)? orcamentoIten.get(0).getId().getOrcamento().getCodigo(): "" %>" />
					<input id="userIdIn" name="userIdIn" type="hidden" value="<%= (isEdition) ? orcamentoIten.get(0).getId().getOrcamento().getUsuario().getCodigo() : "" %>" />
					<%if (isEdition) { %>
						<input id="aprovacao" name="aprovacao" type="hidden" value="<%=(aprovada.trim().equals(""))? "n" : "s" %>"/>					
					<%} else {%>
						<input id="aprovacao" name="aprovacao" type="hidden" value="s"/>
					<%}%>
					<input id="haveParcela" name="haveParcela" type="hidden" value="<%=haveParcela%>"/>
				</div>
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Orçamento"/>			
					</jsp:include>
					<%if (isEdition) {%>
						<div id="abaMenu">
							<div class="aba2">
								<a href="cadastro_cliente_fisico.jsp?state=1&id=<%= orcamentoIten.get(0).getId().getOrcamento().getUsuario().getCodigo()%>">Cadastro</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="anexo_fisico.jsp?id=<%=orcamentoIten.get(0).getId().getOrcamento().getUsuario().getCodigo()%>">Anexo</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="mensalidade.jsp?id=<%= orcamentoIten.get(0).getId().getOrcamento().getUsuario().getCodigo()%>">Mensalidades</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="orcamento_empresa.jsp?id=<%= orcamentoIten.get(0).getId().getOrcamento().getUsuario().getCodigo()%>">Orçamentos de Empresas</a>
							</div>							
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="aba2">
								<a href="orcamento.jsp?id=<%= orcamentoIten.get(0).getId().getOrcamento().getUsuario().getCodigo()%>">Orçamentos de Profissionais</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="sectedAba2">
								<label>Orçamento</label>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>						
							<div class="aba2">
								<a href="cadastro_parcela.jsp?id=<%= orcamentoIten.get(0).getId().getOrcamento().getCodigo()%>">Parcelamento</a>	
							</div>
							<%if (session.getAttribute("perfil").toString().trim().equals("a")
								|| session.getAttribute("perfil").toString().trim().equals("d")
								|| session.getAttribute("perfil").toString().trim().equals("f")) {%>
								<div class="sectedAba2">
									<label>></label>
								</div>
								<div class="aba2">
									<a href="cadastro_parcela.jsp?id=<%= orcamentoIten.get(0).getId().getOrcamento().getCodigo()%>&state=o">Parcelamento Prof.</a>	
								</div>
							<%}%>							
						</div>
					<%} else {%>
						<div id="abaMenu">
							<div class="aba2">
								<a href="orcamento.jsp?id=-1">Orçamentos</a>	
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
						<div class="textBox" id="unidadeId" name="unidadeId" >
							<label>Cód. Unid.</label><br/>
							<select id="unidadeIdIn" name="unidadeIdIn" <% if (isEdition) {%> disabled="disabled" <%}%> style="width: 383px" >
								<option value="" >Selecione</option> 								
								<%if (!isEdition && unidadeList.size()== 1) {
									out.print("<option selected=\"selected\" value=\"" + 
											unidadeList.get(0).getFantasia() + "@" +
											unidadeList.get(0).getCodigo() + "\">" + 
											unidadeList.get(0).getReferencia() + " - "+
											unidadeList.get(0).getFantasia() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										if (isEdition && orcamentoIten.get(0).getTabela().getUnidade().equals(un)) {
											out.print("<option selected=\"selected\" value=\"" + 
													un.getFantasia() + "@" + 
													un.getCodigo() + "\">" + 
													un.getReferencia() + " - " +
													un.getFantasia() +  "</option>");
										} else {
											out.print("<option value=\"" + un.getFantasia() + "@" +
													un.getCodigo() + "\">" + un.getReferencia() + " - " 
													+ un.getFantasia() + "</option>");
										}
									}									
								}%>
							</select>
						</div>						
						
						<div id="username" class="textBox" style="width: 150px;">
							<label>Usuário</label><br/>
							<input id="usernameIn" name="usernameIn" class="required" type="text" "readonly="readonly" style="width: 150px;" value="<%=(isEdition)? orcamentoIten.get(0).getId().getOrcamento().getLogin().getUsername() : session.getAttribute("username") %>"/>
						</div>
						<div id="cadastro" class="textBox" style="width: 73px;">
							<label>Cadastro</label><br/>
							<input id="cadastroIn" name="cadastroIn" class="required" type="text" <%if(isEdition) {%> "readonly="readonly" <%}%> style="width: 73px;" value="<%=(isEdition)? Util.parseDate(orcamentoIten.get(0).getId().getOrcamento().getData(), "dd/MM/yyyy") : Util.getToday() %>" <%if(!isEdition) {%> onkeydown="mask(this, dateType);" <%}%>/>
						</div>
						<div id="setor" class="textBox" style="width: 105px">
							<label>Atividade</label><br/>
							<select type="select-multiple" <% if (isEdition) {%> disabled="disabled" <%}%> id="setorIn" name="setorIn" >
								<%if (isEdition) {%>
									<option value="<%= profissional.getEspecialidade().getSetor() %>"><%= descSetor %></option>
								<%} else {%>
									<option value="">Selecione</option>
									<option value="o">Odontológica</option>
									<option value="l">Laboratorial</option>
									<option value="m">Médica</option>
									<option value="h">Hospitalar</option>
								<%}%>
							</select>
						</div>
						<div id="profId" class="textBox" style="width: 262px;">
							<label>Profissional</label><br/>
							<select id="profIdIn" name="profIdIn" <% if (isEdition) {%> disabled="disabled" <%}%> style="width: 262px">
								<%if (isEdition) {%>								
									<option value="<%= profissional.getCodigo() + "@" + profissional.getConselho()%>"><%= profissional.getNome()%></option>
								<%} else {%> 
									<option value="" >Selecione</option>
								<%}%>
							</select>
						</div>
						<div id="conselho" class="textBox" style="width: 150px" >
							<label>Nro. Conselho</label><br/>
							<input id="conselhoIn" name="conselhoIn" type="text" style="width: 150px;" value="<%=(isEdition)? profissional.getConselho(): "" %>" class="required" enable="false" onblur="genericValid(this);" readonly="readonly" />
						</div>						
						<div class="textBox" id="orcId" style="width: 78px">
							<label>N° Orç.</label><br/>
							<input id="orcIdIn" name="orcIdIn" type="text" style="width: 73px;" value="<%=(isEdition)? orcamentoIten.get(0).getId().getOrcamento().getCodigo(): "" %>" readonly="readonly"/>
						</div>
						<div class="textBox" id="userId" style="width: 80px">
							<label>CTR</label><br/>
							<input id="ctr" name="ctr" type="text" style="width: 80px;" value="<%=(isEdition)? Util.initCap(orcamentoIten.get(0).getId().getOrcamento().getUsuario().getReferencia()): "" %>" class="required" onkeydown="mask(this, onlyNumber);" onblur="genericValid(this);" <%if(isEdition) { out.print("readonly=\"readonly\""); }%> />
						</div>
						<div id="usuario" class="textBox" style="width: 275px;" >
							<label>Titular</label><br/>
							<input id="usuarioIn" name="usuarioIn" type="text" style="width: 270px;" value="<%=(isEdition)? Util.initCap(orcamentoIten.get(0).getId().getOrcamento().getUsuario().getNome()): "" %>" enable="false" readonly="readonly" />
						</div>
						<div class="textBox" id="dependenteId" style="width: 256px">
							<label>Dependente</label><br/>
							<select id="dependenteIdIn" name="dependenteIdIn" style="width: 256px;" <%if (isEdition) out.print("disabled=\"disabled\""); %>>
								<option value="" >Selecione</option> 								
								<%if (isEdition && (orcamentoIten.get(0).getId().getOrcamento().getDependente() != null)) {
									out.print("<option selected=\"selected\" value=\"" +
											orcamentoIten.get(0).getId().getOrcamento().getDependente().getCodigo() + "\">" + 
											Util.initCap(orcamentoIten.get(0).getId().getOrcamento().getDependente().getNome()) + 
											"</option>");
								}%>
							</select>
						</div>
					</div>
				</div>
				<%if (isEdition) {%>
					<div class="topButtonContent">
						<div class="formGreenButton">
							<input  class="greenButtonStyle" type="button" value="Cadastro" onclick="printOrcamento()"/>
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
					<div id="itensOrcamento" class="bigBox" >
						<div class="indexTitle">
							<h4>Procedimentos</h4>
							<div class="alignLine">
								<hr>
							</div>
						</div>
						<div>
							<input type="hidden" id="especialidadeIn" name="especialidadeIn" value=""/>							
						</div>
						<div id="tabela" class="textBox">
							<label>Tabela</label><br/>
							<select type="select-multiple" id="tabelaIn" name="tabelaIn" class="required" onblur="genericValid(this);" style="width: 315px" >
								<option value="">Selecione</option>
								<%if(isEdition) {
									out.print("<option value=\"" + 
										orcamentoIten.get(0).getTabela().getVigencia().getCodigo() +
										"\" selected=\"selected\">" + 
										orcamentoIten.get(0).getTabela().getVigencia().getDescricao() + "</option>");
								}
								for(Vigencia tab: tabelasVig) {
									out.print("<option value=\"" + tab.getCodigo() + "\">" + tab.getDescricao() + "</option>");
								}%>
							</select>
						</div>						
						<div id="servicoRef" class="textBox" style="width: 80px;" >
							<label>Cod. Proc.</label><br/>
							<input id="servicoRefIn" name="servicoRefIn" type="text" style="width: 80px;" readonly="readonly"/>
						</div>						
						<div id="servico" class="textBox" style="width: 335px;" >
							<label>Procedimento</label><br/>
							<input id="servicoIn" name="servicoIn" type="text" style="width: 335px;" readonly="readonly"/>
						</div>
						<div>
							<input type="hidden" id="servicoIdIn" name="servicoIdIn" value="" />
						</div>
						<div id="vlrUnit" class="textBox" style="width: 90px;" >
							<label>Valor Unit.</label><br/>
							<input id="vlrUnitIn" name="vlrUnitIn" type="text" style="width: 90px;" value="0.00" onblur="genericValid(this);" readonly="readonly" />
						</div>
						<div id="qtde" class="textBox" style="width: 30px;" >
							<label>Qtde</label><br/>
							<input id="qtdeIn" name="qtdeIn" type="text" style="width: 30px;" value="1" class="required" onblur="genericValid(this);" readonly="readonly" onkeydown="mask(this, onlyInteger);" />
						</div>
						<div id="tableServico" class="multGrid"></div>
					</div>
					<div id="dataGrid">
						<%DataGrid dataGrid = new DataGrid("#");
						dataGrid.addColum("15", "Atividade");
						dataGrid.addColum("20", "Setor");
						dataGrid.addColum("3", "Código");
						dataGrid.addColum("45", "Procedimento");
						dataGrid.addColum("5", "valor");
						dataGrid.addColum("5", "Qtde");
						dataGrid.addColum("5", "Total");
						dataGrid.addColum("2", "Ck");
						totalServico = 0;
						if (isEdition) {
							for (ItensOrcamento iten: orcamentoIten) {
								totalServico+= iten.getQtde();
								dataGrid.setId("");
								switch (iten.getTabela().getServico().getEspecialidade().getSetor().charAt(0)) {
								case 'o':
									dataGrid.addData("rowSetor", "Odontológica");
									break;
								
								case 'm':
									dataGrid.addData("rowSetor", "Médica");
									break;
									
								case 'h':
									dataGrid.addData("rowSetor", "Hospitalar");
									break;
									
								case 'l':
									dataGrid.addData("rowSetor", "Laboratorial");
									break;
								}						
								
								dataGrid.addData("rowEspecialidade", Util.initCap(
										iten.getTabela().getServico().getEspecialidade().getDescricao()));
								
								dataGrid.addData("rowCodigo", iten.getTabela().getServico().getReferencia());
								dataGrid.addData("rowServico", Util.initCap(
										iten.getTabela().getServico().getDescricao()));
								if (iten.getContabil().equals("s")) {
									dataGrid.addData("rowValor",Util.formatCurrency(
											iten.getTabela().getValorCliente()));
								} else {
									dataGrid.addData("rowValor", "0.00");
								}
								dataGrid.addData("rowQtde", String.valueOf(iten.getQtde()));
								dataGrid.addData("rowTotal",Util.formatCurrency(
										iten.getQtde() * iten.getTabela().getValorCliente()));
								total+= (iten.getQtde() * iten.getTabela().getValorCliente());
								dataGrid.addCheck("checkrowTabela");
								if (haveParcela.equals("n")) {
									query = sess.createQuery("from PlanoServico as p " + 
											" where p.id.plano = :plano " +
											" and p.id.servico = :servico");
									query.setEntity("plano", iten.getId().getOrcamento().getUsuario().getPlano());
									query.setEntity("servico", iten.getTabela().getServico());
									if (query.list().size() > 0) {
										planoServico = (PlanoServico) query.uniqueResult();
										if (iten.getId().getOrcamento().getDependente() == null) {
											query = sess.createQuery("from Score as s " + 
													" where s.validade > current_date " + 
													" and s.usuario = :usuario " + 
													" and s.servico = :servico");
										} else {
											query = sess.createQuery("from Score as s " + 
													" where s.validade > current_date " + 
													" and s.usuario = :usuario " + 
													" and s.servico = :servico " +
													" and s.dependente = :dependente");
											query.setEntity("dependente", iten.getId().getOrcamento().getDependente());
										}
										query.setEntity("usuario", iten.getId().getOrcamento().getUsuario());
										query.setEntity("servico", iten.getTabela().getServico());
										if (query.list().size() > 0) {
											score = (Score) query.uniqueResult();
											if ((planoServico.getQtde() - score.getQtde()) >= iten.getQtde()) {
												desconto += iten.getQtde() * iten.getTabela().getValorCliente();
											} else {
												desconto+= (planoServico.getQtde() - iten.getQtde()) * iten.getTabela().getValorCliente();
											}
										} else {
											if (planoServico.getQtde() >= iten.getQtde()) {
												desconto += iten.getQtde() * iten.getTabela().getValorCliente();
											} else {
												desconto+= (planoServico.getQtde() - iten.getQtde()) * iten.getTabela().getValorCliente();
											}									
										}
									}
								}								
								dataGrid.addRow();
							}
						}
						if (haveParcela.equals("s")) {
							dataGrid.addTotalizador("Valor da Cobertura", Util.formatCurrency(total - desconto), "totalCobGd", true);
							if (isEdition) {
								dataGrid.addTotalizador("Total do Orçamento", Util.formatCurrency(total), "totalOrcGd", true);
								dataGrid.addTotalizador("Procedimentos", String.valueOf(totalServico), "totalServGd", false);								
							} else {
								dataGrid.addTotalizador("Total do Orçamento", Util.formatCurrency(total), "totalOrcGd", false);
							}
							dataGrid.makeTotalizador();
							dataGrid.addTotalizadorRight("Total a pagar", Util.formatCurrency(desconto));
							dataGrid.makeTotalizadorRight();
						} else {
							dataGrid.addTotalizador("Valor da Cobertura", Util.formatCurrency(desconto), "totalCobGd", true);
							if (isEdition) {
								dataGrid.addTotalizador("Total do Orçamento", Util.formatCurrency(total), "totalOrcGd", true);
								dataGrid.addTotalizador("Procedimentos", String.valueOf(totalServico), "totalServGd", false);
							} else {
								dataGrid.addTotalizador("Total do Orçamento", Util.formatCurrency(total), "totalOrcGd", false);
							}
							dataGrid.makeTotalizador();
							dataGrid.addTotalizadorRight("Total a pagar", Util.formatCurrency(total - desconto));
							dataGrid.makeTotalizadorRight();
						}
						out.print(dataGrid.getTable(0));						
						%>
					</div>					
					<div class="buttonContent">					
						<div class="formGreenButton">
							<input name="removeTabela" class="greenButtonStyle" type="button" 
								<%if (isEdition) {
									out.print("disabled=\"disabled\"");
								}%>
							 value="Excluir" onclick="removeRowServico()" />
						</div>					
						<div class="formGreenButton" >
							<input id="specialButton" name="insertTabela" class="greenButtonStyle" type="button"  
								<%if (isEdition) {
									out.print("disabled=\"disabled\"");
								}%>	value="Inserir" onclick="addRowServico()" />
						</div>
					</div>					
					<div class="buttonContent" style="margin-top: 45px;">
						<%if (session.getAttribute("perfil").toString().trim().equals("a")
								|| session.getAttribute("perfil").toString().trim().equals("d")
								|| session.getAttribute("perfil").toString().trim().equals("f")) {%>
							<div class="formGreenButton">						
								<input class="greenButtonStyle" type="button" value="Salvar" onclick="noAccess()" />
							</div>
						<%} else {%>
							<div class="formGreenButton">
								<input class="greenButtonStyle" type="button" value="Salvar" onclick="enviarOrcamento()" />
							</div>
						<%}%>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>