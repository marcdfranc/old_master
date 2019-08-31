package com.marcsoftware.gateway;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Dependente;
import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class for Servlet: PosicaoGet
 *
 */
 public class DependenteGet extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
   static final long serialVersionUID = 1L;   
   
	public DependenteGet() {
		super();
	}	
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		response.setContentType("text/html");
		PrintWriter out= response.getWriter();
		Session session= HibernateUtil.getSession();
		try {
			Query query = null;
			boolean isFilter= request.getParameter("isFilter") == "1";
			Filter filter = mountFilter(request);
			int limit= Integer.parseInt(request.getParameter("limit"));
			int offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
			query = filter.mountQuery(query, session);
			int gridLines= query.list().size();
			query.setFirstResult(offSet);
			query.setMaxResults(limit);		
			List<Dependente> dependenteList = (List<Dependente>) query.list();
			if (dependenteList.size() == 0) {
				out.print("<tr><td></td><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td><td></td></tr>");
			} else {
				DataGrid dataGrid= new DataGrid(null);
				for (Dependente dep : dependenteList) {
					dataGrid.setId(String.valueOf(dep.getCodigo()));
					dataGrid.addData(dep.getUsuario().getReferencia());
					dataGrid.addData(dep.getReferencia());
					dataGrid.addData(Util.initCap(Util.encodeString(dep.getNome(), "UTF8", "ISO-8859-1")));
					dataGrid.addData((dep.getCpf() == null)?
							"" : Util.mountCpf(dep.getCpf()));
					dataGrid.addData((dep.getNascimento() == null)? "" : Util.parseDate(dep.getNascimento(), "dd/MM/yyyy"));							
					dataGrid.addData(dep.getFone());
					
					query = session.getNamedQuery("parcelaByDependente");							
					query.setEntity("usuario", dep.getUsuario());
					query.setEntity("dependente", dep);
					
					dataGrid.addImg((query.list().size() == 0)? "../image/ok_icon.png" : 
						Util.getIcon(query.list(), "orcamento"));			
					
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
		
	}
	
	private Filter mountFilter(HttpServletRequest request) {		
		Filter filter = new Filter("from Dependente as d where (1 = 1)");
		if (!request.getParameter("codUser").equals("")) {
			filter.addFilter("d.usuario.codigo = :usuario", Long.class, "usuario",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("codUser"))));
		}
		if (!request.getParameter("refTitular").equals("")) {
			filter.addFilter("d.usuario.referencia = :refTitular",
					String.class, "refTitular", request.getParameter("refTitular"));
		}
		if (!request.getParameter("referencia").equals("")) {
			filter.addFilter("d.referencia = :referencia",
					String.class, "referencia", request.getParameter("referencia"));
		}
		if (!request.getParameter("nomeIn").equals("")) {
			filter.addFilter("d.nome LIKE :nome", String.class, "nome", 
					"%" + Util.encodeString(request.getParameter("nomeIn"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("cpfIn").equals("")) {
			filter.addFilter("d.cpf = :cpf", String.class, "cpf", 
				 	Util.unMountDocument(request.getParameter("cpfIn")));
		}
		if (!request.getParameter("nascimentoIn").equals("")) {
			filter.addFilter("d.nascimento = :nascimento", java.util.Date.class, 
					"nascimento", Util.parseDate(request.getParameter("nascimentoIn")));
		}		
		if (!request.getParameter("fone").equals("")) {
			filter.addFilter("d.fone = :fone", String.class, "fone", request.getParameter("fone"));
		}
		if (!request.getParameter("ativoChecked").equals("")) {
			filter.addFilter("d.usuario.ativo = :ativo", String.class, "ativo",
					request.getParameter("ativoChecked"));
		}
		if (!request.getParameter("unidadeId").equals("")) {
			filter.addFilter("d.usuario.unidade.codigo = :unidade", Long.class, "unidade",
					Integer.parseInt(Util.getPart(request.getParameter("unidadeId"), 2)));
		}
		
		if (Util.getPart(request.getParameter("order"), 1).trim().equals("CTR")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("d.usuario.referencia");				
			} else {
				filter.setOrder("d.usuario.referencia desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Ref.")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("d.referencia");				
			} else {
				filter.setOrder("d.referencia desc");
			}
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Nome")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("d.nome");				
			} else {
				filter.setOrder("d.nome desc");
			}		
		} else if (Util.getPart(request.getParameter("order"), 1).trim().equals("Nascimento")) {
			if (Util.getPart(request.getParameter("order"), 2).trim().equals("asc")) {
				filter.setOrder("d.nascimento");
			} else {
				filter.setOrder("d.nascimento desc");
			}
		}	
		return filter;
	}
	
}