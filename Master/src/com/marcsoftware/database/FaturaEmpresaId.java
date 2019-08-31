package com.marcsoftware.database;

import java.io.Serializable;

public class FaturaEmpresaId implements Serializable {	
	private Lancamento lancamento;	
	private FaturaEmpresa faturaEmpresa;
	
	public FaturaEmpresaId() {
		
	}	

	public Lancamento getLancamento() {
		return lancamento;
	}

	public void setLancamento(Lancamento lancamento) {
		this.lancamento = lancamento;
	}
	
	public FaturaEmpresa getFaturaEmpresa() {
		return faturaEmpresa;
	}

	public void setFaturaEmpresa(FaturaEmpresa faturaEmpresa) {
		this.faturaEmpresa = faturaEmpresa;
	}

	@Override
	public boolean equals(Object object) {
		if (object == null || !(object instanceof FaturaEmpresaId)) { 
			return false; 
		} 
		
		FaturaEmpresaId novo = (FaturaEmpresaId) object; 
		
		if ((!novo.getFaturaEmpresa().equals(this.faturaEmpresa))
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
