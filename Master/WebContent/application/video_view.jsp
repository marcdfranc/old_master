<%@page import="com.marcsoftware.database.Video"%>
<%
	if (request.getParameter("id") == null || request.getParameter("id") == "") {
		out.print("<script type='text/javascript'>location.href = 'forum.jsp';</script>");
	}
%>

<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<jsp:useBean id="video" class="com.marcsoftware.database.Video"></jsp:useBean>
	<%
	Session sess = (Session) session.getAttribute("hb");
	if (!sess.isOpen()) {
		sess = HibernateUtil.getSession();
	}
	Util.historico(sess, Long.valueOf(session.getAttribute("acessoId").toString()), request);
	video = (Video) sess.load(Video.class, Long.valueOf(request.getParameter("id")));
	%>
	
	
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<link rel="shortcut icon" href="../icone.ico">	
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<link type="text/css" href="../js/jquery/theme/ui.all.css" rel="Stylesheet" />
	<link rel="StyleSheet" href="../css/component.css" type="text/css" />
	
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
	
	<title>Master - Vídeos</title>
	
	<script type="text/javascript" src="../js/jquery/jquery.js"></script>
	<script type="text/javascript" src="../js/jquery/interface.js"></script>
</head>
<body>
	<%@ include file="../inc/header.jsp" %>	
	<jsp:include page="../inc/menu.jsp">
		<jsp:param name="currentPage" value="<%= session.getAttribute("munuParaVideo") %>"/>
	</jsp:include>	
	<div id="centerAll">
		<jsp:include page="../inc/submenu.jsp">
			<jsp:param name="currentPage" value="<%= session.getAttribute("munuParaVideo")%>"/>
		</jsp:include>
		<div id="formStyle">
			<div id="geralDate" class="alignHeader" >
				<jsp:include page="../inc/feedback.jsp">
					<jsp:param name="currPage" value="Vídeo"/>			
				</jsp:include>
		
				<div class="video">
					<iframe width="640" height="360" src="http://www.youtube.com/embed/<%= video.getUrl() %>?feature=player_detailpage" frameborder="0" allowfullscreen></iframe>
				
				</div>
					
			</div>
		</div>
		<%@ include file="../inc/footer.html" %>
		<%sess.close();%>
	</div>
</body>
</html>