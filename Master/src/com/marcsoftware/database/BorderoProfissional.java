package com.marcsoftware.database;

import java.util.Date;

public class BorderoProfissional {
	private Long codigo;
	private Date inicio;
	private Date fim;
	private Date cadastro;
	private FormaPagamento formaPagamento;
	private Pessoa pessoa;
	private String docDigital;
	
	public BorderoProfissional() {
		
	}

	public Long getCodigo() {
		return codigo;
	}

	public void setCodigo(Long codigo) {
		this.codigo = codigo;
	}

	public Date getInicio() {
		return inicio;
	}

	public void setInicio(Date inicio) {
		this.inicio = inicio;
	}

	public Date getFim() {
		return fim;
	}

	public void setFim(Date fim) {
		this.fim = fim;
	}
	
	public Pessoa getPessoa() {
		return pessoa;
	}

	public void setPessoa(Pessoa pessoa) {
		this.pessoa = pessoa;
	}

	public Date getCadastro() {
		return cadastro;
	}
	
	public void setCadastro(Date cadastro) {
		this.cadastro = cadastro;
	}

	public FormaPagamento getFormaPagamento() {
		return formaPagamento;
	}

	public void setFormaPagamento(FormaPagamento formaPagamento) {
		this.formaPagamento = formaPagamento;
	}

	public String getDocDigital() {
		return docDigital;
	}

	public void setDocDigital(String docDigital) {
		this.docDigital = docDigital;
	}
	
	public boolean haveDocDigital() {
		return this.docDigital.equals("s");
	}
}
