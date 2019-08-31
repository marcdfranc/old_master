package com.marcsoftware.database;

import java.util.Date;

public class Catalogo {	
	private Long codigo;
	private String nome;
	private String apelido;
	private Login login;
	private Date aniverssario;
	private TrabalhoContato trabalho;
	private EnderecoCatalogo endereco;
	
	public Catalogo() {
		
	}

	public Long getCodigo() {
		return codigo;
	}

	public void setCodigo(Long codigo) {
		this.codigo = codigo;
	}
	
	public String getNome() {
		return nome;
	}

	public void setNome(String nome) {
		this.nome = nome;
	}

	public String getApelido() {
		return apelido;
	}

	public void setApelido(String apelido) {
		this.apelido = apelido;
	}

	public Login getLogin() {
		return login;
	}

	public void setLogin(Login login) {
		this.login = login;
	}	

	public Date getAniverssario() {
		return aniverssario;
	}

	public void setAniverssario(Date aniverssario) {
		this.aniverssario = aniverssario;
	}

	public TrabalhoContato getTrabalho() {
		return trabalho;
	}

	public void setTrabalho(TrabalhoContato trabalho) {
		this.trabalho = trabalho;
	}

	public EnderecoCatalogo getEndereco() {
		return endereco;
	}

	public void setEndereco(EnderecoCatalogo endereco) {
		this.endereco = endereco;
	}
}
