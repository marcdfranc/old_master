package com.marcsoftware.database;

public class Cep2005 {
	private Long codigo;
	private int cep;
	private String ruaAv, bairro, cidade, uf;
	
	public Long getCodigo() {
		return codigo;
	}
	
	public void setCodigo(Long codigo) {
		this.codigo = codigo;
	}
	
	public int getCep() {
		return cep;
	}
	
	public void setCep(int cep) {
		this.cep = cep;
	}
	
	public String getRuaAv() {
		return ruaAv;
	}
	
	public void setRuaAv(String ruaAv) {
		this.ruaAv = ruaAv;
	}
	
	public String getBairro() {
		return bairro;
	}
	
	public void setBairro(String bairro) {
		this.bairro = bairro;
	}
	
	public String getCidade() {
		return cidade;
	}
	
	public void setCidade(String cidade) {
		this.cidade = cidade;
	}
	
	public String getUf() {
		return uf;
	}
	
	public void setUf(String uf) {
		this.uf = uf;
	}	
}
