package com.marcsoftware.database;

import java.io.Serializable;

public class AcessoNotificacaoId implements Serializable {
	private Login login;
	private Notificacao notificacao;
	
	public AcessoNotificacaoId() {
		
	}

	public Login getLogin() {
		return login;
	}

	public void setLogin(Login login) {
		this.login = login;
	}

	public Notificacao getNotificacao() {
		return notificacao;
	}

	public void setNotificacao(Notificacao notificacao) {
		this.notificacao = notificacao;
	}
	
	@Override
	public boolean equals(Object object) {
		if ((object == null) || !(object instanceof ItensCompraId)) {
			return false;		
		} 
		AcessoNotificacaoId novo= (AcessoNotificacaoId) object;
		
		if ((!novo.getLogin().equals(this.login)) || 
				(!novo.getNotificacao().equals(this.notificacao))) {
			return false;
		}
		return true;
	}
	
	
	@Override
	public int hashCode() {
		return this.notificacao.hashCode();
	}
}
