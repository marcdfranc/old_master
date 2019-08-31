package com.marcsoftware.database;

import java.util.Date;

/**
 * @author Marcelo
 *
 */
public class CobrancaCcob {
	private Long codigo;
	private String descricao;
	private Date cadastro;
	private Unidade unidade;
	private String enviado;
	private String atualizado;
	private String tipo;
	
	public Long getCodigo() {
		return codigo;
	}
	
	public void setCodigo(Long codigo) {
		this.codigo = codigo;
	}
	
	public String getDescricao() {
		return descricao;
	}
	
	public void setDescricao(String descricao) {
		this.descricao = descricao;
	}
	
	public Date getCadastro() {
		return cadastro;
	}
	
	public void setCadastro(Date cadastro) {
		this.cadastro = cadastro;
	}
	
	public Unidade getUnidade() {
		return unidade;
	}
	
	public void setUnidade(Unidade unidade) {
		this.unidade = unidade;
	}

	public String getEnviado() {
		return enviado;
	}

	public void setEnviado(String enviado) {
		this.enviado = enviado;
	}

	public String getAtualizado() {
		return atualizado;
	}

	public void setAtualizado(String atualizado) {
		this.atualizado = atualizado;
	}

	public String getTipo() {
		return tipo;
	}

	public void setTipo(String tipo) {
		this.tipo = tipo;
	}
}
