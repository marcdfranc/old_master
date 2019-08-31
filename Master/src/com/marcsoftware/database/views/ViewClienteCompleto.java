package com.marcsoftware.database.views;

import com.marcsoftware.database.Empresa;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.database.Usuario;

public class ViewClienteCompleto {
	private Long ctr;
	private Unidade unidade;
	private Usuario usuario;
	private Empresa empresa;
	private int atrasoMensalidade, atrasoTratamento, diasMensalidade, diasTratamento;
	

	public ViewClienteCompleto() {
		
	}
	
	public Long getCtr() {
		return this.ctr;
	}
	
	public void setCtr(Long ctr) {
		this.ctr = ctr;
	}

	public Usuario getUsuario() {
		return usuario;
	}

	public void setUsuario(Usuario usuario) {
		this.usuario = usuario;
	}

	public Empresa getEmpresa() {
		return empresa;
	}

	public void setEmpresa(Empresa empresa) {
		this.empresa = empresa;
	}

	public int getAtrasoMensalidade() {
		return atrasoMensalidade;
	}

	public void setAtrasoMensalidade(int atrasoMensalidade) {
		this.atrasoMensalidade = atrasoMensalidade;
	}

	public int getAtrasoTratamento() {
		return atrasoTratamento;
	}

	public void setAtrasoTratamento(int atrasoTratamento) {
		this.atrasoTratamento = atrasoTratamento;
	}

	public int getDiasMensalidade() {
		return diasMensalidade;
	}

	public void setDiasMensalidade(int diasMensalidade) {
		this.diasMensalidade = diasMensalidade;
	}

	public int getDiasTratamento() {
		return diasTratamento;
	}

	public void setDiasTratamento(int diasTratamento) {
		this.diasTratamento = diasTratamento;
	}

	public Unidade getUnidade() {
		return unidade;
	}

	public void setUnidade(Unidade unidade) {
		this.unidade = unidade;
	}
}
