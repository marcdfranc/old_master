package com.marcsoftware.gateway;

import java.io.FileNotFoundException;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Iterator;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.FileUpload;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.ItensConciliacao;
import com.marcsoftware.utilities.BDImgAdmin;
import com.marcsoftware.utilities.HibernateUtil;

/**
 * Servlet implementation class ChequeUpload
 */
public class ChequeUpload extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private String href;	
    
    public ChequeUpload() {
        super();
    }
    
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	PrintWriter out = response.getWriter();
    	doGet(request, response);
    	out.print(href);
    	out.close();		
    }

	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		Session session = null;
		Transaction transaction = null;
		href = "../error_page.jsp?errorMsg=Arquivo enviado com sucesso!&lk=application/conciliacao.jsp";
		if (FileUpload.isMultipartContent(request)) {
			FileItemFactory factory= new DiskFileItemFactory();
			ServletFileUpload upload = new ServletFileUpload(factory);
			try {
				 List<ServletFileUpload> pdfs = upload.parseRequest(request);
				 Iterator<ServletFileUpload> iterator= pdfs.iterator();
				 FileItem item = null;
				 FileItem fileData = null;
				 String nomeArquivo = "";
				 Long idLancamento = null;
				 Long idConciliacao = null;
				 
				 while (iterator.hasNext()) {
					item= (FileItem) iterator.next();
					if (item.getFieldName().trim().equals("nome_arquivo")) {												
						nomeArquivo = item.getString();					
					} else if (item.getFieldName().trim().equals("idConciliacao")) {
						idConciliacao = Long.valueOf(item.getString());
					} else if (item.getFieldName().trim().equals("idLancamento")) {
						idLancamento = Long.valueOf(item.getString());
					} else if ((item.getFieldName().trim().equals("Filedata")) && (!item.isFormField()) && (item.getName().length() > 0)) {
						fileData = item;
					}
				}
				 save(idLancamento, idConciliacao, transaction, session);
				insertImage(fileData, nomeArquivo, this.getServletContext().getRealPath("/application/upload/cheques"));															
			} catch (Exception e) {				
				e.printStackTrace();
				if (transaction != null && transaction.isActive()) {
					transaction.rollback();
				}
				href = "../error_page.jsp?errorMsg=Não foi possível enviar o arquivo devido a um erro interno!&lk=application/conciliacao.jsp";
				return;
			} finally {
				if (session != null && session.isOpen()) {
					session.close();
				}
			}
		}
	}
	
	private void insertImage(FileItem fileIten, String name, String path) throws FileNotFoundException, IOException{		
		String fieldName= fileIten.getFieldName();
		BDImgAdmin admin= new BDImgAdmin(path);
		admin.createfolder(null);
		String fileName= name;
		String extension= fileIten.getName().substring(fileIten.getName().length()-3, fileIten.getName().length());
		admin.createFile(fileName, extension, null);
		admin.copyData(fileIten);
	}
	
	private void save(Long idLancamento, Long idConciliacao, Transaction transaction, Session session) throws Exception {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		Query query = session.createQuery("from ItensConciliacao as i " +
				" where i.id.lancamento.codigo = :lancamento " +
				" and i.id.conciliacao.codigo = :conciliacao");
		query.setLong("lancamento", idLancamento);
		query.setLong("conciliacao", idConciliacao);
		ItensConciliacao item = (ItensConciliacao)  query.uniqueResult();
		item.setDocDigital("s");
		session.update(item);
		transaction.commit();
	}

}
