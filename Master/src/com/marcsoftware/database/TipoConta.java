package com.marcsoftware.database;

public class TipoConta {
	private Long codigo;
	private String descricao, administrativo;
	
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

	public String getAdministrativo() {
		return administrativo;
	}

	public void setAdministrativo(String administrativo) {
		this.administrativo = administrativo;
	}
}
