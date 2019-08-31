package com.marcsoftware.database;

import java.util.Date;

public class Notificacao {
	private Long codigo;
	private String assunto;
	private String descricao;
	private String prioridade;
	private String status;	
	private Date data;
	private Login remetente;
	
	public Notificacao() {
		
	}

	public Long getCodigo() {
		return codigo;
	}

	public void setCodigo(Long codigo) {
		this.codigo = codigo;
	}

	public String getAssunto() {
		return assunto;
	}

	public void setAssunto(String assunto) {
		this.assunto = assunto;
	}

	public String getDescricao() {
		return descricao;
	}

	public void setDescricao(String descricao) {
		this.descricao = descricao;
	}

	public String getPrioridade() {
		return prioridade;
	}

	public void setPrioridade(String prioridade) {
		this.prioridade = prioridade;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}
	
	public Date getData() {
		return data;
	}

	public void setData(Date data) {
		this.data = data;
	}

	public Login getRemetente() {
		return remetente;
	}

	public void setRemetente(Login remetente) {
		this.remetente = remetente;
	}
}
