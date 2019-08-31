package com.marcsoftware.database;

import java.io.Serializable;

public class ItensPedidoId implements Serializable {
	private Pedido pedido;
	private Produto produto;
	
	public ItensPedidoId() {
		
	}

	public Pedido getPedido() {
		return this.pedido;
	}

	public void setPedido(Pedido pedido) {
		this.pedido = pedido;
	}

	public Produto getProduto() {
		return this.produto;
	}

	public void setProduto(Produto produto) {
		this.produto = produto;
	}
	
	@Override
	public boolean equals(Object object) {
		if ((object == null) || !(object instanceof ItensPedidoId)) {
			return false;
		}
		ItensPedidoId novo= (ItensPedidoId) object;
		
		if ((!novo.getPedido().equals(this.pedido)) ||
				(!novo.getProduto().equals(this.produto))) {
			return false;
		}		
		return true;
	}
	
	@Override
	public int hashCode() {		 
		return this.produto.hashCode();
	}
}
