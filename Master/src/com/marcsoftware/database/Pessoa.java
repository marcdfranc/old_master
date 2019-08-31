package com.marcsoftware.database;

import java.util.Date;

public class Pessoa {
	private long codigo;	
	private String referencia;
	private String deleted;
	private String ativo;
	private String vencimento;
	private String observacao;
	private String docDigital;
	private Date cadastro;
	private Login login;
	private Login cadastrador;
	private Unidade unidade;
	
	
	public Pessoa() {
		
	}

	public long getCodigo() {
		return codigo;
	}

	public void setCodigo(long codigo) {
		this.codigo = codigo;
	}
	
	public String getReferencia() {
		return referencia;
	}

	public void setReferencia(String referencia) {
		this.referencia = referencia;
	}

	public String getDeleted() {
		return deleted;
	}

	public void setDeleted(String deleted) {
		this.deleted = deleted;
	}

	public String getAtivo() {
		return ativo;
	}

	public void setAtivo(String ativo) {
		this.ativo = ativo;
	}

	public String getVencimento() {
		return vencimento;
	}

	public void setVencimento(String vencimento) {
		this.vencimento = vencimento;
	}

	public Date getCadastro() {
		return cadastro;
	}

	public void setCadastro(Date cadastro) {
		this.cadastro = cadastro;
	}

	public Login getLogin() {
		return login;
	}

	public void setLogin(Login login) {
		this.login = login;
	}

	public Unidade getUnidade() {
		return unidade;
	}

	public void setUnidade(Unidade unidade) {
		this.unidade = unidade;
	}

	public String getObservacao() {
		return observacao;
	}

	public void setObservacao(String observacao) {
		this.observacao = observacao;
	}

	public Login getCadastrador() {
		return cadastrador;
	}

	public void setCadastrador(Login cadastrador) {
		this.cadastrador = cadastrador;
	}

	public String getDocDigital() {
		return docDigital;
	}

	public void setDocDigital(String docDigital) {
		this.docDigital = docDigital;
	}
}