package com.marcsoftware.gateway;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.io.IOUtils;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.CobrancaCcob;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Token;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


/**
 * Servlet implementation class Centercob
 */
public class Centercob extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public Centercob() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PrintWriter out = response.getWriter();
		int from = request.getParameter("from") == null? -1 : Integer.parseInt(request.getParameter("from"));
		switch (from) {
		case 0:
			response.setContentType("text/plain");
			out.print(getCounts(request));
			break;

		case 1:
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/html");
			boolean isFilter= request.getParameter("isFilter") == "1";
			Filter filter = mountFilter(request);
			int limit= Integer.parseInt(request.getParameter("limit"));
			int offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
			Session session = HibernateUtil.getSession();
			Query query = filter.mountQuery(session);
			int gridLines= query.list().size();
			query.setFirstResult(offSet);
			query.setMaxResults(limit);		
			List<CobrancaCcob> ccobs= (List<CobrancaCcob>) query.list();
			if (ccobs.size() == 0) {
				out.print("<tr><td></td><td><p>" + Util.SEM_REGISTRO + "</p>" +
						"<td></td><td></td><td></td><td></td><td></td><td></td><td></td>");
				session.close();
				out.close();
				return;
			}
			DataGrid dataGrid = null;
			if (request.getSession().getAttribute("perfil").toString().trim().equals("a")
					|| request.getSession().getAttribute("perfil").toString().trim().equals("d")) {
				//dataGrid = new DataGrid("../Centercob", true);							
				dataGrid = new DataGrid(null);							
			} else {
				dataGrid = new DataGrid("#");
			}
			dataGrid.addColum("10", "Código");
			dataGrid.addColum("30" ,"Unidade");
			dataGrid.addColum("35" ,"Nome do Arquivo");
			if (request.getSession().getAttribute("perfil").toString().trim().equals("a")				
					|| request.getSession().getAttribute("perfil").toString().trim().equals("d")) {
				dataGrid.addColum("21" ,"Cadastro");
				dataGrid.addColum("2" ,"St");
				dataGrid.addColum("2" ,"Ck");
			} else {
				dataGrid.addColum("23" ,"Cadastro");
				dataGrid.addColum("2" ,"St");
			}
			
			for(CobrancaCcob ccob: ccobs) {							
				dataGrid.setId(String.valueOf(ccob.getCodigo()));
				
				dataGrid.addData("codigo" + ccob.getCodigo(), 
						String.valueOf(ccob.getCodigo()), false);
				
				dataGrid.addData("unidade" + ccob.getCodigo(), 
						ccob.getUnidade().getReferencia() + " - "
						+ ccob.getUnidade().getDescricao(), false);
				dataGrid.addData("descricao" + ccob.getCodigo(), ccob.getDescricao(), false);
				
				dataGrid.addData("cadastro" + ccob.getCodigo(), Util.parseDate(
						ccob.getCadastro(), "dd/MM/yyyy"), false);
				dataGrid.addImg(ccob.getEnviado().equals("n")? "../image/em_aberto.gif" 
						: "../image/fechado.gif");
				if (request.getSession().getAttribute("perfil").toString().trim().equals("a")				
						|| request.getSession().getAttribute("perfil").toString().trim().equals("d")) {
					dataGrid.addCheck(true);
				}
				dataGrid.addRow();
			}
			out.print(dataGrid.getBody(gridLines));
			session.close();
			out.close();
			break;
			
		case 2:
			geraArquivo(request, response);
			break;
			
		case 3:
			out.print(marcarEnviado(request, response));
			break;
			
		case 4:
			response.setContentType("text/plain");
			out.print(alteraStatus(request));
			break;
			
		case 5:
			response.setContentType("text/plain");
			out.print(excluiArquivo(request));
			break;
			
		default:
			getArquivo(request, response);
			break;
		}
		
	}
	
	private String getCounts(HttpServletRequest request) {
		String result = "";		
		Session session = HibernateUtil.getSession();
		try {		
			Query query = session.createQuery("select count(*) from Usuario as u " +
					"where ccob_status = null " +
					" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "nulos=" + String.valueOf(query.uniqueResult());
			
			query = session.createQuery("select count(*) from Usuario as u " +
					"where ccob_status = 'N' " +
					" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|semEnvio=" + String.valueOf(query.uniqueResult());
			
			query = session.createQuery("select count(*) from Usuario as u " +
					" where ccob_status = 'I' " +
			" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|incluir=" + String.valueOf(query.uniqueResult());
			
			query = session.createQuery("select count(*) from Usuario as u " +
					" where ccob_status = 'E' " +
					" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|enviado=" + String.valueOf(query.uniqueResult());
			
			query = session.createQuery("select count(*) from Usuario as u " +
					"where ccob_status = 'A' " +
					" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|alterar=" + String.valueOf(query.uniqueResult());
			
			query = session.createQuery("select count(*) from Usuario as u " +
					"where ccob_status = 'C' " +
					" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|cancelar=" + String.valueOf(query.uniqueResult());
			
			query = session.createQuery("select count(*) from Usuario as u " +
					"where ccob_status = 'L' " +
					" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|cancelado=" + String.valueOf(query.uniqueResult());
			
			query = session.createQuery("select count(*) from Usuario as u " +
					"where ccob_status = 'R' " +
					" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|erro=" + String.valueOf(query.uniqueResult());
			
			query = session.createQuery("select count(*) from Usuario as u " +
					"where ccob_status = 'D' " +
			" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|atraso=" + String.valueOf(query.uniqueResult());
			
			query = session.createQuery("select count(*) from Usuario as u " +
					"where ccob_status = 'S' " +
			" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|semConta=" + String.valueOf(query.uniqueResult());
			
			query = session.createQuery("select count(*) from Usuario as u " +
					"where ccob_status = 'B' " +
			" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|erroCpfl=" + String.valueOf(query.uniqueResult());
			
			query = session.createQuery("select count(*) from Usuario as u " +
					"where ccob_status = 'T' " +
			" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|negraCpfl=" + String.valueOf(query.uniqueResult());
			
			query = session.createQuery("select count(*) from Usuario as u " +
					"where ccob_status = 'G' " +
			" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|negra=" + String.valueOf(query.uniqueResult());
			
			query = session.createQuery("select count(*) from Usuario as u " +
					"where ccob_status = 'M' " +
			" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|trocaTitular=" + String.valueOf(query.uniqueResult());
			
			query = session.createQuery("select count(*) from Usuario as u " +
					"where ccob_status = 'U' " +
			" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|duplicidade=" + String.valueOf(query.uniqueResult());
			
			query = session.createQuery("select count(*) from Usuario as u " +
					"where ccob_status = 'F' " +
					" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|indefinido=" + String.valueOf(query.uniqueResult());

			query = session.createQuery("select count(*) from Usuario as u " +
					"where ccob_status = 'O' " +
					" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|pagBoleto=" + String.valueOf(query.uniqueResult());
			
			query = session.createQuery("select count(*) from Usuario as u " +
					"where ccob_status = 'P' " +
					" and u.unidade.codigo = :unidade");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
			result+= "|pagCorporativo=" + String.valueOf(query.uniqueResult());
			
			session.close();
			
		} catch (Exception e) {
			//e.printStackTrace();
			result = "erro";
		}
		return result;
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
	}
	
	private void geraArquivo(HttpServletRequest request, HttpServletResponse response) {	
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		try {
			response.setContentType("text/plain");
			PrintWriter out = response.getWriter();
			String urlStr = Util.URL_ENVIO_CCOB;
			//String urlStr = Util.URL_RETORNO_CCOB;
			String data = "unidade=" + request.getParameter("unidade");
			
			data = new String(Base64.encodeBase64(data.getBytes()));	
			
			String strToken = Util.parseDate(new Date(), "yyyy-MM-dd HH:mm:ss");
			strToken = new String(Base64.encodeBase64(strToken.getBytes()));
			
			Token token = new Token();
			token.setDescricao(strToken);
			token.setExpirado("n");
			token.setHora(new Date());
			
			session.save(token);
			
			String id = String.valueOf(token.getId());			
			transaction.commit();
			session.flush();
			session.close();
			
			id = Util.MD5(id);
			
			urlStr = urlStr.replace("{id}", id);
			urlStr = urlStr.replace("{data}", data);
			urlStr = urlStr.replace("{token}", strToken);
			//out.print(urlStr);
			URLConnection connection = new URL(urlStr).openConnection();
			connection.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.95 Safari/537.11");
			connection.connect();
			
			/*URL url = new URL(urlStr);
			InputStreamReader reader = new InputStreamReader(url.openStream());*/
			
			InputStreamReader reader = new InputStreamReader(connection.getInputStream());
			StringWriter writer = new StringWriter();
			IOUtils.copy(reader, writer);
			//response.sendRedirect(url);
			
			urlStr = writer.toString();
			out.print(urlStr);
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
		}		
	}
	
	private Filter mountFilter(HttpServletRequest request) {
		Filter filter = new Filter("from CobrancaCcob as c where (1 = 1)");
			
		if (!request.getParameter("unidade").equals("")) {
			filter.addFilter("c.unidade.codigo = :unidade", Long.class, "unidade",
					Long.valueOf(request.getParameter("unidade")));
		}		
		if ((!request.getParameter("inicio").equals("")) && (!request.getParameter("fim").equals(""))) {
			filter.addFilter("c.cadastro between :inicio", java.util.Date.class, 
					"inicio", Util.parseDate(request.getParameter("inicio")));
			
			filter.addFilter(" :fim", java.util.Date.class, 
					"fim", Util.parseDate(request.getParameter("fim")));			
		}		
		filter.setOrder("c.cadastro DESC");
		return filter;
	}
	
	private void getArquivo(HttpServletRequest request, HttpServletResponse response) {
		String url = Util.URL_RETORNO_CCOB;
		
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		try {
			String strToken = Util.parseDate(new Date(), "yyyy-MM-dd HH:mm:ss");
			strToken = new String(Base64.encodeBase64(strToken.getBytes()));
			
			Token token = new Token();
			token.setDescricao(strToken);
			token.setExpirado("n");
			token.setHora(new Date());
			session.save(token);
			
			String id = String.valueOf(token.getId());			
			id = Util.MD5(id);
			
			String data = "ccobId=" + request.getParameter("id");
			data = new String(Base64.encodeBase64(data.getBytes()));
			
			url = url.replace("{id}", id);
			url = url.replace("{data}", data);
			url = url.replace("{token}", strToken);
			session.flush();
			transaction.commit();
			
			response.sendRedirect(url);
			
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			session.close();
		}
		
	}
	
	private String marcarEnviado(HttpServletRequest request, HttpServletResponse response) {
		String result = "Arquivo marcado como enviado.";
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		try {
			String ids = request.getParameter("arquivos").replace("|", ", ");
			Query query = session.createQuery("from CobrancaCcob where codigo IN(" + ids + ")");
			List<CobrancaCcob> ccobs = (List<CobrancaCcob>) query.list();
			
			for (CobrancaCcob ccob : ccobs) {
				ccob.setEnviado(ccob.getEnviado().equals("s")? "n" : "s");
				session.saveOrUpdate(ccob);
			}
			session.flush();
			transaction.commit();
			
		} catch (Exception e) {
			transaction.rollback();
			result = "Ocorreu um erro e o arquivo não pode ser marcado como enviado!";
			e.printStackTrace();
		}				
		return result;
	}
	
	private String alteraStatus(HttpServletRequest request) {
		String result = "";
		String url = Util.URL_STATUS_CCOB.replace("{id}", request.getParameter("id"));
		
		URLConnection connection;
		try {
			connection = new URL(url).openConnection();
			connection.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.95 Safari/537.11");
			connection.connect();
			
			InputStreamReader reader = new InputStreamReader(connection.getInputStream());
			StringWriter writer = new StringWriter();
			IOUtils.copy(reader, writer);
			//response.sendRedirect(url);
			
			result = writer.toString();
			writer.close();
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			result = "Ocorreu um erro incesperado durante a atualização.";
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			result = "Ocorreu um erro incesperado durante a atualização.";
		}
		return result;
	}
	
	private String excluiArquivo(HttpServletRequest request) {
		String result = "";
		String url = Util.URL_EXCLUI_CCOB.replace("{id}", request.getParameter("id"));
		
		URLConnection connection;
		try {
			connection = new URL(url).openConnection();
			connection.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.95 Safari/537.11");
			connection.connect();
			
			InputStreamReader reader = new InputStreamReader(connection.getInputStream());
			StringWriter writer = new StringWriter();
			IOUtils.copy(reader, writer);
			//response.sendRedirect(url);
			
			result = writer.toString();
			writer.close();
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			result = "Ocorreu um erro incesperado durante a exclusão.";
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			result = "Ocorreu um erro incesperado durante a exclusão.";
		}
		return result;
	}

}
