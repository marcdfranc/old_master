package com.marcsoftware.database;

import java.io.Serializable;

public class ItensCompraId implements Serializable {
	private Compra compra;
	private Insumo insumo;
	
	public ItensCompraId() {
		
	}

	public Compra getCompra() {
		return compra;
	}

	public void setCompra(Compra compra) {
		this.compra = compra;
	}

	public Insumo getInsumo() {
		return insumo;
	}

	public void setInsumo(Insumo insumo) {
		this.insumo = insumo;
	}
	
	@Override
	public boolean equals(Object object) {
		if ((object == null) || !(object instanceof ItensCompraId)) {
			return false;		
		} 
		ItensCompraId novo= (ItensCompraId) object;
		
		if ((!novo.getCompra().equals(this.compra)) || 
				(!novo.getInsumo().equals(this.insumo))) {
			return false;
		}
		return true;
	}
	
	
	@Override
	public int hashCode() {
		return this.compra.hashCode();
	}
}
