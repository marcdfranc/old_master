package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.eclipse.jdt.internal.compiler.flow.FinallyFlowContext;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Video;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroVideo
 */
public class CadastroVideo extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CadastroVideo() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PrintWriter out;
		String href = "cadastro_video.jsp";
		switch (request.getParameter("from").charAt(0)) {
		case '2':
			href = "video_view.jsp";
		
		case '0':
			response.setContentType("text/html");
			out= response.getWriter();
			Session session= HibernateUtil.getSession();
			try {
				boolean isFilter= request.getParameter("isFilter") == "1";
				Filter filter = mountFilter(request);
				int limit= Integer.parseInt(request.getParameter("limit"));
				int offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
				
				Query query = null;
				query = filter.mountQuery(query, session);
				int gridLines= query.list().size();
				query.setFirstResult(offSet);
				query.setMaxResults(limit);
				
				List<Video> videoList = (List<Video>) query.list();
				if (videoList.size() == 0) {
					out.print("<tr><td>Nenhum Registro Encontrado!</td><td></td></tr>");
					session.close();
					out.close();
					return;
				} else {					
					DataGrid dataGrid= new DataGrid(href);						
					for (Video vd: videoList) {
						dataGrid.setId(String.valueOf(vd.getCodigo()));
						dataGrid.addData(vd.getTitulo());
						dataGrid.addData(vd.getUrl());
						dataGrid.addRow();
					}
					out.print(dataGrid.getBody(gridLines));
				}
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				session.close();
				out.close();
			}
			break;
			
			case '1':
				response.setContentType("text/plain");
				out= response.getWriter();
				if (excluiVideo(request))  {
					out.print("0");
				} else {
					out.print("1");
				}
			break;
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {
			if (addRecord(request))  {
				response.sendRedirect("application/videos_edit.jsp");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
				"&lk=application/videos_edit.jsp");
			}			
		} catch (Exception e) {			
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
			"&lk=application/videos_edit.jsp");
		}
	}
	
	private boolean addRecord(HttpServletRequest request) {
		boolean isEdition= (request.getParameter("codVideo") != "");		
		Session session= HibernateUtil.getSession();
		Transaction transaction= session.beginTransaction();
		try {
			Video video = null;
			if (isEdition) {
				video = (Video) session.load(Video.class, Long.valueOf(request.getParameter("codVideo")));
			} else {
				video = new Video();
			}
			
			video.setMenu(request.getParameter("menuIn"));
			video.setTitulo(request.getParameter("tituloIn"));
			video.setUrl(request.getParameter("urlIn"));
			
			session.saveOrUpdate(video);
			
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
			return false;
		} finally {
			session.close();
		}
		return true;
	}
	
	private boolean excluiVideo(HttpServletRequest request) {
		Session session= HibernateUtil.getSession();
		Transaction transaction= session.beginTransaction();
		try {
			Video video = (Video) session.load(Video.class, Long.valueOf(request.getParameter("codVideo")));
			session.delete(video);
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			e.printStackTrace();
			return false;
		} finally {
			session.close();
		}
		return true;
	}
	
	private Filter mountFilter(HttpServletRequest request) {
		Filter filter = new Filter("from Video as v");
		
		if (!request.getParameter("menu").equals("")) {
			filter.addFilter("v.menu = :menu", String.class, "menu",
					request.getParameter("menu"));
		}
		
		if (!request.getParameter("titulo").equals("")) {
			filter.addFilter("v.titulo LIKE :titulo", String.class, "titulo", 
				"%" + Util.encodeString(request.getParameter("titulo"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		filter.setOrder("v.titulo");
		return filter;
	}

}

