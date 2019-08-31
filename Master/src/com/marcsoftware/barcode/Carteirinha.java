package com.marcsoftware.barcode;

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

import com.marcsoftware.database.Dependente;
import com.marcsoftware.database.Endereco;
import com.marcsoftware.database.Informacao;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.BarcodeFactory;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;
/**
 * Servlet implementation class for Servlet: CadastroUnidade
 *@author: Marcelo de Oliveira Francisco
 *@web.servlet
 *  name=CadastroUnidade
 * @cliente: Josias
 * @empresa: Master Odontologia & Saude
 */
 public class Carteirinha extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
   static final long serialVersionUID = 1L;
   private List<Usuario> usuario;
   private List<Dependente> dependente;
   private Dependente dep;
   private Endereco endereco;
   private ArrayList<String> pipe;
   private PrintWriter out;
   private int via;
   private BarcodeFactory factory;
   
   public Carteirinha() {
		super();		
   }
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {		
		if (request.getParameter("from").trim().equals("0")) {
			response.setContentType("text/plain");
			response.setCharacterEncoding("ISO-8859-1");
			out = response.getWriter();
			out.print(getContratos(request));
		} else {
			//out.print(this.getServletContext().getRealPath("/application"));
			//out.print(xmlPrepare(request));
			if (request.getParameter("isTeste").equals("f")) {
				setCarteirinhas(request);
			}
			switch (Integer.parseInt(request.getParameter("tipoRel"))) {
			case 0:
				response.sendRedirect("GeradorRelatorio?rel=11&parametros=7@" +  request.getParameter("unidadeId") +
						"|8@" +  request.getParameter("parametros"));				
				break;

			case 1:
				response.sendRedirect("GeradorRelatorio?rel=200&parametros=454@" +  request.getParameter("unidadeId") +
						"|453@" +  request.getParameter("parametros"));
				break;
				
			case 2:
				response.sendRedirect("GeradorRelatorio?rel=201&parametros=456@" +  request.getParameter("unidadeId") +
						"|455@" +  request.getParameter("parametros"));
				break;
			}
		}
		out.close();		
	}	
	
	private String getContratos(HttpServletRequest request) {
		String sql = "";
		String aux= "";
		String ctr = "";
		boolean isEmpresa = request.getParameter("ctrEmpresa").trim().equals("e");
		boolean isFirst = true;
		if (isEmpresa) {
			sql = "select c.id.usuario from ContratoEmpresa as c " +
					" where (1=1) and c.id.usuario.unidade.codigo =  " +
					request.getParameter("unidade");
		} else if (request.getParameter("ctrEmpresa").trim().equals("c")) {
			sql = "from Usuario as u " +
					" where u not in(select c.id.usuario from ContratoEmpresa as c) " +
					" and u.unidade.codigo = " + request.getParameter("unidade");
		} else {
			sql = "from Usuario as u " +
					" where (1 = 1) and u.unidade.codigo = " + 
					request.getParameter("unidade");
		}
		Session session = HibernateUtil.getSession();
		try {
			if (request.getParameter("via").trim().equals("p")) {
				sql+= (isEmpresa)? "and c.id.usuario.carteirinha = 0 " : 
					"and u.carteirinha = 0 ";
			}
			if (!request.getParameter("pipe").trim().equals("")) {
				//pipe = Util.unmountPipelineStr(request.getParameter("pipe"));
				sql+= (isEmpresa)? "and c.id.empresa.referencia in (" : 
					"and u.contrato.ctr in (";				
				sql+= request.getParameter("pipe").replace(";", ",") +  ")";
			}		
			
			isFirst = true;
			Query query = session.createQuery(sql);		
			usuario = (List<Usuario>) query.list();
			for (Usuario user : usuario) {
				if (! request.getParameter("dependenteType").trim().equals("d")) {
					ctr = user.getContrato().getCtr() + "-0";
					if (isFirst) {
						aux+= ctr + "@" +  ctr  + " " + Util.initCap(user.getNome());					
						isFirst = false;
					} else {						 
						aux+= "|" + ctr + "@" + ctr + " " + Util.initCap(user.getNome());
					}
				}								
				
				if (! request.getParameter("dependenteType").trim().equals("c")) {
					query = session.createQuery("from  Dependente as d where d.usuario.codigo = :usuario");
					query.setLong("usuario", user.getCodigo());
					dependente = (List<Dependente>) query.list();					
					for (Dependente dep : dependente) {
						if ((request.getParameter("via").trim().equals("p")
								&& (dep.getCarteirinha() == 0))
								|| (request.getParameter("via").trim().equals("t"))) {
							ctr = user.getContrato().getCtr() + "-" + dep.getReferencia();
							if (isFirst) {
								aux+= ctr + "@" + ctr + " " + Util.initCap(dep.getNome());
								isFirst = false;
							} else {
								aux+= "|" + ctr + "@" + ctr + " " +	Util.initCap(dep.getNome());
							}
						}
					}
				}
			}			
		} catch (Exception e) {
			e.printStackTrace();
			aux =  "0@nenhum registro encontrado!";
		} finally {
			session.close();
		}
		return aux;
	}
	
	private boolean setCarteirinhas(HttpServletRequest request) {
		boolean result = true;
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		Usuario usuario = null;
		try {
			String pipeStr = request.getParameter("parametros").replace(",", "@");
			ArrayList<String> pipes = Util.unmountPipelineStr(pipeStr);
			int index = pipes.get(0).indexOf("-");
			int qtde = 0;
			Long unidadeId = Long.valueOf(request.getParameter("unidadeId"));
			Dependente dependente = null;
			pipeStr = pipes.get(0).substring(0, index);
			query = session.createQuery("from Usuario AS u " +
				" where u.contrato.ctr = :ctr and u.unidade.codigo = :unidadeId");
			query.setLong("ctr", Long.valueOf(pipeStr));
			query.setLong("unidadeId", unidadeId);
			usuario = (Usuario) query.uniqueResult();
			
			for (String pipe : pipes) {
				index = pipe.indexOf("-") + 1;
				pipeStr = pipe.substring(index, pipe.length());
				if (pipeStr.equals("0")) {
					qtde = usuario.getCarteirinha();
					usuario.setCarteirinha(++qtde);					
					session.update(usuario);					
				} else {
					query = session.createQuery("from Dependente as d where d.usuario = :usuario " +
							" and d.referencia = :referencia");
					query.setEntity("usuario", usuario);
					query.setString("referencia", pipeStr);
					dependente = (Dependente) query.uniqueResult();
					qtde = dependente.getCarteirinha();
					dependente.setCarteirinha(++qtde);
					session.update(dependente);
				}
			}
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
	
	/*private String xmlPrepare(HttpServletRequest request) {
		factory = new BarcodeFactory(this.getServletContext().getRealPath("/application/temp_barcode"));
		String cidade = "";
		String telefone = "";
		boolean isFirst= true;
		
		String xml = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>" +
			"<Carteira xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" " +
			"xsi:noNamespaceSchemaLocation=\"carteirinha.xsd\">";	
		
		String sql = "from Usuario as u where u.codigo in(";
		
		pipe = Util.unmountPipelineStr(request.getParameter("usuario"));
		for (String pp : pipe) {			
			if (isFirst) {
				sql+= Util.getPart(pp.replace("|", "@"), 1);				
				isFirst = false;				
			} else {
				sql+= ", " + Util.getPart(pp.replace("|", "@"), 1);
			}
		}
		sql+= (isFirst)? "0)" : ")";		
		
		try {
			query = session.createQuery(sql);
			usuario = (List<Usuario>) query.list();			
			
			for (Usuario user : usuario) {
				query = session.createQuery("from Endereco as e where e.pessoa.codigo = :codigo");
				query.setLong("codigo", user.getUnidade().getCodigo());
				if (query.list().size() > 0) {
					endereco = (Endereco) query.list().get(0);					
					cidade = Util.initCap(endereco.getCidade()) + "-" +
						endereco.getUf().toUpperCase();					
				} else {
					cidade = "";					
				}
				
				query = session.createQuery("from Informacao as i where i.pessoa.codigo = :codigo and i.principal = 's' ");
				query.setLong("codigo", user.getUnidade().getCodigo());
				if (query.list().size() > 0) {
					telefone = ((Informacao) query.list().get(0)).getDescricao();
				} else {
					telefone = "";
				}
				
				for (String pp : pipe) {
					if (Long.valueOf(Util.getPart(pp.replace("|", "@"), 1)).equals(user.getCodigo()) &&
							Util.getPart(pp.replace("|", "@"), 2).trim().equals("0")) {
						xml += "<carteirinha><codigo>" + user.getCodigo() + "</codigo>" +
						"<dependente_ref>0</dependente_ref>" +
						"<nome>" + Util.initCap(user.getNome()) + "</nome>" +
						"<ctr>" + Util.zeroToLeft(user.getContrato().getCtr(), 4) + "</ctr>" +
						"<plano>"+ user.getPlano().getDescricao() + "</plano>" +
						"<unidade>" + user.getUnidade().getReferencia() + "</unidade>"+
						"<cidade>" + cidade + "</cidade>" +
						"<telefone>" + telefone + "</telefone></carteirinha>";
						via = user.getCarteirinha();
						user.setCarteirinha(++via);
						session.update(user);
					} else if ((!Util.getPart(pp.replace("|", "@"), 2).trim().equals("0")) &&
							Long.valueOf(Util.getPart(pp.replace("|", "@"), 1)).equals(user.getCodigo())) {
						query = session.createQuery("from Dependente as d where d.codigo = :codigo");
						query.setLong("codigo", Long.valueOf(Util.getPart(pp.replace("|", "@"), 2)));
						dep = (Dependente) query.uniqueResult();
						xml += "<carteirinha><codigo>" + user.getCodigo() + "</codigo>" +
						"<dependente_ref>" + dep.getReferencia() + "</dependente_ref>" +
						"<nome>" + Util.initCap(dep.getNome()) + "</nome>" +
						"<ctr>" + Util.zeroToLeft(user.getContrato().getCtr(), 4)  + "</ctr>" +
						"<plano>"+ user.getPlano().getDescricao() + "</plano>" +
						"<unidade>" + user.getUnidade().getReferencia() + "</unidade>"+
						"<cidade>" + cidade + "</cidade>" +
						"<telefone>" + telefone + "</telefone></carteirinha>";
						via = dep.getCarteirinha();
						dep.setCarteirinha(++via);
						session.update(dep);
					}
				}
				factory.generateBarcode(Util.zeroToLeft(user.getCodigo(), 7) , 0, 15, 2, false);				
			}
			xml+= "</Carteira>";
			factory.createXml(xml);
			session.flush();
			transaction.commit();
		} catch (Exception e) {			
			e.printStackTrace();			
			transaction.rollback();
			session.close();
			factory.run();
			return "-1";
		}
		factory.close();
		return "0";
	}*/
	
	
}