<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="java.util.List"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.database.Profissional"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.database.Usuario"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.database.Orcamento"%>
<%@page import="com.marcsoftware.utilities.Util"%>

<%@page import="com.marcsoftware.database.ItensOrcamento"%>
<%@page import="com.marcsoftware.database.Score"%>
<%@page import="com.marcsoftware.database.PlanoServico"%>
<%@page import="com.marcsoftware.database.ParcelaOrcamento"%><html xmlns="http://www.w3.org/1999/xhtml">
	<jsp:useBean id="usuario" class="com.marcsoftware.database.Usuario"></jsp:useBean>
	<jsp:useBean id="profissional" class="com.marcsoftware.database.Profissional"></jsp:useBean>
	
	<%!List<Profissional> profissionalList= null; %>
	<%!List<Usuario> usuarioList= null; %>
	<%!List<ParcelaOrcamento> parcelaList = null; %>
	<%!Query query;%>
	<%!double desconto = 0;%>
	<%!double vlrTotal = 0;%>
	<%!List<ItensOrcamento> itenList;%>
	<%!Score score;%>
	<%!PlanoServico planoServico;%>
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
	<script type="text/javascript" src="../js/comum/orcamento.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>
	
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	usuario = null;
	if (!request.getParameter("id").trim().equals("-1")) {
		query = sess.createQuery("from Usuario as u where u.codigo = :codigo");
		query.setLong("codigo", Long.valueOf(request.getParameter("id")));
		usuario= (Usuario) query.uniqueResult();
	} else if (request.getParameter("dep") != null) {
		query= sess.createQuery("select distinct(d.usuario) from  Dependente as d where d.codigo = :dependente");			
		query.setLong("dependente", Long.valueOf(request.getParameter("dep")));
		usuario= (Usuario) query.uniqueResult();
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
	query= sess.getNamedQuery("profissionalOf");
	query.setLong("codigo", (unidadeList.size() == 1)? unidadeList.get(0).getCodigo() : 0);
	profissionalList= (List<Profissional>) query.list();
	query= sess.createQuery("from Usuario as u where deleted = \'n\' and u.unidade.codigo = :codigo");
	query.setLong("codigo", (unidadeList.size() == 1)? unidadeList.get(0).getCodigo(): 0);
	usuarioList = (List<Usuario>) query.list();
	%>	
	
	<title>Master Orçamento</title>
</head>
<body onload="load()">
	<div id="windowAlertOk" class="removeBorda" title="Exclusão de Orçamento" style="display: none">
		<p>Orçamento excluído com sucesso!</p>
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
			<form id="orc" method="get" onsubmit="return search()" >				
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Orçamentos"/>			
					</jsp:include>
					<%if (usuario != null) {%>
						<div id="abaMenu">
							<div class="aba2">
								<a href="cadastro_cliente_fisico.jsp?state=1&id=<%= usuario.getCodigo()%>">Cadastro</a>
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
							<div class="sectedAba2">
								<label>Orçamentos de Profissionais</label>
							</div>
						</div>
					<%} else {%>
						<div id="abaMenu">
							<!-- <div class="aba2">
								<a href="orcamento_empresa.jsp?id=-1">Orçamentos de Empresas</a>
							</div>	 -->						
							<div class="aba2">
								<a href="produto.jsp">Vendas de Produtos</a>
							</div>
							<div class="sectedAba2">
								<label>></label>	
							</div>
							<div class="sectedAba2">
								<label>Orçamentos de Profissionais</label>
							</div>
						</div>
					<%}%>
					<div class="topContent">
						<div>
							<input id="prive" name="prive" type="hidden" value="<%=request.getSession().getAttribute("perfil").toString() %>" />
							<input id="idUser" name="idUser" type="hidden" value="<%=request.getParameter("id") %>" />
						</div>
						<%if (usuario == null) {%>
						<div id="userId" class="textBox" style="width:50px">
							<label>CTR</label><br/>
							<input id="userIdIn" name="userIdIn" type="text" style="width: 50px;"/>
						</div>
						<div id="usuario" class="textBox" style="width:280px">
							<label>Titular</label><br/>
							<input id="usuarioIn" name="usuarioIn" type="text" style="width: 280px"/>
						</div>
						<div id="dependente" class="textBox" style="width:280px">
							<label>Dependente</label><br/>
							<input id="dependenteIn" name="dependenteIn" type="text" style="width: 280px"/>
						</div>
						<div id="orcId" class="textBox" style="width:50px">
							<label>Orç.</label><br/>
							<input id="orcIn" name="orcIn" type="text" style="width: 50px;"/>
						</div>
						<div class="textBox" id="profissionalId" style="width: 80px;">
							<label>Ref. Prof.</label><br/>
							<select id="profissionalIdIn" name="profissionalIdIn">
								<option value="">Selecione</option>								
								<%if (unidadeList.size() == 1) {
									for(Profissional  prof: profissionalList) {
										out.print("<option value=\"" + prof.getCodigo() + 
												"\">" + prof.getCodigo() + "</option>");
									}
								}%>
							</select>
						</div>					
						<div id="profissional" class="textBox" style="width: 235px;">
							<label>Profissional</label><br/>
							<input id="profissionalIn" name="profissionalIn" type="text" style="width: 235px;"/>
						</div>
						<div id="unidadeId" class="textBox">
							<label>Cod. Unid.</label><br/>
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
								}
								%>
							</select>
						</div>
						<%} else {%>							
							<div class="textBox" id="userRef" name="userRef" style="width: 50px;">
								<label>CTR</label><br/>
								<input id="userRefIn" name="userRefIn" type="text" style="width:50px" readonly="readonly" value="<%=usuario.getReferencia()%>"/>
							</div>
							<div id="nome" class="textBox" style="width: 220px;">
								<label>Cliente</label><br/>
								<input id="nomeIn" name="nomeIn" type="text" style="width: 220px;" value="<%=Util.initCap(usuario.getNome())%>" readonly="readonly" />
							</div>
							<div class="textBox" id="sexo" name="sexo" style="width: 65px;">
								<label>Sexo</label><br/>
								<input id="sexoIn" name="sexoIn" type="text" style="width:65px" readonly="readonly" value="<%=(usuario.getSexo().equals("m"))? "Masculino" : "Feminino"%>"/>
							</div>
							<div class="textBox" id="cpf" name="cpf" style="width: 100px;">
								<label>Cpf</label><br/>
								<input id="cpfIn" name="cpfIn" type="text" style="width:100px" readonly="readonly" value="<%=Util.mountCpf(usuario.getCpf()) %>"/>
							</div>
							<div class="textBox" id="rg" name="rg" style="width: 89px;">
								<label>Rg</label><br/>
								<input id="rgIn" name="rgIn" type="text" style="width:89px" readonly="readonly" value="<%=usuario.getRg() %>"/>
							</div>
							<div class="textBox" id="nascimento" name="nascimento" style="width: 75px;">
								<label>Nascimento</label><br/>
								<input id="nascimentoIn" name="nascimentoIn" type="text" style="width:75px" readonly="readonly" value="<%=Util.parseDate(usuario.getNascimento(), "dd/MM/yyyy") %>"/>
							</div>
							<div class="textBox" id="estadoCivil" name="estadoCivil" style="width: 75px;">
								<label>Estado Civil</label><br/>
								<input id="estadoCivilIn" name="estadoCivilIn" type="text" style="width:75px" readonly="readonly" value="<%
									 if (usuario.getEstadoCivil().equals("s")) {
										 out.print("Solteiro(a)");
									 } else if (usuario.getEstadoCivil().equals("f")) {
										 out.print("Casado(a)");
									 } else {
										 out.print("Outro");
									 }%>"/>
							</div>
							<div id="orcId" class="textBox" style="width:50px">
								<label>Orç.</label><br/>
								<input id="orcIn" name="orcIn" type="text" style="width: 50px;"/>
							</div>
						<%}%>
					</div>
				</div>
				<div class="topButtonContent">
					<div class="leftButtonContent">
						<input id="buscar" name="insertConta" class="greenButtonStyle" type="<%=(usuario == null)?  "submit": "button"%>" value="<%=(usuario == null)? "Buscar": "Voltar" %>" 
							<%if (usuario != null) {%> 
								onclick="voltar()" 
							<%}%>/>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%DataGrid dataGrid= new DataGrid( null);
						if (usuario == null) {
						query = sess.getNamedQuery("orcamentoProfOf");
						query.setLong("codigo", 
								(unidadeList.size() == 1)? unidadeList.get(0).getCodigo() : 0);
						} else {
							query = sess.getNamedQuery("orcamentoByUser");							
							query.setLong("codigo",	usuario.getCodigo());
						}
						int gridLines = query.list().size();
						String resultQuery = "";
						query.setFirstResult(0);
						query.setMaxResults(30);
						List<Orcamento> orcamento= (List<Orcamento>) query.list();
						dataGrid.addColumWithOrder("5", "CTR", false);						
						dataGrid.addColumWithOrder("35", "Cliente", true);
						dataGrid.addColumWithOrder("5", "Orc.", false);
						dataGrid.addColumWithOrder("15", "Data", false);
						dataGrid.addColum("33", "Profissional");
						dataGrid.addColum("5", "Valor");
						dataGrid.addColumWithOrder("2", "St.", false);
						for(Orcamento orc: orcamento) {							
							query= sess.getNamedQuery("totalOrcamento");
							if (usuario != null) {
								query.setLong("unidade", usuario.getUnidade().getCodigo());							
							} else {
								query.setLong("unidade", unidadeList.get(0).getCodigo());
							}	
							query.setLong("orcamento", orc.getCodigo());
							try {
								resultQuery =  query.uniqueResult().toString();							
							} catch (Exception e) {
								resultQuery = "0";
							}					
							vlrTotal = Double.parseDouble(resultQuery);
							
							profissional = (Profissional) sess.get(Profissional.class, orc.getPessoa().getCodigo());
							
							dataGrid.setId(String.valueOf(orc.getCodigo()));
							dataGrid.addData(Util.zeroToLeft(orc.getUsuario().getContrato().getCtr(), 4));
							dataGrid.addData((orc.getDependente() == null)? 
									Util.initCap(orc.getUsuario().getNome()) : 
									Util.initCap(orc.getDependente().getNome()));							
							dataGrid.addData(String.valueOf(orc.getCodigo()));
							dataGrid.addData(Util.parseDate(orc.getData(), "dd/MM/yyyy"));
							dataGrid.addData(Util.initCap(profissional.getNome()));
							dataGrid.addData(Util.formatCurrency(vlrTotal));
							query = sess.getNamedQuery("parcelamentoByCodeOrcamento");
							query.setLong("codigo", orc.getCodigo());
							parcelaList = (List<ParcelaOrcamento>) query.list();
							desconto = 0;
							if (orc.getUsuario().getPlano().getTipo().equals("l")) {
								query = sess.createQuery("from ItensOrcamento as i where i.id.orcamento = :orcamento");
								query.setEntity("orcamento", orc);
								itenList = (List<ItensOrcamento>) query.list();
								for (ItensOrcamento iten: itenList) {
									if (parcelaList.size() > 0) {										
										query = sess.createSQLQuery("SELECT SUM(l.valor) FROM parcela_orcamento AS p " +
												" INNER JOIN lancamento AS l ON(p.cod_lancamento = l.codigo) " +
												" WHERE p.cod_orcamento = :orcamento");
										query.setLong("orcamento", orc.getCodigo());
										desconto = Double.parseDouble(query.uniqueResult().toString());
									} else {
										query = sess.createQuery("from PlanoServico as p " + 
												" where p.id.plano = :plano " +
												" and p.id.servico = :servico");
										query.setEntity("plano", orc.getUsuario().getPlano());
										query.setEntity("servico", iten.getTabela().getServico());
										if (query.list().size() > 0) {
											planoServico = (PlanoServico) query.uniqueResult();
											if (orc.getDependente() == null) {
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
												query.setEntity("dependente", orc.getDependente());
											}
											query.setEntity("usuario", orc.getUsuario());
											query.setEntity("servico", iten.getTabela().getServico());
											if (query.list().size() > 0) {
												score = (Score) query.uniqueResult();
												if ((planoServico.getQtde() - score.getQtde()) >= iten.getQtde()) {
													desconto += iten.getQtde() * iten.getTabela().getValorCliente();
												} else {
													desconto+= (planoServico.getQtde() - iten.getQtde()) * iten.getTabela().getValorCliente();
												}
											} else {
												if ((planoServico.getQtde()) >= iten.getQtde()) {
													desconto += iten.getQtde() * iten.getTabela().getValorCliente();
												} else {
													desconto+= (planoServico.getQtde() - iten.getQtde()) * iten.getTabela().getValorCliente();
												}
											}
										}
									}
								}
							}
							/*if (parcelaList.size() > 0 && orc.getUsuario().getPlano().getTipo().equals("l")) {
								dataGrid.addData(Util.formatCurrency(vlrTotal - desconto));
							} else if (orc.getUsuario().getPlano().getTipo().equals("l")) {
								dataGrid.addData(Util.formatCurrency(desconto));
							} else {
								dataGrid.addData("0.00");
							}*/
							dataGrid.addImg(Util.getIconMax(parcelaList));
							dataGrid.addRow();
						}
						out.print(dataGrid.getTable(gridLines));
						
						%>
						<div id="pagerGrid" class="pagerGrid"></div>												
					</div>
				</div>				
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close(); %>
	</div>
</body>
</html>