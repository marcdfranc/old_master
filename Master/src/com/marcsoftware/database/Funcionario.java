package com.marcsoftware.database;

public class Funcionario extends Fisica{
	private String ctps, cnh, pis;
	private double salario, comissao, bonus;
	private int meta;
	private Posicao posicao;
	private String ccobVendedor;
	
	public Funcionario() {
		
	}
	
	public String getCtps() {
		return ctps;
	}

	public void setCtps(String ctps) {
		this.ctps = ctps;
	}

	public String getCnh() {
		return cnh;
	}

	public void setCnh(String cnh) {
		this.cnh = cnh;
	}

	public double getSalario() {
		return salario;
	}

	public void setSalario(double salario) {
		this.salario = salario;
	}

	public double getComissao() {
		return comissao;
	}

	public void setComissao(double comissao) {
		this.comissao = comissao;
	}

	public double getBonus() {
		return bonus;
	}

	public void setBonus(double bonus) {
		this.bonus = bonus;
	}
	
	public Posicao getPosicao() {
		return posicao;
	}

	public void setPosicao(Posicao posicao) {
		this.posicao = posicao;
	}

	public int getMeta() {
		return meta;
	}

	public void setMeta(int meta) {
		this.meta = meta;
	}	

	public String getPis() {
		return pis;
	}

	public void setPis(String pis) {
		this.pis = pis;
	}

	public String getCcobVendedor() {
		return ccobVendedor;
	}

	public void setCcobVendedor(String ccobVendedor) {
		this.ccobVendedor = ccobVendedor;
	}
}
