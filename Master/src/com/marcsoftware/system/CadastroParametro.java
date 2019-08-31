package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Parametro;
import com.marcsoftware.database.Relatorio;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroParametro
 */
public class CadastroParametro extends HttpServlet {
	private static final long serialVersionUID = 1L;	
    
    public CadastroParametro() {
        super();
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("ISO-8859-1");				
		PrintWriter out= response.getWriter();
		switch (Integer.parseInt(request.getParameter("from"))) {
		case 1:
			response.setContentType("text/palin");
			if (!positionConfig(request)) {
				out.print("0");
				out.close();
				return;
			} else {
				out.print("1");
				out.close();
				return;
			}

		case 2:
			response.setContentType("text/palin");
			out.print(getParameterConfig(request));
			out.close();
			return;
			
		case 3:
			response.setContentType("text/palin");
			out.print(sequenciar(request));
			out.close();
			return;
			
		default:
			response.setContentType("text/html");		
			Session session= HibernateUtil.getSession();
			boolean isFilter= request.getParameter("isFilter") == "1";		
			int limit= Integer.parseInt(request.getParameter("limit"));
			int offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
			Query query = session.createQuery("from Parametro as p order by p.codigo");		
			query.setFirstResult(offSet);
			query.setMaxResults(limit);
			List<Parametro> paramList = (List<Parametro>) query.list();
			int gridLines = paramList.size();
			try {
				if (paramList.size() == 0) {
					out.print("0");			
					session.close();
					out.close();
					return;
				}
				DataGrid dataGrid = new DataGrid(null);
				for (Parametro param : paramList) {
					dataGrid.setId(String.valueOf(param.getCodigo()));
					dataGrid.addData(String.valueOf(param.getCodigo()));
					dataGrid.addData(param.getDescricao());
					dataGrid.addData(param.getTipo());
					if (param.getComponente().trim().equals("r")) {
						dataGrid.addData("Radio Button");
					} else if (param.getComponente().trim().equals("i")) {
						dataGrid.addData("Item Selector");
					} else if (param.getComponente().trim().equals("c")) {
						dataGrid.addData("Combo Box");
					} else if (param.getComponente().trim().equals("t")) {
						dataGrid.addData("Prompt");
					} else {
						dataGrid.addData("Check Box");
					}
					dataGrid.addData(param.getRotulo());
					if (param.getRequerido().trim().equals("s")) {
						dataGrid.addData("Sim");
					} else {
						dataGrid.addData("Não");
					}
					dataGrid.addRow();
				}
				out.print(dataGrid.getBody(gridLines));
			} catch (Exception e) {
				e.printStackTrace();			
			} finally {
				out.close();
				session.close();
			}			
			break;
		}	
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		if (addRecord(request))  {
			response.sendRedirect("application/parametro.jsp?id=" + 
					request.getParameter("codRel"));
		} else {
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
			"&lk=application/parametro.jsp?id=" + request.getParameter("codRel"));
		}
	}
	
	private boolean addRecord(HttpServletRequest request) {
		boolean isEdition= (request.getParameter("codParam") != "");
		boolean result = true;
		Session session= HibernateUtil.getSession();
		Transaction transaction= session.beginTransaction();
		Query query;
		try {
			query = session.createQuery("from Relatorio as r where r.codigo = :relatorio");
			query.setLong("relatorio", Long.valueOf(request.getParameter("codRel")));
			Relatorio relatorio = (Relatorio) query.uniqueResult();
			
			Parametro parametro = new Parametro();
			if (isEdition) {
				parametro.setCodigo(Long.valueOf(request.getParameter("codParam")));
			}
			if (request.getParameter("componenteIn").trim().equals("c")
					|| request.getParameter("componenteIn").trim().equals("i")) {
				parametro.setMascara(request.getParameter("maskComboIn"));
			} else {
				parametro.setMascara(request.getParameter("maskIn"));
			}
			parametro.setComponente(request.getParameter("componenteIn"));
			parametro.setDados(request.getParameter("dadosIn").replace("\n", ""));
			parametro.setDescricao(request.getParameter("descricaoIn"));
			parametro.setRelatorio(relatorio);
			parametro.setRequerido(request.getParameter("requeridoIn"));
			parametro.setRotulo(request.getParameter("rotuloIn"));
			parametro.setTipo(request.getParameter("tipoIn"));
			parametro.setOperador(request.getParameter("operadorIn"));
			parametro.setCampo(request.getParameter("campoIn"));
			parametro.setRefUnidade(request.getParameter("chkUnidadeIn"));
			parametro.setSequencial(Integer.parseInt(request.getParameter("seq")));
			session.saveOrUpdate(parametro);			
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
	
	private boolean positionConfig(HttpServletRequest request) {
		List<String> dados;
		List<String> position;
		Long idx;
		String aux= "";
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		Parametro parametro;
		try {
			List<Long> pipe = Util.unmountPipeline(request.getParameter("id"));			
			for (Long pp : pipe) {
				query = session.createQuery("from Parametro as p where p.codigo = :parametro");
				query.setLong("parametro", pp);
				if (query.list().size() > 0) {
					parametro = (Parametro) query.uniqueResult();
					idx = parametro.getCodigo();
					switch (parametro.getComponente().charAt(0)) {
					case 'r':
						position = Util.unmountRealPipe(request.getParameter("position"));
						dados = Util.unmountRealPipe(request.getParameter("dados"));
						for (String pos : position) {
							if (Long.valueOf(Util.getPipeById(pos, 0)).equals(idx)) {
								parametro.setPx(Integer.parseInt(Util.getPipeById(pos, 1)));
								parametro.setPy(Integer.parseInt(Util.getPipeById(pos, 2)));
								break;
							}
						}
						for (String data : dados) {
							if (Long.valueOf(Util.getPart(data, 1)).equals(idx)) {
								aux= Util.getPart(data, 2).replace(";", "|");
								parametro.setDados(aux.replace(",", "@"));
								break;
							}
						}					
						break;
						
					case 'i':
						position = Util.unmountRealPipe(request.getParameter("position"));
						for (String pos : position) {
							if (Long.valueOf(Util.getPipeById(pos, 0)).equals(idx)) {
								parametro.setPx(Integer.parseInt(Util.getPipeById(pos, 1)));
								parametro.setPy(Integer.parseInt(Util.getPipeById(pos, 2)));
								break;
							}
						}
						break;
						
					case 'c':
						position = Util.unmountRealPipe(request.getParameter("position"));
						dados = Util.unmountRealPipe(request.getParameter("dados"));
						for (String pos : position) {
							if (Long.valueOf(Util.getPipeById(pos, 0)).equals(idx)) {
								parametro.setPx(Integer.parseInt(Util.getPipeById(pos, 1)));
								parametro.setPy(Integer.parseInt(Util.getPipeById(pos, 2)));
								break;
							}
						}
						for (String data : dados) {
							if (Long.valueOf(Util.getPart(data, 1)).equals(idx)) {
								aux= Util.getPart(data, 2).replace(";", "|");
								parametro.setMascara(aux.replace(",", "@"));
								break;
							}
						}
						break;
						
					case 'd':
						position = Util.unmountRealPipe(request.getParameter("position"));
						dados = Util.unmountRealPipe(request.getParameter("dados"));
						for (String pos : position) {
							if (Long.valueOf(Util.getPipeById(pos, 0)).equals(idx)) {
								parametro.setPx(Integer.parseInt(Util.getPipeById(pos, 1)));
								parametro.setPy(Integer.parseInt(Util.getPipeById(pos, 2)));
								break;
							}
						}
						for (String data : dados) {
							if (Long.valueOf(Util.getPart(data, 1)).equals(idx)) {
								aux= Util.getPart(data, 2).replace(";", "|");
								parametro.setDados(aux.replace(",", "@"));
								break;
							}
						}
						break;					
						
					case 't':
						position = Util.unmountRealPipe(request.getParameter("position"));
						dados = Util.unmountRealPipe(request.getParameter("dados"));
						for (String pos : position) {
							if (Long.valueOf(Util.getPipeById(pos, 0)).equals(idx)) {
								parametro.setPx(Integer.parseInt(Util.getPipeById(pos, 1)));
								parametro.setPy(Integer.parseInt(Util.getPipeById(pos, 2)));
								break;
							}
						}
						for (String data : dados) {
							if (Long.valueOf(Util.getPart(data, 1)).equals(idx)) {
								aux= Util.getPart(data, 2).replace(";", "|");
								parametro.setDados(aux.replace(",", "@"));
								break;
							}
						}
						break;
						
					case 'k':
						position = Util.unmountRealPipe(request.getParameter("position"));
						for (String pos : position) {
							if (Long.valueOf(Util.getPipeById(pos, 0)).equals(idx)) {
								parametro.setPx(Integer.parseInt(Util.getPipeById(pos, 1)));
								parametro.setPy(Integer.parseInt(Util.getPipeById(pos, 2)));
							}
						}
						break;
					}
					session.update(parametro);
				}
			}
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return false;
		} finally {
			session.close();
		}
		return true;
	}
	
	private String getParameterConfig(HttpServletRequest request) {
		String retorno= "";
		String aux= "";
		Session session = HibernateUtil.getSession();		
		Query query;
		try {
			query = session.createQuery("from Parametro as p where p.relatorio.codigo = :relatorio");
			query.setLong("relatorio", Long.valueOf(request.getParameter("relatorio")));
			List<Parametro> paramList = (List<Parametro>) query.list();
			for (Parametro param : paramList) {
				if (retorno.trim().equals("")) {
					retorno+= param.getCodigo();					
				} else {
					retorno+= "|" + param.getCodigo();
				}
				aux = param.getDados().replace("|", ";");
				aux = aux.replace("@", ",");
				retorno+= "@" + param.getComponente() + "@" + param.getPx();
				retorno+= "@" + param.getPy() + "@";
				retorno+= (param.getComponente().trim().equals("i")
						|| param.getComponente().trim().equals("c"))? "-1" : aux;
				retorno+= "@" + param.getRotulo() + "@" + param.getMascara();
			}					
		} catch (Exception e) {
			e.printStackTrace();			
			retorno = "0";
		} finally {
			session.close();
		}
		return retorno;
	}
	
	private String sequenciar(HttpServletRequest request) {
		String result = "0";
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;		
		try {
			query = session.createQuery("from Parametro as p where p.relatorio.codigo = :relatorio");
			query.setLong("relatorio", Long.valueOf(request.getParameter("codRel")));
			List<Parametro> parametros = (List<Parametro>) query.list();
			ArrayList<String> pipe = Util.unmountRealPipe(request.getParameter("pipe"));
			for (Parametro param : parametros) {
				for (String pp : pipe) {
					if (param.getCodigo().equals(Long.valueOf(Util.getPart(pp, 1)))) {
						param.setSequencial(Integer.parseInt(Util.getPart(pp, 2)));
						break;
					}
				}
				session.update(param);
			}
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			result = "-1";
		} finally {
			session.close();
		}
		return result;
	}
}
