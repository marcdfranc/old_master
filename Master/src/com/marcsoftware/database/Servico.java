package com.marcsoftware.database;

public class Servico {
	private long codigo;
	private String descricao, referencia;
	private Especialidade especialidade;
	private double ref;
	
	public Servico() {
		
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
	
	public Especialidade getEspecialidade() {
		return especialidade;
	}
	
	public void setEspecialidade(Especialidade especialidade) {
		this.especialidade = especialidade;
	}

	public String getReferencia() {
		return referencia;
	}

	public void setReferencia(String referencia) {
		this.referencia = referencia;
	}

	public double getRef() {
		return ref;
	}

	public void setRef(double ref) {
		this.ref = ref;
	}
}
