<%String currentPage = request.getParameter("currentPage");
	if (currentPage.equals("unidade")) {
		currentPage= "Unidades";
	} else if ((currentPage.equals("clienteF")) || (currentPage.equals("clienteJ"))) {
		currentPage= "Clientes";
	} else if (currentPage.equals("rh")) {
		currentPage= "RH";
	}	
%>
<div id="menu">
	<ul>
		<li>			
			<blockquote>
				<a class="<%=(currentPage.equals("forum"))? "lighterMenu" : "blueButtonStyle"%>" href="<%=(currentPage.trim().equals("financeiroBlk"))? "#" : "forum.jsp" %>" >Início</a>				
			</blockquote>
		</li>
		<li>							
			<blockquote id="popUpUnidade" >
				<a class="<%=(currentPage.equals("Unidades"))? "lighterMenu" : "blueButtonStyle"%>" href="<%=(currentPage.trim().equals("financeiroBlk"))? "#" : "unidade.jsp" %>" >Unidades</a>
			</blockquote>							
		</li>
		<li>							
			<blockquote id="popUpCliente" >
				<a class="<%=(currentPage.equals("Clientes"))? "lighterMenu" : "blueButtonStyle"%>"" href="<%=(currentPage.trim().equals("financeiroBlk"))? "#" : "cliente_fisico.jsp" %>">Clientes</a>								
			</blockquote>												
		</li>
		<li>
			<blockquote >
				<a class="<%=(currentPage.equals("orcamento") || currentPage.equals("produto"))? "lighterMenu" : "blueButtonStyle"%>"  href="<%=(currentPage.trim().equals("financeiroBlk"))? "#" : "orcamento.jsp?id=-1"%>">Orçamentos</a>
			</blockquote>
		</li>
			
		<li>
			<blockquote id="popUpProfissional" >
				<a class="<%=(currentPage.equals("profissional"))? "lighterMenu" : "blueButtonStyle"%>" href="<%=(currentPage.trim().equals("financeiroBlk"))? "#" : "profissionais.jsp"%>" >Profissionais</a>
			</blockquote>
		</li>
		<li>
			<blockquote >
				<a class="<%=(currentPage.equals("servico"))? "lighterMenu" : "blueButtonStyle"%>"  href="<%=(currentPage.trim().equals("financeiroBlk"))? "#" : "plano.jsp"%>" >Planos</a>
			</blockquote>
		</li>
		<li>
			<blockquote>
				<a class="<%=(currentPage.equals("RH"))? "lighterMenu" : "blueButtonStyle"%>"  href="<%=(currentPage.trim().equals("financeiroBlk"))? "#" : "funcionario.jsp"%>" >RH</a>
			</blockquote>
		</li>		
		<li>			
			<blockquote>				
				<a class="<%=(currentPage.equals("fornecedor") || currentPage.equals("prestador"))? "lighterMenu" : "blueButtonStyle"%>"  href="compra.jsp?origem=forn&idFornecedor=0" >Fornecedores</a>				
			</blockquote>
		</li>
		<li>
			<blockquote>
				<a class="<%=(currentPage.equals("financeiro"))? "lighterMenu" : "blueButtonStyle"%>" href="<%=(currentPage.trim().equals("financeiroBlk"))? "#" : "caixa.jsp"%>" >Financeiro</a>
			</blockquote>
		</li>
		<li>
			<%if(request.getSession().getAttribute("perfil").toString().trim().equals("a")) {%>
				<blockquote >
					<a class="<%=(currentPage.equals("adm"))? "lighterMenu" : "blueButtonStyle"%>"  href="adm.jsp" >ADM</a>
				</blockquote>
			<%} else {%>
				<blockquote >
					<a class="<%=(currentPage.equals("adm"))? "lighterMenu" : "blueButtonStyle"%>"  href="#" >ADM</a>
				</blockquote>
			<%}%>
		</li>
		<%
		if(request.getSession().getAttribute("perfil").toString().trim().equals("d")) {%>
			<li>
				<blockquote>
					<a class="<%=(currentPage.equals("rel"))? "lighterMenu" : "blueButtonStyle"%>"  href="relatorio_adm.jsp" >Rel. Admin</a>
				</blockquote>
			</li>
		<%}%>				
	</ul>
</div>
