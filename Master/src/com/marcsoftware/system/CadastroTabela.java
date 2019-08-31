package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;


import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Servico;
import com.marcsoftware.database.Tabela;
import com.marcsoftware.database.TabelaId;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.database.Vigencia;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class for Servlet: CadastroServico
 *
 */
public class CadastroTabela extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
	static final long serialVersionUID = 1L;
	private Servico servico;
	private Tabela tabela;
	private TabelaId idTable;	
	private Unidade unidade;
	private List<Tabela> tabelaList;
	private boolean isFilter, haveUnit;
	private int limit, offSet, gridLines;
	private DataGrid dataGrid;
	private PrintWriter out;
	private Filter filter;
	private Session session;
	private Transaction transaction;
	private Query query;
	    
	public CadastroTabela() {
		super();
	}	
		
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		switch (Integer.parseInt(request.getParameter("from"))) {
		case 0:
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			session= HibernateUtil.getSession();
			transaction= session.beginTransaction();
			isFilter= request.getParameter("isFilter") == "1";
			haveUnit= !request.getParameter("unidadeId").trim().isEmpty(); 
			if (haveUnit) {
				mountFilter(request);			
				query = filter.mountQuery(query, session); 
			} else {
				query = session.getNamedQuery("tabelaUnidadeByCode");
				query.setLong("codigo", 0);
			}
			limit= Integer.parseInt(request.getParameter("limit"));
			offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));	
			gridLines= query.list().size();
			query.setFirstResult(offSet);
			query.setMaxResults(limit);
			tabelaList= (List<Tabela>) query.list();
			if (tabelaList.size()== 0) {
				out.print("0");
				transaction.commit();
				session.close();
				out.close();
				return;
			}
			if (request.getSession().getAttribute("perfil").toString().trim().equals("a")
					|| request.getSession().getAttribute("perfil").toString().trim().equals("d")
					|| request.getSession().getAttribute("perfil").toString().trim().equals("f")){
				dataGrid = new DataGrid("cadastro_tabela.jsp");
			} else {
				dataGrid = new DataGrid("#");
			}
			//dataGrid = new DataGrid("cadastro_tabela.jsp");
			for (Tabela tab : tabelaList) {
				dataGrid.setId(tab.getCodigo() + "&unidadeId=" + tab.getUnidade().getCodigo() + 
						"&vigencia=" +	tab.getVigencia().getCodigo());
				dataGrid.addData(tab.getServico().getReferencia());
				if (tab.getServico().getEspecialidade().getSetor().equals("o")) {
					dataGrid.addData("Odontológico");
				} else if (tab.getServico().getEspecialidade().getSetor().equals("m")){
					dataGrid.addData("Médico");
				} else if (tab.getServico().getEspecialidade().getSetor().equals("l")){
					dataGrid.addData("Laboratorial");
				} else {
					dataGrid.addData("Hospitalar");
				}
				dataGrid.addData(Util.initCap(
						tab.getServico().getEspecialidade().getDescricao()));
				dataGrid.addData(Util.initCap(tab.getServico().getDescricao()));
				if (request.getSession().getAttribute("perfil").equals("a") 
						|| request.getSession().getAttribute("perfil").equals("d")
						|| request.getSession().getAttribute("perfil").equals("f")) {
					dataGrid.addData(Util.formatCurrency(String.valueOf(tab.getValorCliente())));							
					dataGrid.addData(Util.formatCurrency(String.valueOf(tab.getOperacional())));
				} else if (request.getSession().getAttribute("perfil").equals("r")) {
					dataGrid.addData(Util.formatCurrency(String.valueOf(tab.getValorCliente())));
					dataGrid.addData("----------");									
				} else if (request.getSession().getAttribute("perfil").equals("p")) {
					dataGrid.addData("----------");
					dataGrid.addData(Util.formatCurrency(String.valueOf(tab.getOperacional())));
				}
				dataGrid.addRow();
			}
			transaction.commit();
			out.print(dataGrid.getBody(gridLines));
			session.close();
			out.close();			
			break;

		case 1:
			response.setContentType("text/plain");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			out.print(getAprovado(request));
			out.close();
			break;
			
		case 2:
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			out.print(getServicos(request));
			out.close();
			break;	
		}
	}	
		
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		boolean isOk = true;
		try {
			if (request.getParameter("tipoSubmit").equals("e")) {
				isOk = excluir(request);
			} else {
				isOk = addRecord(request);
			}				
			if (isOk)  {
				response.sendRedirect("application/tabela.jsp");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=Não foi possível completar a operação devido a um erro interno!" +  
				"&lk=application/servico.jsp");
			}			
		} catch (Exception e) {			
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=Não foi possível completar a operação devido a um erro interno!" +  
			"&lk=application/servico.jsp");
		}
	}
	
	private boolean addRecord(HttpServletRequest request) {
		boolean isEdition= !request.getParameter("tabelaId").trim().equals(""); 
		String aprovacao = "";
		session= HibernateUtil.getSession();		
		transaction= session.beginTransaction();		
		try {
			if (isEdition) {
				tabela = (Tabela) session.get(Tabela.class, 
						Long.valueOf(request.getParameter("tabelaId")));
			} else {				
				servico= (Servico) session.load(Servico.class, 
						Long.valueOf(Util.getPart(request.getParameter("servicoIn"), 1)));
				
				query= session.createQuery("from Unidade as u where u.codigo = :codigo");			
				query.setLong("codigo", Long.valueOf(Util.getPart(request.getParameter("unidadeIdIn"), 2)));		
				unidade = (Unidade) query.uniqueResult();
				
				Vigencia vigencia = (Vigencia) session.load(Vigencia.class, 
						Long.valueOf(request.getParameter("tabelaIn")));
				
				tabela= new Tabela();
				tabela.setServico(servico);
				tabela.setUnidade(unidade);
				//tabela.setAprovacao(aprovacao);
				tabela.setVigencia(vigencia);
			}			
			tabela.setOperacional(Double.parseDouble(request.getParameter("operacionalIn")));
			tabela.setValorCliente(Double.parseDouble(request.getParameter("vlrClienteIn")));
			
			session.saveOrUpdate(tabela);
			
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
	
	private void mountFilter(HttpServletRequest request) {
		if (request.getParameter("tabelaIn").equals("")) {
			filter = new Filter("from Tabela as t where (1 <> 1)");
		} else {
			filter = new Filter("from Tabela as t where (1 = 1)");
			filter.addFilter("t.vigencia.codigo = :vigencia",
				Long.class, "vigencia", Long.valueOf(request.getParameter("tabelaIn")));
		}
		
		//filter.addFilter("t.aprovacao = :aprovacao", String.class, "aprovacao", "s");
		
		filter.addFilter("t.id.unidade.codigo = :unidade", Long.class, 
				"unidade", Long.valueOf(request.getParameter("unidadeId")));		
		
		if (!request.getParameter("referenciaIn").equals("")) {
			filter.addFilter("t.id.servico.referencia = :referencia",
					String.class, "referencia", request.getParameter("referenciaIn"));
		}
		if (!request.getParameter("setorIn").equals("")) {
			filter.addFilter("t.id.servico.especialidade.setor = :setor",
					String.class, "setor", request.getParameter("setorIn"));
		}
		if (!request.getParameter("especialidadeIn").equals("")) {
			filter.addFilter("t.servico.especialidade.descricao = :especialidade",
					String.class, "especialidade", request.getParameter("especialidadeIn"));
		}
		if (!request.getParameter("descricaoIn").equals("")) {
			filter.addFilter("t.id.servico.descricao LIKE :descricao", String.class, "descricao", 
					"%" + Util.encodeString(request.getParameter("descricaoIn"), "ISO-8859-1", 
							"UTF8").toLowerCase()  + "%");
		}
		filter.setOrder("t.servico.especialidade.descricao, t.servico.descricao");
	}
	
	private String getAprovado(HttpServletRequest request) {
		String aux = "";
		ArrayList<String> tabelaAprove;
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			query= session.createQuery("from Unidade as u where u.codigo = :codigo");
			query.setLong("codigo", Long.valueOf(request.getParameter("unidadeId")));
			unidade= (Unidade) query.uniqueResult();
			aux+= unidade.getDescricao();
			
			query = session.createQuery("from Vigencia as v where v.unidade = :unidade");
			query.setEntity("unidade", unidade);
			List<Vigencia> vigencias = (List<Vigencia>) query.list();
			
			for (Vigencia vigencia : vigencias) {
				aux+= "|" + vigencia.getCodigo() + "@" + vigencia.getDescricao();					
			}			
			transaction.commit();
			session.close();
			return aux;
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "";
		}
	}
	
	private boolean excluir(HttpServletRequest request) {
		boolean isEdition= !request.getParameter("tabelaId").trim().equals("");
		boolean result = true;
		if (isEdition) {
			session = HibernateUtil.getSession();
			transaction = session.beginTransaction();
			try {
				tabela = (Tabela) session.load(Tabela.class, Long.valueOf(request.getParameter("tabelaId")));
				query = session.createQuery("from ItensOrcamento as i where i.tabela = :tabela");
				query.setEntity("tabela", tabela);
				result = query.list().size() <= 0;
				if (result) {
					session.delete(tabela);
					session.flush();
					transaction.commit();				
				} else {
					transaction.rollback();
				}
			} catch (Exception e) {
				e.printStackTrace();
				transaction.rollback();
				result = false;
			} finally {
				session.close();
			}
		} else {
			result = false;
		}
		return result;
	}
	
	private String getServicos(HttpServletRequest request) {
		String result = "<option value=\"\">Selecione</option>";
		session = HibernateUtil.getSession();
		try {
			query = session.createQuery("from Servico AS s where s.especialidade.codigo = :idEspecialidade");
			query.setLong("idEspecialidade", Long.valueOf(request.getParameter("idEspecialidade")));
			List<Servico> servicos = (List<Servico>) query.list();
			for (Servico serv : servicos) {
				result += "<option value=\"" + serv.getCodigo() + "@" +  serv.getReferencia() + "@" +
					serv.getEspecialidade().getCodigo() + "\">" + serv.getDescricao() +
					"</option>";
			}
		} catch (Exception e) {
			e.printStackTrace();
			result = "<option value=\"\">Selecione</option>";
		} finally {
			session.close();
		}
		return result;
	}
}