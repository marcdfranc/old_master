package com.marcsoftware.database;

import java.util.Date;

public class Contrato {
	private Long codigo;
	private Long ctr;
	private Date requisicao;
	private Funcionario funcionario;
	private Lancamento lancamento;
	private String status;
	private Unidade unidade;
	
	public Contrato() {
		
	}

	public Long getCodigo() {
		return codigo;
	}

	public void setCodigo(Long codigo) {
		this.codigo = codigo;
	}

	public Date getRequisicao() {
		return requisicao;
	}

	public void setRequisicao(Date requisicao) {
		this.requisicao = requisicao;
	}

	public Funcionario getFuncionario() {
		return funcionario;
	}

	public void setFuncionario(Funcionario funcionario) {
		this.funcionario = funcionario;
	}

	public Lancamento getLancamento() {
		return lancamento;
	}

	public void setLancamento(Lancamento lancamento) {
		this.lancamento = lancamento;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Long getCtr() {
		return ctr;
	}

	public void setCtr(Long ctr) {
		this.ctr = ctr;
	}

	public Unidade getUnidade() {
		return unidade;
	}

	public void setUnidade(Unidade unidade) {
		this.unidade = unidade;
	}	
}
