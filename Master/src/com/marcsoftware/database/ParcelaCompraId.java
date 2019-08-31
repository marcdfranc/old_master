package com.marcsoftware.database;

import java.io.Serializable;

public class ParcelaCompraId implements Serializable {
	private Compra compra;
	private Lancamento lancamento;
	
	public ParcelaCompraId() {
		
	}

	public Compra getCompra() {
		return compra;
	}

	public void setCompra(Compra compra) {
		this.compra = compra;
	}

	public Lancamento getLancamento() {
		return lancamento;
	}

	public void setLancamento(Lancamento lancamento) {
		this.lancamento = lancamento;
	}
	
	@Override
	public boolean equals(Object object) {
		if ((object == null) || !(object instanceof ParcelaCompraId)) {
			return false;
		}
		ParcelaCompraId novo= (ParcelaCompraId) object;
		
		if ((!novo.getCompra().equals(this.compra)) ||
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
