package com.marcsoftware.database;

import java.util.Date;

public class Dependente {
	private long codigo;
	private String nome;
	private String parentesco;
	private String referencia;
	private String cpf;
	private String fone; 
	private Date nascimento;
	private Date consultaCredito;
	private Integer spc;
	private Integer devolucaoCheques;
	private Integer protestos;
	private int carteirinha;
	private Usuario usuario;
	
	public Dependente() {
		
	}
	
	public Usuario getUsuario() {
		return usuario;
	}

	public void setUsuario(Usuario usuario) {
		this.usuario = usuario;
	}

	public long getCodigo() {
		return codigo;
	}

	public void setCodigo(long codigo) {
		this.codigo = codigo;
	}
	
	public String getNome() {
		return nome;
	}

	public void setNome(String nome) {
		this.nome = nome;
	}

	public String getParentesco() {
		return parentesco;
	}

	public void setParentesco(String parentesco) {
		this.parentesco = parentesco;
	}

	public String getReferencia() {
		return referencia;
	}

	public void setReferencia(String referencia) {
		this.referencia = referencia;
	}

	public String getCpf() {
		return cpf;
	}

	public void setCpf(String cpf) {
		this.cpf = cpf;
	}

	public String getFone() {
		return fone;
	}

	public void setFone(String fone) {
		this.fone = fone;
	}

	public Date getNascimento() {
		return nascimento;
	}

	public void setNascimento(Date nascimento) {
		this.nascimento = nascimento;
	}

	public int getCarteirinha() {
		return carteirinha;
	}

	public void setCarteirinha(int carteirinha) {
		this.carteirinha = carteirinha;
	}

	public Date getConsultaCredito() {
		return consultaCredito;
	}

	public void setConsultaCredito(Date consultaCredito) {
		this.consultaCredito = consultaCredito;
	}

	public Integer getSpc() {
		return spc;
	}

	public void setSpc(Integer spc) {
		this.spc = spc;
	}

	public Integer getDevolucaoCheques() {
		return devolucaoCheques;
	}

	public void setDevolucaoCheques(Integer devolucaoCheques) {
		this.devolucaoCheques = devolucaoCheques;
	}

	public Integer getProtestos() {
		return protestos;
	}

	public void setProtestos(Integer protestos) {
		this.protestos = protestos;
	}
}
