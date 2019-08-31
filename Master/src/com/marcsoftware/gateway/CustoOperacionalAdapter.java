package com.marcsoftware.gateway;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.database.Profissional;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CustoOperacionalAdapter
 */
public class CustoOperacionalAdapter extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Session session;
	private Transaction transaction;
	private Query query;
	private List<Profissional> profissionalList;
	private Unidade unidade;
	private List<ParcelaOrcamento> parcelaList;
	private Date vencimento, now;
	private double vlrCliente, operacional, calcOperacional, calcCliente, totalOperacional,
		totalCliente, totalC2, retorno;
	private int totalGuias, gridLines;
	private PrintWriter out;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CustoOperacionalAdapter() {
        super();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/html");
		out= response.getWriter();
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			now = new Date();
			DataGrid dataGrid = new DataGrid("#");
			dataGrid.addColum("5", "Ref.");
			dataGrid.addColum("35", "Nome");
			dataGrid.addColum("5", "Guias");
			dataGrid.addColum("19", "Vencimento");
			dataGrid.addColum("12", "Vlr. Cliente");
			dataGrid.addColum("12", "Vlr. Operac.");
			dataGrid.addColum("12", "Vlr. Adm.");
			if (!request.getParameter("unidadeId").equals("")) {
				unidade = (Unidade) session.get(Unidade.class, Long.valueOf(request.getParameter("unidadeId")));
				if (unidade == null) {
					query = session.createQuery("from Profissional as p where (1 <> 1)");
				} else {
					query = session.createQuery("from Profissional as p where p.unidade = :unidade order by p.codigo");
					query.setEntity("unidade", unidade);
				}
			} else if (request.getSession().getAttribute("perfil").toString().equals("a")) {
				query = session.createQuery("from Profissional as p");
			} else {
				query = session.createQuery("from Profissional as p where (1 <> 1)");
			}
			profissionalList = (List<Profissional>) query.list();
			gridLines = profissionalList.size();
			totalGuias =  0;
			totalCliente = calcCliente = calcOperacional = totalOperacional = totalC2 = 0;
			
			for(Profissional prof: profissionalList) {
				vlrCliente = operacional = retorno = 0;				
				if (request.getParameter("unidadeId").trim().equals("")) {
					query = session.createQuery("from ParcelaOrcamento as p " + 
							" where p.id.lancamento.status in('q', 'f') " +
							" and p.id.orcamento.profissional.codigo = :profisional " +
							" and p.id.lancamento.dataQuitacao between :inicio and :fim");
					//query = session.getNamedQuery("pagProfissionalBase");						
				} else {
					query = session.createQuery("from ParcelaOrcamento as p " + 
							" where p.id.lancamento.status in('q', 'f') " +
							" and p.id.lancamento.unidade.codigo = :unidade " +
							" and p.id.orcamento.pessoa.codigo = :profissional " +
							" and p.id.lancamento.dataQuitacao between :inicio and :fim");
					
					//query = session.getNamedQuery("pagProfissionalUnd");
					query.setLong("unidade", Long.valueOf(request.getParameter("unidadeId")));
				}
				query.setLong("profissional", prof.getCodigo());
				query.setDate("inicio", Util.parseDate(request.getParameter("inicio")));
				
				query.setDate("fim", Util.parseDate(request.getParameter("fim")));
				vencimento = Util.parseDate(prof.getVencimento() + "/" +
						Util.getMonthDate(now) + "/" + Util.getYearDate(now));
				
				parcelaList = (List<ParcelaOrcamento>) query.list();
				for(ParcelaOrcamento parcela: parcelaList) {
					query = session.getNamedQuery("operacionalOrcamento");
					query.setLong("orcamento", parcela.getId().getOrcamento().getCodigo());
					query.setLong("unidade", parcela.getId().getLancamento().getUnidade().getCodigo());
					calcOperacional = Util.round(Double.parseDouble(query.uniqueResult().toString()), 2);
					
					query = session.getNamedQuery("clienteOrcamento");
					query.setLong("orcamento", parcela.getId().getOrcamento().getCodigo());
					query.setLong("unidade", parcela.getId().getLancamento().getUnidade().getCodigo());
					calcCliente = Util.round(Double.parseDouble(query.uniqueResult().toString()), 2);
					
					vlrCliente+= parcela.getId().getLancamento().getValor();
					vlrCliente = Util.round(vlrCliente, 2);
					operacional+= Util.getOperacional(calcOperacional, calcCliente,
							parcela.getId().getLancamento().getValor());
					operacional = Util.round(operacional, 2);
				}
				totalGuias+= parcelaList.size(); 
				totalCliente+= vlrCliente;
				totalCliente = Util.round(totalCliente, 2);
				totalOperacional+= operacional;
				totalOperacional = Util.round(totalOperacional, 2);
				totalC2 += (vlrCliente - operacional);
				totalC2 = Util.round(totalC2, 2);
				
				dataGrid.setId(String.valueOf(prof.getCodigo()));
				dataGrid.addData(String.valueOf(prof.getCodigo()));
				dataGrid.addData(Util.initCap(prof.getNome()));
				dataGrid.addData(String.valueOf(parcelaList.size()));
				dataGrid.addData(Util.parseDate(vencimento, "dd/MM/yyyy"));
				dataGrid.addData(Util.formatCurrency(vlrCliente));
				dataGrid.addData(Util.formatCurrency(operacional));
				dataGrid.addData(Util.formatCurrency(Util.round(vlrCliente - operacional, 2)));
				
				dataGrid.addRow();
			}		
			dataGrid.addTotalizador("Vlr. Administrativo", Util.formatCurrency(totalC2), true);
			dataGrid.addTotalizador("Vlr. Operacional", Util.formatCurrency(totalOperacional), true);
			dataGrid.addTotalizador("Vlr. Cliente", Util.formatCurrency(totalCliente), true);
			dataGrid.addTotalizador("Guias Emitidas", String.valueOf(totalGuias), false);
			dataGrid.makeTotalizador();
			out.print(dataGrid.getTable(gridLines));
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			out.print("erro");
		}
		out.close();
	}

}
