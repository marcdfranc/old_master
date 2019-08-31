package com.marcsoftware.database;

public class Unidade extends Juridica {	
	private String descricao, tipo, logo, reportLogo, thumb, thumbReport, logoCarteirinha, thumbCarteirinha;
	private double taxa, tabela2, adesao;
	private Login login;
	private Fisica administrador;
	private TabelaFranchising tabelaFranchising;
	private double percentagemTratamento;
	private double percentagemMensalidade;
	private String site;
	private String ccobId;
	private String ccobVerssao;
	private Long ccobSequencial;
	
	public Unidade() {
				
	}

	public String getDescricao() {
		return descricao;
	}

	public void setDescricao(String descricao) {
		this.descricao = descricao;
	}

	public String getTipo() {
		return tipo;
	}

	public void setTipo(String tipo) {
		this.tipo = tipo;
	}

	public double getTaxa() {
		return taxa;
	}

	public void setTaxa(double taxa) {
		this.taxa = taxa;
	}

	public double getTabela2() {
		return tabela2;
	}

	public void setTabela2(double tabela2) {
		this.tabela2 = tabela2;
	}

	public double getAdesao() {
		return adesao;
	}

	public void setAdesao(double adesao) {
		this.adesao = adesao;
	}

	public Login getLogin() {
		return login;
	}

	public void setLogin(Login login) {
		this.login = login;
	}

	public Fisica getAdministrador() {
		return administrador;
	}

	public void setAdministrador(Fisica administrador) {
		this.administrador = administrador;
	}
	
	public String getLogo() {
		return logo;
	}

	public void setLogo(String logo) {
		this.logo = logo;
	}

	public String getReportLogo() {
		return reportLogo;
	}

	public void setReportLogo(String reportLogo) {
		this.reportLogo = reportLogo;
	}

	public String getThumb() {
		return thumb;
	}

	public void setThumb(String thumb) {
		this.thumb = thumb;
	}

	public String getThumbReport() {
		return thumbReport;
	}

	public void setThumbReport(String thumbReport) {
		this.thumbReport = thumbReport;
	}

	public TabelaFranchising getTabelaFranchising() {
		return tabelaFranchising;
	}

	public void setTabelaFranchising(TabelaFranchising tabelaFranchising) {
		this.tabelaFranchising = tabelaFranchising;
	}

	public double getPercentagemTratamento() {
		return percentagemTratamento;
	}

	public void setPercentagemTratamento(double percentagemTratamento) {
		this.percentagemTratamento = percentagemTratamento;
	}

	public double getPercentagemMensalidade() {
		return percentagemMensalidade;
	}

	public void setPercentagemMensalidade(double percentagemMensalidade) {
		this.percentagemMensalidade = percentagemMensalidade;
	}
	
	public String getSite() {
		return site;
	}

	public void setSite(String site) {
		this.site = site;
	}

	public String getLogoCarteirinha() {
		return logoCarteirinha;
	}

	public void setLogoCarteirinha(String logoCarteirinha) {
		this.logoCarteirinha = logoCarteirinha;
	}

	public String getThumbCarteirinha() {
		return thumbCarteirinha;
	}

	public void setThumbCarteirinha(String thumbCarteirinha) {
		this.thumbCarteirinha = thumbCarteirinha;
	}

	public String getCcobId() {
		return ccobId;
	}

	public void setCcobId(String ccobId) {
		this.ccobId = ccobId;
	}

	public String getCcobVerssao() {
		return ccobVerssao;
	}

	public void setCcobVerssao(String ccobVerssao) {
		this.ccobVerssao = ccobVerssao;
	}

	public Long getCcobSequencial() {
		return ccobSequencial;
	}

	public void setCcobSequencial(Long ccobSequencial) {
		this.ccobSequencial = ccobSequencial;
	}	
	
}