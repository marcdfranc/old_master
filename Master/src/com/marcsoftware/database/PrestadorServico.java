package com.marcsoftware.database;

public class PrestadorServico extends Fisica {
	private Ramo ramo;
	
	public PrestadorServico() {
		
	}

	public Ramo getRamo() {
		return ramo;
	}

	public void setRamo(Ramo ramo) {
		this.ramo = ramo;
	}
}
