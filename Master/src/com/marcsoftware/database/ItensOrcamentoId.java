package com.marcsoftware.database;

import java.io.Serializable;


public class ItensOrcamentoId implements Serializable {
	private Orcamento orcamento;
	private long sequencial;
	
	public ItensOrcamentoId() {
		
	}

	public Orcamento getOrcamento() {
		return orcamento;
	}

	public void setOrcamento(Orcamento orcamento) {
		this.orcamento = orcamento;
	}	
	
	public long getSequencial() {
		return sequencial;
	}

	public void setSequencial(long sequencial) {
		this.sequencial = sequencial;
	}

	public boolean equals(Object object) {
		if ((object == null) || !(object instanceof PlanoServicoId)) {
			return false;		
		} 
		ItensOrcamentoId novo= (ItensOrcamentoId) object;
		
		if ((novo.getSequencial() != this.sequencial) || 
				(!novo.getOrcamento().equals(this.orcamento))) {
			return false;
		}	
		return true;
	}
	
	
	public int hashCode() {		
		return this.orcamento.hashCode();
	}	
}
