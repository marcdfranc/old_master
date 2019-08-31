package com.marcsoftware.database;

public class Pagina {
	private Long codigo;
	private String descricao;
	private String url;	

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

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = (url == null)? null : url.toLowerCase();
	}
}
