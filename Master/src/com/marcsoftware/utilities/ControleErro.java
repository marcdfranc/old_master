package com.marcsoftware.utilities;

public class ControleErro {
	private String msg;
	private String link;
	
	public ControleErro() {
		msg = "A página não pode ser exibida devido a um erro interno!";
		link = "/index.jsp";
	}
	
	public String getMsg() {		
		String result = this.msg;
		this.msg = "A página não pode ser exibida devido a um erro interno!";
		return result;
	}
	
	public void setMsg(String msg) {
		this.msg = msg;
	}
	
	public String getLink() {		
		return this.link;
	}
	
	public void setLink(String link) {
		this.link = link;
	}
}
