package com.marcsoftware.database;

public class FormaPagamento {
	private long codigo;
	private String descricao, concilia;	
	
	public FormaPagamento() {
		
	}
	
	public long getCodigo() {
		return codigo;
	}
	
	public void setCodigo(long codigo) {
		this.codigo = codigo;
	}
	
	public String getDescricao() {
		return descricao;
	}
	
	public void setDescricao(String descricao) {
		this.descricao = descricao;
	}

	public String getConcilia() {
		return concilia;
	}

	public void setConcilia(String concilia) {
		this.concilia = concilia;
	}
}
