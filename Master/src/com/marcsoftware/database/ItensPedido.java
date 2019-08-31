package com.marcsoftware.database;

import java.io.Serializable;

public class ItensPedido {
	private ItensPedidoId id;
	private int qtde;
	
	public ItensPedido() {
		// TODO Auto-generated constructor stub
	}

	public ItensPedidoId getId() {
		return id;
	}

	public void setId(ItensPedidoId id) {
		this.id = id;
	}

	public int getQtde() {
		return qtde;
	}

	public void setQtde(int qtde) {
		this.qtde = qtde;
	}

	
}
