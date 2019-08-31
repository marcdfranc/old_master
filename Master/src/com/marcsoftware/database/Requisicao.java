package com.marcsoftware.database;

import java.util.Date;

public class Requisicao {
	private long codigo;
	private double kmSaida, kmChegada;
	private Date dataSaida, dataChegada;
	private String horaSaida, horaChegada;
	private Veiculo veiculo;
	private Funcionario funcionario;
	
	public Requisicao() {
		
	}
	
	public long getCodigo() {
		return codigo;
	}
	
	public void setCodigo(long codigo) {
		this.codigo = codigo;
	}
	
	public double getKmSaida() {
		return kmSaida;
	}
	
	public void setKmSaida(double kmSaida) {
		this.kmSaida = kmSaida;
	}
	
	public double getKmChegada() {
		return kmChegada;
	}
	
	public void setKmChegada(double kmChegada) {
		this.kmChegada = kmChegada;
	}
	
	public Date getDataSaida() {
		return dataSaida;
	}
	
	public void setDataSaida(Date dataSaida) {
		this.dataSaida = dataSaida;
	}
	
	public Date getDataChegada() {
		return dataChegada;
	}
	
	public void setDataChegada(Date dataChegada) {
		this.dataChegada = dataChegada;
	}
	
	public String getHoraSaida() {
		return horaSaida;
	}
	
	public void setHoraSaida(String horaSaida) {
		this.horaSaida = horaSaida;
	}
	
	public String getHoraChegada() {
		return horaChegada;
	}
	
	public void setHoraChegada(String horaChegada) {
		this.horaChegada = horaChegada;
	}
	
	public Veiculo getVeiculo() {
		return veiculo;
	}
	
	public void setVeiculo(Veiculo veiculo) {
		this.veiculo = veiculo;
	}
	
	public Funcionario getFuncionario() {
		return funcionario;
	}
	
	public void setFuncionario(Funcionario funcionario) {
		this.funcionario = funcionario;
	}
}
