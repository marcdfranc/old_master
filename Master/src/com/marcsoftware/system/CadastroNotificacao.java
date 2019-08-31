package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.AcessoNotificacao;
import com.marcsoftware.database.AcessoNotificacaoId;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Login;
import com.marcsoftware.database.Notificacao;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroNotificacao
 */
public class CadastroNotificacao extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CadastroNotificacao() {
        super();        
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PrintWriter out = response.getWriter();
		switch (Integer.parseInt(request.getParameter("from"))) {
		case 0:
			response.setContentType("text/plain");
			String aux = request.getParameter("saIsOpen");
			request.getSession().setAttribute("saIsOpen", aux);
			response.setCharacterEncoding("ISO-8859-1");
			out.print(aux);			
			break;

		case 1:
			response.setContentType("text/plain");
			out.print(setLida(request));
			break;
			
		case 2:
			response.setContentType("text/html");
			boolean isFilter= request.getParameter("isFilter") == "1";
			Filter filter = mountFilter(request);
			Session session= HibernateUtil.getSession();
			Query query = null;
			try {
				int limit= Integer.parseInt(request.getParameter("limit"));
				int offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
				query = filter.mountQuery(query, session);				
				int gridLines= query.list().size();
				query.setFirstResult(offSet);
				query.setMaxResults(limit);	
				List<AcessoNotificacao> notificacaoList = (List<AcessoNotificacao>) query.list();
				if (notificacaoList.size() == 0) {
					out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td><td></td></tr>");
					session.close();
					out.close();
					return;
				}			
				DataGrid dataGrid= new DataGrid(null);
				dataGrid.addColum("30", "Remetente");
				dataGrid.addColum("50", "Assunto");
				dataGrid.addColum("10", "Data");
				dataGrid.addColum("10", "Hora");
				for(AcessoNotificacao notificacao : notificacaoList) {
					dataGrid.setId(String.valueOf(notificacao.getId().getNotificacao().getCodigo()));									
					dataGrid.addData(notificacao.getId().getNotificacao().getRemetente().getUsername());
					dataGrid.addData(notificacao.getId().getNotificacao().getAssunto());
					dataGrid.addData(Util.parseDate(notificacao.getId().getNotificacao().getData(), "dd/MM/yyyy"));
					dataGrid.addData(Util.getTime(notificacao.getId().getNotificacao().getData()));
					if (notificacao.getVisualizada().equals("s")) {
						dataGrid.addImg("../image/ok_icon.png");
					} else {
						dataGrid.addImg("../image/em_aberto.gif");
					}
					dataGrid.addRow();
				}
				out.print(dataGrid.getBody(gridLines));
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				session.close();
			}
			break;
			
		case 3:
			response.setContentType("text/xml");
			response.setHeader("Cache-Control", "no-cache");
			response.setCharacterEncoding("ISO-8859-1");
			out.write(getMsg(request));
			break;
			
		case 4:
			response.setContentType("text/plain");
			out.print(responder(request));
			break;
			
		case 5:
			response.setContentType("text/plain");
			out.print(setSessao(request));
			break;
			
		case 6:
			response.setContentType("text/plain");
			out.print(delMessage(request));
			break;
			
		case 7:
			response.setContentType("text/xml");
			response.setHeader("Cache-Control", "no-cache");
			response.setCharacterEncoding("ISO-8859-1");
			out.write(getLogins(request));
			break;
		}
		out.close();
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.sendRedirect(addRecord(request));
	}
	
	private String addRecord(HttpServletRequest request) {
		boolean isEdition= (request.getParameter("codNotificacao") != "");
		String result = "?errorMsg=Mensagem enviada com sucesso!&lk=application/notificacao.jsp";
		Notificacao notificacao = null;
		AcessoNotificacao acesso = null;
		AcessoNotificacaoId id = null;
		Login login = null;
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		try {
			query = session.createQuery("from Login as l where l.username = :username");
			query.setString("username", request.getSession().getAttribute("username").toString());
			login = (Login) query.uniqueResult();
			if (isEdition) {
				notificacao = (Notificacao) session.load(Notificacao.class, Long.valueOf(request.getParameter("codNotificacao")));
			} else {
				notificacao = new Notificacao();
			}
			notificacao.setAssunto(request.getParameter("assuntoIn"));
			notificacao.setData((isEdition)? Util.parseDate(request.getParameter("dataIn")): new Date());
			notificacao.setDescricao(request.getParameter("descricaoIn"));
			notificacao.setPrioridade(request.getParameter("prioridadeIn"));
			notificacao.setRemetente(login);
			notificacao.setStatus(request.getParameter("statusIn"));
			
			session.saveOrUpdate(notificacao);
			
			int count = 0;
			String usuario = request.getSession().getAttribute("username").toString();
			List<Notificacao> sessNotificacao;
			while (request.getParameter("rowUser" + String.valueOf(count)) != null) {
				if (isEdition) {
					query = session.createQuery("from AcessoNotificacao as a " +
							"where a.id.Notificacao = :notificacao and a.id.login.username = :username");
					query.setEntity("notificacao", notificacao);
					query.setString("username", request.getParameter("rowUser" + String.valueOf(count)));
					if (query.list().size() < 1) {
						acesso = new AcessoNotificacao();
						id = new AcessoNotificacaoId();
						query = session.createQuery("from Login as l where l.username = :username");
						query.setString("username", request.getParameter("rowUser" + String.valueOf(count)));
						login = (Login) query.uniqueResult();
						if (login.getUsername().equals(usuario)) {
							sessNotificacao = (List<Notificacao>) request.getSession().getAttribute("notificacaoList");
							if (sessNotificacao == null || sessNotificacao.size() == 0) {
								sessNotificacao = new ArrayList<Notificacao>();
							}
							sessNotificacao.add(notificacao);
							request.getSession().setAttribute("notificacaoList", sessNotificacao);
							usuario = request.getSession().getAttribute("saIsOpen").toString();
							if (usuario == null) {
								request.getSession().setAttribute("saIsOpen", "n");								
							}
							usuario = request.getSession().getAttribute("username").toString();
						}
						id.setLogin(login);
						id.setNotificacao(notificacao);
						acesso.setId(id);
						acesso.setVisualizada("n");
						session.save(acesso);
					} 					
				} else {
					acesso = new AcessoNotificacao();
					id = new AcessoNotificacaoId();
					query = session.createQuery("from Login as l where l.username = :username");
					query.setString("username", request.getParameter("rowUser" + String.valueOf(count)));
					login = (Login) query.uniqueResult();
					if (login.getUsername().equals(usuario)) {
						sessNotificacao = (List<Notificacao>) request.getSession().getAttribute("notificacaoList");
						if (sessNotificacao == null || sessNotificacao.size() == 0) {
							sessNotificacao = new ArrayList<Notificacao>();
						}
						sessNotificacao.add(notificacao);
						request.getSession().setAttribute("notificacaoList", sessNotificacao);
					}
					id.setLogin(login);
					id.setNotificacao(notificacao);
					acesso.setId(id);
					acesso.setVisualizada("n");
					
					session.save(acesso);
				}
				count++;
			}
			session.flush();
			transaction.commit();			
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			result = "?errorMsg=Não foi possível enviar a mensagem devido a um erro interno!&lk=application/notificacao.jsp"; 
		} finally {
			session.close();
		}		
		return "../error_page.jsp" +  result;
	}
	
	private String setLida(HttpServletRequest request) {
		String result = "?errorMsg=Operação realizada com sucesso!&lk=application/notificacao.jsp";
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		AcessoNotificacao acesso;
		List<Notificacao> notificacaoList;
		try {			
			query = session.createQuery("from AcessoNotificacao as a " +
					" where a.id.notificacao.codigo = :notificacao and a.id.login.username = :username");
			query.setLong("notificacao", Long.valueOf(request.getParameter("id")));
			query.setString("username", request.getSession().getAttribute("username").toString());			
			acesso = (AcessoNotificacao) query.uniqueResult();
			
			query = session.createQuery("select a.id.notificacao from AcessoNotificacao as a " +
					" where a.id.login.username = :username " +
					" and a.id.notificacao not in(:notificacao) " +
					" and a.visualizada = 'n'");
			query.setString("username", request.getSession().getAttribute("username").toString());
			query.setEntity("notificacao", acesso.getId().getNotificacao());
			notificacaoList = (List<Notificacao>) query.list();	
			
			request.getSession().setAttribute("notificacaoList", notificacaoList);
			
			request.getSession().getAttribute("notificacaoList");
			acesso.setVisualizada("s");
			session.update(acesso);
			
			session.flush();
			transaction.commit();			
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			result = "?errorMsg=Não foi possível enviar a mensagem devido a um erro interno!&lk=application/notificacao.jsp";
		} finally {
			session.close();
		}
		return "../error_page.jsp" +  result;
	}
	
	private Filter mountFilter(HttpServletRequest request) {
		String sql = "";
		if (request.getParameter("tipoTela").equals("l")) {
			sql = "from AcessoNotificacao as a where a.visualizada = 's' ";
		} else if (request.getParameter("tipoTela").equals("n")) {
			sql = "from AcessoNotificacao as a where and a.visualizada = 'n' ";
		} else if (request.getParameter("tipoTela").equals("e")) {
			sql = "from AcessoNotificacao as a " + 
				" where a.id.notificacao.remetente.username = :login ";
		} else {
			sql = "from AcessoNotificacao as a where a.visualizada not in('e') ";
		}		
		Filter filter = new Filter(sql);
		
		if (request.getParameter("tipoTela").equals("e")) {
			filter.addFilter("a.id.notificacao.remetente.username = :login", String.class, "login",
					request.getSession().getAttribute("username"));
		} else {
			filter.addFilter("a.id.login.username = :login", String.class, "login",
					request.getSession().getAttribute("username"));
		}		
		if (Util.getPart(request.getParameter("order"), 1).trim().equals("Remetente")) {
			filter.setOrder("a.visualizada, a.id.notificacao.remetente");
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Assunto")) {
			filter.setOrder("a.visualizada, a.id.notificacao.assunto");
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Data")) {
			filter.setOrder("a.visualizada, a.id.notificacao.data");
		}
		return filter;
	}
	
	private String getMsg(HttpServletRequest request) {
		String result = "";
		Session session = HibernateUtil.getSession();
		try {
			Notificacao notificacao = (Notificacao) session.load(Notificacao.class, Long.valueOf(request.getParameter("msgId")));
			result = "<?xml version=\"1.0\" encoding=\"iso-8859-1\" ?>";
			result+= "<notificacao><isOk>s</isOk><remetente>" + notificacao.getRemetente().getUsername() + "</remetente>";
			result+= "<assunto>" + notificacao.getAssunto() + "</assunto>";
			result+= "<data>" + Util.parseDate(notificacao.getData(), "dd/MM/yyyy") + "</data>";
			result+= "<hora>" + Util.getTime(notificacao.getData()) + "</hora>";
			result+= "<msg>" + notificacao.getDescricao() + "</msg></notificacao>";
		} catch (Exception e) {
			result = "<notificacao><isOk>n</isOk></notificacao>";
		} finally {
			session.close();
		}
		return result;
	}
	
	private String responder(HttpServletRequest request) {
		String result = "../error_page.jsp?errorMsg=Mensagem enviada com sucesso!&lk=application/notificacao.jsp";
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		try {
			query = session.createQuery("from Login as l where l.username = :username");
			query.setString("username", request.getSession().getAttribute("username").toString());
			Login remetente = (Login) query.uniqueResult();
			Notificacao notificacao = (Notificacao) session.load(Notificacao.class, Long.valueOf(request.getParameter("msgId")));
			Notificacao resposta = new Notificacao();
			resposta.setAssunto("Resposta para mensagem de asssunto: " + notificacao.getAssunto());
			resposta.setData(new Date());
			resposta.setDescricao(request.getParameter("msg"));
			resposta.setPrioridade(request.getParameter("prioridade"));
			resposta.setStatus(request.getParameter("status"));
			resposta.setRemetente(remetente);
			
			session.save(resposta);
			
			AcessoNotificacaoId id = new AcessoNotificacaoId();
			id.setLogin(notificacao.getRemetente());
			id.setNotificacao(resposta);
			
			AcessoNotificacao acesso = new AcessoNotificacao();
			acesso.setVisualizada("n");
			acesso.setId(id);
			
			session.save(acesso);
			
			session.flush();
			transaction.commit();			 
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			result = "../error_page.jsp?errorMsg=Não foi possível enviar a mensagem devido a um erro interno!&lk=application/notificacao.jsp";
		} finally {
			session.close();
		}
		return result;
	}
	
	private String setSessao(HttpServletRequest request) {
		String result = "0";
		Session session = HibernateUtil.getSession();
		Query query;
		try {
			query = session.createQuery("select a.id.notificacao from AcessoNotificacao as a " +
					" where a.id.login.username = :username and a.id.notificacao.status = 'a' " +
				" and a.visualizada = 'n'");
			query.setString("username", request.getSession().getAttribute("username").toString());
			List<Notificacao> notificacaoList = (List<Notificacao>) query.list();
			
			if (notificacaoList.size() > 0) {
				request.getSession().setAttribute("notificacaoList", notificacaoList);				
				if (request.getSession().getAttribute("saIsOpen") == null) {
					request.getSession().setAttribute("saIsOpen", "n");
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			result= "-1";
		}  finally {
			session.close();
		}
		return result;
	}
	
	private String delMessage(HttpServletRequest request) {
		String result = "../error_page.jsp?errorMsg=Mensagem deletada com sucesso!&lk=application/notificacao.jsp";
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		try {
			query = session.createQuery("from AcessoNotificacao as a " +
					" where a.id.login.username = :username " +
					" and a.id.notificacao.codigo = :idNotificacao");
			query.setString("username", request.getSession().getAttribute("username").toString());
			query.setLong("idNotificacao", Long.valueOf(request.getParameter("idNotificacao")));
			AcessoNotificacao acesso = (AcessoNotificacao) query.uniqueResult();
			acesso.setVisualizada("e");
			
			session.update(acesso);
			
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			result = "../error_page.jsp?errorMsg=Não foi possível deletar a mensagem devido a um erro interno!&lk=application/notificacao.jsp";
		} finally {
			session.close();
		}
		return result;		
	}
	
	private String getLogins(HttpServletRequest request) {
		String xml = "<?xml version=\"1.0\" encoding=\"iso-8859-1\" ?><loginColection>";
		Session session = HibernateUtil.getSession();
		try {
			Query query = session.createQuery("from Login as l where l.perfil = 'a' order by l.username");			
			List<Login> logins = (List<Login>) query.list();			
			xml+= "<logins id=\"adm\">";
			for (Login login : logins) {
				xml+= "<login username=\"" + login.getUsername() + 
					"\" foto=\"" + login.getFoto() + "\" />";
			}
			query = session.createQuery("select u.administrador.login from Unidade AS u " +
					" where u.codigo = :unidadeId order by u.administrador.login.username");
			query.setLong("unidadeId", Long.valueOf(request.getParameter("unidadeId")));
			logins = (List<Login>) query.list();
			for (Login login : logins) {
				xml+= "<login username=\"" + login.getUsername() + 
				"\" foto=\"" + login.getFoto() + "\" />";
			}
			xml+= "</logins><logins id=\"atendente\">";
			query = session.createQuery("select distinct(p.login) from Pessoa as p " +
					" where p.unidade.codigo = :unidadeId " +
					" and p.login.perfil = 'r' " +
					" ordre by p.login.userlname");
			query.setLong("unidadeId", Long.valueOf(request.getParameter("unidadeId")));
			logins = (List<Login>) query.list();
			for (Login login : logins) {
				xml+= "<login username=\"" + login.getUsername() + 
				"\" foto=\"" + login.getFoto() + "\" />";
			}
			xml+= "</logins></loginColection>";
			
		} catch (Exception e) {
			e.printStackTrace();
			xml = "<?xml version=\"1.0\" encoding=\"iso-8859-1\" ?><loginColection></loginColection>";
		} finally {
			session.close();
		}
		return xml;
	}
}
