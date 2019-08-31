package com.marcsoftware.database;

public class PlanoServico {
	private PlanoServicoId id;
	private int qtde;
	
	public PlanoServico() {
		
	}

	public PlanoServicoId getId() {
		return id;
	}

	public void setId(PlanoServicoId id) {
		this.id = id;
	}

	public int getQtde() {
		return qtde;
	}

	public void setQtde(int qtde) {
		this.qtde = qtde;
	}
}
