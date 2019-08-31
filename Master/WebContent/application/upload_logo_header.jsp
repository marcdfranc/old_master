<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page errorPage="/exception.jsp" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />	
	<link rel="shortcut icon" href="../icone.ico">
	<link rel="StyleSheet" href="../css/estilo.css" type="text/css" />
	<!--[if IE]><link rel="StyleSheet" href="../css/ieStyle.css" type="text/css" /><![endif]-->
		
<title>Master Upload</title>
</head>
<body>
	<div>
		<div id="upload">
			<h1>Seleção de imagens</h1>
		</div>		
		<form name="formPost" method="post" name="formPost" action="../LogoHeaderUpload" enctype="multipart/form-data">
			<input id="idPessoa" name="idPessoa" type="hidden" value="<%=request.getParameter("id") %>"/>
			<div id="fotoAdm" class="textBox" style="width: 340px; margin-left: 100px;">
				<label>Foto</label><br/>					
				<input id="fotoAdmIn" name="fotoAdmIn" type="file" accept="image/jpeg; image/gif; image/bmp; image/png" id="imagem" class="dados" maxlength="1000" tabindex="1" value="c:/" size ="40" >
			</div>
			<div style="position: relative; top: 80px; right: 350px;">
				<div class="formGreenButton">
					<input id="save" name="save" class="greenButtonStyle" type="submit" value="Salvar" />
				</div>
			</div>								
		</form>
	</div>
</body>
</html>