package com.marcsoftware.database.views;

import java.util.Date;

import com.marcsoftware.database.Orcamento;

public class ViewDebitoOrcamento {
	private Orcamento orcamento;
	private Long parcelas;
	private Date vencimento;
	private int atraso;
	
	public ViewDebitoOrcamento() {
		
	}

	public Orcamento getOrcamento() {
		return orcamento;
	}

	public void setOrcamento(Orcamento orcamento) {
		this.orcamento = orcamento;
	}

	public Long getParcelas() {
		return parcelas;
	}

	public void setParcelas(Long parcelas) {
		this.parcelas = parcelas;
	}

	public Date getVencimento() {
		return vencimento;
	}

	public void setVencimento(Date vencimento) {
		this.vencimento = vencimento;
	}

	public int getAtraso() {
		return atraso;
	}

	public void setAtraso(int atraso) {
		this.atraso = atraso;
	}
}
