package com.marcsoftware.database;

public class Profissional extends Fisica {
	private String conselho;
	private Especialidade especialidade;
	
	public Profissional() {
		
	}
	
	public String getConselho() {
		return conselho;
	}
	
	public void setConselho(String conselho) {
		this.conselho = conselho;
	}
	
	public Especialidade getEspecialidade() {
		return especialidade;
	}
	
	public void setEspecialidade(Especialidade especialidade) {
		this.especialidade = especialidade;
	}
}
