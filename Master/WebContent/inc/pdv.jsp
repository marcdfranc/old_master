<%@page import="com.marcsoftware.utilities.Util"%>
<%@page import="com.marcsoftware.database.FormaPagamento"%>
<%@page import="java.util.List"%>
<%@page import="com.marcsoftware.utilities.HibernateUtil"%>
<%@page import="org.hibernate.Session"%>
<%@page import="org.hibernate.Query"%>
<%
Query query;
Session sess = (Session) session.getAttribute("hb");
if (!sess.isOpen()) {
	sess = HibernateUtil.getSession();
}
query = sess.createQuery("from FormaPagamento as f order by f.descricao");
List<FormaPagamento> pagamentoList = (List<FormaPagamento>) query.list();
String tpPagamento = "";
String pagId = "2";
if (pagamentoList.size() > 0) {
	for(int i = 0; i < pagamentoList.size(); i++) {
		tpPagamento+= (i == 0)? pagamentoList.get(i).getCodigo() + "@" +
				pagamentoList.get(i).getDescricao() + "@" + pagamentoList.get(i).getConcilia() 
				: "|" +	pagamentoList.get(i).getCodigo() + "@" + 
				pagamentoList.get(i).getDescricao() + "@" + 
				pagamentoList.get(i).getConcilia();
	}
}
%>
<div id="conciliaWindow" class="removeBorda" title="Vendas" style="display: none;">			
	<form id="formPagamento" onsubmit="return false;">
		<div class="conteiner-left" style="width: 300px">
			<input type="hidden" name="dtEmit" id="dtEmit" class="textDialog ui-widget-content ui-corner-all" readonly="readonly" value="<%= Util.getToday() %>" />
			<label for="vlrTotal">Valor Atual</label>
			<input type="text" name="vlrTotal" id="vlrTotal" class="textDialog ui-widget-content ui-corner-all" readonly="readonly" style="height: 35px; font-size: 30px; color: #007CC3" />
			<div style="float: left; margin-top: 10px; width: 240px; margin-bottom: 15px; ">
				<input type="checkbox" id="impCupon" name="impCupon" checked="checked" onchange="atualizaTotal()"/>
				<label for="impCupon" >Emitir Cupom</label>
			</div><br clear="all" />
			<label for="tpPagamento" style="width: 100%">Pagamento</label><br/>
			<select id="tpPagamento" style="width: 100%" onchange="adjustPagamento(this)">
				<%if (pagamentoList.size() > 0) {
					for(FormaPagamento pagamento : pagamentoList) {
						if (pagamento.getCodigo() == new Long(2)) {%>
							<option value="<%= pagamento.getCodigo() + "@" + pagamento.getConcilia()%>" selected="selected" ><%= pagamento.getDescricao()%> </option>
						<%} else {%>
							<option value="<%= pagamento.getCodigo() + "@" + pagamento.getConcilia()%>" ><%= pagamento.getDescricao()%> </option>
						<%}%>
					<%}						
				} else {%>
					<option value="">Selecione</option>
				<%}%>
			</select><br/>				
			<div id="blocoShow" class="cpEscondeWithHeight">
				<label for="numConcilio">Nº de controle</label>
				<input type="text" name="numConcilio" id="numConcilio" class="textDialog ui-widget-content ui-corner-all"  />
				<label for="dtVenc">Vencimento</label>
				<input type="text" name="dtVenc" id="dtVenc" class="textDialog ui-widget-content ui-corner-all" onkeydown="mask(this, dateType);" onblur="atualizaTotal()"/>
			</div>
			<label for="aPagar">Valor a Pagar</label>
			<input type="text" name="aPagar" id="aPagar" class="textDialog ui-widget-content ui-corner-all" readonly="readonly" value="0.00" style="height: 35px; font-size: 30px; color: #007CC3" />
			<label for="money">Dinheiro</label>
			<input type="text" name="money" id="money" class="textDialog ui-widget-content ui-corner-all" value="0.00" onkeydown="mask(this, decimalNumber);" onblur="getTroco()" style="height: 35px; font-size: 30px; color: #666666;"/>
			<label for="troco">Troco</label>
			<input type="text" name="troco" id="troco" class="textDialog ui-widget-content ui-corner-all" readonly="readonly" value="0.00" style="height: 35px; font-size: 30px; color: #007CC3"/>
		</div>
		<div class="conteiner-right">
			<textarea rows="19" cols="70" readonly="readonly"></textarea>
		</div>
	</form>
</div>