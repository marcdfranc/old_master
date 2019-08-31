package com.marcsoftware.database;

public class ItensVendedor {
	private ItensVendedorId id;
	private Long newCodigo;
	
	public ItensVendedor() {
		
	}

	public ItensVendedorId getId() {
		return id;
	}

	public void setId(ItensVendedorId id) {
		this.id = id;
	}

	public Long getNewCodigo() {
		return newCodigo;
	}

	public void setNewCodigo(Long newCodigo) {
		this.newCodigo = newCodigo;
	}
}
