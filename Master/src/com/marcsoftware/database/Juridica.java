package com.marcsoftware.database;

public class Juridica extends Pessoa {	
	private String razaoSocial, fantasia, cnpj, ie;	
	
	public Juridica() {
		
	}	
	
	public String getRazaoSocial() {		
		return razaoSocial;
	}
	
	public void setRazaoSocial(String razaoSocial) {
		this.razaoSocial = razaoSocial;
	}
	
	public String getFantasia() {
		return fantasia;
	}
	
	public void setFantasia(String fantasia) {
		this.fantasia = fantasia;
	}
	
	public String getCnpj() {
		return cnpj;
	}

	public void setCnpj(String cnpj) {
		this.cnpj= cnpj;
	}
	
	public String getIe() {
		return ie;
	}
	
	public void setIe(String ie) {
		this.ie = ie;
	}	
}
