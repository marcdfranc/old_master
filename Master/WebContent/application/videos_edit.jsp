<%@page import="com.marcsoftware.database.Video"%>
<%@page import="com.marcsoftware.utilities.DataGrid"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="org.hibernate.Session"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	String errorMessagePop = "";
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
%> 
<html>
<head>
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
		
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Master Vídeos</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
    <script type="text/javascript" src="../js/jquery/interface.js"></script>	
	<script type="text/javascript" src="../js/lib/new_datagrid.js"></script>
	<script type="text/javascript" src="../js/lib/util.js"></script>	
	<script type="text/javascript" src="../js/lib/componentes/msf_windows.js"></script>
	<script type="text/javascript" src="../js/comum/videos_edit.js"></script>
	
</head>
<body>
	<%@ include file="../inc/header.jsp" %>
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="adm"/>
	</jsp:include>	
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="adm"/>
		</jsp:include>
		<div id="formStyle">
			<form method="get" onsubmit="return search();" action="">
				
				
				<div id="geralDate" class="alignHeader" >
					<jsp:include page="../inc/feedback.jsp">
						<jsp:param name="currPage" value="Videos"/>			
					</jsp:include>
					<div class="topContent">
						<div class="textBox" style="width: 180px;">
							<label>Categoria</label><br/>
							<select id="menuIn" name="menuIn" style="width: 180px;">
								<option value="">Selecione</option>
 								<option value="unidade">Unidade</option>
 								<option value="clienteF">Cliente Físico</option>
 								<option value="clienteJ">Cliente Jurídico</option>
 								<option value="rh">RH</option>
 								<option value="financeiro">Financeiro</option>
 								<option value="profissional">Profissional</option>
 								<option value="servico">Planos</option>
 								<option value="orcamento">Orçamento</option>
 								<option value="orcamentoEmp">Orçamento de Empresas</option>
 								<option value="fornecedor">Fornecedor</option>
 								<option value="prestador">Prestador de Serviços</option>
 								<option value="empSaude">Empresa de Saúde</option>
 								<option value="forum">Intranet</option>
 								<option value="adm">ADM</option>
							</select>
						</div>
											
						<div id="referencia" class="textBox" style="width: 300px; ">
							<label>Título Vídeo</label><br/>
							<input id="tituloIn" name="tituloIn" type="text" style="width: 300px;"/>												
						</div>
					</div>
				</div>
				<div class="topButtonContent">					
					<div class="formGreenButton">
						<input id="buscar" name="insertConta" class="greenButtonStyle" type="submit" value="Buscar"/>					
					</div>
				</div>
				<div id="mainContent">
					<div id="counter" class="counter"></div>
					<div id="dataGrid">
						<%						
						Query query = sess.createQuery("from Video as v order by v.titulo");
												
						int gridLines= query.list().size();
						query.setFirstResult(0);
						query.setMaxResults(2);
						List<Video> videos = (List<Video>) query.list();
						
						DataGrid dataGrid= new DataGrid("cadastro_video.jsp");
						dataGrid.addColum("40", "titulo");
						dataGrid.addColum("60", "url");
						for (Video vd: videos) {
							dataGrid.setId(String.valueOf(vd.getCodigo()));
							dataGrid.addData(vd.getTitulo());
							dataGrid.addData(vd.getUrl());
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