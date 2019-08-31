<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Query"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Profissional"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="java.util.Date"%>
<%@page import="com.marcsoftware.database.ParcelaOrcamento"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.database.EmpresaSaude"%>
<%@page import="com.marcsoftware.utilities.Util"%><html xmlns="http://www.w3.org/1999/xhtml">
	<%Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	Query query;
	List<ParcelaOrcamento> parcelaList;
	List<Profissional> profissionalList;
	List<EmpresaSaude> empresaList;
	Date vencimento = new Date();
	Date now = new Date();
	Date inicio = Util.removeMonths(new Date(), 1);
	Date fim = new Date();
	double vlrCliente = 0;
	double operacional = 0;
	double calcOperacional = 0;
	double calcCliente = 0;
	double retorno = 0;
	int totalGuias = 0;
	double totalOperacional = 0;
	double totalCliente = 0;
	double totalC2 = 0;
	
	inicio = Util.parseDate("26/" + Util.getMonthDate(inicio) + "/" + Util.getYearDate(inicio));
	fim = Util.parseDate("25/" + Util.getMonthDate(fim) + "/" + Util.getYearDate(fim));
	
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
	
	if (unidadeList.size() == 1) {
		query = sess.getNamedQuery("profissionalOf");
		query.setLong("codigo", unidadeList.get(0).getCodigo());
		profissionalList = (List<Profissional>) query.list();
		query = sess.getNamedQuery("empresaSaudeOf");
		query.setLong("unidade", unidadeList.get(0).getCodigo());
		empresaList = (List<EmpresaSaude>) query.list();
	} else if(session.getAttribute("perfil").toString().equals("a")) {
		query = sess.createQuery("from Profissional as p order by p.codigo");
		profissionalList = (List<Profissional>) query.list();
		query = sess.createQuery("from EmpresaSaude as e order by e.codigo");
		empresaList = (List<EmpresaSaude>) query.list();
	} else {
		query = sess.createQuery("from Profissional as p where (1 <> 1)");		
		profissionalList = (List<Profissional>) query.list();
		query = sess.createQuery("from EmpresaSaude as e where (1 <> 1)");
		empresaList = (List<EmpresaSaude>) query.list();
	}
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
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/comum/custo_operacional.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	
	<title>Master Custo Operacional</title>	
</head>
<body>
	<%@ include file="../inc/header.jsp" %>	
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="financeiro"/>
	</jsp:include>	
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="financeiro"/>			
		</jsp:include>
		<div id="formStyle">
			<form id="unit" method="get" onsubmit="return search()">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Carteira ADM"/>			
					</jsp:include>
					<div class="topContent">
						<div id="unidadeIn" class="textBox">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId">
								<%if (session.getAttribute("perfil").toString().equals("a")) {%>
									<option value="">Selecione</option>
								<%} else {%>
									<option value="0">Selecione</option>
								<%}%>
								<%if (unidadeList.size() == 1) {
									out.print("<option value=\"" + unidadeList.get(0).getCodigo() + 
											"\" selected=\"selected\">" + unidadeList.get(0).getReferencia() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										out.print("<option value=\"" + un.getCodigo() + "\">" + 
												un.getReferencia() + "</option>");
									}
								}
								%>
							</select>
						</div>						
						<div id="inicio" class="textBox" style="width: 73px;">
							<label>Início</label><br/>
							<input id="inicioIn" name="inicioIn" type="text" style="width: 73px;" onkeydown="mask(this, dateType);"/>
						</div>
						<div id="fim" class="textBox" style="width: 73px;">
							<label>Fim</label><br/>
							<input id="fimIn" name="fimIn" type="text" style="width: 73px;" onkeydown="mask(this, dateType);"/>
						</div>
					</div>					
				</div>
				<div class="topButtonContent">
					<div class="formGreenButton">
						<input class="greenButtonStyle" type="button" value="Imprimir" onclick="generatePdf()"/>
					</div>
					<div class="formGreenButton">
						<input class="greenButtonStyle" type="submit" value="Buscar"/>
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%int gridLines = profissionalList.size();
						DataGrid dataGrid = new DataGrid("#");
						dataGrid.addColum("5", "Ref.");
						dataGrid.addColum("35", "Profissional/Empresa de Saúde");
						dataGrid.addColum("5", "Guias");
						dataGrid.addColum("19", "Vencimento");
						dataGrid.addColum("12", "Vlr. Cliente");
						dataGrid.addColum("12", "Vlr. Operac.");
						dataGrid.addColum("12", "Vlr. Adm.");						
						for(Profissional prof: profissionalList) {
							query = sess.createQuery("from ParcelaOrcamento as p " + 
									" where p.id.orcamento.pessoa.codigo = :profissional " +
									" and p.id.lancamento.dataQuitacao between :inicio and :fim " +
									" and p.id.lancamento.status in ('f', 'q') order by p.id.lancamento.dataQuitacao");
							
							query.setLong("profissional", prof.getCodigo());
							query.setDate("inicio", inicio);
							query.setDate("fim", fim);
							parcelaList = (List<ParcelaOrcamento>) query.list();
							vlrCliente = operacional = retorno = 0;
							for(ParcelaOrcamento parcela: parcelaList) {
								query = sess.getNamedQuery("operacionalOrcamento");
								query.setLong("orcamento", parcela.getId().getOrcamento().getCodigo());
								query.setLong("unidade", parcela.getId().getLancamento().getUnidade().getCodigo());
								calcOperacional = Double.parseDouble(query.uniqueResult().toString());
								
								query = sess.getNamedQuery("clienteOrcamento");
								query.setLong("orcamento", parcela.getId().getOrcamento().getCodigo());
								query.setLong("unidade", parcela.getId().getLancamento().getUnidade().getCodigo());
								calcCliente = Double.parseDouble(query.uniqueResult().toString());
								
								vlrCliente+= parcela.getId().getLancamento().getValor();
								operacional+= Util.getOperacional(calcOperacional, calcCliente,
										 parcela.getId().getLancamento().getValor());
							}
							totalGuias+= parcelaList.size(); 
							totalCliente+= vlrCliente;
							totalOperacional+= operacional;
							totalC2+= (vlrCliente - operacional);							
							
							vencimento = Util.parseDate(prof.getVencimento() + "/" +
									Util.getMonthDate(now) + "/" + Util.getYearDate(now));
							
							dataGrid.setId(String.valueOf(prof.getCodigo()));
							dataGrid.addData(String.valueOf(prof.getCodigo()));
							dataGrid.addData(Util.initCap(prof.getNome()));
							dataGrid.addData(String.valueOf(parcelaList.size()));
							dataGrid.addData(Util.parseDate(vencimento, "dd/MM/yyyy"));
							dataGrid.addData(Util.formatCurrency(vlrCliente));
							dataGrid.addData(Util.formatCurrency(operacional));
							dataGrid.addData(Util.formatCurrency(vlrCliente - operacional));
							
							dataGrid.addRow();
						}
						for(EmpresaSaude emp: empresaList) {
							query = sess.createQuery("from ParcelaOrcamento as p " + 
									" where p.id.orcamento.pessoa.codigo = :empresa " +
									" and p.id.lancamento.dataQuitacao between :inicio and :fim " +
									" and p.id.lancamento.status in ('f', 'q') order by p.id.lancamento.dataQuitacao");
							
							query.setLong("empresa", emp.getCodigo());
							query.setDate("inicio", inicio);
							query.setDate("fim", fim);
							parcelaList = (List<ParcelaOrcamento>) query.list();
							vlrCliente = operacional = retorno = 0;
							for(ParcelaOrcamento parcela: parcelaList) {
								query = sess.getNamedQuery("operacionalOrcamento");
								query.setLong("orcamento", parcela.getId().getOrcamento().getCodigo());
								query.setLong("unidade", parcela.getId().getLancamento().getUnidade().getCodigo());
								calcOperacional = Util.round(Double.parseDouble(query.uniqueResult().toString()), 2);								
								
								query = sess.getNamedQuery("clienteOrcamento");
								query.setLong("orcamento", parcela.getId().getOrcamento().getCodigo());
								query.setLong("unidade", parcela.getId().getLancamento().getUnidade().getCodigo());
								calcCliente = Util.round(Double.parseDouble(query.uniqueResult().toString()), 2);
								
								vlrCliente+= parcela.getId().getLancamento().getValor();
								vlrCliente = Util.round(vlrCliente, 2);
								operacional+= Util.getOperacional(calcOperacional, calcCliente,
										 parcela.getId().getLancamento().getValor());
								operacional = Util.round(operacional, 2);
							}
							totalGuias+= parcelaList.size(); 
							totalCliente+= vlrCliente;
							totalCliente = Util.round(totalCliente, 2);
							totalOperacional+= operacional;
							totalOperacional = Util.round(totalOperacional, 2);
							totalC2+= (vlrCliente - operacional);
							totalC2 = Util.round(totalC2, 2);
							
							vencimento = Util.parseDate(emp.getVencimento() + "/" +
									Util.getMonthDate(now) + "/" + Util.getYearDate(now));
							
							dataGrid.setId(String.valueOf(emp.getCodigo()));
							dataGrid.addData(String.valueOf(emp.getCodigo()));
							dataGrid.addData(Util.initCap(emp.getFantasia()));
							dataGrid.addData(String.valueOf(parcelaList.size()));
							dataGrid.addData(Util.parseDate(vencimento, "dd/MM/yyyy"));
							dataGrid.addData(Util.formatCurrency(vlrCliente));
							dataGrid.addData(Util.formatCurrency(operacional));
							dataGrid.addData(Util.formatCurrency(Util.round(vlrCliente - operacional, 2)));
							
							dataGrid.addRow();
						}						
						dataGrid.addTotalizador("Vlr. Administrativo", Util.formatCurrency(totalC2), true);
						dataGrid.addTotalizador("Vlr. Operacional", Util.formatCurrency(totalOperacional), true);
						dataGrid.addTotalizador("Vlr. Cliente", Util.formatCurrency(totalCliente), true);
						dataGrid.addTotalizador("Guias Emitidas", String.valueOf(totalGuias), false);
						dataGrid.makeTotalizador();
						
						out.print(dataGrid.getTable(gridLines));
						%>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close(); %>
	</div>
</body>
</html>