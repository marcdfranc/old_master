package com.marcsoftware.database;

public class ParcelaOrcamento {
	private ParcelaOrcamentoId id;
	private String beneficiario;
	private Long sequencial;
	
	public ParcelaOrcamento() {
		
	}

	public ParcelaOrcamentoId getId() {
		return id;
	}

	public void setId(ParcelaOrcamentoId id) {
		this.id = id;
	}

	public String getBeneficiario() {
		return beneficiario;
	}

	public void setBeneficiario(String beneficiario) {
		this.beneficiario = beneficiario;
	}

	public Long getSequencial() {
		return sequencial;
	}

	public void setSequencial(Long sequencial) {
		this.sequencial = sequencial;
	}
}