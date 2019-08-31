package com.marcsoftware.utilities;

import java.util.Date;

import com.marcsoftware.database.Conta;



/*
 * O primeiro digito do campo nossoNumero indicará o tipo de cobrança
 * 		0 = menslidade
 * 		1 = tratamento
 * 		2 = fatura de empresa
 * 
 * o restante representará
 *		para mensalidade: o codigo da mensalidade
 *		para tratamento : o numero do lançamento
 *		para fatura empresa: o código da fatura 
 **/
public class CNABAdmin {
	private Conta conta;
	private String linhaDigitavel, codBanco, nossoNum, digitao, 
		fatorVencimento, valor, digitaoBarra;
	private int tipo;	

	public void setConta(Conta conta) {
		this.conta = conta;
	}
	
	public void setDigitao(int tipo, String nossoNumero) {
		linhaDigitavel = "";		
		int aux = 0;
		this.tipo = tipo;
		int soma= 0;
		this.nossoNum = "000000" + nossoNumero;
		boolean isDois = true;
		switch (Integer.parseInt(Long.toString(conta.getBanco().getCodigo()))) {
		case 1:
			codBanco = "356-5";
			this.linhaDigitavel = nossoNumero + conta.getAgencia() + conta.getNumero();
			for (int i = this.linhaDigitavel.length() ; i > 0 ; i--) {
				if (isDois) {
					aux = Integer.parseInt(String.valueOf(this.linhaDigitavel.charAt(i - 1))) * 2;
					if (String.valueOf(aux).length() == 2) {
						aux = 1 + (aux - 10);
					}
				} else {
					aux = Integer.parseInt(String.valueOf(this.linhaDigitavel.charAt(i - 1)));
				}
				soma += aux;
				isDois = !isDois;
			} 
			if ((10 - (soma % 10)) == 10) {
				this.digitao = "0";
			} else {
				this.digitao = String.valueOf(10 -(soma % 10));
			}
			break;
		}	
		this.linhaDigitavel = "";
	}

	public String getDigitao() {
		return digitao;
	}	
	
	
	public void setFatorVencimento(String vencimento) {
		Date venc = Util.parseDate(vencimento);
		Date dataBase = Util.parseDate("03/07/2000");		
		this.fatorVencimento = String.valueOf(Util.diferencaDias(venc, dataBase) + 1000);
	}	

	public void setValor(String valor) {
		this.valor = Util.formatCurrency(valor);
	}
	
	public void setValor(Double valor) {
		this.valor = Util.formatCurrency(valor);
	}
	
	public void setDigitaoCodBarra() {
		int soma = 0;
		int peso = 2;		
		String bloco = codBanco.substring(0, codBanco.length() - 2) + "9" + fatorVencimento;
		bloco += Util.zeroToLeft(valor.replace(".", ""), 10) + conta.getAgencia();
		bloco+= conta.getNumero() + digitao + nossoNum; 
		for (int i = bloco.length(); i > 0; i--) {
			soma += Integer.parseInt(String.valueOf(bloco.charAt(i - 1))) * peso;
			peso = (peso == 9)? 2 : peso + 1;
		}
		if (((11 - (soma % 11)) == 10) || ((11 - (soma % 11)) == 1) 
				|| ((11 - (soma % 11)) == 0)) {
			digitaoBarra = "1";
		} else {
			digitaoBarra = String.valueOf(11 - (soma % 11));
		}
	}

	public void setLinhaDigitavel() {
		String bloco = codBanco.substring(0, codBanco.length() - 2) + "9" + conta.getAgencia().substring(0, 1);
		bloco+= "." + conta.getAgencia().substring(1, conta.getAgencia().length());
		bloco+= conta.getNumero().substring(0, 1);
		linhaDigitavel = mountBloco(bloco, true) + "  ";
		bloco = conta.getNumero().substring(1, conta.getNumero().length() - 1);
		bloco+= "." + conta.getNumero().substring(conta.getNumero().length() - 1, conta.getNumero().length());
		bloco+= digitao + this.nossoNum.substring(0, 3);
		this.linhaDigitavel+= mountBloco(bloco, false) + "  ";
		bloco = this.nossoNum.substring(3, 8) + "." + this.nossoNum.substring(8, this.nossoNum.length());
		this.linhaDigitavel+= mountBloco(bloco, false) + "  " + digitaoBarra + "  ";
		this.linhaDigitavel+= fatorVencimento + Util.zeroToLeft(valor.replace(".", ""), 10);
	}
	
	private String mountBloco(String bloco, boolean isDois) {
		int aux = 0;
		int soma = 0;
		for (int i = 0; i < bloco.length(); i++) {
			if (bloco.charAt(i) != '.') {
				if (isDois) {
					aux = Integer.parseInt(String.valueOf(bloco.charAt(i))) * 2;
					if (String.valueOf(aux).length() == 2) {
						aux = 1 + (aux - 10);
					}
				} else {
					aux = Integer.parseInt(String.valueOf(bloco.charAt(i)));
				}
				soma+= aux;
				isDois = !isDois;
			}
		}
		if ((10 - (soma % 10)) == 10) {
			bloco += "0";
		} else {
			bloco += String.valueOf(10 -(soma % 10));
		}
		return bloco;
	}
	
	public String getLinhaDigitavel() {
		return this.linhaDigitavel;
	}
}
