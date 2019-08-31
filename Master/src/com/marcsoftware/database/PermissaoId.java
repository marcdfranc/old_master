package com.marcsoftware.database;

import java.io.Serializable;

public class PermissaoId implements Serializable {
	private Funcao funcao;
	private Perfil perfil;

	public Funcao getFuncao() {
		return funcao;
	}

	public void setFuncao(Funcao funcao) {
		this.funcao = funcao;
	}

	public Perfil getPerfil() {
		return perfil;
	}

	public void setPerfil(Perfil perfil) {
		this.perfil = perfil;
	}
	
	@Override
	public boolean equals(Object object) {
		if (object == null || !(object instanceof PermissaoId)) { 
			return false; 
		} 
		
		PermissaoId novo = (PermissaoId) object; 
		
		if ((!novo.getFuncao().equals(this.funcao)) || 
					(!novo.getPerfil().equals(this.perfil))) {
			return false; 
		}
		return true;
	}
	
	@Override
	public int hashCode() {
		return (int) this.funcao.hashCode();
	}
}
