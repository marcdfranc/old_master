package com.marcsoftware.database;

public class ItensBordero {
	private ItensBorderoId id;
	private Lancamento operacional;
	
	public ItensBordero() {
		
	}
	
	public ItensBorderoId getId() {
		return id;
	}
	
	public void setId(ItensBorderoId id) {
		this.id = id;
	}
	
	public Lancamento getOperacional() {
		return operacional;
	}
	
	public void setOperacional(Lancamento operacional) {
		this.operacional = operacional;
	}
}
