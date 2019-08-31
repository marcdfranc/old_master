package com.marcsoftware.database;

public class Login {
	private String username, senha, foto, perfil, porta, headerCupom, subHeader, footerCupom, subFooter, blocoNotas;
	private Integer tries, colunas;
	
	public Login(){
		
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getSenha() {
		return senha;
	}

	public void setSenha(String senha) {
		this.senha = senha;
	}

	public String getFoto() {
		return foto;
	}

	public void setFoto(String foto) {
		this.foto = foto;
	}

	public String getPerfil() {
		return perfil;
	}

	public void setPerfil(String perfil) {
		this.perfil = perfil;
	}

	public String getPorta() {
		return porta;
	}

	public void setPorta(String porta) {
		this.porta = porta;
	}

	public Integer getTries() {
		return tries;
	}

	public void setTries(Integer tries) {
		this.tries = tries;
	}

	public String getHeaderCupom() {
		return headerCupom;
	}

	public void setHeaderCupom(String headerCupom) {
		this.headerCupom = headerCupom;
	}	

	public String getSubHeader() {
		return subHeader;
	}

	public void setSubHeader(String subHeader) {
		this.subHeader = subHeader;
	}	

	public String getFooterCupom() {
		return footerCupom;
	}

	public void setFooterCupom(String footerCupom) {
		this.footerCupom = footerCupom;
	}

	public String getSubFooter() {
		return subFooter;
	}

	public void setSubFooter(String subFooter) {
		this.subFooter = subFooter;
	}

	public Integer getColunas() {
		return colunas;
	}

	public void setColunas(Integer colunas) {
		this.colunas = colunas;
	}

	public String getBlocoNotas() {
		return blocoNotas;
	}

	public void setBlocoNotas(String blocoNotas) {
		this.blocoNotas = blocoNotas;
	}
}
