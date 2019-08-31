package com.marcsoftware.database;

import java.util.Date;

public class TabelaFranchising {
	private Long codigo;	
	private String descricao;
	private Date cadastro;
	
	public TabelaFranchising() {
		
	}

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
}
