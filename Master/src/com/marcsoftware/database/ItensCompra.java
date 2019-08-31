package com.marcsoftware.database;

public class ItensCompra {
	private String unidadeMedida;
	private int quantidade;
	private double custo;
	private ItensCompraId id;
	
	public ItensCompra() {
		
	}

	public String getUnidadeMedida() {
		return unidadeMedida;
	}

	public void setUnidadeMedida(String unidadeMedida) {
		this.unidadeMedida = unidadeMedida;
	}

	public int getQuantidade() {
		return quantidade;
	}

	public void setQuantidade(int quantidade) {
		this.quantidade = quantidade;
	}

	public double getCusto() {
		return custo;
	}

	public void setCusto(double custo) {
		this.custo = custo;
	}

	public ItensCompraId getId() {
		return id;
	}

	public void setId(ItensCompraId id) {
		this.id = id;
	}	
}
