package com.marcsoftware.utilities;

import java.util.ArrayList;
import java.util.List;


import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Parametro;

public class WindowConfig {
	private String htm, campos;
	private Session session;
	private Transaction transaction;
	private Query query;
	private List<Parametro> parametros;
	private ArrayList<String> pipe;
	private ArrayList<String> subPipe;
	private int widthBox, heightBox, marginTopButton;
	
	public WindowConfig(int width, int height) {
		this.htm = "<div id=\"wdPai\" class=\"parametroWindow\" " +
				"style=\"height: "+ height + "px; width: " + width + 
				"px;\"><div class=\"cpDefaulWindowHeader\" style=\"" +
				"position: absolute;\">" +
				"<div id=\"WdLabel\" class=\"cpWindowLabelHeader\" " +
				"style=\"width: " + width + "px;\"><label id=\"WdHd\">" +
				"Configurador de Janela</label></div></div>" +
				"<div id=\"WdContente\" class=\"cpWindowContent\">";
	}
	
	public void addComponent(String id, String rotulo, String tipo, int px, int py, String data) {		
		String aux= "";
		switch (tipo.charAt(0)) {
		case 'r':			
			pipe = Util.unmountRealPipe(data);
			aux+= Util.getRealPipeById(data, 0);
			
			//monta label principal da radio
			this.htm += "<div id=\""+ id + "RdTitle\" style=\"top: " +
					py + "px; left: " +	px + "px; width: auto;\"><label id=\"lb" + id + 
					"RdTitle\" name=\"lb" + id + "RdTitle\">" +
					rotulo + "</label></div>";
			
			for (int i= 0; i < pipe.size(); i++) {
				//monta label de radio
				this.htm += "<div id=\""+ id + "RdLb" + i + "\" style=\"top: " +
				Util.getPipeById(pipe.get(i), 2) + "px; left: " +
				Util.getPipeById(pipe.get(i), 1) + "px;\"><label id=\"lb" + id + 
				"RdLabel" + i + "\" name=\"lb" + id + "RdLabel" + i + "\">" +
				Util.getPipeById(pipe.get(i), 0) + "</label></div>";
				
				//monta imagem da radio
				this.htm+= "<div id=\"" + id + "Rd" + i +"\" class=\"cpRadio\" " +
						"style=\"top: " + Util.getPipeById(pipe.get(i), 4) + "px; " +
						"left: " + Util.getPipeById(pipe.get(i), 3) + "px;\"><img " +
						"id=\"rdImg" + id + i + "\" class=\"cpRadioImg\" " +
						"src=\"../image/radio_clear.gif\"/></div>";
			}			
			break;

		case 'i':
			this.widthBox = Util.round(
					((Double.parseDouble(Util.getPart(data, 1)) - 45) / 2) - 15
				);
			this.heightBox = Util.round(Double.parseDouble(Util.getPart(data, 2)) - 90);
			this.marginTopButton = Util.round((this.heightBox - 40) / 2); 
			
			this.htm+= "<div id=\"selector" + id + "\" class=\"cpPrompt\" style=\"top: " +
					py + "px; left: " + px + "px;\"><div class=\"cpItemSelector\" " +
					"style=\"height: " + Util.getPart(data, 2) + "px; width: " +
					Util.getPart(data, 1) + "px;\"><div class=\"cpTitleItemSelector\">" +
					"<label>Configuração de Filtro</label></div>" +
					"<div class=\"cpLeftBoxItemSelector\" style=\"width: " + this.widthBox + 
					"px;\"><div class=\"tituloBoxItemSelector\"><label>valores</label></div>" +
					"<div id=\"selectorCarteiraL\" class=\"cpContentItemSelector\" " +
					"style=\"height: " + this.heightBox + "px;\"></div></div><div class=\"" +
					"cpButtonIttenSelector\" style=\"margin-top: " + this.marginTopButton + 
					"px;\"><input type=\"button\" onclick=\"tudoADireita()\" value=\">>\"/>" +
					"<br/><input type=\"button\" onclick=\"paraDireita()\" value=\">\"/><br/>" +
					"<input type=\"button\" onclick=\"paraEsquerda()\" value=\"<\"/><br/>" +
					"<input type=\"button\" onclick=\"tudoAEsquerda()\" value=\"<<\"/><br/>" +
					"</div><div class=\"cpRightBoxItemSelector\" style=\"width: " +
					this.widthBox + "px;\"><div class=\"tituloBoxItemSelector\"><label>" +
					"Selecionados</label></div><div id=\"selectorCarteiraR\" " +
					"class=\"cpContentItemSelector\" style=\"height: " + this.heightBox + 
					"px;\"/></div></div></div></div>";
			break;
			
		case 'c':			
			
		case 't':
			this.htm+= "<div id=\"lbText" + id + "\" style=\"top: " +
					py + "px; left: " + 
					px + "px;\"><label id=\"lbData\" name=\"lbData\">" +
					rotulo + "</label></div><div id=\"dataPrompt" + id + "\" style=\"top: " +
					Util.getPipeById(data, 1) + "px; left: " + Util.getPipeById(data, 0) +
					"px; width: " + (Integer.parseInt(Util.getPipeById(data, 2)) + 10) + "px;\">" +
					"<input id=\"prompt" + id + "\" type=\"text\" " +
					"style=\"width: " + Util.getPipeById(data, 2) + 
					"px;\" name=\"prompt" + id + "\"/></div>";
			break;
			
		case 'd':
			this.htm += "<div id=\"1lbText" + id + "\" style=\"top: " +
				py + "px; left: " + 
				px + "px;\"><label id=\"lbData\" name=\"lbData\">" +
				rotulo + "</label></div><div id=\"1dataPrompt" + id + "\" style=\"top: " +
				Util.getPipeById(data, 1) + "px; left: " + Util.getPipeById(data, 0) +
				"px; width: " + (Integer.parseInt(Util.getPipeById(data, 2)) + 10) + "px;\">" +
				"<input id=\"1prompt" + id + "\" type=\"text\" " +
				"style=\"width: " + Util.getPipeById(data, 2) + 
				"px;\" name=\"1prompt" + id + "\"/></div>";
			
			this.htm += "<div id=\"2lbText" + id + "\" style=\"top: " +
			Util.getPipeById(data, 5) + "px; left: " + 
			Util.getPipeById(data, 4) + "px;\"><label id=\"lbData\" name=\"lbData\">" +
			Util.getPipeById(data, 3) + "</label></div><div id=\"2dataPrompt" + id + "\" style=\"top: " +
			Util.getPipeById(data, 7) + "px; left: " + Util.getPipeById(data, 6) +
			"px; width: " + (Integer.parseInt(Util.getPipeById(data, 8)) + 10) + "px;\">" +
			"<input id=\"2prompt" + id + "\" type=\"text\" " +
			"style=\"width: " + Util.getPipeById(data, 8) + 
			"px;\" name=\"2prompt" + id + "\"/></div>";
			break;
			
		case 'k':
			this.htm += "<div id=\"checkPai" + id + "\" style=\"top: " + py + "px; left: " +
				px + "px;\" name=\"checkPai" + id  + "\"><img id=\"imgCheck" + id +
				"\" src=\"../image/unchecked_img.gif\" name=\"imgCheck" + id + "\"/>" +
				"</div><div id=\"ckTestelabelLabel\" class=\"cpLabelWindow\" " +
				"style=\"top: " + py + "px; left: " + (px + 25) +
				"px;\"><label id=\"ckTestelabel\" " +
				"name=\"ckTestelabel\">" + rotulo + "</label></div>";
			break;
		}
	}
	
	public void mountarFiltro(Long idRel) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		String aux= "";
		try {
			campos= "";
			query = session.createQuery("from Parametro as p where p.relatorio.codigo = :relatorio");
			query.setLong("relatorio", idRel);
			parametros = (List<Parametro>) query.list();
			for (int i = 0; i < parametros.size() ; i++) {
				switch (parametros.get(i).getComponente().charAt(0)) {
				case 'r':				
					//monta label principal da radio
					pipe = Util.unmountRealPipe(parametros.get(i).getDados());
					aux+= Util.getRealPipeById(parametros.get(i).getDados(), 0);
					this.htm += "<div id=\""+ parametros.get(i).getCodigo() +
							"RdTitle\" style=\"top: " +	parametros.get(i).getPy() + 
							"px; left: " +	parametros.get(i).getPx() + 
							"px; width: auto;\"><label id=\"lb" + 
							parametros.get(i).getCodigo() +	"RdTitle\" name=\"lb" + 
							parametros.get(i).getCodigo() + "RdTitle\">" +
							parametros.get(i).getRotulo() + "</label></div>";
					
					for (int j= 0; j < pipe.size(); j++) {
						//monta label de radio
						this.htm += "<div id=\""+ parametros.get(i).getCodigo() +
						"RdLb" + i + "\" style=\"top: " + 
						Util.getPipeById(pipe.get(j), 2) + "px; left: " +
						Util.getPipeById(pipe.get(j), 1) + "px;\"><label id=\"lb" + 
						parametros.get(i).getCodigo() +	"RdLabel" + j + 
						"\" name=\"lb" + parametros.get(i).getCodigo() + 
						"RdLabel" + j + "\">" +	Util.getPipeById(pipe.get(j), 0) + 
						"</label></div>";
						
						//monta imagem da radio
						this.htm+= "<div id=\"" + parametros.get(i).getCodigo() + 
								"Rd" + j +"\" class=\"cpRadio\" style=\"top: " + 
								Util.getPipeById(pipe.get(j), 4) + "px; " +
								"left: " + Util.getPipeById(pipe.get(j), 3) + 
								"px;\"><img id=\"" + parametros.get(i).getCodigo() + 
								"@" + i + "@" + Util.getPipeById(pipe.get(j), 5) +   
								parametros.get(i).getCodigo() + j + "\" class=\"cpRadioImg\" " +
								"onclick=\"setParamValue(this)\" ";
						if (j == 0) {
							this.htm+= "src=\"../image/radio_color.gif\"/></div>";
						} else {
							this.htm+= "src=\"../image/radio_clear.gif\"/></div>";
						}
					}
					break;

				case 'i':
					this.htm+= "<div id=\"selector" + //id + "\" class=\"cpPrompt\" style=\"top: " +
							//py + "px; left: " + px + "px;\"><div class=\"cpItemSelector\" " +
							"style=\"height: 150px; width: 750px;\"><div class=\"" +
							"cpTitleItemSelector\"><label>Configuração de Filtro</label></div>" +
							"<div class=\"cpLeftBoxItemSelector\" style=\"width: 337px;\">" +
							"<div class=\"tituloBoxItemSelector\"><label>valores</label></div>" +
							"<div id=\"selectorCarteiraL\" class=\"cpContentItemSelector\" " +
							"style=\"height: 60px;\"></div></div><div class=\"" +
							"cpButtonIttenSelector\" style=\"margin-top: 25px;\">" +
							"<input type=\"button\" onclick=\"tudoADireita()\" value=\">>\"/><br/>" +
							"<input type=\"button\" onclick=\"paraDireita()\" value=\">\"/><br/>" +
							"<input type=\"button\" onclick=\"paraEsquerda()\" value=\"<\"/><br/>" +
							"<input type=\"button\" onclick=\"tudoAEsquerda()\" value=\"<<\"/><br/>" +
							"</div><div class=\"cpRightBoxItemSelector\" style=\"width: 337px;\">" +
							"<div class=\"tituloBoxItemSelector\"><label>Selecionados</label>" +
							"</div><div id=\"selectorCarteiraR\" class=\"cpContentItemSelector\" " +
							"style=\"height: 60px;\"/></div></div></div></div>";
					break;
					
				case 'c':
					
					break;
					
				case 't':
					/*this.htm+= "<div id=\"lbText" + id + "\" style=\"top: " +
							py + "px; left: " + 
							px + "px;\"><label id=\"lbData\" name=\"lbData\">" +
							rotulo + "</label></div><div id=\"dataPrompt" + id + "\" style=\"top: " +
							Util.getPipeById(data, 1) + "px; left: " + Util.getPipeById(data, 0) +
							"px; width: " + (Integer.parseInt(Util.getPipeById(data, 2)) + 10) + "px;\">" +
							"<input id=\"prompt" + id + " type=\"text\" " +
							"style=\"width: " + Util.getPipeById(data, 2) + 
							"px;\" name=\"prompt" + id + "\"/></div>";*/
					break;
					
				case 'k':
					
					break;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
		}
	}
	
	public String getWindow() {
		this.htm+= "</div></div><input id=\"configWindow\" name=\"configWindow\" " +
				"value=\"\" type=\"hidden\"/>";
		return this.htm;
	}
}
