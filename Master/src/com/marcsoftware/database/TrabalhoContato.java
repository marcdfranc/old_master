package com.marcsoftware.database;

public class TrabalhoContato {
	private Long codigo;
	private String cargo;
	private String setor;
	private String empresa;
	private String website;
	private String fone;
	private EnderecoCatalogo endereco;
	
	public TrabalhoContato() {
		
	}

	public Long getCodigo() {
		return codigo;
	}

	public void setCodigo(Long codigo) {
		this.codigo = codigo;
	}

	public String getCargo() {
		return cargo;
	}

	public void setCargo(String cargo) {
		this.cargo = cargo;
	}

	public String getSetor() {
		return setor;
	}

	public void setSetor(String setor) {
		this.setor = setor;
	}

	public String getEmpresa() {
		return empresa;
	}

	public void setEmpresa(String empresa) {
		this.empresa = empresa;
	}

	public String getWebsite() {
		return website;
	}

	public void setWebsite(String website) {
		this.website = website;
	}

	public String getFone() {
		return fone;
	}

	public void setFone(String fone) {
		this.fone = fone;
	}

	public EnderecoCatalogo getEndereco() {
		return endereco;
	}

	public void setEndereco(EnderecoCatalogo endereco) {
		this.endereco = endereco;
	}
}
