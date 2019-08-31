package com.marcsoftware.database;

public class ItensFolha {
	private long codigo;
	private Folha folha;
	private Encargo encargo;
	
	public ItensFolha() {
		
	}

	public long getCodigo() {
		return codigo;
	}

	public void setCodigo(long codigo) {
		this.codigo = codigo;
	}

	public Folha getFolha() {
		return folha;
	}

	public void setFolha(Folha folha) {
		this.folha = folha;
	}

	public Encargo getEncargo() {
		return encargo;
	}

	public void setEncargo(Encargo encargo) {
		this.encargo = encargo;
	}
}
