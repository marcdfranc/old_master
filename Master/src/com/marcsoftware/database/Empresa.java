package com.marcsoftware.database;

public class Empresa extends Juridica {
	private String contato, cargoContato;
	private Funcionario funcionario;
	private Ramo ramo;
	private double saldoAcumulado;
	
	public Empresa() {
		
	}

	public Ramo getRamo() {
		return ramo;
	}

	public void setRamo(Ramo ramo) {
		this.ramo = ramo;
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

	public Funcionario getFuncionario() {
		return funcionario;
	}

	public void setFuncionario(Funcionario funcionario) {
		this.funcionario = funcionario;
	}

	public double getSaldoAcumulado() {
		return saldoAcumulado;
	}

	public void setSaldoAcumulado(double saldoAcumulado) {
		this.saldoAcumulado = saldoAcumulado;
	}

}
