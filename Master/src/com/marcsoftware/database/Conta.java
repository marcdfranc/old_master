package com.marcsoftware.database;

public class Conta {
	private Long codigo;
	private String agencia, numero, titular, carteira;	
	private Pessoa pessoa;
	private Banco banco;
	private Double vlrBoleto;

	public Conta() {
		
	}

	public Long getCodigo() {
		return codigo;
	}

	public void setCodigo(Long codigo) {
		this.codigo = codigo;
	}

	public String getAgencia() {
		return agencia;
	}

	public void setAgencia(String agencia) {
		this.agencia = agencia;
	}

	public String getNumero() {
		return numero;
	}

	public void setNumero(String numero) {
		this.numero = numero;
	}

	public String getTitular() {
		return titular;
	}

	public void setTitular(String titular) {
		this.titular = titular;
	}

	public Pessoa getPessoa() {
		return pessoa;
	}

	public void setPessoa(Pessoa pessoa) {
		this.pessoa = pessoa;
	}
	
	public Banco getBanco() {
		return banco;
	}
	
	public void setBanco(Banco banco) {
		this.banco = banco;
	}

	public String getCarteira() {
		return carteira;
	}

	public void setCarteira(String carteira) {
		this.carteira = carteira;
	}

	public Double getVlrBoleto() {
		return vlrBoleto;
	}

	public void setVlrBoleto(Double vlrBoleto) {
		this.vlrBoleto = vlrBoleto;
	}	
}
