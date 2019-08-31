package com.marcsoftware.database;

import java.io.Serializable;

public class ItensBorderoId implements Serializable {
	
	private BorderoProfissional borderoProfissional;
	private Lancamento cliente;
	
	public ItensBorderoId() {
		
	}
	
	public BorderoProfissional getBorderoProfissional() {
		return borderoProfissional;
	}
	
	public void setBorderoProfissional(BorderoProfissional borderoProfissional) {
		this.borderoProfissional = borderoProfissional;
	}
	
	public Lancamento getCliente() {
		return cliente;
	}
	
	public void setCliente(Lancamento lancamento) {
		this.cliente = lancamento;
	}
	
	@Override
	public boolean	equals(Object object) {
		if ((object == null) || !(object instanceof ItensBorderoId)) {
			return false;
		}
		
		ItensBorderoId novo = new ItensBorderoId();
		
		if ((!novo.getBorderoProfissional().equals(this.borderoProfissional)) || 
				(!novo.getCliente().equals(this.cliente))) {
			return false;
		}		
		return true;
	}
	
	@Override
	public int hashCode() {
		return this.borderoProfissional.hashCode();
	}
}
