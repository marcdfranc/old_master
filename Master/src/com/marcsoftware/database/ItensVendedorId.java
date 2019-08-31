package com.marcsoftware.database;

import java.io.Serializable;

public class ItensVendedorId implements Serializable {
	private FaturaVendedor faturaVendedor;
	private Contrato contrato;
	
	public ItensVendedorId() {
		
	}
		
	public FaturaVendedor getFaturaVendedor() {
		return faturaVendedor;
	}
	
	public void setFaturaVendedor(FaturaVendedor faturaVendedor) {
		this.faturaVendedor = faturaVendedor;
	}
	
	public Contrato getContrato() {
		return contrato;
	}
	
	public void setContrato(Contrato contrato) {
		this.contrato = contrato;
	}
	
	@Override
	public boolean equals(Object object) {
		if (object == null || !(object instanceof ItensVendedorId)) { 
			return false; 
		} 
		
		ItensVendedorId novo = (ItensVendedorId) object; 
		
		if ((!novo.getContrato().equals(this.contrato)) || 
					(!novo.getFaturaVendedor().equals(this.faturaVendedor))) {
			return false; 
		}
		return true;
	}
	
	@Override
	public int hashCode() {
		return (int) this.faturaVendedor.hashCode();
	}
}
