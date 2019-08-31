package com.marcsoftware.gateway;

import java.io.FileNotFoundException;
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

import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.BDImgAdmin;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class LogoReportUpload
 */
public class LogoReportUpload extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private boolean isOk;
	private BDImgAdmin admin;
	private String extension;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public LogoReportUpload() {
        super();
        // TODO Auto-generated constructor stub
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	doGet(request, response);		
    	if (isOk) {
    		response.sendRedirect("application/splash_ok.jsp");			
    	} else {
    		response.sendRedirect("application/splash_ok.jsp");
    	}
    }
    
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		isOk = true;
		FileItem item = null;
		Long id = new Long("0");
		if (FileUpload.isMultipartContent(request)) {
			FileItemFactory factory= new DiskFileItemFactory();
			ServletFileUpload upload = new ServletFileUpload(factory);
			try {
				 List<ServletFileUpload> images = upload.parseRequest(request);
				 Iterator<ServletFileUpload> iterator= images.iterator();
				 while (iterator.hasNext()) {
					item= (FileItem) iterator.next();
					if (item.getFieldName().trim().equals("idPessoa")) {
						id = Long.valueOf(Util.removeAspas(item.getString()));
					}
					if ((!item.isFormField()) && (item.getName().length() > 0) && id > 0) {
						insertImage(item, id, this.getServletContext().getRealPath("/report/logo_report"));															
					}
				}
			} catch (Exception e) {
				e.printStackTrace();
				isOk = false;
				return;
			}
			if (!saveImage(id)) {
				if (admin != null) {
					admin.deleteFile();
				}
				isOk = false;
			}
		}
	}	
	
	private void insertImage(FileItem fileIten, Long id, String path) throws FileNotFoundException, IOException{		
		String fieldName= fileIten.getFieldName();
		admin= new BDImgAdmin(path);
		admin.createfolder(null);
		String fileName= "logo" + id;
	 	extension= fileIten.getName().substring(fileIten.getName().length()-3, fileIten.getName().length());
		if (extension== "peg") {
			extension= "jpeg";
		}
		admin.createFile(fileName, extension, null);
		admin.copyData(fileIten);
		admin.createThumb(this.getServletContext().getRealPath("/report/logo_report"), "thumb" + id, extension);
	}
	
	private boolean saveImage(Long id) {
		boolean result = true;
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		try {
			Unidade unidade = (Unidade) session.load(Unidade.class, id);			
			unidade.setReportLogo("logo_report/logo" + id + "." + extension);
			unidade.setThumbReport("../report/logo_report/thumb" + id + "." + extension);
			session.update(unidade);
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();			
			result = false;
		} finally {
			session.close();
		}
		return result;
	}
}
