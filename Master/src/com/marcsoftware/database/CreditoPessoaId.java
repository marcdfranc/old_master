package com.marcsoftware.database;

import java.io.Serializable;

public class CreditoPessoaId implements Serializable {
	private Pessoa pessoa;
	private Lancamento lancamento;
	
	public CreditoPessoaId() {
		
	}

	public Pessoa getPessoa() {
		return pessoa;
	}

	public void setPessoa(Pessoa pessoa) {
		this.pessoa = pessoa;
	}

	public Lancamento getLancamento() {
		return lancamento;
	}

	public void setLancamento(Lancamento lancamento) {
		this.lancamento = lancamento;
	}
	
	@Override
	public boolean equals(Object object) {
		if (object == null || !(object instanceof CreditoPessoaId)) {
			return false;
		}
		CreditoPessoaId novo = (CreditoPessoaId) object;
		if ((!novo.getPessoa().equals(this.getPessoa())) || 
				(!novo.getLancamento().equals(this.getLancamento()))) {
			return false;
		}		
		return true;
	}
	
	@Override
	public int hashCode() {
		return this.lancamento.hashCode();
	}	
}
