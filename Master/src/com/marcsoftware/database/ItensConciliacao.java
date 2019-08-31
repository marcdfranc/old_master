package com.marcsoftware.database;

public class ItensConciliacao {
	private ItensConciliacaoId id;
	private String docDigital;
	
	public ItensConciliacao() {
		
	}

	public ItensConciliacaoId getId() {
		return id;
	}

	public void setId(ItensConciliacaoId id) {
		this.id = id;
	}

	public String getDocDigital() {
		return docDigital;
	}

	public void setDocDigital(String docDigital) {
		this.docDigital = docDigital;
	}
}
