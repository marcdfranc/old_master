package com.marcsoftware.database;

import java.io.Serializable;

public class ContratoEmpresaId implements Serializable {
	private Empresa empresa;
	private Usuario usuario;
	
	public ContratoEmpresaId() {
		
	}

	public Empresa getEmpresa() {
		return empresa;
	}

	public void setEmpresa(Empresa empresa) {
		this.empresa = empresa;
	}

	public Usuario getUsuario() {
		return usuario;
	}

	public void setUsuario(Usuario usuario) {
		this.usuario = usuario;
	}
	
	@Override
	public boolean equals(Object object) {
		if (object == null || !(object instanceof ContratoEmpresaId)) { 
			return false; 
		} 
		
		ContratoEmpresaId novo = (ContratoEmpresaId) object; 
		
		if ((!novo.getUsuario().equals(this.usuario)) || 
					(!novo.getEmpresa().equals(this.empresa))) {
			return false; 
		}
		return true;
	}
	
	@Override
	public int hashCode() {
		return (int) this.usuario.hashCode();
	}
}
