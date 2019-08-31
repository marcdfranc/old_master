package com.marcsoftware.database;

import java.io.Serializable;

public class ItensOrcamento {
	private ItensOrcamentoId id;
	private int qtde;
	private Tabela tabela;
	private String contabil;
	
	public ItensOrcamento() {
		
	}
	
	public ItensOrcamentoId getId() {
		return id;
	}

	public void setId(ItensOrcamentoId id) {
		this.id = id;
	}
	
	public int getQtde() {
		return qtde;
	}

	public void setQtde(int qtde) {
		this.qtde = qtde;
	}

	public Tabela getTabela() {
		return tabela;
	}

	public void setTabela(Tabela tabela) {
		this.tabela = tabela;
	}

	public String getContabil() {
		return contabil;
	}

	public void setContabil(String contabil) {
		this.contabil = contabil;
	}
}
