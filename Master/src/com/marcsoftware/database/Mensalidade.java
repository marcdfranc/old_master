package com.marcsoftware.database;

public class Mensalidade {
	private Long codigo, vigencia;
	private Usuario usuario;
	private Lancamento lancamento;	
	
	public Long getVigencia() {
		return vigencia;
	}

	public void setVigencia(Long vigencia) {
		this.vigencia = vigencia;
	}

	public Mensalidade() {
		
	}

	public Usuario getUsuario() {
		return usuario;
	}

	public void setUsuario(Usuario usuario) {
		this.usuario = usuario;
	}

	public Long getCodigo() {
		return codigo;
	}

	public void setCodigo(Long codigo) {
		this.codigo = codigo;
	}

	public Lancamento getLancamento() {
		return lancamento;
	}

	public void setLancamento(Lancamento lancamento) {
		this.lancamento = lancamento;
	}
}
