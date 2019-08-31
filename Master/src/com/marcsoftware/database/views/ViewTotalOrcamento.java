package com.marcsoftware.database.views;

import com.marcsoftware.database.Orcamento;



public class ViewTotalOrcamento {
	private Orcamento orcamento;
	private double vlrCliente, vlrOperacional;
	private int qtdeParcelas, qtdeQuitadas;
	private String status;
	
	public ViewTotalOrcamento() {
		
	}	
	
	public Orcamento getOrcamento() {
		return orcamento;
	}
	
	public void setOrcamento(Orcamento orcamento) {
		this.orcamento = orcamento;
	}



	public double getVlrCliente() {
		return vlrCliente;
	}

	public void setVlrCliente(double vlrCliente) {
		this.vlrCliente = vlrCliente;
	}

	public double getVlrOperacional() {
		return vlrOperacional;
	}

	public void setVlrOperacional(double vlrOperacional) {
		this.vlrOperacional = vlrOperacional;
	}

	public int getQtdeParcelas() {
		return qtdeParcelas;
	}

	public void setQtdeParcelas(int qtdeParcelas) {
		this.qtdeParcelas = qtdeParcelas;
	}

	public int getQtdeQuitadas() {
		return qtdeQuitadas;
	}

	public void setQtdeQuitadas(int qtdeQuitadas) {
		this.qtdeQuitadas = qtdeQuitadas;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}
}
