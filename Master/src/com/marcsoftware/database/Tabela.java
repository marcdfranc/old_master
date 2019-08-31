package com.marcsoftware.database;

public class Tabela {
	private Long codigo;
	private Servico servico;
	private Unidade unidade;
	private Vigencia vigencia;
	private double operacional, valorCliente;
	
	public Tabela() {
		
	}
	
	public double getOperacional() {
		return operacional;
	}

	public void setOperacional(double operacional) {
		this.operacional = operacional;
	}

	public double getValorCliente() {
		return valorCliente;
	}

	public void setValorCliente(double valorCliente) {
		this.valorCliente = valorCliente;
	}

	public Long getCodigo() {
		return codigo;
	}

	public void setCodigo(Long codigo) {
		this.codigo = codigo;
	}

	public Servico getServico() {
		return servico;
	}

	public void setServico(Servico servico) {
		this.servico = servico;
	}

	public Unidade getUnidade() {
		return unidade;
	}

	public void setUnidade(Unidade unidade) {
		this.unidade = unidade;
	}
	
	public Vigencia getVigencia() {
		return vigencia;
	}

	public void setVigencia(Vigencia vigencia) {
		this.vigencia = vigencia;
	}	
}
