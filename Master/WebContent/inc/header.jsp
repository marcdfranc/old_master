<%@page import="com.marcsoftware.utilities.UserCounter"%>
<%@page import="com.marcsoftware.utilities.Util"%>


<%@page import="java.util.Date"%>
<%@page import="org.hibernate.Query"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%><%@page import="java.util.List"%>
<%@page import="com.marcsoftware.database.Notificacao"%><script type="text/javascript">
	var tempoAtual;
	var data = new Date();
	$(document).ready(function() {
		$.get("../CadastroNotificacao",{from: "5"}, function (response) {
			if (response == "-1") {
				alert("ocorreu um erro de sessão!");
			} 
		});
				
		$(window).load(function() {
			renderizeClock();
		});
		
		renderizeClock = function() {
			data = new Date();
			var hora = data.getHours();
			var minuto = data.getMinutes();
			var segundo = data.getSeconds();
			hora = hora + "";
			minuto = minuto + "";
			segundo = segundo + "";
			if (hora.length == 1) {
				hora = "0" + hora;
			}
			if (minuto.length == 1) {
				minuto = "0" + minuto;
			}
			if (segundo.length == 1) {
				segundo = "0" + segundo;
			}			
			tempoAtual = hora + ":" + minuto + ":" + segundo;
			$("#clock").text(tempoAtual);
			setTimeout("renderizeClock()", 1000);
		}
		
	});

	function openComunicadoSA(idSA) {
		$("#comSaHeader" + idSA).removeClass("cpEscondeWithHeight");
		$("#comSaHeader" + idSA).dialog({
	 		modal: true,
	 		width: 789,
	 		heigth: 479,
	 		show: 'fade',
		 	hide: 'clip',	 		
	 		buttons: {
	 			"Fechar" : function () {
					$(this).dialog('close');
	 			},
	 			"Marcar como Lida": function () {
	 				setLida($('#headerSaIdMsg' + idSA).val());
	 				$(this).dialog('close');
				}
			},
	 		close: function() {
	 			$(this).dialog('destroy');	 			
	 		}
		 });

	}

	function maximizeComunicadoSA() {
		$("#comunicadoSAClose").slideUp("slow");
		$("#comunicadoSA").hide();
		$("#comunicadoSA").removeClass("cpEscondeWithHeight");
		$("#comunicadoSA").slideToggle("slow");
		setSaIsOpen();
	}

	function minimizeComunidadoSA() {
		$("#comunicadoSA").slideUp("slow");
		$("#comunicadoSAClose").hide();
		$("#comunicadoSAClose").removeClass("cpEscondeWithHeight");
		$("#comunicadoSAClose").slideToggle("slow");
		setSaIsOpen();
	}

	function setSaIsOpen() {
		$.get("../CadastroNotificacao", {
			from: "0",
			saIsOpen: ($("#saIsOpen").val() == "s")? "n" : "s"
			}, 
			function(response) {
				$("#saIsOpen").val(response);
			}	
		);
	}

	function setLida(value) {
		$.get("../CadastroNotificacao", {
			from: "1",
			id: value
		}, function (response) {
			location.href = response;
		});
	}
</script>
<%	
	List<Notificacao> listaNotTitle = (List<Notificacao>) session.getAttribute("notificacaoList");
	String assuntoCompareHeader = "";
	if (listaNotTitle != null) {
		for(Notificacao notifiForHeader: listaNotTitle) {%>			
			<div id="comSaHeader<%=notifiForHeader.getCodigo() %>" class="removeBorda" title="Mensagem Recebida" style="display: none;">
				<input id="headerSaIdMsg<%= notifiForHeader.getCodigo() %>" name="headerSaIdMsg<%= notifiForHeader.getCodigo() %>" type="hidden" value="<%= notifiForHeader.getCodigo() %>">
				<p><b>Remetente:</b> <%= notifiForHeader.getRemetente().getUsername() %></p>
				<p><b>Assunto:</b> <%= notifiForHeader.getAssunto() %></p>
				<p><b>Data:</b> <%= Util.parseDate(notifiForHeader.getData(), "dd/MM/yyyy") %></p>
				<p><b>Hora:</b> <%= Util.getTime(notifiForHeader.getData())  %></p><br/>
				<textarea rows="15" cols="60" class="textDialog ui-widget-content ui-corner-all"><%= notifiForHeader.getDescricao() %></textarea>
			</div>
		<%}
	}%>

<form id="formSetaNotificacao">
	<input type="hidden" name="saIsOpen" id="saIsOpen" value="<%= session.getAttribute("saIsOpen").toString() %>">
</form>

<div id="loaderHeader">
	
	<br/><p style="margin: 0 0 0 30px">Carregando...</p>	
</div>
<div id="header">
	<% if (listaNotTitle != null && listaNotTitle.size() > 0) {
		if (session.getAttribute("saIsOpen").toString().equals("s")){%>
			<div id="comunicadoSAClose" class="comunicadoCloseSA cpEscondeWithHeight"  onclick="maximizeComunicadoSA()">			
		<%} else {%>
			<div id="comunicadoSAClose" class="comunicadoCloseSA" onclick="maximizeComunicadoSA()">
		<%}%>
				<div class="cartaChega">
					<label>@</label>
				</div>
			</div>
			<% if (session.getAttribute("saIsOpen").toString().equals("s")){%>
				<div id="comunicadoSA" >
			<%} else {%>
				<div id="comunicadoSA" class="cpEscondeWithHeight">
			<%}%>
				<div class="buttonCloseNotifique">
					<label onclick="minimizeComunidadoSA()">x</label>
				</div>
				<div id="conteinerSA">
					<ol>
						<%for(Notificacao notifiForHeader: listaNotTitle) {
							if (notifiForHeader.getAssunto().length() >= 39) {
								assuntoCompareHeader = notifiForHeader.getAssunto().substring(0, 39);
								assuntoCompareHeader+= "...";
							} else {
								assuntoCompareHeader = notifiForHeader.getAssunto();
							}
						%>
							<li>
								<div class="notificacaoIten<%= notifiForHeader.getPrioridade() %>">
									<label>Assunto: <%= assuntoCompareHeader %></label>
									<div class="buttonNotifique" onclick="openComunicadoSA(<%= notifiForHeader.getCodigo() %>)">
										<label>&nbsp;</label>
									</div>
								</div>
							</li>
						<%}%>
					</ol>				
				</div>
			</div>
		<%}%>
	<img class="logoHeader" src="<%= session.getAttribute("logo") %>"/>	
	<div class="logado">
		<label>Usuário: </label>
		<span><%= (String) session.getAttribute("username") %></span>				
	</div>
	<div class="logado"> 
		<label>Perfil: </label>
		<span>
			<%if (session.getAttribute("perfil").equals("a")) {
				out.print("Administrador");
			} else if (session.getAttribute("perfil").equals("d")) {
				out.print("Desenvolvedor");
			} else if (session.getAttribute("perfil").equals("f")) {
				out.print("Administrador");
			} else {
				out.print("Atendente");
			}%>
		</span>
	</div>	
	<div class="logado">
		<a href="comunicacao.jsp" style="color: #FFFFFF !important"><img src="../image/logados.png"/></a>
	</div>
	<div class="logado">		
		<label class="headerCounter"><%=": " + Util.zeroToLeft(String.valueOf(UserCounter.getUserOnline()), 2)%></label>
	</div>
	<div id="clockContent">
		<label id="dateClock" name="dateClock" class="headerContent" style="margin-right: 13px"><%Date momentoAtual = new Date(); out.print(Util.parseDate(momentoAtual, "EEEE, dd MMMM yyyy"));%></label>
		<label id="dateClock" name="dateClock" class="headerContent" >Hora: </label>
		<label id="clock" name="clock" class="headerContent"></label>
	</div>
	<div class="logado">
		<a class="sair" href="../Termination" >Sair</a>
	</div>	
</div>
