package com.marcsoftware.database;

import java.io.Serializable;

public class PlanoServicoId implements Serializable {
	private Servico servico;
	private Plano plano;
	
	public PlanoServicoId() {
		
	}

	public Servico getServico() {
		return servico;
	}

	public void setServico(Servico servico) {
		this.servico = servico;
	}

	public Plano getPlano() {
		return plano;
	}

	public void setPlano(Plano plano) {
		this.plano = plano;
	}
	
	@Override
	public boolean equals(Object object) {
		if ((object == null) || !(object instanceof PlanoServicoId)) {
			return false;		
		} 
		PlanoServicoId novo= (PlanoServicoId) object;
		
		if ((!novo.getServico().equals(this.servico)) || 
				(!novo.getPlano().equals(this.plano))) {
			return false;
		}
		return true;
	}
	
	@Override
	public int hashCode() {
		return this.servico.hashCode();
	}	
}
