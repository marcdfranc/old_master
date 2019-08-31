package com.marcsoftware.database;

import java.util.Date;
import java.util.List;

public class Orcamento {
	private long codigo;
	private int parcelas;	 
	private Pessoa pessoa;
	private Usuario usuario;
	private Dependente dependente;
	private Date data;
	private String observacao, status;
	private Login login;
	private boolean isDependenteNul;
	private String docDigital;
	private String docParcelaDigital;
	
	public Orcamento() {
		
	}
	
	public Date getData() {
		return data;
	}

	public void setData(Date data) {
		this.data = data;
	}
	
	public int getParcelas() {
		return parcelas;
	}
	
	public void setParcelas(int parcelas) {
		this.parcelas = parcelas;
	}
	
	public Pessoa getPessoa() {
		return pessoa;
	}

	public void setPessoa(Pessoa pessoa) {
		this.pessoa = pessoa;
	}

	public Usuario getUsuario() {
		return usuario;
	}
	
	public void setUsuario(Usuario usuario) {
		this.usuario = usuario;
	}
	
	public Dependente getDependente() {
		return dependente;
	}
	
	public void setDependente(Dependente dependente) {		
		this.dependente = dependente;
		isDependenteNul = dependente == null;
	}
	
	public long getCodigo() {
		return codigo;
	}

	public void setCodigo(long codigo) {
		this.codigo = codigo;
	}

	public String getObservacao() {
		return observacao;
	}

	public void setObservacao(String observacao) {
		this.observacao = observacao;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Login getLogin() {
		return login;
	}

	public void setLogin(Login login) {
		this.login = login;
	}

	public boolean isDependenteNul() {
		return isDependenteNul;
	}

	public String getDocDigital() {
		return docDigital;
	}

	public void setDocDigital(String docDigital) {
		this.docDigital = docDigital;
	}

	public String getDocParcelaDigital() {
		return docParcelaDigital;
	}

	public void setDocParcelaDigital(String docParcelaDigital) {
		this.docParcelaDigital = docParcelaDigital;
	}
}
