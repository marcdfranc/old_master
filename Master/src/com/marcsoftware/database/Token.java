package com.marcsoftware.database;

import java.util.Date;

public class Token {
	private Long id;
	private String descricao;
	private Date hora;
	private String expirado;
	
	public Token() {
		
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getDescricao() {
		return descricao;
	}

	public void setDescricao(String descricao) {
		this.descricao = descricao;
	}

	public Date getHora() {
		return hora;
	}

	public void setHora(Date hora) {
		this.hora = hora;
	}

	public String getExpirado() {
		return expirado;
	}

	public void setExpirado(String expirado) {
		this.expirado = expirado;
	}	
}
