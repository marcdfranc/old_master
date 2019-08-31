package com.marcsoftware.database;

public class Endereco {
	private long codigo;
	private String ruaAv, numero, bairro, complemento, cidade, uf, cep;
	private Pessoa pessoa;	
	
	public Endereco() {
				
	}
	
	public long getCodigo() {
		return codigo;
	}
	
	public void setCodigo(long codigo) {
		this.codigo = codigo;
	}
	
	public String getRuaAv() {
		return ruaAv;
	}
	
	public void setRuaAv(String ruaAv) {
		this.ruaAv = ruaAv;
	}
	
	public String getNumero() {
		return numero;
	}
	
	public void setNumero(String numero) {
		this.numero = numero;
	}
	
	public String getBairro() {
		return bairro;
	}
	
	public void setBairro(String bairro) {
		this.bairro = bairro;
	}
	
	public String getComplemento() {
		return complemento;
	}
	
	public void setComplemento(String complemento) {
		this.complemento = complemento;
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
	
	public String getCep() {
		return cep;
	}
	
	public Pessoa getPessoa() {
		return pessoa;
	}
	
	public void setCep(String cep) {
		this.cep = cep;
	}

	public void setPessoa(Pessoa pessoa) {
		this.pessoa = pessoa;
	}
}
