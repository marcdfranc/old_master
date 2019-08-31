package com.marcsoftware.database;

import java.io.Serializable;

public class ParcelaPedidoId implements Serializable {
	private Pedido pedido;
	private Lancamento lancamento;
	
	public ParcelaPedidoId() {
		
	}

	public Pedido getPedido() {
		return this.pedido;
	}

	public void setPedido(Pedido pedido) {
		this.pedido = pedido;
	}

	public Lancamento getLancamento() {
		return this.lancamento;
	}

	public void setLancamento(Lancamento lancamento) {
		this.lancamento = lancamento;
	}
	
	@Override
	public boolean equals(Object object) {
		if ((object == null) || !(object instanceof ParcelaPedidoId)) {
			return false;
		}
		ParcelaPedidoId novo= (ParcelaPedidoId) object;
		
		if ((!novo.getPedido().equals(this.pedido)) ||
				(!novo.getLancamento().equals(this.lancamento))) {
			return false;
		}		
		return true;
	}
	
	@Override
	public int hashCode() {		 
		return this.lancamento.hashCode();
	}
}
