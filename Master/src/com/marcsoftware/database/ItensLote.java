package com.marcsoftware.database;

public class ItensLote {
	private Long codigo;
	private LoteParcelaCompra lote;
	private ParcelaCompra parcelaCompra;
	
	public ItensLote() {
		
	}

	public Long getCodigo() {
		return codigo;
	}

	public void setCodigo(Long codigo) {
		this.codigo = codigo;
	}

	public LoteParcelaCompra getLote() {
		return lote;
	}

	public void setLote(LoteParcelaCompra lote) {
		this.lote = lote;
	}

	public ParcelaCompra getParcelaCompra() {
		return parcelaCompra;
	}

	public void setParcelaCompra(ParcelaCompra parcelaCompra) {
		this.parcelaCompra = parcelaCompra;
	}
}
