package com.marcsoftware.utilities;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.Transparency;
import java.awt.image.BufferedImage;
import java.io.UnsupportedEncodingException;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.Enumeration;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import org.hibernate.Transaction;

import org.hibernate.Session;
import org.mozilla.javascript.edu.emory.mathcs.backport.java.util.concurrent.ConcurrentHashMap;

import com.ibm.icu.util.Calendar;
import com.marcsoftware.database.Acesso;
import com.marcsoftware.database.HistoricoNavegacao;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Mensalidade;
import com.marcsoftware.database.ParcelaCompra;
import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.database.Unidade;

public class Util {
	//parametros do applet de impressão matricial
	//rel: string contendo o relatório;
	//porta: porta de impressão
	//next_page: página a ser redirecionada após a imoressão
	
	
	public static final String ERRO= "Acesso Negado!  Senha ou Nome de usuário invalido.\n";
	
	public static final String SENHA_INVALIDA= "Acesso Negado!  Senha ou Nome de usuário invalido.\n"; 
	
	public static final String ERRO_UPDATE = "Erro de atualização! Procure o administrador do sistema para maiores inforções";
	
	public static final String ERRO_INSERT= "Não foi possível salvar o arquivo devido a um erro interno, " +
			"procure o administrador do sistema para maiores inforamções.";
	
	public static final String SEM_REGISTRO= "Nenhum registro encontrado.";
	
	public static final String BD_IMG_PATH= "C:\\Arquivos de programas\\Apache Software " +
			"Foundation\\Tomcat 6.0\\webapps\\master\\application\\bd_img";
	
	public static final String BD_IMG_SRC = "bd_img/";
	
	public static final String BIRT_VIEWER= "http://localhost:8080/birt-viewer/";	
	
	public static final String BIRT_FRAMESET= "http://localhost:8080/birt-viewer/frameset?__report=";
	
	public static final String BIRT_RUN = "http://localhost:8080/birt-viewer/run?__report=";
	
	public static final String BIRT_PDF = "&__format=pdf";
	
	public static final String BIRT_HTML = "&__format=html";
	
	public static final String TEMP_BARCODE_PATH = "C:\\Arquivos de programas\\" +
			"Apache Software Foundation\\Tomcat 6.0\\webapps\\master.com\\application\\temp_barcode\\barcode";
	
	public static final String[] MES_LITERAL = {"Janeiro", "Fevereiro", "Março", "Abril",
		"Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"};
	
	public static final String URL_ENVIO_CCOB = "http://app.gruponewmed.com.br/ccob/ger/ft/{id}/dt/{data}/tk/{token}";
	//public static final String URL_ENVIO_CCOB = "http://app.net/ccob/ger/ft/{id}/dt/{data}/tk/{token}";
	
	public static final String URL_RETORNO_CCOB = "http://app.gruponewmed.com.br/ccob/ret/ft/{id}/dt/{data}/tk/{token}";
	//public static final String URL_RETORNO_CCOB = "http://app.net/ccob/ret/ft/{id}/dt/{data}/tk/{token}";
	
	public static final String URL_STATUS_CCOB = "http://app.gruponewmed.com.br/ccob/atst/id/{id}";
	//public static final String URL_STATUS_CCOB = "http://app.net/ccob/atst/id/{id}";
	
	public static final String URL_EXCLUI_CCOB = "http://app.gruponewmed.com.br/ccob/exarq/id/{id}";
	//public static final String URL_EXCLUI_CCOB = "http://app.net/ccob/exarq/id/{id}";
	
	
	public static final Map<String, String> ESTADO_LITERAL = new ConcurrentHashMap(){{
		put("AC", "Acre");
		put("AL", "Alagoas");
		put("AP", "Amapá");
		put("AM", "Amazonas");
		put("BA", "Bahia");
		put("CE", "Ceará");
		put("DF", "Distrito Federal");
		put("ES", "Espírito Santo");
		put("GO", "Goiás");
		put("MA", "Maranhão");
		put("MT", "Mato Grosso");
		put("MS", "Mato Grosso do Sul");
		put("MG", "Minas Gerais");
		put("PA", "Pará");
		put("PB", "Paraíba");
		put("PR", "Paraná");
		put("PE", "Pernambuco");
		put("PI", "Piauí");
		put("RJ", "Rio de Janeiro");
		put("RN", "Rio Grande do Norte");
		put("RS", "Rio Grande do Sul");
		put("RO", "Rondônia");
		put("RR", "Roraima");
		put("SC", "Santa Catarina");
		put("SP", "São Paulo");
		put("SE", "Sergipe");
		put("TO", "Tocantins");
	}};  
		
	public static String unMountDocument(String doc) {
		String aux= "";
		if (doc != null) {
			aux= doc.replace('.', '-');
			aux= aux.replace('/', '-');
			aux= aux.replaceAll("-", "");
		}
		return aux;
	}
	
	public static String removeAspas(String text) {
		if (text == null) {
			return "";
		} else {
			return text.replace("\'", "");
		}
	}
	
	public static String unMountDateSql(String data) {
		if (data == null) {
			return "";
		} else {
			String aux= data.substring(0, 4);
			data= data.substring(8, data.length()) + "/" + data.substring(5, 7) + "/" + aux;		
			return data;
		}
	}
	
	public static String mountDateSql(String data) {
		String aux= "";
		if (data != null) {
			aux = data.substring(6, data.length()) + "-" + data.substring(3, 5) + "-" + 
			data.substring(0, 2);
		}
		return aux;
	}
	
	public static String mountCnpj(String cnpj) {
		String aux= "";
		if (cnpj != null) {
			aux = cnpj.substring(0, 2) + "." + cnpj.substring(2, 5) + "." +
			cnpj.substring(5, 8) + "/" + cnpj.substring(8, 12) + "-" +
			cnpj.substring(12, cnpj.length());
		}
		return aux;
	}
	
	public static String mountCpf(String cpf) {
		if (cpf != null && !cpf.trim().isEmpty()) {
			String aux= cpf.substring(0, 3) + "." + cpf.substring(3, 6) + "."  +
				cpf.substring(6, 9) + "-" + cpf.substring(9, cpf.length());
			return aux;
		} else {
			return "";
		}
	}	
	
	public static int getDayDate(String date) {		
		return (date == null)? null: Integer.parseInt(date.substring(0,2));
	}
	public static int getMonthDate(String date) {		
		return (date == null)? null : Integer.parseInt(date.substring(3,5));
	}
	
	public static String getMonthLiteral(String date) {
		return (date == null)? null : MES_LITERAL[getMonthDate(date) - 1];
	}	
	
	public static int getYearDate(String date) {
		return (date == null)? null : Integer.parseInt(date.substring(6, date.length()));
	}
	
	public static int getDayDate(Date date) {		
		String aux= "";
		if (date != null) {
			aux =  parseDate(date, "dd/MM/yyyy");
		}
		return (aux.isEmpty())? null : Integer.parseInt(aux.substring(0,2));
	}
	
	public static int getMonthDate(Date date) {
		String aux= "";
		if (date != null) {
			aux = parseDate(date, "dd/MM/yyyy");
		}
		return (aux.isEmpty())? null : Integer.parseInt(aux.substring(3,5));		
	}
	
	public static String getMonthLiteral(Date date) {
		return (date == null)? null : MES_LITERAL[getMonthDate(date) - 1];
	}
	
	public static int getYearDate(Date date) {
		String aux= parseDate(date, "dd/MM/yyyy");
		return (date == null)? null : Integer.parseInt(aux.substring(6, aux.length()));
	}
	
	public static String getToday() {
		GregorianCalendar calendar= new GregorianCalendar();
		SimpleDateFormat format= new SimpleDateFormat("dd/MM/yyyy");		
		return format.format(calendar.getTime());
	}
	
	public static String getNow() {
		Date date = new Date();
		SimpleDateFormat parser = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
		try {
			String aux = parser.format(date);
			return aux.substring(10, aux.length());
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public static Date getZeroDate(String data) {	
		return (data == null || data.isEmpty())? null : parseDate(data.trim() + " 00:00:01", "HH:mm:ss");
	}
	
	public static Date getZeroDate(Date data) {		 
		return (data == null)? null : getZeroDate(parseDate(data, "dd/MM/yyyy"));
	}
	
	public static int getLastDayOfMonth(Date data) {
		return (data == null)? null : Integer.parseInt(new SimpleDateFormat("dd").format(new Date(getYearDate(data), getMonthDate(data), 0)));
	}
	
	public static int getLastDayOfMonth(String data) {
		return (data == null)? null :  Integer.parseInt(new SimpleDateFormat("dd").format(new Date(getYearDate(data), getMonthDate(data), 0)));
	}
	
	public static Date getLastDateOfMonth(String data) {
		String aux = new SimpleDateFormat("dd/MM").format(new Date(getYearDate(data), getMonthDate(data), 0));
		aux+= "/" + getYearDate(data);
		return parseDate(aux);
	}
	
	public static Date getLastDateOfMonth(Date data) {
		String aux = new SimpleDateFormat("dd/MM").format(new Date(getYearDate(data), getMonthDate(data), 0));
		aux+= "/" + getYearDate(data);
		return parseDate(aux);
	}
	
	public static String mountCep(String cep) {
		if (cep == null || cep.length() < 8) {
			return "";
		} else {
			return (cep == null || cep.isEmpty())? "" : cep.substring(0,cep.length() - 3) + "-" + 
					cep.substring(cep.length() - 3, cep.length());
		}
	}
	
	public static String getPart(String valor, int position) throws NullPointerException{
		String aux= "";
		int count= 1;
		for (int i = 0; i < valor.length(); i++) {
			if (count < position) {
				if (valor.charAt(i)== '@') {
					count++;
				}
				if (i == (valor.length() - 1)) {
					count = i + 1;
				}
			} else {
				count = i;
				break;
			}
		}
		for (int i = count ; i < valor.length(); i++) {
			if ((valor.charAt(i) != '@')) {
				 aux+= valor.charAt(i);
			} else {
				break;
			}
		}
		return aux;
	}
	
	public static boolean isEmpty(String value) {
		String aux= value.trim();
		return aux.isEmpty();
	}
	
	public static String encodeString(String valor, String padrao, String retorno) {
		String textAux = "";  
		byte[] aux;
		try {
			aux = valor.getBytes(padrao);
			textAux= new String(aux, retorno); 
		} catch (UnsupportedEncodingException e) {			
			e.printStackTrace();			
		}  
		return textAux;
	}
	
	public static String formatCurrency(String value) {		
		if (value.contains(".")) {
			String right= value.substring(0, value.indexOf("."));
			value= value.substring(value.indexOf("."), value.length());
			if (value.length() > 3) {
				value = value.substring(value.indexOf("."), value.indexOf(".") + 3);
			} else if (value.length() == 2){
				value+= "0";
			} else if (value.length() == 1) {
				value+= "00";
			}
			return right + value;
		} else {
			return value + ".00";
		}
	}
	
	public static double trunc(double value, int aproximacao) {
		String aux = String.valueOf(value);
		String intPart = aux.substring(0, aux.indexOf("."));		
		String decPart = aux.substring(aux.indexOf(".") + 1, aux.length());
		decPart = (aproximacao > decPart.length())? decPart.substring(0, decPart.length()) :
				decPart.substring(0, aproximacao);
		aux = intPart;
		aux += (decPart.length() > 0)? "." + decPart : "";		
		return Double.parseDouble(aux);
	}
	
	public static int trunc(double value) {
		String aux = String.valueOf(value);
		return Integer.parseInt(aux.substring(0, aux.indexOf(".")));
	}
	
	public static double round(double value, int aproximacao) {
		if (Double.isNaN(value)) {
			value = 0;
		}
		String aux = String.valueOf(value);
		String intPart = aux.substring(0, aux.indexOf("."));		
		String decPart = aux.substring(aux.indexOf(".") + 1, aux.length());
		if (decPart.length() > aproximacao) {
			if (Integer.parseInt(decPart.substring(aproximacao, aproximacao + 1)) > 4) {				
				decPart = decPart.substring(0, aproximacao);				
			} else {
				aux = String.valueOf(decPart.charAt(aproximacao -1));
				aux = (aux.equals("0"))? "0" : String.valueOf(Integer.parseInt(aux) - 1);
				decPart = decPart.substring(0, aproximacao - 1) + aux;
			}			 
		} else if (aproximacao == 0) {
			aux = decPart.substring(0, 1);
			if (Integer.parseInt(aux) < 5 && Integer.parseInt(aux) > 0) {
				aux = intPart.substring(intPart.length() -1, intPart.length());
				intPart = intPart.substring(0, intPart.length() -1) + 
					(Integer.parseInt(aux) - 1); 
			}
		}
		aux = intPart;
		aux += (decPart.length() > 0)? "." + decPart : "";
		return Double.parseDouble(aux);
	}
	
	public static int round(double value) {
		String aux = String.valueOf(value);
		String intPart = aux.substring(0, aux.indexOf("."));
		String decPart = aux.substring(aux.indexOf(".") + 1, aux.length());
		decPart = String.valueOf(decPart.charAt(0));
		if (Integer.parseInt(decPart) < 5 && Integer.parseInt(decPart) > 0) {
			aux = intPart.substring(intPart.length() - 1, intPart.length());
			intPart = intPart.substring(0, intPart.length() -1) + 
				(Integer.parseInt(aux) - 1);			
		}
		aux = intPart;	
		return Integer.parseInt(aux);
	}
	
	public static String formatCurrency(double valor) {
		String value = String.valueOf(valor);
		if (value.contains(".")) {
			String right= value.substring(0, value.indexOf("."));
			value= value.substring(value.indexOf("."), value.length());
			if (value.length() > 3) {
				value = value.substring(value.indexOf("."), value.indexOf(".") + 3);
			} else if (value.length() == 2){
				value+= "0";
			}			
			return right + value;
		} else {
			return value;
		}		
	}
	
	public static boolean isDate(String data) {
		String val[] = data.split("/");
		Integer valores[] = {0, 0, 0};
		boolean result = true;
		for (int i = 0; i < val.length; i++) {
			valores[i] = Integer.parseInt(val[i]);
			if (i == 0 && ((valores[i] < 0) || valores[i] > 31))  {
				result = false;
				break;
			} else if (i == 1 && ((valores[i] < 0) || valores[i] > 12)) {
				result = false;
				break;
			} else if (i == 2 && ((valores[i] < 1910) || valores[i] > 2100)) {
				result = false;
				break;
			}
		}
		return result;
	}
	
	public static Date parseDate(String date) {
		SimpleDateFormat format= new SimpleDateFormat("dd/MM/yyyy");
		try {
			return isDate(date)? format.parse(date) : null;
		} catch (ParseException e) {			
			e.printStackTrace();
			return null;
		}		
	}
	
	public static Date parseDate(String date, String format) {
		SimpleDateFormat parser = new SimpleDateFormat("dd/MM/yyyy " + format);
		try {
			return parser.parse(date);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}	
	}
	
	public static String parseDate(Date date, String format) {
		SimpleDateFormat parser= new SimpleDateFormat(format);
		try {
			return parser.format(date);
		} catch (Exception e) {			
			e.printStackTrace();
			return null;
		}		
	}
	
	
	public static String getTime(Date date) {
		SimpleDateFormat parser = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
		try {
			String aux = parser.format(date);
			return aux.substring(10, aux.length());
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public static String getSimpleTime(Date date) {
		SimpleDateFormat parser = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
		try {
			String aux = parser.format(date);
			return aux.substring(10, 16);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public static String initCap(String text) {
		String aux= "";
		text = (text == null)? "": text;
		if (!text.trim().equals("")) {
			Pattern pattern= Pattern.compile("( [A-Za-z])");
			Matcher matcher= pattern.matcher(text);
			text= text.substring(0, 1).toUpperCase() + text.substring(1);
			while (matcher.find()) {
				aux= matcher.group();			 
				text= text.replace(aux, aux.toUpperCase());			
			}
		}
		return text;
	}
	
	public static long diferencaYear(Date finalDate, Date inicialDate) {
		return diferencaMonth(finalDate, inicialDate)/12;
	}
	
	public static long diferencaMonth(Date finalDate, Date inicialDate) {				
		return diferencaDias(finalDate, inicialDate)/30;
	}
	
	public static long diferencaDias(Date finalDate, Date inicialDate){
		GregorianCalendar calendarStart= new GregorianCalendar();
		GregorianCalendar calendarOver= new GregorianCalendar();
		calendarStart.setTime(inicialDate);
		calendarOver.setTime(finalDate);		
		return (calendarOver.getTimeInMillis() - calendarStart.getTimeInMillis())/ (24 * 60 * 60 * 1000);
	}
	
	public static Date addYears(Date data,  int years) {
		GregorianCalendar aux = new GregorianCalendar();
		aux.setTime(data);		
		aux.add(Calendar.YEAR, years);		
		return aux.getTime();
	}
	
	public static Date addYears(String data,  int years) {
		GregorianCalendar aux = new GregorianCalendar();
		aux.setTime(parseDate(data));		
		aux.add(Calendar.YEAR, years);		
		return aux.getTime();
	}
	
	public static Date addMonths(Date data,  int meses) {
		GregorianCalendar aux = new GregorianCalendar();
		aux.setTime(data);		
		aux.add(Calendar.MONTH, meses);		
		return aux.getTime();
	}
	
	public static Date addMonths(String data,  int meses) {
		GregorianCalendar aux = new GregorianCalendar();
		aux.setTime(parseDate(data));		
		aux.add(Calendar.MONTH, meses);		
		return aux.getTime();
	}
	
	public static Date addDays(Date data,  int days) {
		GregorianCalendar aux = new GregorianCalendar();
		aux.setTime(data);
		aux.add(GregorianCalendar.DAY_OF_YEAR , days);
		return aux.getTime();
	}	
	
	public static Date addDays(String data,  int days) {
		GregorianCalendar aux = new GregorianCalendar();
		aux.setTime(parseDate(data));
		aux.add(GregorianCalendar.DAY_OF_YEAR , days);		
		return aux.getTime();
	}
	
	public static Date removeYears(Date data, int years) {
		GregorianCalendar aux = new GregorianCalendar();
		aux.setTime(data);
		aux.set (Calendar.YEAR , (years * (-1)));		
		return aux.getTime();
	}
	
	public static Date removeMonths(Date data, int months) {
		GregorianCalendar aux = new GregorianCalendar();
		aux.setTime(data);
		aux.add(GregorianCalendar.MONTH , (months * (-1)));		
		return aux.getTime();
	}
	
	public static Date removeDays(Date data, int days) {
		GregorianCalendar aux = new GregorianCalendar();
		aux.setTime(data);
		aux.add(GregorianCalendar.DAY_OF_YEAR , (days * (-1)));		
		return aux.getTime();
	}
	
	public static String zeroToLeft(String valor, int casas) {
		char aux[];
		if ((casas - valor.length()) > 0) {
			aux= new char[casas - valor.length()];			
			Arrays.fill(aux, '0');
			valor = String.copyValueOf(aux) + valor;
		}
		return valor;
	}
	
	public static String zeroToLeft(Long valor,  int casas) {
		char aux[];
		String valorStr = String.valueOf(valor);
		if ((casas - valorStr.length()) > 0) {
			aux= new char[casas - valorStr.length()];			
			Arrays.fill(aux, '0');
			valorStr = String.copyValueOf(aux) + valorStr;
		}
		return valorStr;
	}
	
	public static String zeroToLeft(int valor,  int casas) {
		char aux[];
		String valorStr = String.valueOf(valor);
		if ((casas - valorStr.length()) > 0) {
			aux= new char[casas - valorStr.length()];			
			Arrays.fill(aux, '0');
			valorStr = String.copyValueOf(aux) + valorStr;
		}
		return valorStr;
	}
	
	public static String removeZeroLeft(String valor) {		
		while (valor.charAt(0) == '0') {
			valor = valor.substring(1, valor.length());
		}
		return valor;
	}	
	
	public static double calculaAtraso(double nominal, double taxa, Date vencimento) {
		Date aux= new Date();
		long months = 0;
		if (aux.after(vencimento)) {
			months = diferencaMonth(aux, vencimento);
			if (months > 0 ) {
				nominal = nominal * Math.pow((1 + taxa/100), months);
			} else {
				months = 1;
				nominal = nominal * Math.pow((1 + taxa/100), months);
			}
		}
		return Double.valueOf(formatCurrency(String.valueOf(nominal)));
	}
	
	public static double calculaAtraso(double nominal, double taxa, double multa, Date vencimento) {
		Date aux= new Date();
		long months = 0;
		multa = multa/100;
		if (aux.after(vencimento)) {
			months = diferencaMonth(aux, vencimento);
			if (months < 1) {
				nominal = nominal * (multa + 1);
			}else if (months >= 1 ) {
				multa = nominal * multa;
				nominal = nominal * Math.pow((1 + taxa/100), months);
				nominal+= multa;
			}
		}
		return Double.valueOf(formatCurrency(String.valueOf(nominal)));
	}
	
	public static double getOperacional(double operacional, double cliente, double parcela) {
		return operacional * (parcela / cliente);	 		
	}
	
	public static int getMesBase() {
		Date now = new Date();
		return getMonthDate(parseDate(now, "dd/MM/yyyy"));
	}
	
	public static int getAnoBase() {
		Date now = new Date();
		return getYearDate(parseDate(now, "dd/MM/yyyy"));
	}
	
	public static ArrayList<Long> unmountPipeline(String pipeline) {
		ArrayList<Long> pipe = new ArrayList<Long>();
		String aux= "";
		for (char pp : pipeline.toCharArray()) {
			if (pp == '@') {
				pipe.add(Long.valueOf(aux));
				aux = "";
			} else {
				aux+= pp;
			}
		}
		pipe.add(Long.valueOf(aux));
		return pipe;
	}
	
	public static ArrayList<String> unmountPipelineStr(String pipeline) {
		ArrayList<String> pipe = new ArrayList<String>();
		String aux= "";
		for (char pp : pipeline.toCharArray()) {
			if (pp == '@') {
				pipe.add(aux);
				aux = "";
			} else {
				aux+= pp;
			}
		}
		pipe.add(aux);
		return pipe;
	}
	
	public static ArrayList<String> unmountRealPipe(String pipeline) {
		ArrayList<String> pipe = new ArrayList<String>();
		String aux = "";
		for (char pp : pipeline.toCharArray()) {
			if (pp == '|') {
				pipe.add(aux);
				aux= "";
			} else {
				aux+= pp;
			}
		}
		if (aux != "") {
			pipe.add(aux);
		}
		return pipe;
	}
	
	public static ArrayList<String> unmountRealPipeWithSpace(String pipeline) {
		ArrayList<String> pipe = new ArrayList<String>();
		String aux = "";
		for (char pp : pipeline.toCharArray()) {
			if (pp == '|') {
				pipe.add(aux);
				aux= "";
			} else {
				aux+= pp;
			}
		}	
		pipe.add(aux);
		return pipe;
	}	
	
	public static String getPipeById(String pipeline, int id) {
		int count = 0;
		int start = 0;
		String text = "";
		if (id == 0) {
			start = 0;
		} else {
			for(int i = 0; i < pipeline.length(); i++) {
				if (pipeline.charAt(i) == '@') {
					count++;
					if (count == id) {
						start = i + 1;
						break;
					}
				}
			}		
		}
		for (int i = start; i < pipeline.length(); i++) {
			if (pipeline.charAt(i) != '@') {
				text+= pipeline.charAt(i);
			} else {
				break;
			}
		}
		return text;
	}
	
	public static String getRealPipeById(String pipeline, int id) {
		int count = 0;
		int start = 0;
		String text = "";
		if (id == 0) {
			start = 0;
		} else {
			for(int i = 0; i < pipeline.length(); i++) {
				if (pipeline.charAt(i) == '|') {
					count++;
					if (count == id) {
						start = i + 1;
						break;
					}
				}
			}		
		}
		for (int i = start; i < pipeline.length(); i++) {
			if (pipeline.charAt(i) != '|') {
				text+= pipeline.charAt(i);
			} else {
				break;
			}
		}
		return text;
	}
	
	public static String getIcon(Date vencimento, String status) {		
		Date now = new Date();
		if (status.trim().equals("a") && vencimento.after(now)) {
			return "../image/ok_icon.png";
		} else if (status.trim().equals("a") && vencimento.before(now)) {
			return "../image/atraso.png";
		} else if (status.trim().equals("n") && vencimento.after(now)) {
			return "../image/negociado.png";
		} else if (status.trim().equals("n") && vencimento.before(now)) {
			return "../image/atraso_negociado.png";
		} else if (status.trim().equals("q") || status.trim().equals("f")) {
			return "../image/ok_icon.png";
		} else if (status.equals("e")){
			return "../image/estorno.png";
		} else {
			return "../image/cancelado.png";
		}
	}
	
	public static String getRealIcon(Date vencimento, String status) {
		Date now = new Date();
		if (status.trim().equals("a") && vencimento.after(now)) {
			return "../image/inactive_icon.png";
		} else if (status.trim().equals("a") && vencimento.before(now)) {
			return "../image/atraso.png";
		} else if (status.trim().equals("n") && vencimento.after(now)) {
			return "../image/negociado.png";
		} else if (status.trim().equals("n") && vencimento.before(now)) {
			return "../image/atraso_negociado.png";
		} else if (status.trim().equals("q") || status.trim().equals("f")) {
			return "../image/ok_icon.png";
		} else {
			return "../image/cancelado.png";
		}
	}
	
	public static String getIcon(List valor, String tipo) {
		int neg = 0;
		int negAtraso= 0;
		int atraso = 0;
		int cancelado = 0;
		String teste = "";
		Date now = new Date();
		Date datautil;
		if (tipo == "mensalidade") {
			List<Mensalidade> mensalidade = (List<Mensalidade>) valor;
			for (Mensalidade mens : mensalidade) {
				if (mens.getLancamento().getStatus().trim().equals("a") && 
						mens.getLancamento().getVencimento().before(now)) {
					atraso++;
				} else if (mens.getLancamento().getStatus().trim().equals("n") && 
						mens.getLancamento().getVencimento().after(now)) {
					neg++;
				} else if (mens.getLancamento().getStatus().trim().equals("n") && 
						mens.getLancamento().getVencimento().before(now)) {
					negAtraso++;
				}
			}
		} else if (tipo == "orcamento") {
			List<ParcelaOrcamento> parcela = (List<ParcelaOrcamento>) valor;
			for (ParcelaOrcamento parc : parcela) {
				teste = parc.getId().getOrcamento().getStatus();
				datautil = parc.getId().getLancamento().getVencimento();
				if (parc.getId().getLancamento().getStatus().trim().equals("a") && 
						parc.getId().getLancamento().getVencimento().before(now)) {
					atraso++;
				} else if (parc.getId().getLancamento().getStatus().trim().equals("n") && 
						parc.getId().getLancamento().getVencimento().after(now)) {
					neg++;
				} else if (parc.getId().getLancamento().getStatus().trim().equals("n") && 
						parc.getId().getLancamento().getVencimento().before(now)) {
					negAtraso++;
				} else if (parc.getId().getLancamento().getStatus().trim().equals("c")) {
					cancelado++;
				}
			}
		} else if (tipo == "compra") {	
			List<ParcelaCompra> parcela = (List<ParcelaCompra>) valor;
			for (ParcelaCompra parc : parcela) {				
				datautil = parc.getId().getLancamento().getVencimento();
				if (parc.getId().getLancamento().getStatus().trim().equals("a") && 
						parc.getId().getLancamento().getVencimento().before(now)) {
					atraso++;
				} else if (parc.getId().getLancamento().getStatus().trim().equals("n") && 
						parc.getId().getLancamento().getVencimento().after(now)) {
					neg++;
				} else if (parc.getId().getLancamento().getStatus().trim().equals("n") && 
						parc.getId().getLancamento().getVencimento().before(now)) {
					negAtraso++;
				} else if (parc.getId().getLancamento().getStatus().trim().equals("c")) {
					cancelado++;
				}
			}
		} else {
			List<Lancamento> lancamento = (List<Lancamento>) valor;
			for (Lancamento lanc : lancamento) {
				if (lanc.getStatus().trim().equals("a")
						&& lanc.getVencimento().before(now)) {
					atraso++;					
				} else if (lanc.getStatus().trim().equals("n")
						&& lanc.getVencimento().after(now)){
					neg++;
				} else if (lanc.getStatus().trim().equals("n")
						&& lanc.getVencimento().before(now)) {
					negAtraso++;
				} else if (lanc.getStatus().trim().equals("c")) {
					cancelado++;
				}
			}
		}
		
		if ((cancelado > 0) && (cancelado == valor.size())) {
			return "../image/cancelado.png";
		} else if (negAtraso > 0) {
			return "../image/atraso_negociado.png";
		} else if (neg > 0) {
			return "../image/negociado.png";
		} else if (atraso > 0) {
			return "../image/atraso.png";
		} else {		
			return "../image/ok_icon.png";
		}			
	}
	
	public static String getIconMax(List valor) {
		int atraso, negociado, negAtraso, aberto, fechado, cancelado, estornado, conciliado;
		atraso = negociado = negAtraso = aberto = fechado = cancelado = estornado = conciliado = 0;
		Date datautil, now;
		now = new Date();
		boolean isOpen = true; 
		List<ParcelaOrcamento> parcela = (List<ParcelaOrcamento>) valor;
		for (ParcelaOrcamento parc : parcela) {
			if (isOpen) {
				isOpen = false;
			}
			datautil = parc.getId().getLancamento().getVencimento();
			if (parc.getId().getLancamento().getStatus().trim().equals("a") && 
					datautil.before(now)) {
				atraso++;
			} else if (parc.getId().getLancamento().getStatus().trim().equals("n") && 
					parc.getId().getLancamento().getVencimento().after(now)) {
				negociado++;
			} else if (parc.getId().getLancamento().getStatus().trim().equals("n") && 
					parc.getId().getLancamento().getVencimento().before(now)) {
				negAtraso++;
			} else if (parc.getId().getLancamento().getStatus().trim().equals("c")) {
				cancelado++;
			} else if (parc.getId().getLancamento().getStatus().trim().equals("e")) {
				estornado++;
			} else if (parc.getId().getLancamento().getStatus().trim().equals("f")
					|| parc.getId().getLancamento().getStatus().trim().equals("q")) {
				fechado ++;
			}
		}
		if (isOpen) {
			return "../image/em_aberto.gif";
		} else if (parcela.size() == fechado) {
			return "../image/fechado.gif";
		} else if (estornado > 0) {
			return "../image/estorno.gif";
		} else if ((cancelado > 0) && (cancelado == valor.size())) {
			return "../image/cancelado.png";
		} else if (negAtraso > 0) {
			return "../image/atraso_negociado.png";
		} else if (negociado > 0) {
			return "../image/negociado.png";
		} else if (atraso > 0) {
			return "../image/atraso.png";
		} else {		
			return "../image/ok_icon.png";
		}
	}
	
	public static String getIcon(String status) {
		if (status.trim().equals("a")) {
			return "../image/ok_icon.png";
		} else if (status.trim().equals("c")){
			return "../image/cancelado.png";
		} else {
			return "../image/negociado.png";
		}		
	}
	
	public static String getStatus(Date vencimento, String status) {
		Date now = new Date();
		if (status.trim().equals("a") && vencimento.after(now)) {
			return "Ok";
		} else if (status.trim().equals("a") && vencimento.before(now)) {
			return "Atraso";
		} else if (status.trim().equals("n") && vencimento.after(now)) {
			return "Neg.";
		} else if (status.trim().equals("n") && vencimento.before(now)) {
			return "Atraso";
		} else if (status.trim().equals("q")) {
			return "Ok";
		} else if(status.trim().equals("e")) {
			return "Estor.";
		} else {
			return "Canc.";
		}
	}
	
	public static String getUnidadeIn(List<Unidade> unidadeList) {
		String aux = "(";
		boolean isFirst = true;
		for (Unidade unidade : unidadeList) {
			if (isFirst) {
				aux+= unidade.getCodigo(); 
			} else {
				aux+= ", " + unidade.getCodigo();
			}
		}
		aux+= ")";
		return aux;
	}
	
	public static String prepareStrSqlIn(String text) {
		text = text.replace(";", ",");
		String aux = "";
		for (int i = 0; i < text.toCharArray().length ; i++) {
			if (text.charAt(i) == ',') {
				aux+= "\'" + text.charAt(i) + "\'";
			} else if (i == 0) {
				aux+= "\'" + text.charAt(i);
			} else if (i == (text.toCharArray().length - 1)) {
				aux+= text.charAt(i) + "\'";
			} else {
				aux+= text.charAt(i);				
			}
		}
		return aux;
	}
	
	public static String getUrlFromPage(HttpServletRequest request, String pagina) {
		String totalUrl = request.getRequestURL().toString();
		return totalUrl.replace(pagina, "");
	}
	
	public static String linkToNewPage(HttpServletRequest request, String from, String to) {
		return getUrlFromPage(request, from) + to;
	}
	
	public static String getFirstName(String name) {
		String aux = "";
		for (int i = 0; i < name.length(); i++) {
			if (name.charAt(i) != ' ') {
				aux+= name.charAt(i);
			} else {
				break;
			}
		}
		return aux;
	}
	
	private void testeUnmountPipe(String pipe) {
		ArrayList<String> rows = new ArrayList<String>();	
		String text = "";
		for (int i = 0; i < pipe.length(); i++) {		
			if (pipe.charAt(i)!= '@') {
				text += pipe.charAt(i);		
			} else {
				rows.add(text);
				text = "";
			}
		}
		rows.add(text);
	}
	
	public static String convertObjStr(String textObject) {
		textObject = textObject.replace("[", "");
		textObject = textObject.replace("]", "");
		textObject = textObject.replace(",", "@");
		return textObject;
	}
	
	public static BufferedImage getScaledInstance(BufferedImage img, int targetWidth, int targetHeight, 
			Object hint, boolean higherQuality)	{
		int type = (img.getTransparency() == Transparency.OPAQUE) ?
				BufferedImage.TYPE_INT_RGB : BufferedImage.TYPE_INT_ARGB;
		BufferedImage ret = (BufferedImage)img;
		int w, h;
		if (higherQuality) {
			// Use multi-step technique: start with original size, then
			// scale down in multiple passes with drawImage()
			// until the target size is reached
			w = img.getWidth();
			h = img.getHeight();
		} else {
			// Use one-step technique: scale directly from original
			// size to target size with a single drawImage() call
			w = targetWidth;
			h = targetHeight;
		}

		do {
			if (higherQuality && w > targetWidth) {
				w /= 2;
				if (w < targetWidth) {
					w = targetWidth;
				}
			}

			if (higherQuality && h > targetHeight) {
				h /= 2;
				if (h < targetHeight) {
					h = targetHeight;
				}
			}

			BufferedImage tmp = new BufferedImage(w, h, type);
			Graphics2D g2 = tmp.createGraphics();
			g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION, hint);
			g2.drawImage(ret, 0, 0, w, h, null);
			g2.dispose();

			ret = tmp;
		} while (w != targetWidth || h != targetHeight);

		return ret;
	}
	
	public static void historico_inactive(Session session, Long idAcesso, String url) {
		boolean sessionIsOpen = (session == null);
		if (sessionIsOpen) {
			session = HibernateUtil.getSession();
		}
		Transaction transaction = session.beginTransaction();
		try {
			Acesso acesso = (Acesso) session.load(Acesso.class, idAcesso);
			HistoricoNavegacao historico = new HistoricoNavegacao();
			historico.setAcesso(acesso);
			historico.setData(new Date());
			historico.setUrl(url);
			session.save(historico);
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
		} finally {
			if (sessionIsOpen) {
				session.close();
			}
		}
	}
	
	public static void historico(Session session, Long idAcesso, HttpServletRequest request) {		
		if (!request.getSession().getAttribute("perfil").equals("d")) {
			String aux = "";
			boolean isFirst = true;
			boolean sessionIsOpen = (session != null);
			if (!sessionIsOpen || !session.isOpen()) {
				session = HibernateUtil.getSession();
			}
			String url = request.getRequestURI();
			Enumeration<String> parametros = request.getParameterNames();
			while (parametros.hasMoreElements()) {
				aux = (String) parametros.nextElement();
				url+= (isFirst)? "?" + aux + "=" + request.getParameter(aux) 
						: "&" + aux + "=" + request.getParameter(aux);
				isFirst = false;
			}
			Transaction transaction = session.beginTransaction();
			try {
				Acesso acesso = (Acesso) session.load(Acesso.class, idAcesso);
				HistoricoNavegacao historico = new HistoricoNavegacao();
				historico.setAcesso(acesso);
				historico.setData(new Date());
				historico.setUrl(url);
				session.save(historico);
				session.flush();
				transaction.commit();
			} catch (Exception e) {
				e.printStackTrace();
				transaction.rollback();
			} finally {
				if (!sessionIsOpen) {
					session.close();
				}
			}
		}
	}
	
	public static String geraPalavra(int length) {
		String result = "";
		Random random = new Random();
		String[] abc = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
				"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}; 
		for (int i = 0; i < length; i++) {
			result+= abc[random.nextInt(abc.length)];
		}
		return result;
	}
	
	public static String MD5(String md5) {
	   try {
	        java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
	        byte[] array = md.digest(md5.getBytes());
	        StringBuffer sb = new StringBuffer();
	        for (int i = 0; i < array.length; ++i) {
	          sb.append(Integer.toHexString((array[i] & 0xFF) | 0x100).substring(1,3));
	       }
	        return sb.toString();
	    } catch (java.security.NoSuchAlgorithmException e) {
	    }
	    return null;
	}
	
	public static String statusLiteral(String status) {
		if (status == null || status.isEmpty()) {
			return "Selecione";
		} else {
			switch (status.charAt(0)) {		
			case 'N':
				return "Não Enviar - Pag. Esc.";			
			case 'I':
				return "Para Enviar";		
			case 'E':
				return "Enviado";
			case 'A':
				return "Para Alterar - UC";
			case 'C':
				return "Para Cancelar";
			case 'L':
				return "Cancelado";
			case 'R':
				return "Com Falta ou Erro de Dados";
			case 'D':
				return "Com Contas em Atraso";
			case 'S':
				return "Sem Conta de Energia Elétrica";
			case 'B':
				return "Ocorrência de Erro na CPFL";
			case 'T':
				return "Lista Negra da CPFL";			
			case 'G':
				return "Lista Negra do Plano";			
			case 'M':
				return "Houve troca de Titularidade";			
			case 'U':
				return "Duplicidade de Cobrança na mesma UC";
			case 'F':
				return "Aguardando Definição";			
			default:
				return "Selecione";
			}
		}
	}
}
