package com.marcsoftware.database;

import java.util.Date;


public class Usuario extends Fisica {
	private String profissao;
	private String mae;
	private String pai;
	private String status; 
	private Plano plano;	
	private FormaPagamento pagamento;
	private Contrato contrato;
	private Date renovacao;	
	private Date consultaCredito;
	private int qtdeParcela;
	private int carteirinha;
	private Integer spc;
	private Integer devolucaoCheques;
	private Integer protestos;
	private Long ctr;
	private String ccobUndConsumidora;
	private String ccobConcessionaria;
	private String ccobTitular;
	private Date ccobDtLeitura;
	private Date ccobDtVencimento;
	private Long ccobLogradouro;
	private String ccobStatus;
	private Double ccobValor;
	private String ccobTipo;
	private String ccobDocumento;
	private String ccobDocEstadual;
	private Double ccobAdesao;
	private String ccobCobrar;
	
	
	public int getQtdeParcela() {
		return qtdeParcela;
	}

	public void setQtdeParcela(int qtdeParcela) {
		this.qtdeParcela = qtdeParcela;
	}
	
	public Usuario(){
		
	}

	public String getProfissao() {
		return profissao;
	}

	public void setProfissao(String profissao) {
		this.profissao = profissao;
	}

	public String getMae() {
		return mae;
	}

	public void setMae(String mae) {
		this.mae = mae;
	}

	public String getPai() {
		return pai;
	}

	public void setPai(String pai) {
		this.pai = pai;
	}

	public Date getRenovacao() {
		return renovacao;
	}

	public void setRenovacao(Date renovacao) {
		this.renovacao = renovacao;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Plano getPlano() {
		return plano;
	}

	public void setPlano(Plano plano) {
		this.plano = plano;
	}
	
	public FormaPagamento getPagamento() {
		return pagamento;
	}

	public void setPagamento(FormaPagamento pagamento) {
		this.pagamento = pagamento;
	}

	public int getCarteirinha() {
		return carteirinha;
	}

	public void setCarteirinha(int carteirinha) {
		this.carteirinha = carteirinha;
	}
	
	public Contrato getContrato() {
		return contrato;
	}
	
	public void setContrato(Contrato contrato) {
		this.contrato = contrato;
	}
	
	public Long getCtr() {
		return ctr;
	}

	public void setCtr(Long ctr) {
		this.ctr = ctr;
	}
	
	public Date getConsultaCredito() {
		return consultaCredito;
	}

	public void setConsultaCredito(Date consultaCredito) {
		this.consultaCredito = consultaCredito;
	}

	public Integer getSpc() {
		return spc;
	}

	public void setSpc(Integer spc) {
		this.spc = spc;
	}

	public Integer getDevolucaoCheques() {
		return devolucaoCheques;
	}

	public void setDevolucaoCheques(Integer devolucaoCheques) {
		this.devolucaoCheques = devolucaoCheques;
	}

	public Integer getProtestos() {
		return protestos;
	}

	public void setProtestos(Integer protestos) {
		this.protestos = protestos;
	}

	public String getCcobUndConsumidora() {
		return ccobUndConsumidora;
	}

	public void setCcobUndConsumidora(String ccobUndConsumidora) {
		this.ccobUndConsumidora = ccobUndConsumidora;
	}

	public String getCcobConcessionaria() {
		return ccobConcessionaria;
	}

	public void setCcobConcessionaria(String ccobConcessionaria) {
		this.ccobConcessionaria = ccobConcessionaria;
	}

	public String getCcobTitular() {
		return ccobTitular;
	}

	public void setCcobTitular(String ccobTitular) {
		this.ccobTitular = ccobTitular;
	}

	public Date getCcobDtLeitura() {
		return ccobDtLeitura;
	}

	public void setCcobDtLeitura(Date ccobDtLeitura) {
		this.ccobDtLeitura = ccobDtLeitura;
	}

	public Date getCcobDtVencimento() {
		return ccobDtVencimento;
	}

	public void setCcobDtVencimento(Date ccobDtVencimento) {
		this.ccobDtVencimento = ccobDtVencimento;
	}

	public Long getCcobLogradouro() {
		return ccobLogradouro;
	}

	public void setCcobLogradouro(Long ccobLogradouro) {
		this.ccobLogradouro = ccobLogradouro;
	}

	public Double getCcobValor() {
		return ccobValor;
	}

	public void setCcobValor(Double ccobValor) {
		this.ccobValor = ccobValor;
	}

	public String getCcobTipo() {
		return ccobTipo;
	}

	public void setCcobTipo(String ccobTipo) {
		this.ccobTipo = ccobTipo;
	}

	public String getCcobDocumento() {
		return ccobDocumento;
	}

	public void setCcobDocumento(String ccobDocumento) {
		this.ccobDocumento = ccobDocumento;
	}

	public String getCcobDocEstadual() {
		return ccobDocEstadual;
	}

	public void setCcobDocEstadual(String ccobDocEstadual) {
		this.ccobDocEstadual = ccobDocEstadual;
	}

	public String getCcobStatus() {
		return ccobStatus;
	}

	public void setCcobStatus(String ccobStatus) {
		this.ccobStatus = ccobStatus;
	}

	public Double getCcobAdesao() {
		return ccobAdesao;
	}
	
	public void setCcobAdesao(Double ccobAdesao) {
		this.ccobAdesao = ccobAdesao;
	}

	public String getCcobCobrar() {
		return ccobCobrar;
	}

	public void setCcobCobrar(String ccobCobrar) {
		this.ccobCobrar = ccobCobrar;
	}
}
