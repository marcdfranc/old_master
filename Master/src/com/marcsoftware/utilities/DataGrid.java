package com.marcsoftware.utilities;

import java.util.ArrayList;

public class DataGrid {
	private String header, href, id, order, total, totalRight;
	private ArrayList<String> rowValue, row;
	private int ckIndex;
	private boolean target;
	
	public DataGrid(String href) {	
		this.href= href;
		this.header= "<div id=\"gridContent\" class=\"dataGrid\"> " + 
		"<table id=\"dg\" cellpadding=\"0\" cellspacing=\"0\" class=\"lastGrid\"> " +
		"<thead class=\"headerGrid\"><tr> ";
		row= new ArrayList<String>();
		rowValue= new ArrayList<String>();
		ckIndex = -1;
		order = "";
		total = "";
		totalRight = "";
		target = false;
	}
	
	public DataGrid(String href, boolean target) {
		this.href= href;
		this.header= "<div id=\"gridContent\" class=\"dataGrid\"> " + 
			"<table id=\"dg\" cellpadding=\"0\" cellspacing=\"0\" class=\"lastGrid\"> " +
			"<thead class=\"headerGrid\"><tr> ";
		row= new ArrayList<String>();
		rowValue= new ArrayList<String>();
		ckIndex = -1;
		order = "";
		total = "";
		totalRight = "";
		this.target = target;
	}
	
	public void setHref(String href) {
		this.href = href;
	}

	public void addColum(String size, String name) {
		header += "<th style=\"width:" + size + "%\"> " +
			"<div class=\"headerColum\"><p>" + name + "</p></div></th> "; 
	}
	
	public void addColumWithOrder(String size, String name, boolean isSet) {
		header += "<th style=\"width:" + size + "%\"> " +
			"<div class=\"headerColum\"><p onclick=\"changeOrderGrid(this)\" " +
			"class=\"linkHeader\" id=\"" + name + "\">" + name + "</p></div>";
		if (isSet) {
			header+= "<div id=\"" + name + "Od\"><img src=\"../image/order.gif\"/>" +
					"</div></th> ";
			order = name + "@asc"; 
		} else {
			header+= "<div id=\"" + name + "Od\"></div></th> ";
		}
	}
	
	public void addColumWithOrder(String size, String name, String idOrder, boolean isSet) {
		header += "<th style=\"width:" + size + "%\"> " +
			"<div class=\"headerColum\"><p onclick=\"changeOrderGrid(this)\" " +
			"class=\"linkHeader\" id=\"" + idOrder + "\">" + name + "</p></div>";
		if (isSet) {
			header+= "<div id=\"" + idOrder + "Od\"><img src=\"../image/order.gif\"/>" +
					"</div></th> ";
			order = idOrder + "@asc"; 
		} else {
			header+= "<div id=\"" + idOrder + "Od\"></div></th> ";
		}
	}


	public void setId(String id) {
		this.id= id;
		ckIndex++;
	}

	public void addData(String data) {
		if (href == null) {
			rowValue.add("<label onClick=\"appendMenu(\'rowMenu" + id +
				"\')\" >" + data + "</label></td>");
		} else if (href.trim().equals("")) {
			rowValue.add("<label>" + data + "</label></td>");
		} else {
			if (target) {
				rowValue.add("<a target=\"_blank\" onclick=\"showGlobal()\" href=\"" + href + 
						"?state=1&id=" + id + "\">" + data + "</a></td>");				
			} else {
				rowValue.add("<a onclick=\"showGlobal()\" href=\"" + href + 
						"?state=1&id=" + id + "\">" + data + "</a></td>");				
			}
		}
	}
	
	
	public void addData(String field, String data) {
		if (href == null) {
			rowValue.add("<label onClick=\"appendMenu(\'rowMenu" + id +
				"\')\" id=\"" + field + ckIndex + "\" name=\"" + field + ckIndex +
				"\">" + data + "</label></td>");
		} else {
			if (target) {
				rowValue.add("<a target=\"_blank\" onclick=\"showGlobal()\" href=\"" + href + 
						"?state=1&id=" + id + "\" id=\"" + field + ckIndex + "\" name=\"" +
						field + ckIndex + "\">" + data + "</a></td>");
			} else {
				rowValue.add("<a onclick=\"showGlobal()\" href=\"" + href + 
						"?state=1&id=" + id + "\" id=\"" + field + ckIndex + "\" name=\"" +
						field + ckIndex + "\">" + data + "</a></td>");
			}
		}
	}
	
	public void addData(String field, String data, String evento, String funcao, String parametro) {
		if (parametro.equals("id")) {
			if (href == null) {
				if (evento.equals("onClick")) {
					rowValue.add("<label onClick=\"appendMenu(\'rowMenu" + id +
							"\'); " + funcao + "(" + id + "); \" id=\"" + 
							field + ckIndex + "\" name=\"" + field + ckIndex +
							"\">" + data + "</label></td>");					
				} else {
					rowValue.add("<label onClick=\"appendMenu(\'rowMenu" + id +
							"\')\" " + evento + "=\"" + funcao + "(" + id + ")\" id=\"" + 
							field + ckIndex + "\" name=\"" + field + ckIndex +
							"\">" + data + "</label></td>");
				}
			} else {
				if (evento.equals("onClick")) {
					if (target) {
						rowValue.add("<a target=\"_blank\" onclick=\"showGlobal(); " + funcao + "(" + id + ");\" href=\"" + href + 
								"?state=1&id=" + id + "\" id=\"" + field + ckIndex + "\" name=\"" +
								field + ckIndex + "\">" + data + "</a></td>");
					} else {						
						rowValue.add("<a onclick=\"showGlobal(); " + funcao + "(" + id + ");\" href=\"" + href + 
								"?state=1&id=" + id + "\" id=\"" + field + ckIndex + "\" name=\"" +
								field + ckIndex + "\">" + data + "</a></td>");
					}
				} else {
					if (target) {
						rowValue.add("<a target=\"_blank\" onclick=\"showGlobal()\" " + evento + "=\"" + funcao + "(" + id + ") " +
								"href=\"" + href + "?state=1&id=" + id + "\" id=\"" + field + ckIndex + "\" name=\"" +
								field + ckIndex + "\">" + data + "</a></td>");
					} else {
						rowValue.add("<a onclick=\"showGlobal()\" " + evento + "=\"" + funcao + "(" + id + ") " +
								"href=\"" + href + "?state=1&id=" + id + "\" id=\"" + field + ckIndex + "\" name=\"" +
								field + ckIndex + "\">" + data + "</a></td>");
					}
				}
				
			}
		} else {
			if (href == null) {
				if (evento.equals("onClick")) {
					rowValue.add("<label onClick=\"appendMenu(\'rowMenu" + id +
							"\'); " + funcao + "(" + ckIndex + "); \" id=\"" + 
							field + ckIndex + "\" name=\"" + field + ckIndex +
							"\">" + data + "</label></td>");					
				} else {
					rowValue.add("<label onClick=\"appendMenu(\'rowMenu" + id +
							"\')\" " + evento + "=\"" + funcao + "(" + ckIndex + ")\" id=\"" + 
							field + ckIndex + "\" name=\"" + field + ckIndex +
							"\">" + data + "</label></td>");
				}
			} else {
				if (evento.equals("onClick")) {
					if (target) {
						rowValue.add("<a target=\"_blank\" onclick=\"showGlobal(); " + funcao + "(" + ckIndex + ");\" href=\"" + href + 
								"?state=1&id=" + id + "\" id=\"" + field + ckIndex + "\" name=\"" +
								field + ckIndex + "\">" + data + "</a></td>");
					} else {
						rowValue.add("<a onclick=\"showGlobal(); " + funcao + "(" + ckIndex + ");\" href=\"" + href + 
								"?state=1&id=" + id + "\" id=\"" + field + ckIndex + "\" name=\"" +
								field + ckIndex + "\">" + data + "</a></td>");
					}
				} else {
					if (target) {
						rowValue.add("<a target=\"_blank\" onclick=\"showGlobal()\" " + evento + "=\"" + funcao + "(" + ckIndex + ") " +
								"href=\"" + href + "?state=1&id=" + id + "\" id=\"" + field + ckIndex + "\" name=\"" +
								field + ckIndex + "\">" + data + "</a></td>");
					} else {
						rowValue.add("<a onclick=\"showGlobal()\" " + evento + "=\"" + funcao + "(" + ckIndex + ") " +
								"href=\"" + href + "?state=1&id=" + id + "\" id=\"" + field + ckIndex + "\" name=\"" +
								field + ckIndex + "\">" + data + "</a></td>");
					}
				}				
			}
		}
	}
	
	public void addData(String field, String data, boolean useIndex) {
		if (href == null) {
			rowValue.add("<label onClick=\"appendMenu(\'rowMenu" + id +
				"\')\" id=\"" + field + ((useIndex)? ckIndex : "") + "\" name=\"" + field + 
				((useIndex)? ckIndex : "") + "\">" + data + "</label></td>");
		} else {
			if (target) {
				rowValue.add("<a target=\"_blank\" onclick=\"showGlobal()\" href=\"" + href + 
						"?state=1&id=" + id + "\" id=\"" + field + ((useIndex)? ckIndex : "") +
						"\" name=\"" + field + ((useIndex)? ckIndex : "") + "\">" + 
						data + "</a></td>");
			} else {
				rowValue.add("<a onclick=\"showGlobal()\" href=\"" + href + 
						"?state=1&id=" + id + "\" id=\"" + field + ((useIndex)? ckIndex : "") +
						"\" name=\"" + field + ((useIndex)? ckIndex : "") + "\">" + 
						data + "</a></td>");
			}
		}
	}
	
	public void addCheck() {
		rowValue.add("<input type=\"checkbox\" value=\"" + id + "\" name=\"ck" +
				ckIndex + "\" id=\"ck" + ckIndex + "\"/></td>");		
	}
	
	public void addCheck(String field) {
		rowValue.add("<input type=\"checkbox\" value=\"" + id + "\" name=\"" +
				field + ckIndex + "\" id=\"" + field + ckIndex + "\"/></td>");		
	}
	
	public void addCheck(boolean haveFunction) {
		if (haveFunction) {
			rowValue.add("<input type=\"checkbox\" value=\"" + id + "\" name=\"ck" +
					ckIndex + "\" id=\"ck" + ckIndex + 
			"\" class=\"ck-grid\" onClick=\"ckFunction(this)\"/></td>");			
		} else {
			rowValue.add("<input type=\"checkbox\" class=\"ck-grid\" value=\"" + id + "\" name=\"ck" +
					ckIndex + "\" id=\"ck" + ckIndex + "\"/></td>");
		}		
	}
	
	public void addCheck(boolean haveFunction, String attr) {
		if (haveFunction) {
			rowValue.add("<input type=\"checkbox\" value=\"" + id + "\" name=\"ck" +
					ckIndex + "\" id=\"ck" + ckIndex + 
					"\" class=\"ck-grid\" " + attr + " onClick=\"ckFunction(this)\"/></td>");			
		} else {
			rowValue.add("<input type=\"checkbox\" class=\"ck-grid\"  " + attr + "  value=\"" + id + "\" name=\"ck" +
					ckIndex + "\" id=\"ck" + ckIndex + "\"/></td>");
		}		
	}
	
	public void addImg(String src) {
		if (href == null) {
			rowValue.add("<img src=\"" + src + "\" /></td>");
		} else {
			rowValue.add("<img src=\"" + src + "\"/></td>");
		}		
	}
	
	public void addImg(String src, String field) {
		if (href == null) {
			rowValue.add("<img name=\"" + field + ckIndex + "\" id=\"" + field + ckIndex + 
					"\" src=\"" + src + "\" /></td>");
		} else {
			rowValue.add("<img name=\"" + field + ckIndex + "\" id=\"" + field + ckIndex + 
					"\" src=\"" + src + "\"/></td>");
		}
	}
	
	public void addImg(String src, String field, String paramentros) {
		if (href == null) {
			rowValue.add("<img name=\"" + field + ckIndex + "\" id=\"" + field + ckIndex + 
					"\" src=\"" + src + "\" " + paramentros + "\"/></td>");
		} else {
			rowValue.add("<img name=\"" + field + ckIndex + "\" id=\"" + field + ckIndex + 
					"\" src=\"" + src + "\" " + paramentros + "\"/></td>");
		}
	}

	public String mountRow() {
		String aux= "";
		if ((href == null) || (!href.trim().equals(""))) {
			aux= "<tr class=\"gridRow\"> ";
		} else {
			aux= "<tr class=\"gridRowEmpty\"> ";
		}
		for (String value: rowValue) {			
			aux+= "<td>" + value;
		}
		aux+= "</tr><tr id=\"rowMenu" + id + "\" class=\"rowMenu\"></tr>";
		rowValue= new ArrayList<String>();
		return aux;
	}
	
	public String mountSimpleRow() {
		String aux= "";
		if ((href == null) || (!href.trim().equals(""))) {
			aux= "<tr class=\"gridRow\"> ";
		} else {
			aux= "<tr class=\"gridRowEmpty\"> ";
		}
		for (String value: rowValue) {			
			aux+= "<td>" + value;
		}
		aux+= "</tr>";
		rowValue= new ArrayList<String>();
		return aux;
	}

	public void addRow() {
		row.add(mountRow());
	}
	
	public void addSimpleRow() {
		row.add(mountSimpleRow());
	}
	
	public void addTotalizador(String title, String value, boolean withMargin) {
		if (total.trim().equals("")) {
			total = "<div class=\"totalizador\" style=\"padding-top: 15px;\">"+ 
				"<label id=\"total\" name=\"total\" style=\"margin-left: 5px;\">"+ 
				value + "</label>" +			
				"<label id=\"labelTotal\" ";
			if (withMargin) {
				total += "style=\"margin-left: 15px;\" class=\"titleCounter\">" + 
					title + ": </label>"; 
			} else {
				total += " class=\"titleCounter\">" + title + ": </label>"; 
			}
		} else {
			total += "<label id=\"total\" name=\"total\" style=\"margin-left: 5px;\">"+ 
				value + "</label>" +
				"<label id=\"labelTotal\" ";
			if (withMargin) {
				total+= " style=\"margin-left: 15px;\" class=\"titleCounter\">" + 
					title + ": </label>"; 
			} else {
				total+= " class=\"titleCounter\">" + title + ": </label>"; 
			}
		}
	}
	
	public void addTotalizador(String title, String value, String id, boolean withMargin) {
		if (total.trim().equals("")) {
			total = "<div class=\"totalizador\" style=\"padding-top: 15px;\">"+ 
				"<label id=\"" + id + "\" name=\"total\" style=\"margin-left: 5px;\">"+ 
				value + "</label>" +			
				"<label id=\"labelTotal\" ";
			if (withMargin) {
				total += "style=\"margin-left: 15px;\" class=\"titleCounter\">" + 
					title + ": </label>"; 
			} else {
				total += " class=\"titleCounter\">" + title + ": </label>"; 
			}
		} else {
			total += "<label id=\"" + id + "\" name=\"total\" style=\"margin-left: 5px;\">"+ 
				value + "</label>" +
				"<label id=\"labelTotal\" ";
			if (withMargin) {
				total+= " style=\"margin-left: 15px;\" class=\"titleCounter\">" + 
					title + ": </label>"; 
			} else {
				total+= " class=\"titleCounter\">" + title + ": </label>"; 
			}
		}
	}
	
	
	public void addTotalizadorRight(String title, String value) {
		if (totalRight.trim().equals("")) {
			totalRight = "<div class=\"totalizadorRight\" style=\"padding-top: 15px;\">"+ 
				"<label id=\"labelTotal\" style=\"margin-left: 15px;\" class=\"titleCounter\">" + 
				title + ": </label>" +
				"<label id=\"total\" name=\"total\" style=\"margin-left: 5px\">"+ 
				value + "</label>";			
		} else {
			totalRight += "<label id=\"labelTotal\" style=\"margin-left: 15px;\" class=\"titleCounter\">" + 
				title + ": </label>" +
				"<label id=\"total\" name=\"total\" style=\"margin-left: 5px\">"+ 
				value + "</label>";
		}
	}
	
	public void addTotalizadorRight(String title, String value, String id) {
		if (totalRight.trim().equals("")) {
			totalRight = "<div class=\"totalizadorRight\" style=\"padding-top: 15px;\">"+ 
				"<label id=\"labelTotal\" style=\"margin-left: 15px;\" class=\"titleCounter\">" + 
				title + ": </label>" +
				"<label id=\"" + id + "\" name=\"total\" style=\"margin-left: 5px\">"+ 
				value + "</label>";			
		} else {
			totalRight += "<label id=\"labelTotal\" style=\"margin-left: 15px;\" class=\"titleCounter\">" + 
				title + ": </label>" +
				"<label id=\"" + id + "\" name=\"total\" style=\"margin-left: 5px\">"+ 
				value + "</label>";
		}
	}
	
	public void makeTotalizador() {
		total += "</div>"; 
	}
	
	
	public void makeTotalizadorRight() {
		totalRight+= "</div>";
	}

	public String getTable(int qtde) {
		String aux= header + "</tr></thead><tbody id=\"dataBank\" > ";
		for (String value : row) {
			aux+= value;
		}		
		aux+= "<input id=\"gridLines\" type=\"hidden\" value=\"" + 
			String.valueOf(qtde) + "\"/>";
		if (!order.trim().equals("")) {
			aux+= "<input id=\"orderGd\" type=\"hidden\" value=\"" + order + "\"/>";
		}
		aux+= "</tbody></table>" + total + totalRight + "</div>";
		return aux;
	}
	
	/*public String getTable(int qtde) {
		String aux= header + "</tr></thead><tbody id=\"dataBank\" > ";
		for (String value : row) {
			aux+= value;
		}		
		aux+= "<input id=\"gridLines\" type=\"hidden\" value=\"" + 
			String.valueOf(qtde) + "\"/>";
		if (!order.trim().equals("")) {
			aux+= "<input id=\"orderGd\" type=\"hidden\" value=\"" + order + "\"/>";
		}
		aux+= "</tbody></table>" +
				"<div class=\"totalizadorRight\" style=\"padding-top: 15px;\">" +
				"<label id=\"labelTotal\" style=\"margin-left: 15px;\" class=\"titleCounter\">Valor Total: </label>" +
				"<label id=\"total\" name=\"total\" style=\"margin-left: 5px\">500.00</label>" +
				"<label id=\"labelTotal\" style=\"margin-left: 15px;\" class=\"titleCounter\">Valor Total: </label>" +
				"<label id=\"total\" name=\"total\" style=\"margin-left: 15px\">500.00</label>" +
				"</div></div>";
		return aux;
	}*/
	
	
	
	public String getTable(String qtde) {
		String aux= header + "</tr></thead><tbody id=\"dataBank\" > ";
		for (String value : row) {
			aux+= value;
		}		
		aux+= "<input id=\"gridLines\" type=\"hidden\" value=\"" + 
			String.valueOf(qtde) + "\"/>";
		if (!order.trim().equals("")) {
			aux+= "<input id=\"orderGd\" type=\"hidden\" value=\"" + order + "\"/>";
		}
		aux+= "</tbody></table>" + total + totalRight + "</div>";
		return aux;
	}
	
	public String getBody(int qtde) {
		String aux= "";
		for (String value : row) {
			aux+= value;
		}
		aux+= "<input id=\"gridLines\" onLoad=\"mostraAlert();\" type=\"hidden\" value=\"" + 
			String.valueOf(qtde) + "\"/>";
		if (!order.trim().equals("")) {
			aux+= "<input id=\"orderGd\" type=\"hidden\" value=\"" + order + "\"/>";
		}
		return aux;
	}
	
	public String getBody(String qtde) {
		String aux= "";
		for (String value : row) {
			aux+= value;
		}
		aux+= "<input id=\"gridLines\" onLoad=\"mostraAlert();\" type=\"hidden\" value=\"" + 
			String.valueOf(qtde) + "\"/>";
		if (!order.trim().equals("")) {
			aux+= "<input id=\"orderGd\" type=\"hidden\" value=\"" + order + "\"/>";
		}
		return aux;
	}
}
