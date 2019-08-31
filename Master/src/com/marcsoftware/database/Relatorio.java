package com.marcsoftware.database;

public class Relatorio {
	private Long codigo;
	private String descricao, tela, nome, comando, path, tipo, dinamico, ordem;
	private int widthFiltro, heightFiltro;
	  
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
	
	public String getTela() {
		return tela;
	}
	
	public void setTela(String tela) {
		this.tela = tela;
	}

	public String getNome() {
		return nome;
	}

	public void setNome(String nome) {
		this.nome = nome;
	}

	public String getComando() {
		return comando;
	}

	public void setComando(String comando) {
		this.comando = comando;
	}

	public String getPath() {
		return path;
	}

	public void setPath(String path) {
		this.path = path;
	}

	public String getTipo() {
		return tipo;
	}

	public void setTipo(String tipo) {
		this.tipo = tipo;
	}

	public String getDinamico() {
		return dinamico;
	}

	public void setDinamico(String dinamico) {
		this.dinamico = dinamico;
	}

	public int getWidthFiltro() {
		return widthFiltro;
	}

	public void setWidthFiltro(int widthFiltro) {
		this.widthFiltro = widthFiltro;
	}

	public int getHeightFiltro() {
		return heightFiltro;
	}

	public void setHeightFiltro(int heightFiltro) {
		this.heightFiltro = heightFiltro;
	}

	public String getOrdem() {
		return ordem;
	}

	public void setOrdem(String ordem) {
		this.ordem = ordem;
	}
}
