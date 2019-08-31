package com.marcsoftware.database;

import java.io.Serializable;

public class TabelaId implements Serializable {
	private Servico servico;
	private Unidade unidade;	
	
	public TabelaId() {
		
	}

	public Servico getServico() {
		return servico;
	}

	public void setServico(Servico servico) {
		this.servico = servico;
	}

	public Unidade getUnidade() {
		return unidade;
	}

	public void setUnidade(Unidade unidade) {
		this.unidade = unidade;
	}
	
	@Override
	public boolean equals(Object object) {
		if ((object == null) || !(object instanceof PlanoServicoId)) {
			return false;		
		} 
		TabelaId novo= (TabelaId) object;
		
		if ((!novo.getServico().equals(this.servico)) || 
				(!novo.getUnidade().equals(this.unidade))) {
			return false;
		}
		return true;
	}
	
	@Override
	public int hashCode() {		
		return this.servico.hashCode();
	}
}
