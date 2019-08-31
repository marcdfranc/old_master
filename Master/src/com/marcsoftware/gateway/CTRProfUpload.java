package com.marcsoftware.gateway;

import java.io.FileNotFoundException;
import java.io.PrintWriter;

import java.io.IOException;
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
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Profissional;
import com.marcsoftware.utilities.BDImgAdmin;
import com.marcsoftware.utilities.HibernateUtil;

/**
 * Servlet implementation class ProfissionalUpload
 */
public class CTRProfUpload extends HttpServlet {
	private static final long serialVersionUID = 1L;       
    
    public CTRProfUpload() {
        super();
        // TODO Auto-generated constructor stub
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		if (request.getParameter("from").equals("0")) {
			Session session = null;
			Transaction transaction = null;
			String href = "../error_page.jsp?errorMsg=Arquivo enviado com sucesso!&lk=application/profissionais.jsp";
			if (FileUpload.isMultipartContent(request)) {
				FileItemFactory factory= new DiskFileItemFactory();
				ServletFileUpload upload = new ServletFileUpload(factory);
				try {
					List<ServletFileUpload> pdfs = upload.parseRequest(request);
					Iterator<ServletFileUpload> iterator= pdfs.iterator();
					FileItem item = null;
					FileItem fileData = null;
					String nomeArquivo = "";
					Long id = null;
					
					while (iterator.hasNext()) {
						item= (FileItem) iterator.next();
						//if (item.getFieldName().trim().equals("idPessoa")) {
						if (item.getFieldName().trim().equals("nome_arquivo")) {												
							nomeArquivo = item.getString();					
						} else if (item.getFieldName().trim().equals("idProfissional")) {
							id = Long.valueOf(item.getString());
						} else if ((item.getFieldName().trim().equals("Filedata")) && (!item.isFormField()) && (item.getName().length() > 0)) {
							fileData = item;
						}
					}
					save(id, transaction, session);
					insertImage(fileData, nomeArquivo, this.getServletContext().getRealPath("/application/upload/ctrs_profissionais"));				
				} catch (Exception e) {
					e.printStackTrace();
					if (transaction != null && transaction.isActive()) {
						transaction.rollback();
					}
					href = "../error_page.jsp?errorMsg=Não foi possível enviar o arquivo devido a um erro interno!&lk=application/profissionais.jsp";
					return;
				} finally {
					if (session != null && session.isOpen()) {
						session.close();
					}
				}
			}
		} else {
			PrintWriter out = response.getWriter();
			out.print("esse negócio ta funcionando sim!!");
			out.close();
		}
	}
	
	private void insertImage(FileItem fileIten, String name, String path) throws FileNotFoundException, IOException{
		BDImgAdmin admin= new BDImgAdmin(path);
		admin.createfolder(null);
		String fileName= name;
		String extension= fileIten.getName().substring(fileIten.getName().length()-3, fileIten.getName().length());
		admin.createFile(fileName, extension, null);
		admin.copyData(fileIten);
	}
	
	private void save(Long idProfissional, Transaction transaction, Session session) throws Exception {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		Profissional profissional = (Profissional) session.load(Profissional.class, idProfissional);
		profissional.setDocDigital("s");
		session.update(profissional);
		session.flush();
		transaction.commit();
	}

}
