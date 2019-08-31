package com.marcsoftware.database.views;

import com.marcsoftware.database.Empresa;
import com.marcsoftware.database.Usuario;

public class ViewDebitoMensalidade {
	private Long ctr;
	private Usuario usuario;
	private Empresa empresa;
	private int parcelasAtraso, diasAtraso;
	
	public ViewDebitoMensalidade() {
		
	}

	public Long getCtr() {
		return ctr;
	}

	public void setCtr(Long ctr) {
		this.ctr = ctr;
	}

	public Usuario getUsuario() {
		return usuario;
	}

	public void setUsuario(Usuario usuario) {
		this.usuario = usuario;
	}

	public Empresa getEmpresa() {
		return empresa;
	}

	public void setEmpresa(Empresa empresa) {
		this.empresa = empresa;
	}

	public int getParcelasAtraso() {
		return parcelasAtraso;
	}

	public void setParcelasAtraso(int parcelasAtraso) {
		this.parcelasAtraso = parcelasAtraso;
	}

	public int getDiasAtraso() {
		return diasAtraso;
	}

	public void setDiasAtraso(int diasAtraso) {
		this.diasAtraso = diasAtraso;
	}
}
