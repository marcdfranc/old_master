package com.marcsoftware.database;

import java.util.Date;

public class BoletoMensalidade {
	private long codigo;
	private Date data;
	private Usuario usuario;
	
	public BoletoMensalidade() {
		
	}

	public long getCodigo() {
		return codigo;
	}

	public void setCodigo(long codigo) {
		this.codigo = codigo;
	}

	public Date getData() {
		return data;
	}

	public void setData(Date data) {
		this.data = data;
	}

	public Usuario getUsuario() {
		return usuario;
	}

	public void setUsuario(Usuario usuario) {
		this.usuario = usuario;
	}
}
