<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="org.hibernate.Session"%>
<%@page import="org.hibernate.Transaction"%>
<%@page import="org.hibernate.Query"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Unidade"%>
<%@page import="com.marcsoftware.database.Cc"%>
<%@page import="java.util.Date"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.database.ParcelaOrcamento"%>
<%@page import="com.marcsoftware.utilities.UserCounter"%><html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	<%double saldo = 0;
	double creditConcilio = 0;
	double debitoConcilio = 0;
	double operacional = 0;
	double cliente= 0;
	double debitoProfissionais = 0;
	double debitoVendedor = 0;
	double comissaoVendedor = 0;
	double receberFisica = 0;
	double receberJuridica = 0;
	int caixaAberto = 0;
	List<ParcelaOrcamento> parcelaList;
	
	Session sess = HibernateUtil.getSession();
	Transaction transaction = sess.beginTransaction();
	Query query;
	if (session.getAttribute("perfil").equals("a")) {
		query = sess.createQuery("from Unidade as u where u.deleted =\'n\'");		
	} else if (session.getAttribute("perfil").equals("f")) {
		query= sess.getNamedQuery("unidadeByUser");
		query.setString("username", (String) session.getAttribute("username"));
	} else {
		query = sess.createQuery("select p.unidade from Pessoa as p where p.login = :username");
		query.setString("username", (String) session.getAttribute("username"));
	}
	List<Unidade> unidadeList= (List<Unidade>) query.list();
	
	if (unidadeList.size() > 0) {
		query = sess.createQuery("from Cc where unidade.codigo = :unidade");
		if (session.getAttribute("perfil").toString().equals("a")) {
			query.setLong("unidade", Long.valueOf(session.getAttribute("unidade").toString()));
		} else {
			query.setLong("unidade", unidadeList.get(0).getCodigo());			
		}
	} else {
		query = sess.createQuery("from Cc where (1 <> 1)");
	}
	List<Cc> contaList = (List<Cc>) query.list();
	
	Date inicio = new Date();
	Date fim = Util.parseDate(Util.parseDate(Util.addDays(inicio, 1), "dd/MM/yyyy") + " 23:59:59");
	inicio = Util.parseDate(Util.parseDate(inicio, "dd/MM/yyyy") + " 00:00:00.1");
	
	//valor da conta corrente "saldo"
	if (contaList.size() > 0) {
		if (unidadeList.size() > 1 && (!session.getAttribute("perfil").equals("a"))) {
			saldo = creditConcilio = debitoConcilio = 0;			
		} else {
			if (session.getAttribute("perfil").toString().equals("a")) {
				query = sess.getNamedQuery("contaCreditoHold");
			} else {
				query = sess.getNamedQuery("contaCredito");
				query.setLong("unidade", contaList.get(0).getUnidade().getCodigo());
			}							
			query.setTimestamp("dataInicio", contaList.get(0).getCadastro());
			query.setTimestamp("dataFim", fim);
			
			saldo = contaList.get(0).getValor() + ((query.uniqueResult() != null)?
					Double.parseDouble(query.uniqueResult().toString()) : 0);
			
			if (session.getAttribute("perfil").toString().equals("a")) {
				query = sess.getNamedQuery("contaDebitoHold");
			} else {
				query = sess.getNamedQuery("contaDebito");
				query.setLong("unidade", contaList.get(0).getUnidade().getCodigo());
			}
			query.setTimestamp("dataInicio", contaList.get(0).getCadastro());
			query.setTimestamp("dataFim", fim);
			
			saldo-= (query.uniqueResult() != null)?
					Double.parseDouble(query.uniqueResult().toString()) : 0;
					
			if (session.getAttribute("perfil").toString().equals("a")) {
				query = sess.getNamedQuery("totalComissaoHold");
				comissaoVendedor = Double.parseDouble(query.uniqueResult().toString());
				
				query = sess.getNamedQuery("debitoAConciliarHold");
				debitoConcilio = (query.uniqueResult() != null)?
						Double.parseDouble(query.uniqueResult().toString()) : 0;
						
				query = sess.getNamedQuery("creditoAConciliarHold");
				creditConcilio = (query.uniqueResult() != null)?
						Double.parseDouble(query.uniqueResult().toString()) : 0;
						
				query = sess.getNamedQuery("totalComissaoHold");
				debitoVendedor = (query.uniqueResult() == null)? 0
						: Double.parseDouble(query.uniqueResult().toString());
				
				query = sess.createQuery("from Caixa as c where c.status = 'a'");
				caixaAberto = query.list().size();
				
				query = sess.getNamedQuery("mensalidadeFisicaHold");
				query.setDate("inicio", Util.removeMonths(inicio, 1));
				query.setDate("fim", inicio);
				
				receberFisica = (query.uniqueResult() == null)? 0
						: Double.parseDouble(query.uniqueResult().toString());
				
				query = sess.getNamedQuery("totalParcelaFisicoHold");
				query.setDate("inicio", Util.removeMonths(inicio, 1));
				query.setDate("fim", inicio);
				
				receberFisica+= (query.uniqueResult() == null)? 0
						: Double.parseDouble(query.uniqueResult().toString());				
				
				query = sess.getNamedQuery("mensalidadeJuridicaHold");
				query.setDate("inicio", Util.removeMonths(inicio, 1));
				query.setDate("fim", inicio);
				
				receberJuridica = (query.uniqueResult() == null)? 0
						: Double.parseDouble(query.uniqueResult().toString());
				
				query = sess.getNamedQuery("totalParcelaHold");
				query.setDate("inicio", Util.removeMonths(inicio, 1));
				query.setDate("fim", inicio);
				
				receberJuridica+= (query.uniqueResult() == null)? 0
						: Double.parseDouble(query.uniqueResult().toString());
				
				query = sess.createQuery("from ParcelaOrcamento as p where " +
						" p.id.lancamento.status = 'f'");
			} else {
				query = sess.getNamedQuery("totalComissao");
				query.setLong("unidade", unidadeList.get(0).getCodigo());
				comissaoVendedor+= Double.parseDouble(query.uniqueResult().toString());
				
				query = sess.getNamedQuery("debitoAConciliar");
				query.setLong("unidade", unidadeList.get(0).getCodigo());
				debitoConcilio = (query.uniqueResult() != null)?
						Double.parseDouble(query.uniqueResult().toString()) : 0;
						
				query = sess.getNamedQuery("creditoAConciliar");
				query.setLong("unidade", unidadeList.get(0).getCodigo());
				creditConcilio = (query.uniqueResult() != null)?
						Double.parseDouble(query.uniqueResult().toString()) : 0;
						
				query = sess.getNamedQuery("totalComissao");
				query.setLong("unidade", unidadeList.get(0).getCodigo());
					debitoVendedor = (query.uniqueResult() == null)? 0
						: Double.parseDouble(query.uniqueResult().toString());
					
				query = sess.createQuery("from Caixa as c where c.status = 'a' " +
						"and c.unidade = :unidade");
				query.setEntity("unidade", unidadeList.get(0));
				caixaAberto = query.list().size();
				
				query = sess.getNamedQuery("mensalidadeFisica");
				query.setDate("inicio", Util.removeMonths(inicio, 1));
				query.setDate("fim", inicio);
				query.setLong("unidade", unidadeList.get(0).getCodigo());				
				
				receberFisica = (query.uniqueResult() == null)? 0
						: Double.parseDouble(query.uniqueResult().toString());
				
				query = sess.getNamedQuery("totalParcelaFisico");
				query.setDate("inicio", Util.removeMonths(inicio, 1));
				query.setDate("fim", inicio);
				query.setLong("unidade", unidadeList.get(0).getCodigo());
				
				receberFisica+= (query.uniqueResult() == null)? 0
						: Double.parseDouble(query.uniqueResult().toString());				
				
				query = sess.getNamedQuery("mensalidadeJuridica");
				query.setDate("inicio", Util.removeMonths(inicio, 1));
				query.setDate("fim", inicio);
				query.setLong("unidade", unidadeList.get(0).getCodigo());
				
				receberJuridica = (query.uniqueResult() == null)? 0
						: Double.parseDouble(query.uniqueResult().toString());
				
				query = sess.getNamedQuery("totalparcela");
				query.setDate("inicio", Util.removeMonths(inicio, 1));
				query.setDate("fim", inicio);
				query.setLong("unidade", unidadeList.get(0).getCodigo());
				
				receberJuridica+= (query.uniqueResult() == null)? 0
						: Double.parseDouble(query.uniqueResult().toString());
				
				query = sess.createQuery("from ParcelaOrcamento as p where " +
						" p.id.lancamento.unidade = :unidade " +
						" and p.id.lancamento.status = 'f'");
				query.setEntity("unidade", unidadeList.get(0));
			}
			parcelaList = (List<ParcelaOrcamento>) query.list();
			
			debitoProfissionais = 0;
			for(ParcelaOrcamento parcela: parcelaList) {
				query = sess.getNamedQuery("operacionalOrcamento");
				query.setLong("orcamento", parcela.getId().getOrcamento().getCodigo());
				query.setLong("unidade", parcela.getId().getLancamento().getUnidade().getCodigo());
				operacional = Double.parseDouble(query.uniqueResult().toString());
				
				query = sess.getNamedQuery("clienteOrcamento");
				query.setLong("orcamento", parcela.getId().getOrcamento().getCodigo());
				query.setLong("unidade", parcela.getId().getLancamento().getUnidade().getCodigo());
				cliente = Double.parseDouble(query.uniqueResult().toString());
				
				debitoProfissionais+= Util.getOperacional(operacional, cliente,
						parcela.getId().getLancamento().getValor());
			}
		}
	}%>
	
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />	
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/comum/painel_financ.js" ></script>
	<script type="text/javascript" src="../js/lib/componentes/msf_window.js"></script>
	<script type="text/javascript" src="../js/lib/mask.js" ></script>
	<script type="text/javascript" src="../js/lib/util.js" ></script>	
	
	<title>Master - Painel Financeiro</title>
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
			<form id="parc" method="get">
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Painel Financeiro"/>			
					</jsp:include>
					<div class="topContent">
						<div id="unidadeIn" class="textBox">
							<label>Cod. Unid.</label><br/>
							<select id="unidadeId" name="unidadeId">
								<option value="0">Selecione</option>
								<%if (unidadeList.size() == 1) {
									out.print("<option value=\"" + unidadeList.get(0).getCodigo() + 
											"\" selected=\"selected\">" + 
											unidadeList.get(0).getReferencia() + "</option>");
								} else {
									for(Unidade un: unidadeList) {
										out.print("<option value=\"" + un.getCodigo() + "\">" + 
												un.getReferencia() + "</option>");
									}
								}
								%>
							</select>
						</div>
					</div>
				<div id="mainContent">
					<div id="responsavel" class="bigBox" >
						<div class="indexTitle" style="margin-bottom: 20px;">
							<h4>Status Atual</h4>
							<div class="alignLine">
								<hr>
							</div>
							<div style="width: 1000px;">
								<div id="dataGrid" >
									<div class="panelLines" style="width: 600px; background: url('../image/back_check.png') repeat-x top left; border-bottom: none !important;">
										<label id="headerLabel"  style="float: left;">Descrição</label>
									</div>								
									<div class="panelLines" style="width: 280px; background: url('../image/back_check.png') repeat-x top left; border-bottom: none !important;">
										<label id="headerResult" style="float: right;" >Qtde.</label>
									</div>								
								</div>
								<div id="dataGrid">
									<div class="panelLines" style="width: 600px;">										
										<a id="debitoLabel" href="painel_web.jsp" style="float: left;">Usuários Logados</a>
									</div>
									<div class="panelLines" style="width: 280px;">
										<a id="debitoLabel" href="painel_web.jsp" style="float: right;"><%=Util.zeroToLeft(String.valueOf(UserCounter.getUserOnline()), 2)%></a>
									</div>
								</div>
								<div id="dataGrid">
									<div class="panelLines" style="width: 600px; border-bottom: 2px solid #42929D !important;">
										<a id="ccLabel"  style="float: left;">Caixas Abertos</a>
									</div>
									<div class="panelLines" style="width: 280px; border-bottom: 2px solid #42929D !important;">
										<a id="ccLabel"  style="float: right;" ><%=caixaAberto%></a>
									</div>
								</div>
							</div>						
						</div>						
						</div>
						<div id="responsavel" class="bigBox" >
						<div class="indexTitle" style="margin-bottom: 20px;">
							<h4>Movimentações Previstas</h4>
							<div class="alignLine">
								<hr>
							</div>
							<div style="width: 1500px;">
								<div id="dataGrid" >
									<div class="panelLines" style="width: 600px; background: url('../image/back_check.png') repeat-x top left; border-bottom: none !important;">
										<label id="headerLabel"  style="float: left;">Descrição</label>
									</div>
									<div class="panelLines" style="width: 30px; background: url('../image/back_check.png') repeat-x top left; border-bottom: none !important;">
										<label id="headerCk" style="float: left;">Tipo</label>
									</div>
									<div class="panelLines" style="width: 200px; background: url('../image/back_check.png') repeat-x top left; border-bottom: none !important;">
										<label id="headerResult" style="float: right;" >Valor</label>
									</div>
									<div class="panelLines" style="width: 20px; background: url('../image/back_check.png') repeat-x top left; border-bottom: none !important;">
										<label id="headerCk" style="float: left;">Ck</label>
									</div>
								</div>
								<div id="dataGrid">
									<div class="panelLines" style="width: 600px;">
										<a id="ccLabel" href="conta_corrente.jsp" style="float: left;">Saldo de Conta Corrente</a>
									</div>
									<div class="panelLines" style="width: 30px;">
										<img src="../image/credito.gif" />
									</div>
									<div class="panelLines" style="width: 200px;">
										<a id="ccResult" href="conta_corrente.jsp" style="float: right;" ><%= Util.formatCurrency(saldo) %></a>
									</div>
									<div class="panelLines" style="width: 20px;">
										<input id="ck0" type="checkbox" value="<%="s@" + Util.formatCurrency(saldo) %>" onmouseup="somatorio(this)"/>
									</div>
								</div>
								<div id="dataGrid">
									<div class="panelLines" style="width: 600px;">
										<a id="creditoLabel" href="conciliacao.jsp" style="float: left;">Crédito A Conciliar</a>
									</div>
									<div class="panelLines" style="width: 30px;">
										<img src="../image/credito.gif" />
									</div>
									<div class="panelLines" style="width: 200px;">
										<a id="creditoResult" href="conciliacao.jsp" style="float: right;" ><%= Util.formatCurrency(creditConcilio) %></a>
									</div>
									<div class="panelLines" style="width: 20px;">
										<input id="ck1" href="conciliacao.jsp" type="checkbox" value="<%="s@" + Util.formatCurrency(creditConcilio) %>" onmouseup="somatorio(this)"/>
									</div>
								</div>
								<div id="dataGrid">
									<div class="panelLines" style="width: 600px;">
										<a id="debitoLabel" href="conciliacao.jsp" style="float: left;">Débito A Conciliar</a>
									</div>
									<div class="panelLines" style="width: 30px;">
										<img src="../image/debito.gif" />
									</div>
									<div class="panelLines" style="width: 200px;">
										<a id="debitoResult" href="conciliacao.jsp" style="float: right;" ><%= Util.formatCurrency(debitoConcilio) %></a>
									</div>
									<div class="panelLines" style="width: 20px;">
										<input id="ck2" type="checkbox" value="<%="n@" + Util.formatCurrency(debitoConcilio) %>" onmouseup="somatorio(this)"/>
									</div>
								</div>
								<div id="dataGrid">
									<div class="panelLines" style="width: 600px;">
										<a id="royaltLabel" style="float: left;">Royalties, produtos ou serviços</a>
									</div>
									<div class="panelLines" style="width: 30px;">
										<img src="../image/debito.gif" />
									</div>
									<div class="panelLines" style="width: 200px;">
										<a id="royaltResult" style="float: right;" >0.00</a>
									</div>
									<div class="panelLines" style="width: 20px;">
										<input id="ck2" type="checkbox" value="0.00" onmouseup="somatorio(this)"/>
									</div>
								</div>
								<div id="dataGrid">
									<div class="panelLines" style="width: 600px;">
										<a id="fisicoRecebLabel" href="conta_receber.jsp" style="float: left;">Contas a Receber Clientes Físicos</a>
									</div>
									<div class="panelLines" style="width: 30px;">
										<img src="../image/credito.gif" />
									</div>
									<div class="panelLines" style="width: 200px;">
										<a id="fisicoRecebResult" href="conta_receber.jsp" style="float: right;" ><%= Util.formatCurrency(receberFisica) %></a>
									</div>
									<div class="panelLines" style="width: 20px;">
										<input id="ck2" type="checkbox" value="<%="s@" + Util.formatCurrency(receberFisica) %>" onmouseup="somatorio(this)"/>
									</div>
								</div>
								<div id="dataGrid">
									<div class="panelLines" style="width: 600px;">
										<a id="jurRecebLabel" href="conta_receber.jsp" style="float: left;">Contas a Receber Clientes Jurídicos</a>
									</div>
									<div class="panelLines" style="width: 30px;">
										<img src="../image/credito.gif" />
									</div>
									<div class="panelLines" style="width: 200px;">
										<a id="jurRecebResult" href="conta_receber.jsp" style="float: right;" ><%= Util.formatCurrency(receberJuridica) %></a>
									</div>
									<div class="panelLines" style="width: 20px;">
										<input id="ck2" type="checkbox" value="<%="s@" + Util.formatCurrency(receberJuridica)  %>" onmouseup="somatorio(this)"/>
									</div>
								</div>
								<div id="dataGrid">
									<div class="panelLines" style="width: 600px;">
										<a id="pagLabel" href="conta_pagar.jsp" style="float: left;">Contas a Pagar</a>
									</div>
									<div class="panelLines" style="width: 30px;">
										<img src="../image/debito.gif" />
									</div>
									<div class="panelLines" style="width: 200px;">
										<a id="pagResult" href="conta_pagar.jsp" style="float: right;" >0.00</a>
									</div>
									<div class="panelLines" style="width: 20px;">
										<input id="ck2" type="checkbox" value="<%="n@" + Util.formatCurrency(debitoConcilio) %>" onmouseup="somatorio(this)"/>
									</div>
								</div>
								<div id="dataGrid">
									<div class="panelLines" style="width: 600px;">
										<a id="profLabel" href="lancamento_profissional.jsp" style="float: left;">Débito de Profissionais e Clínicas</a>
									</div>
									<div class="panelLines" style="width: 30px;">
										<img src="../image/debito.gif" />
									</div>
									<div id="profResult" class="panelLines" style="width: 200px;">
										<a href="lancamento_profissional.jsp" style="float: right;" ><%= Util.formatCurrency(debitoProfissionais) %></a>
									</div>
									<div class="panelLines" style="width: 20px;">
										<input id="ck3" type="checkbox" value="<%="n@" + Util.formatCurrency(debitoProfissionais) %>" onmouseup="somatorio(this)"/>
									</div>
								</div>
								<div id="dataGrid">
									<div class="panelLines" style="width: 600px; border-bottom: 2px solid #42929D !important;">
										<a href="lancamento_funcionario.jsp" id="funcLabel" style="float: left;">Débito de Vendedores e Revendedores</a>
									</div>
									<div class="panelLines" style="width: 30px; border-bottom: 2px solid #42929D !important;">
										<img src="../image/debito.gif" />
									</div>
									<div class="panelLines" style="width: 200px; border-bottom: 2px solid #42929D !important;">
										<a href="lancamento_funcionario.jsp" id="funcResult" style="float: right;" ><%= Util.formatCurrency(debitoVendedor) %></a>
									</div>
									<div class="panelLines" style="width: 20px; border-bottom: 2px solid #42929D !important;">
										<input id="ck4" type="checkbox" value="<%="n@" + Util.formatCurrency(debitoVendedor) %>" onmouseup="somatorio(this)"/>
									</div>
									<div class="totalizadorRight" style="padding-top: 20px; font-size: 12px !important">
										<label id="labelSoma" name="labelSoma" class="titleCounter" style="margin-right: 5px; float: left;">Saldo Das Movimentações:</label>
										<label id="totalSoma" name="totalSoma" style="width: 30px; height:20px; float: right !important; margin-right: 70px;" class="valueCounter" >0.00</label>				
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</form>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%transaction.commit(); sess.close(); %>
	</div>
</body>
</html>