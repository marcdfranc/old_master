package com.marcsoftware.database;

import java.io.Serializable;

public class ParcelaOrcamentoId implements Serializable {
	private Orcamento orcamento;
	private Lancamento lancamento;
	
	public ParcelaOrcamentoId() {
		
	}
	
	public Orcamento getOrcamento() {
		return orcamento;
	}

	public void setOrcamento(Orcamento orcamento) {
		this.orcamento = orcamento;
	}


	public Lancamento getLancamento() {
		return lancamento;
	}


	public void setLancamento(Lancamento lancamento) {
		this.lancamento = lancamento;
	}
	
	@Override
	public boolean equals(Object object) {
		if ((object== null) || !(object instanceof ParcelaOrcamentoId)) {
			return false;
		}
		ParcelaOrcamentoId novo = (ParcelaOrcamentoId) object;
		if ((!novo.getOrcamento().equals(this.orcamento)) || 
				(!novo.getLancamento().equals(this.lancamento))) {
			return false;
		}
		return true;
	}
	
	@Override
	public int hashCode() {	
		return this.lancamento.hashCode();
	}
}
