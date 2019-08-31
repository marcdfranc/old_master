package com.marcsoftware.database;

import java.io.Serializable;

public class ItensConciliacaoId implements Serializable {
	private Lancamento lancamento;
	private Conciliacao conciliacao;
	
	public ItensConciliacaoId() {
		
	}
	
	public Lancamento getLancamento() {
		return lancamento;
	}
	
	public void setLancamento(Lancamento lancamento) {
		this.lancamento = lancamento;
	}
	
	public Conciliacao getConciliacao() {
		return conciliacao;
	}
	
	public void setConciliacao(Conciliacao conciliacao) {
		this.conciliacao = conciliacao;
	}
	
	@Override
	public boolean equals(Object object) {
		if ((object == null) || !(object instanceof ItensCompraId)) {
			return false;		
		} 
		ItensConciliacaoId novo= (ItensConciliacaoId) object;
		
		if ((!novo.getLancamento().equals(this.lancamento)) || 
				(!novo.getConciliacao().equals(this.conciliacao))) {
			return false;
		}
		return true;
	}
	
	
	@Override
	public int hashCode() {
		return this.lancamento.hashCode();
	}
}
