package com.marcsoftware.utilities;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.net.URL;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JRParameter;
import net.sf.jasperreports.engine.JRResultSetDataSource;
import net.sf.jasperreports.engine.JasperReport;
import net.sf.jasperreports.engine.JasperRunManager;
import net.sf.jasperreports.engine.util.JRLoader;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Acesso;
import com.marcsoftware.database.ConnectionFactory;
import com.marcsoftware.database.HistoricoNavegacao;
import com.marcsoftware.database.Parametro;
import com.marcsoftware.database.Relatorio;

public class RelatorioAdmin {
	public String path, sql, link, realPath;
	private List<Parametro> parametro;
	private Relatorio relatorio;
	private HashMap parameters;
	private Session session;
	private Transaction transaction;
	private Query query;
	private PreparedStatement statement;
	private ResultSet resultSet;
	private boolean isSqlDinamic;	
	private ArrayList<ReportParametro> rpParametro;
	private JasperReport report;
	private JRResultSetDataSource jrRs;
	
	public RelatorioAdmin(String path, Long id, Long acessoId) {
		path = path.replace('\\', '/');
		this.realPath= path + "/";		
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		query = session.createQuery("from Relatorio as r where r.codigo = :relatorio");
		query.setLong("relatorio", id);
		relatorio = (Relatorio) query.uniqueResult();
		Acesso acesso = (Acesso) session.load(Acesso.class, acessoId);		
		HistoricoNavegacao historico = new HistoricoNavegacao();
		historico.setAcesso(acesso);
		historico.setData(new java.util.Date());
		historico.setUrl("relatorio: " + relatorio.getNome());
		session.save(historico);
		query = session.createQuery("from Parametro as p where p.relatorio = :relatorio");
		query.setEntity("relatorio", relatorio);
		parametro = (List<Parametro>) query.list();
		transaction.commit();
		session.close();
		isSqlDinamic = relatorio.getDinamico().trim().equals("t");
		this.path = path + relatorio.getDescricao();
		this.path = this.path.replace('\\', '/');
	}
	
	private boolean haveReport(String text) {
		String aux = "";
		for (int i = text.toCharArray().length; i < text.toCharArray().length - 6; i--) {
			aux+= text.charAt(i);
		}
		return aux.trim().equalsIgnoreCase("report");
	}
	
	
	public byte[] getOutput() throws SQLException, JRException, FileNotFoundException {
		byte[] retorno = null;
		Connection connection = ConnectionFactory.getConnection();
		parameters = new HashMap();
		Locale locale = new Locale("pt", "BR");
		parameters.put(JRParameter.REPORT_LOCALE, locale);
		ArrayList<ParamValues> values = new ArrayList<ParamValues>();
		ArrayList<String> in;
		String aux= "";
		boolean isFirst = true;
		FileInputStream fis = new FileInputStream(this.path);
		BufferedInputStream arquivo = new BufferedInputStream(fis);
		if (isSqlDinamic) {
			sql = relatorio.getComando();
			if (rpParametro != null && rpParametro.size() > 0) {
				values = new ArrayList<ParamValues>();
				in = new ArrayList<String>();
				for (ReportParametro param: rpParametro) {					
					if (param.getRequerido() 
							|| ((!param.getRequerido() && (param.getValue() != null)
							&& (!param.getValue().trim().equals(""))))) {
						if (param.getOperador().trim().equals("ls")
								|| param.getOperador().trim().equals("le")
								|| param.getOperador().trim().equals("la")) {
							sql+= " and " + param.getField() + " like ?";						
						} else if (param.getOperador().trim().equals("=")) {
							sql+= " and " + param.getField() + " = ?";
						} else if (param.getOperador().trim().equals("<")) {
							sql+= " and " + param.getField() + " < ?";						
						} else if (param.getOperador().trim().equals(">")) {
							sql+= " and " + param.getField() + " > ?";						
						} else if (param.getOperador().trim().equals("<>")) {
							sql+= " and " + param.getField() + " <> ?";
						} else if (param.getOperador().trim().equals("b")) {
							aux = param.getValue().replace("?", "@");						
							if (!aux.trim().equals("")) {
								sql+= " and (" + param.getField() + " between ? and ?)";
								values.add(new ParamValues(Util.getPart(aux, 1), param.getTipo()));
								values.add(new ParamValues(Util.getPart(aux, 2), param.getTipo()));
							}
						} else if (param.getOperador().trim().equals("in")) {						
							aux = (param.getValue() == null)? "" : param.getValue().replace(",", "@");
							aux = aux.replace(";", "|");
							if (!aux.trim().equals("")) {
								sql+= " and " + param.getField() + " in(";
								in = Util.unmountPipelineStr(aux);
								for (String pp : in) {
									if (isFirst) {
										sql+= "?";
										isFirst = false;
									} else {
										sql+= ", ?";
									}
									values.add(new ParamValues(pp, param.getTipo()));
								}
								sql+= ") ";
								isFirst = true;
							}
						}
						
						if (param.getOperador().trim().equals("ls")) {
							values.add(new ParamValues(param.getValue() + "%", param.getTipo()));						
						} else if (param.getOperador().trim().equals("le")) {
							values.add(new ParamValues("%" + param.getValue(), param.getTipo()));
						} else if (param.getOperador().trim().equals("la")) {
							values.add(new ParamValues("%" + param.getValue() + "%", param.getTipo()));						
						} else if ((!param.getOperador().equals("in")) 
								&& (!param.getOperador().equals("cn"))
								&& (!param.getOperador().equals("b"))) {						
							values.add(new ParamValues(param.getValue(), param.getTipo()));				
						}
					}										
				}
			}
			sql+=  " " + relatorio.getOrdem();
			statement = connection.prepareStatement(sql);
			for (int i = 0; i < values.size(); i++) {
				switch (values.get(i).getTipo().charAt(0)) {
				case 's':
					statement.setString(i + 1, values.get(i).getValue());						
					break;

				case 'i':
					statement.setInt(i + 1, Integer.parseInt(values.get(i).getValue()));
					break;
					
				case 'd':
					//statement.setString(i + 1, Util.mountDateSql(values.get(i).getValue()));
					//statement.setDate(i + 1, (Date) Util.parseDate(values.get(i).getValue()));
					statement.setDate(i + 1, Date.valueOf(Util.mountDateSql(values.get(i).getValue())));
					break;
				
				case 'f':
					statement.setDouble(i + 1, Double.parseDouble(values.get(i).getValue()));
					break;
					
				case 'l':
					statement.setLong(i + 1, Long.valueOf(values.get(i).getValue()));
					break;
				}
			}
			resultSet = statement.executeQuery();
			/*while (resultSet.next()) {
				System.out.print(resultSet.getObject(1).toString());
				System.out.print(resultSet.getObject(2).toString());
				System.out.print(resultSet.getObject(3).toString());
				System.out.print(resultSet.getObject(4).toString());
				System.out.print(resultSet.getObject(5).toString());
				System.out.print(resultSet.getObject(6).toString());
				System.out.print(resultSet.getObject(7).toString());
				System.out.print(resultSet.getObject(8).toString());
				System.out.print(resultSet.getObject(9).toString());
			}*/
			
			 
			
			jrRs = new JRResultSetDataSource(resultSet);				
			report = (JasperReport) JRLoader.loadObject(arquivo);
			parameters.put("CONTEXT_PATH", this.realPath);
			for (Parametro param : parametro) {
				if (param.getOperador().equals("cn")) {
					parameters.put("CONEXAO_EXTERNA", connection);
					/*for (ReportParametro rp : rpParametro) {
						if (rp.getNome().equals(param.getDescricao())) {
							parameters.put(rp.getNome(), rp.getConnection());
						}
					}*/
				}
			}
			retorno = JasperRunManager.runReportToPdf(report, parameters, jrRs);			
		} else {
			report = (JasperReport) JRLoader.loadObject(arquivo);
			parameters.put("CONTEXT_PATH", this.realPath);
			if (rpParametro != null && rpParametro.size() > 0) {
				for (ReportParametro param : rpParametro) {
					if (param.getOperador().trim().equals("ls")) {
						parameters.put(param.getNome(), param.getValue() + "%");
					} else if (param.getOperador().trim().equals("le")) {
						parameters.put(param.getNome(), "%" + param.getValue());
					} else if (param.getOperador().trim().equals("la")) {
						parameters.put(param.getNome(), "%" + param.getValue() + "%");
					} else if (!param.getOperador().equals("in")) {
						switch (param.getTipo().charAt(0)) {
						case 's':
							parameters.put(param.getNome(), param.getValue());
							break;

						case 'i':
							if (param.getValue() != null) {
								parameters.put(param.getNome(), Integer.parseInt(param.getValue()));
							}
							break;
							
						case 'l':
							if (param.getValue() != null) {
								parameters.put(param.getNome(), (param.getValue().trim().equals(""))?
										null : Long.valueOf(param.getValue()));
							}
							break;
							
						case 'f':
							if (param.getValue() != null) {
								parameters.put(param.getNome(), Double.parseDouble((param.getValue())));
							}
							break;
						
						case 'd':
							if (param.getValue() != null) {
								parameters.put(param.getNome(), Util.parseDate(param.getValue()));
							}
							break;						
						}						
					} else {
						switch (param.getTipo().charAt(0)) {
						case 's':
							parameters.put(param.getNome(), param.getValue());
							break;
							
						case 'i':
							parameters.put(param.getNome(), Integer.parseInt(param.getValue()));
							break;
							
						case 'l':
							parameters.put(param.getNome(), Long.valueOf(param.getValue()));
							break;
							
						case 'f':
							parameters.put(param.getNome(), Double.parseDouble((param.getValue())));
							break;
							
						case 'd':
							parameters.put(param.getNome(), Util.parseDate(param.getValue()));
							break;						
						}						
					}
				}
			}
			retorno = JasperRunManager.runReportToPdf(report, parameters, connection);
		}
		
		if (rpParametro != null && rpParametro.size() > 0) {
			for (ReportParametro rp : rpParametro) {
				if (rp.getOperador().equals("cn")) {
					rp.closeConnection();
				}
			}
		}
		connection.close();		
		return retorno;
	}
	
	
	public String getHtm() throws JRException, SQLException {
		Connection connection = ConnectionFactory.getConnection();
		parameters = new HashMap();
		Locale locale = new Locale("pt", "BR");
		parameters.put(JRParameter.REPORT_LOCALE, locale);
		if (rpParametro != null && rpParametro.size() > 0) {
			for (ReportParametro param : rpParametro) {
				parameters.put(param.getNome(), param.getValue());				
			}
		}
		String aux = JasperRunManager.runReportToHtmlFile (this.path, parameters, connection);
		return aux;
	}
	
	public boolean setParametro(ArrayList<String> pp) throws SQLException {
		boolean aux = false;
		boolean isSetParametro = false;
		String valor= "";
		for (String pipe : pp) {
			for (Parametro param: parametro) {
				valor = pipe.replace(",", "@");
				if (Long.valueOf(Util.getPart(valor, 1)).equals(param.getCodigo())) {
					if (rpParametro == null || rpParametro.size() == 0) {
						rpParametro = new ArrayList<ReportParametro>();
					}
					if (param.getRefUnidade().equals("s") && param.getComponente().equals("c")) {
						rpParametro.add(new ReportParametro(param.getDescricao(), 
								Util.getPart(pipe, 2), param.getOperador(), 
								Util.getPart(param.getCampo(), 1) , param.getTipo(), param.getRequerido()));
					} else {
						rpParametro.add(new ReportParametro(param.getDescricao(), 
								Util.getPart(pipe, 2), param.getOperador(), 
								param.getCampo(), param.getTipo(), param.getRequerido()));
					}
					aux = true;
					break;
				} else if ((param.getOperador().equals("cn")) && (!isSetParametro)) {
					if (rpParametro == null || rpParametro.size() == 0) {
						rpParametro = new ArrayList<ReportParametro>();
					}
					ReportParametro paramAux = new ReportParametro(param.getDescricao(), 
						"-1", "cn", "-1", param.getTipo(), param.getRequerido());
					paramAux.setConnection(ConnectionFactory.getConnection());
					rpParametro.add(paramAux);
					isSetParametro= true;
				}
			}
		}
		return aux;	
	}
	
	public String getTipo() {
		return relatorio.getTipo();
	}
	
	public String getLink() {
		link = "";
		String aux = "";
		ArrayList<String> in;
		if (rpParametro != null && rpParametro.size() > 0) {
			for (ReportParametro param : rpParametro) {
				if (param.getOperador().trim().equals("in")) {
					aux = param.getValue().replace(",", "@");
					aux = aux.replace(";", "|");
					if (!aux.trim().equals("")) {
						in = Util.unmountPipelineStr(aux);
						for (String vl : in) {
							link+= "&" + param.getNome() + "=" + vl;
						}
					}					
				} else {
					link+= "&" + param.getNome() + "=" + param.getValue(); 
				}
			}
		}
		aux = link;
		link = "";
		switch (relatorio.getDinamico().charAt(0)) {
		case 'p':
			link = Util.BIRT_RUN;
			link+= relatorio.getDescricao() + aux + Util.BIRT_PDF;		
			break;

		case 'b':
			link = Util.BIRT_FRAMESET;
			link+= relatorio.getDescricao() + aux;
			break;
			
		case 'h':
			link = Util.BIRT_RUN;
			link+= relatorio.getDescricao() + aux + Util.BIRT_HTML;
			break;
		}		
		return link;
	}
	
	private class ReportParametro {
		private String nome, valor, operador, field, tipo;
		private boolean requerido;
		private Connection conn;
		
		public ReportParametro(String nome, String valor, String operador, String field, String tipo, String requerido) {
			this.nome = nome;
			this.valor = (valor == null || valor.isEmpty())? null: valor;
			this.operador = operador;
			this.field = field;
			this.tipo = tipo;
			this.requerido = requerido.trim().equals("t");
		}
		
		public void setConnection(Connection conn) {
			this.conn = conn;
		}
		
		public String getValue() {
			return this.valor;
		}
		
		public String getNome() {
			return this.nome;
		}
		
		public String getOperador() {
			return this.operador;
		}
		
		public String getField() {
			return this.field;
		}
		
		public String getTipo() {
			return this.tipo;
		}
		
		public Connection getConnection() {
			return this.conn;
		}
		
		public void closeConnection() throws SQLException {			
			this.conn.close();
		}
		
		public boolean getRequerido() {
			return this.requerido;
		}
	}
	
	private class ParamValues {
		private String value, tipo;
		
		public ParamValues(String value, String tipo) {
			this.tipo= tipo;
			this.value = value;
		}

		public String getValue() {
			return value;
		}

		public String getTipo() {
			return tipo;
		}
	}
}
