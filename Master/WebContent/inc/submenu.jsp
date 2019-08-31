<%
	int iten= 0;
	ArrayList<String> hrefs = new ArrayList<String>();
	ArrayList<String> label= new ArrayList<String>();
	String currentPage = request.getParameter("currentPage"); 
	if( currentPage.equals("unidade")) {
		label.add("Home");
		hrefs.add("unidade.jsp");
		if (session.getAttribute("perfil").toString().trim().equals("a")
				|| session.getAttribute("perfil").toString().trim().equals("d")) {
			label.add("Novo");			
			hrefs.add("cadastro_unidade.jsp");
		}
		if (session.getAttribute("perfil").toString().trim().equals("a")
				|| session.getAttribute("perfil").toString().trim().equals("d")) {
			label.add("Nova tabela");
			hrefs.add("cadastro_tabela_franchising.jsp");
			label.add("tabela");
			hrefs.add("tabela_franchising.jsp");			
		} else {
			label.add("Nova tabela");
			hrefs.add("#");
			label.add("tabela");
			hrefs.add("#");
		}
		label.add("Quadro");
		hrefs.add("#");
		label.add("Inventário");
		hrefs.add("#");
		label.add("Borderô");
		hrefs.add("#");
		label.add("Requisições");
		hrefs.add("#");
		label.add("Solicitações");
		hrefs.add("#");
		label.add("Frota");
		hrefs.add("#");
		label.add("CFTV");		
		hrefs.add("#");
		label.add("Alarme");
		hrefs.add("#");
		label.add("Relatório");
		hrefs.add("#");
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	} else if(currentPage.equals("clienteF")) {
		label.add("Home");		
		hrefs.add("cliente_fisico.jsp");
		label.add("Novo");
		hrefs.add("cadastro_cliente_fisico.jsp");
		label.add("Baixa Manual");
		hrefs.add("baixa_manual.jsp");		
		label.add("Consulta SPC");
		hrefs.add("#");
		label.add("Relatório");
		hrefs.add("#");
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	} else if(currentPage.equals("clienteJ")) {
		label.add("Home");
		hrefs.add("empresa.jsp");
		label.add("Novo");
		hrefs.add("cadastro_cliente_juridico.jsp");
		//label.add("Faturas");
		//hrefs.add("fatura_empresa.jsp?id=-1");
		if (session.getAttribute("perfil").toString().trim().equals("a")
				|| session.getAttribute("perfil").toString().trim().equals("d")) {
			label.add("Ramo");
			hrefs.add("ramo.jsp");
		}
		label.add("Borderô");
		hrefs.add("lancamento_empresa.jsp");		
		label.add("Relatório");
		hrefs.add("#");
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	} else if(currentPage.equals("rh")){
		hrefs.add("funcionario.jsp");
		label.add("Home");
		hrefs.add("cadastro_funcionario.jsp");
		label.add("Novo");
		//hrefs.add("fatura_vendedor.jsp");
		//label.add("Faturas");
		if (session.getAttribute("perfil").toString().trim().equals("a")
				|| session.getAttribute("perfil").toString().trim().equals("d")) {
			hrefs.add("posicao.jsp");		
			label.add("Posição");
		}
		//hrefs.add("encargo.jsp");
		//label.add("Encargo");
		hrefs.add("lancamento_funcionario.jsp");
		label.add("Borderô");
		hrefs.add("#");
		label.add("Relatório");
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	} else if(currentPage.equals("financeiro")) {
		label.add("Caixa");
		hrefs.add("caixa.jsp");
		label.add("Lançar Conta");
		hrefs.add("cadastro_lancamento.jsp");
		if (request.getSession().getAttribute("perfil").toString().trim().equals("a")				
				|| request.getSession().getAttribute("perfil").toString().trim().equals("d")) {
			label.add("Painel");
			hrefs.add("painel_financ.jsp");
		}
		if (request.getSession().getAttribute("perfil").toString().trim().equals("a")
				|| request.getSession().getAttribute("perfil").toString().trim().equals("f")
				|| request.getSession().getAttribute("perfil").toString().trim().equals("d")) {
			label.add("Conta Corrente");
			hrefs.add("conta_corrente.jsp");
			label.add("Lançamentos");
			hrefs.add("lancamento.jsp");
			label.add("Carteira ADM");
			hrefs.add("custo_operacional.jsp");
		}
		label.add("Cobrança");
		if (session.getAttribute("perfil").toString().trim().equals("a")
				|| session.getAttribute("perfil").toString().trim().equals("f")) {			
			hrefs.add("painel_cobranca.jsp?origem=fin");
		} else {
			hrefs.add("cobranca_c1.jsp?dias=30&origem=fin");
		}
		if (request.getSession().getAttribute("perfil").toString().trim().equals("a")
				|| request.getSession().getAttribute("perfil").toString().trim().equals("f")
				|| request.getSession().getAttribute("perfil").toString().trim().equals("d")) {
			label.add("Cobrança Aut.");
			hrefs.add("cobranca_automatica.jsp");			
		}
		
		label.add("Conciliação");
		hrefs.add("conciliacao.jsp");
		if (request.getSession().getAttribute("perfil").toString().trim().equals("a")
				|| request.getSession().getAttribute("perfil").toString().trim().equals("f")
				|| request.getSession().getAttribute("perfil").toString().trim().equals("d")) {
			label.add("Receber");
			hrefs.add("conta_receber.jsp");
			label.add("Pagar");
			hrefs.add("conta_pagar.jsp");
		}
		if (request.getSession().getAttribute("perfil").toString().trim().equals("a")
				|| request.getSession().getAttribute("perfil").toString().trim().equals("d")){
			hrefs.add("bancos.jsp");
			label.add("Bancos");
			hrefs.add("forma_pagamento.jsp");
			label.add("Forma Pag.");
			hrefs.add("cadastro_tipo_conta.jsp");
			label.add("Tipos de Conta");
		}
		hrefs.add("#");		
		label.add("Relatório");
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	} else if(currentPage.equals("financeiroBlk")) {
		hrefs.add("#");
		hrefs.add("#");
		hrefs.add("#");
		hrefs.add("#");
		hrefs.add("#");
		hrefs.add("#");
		hrefs.add("#");
		hrefs.add("#");
		hrefs.add("#");
		hrefs.add("#");
		hrefs.add("#");
		hrefs.add("#");
		label.add("Home");
		label.add("Bancos");
		label.add("Tipos de Conta");
		label.add("Lançamentos");
		label.add("Conta Corrente");
		label.add("Lançar Conta");
		label.add("Caixa");
		label.add("Carteira ADM");
		label.add("Forma Pag.");
		label.add("Receber");
		label.add("Pagar");
		label.add("Relatorio");
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	}	else if(currentPage.equals("profissional")) {
		hrefs.add("profissionais.jsp");
		label.add("Home");
		hrefs.add("cadastro_profissional.jsp");
		label.add("Novo");
		if (session.getAttribute("perfil").toString().trim().equals("a")
				|| session.getAttribute("perfil").toString().trim().equals("d")) {
			hrefs.add("especialidade.jsp?origem=prof");
			label.add("Especialidades");
		}
		hrefs.add("lancamento_profissional.jsp?tp=p");
		label.add("Borderô");
		hrefs.add("relatorio_profissional.jsp");
		label.add("Relatório");
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	} else if(currentPage.equals("servico")) {
		hrefs.add("plano.jsp");
		label.add("Planos");
		hrefs.add("servico.jsp");		
		label.add("Procedimentos");
		if (session.getAttribute("perfil").toString().trim().equals("a")
				|| session.getAttribute("perfil").toString().trim().equals("d")) {
			hrefs.add("cadastro_servico.jsp");
			label.add("Novo");
			hrefs.add("especialidade.jsp?origem=serv");
			label.add("Especialidades");
		}
		hrefs.add("tabela_vigencia.jsp");
		label.add("Hist. Tabelas");
		hrefs.add("tabela.jsp");
		label.add("Tabela de Vlr.");
		if (session.getAttribute("perfil").toString().trim().equals("a")
				|| session.getAttribute("perfil").toString().trim().equals("d")
				|| session.getAttribute("perfil").toString().trim().equals("f")) {
			hrefs.add("cadastro_tabela.jsp");
			label.add("Edição de Vlr.");			
		}
		hrefs.add("relatorio_profissional.jsp");
		label.add("Relatório");
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	} else if (currentPage.equals("orcamento")) {
		label.add("Home");
		hrefs.add("orcamento.jsp?id=-1");
		label.add("Novo");		
		hrefs.add("cadastro_orcamento.jsp");
		label.add("Relatório");
		hrefs.add("#");
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	} else if (currentPage.equals("orcamentoEmp")) {	
		label.add("Home");
		hrefs.add("orcamento_empresa.jsp?id=-1");
		label.add("Novo");		
		hrefs.add("cadastro_orcamento_emp.jsp");
		label.add("Relatório");
		hrefs.add("#");
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	} else if (currentPage.equals("rel")) {
		label.add("Home");
		hrefs.add("relatorio_adm.jsp?id=-1");
		label.add("Novo Relatório");
		hrefs.add("cadastro_relatorio.jsp"); 
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	} else if (currentPage.equals("fornecedor")) {
		label.add("Home");
		hrefs.add("compra.jsp?origem=forn&idFornecedor=0");
		
		label.add("Fornecedores");
		hrefs.add("fornecedor.jsp");
		
		label.add("Novo Fornec.");
		hrefs.add("cadastro_fornecedor.jsp");
		
		label.add("Prod. Serv.");
		hrefs.add("insumo.jsp?origem=forn");
		
		label.add("Estoque");
		hrefs.add("estoque.jsp");
		
		label.add("PDV");
		hrefs.add("javascript:mostraPDV()");
		
		
		label.add("Faturas");
		hrefs.add("agrupamento.jsp?origem=forn&idFornecedor=0");
		
		label.add("Borderô");
		hrefs.add("bordero_fornecedor.jsp?origem=forn&idFornecedor=0");
		
		label.add("Relatório");
		hrefs.add("#");
		
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	} else if (currentPage.equals("prestador")) {
		label.add("Home");
		hrefs.add("prestador_servico.jsp");
		label.add("Novo");
		hrefs.add("cadastro_prestador_servico.jsp");
		label.add("Insumo");		
		hrefs.add("insumo.jsp?origem=prest");
		label.add("Pedidos");
		hrefs.add("compra.jsp?origem=prest&idFornecedor=0");
		label.add("Faturas");
		hrefs.add("agrupamento.jsp?origem=prest&idFornecedor=0");
		label.add("Borderô");
		hrefs.add("bordero_fornecedor.jsp?origem=prest&idFornecedor=0");
		label.add("Relatório");
		hrefs.add("#");
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	} else if (currentPage.equals("empSaude")) {
		label.add("Home");
		hrefs.add("empresa_saude.jsp");
		label.add("Novo");
		hrefs.add("cadastro_empresa_saude.jsp");
		label.add("Borderô");
		hrefs.add("lancamento_profissional.jsp?tp=e");
		label.add("Relatório");
		hrefs.add("relatorio_profissional.jsp");
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	} else if (currentPage.equals("forum")) {
		label.add("Home");
		hrefs.add("forum.jsp");
		label.add("Perfil");
		hrefs.add("#");
		label.add("Agenda");
		//hrefs.add("#");
		//hrefs.add("teste_novo_conteiner.jsp");
		//label.add("Agenda Telef.");
		hrefs.add("catalogo.jsp");
		//hrefs.add("#");
		if (session.getAttribute("perfil").toString().trim().equals("a")
				|| session.getAttribute("perfil").toString().trim().equals("d")
				|| session.getAttribute("perfil").toString().trim().equals("f")) {
			label.add("Conexões");
			hrefs.add("painel_web_sys.jsp");
		}		
		label.add("Notificações");
		hrefs.add("notificacao.jsp");		
		label.add("E-mail");
		hrefs.add("#");
		label.add("forum");
		hrefs.add("#");
		label.add("Skype");
		hrefs.add("#");
		label.add("Messenger");
		hrefs.add("#");
		label.add("Calendário");
		hrefs.add("#");
		label.add("Ponto");
		hrefs.add("#");
		label.add("Rotina");
		hrefs.add("#");
		label.add("Disco Virtual");
		hrefs.add("#");
		label.add("Ajuda");
		hrefs.add("#");
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	} else if (currentPage.equals("adm")) {
		label.add("Home");
		hrefs.add("adm.jsp");
		label.add("Novo");
		hrefs.add("cadastro_administrador.jsp");
		label.add("Relatorio");
		hrefs.add("relatorio_profissional.jsp?rel=" + currentPage);
		label.add("Novo Vídeo");
		hrefs.add("cadastro_video.jsp");
		label.add("Vídeos");
		hrefs.add("videos_edit.jsp");
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	} else if (currentPage.equals("produto")) {
		label.add("Home");
		hrefs.add("prduto.jsp");
		label.add("Pedido");
		hrefs.add("pedido.jsp");
		label.add("Novo Pedido");
		hrefs.add("cadastro_pedido.jsp");
		label.add("Relatorio");
		hrefs.add("#");
		label.add("Novo Vídeo");
		hrefs.add("cadastro_video.jsp");
		label.add("Vídeos");
		hrefs.add("videos_edit.jsp");
		label.add("Tutoriais");
		hrefs.add("videos.jsp?pag=" + currentPage);
	}
%>

<%@page import="java.util.ArrayList"%>
<img id="imgTopBox" src="../image/top_box.png" />
<script type="text/javascript">
	function MM_openBrWindow() {	
		var configuracao = "";	
		var end = "www.scpc.inf.br";
		var pagina="/cgi-bin/spcnweb";
		var programa="md000008.int";
		var imagem="/spcn/imagens/logosentrada/araraquara.jpg";
		var css = "/spcn/imagens/logosentrada/araraquara.css";
		var entidade = "14800";
		document.title = "Sophus - Consultas de Informações";
		var stringEnvio = "";
		stringEnvio = "https://" + end + pagina + "?HTML_PROGRAMA=" + programa;
		if (imagem != "") {
			stringEnvio += "&HTML_IMAGEM="+imagem;
		}
		if (css != "") {
			stringEnvio += "&HTML_CSS="+css;
		}
		if (entidade != "")	{
			stringEnvio += "&HTML_ENTIDADE="+entidade;
		}
		var top = (screen.height - 600)/2;
		var left= (screen.width - 800)/2;
		configuracao = 'width= 800, height= 600, top= ' + top + ', left= ' + left;
		window.open(stringEnvio,'',configuracao);
	}
</script>
<div class="boxMenu">
	<div id="boxMenuContent">
		<ul>
			<%
			for(int i= 0; i < hrefs.size(); i++) {
				if (label.get(i).equals("Relatorio")) {
					out.print("<li><a class=\"grayButtonStyle\" href=\"" +
						hrefs.get(i) + "\"><label>" +
						label.get(i) + "</label></a></li>");
				} else if (label.get(i).equals("Relatório")) {
					out.print("<li><a href=\"" + 
							"relatorio_profissional.jsp?rel=" + currentPage + "\"><label>" +
							label.get(i) + "</label></a></li>");							
				} else if (label.get(i).equals("Consulta SPC")) {
					out.print("<li><a href=\"jasvascript:MM_openBrWindow()\" \"><label>" +
							label.get(i) + "</label></a></li>");
				} else {
					out.print("<li><a href=\"" + 
					hrefs.get(i) + "\"><label>" +
					label.get(i) + "</label></a></li>");
				}
			}%>									
		</ul>
	</div>		
	<img id="imgBottonBox" src="../image/botton_box.png" />
</div>