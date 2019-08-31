package com.marcsoftware.database;

public class Permissao { 	
	private PermissaoId id;
	private String acesso;
	
	public Permissao() {
		
	}
	
	public PermissaoId getId() {
		return id;
	}

	public void setId(PermissaoId id) {
		this.id = id;
	}

	public String getAcesso() {
		return acesso;
	}

	public void setAcesso(String acesso) {
		this.acesso = acesso;
	}
}
