package com.marcsoftware.database;

import java.io.Serializable;

public class LoginUnidadeId implements Serializable {
	private Login login;
	private Unidade unidade;
	
	public LoginUnidadeId() {
		
	}
	
	public Login getLogin() {
		return login;
	}
	
	public void setLogin(Login login) {
		this.login = login;
	}
	
	public Unidade getUnidade() {
		return unidade;
	}
	
	public void setUnidade(Unidade unidade) {
		this.unidade = unidade;
	}
	
	@Override
	public boolean equals(Object object) {
		if ((object == null) || !(object instanceof LoginUnidadeId)) {
			return false;
		} 
		LoginUnidadeId novo= (LoginUnidadeId) object;
		
		if ((!novo.getLogin().equals(this.login)) || 
				(!novo.getUnidade().equals(this.unidade))) {
			return false;
		}
		return true;
	}
	
	@Override
	public int hashCode() {		
		return this.login.hashCode();
	}
}
