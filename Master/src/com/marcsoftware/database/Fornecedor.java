package com.marcsoftware.database;

public class Fornecedor extends Juridica {
	private Ramo ramo;
	private String contato, cargoContato;	
	
	public Fornecedor() {
		
	}
	
	public Ramo getRamo() {
		return ramo;
	}

	public void setRamo(Ramo ramo) {
		this.ramo = ramo;
	}

	public String getContato() {
		return contato;
	}

	public void setContato(String contato) {
		this.contato = contato;
	}

	public String getCargoContato() {
		return cargoContato;
	}

	public void setCargoContato(String cargoContato) {
		this.cargoContato = cargoContato;
	}
}
