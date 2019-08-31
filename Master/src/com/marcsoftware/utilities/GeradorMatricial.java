package com.marcsoftware.utilities;

import java.util.ArrayList;

public class GeradorMatricial {
	private static final String ESC = "\u001B"; //Escape	
	private static final String NOVA_LINHA = (char) 10+""; //line feed/new line	 
	//private static final String TABELA_CARACTERES = "(t" + (char)3 + (char)0 + (char)0 + (char)25 + (char)0;
	private static final String ABRE_CONDENSADO  = (char)15+"";
	private static final String FECHA_CONDENSADO  = (char)18+"";
	private static final String FONT_10 = (char)80+"";
	private static final String FONT_15 = (char)103+"";
	private static final String RASCUNHO = (char)120+"";
	private static final String ABRE_NEGRITO = (char)69+"";
	private static final String FECHA_NEGRITO = (char)70+"";	
	private String linha;
	private ArrayList<String> linhas;
	private int colunas;
	
	public GeradorMatricial(int colunas) {
		this.colunas = colunas;
		this.linha = "";
		this.linhas = new ArrayList<String>();
	}	
	
	public void addRow() {
		linhas.add(linha);		
		linha = "";
	}
	
	public void set10Cpi() {
		linha+= ESC + FONT_10;
		addRow();
	}
	
	public void se15Cpi() {
		linha+= ESC + FONT_15;
		addRow();
	}
	
	public void setRascunho() {
		linha+= ESC + RASCUNHO;
		addRow();
	}
	
	public void addLine() {
		for (int i = 0; i < colunas; i++) {
			linha += "-";
		}
		addRow();
	}	
	
	public void addExpression(int col, String expression) {
		if ((colunas > linha.length())
				&& ((linha.length() + expression.length()) < colunas)) {
			if (col < linha.length()) {
				linha += "erro" + NOVA_LINHA;
				
				return;
			} else {
				for (int i = linha.length(); i < col; i++) {
					linha += " ";
				}
			}
			linha += expression;
		} else {
			linha+= "erro" + NOVA_LINHA;
			return;
		}
	}
	
	public void addRightExpression(String expression) {
		if ((colunas - linha.length()) < expression.length()) {
			linha+= "erro" + NOVA_LINHA;
		} else {
			addExpression(colunas - expression.length(), expression);
		}
		addRow();	
	}
	
	public void addCenterExpression(String expression) {
		int left= (Integer) (colunas - expression.length())/2;
		int right= left;
		left-= (expression.length() + right + left) - colunas; 
		if (linha.length() > 0) {
			linha+= "erro";			
		} else {
			for (int i = 0; i < left; i++) {
				linha += " ";
			}
			linha += expression;
			for (int i = 0; i < right; i++) {
				linha+= " ";
			}
		}
		addRow();
	}
	
	public void nextLine() {		
		linha += NOVA_LINHA;
		addRow();
	}
	
	
	public int getColuns() {
		return colunas;
	}
	
	public void setColuns(int coluns) {
		colunas = coluns;
	}
	
	public void abreCondensado() {
		linha+= ESC + ABRE_CONDENSADO;
		addRow();
	}
	
	public void fechaCondensado() {
		linha+= ESC + FECHA_CONDENSADO;
		addRow();
	}
	
	public void abreNegrito() {
		linha+= ESC + ABRE_NEGRITO;
		addRow();
	}
	
	public void fechaNegrito() {
		linha+= ESC + FECHA_NEGRITO;
		addRow();
	}
	
	public String getRelatorio() {
		String aux= NOVA_LINHA;
		for (int i = 0; i < linhas.size(); i++) {
			aux+= "@" + linhas.get(i);
		}
		for (int i = 0; i < 7; i++) {
			aux+= "@" + NOVA_LINHA;
		}
		return aux;
	}	
}
