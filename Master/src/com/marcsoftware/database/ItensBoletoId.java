package com.marcsoftware.database;

import java.io.Serializable;

public class ItensBoletoId implements Serializable {
	private Boleto boleto;
	private Lancamento lancamento;
	
	public ItensBoletoId() {
		// TODO Auto-generated constructor stub
	}

	public Boleto getBoleto() {
		return boleto;
	}

	public void setBoleto(Boleto boleto) {
		this.boleto = boleto;
	}

	public Lancamento getLancamento() {
		return lancamento;
	}

	public void setLancamento(Lancamento lancamento) {
		this.lancamento = lancamento;
	}
	
	@Override
	public boolean equals(Object object) {
		if ((object == null) || !(object instanceof ItensBoletoId)) {
			return false;
		} 
		ItensBoletoId novo= (ItensBoletoId) object;
		
		if ((!novo.getBoleto().equals(this.boleto)) || 
				(!novo.getLancamento().equals(this.lancamento))) {
			return false;
		}
		return true;
	}
	
	@Override
	public int hashCode() {		
		return this.boleto.hashCode();
	}
}
