package com.marcsoftware.database;

public class DebitoAnteriorId {
	private Lancamento lancamento;
	private Pessoa pessoa;
	
	public DebitoAnteriorId() {
		
	}

	public Lancamento getLancamento() {
		return lancamento;
	}

	public void setLancamento(Lancamento lancamento) {
		this.lancamento = lancamento;
	}
		
	public Pessoa getPessoa() {
		return pessoa;
	}

	public void setPessoa(Pessoa pessoa) {
		this.pessoa = pessoa;
	}

	@Override
	public boolean equals(Object object) {
		if (object == null || !(object instanceof FaturaEmpresaId)) { 
			return false; 
		} 
		
		DebitoAnteriorId novo = (DebitoAnteriorId) object; 
		
		if ((!novo.getPessoa().equals(this.pessoa))
				|| (!novo.getLancamento().equals(this.lancamento))) {
			return false; 
		}
		return true;
	}
	
	@Override
	public int hashCode() {
		return (int) this.lancamento.hashCode();
	}
}
