package com.marcsoftware.database;

import java.io.Serializable;

public class ItensFaturaFranchisingId implements Serializable {		
	private FaturaFranchising fatura;
	private Lancamento lancamento;
	
	public ItensFaturaFranchisingId() {
		
	}

	public FaturaFranchising getFatura() {
		return fatura;
	}

	public void setFatura(FaturaFranchising fatura) {
		this.fatura = fatura;
	}

	public Lancamento getLancamento() {
		return lancamento;
	}

	public void setLancamento(Lancamento lancamento) {
		this.lancamento = lancamento;
	}
	
	@Override
	public boolean equals(Object object) {
		if ((object == null) || !(object instanceof ItensCompraId)) {
			return false;		
		} 
		ItensFaturaFranchisingId novo= (ItensFaturaFranchisingId) object;
		
		if ((!novo.getLancamento().equals(this.lancamento)) || 
				(!novo.getFatura().equals(this.fatura))) {
			return false;
		}
		return true;
	}
	
	
	@Override
	public int hashCode() {
		return this.lancamento.hashCode();
	}
}
