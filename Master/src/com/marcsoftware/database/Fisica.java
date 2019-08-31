package com.marcsoftware.database;

import java.util.Date;

public class Fisica extends Pessoa {	
	private String nome;
	private String rg;
	private String cpf;
	private String estadoCivil;
	private String naturalidade;
	private String nacionalidade;
	private String naturalidadeUf;
	private String isAdm; 
	private String sexo;
	private Date nascimento;
	
	public Fisica() {
		
	}
	
	public String getRg() {
		return rg;
	}
	
	public void setRg(String rg) {
		this.rg = rg;
	}
	
	public String getCpf() {
		return cpf;
	}
	
	public void setCpf(String cpf) {
		this.cpf = cpf;
	}

	public String getNome() {
		return nome;
	}

	public void setNome(String nome) {
		this.nome = nome;
	}

	public String getEstadoCivil() {
		return estadoCivil;
	}

	public void setEstadoCivil(String estadoCivil) {
		this.estadoCivil = estadoCivil;
	}

	public String getNaturalidade() {
		return naturalidade;
	}

	public void setNaturalidade(String naturalidade) {
		this.naturalidade = naturalidade;
	}

	public String getNacionalidade() {
		return nacionalidade;
	}

	public void setNacionalidade(String nacionalidade) {
		this.nacionalidade = nacionalidade;
	}

	public String getNaturalidadeUf() {
		return naturalidadeUf;
	}

	public void setNaturalidadeUf(String naturalidadeUf) {
		this.naturalidadeUf = naturalidadeUf;
	}

	public String getSexo() {
		return sexo;
	}

	public void setSexo(String sexo) {
		this.sexo = sexo;
	}

	public Date getNascimento() {
		return nascimento;
	}

	public void setNascimento(Date nascimento) {
		this.nascimento = nascimento;
	}

	public String getIsAdm() {
		return isAdm;
	}

	public void setIsAdm(String isAdm) {
		this.isAdm = isAdm;
	}
	
	public boolean isAdm() {
		return (this.isAdm == "t");
	}
}
