package com.marcsoftware.database;

public class EmpresaSaude extends Juridica {
	private String responsavel, conselhoResponsavel, contato, cargoContato; 
	private Ramo ramo;
	private Especialidade especialidade;
	
	public EmpresaSaude() {
		
	}

	public String getResponsavel() {
		return responsavel;
	}

	public void setResponsavel(String responsavel) {
		this.responsavel = responsavel;
	}

	public String getConselhoResponsavel() {
		return conselhoResponsavel;
	}

	public void setConselhoResponsavel(String conselhoResponsavel) {
		this.conselhoResponsavel = conselhoResponsavel;
	}

	public String getContato() {
		return contato;
	}

	public void setContato(String contato) {
		this.contato = contato;
	}

	public String getCargoContato() {
		return cargoContato;
	}

	public void setCargoContato(String cargoContato) {
		this.cargoContato = cargoContato;
	}

	public Ramo getRamo() {
		return ramo;
	}

	public void setRamo(Ramo ramo) {
		this.ramo = ramo;
	}

	public Especialidade getEspecialidade() {
		return especialidade;
	}

	public void setEspecialidade(Especialidade especialidade) {
		this.especialidade = especialidade;
	}
}
