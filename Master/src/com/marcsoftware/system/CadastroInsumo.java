package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Filter;
import com.marcsoftware.database.Insumo;
import com.marcsoftware.database.ItensCompra;
import com.marcsoftware.database.Plano;
import com.marcsoftware.database.Ramo;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroInsumo
 */
public class CadastroInsumo extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private PrintWriter out;
	private Session session;
	private Transaction transaction;
	private Query query;
	private Filter filter;
	private List<Insumo> insumoList;
	private Insumo insumo;
	private Ramo ramo;
	private Unidade unidade;
	private DataGrid dataGrid;
	private boolean isFilter;
	private int limit, offSet, gridLines;       
    
    public CadastroInsumo() {
        super();        
    }

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		switch (Integer.parseInt(request.getParameter("from"))) {
		case 0:
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/html");
			out= response.getWriter();
			session= HibernateUtil.getSession();
			transaction= session.beginTransaction();
			isFilter= request.getParameter("isFilter") == "1";
			mountFilter(request);
			limit= Integer.parseInt(request.getParameter("limit"));
			offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
			query = filter.mountQuery(query, session);
			gridLines= query.list().size();
			query.setFirstResult(offSet);
			query.setMaxResults(limit);	
			insumoList = (List<Insumo>) query.list();
			if (insumoList.size() == 0) {
				out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td></tr>");
				transaction.commit();
				session.close();
				out.close();
				return;
			}
			dataGrid= new DataGrid(null);
			for(Insumo ins: insumoList) {							
				dataGrid.setId(String.valueOf(ins.getCodigo()));
				dataGrid.addData("codigo" + ins.getCodigo(), String.valueOf(ins.getCodigo()), false);
				dataGrid.addData("ramo" + ins.getCodigo(), Util.encodeString(ins.getRamo().getDescricao(), "ISO-8859-1", "UTF-8"), false);
				dataGrid.addData("descricao" + insumo.getCodigo(), Util.encodeString(insumo.getDescricao(), "ISO-8859-1", "UTF-8"), false);
				dataGrid.addData("unidade" + insumo.getCodigo(), insumo.getUnidade().getReferencia());
				if(ins.getTipo().trim().equals("s")) {
					dataGrid.addData("tipo" + ins.getCodigo(), "Serviço", false);
				} else {
					dataGrid.addData("tipo" + ins.getCodigo(), "Produto", false);
				}
				if(ins.getTipo().trim().equals("d")) {
					dataGrid.addData("status" + ins.getCodigo(), "Descontinuado", false);
				} else {
					dataGrid.addData("status" + ins.getCodigo(), "Ativo", false);
				}
				dataGrid.addRow();
			}
			transaction.commit();
			session.close();
			out.print(dataGrid.getBody(gridLines));
			out.close();
			break;
		
		case 1:
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(Util.encodeString(addRecord(request, false), "ISO-8859-1", "UTF8"));
			out.close();						
			break;
		
		case 2:
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(Util.encodeString(deleteInsumo(request), "UTF8", "ISO-8859-1"));
			out.close();
			break;
			
		case 3:
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(Util.encodeString(remarcar(request), "ISO-8859-1", "UTF8"));
			out.close();
			break;
			
		case 4:
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/plain");
			out = response.getWriter();
			out.print(Util.encodeString(loadInsumo(request), "ISO-8859-1", "UTF8"));
			out.close();
			break;
			
		case 5:
			request.setCharacterEncoding("ISO-8859-1");
			response.setContentType("text/html");
			out= response.getWriter();
			session= HibernateUtil.getSession();
			transaction= session.beginTransaction();
			isFilter= request.getParameter("isFilter") == "1";
			mountFilter(request);
			limit= Integer.parseInt(request.getParameter("limit"));
			offSet = (isFilter)? 0 : Integer.parseInt(request.getParameter("offset"));
			query = filter.mountQuery(query, session);
			gridLines= query.list().size();
			query.setFirstResult(offSet);
			query.setMaxResults(limit);	
			insumoList = (List<Insumo>) query.list();
			if (insumoList.size() == 0) {
				out.print("<tr><td></td><td>Nenhum Registro Encontrado!</td><td></td><td></td><td></td></tr>");
				transaction.commit();
				session.close();
				out.close();
				return;
			}
			dataGrid= new DataGrid(null);
			for(Insumo ins: insumoList) {							
				dataGrid.setId(String.valueOf(ins.getCodigo()));
				dataGrid.addData("codigo" + ins.getCodigo(), String.valueOf(ins.getCodigo()), false);
				dataGrid.addData("ramo" + ins.getCodigo(), Util.encodeString(ins.getRamo().getDescricao(), "ISO-8859-1", "UTF-8"), false);
				dataGrid.addData("descricao" + insumo.getCodigo(), Util.encodeString(insumo.getDescricao(), "ISO-8859-1", "UTF-8"), false);
				dataGrid.addData("unidade" + insumo.getCodigo(), insumo.getUnidade().getReferencia());
				if(ins.getTipo().trim().equals("s")) {
					dataGrid.addData("tipo" + ins.getCodigo(), "Serviço", false);
				} else {
					dataGrid.addData("tipo" + ins.getCodigo(), "Produto", false);
				}
				if(ins.getTipo().trim().equals("d")) {
					dataGrid.addData("status" + ins.getCodigo(), "Descontinuado", false);
				} else {
					dataGrid.addData("status" + ins.getCodigo(), "Ativo", false);
				}
				dataGrid.addRow();
			}
			transaction.commit();
			session.close();
			out.print(dataGrid.getBody(gridLines));
			out.close();
			break;
		} 
	}

	private String addRecord(HttpServletRequest request, boolean isAdjuste) {
		String aux = request.getParameter("qtde");
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			ramo = (Ramo) session.get(Ramo.class, Long.valueOf(request.getParameter("ramo")));
			unidade = (Unidade) session.get(Unidade.class, Long.valueOf(request.getParameter("unidade")));
			if (request.getParameter("codigo").trim().equals("")) {
				insumo = new Insumo();
			} else {
				insumo = (Insumo) session.get(Insumo.class, 
						Long.valueOf(request.getParameter("codigo")));
			}
			insumo.setAtivo(request.getParameter("statusIn"));
			insumo.setDescricao(Util.encodeString(request.getParameter("descricao"), "ISO-8859-1","UTF8").toLowerCase());
			insumo.setTipo(request.getParameter("tipo"));
			insumo.setQtde(Integer.parseInt(request.getParameter("qtde")));
			insumo.setValor(Double.parseDouble(request.getParameter("valor")));
			insumo.setRamo(ramo);
			insumo.setUnidade(unidade);
			
			session.saveOrUpdate(insumo);
			if (isAdjuste) {
				query = session.createQuery("from Insumo as i where i.ramo = :ramo");
				query.setEntity("ramo", ramo);
				insumoList = (List<Insumo>) query.list();
				for (Insumo ins : insumoList) {
					if (isAdjuste) {
						aux = "0" + "@" + ins.getCodigo() + "@" + ins.getTipo() + "@" + ins.getDescricao();
						isAdjuste = false;
					} else {
						aux+= "|" + ins.getCodigo() + "@" + ins.getTipo() + "@" + ins.getDescricao();
					}
				}
				session.flush();
				transaction.commit();
				session.close();
				return aux;
			} else {
				session.flush();
				transaction.commit();
				session.close();
			}
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível salvar o Insumo devido a um erro interno!";
		}		
		return "Insumo salvo com sucesso!";
	}
	
	private String deleteInsumo(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			insumo = (Insumo) session.get(Insumo.class, 
					Long.valueOf(request.getParameter("codigo")));
			query = session.createQuery("from ItensCompra as i where i.id.insumo = :insumo");
			query.setEntity("insumo", insumo);
			if (query.list().size() > 0) {
				transaction.rollback();
				session.close();
				return "Para exclusão é necessário que não haja pedidos para este insumo!";
			} else {
				session.delete(insumo);
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Não foi possível excluir o Insumo devido a um erro interno!";
		}
		return "Insumo excluído com sucesso!";
	}
	
	private String loadInsumo(HttpServletRequest request) {
		Session session = HibernateUtil.getSession();
		Query query = session.createQuery("from ItensCompra i where i.id.insumo.codigo = :codInsumo order by i.id.compra.cadastro DESC");
		query.setLong("codInsumo", Long.valueOf(request.getParameter("codInsumo")));
		
		List<ItensCompra> itens = (List<ItensCompra>) query.list();
		if (itens.size() > 0 ) {
			return String.valueOf(itens.get(0).getCusto());			
		} else {
			return "0.00";
		}
	}
	
	private String remarcar(HttpServletRequest request) {
		Session session = HibernateUtil.getSession();
		String result = "";
		double valor = 0;
		if (request.getParameter("tipo").equals("p")) {
			valor = ((Double.parseDouble(request.getParameter("valor"))/100) + 1) * Double.parseDouble(request.getParameter("custo"));
		} else {
			valor = Double.parseDouble(request.getParameter("valor"));
		}
		Insumo insumo = (Insumo) session.load(Insumo.class, Long.valueOf(request.getParameter("idInumo")));
		try {
			transaction = session.beginTransaction();
			insumo.setValor(valor);
			session.saveOrUpdate(insumo);
			transaction.commit();
			result = "Operação realizada com sucesso";
			
		} catch (Exception e) {
			transaction.rollback();
			result = "Não foi possível concretizar a operação devido a um erro interno!";
		}
		return result;
	}
	
	private void mountFilter(HttpServletRequest request) {
		filter = new Filter("from Insumo as i where (1 = 1)");
		
		if (!request.getParameter("codigo").equals("")) {
			filter.addFilter("i.codigo = :codigo", Long.class, "codigo",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("codigo"))));
		}
		if (!request.getParameter("ramo").equals("")) {
			filter.addFilter("i.ramo.codigo = :ramo", Long.class, "ramo",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("ramo"))));
		}
		if (!request.getParameter("descricao").equals("")) {
			filter.addFilter("i.descricao LIKE :descricao", String.class, "descricao", 
					"%" + Util.encodeString(request.getParameter("descricao"), "ISO-8859-1", "UTF-8").toLowerCase() + "%");
		}
		if (!request.getParameter("statusIn").equals("")) {
			filter.addFilter("i.ativo = :status", String.class, "status", 
					Util.encodeString(request.getParameter("statusIn"), "ISO-8859-1", "UTF-8").toLowerCase());
		}
		if (!request.getParameter("tipo").equals("")) {
			filter.addFilter("i.tipo = :tipo", String.class, "tipo", 
					Util.encodeString(request.getParameter("tipo"), "ISO-8859-1", "UTF-8").toLowerCase());
		}
		if (!request.getParameter("unidade").equals("")) {
			filter.addFilter("i.unidade.codigo = :unidade", Long.class, "unidade",
					Long.valueOf(Util.removeZeroLeft(request.getParameter("unidade"))));
		}
		filter.setOrder("i.codigo");
	}
}
