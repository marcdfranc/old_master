package com.marcsoftware.database;

import java.util.Date;

public class HistoricoNavegacao {
	private Long codigo;
	private Date data;
	private String url; 
	private Acesso acesso;
	
	public HistoricoNavegacao() {
		
	}

	public Long getCodigo() {
		return codigo;
	}

	public void setCodigo(Long codigo) {
		this.codigo = codigo;
	}

	public Date getData() {
		return data;
	}

	public void setData(Date data) {
		this.data = data;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public Acesso getAcesso() {
		return acesso;
	}

	public void setAcesso(Acesso acesso) {
		this.acesso = acesso;
	}
}
