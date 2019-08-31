package com.marcsoftware.gateway;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Iterator;
import java.util.List;
import java.util.Random;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.batik.css.engine.value.css2.SrcManager;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.FileUpload;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Login;
import com.marcsoftware.database.Pessoa;
import com.marcsoftware.utilities.BDImgAdmin;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


/**
 * Servlet implementation class for Servlet: ImageUpload
 *
 * */

 public class ImageUpload extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
	private FileItemFactory factory;
	private ServletFileUpload upload;
	private List<ServletFileUpload> images;
	private FileItem item;	
	private String fileName, extension, fieldName;		
	private BDImgAdmin admin;
	private PrintWriter out;
	private boolean isok;
	private Long id;
	private Login login;
	private Pessoa pessoa;
	private Session session;
	private Transaction transaction;
	private Query query;	
	
	public void init() throws ServletException{	
		fileName= "";
		extension= "";		
	}
	
	@Override
	public void doPost(HttpServletRequest servletRequest, HttpServletResponse servletResponse) throws ServletException, IOException{
		doGet(servletRequest, servletResponse);		
		if (isok) {
			//servletResponse.sendRedirect("application/splash_ok.jsp");			
		} else {
			//servletResponse.sendRedirect("application/splash_ok.jsp");
		}
		out = servletResponse.getWriter();
		out.print("upload efetuado com sucesso");
		//out.close();
	}
	
	@Override
	public void doGet(HttpServletRequest request, HttpServletResponse response)throws ServletException, IOException {
		isok = true;
		if (FileUpload.isMultipartContent(request)) {
			factory= new DiskFileItemFactory();
			upload = new ServletFileUpload(factory);
			try {
				 images = upload.parseRequest(request);
				 Iterator<ServletFileUpload> iterator= images.iterator();
				 while (iterator.hasNext()) {
					item= (FileItem) iterator.next();
					if (item.getFieldName().trim().equals("idPessoa")) {
						id = Long.valueOf(Util.removeAspas(item.getString()));
						if (! loadData(id)) {
							isok = false;
							return;
						}
					}
					if ((!item.isFormField()) && (item.getName().length() > 0)) {
						insertImage(item, String.valueOf(id), this.getServletContext().getRealPath("/application/bd_img"));															
					}
				}
			} catch (Exception e) {				
				e.printStackTrace();
				isok = false;
				return;
			}
			if (!saveImage()) {
				if (admin != null) {
					admin.deleteFile();
				}
				isok = false;
			}
		}		
	}
	
	private void insertImage(FileItem fileIten, String name, String path) throws FileNotFoundException, IOException{		
		fieldName= fileIten.getFieldName();
		admin= new BDImgAdmin(path);
		admin.createfolder(null);
		fileName= name;
		extension= fileIten.getName().substring(fileIten.getName().length()-3, fileIten.getName().length());
		if (extension== "peg") {
			extension= "jpeg";
		}
		admin.createFile(fileName, extension, null);
		admin.copyData(fileIten);		
	}
	
	private boolean loadData(long id) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		String usrPass = "";
		Random random = new Random();
		try {
			query = session.createQuery("from Pessoa as p where p.codigo = :codigo");
			query.setLong("codigo", id);
			pessoa = (Pessoa) query.uniqueResult();			
			if (pessoa.getLogin() == null) {
				while (usrPass.length() <= 5) {
					usrPass = Util.geraPalavra(random.nextInt(30));					
				}
				login = new Login();
				login.setSenha("123Mudar");
				login.setPerfil("p");
				login.setUsername(usrPass);
				login.setTries(0);
				session.save(login);
				
				pessoa.setLogin(login);
				
				session.update(pessoa);		
				transaction.commit();
				session.close();				
				return true;
			} else {
				login = pessoa.getLogin();								
			}
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			return false;
		}
		return true;
	}
	
	private boolean saveImage() {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			login.setFoto("bd_img/" + id + "." + extension);
			session.update(login);
			session.flush();
			transaction.commit();			
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return false;
		}
		return true;
	}
}
