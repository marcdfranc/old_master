package com.marcsoftware.database;

public class ItensTabelaFranchising {
	private Long codigo; 
	private String tipoCobranca; 
	private double valor; 
	private TipoConta tipoConta;
	private TabelaFranchising tabela;
	
	public ItensTabelaFranchising() {
		
	}

	public Long getCodigo() {
		return codigo;
	}

	public void setCodigo(Long codigo) {
		this.codigo = codigo;
	}
	
	public String getTipoCobranca() {
		return tipoCobranca;
	}

	public void setTipoCobranca(String tipoCobranca) {
		this.tipoCobranca = tipoCobranca;
	}

	public double getValor() {
		return valor;
	}

	public void setValor(double valor) {
		this.valor = valor;
	}

	public TipoConta getTipoConta() {
		return tipoConta;
	}

	public void setTipoConta(TipoConta tipoConta) {
		this.tipoConta = tipoConta;
	}

	public TabelaFranchising getTabela() {
		return tabela;
	}

	public void setTabela(TabelaFranchising tabela) {
		this.tabela = tabela;
	}
}
