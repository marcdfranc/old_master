package com.marcsoftware.database;

public class Perfil {
	private Long codigo;	
	private String descricao;
	private String unitario;

	public Long getCodigo() {
		return codigo;
	}

	public void setCodigo(Long codigo) {
		this.codigo = codigo;
	}

	public String getDescricao() {
		return descricao;
	}

	public void setDescricao(String descricao) {
		this.descricao = descricao;
	}

	public String getUnitario() {
		return unitario;
	}

	public void setUnitario(String unitario) {
		this.unitario = unitario;
	}
}
