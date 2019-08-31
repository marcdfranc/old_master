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

import com.marcsoftware.database.Contrato;
import com.marcsoftware.database.FaturaVendedor;
import com.marcsoftware.database.Funcionario;
import com.marcsoftware.database.ItensVendedor;
import com.marcsoftware.database.ItensVendedorId;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Parametro;
import com.marcsoftware.database.Relatorio;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroContrato
 */
public class CadastroContrato extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Session session;	
	private Transaction transaction;
	private Query query;	
	private Contrato contrato;
	private FaturaVendedor fatura;
	private ItensVendedorId id;
	private ItensVendedor itensVendedor;
	private Funcionario funcionario;
	private Lancamento lancamento, adesao;
	private TipoConta conta;
	//private double adesao;
	private List<Usuario> usuarioList;
	private List<Contrato> contratoList;
	private ArrayList<Long> pipe;
	private PrintWriter out;
   
    public CadastroContrato() {
        super();        
    }

	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.setContentType("text/plain");
		out= response.getWriter();
		switch (Integer.parseInt(request.getParameter("from"))) {
		case 0:
			out.print(mountCtr(request));			
			break;
		
		case 1:
			if (generateFatura(request)) {
				out.print("0");
			} else {
				out.print("1");
			}			
			break;
		
		case 2:
			if(deleteFatura(request)) {
				out.print("0");
			} else {
				out.print("1");
			}
			break;
			
		case 3:
			printContrato(request);
			session = HibernateUtil.getSession();
			try {
				query = session.createQuery("from Relatorio AS r where r.nome = :relUnidade");
				query.setString("relUnidade", request.getParameter("idUnidade") + "contrat");				
				String idRel = String.valueOf(((Relatorio) query.uniqueResult()).getCodigo());
				query = session.createQuery("from Parametro as p where p.relatorio.codigo = :codRel and p.tipo <> 'cn'");
				query.setLong("codRel", Long.valueOf(idRel));				
				String virgulaContrato = request.getParameter("contratos").replace("@", ",");
				String paramList = ((Parametro) query.uniqueResult()).getCodigo() + "@" + virgulaContrato;				
				response.sendRedirect("GeradorRelatorio?rel=" + idRel + "&parametros=" + paramList);			
			} catch (Exception e) {
				e.printStackTrace();				
			} finally {
				session.close();
			}
			break;
		}	
		out.close();
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try {			
			if (addRecord(request))  {
				response.sendRedirect("application/funcionario.jsp");
			} else {
				response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
				"&lk=application/funcionario.jsp");
			}
		} catch (Exception e) {			
			e.printStackTrace();
			response.sendRedirect("error_page.jsp?errorMsg=" + Util.ERRO_INSERT + 
			"&lk=application/cliente_fisico.jsp");
		}
	}
	
	private String mountCtr(HttpServletRequest request) {
		String aux = "";
		int count = 0;
		int index = 0;
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			if (request.getParameter("byPeriodo").equals("s")) {
				query = session.createQuery("select max(c.ctr) from Contrato as c " +
							"where c.unidade.codigo = :unidade");
				query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
				index = Integer.parseInt(query.uniqueResult().toString()) + 1;
				count = Integer.parseInt(request.getParameter("qtde")) + index;
				for (int i = index; i < count; i++) {
					query = session.createQuery("from Contrato as c " +
							" where c.unidade.codigo = :unidade " +
							" and c.ctr = :ctr");
					query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
					query.setLong("ctr", Long.valueOf(String.valueOf(i)));
					if (query.list().size() > 0) {
						transaction.rollback();
						session.close();
						return "1@Ctr " + i + " já cadastrado para um vendedor.";
					} else {
						aux+= (aux == "")? i : "|" + i;
					}
				}
			}
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();			
		}
		return (aux == "")? "1@" : "0@" + aux;
	}
	
	private boolean addRecord(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		Long verificador;
		int count = -1;
		Query query;
		try {
			funcionario = (Funcionario) session.get(Funcionario.class, Long.valueOf(request.getParameter("idFuncionario")));
			Unidade unidade = (Unidade) session.get(Unidade.class, Long.valueOf(request.getParameter("unidadeId")));
			while (request.getParameter("rowCtr" + String.valueOf(++count)) != null) {
				verificador = Long.valueOf(request.getParameter("rowCtr" + String.valueOf(count)).trim());
				query = session.createQuery("from Contrato as c " +
						" where c.ctr = :ctr" +
						" and c.unidade = :unidade");
				query.setLong("ctr", verificador);
				query.setEntity("unidade", unidade);
				if (query.list().size() > 0) {
					transaction.rollback();
					session.close();
					return false;
				} else {
					contrato = new Contrato();
					contrato.setCtr(verificador);
					contrato.setFuncionario(funcionario);
					contrato.setRequisicao(Util.parseDate(request.getParameter("requisicaoIn")));
					contrato.setStatus("a");
					contrato.setUnidade(unidade);
					session.save(contrato);
				}
			}
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
	
	private boolean generateFatura(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		int ctrs;
		int mes = Util.getMonthDate(request.getParameter("cadastro"));
		int ano = Util.getYearDate(request.getParameter("cadastro"));
		Date cadastro = Util.parseDate(request.getParameter("cadastro"));
		try {
			fatura = new FaturaVendedor();
			fatura.setCadastro(cadastro);
			fatura.setFim(Util.parseDate("25/" + mes + "/" + ano));			
			if (mes == 1) {
				fatura.setInicio(Util.parseDate("26/12/" + (ano - 1)));
			} else {
				fatura.setInicio(Util.parseDate("26/" + (mes - 1) + "/" + ano));
			}
			session.save(fatura);
			
			pipe = Util.unmountPipeline(request.getParameter("contratos"));
			ctrs = pipe.size();
			
			for (Long pp : pipe) {
				contrato = (Contrato) session.get(Contrato.class, pp);
				conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("10"));
				
				query = session.getNamedQuery("adesaoByCtr");
				query.setLong("codigo", contrato.getCodigo());
				adesao = (Lancamento) query.uniqueResult();
				
				
				lancamento = new Lancamento();
				lancamento.setConta(conta);
				//lancamento.setDescricao(conta.getDescricao());
				lancamento.setDocumento("fatura: " + fatura.getCodigo() + 
						" rh: " + contrato.getFuncionario().getCodigo());
				lancamento.setEmissao(cadastro);
				lancamento.setJuros(0);
				lancamento.setMulta(0);
				lancamento.setStatus("a");
				lancamento.setTaxa(0);
				lancamento.setTipo("d");
				lancamento.setUnidade(contrato.getFuncionario().getUnidade());
				if (ctrs >= contrato.getFuncionario().getMeta()) {
					lancamento.setValor(adesao.getValor() * (contrato.getFuncionario().getBonus() / 100));
				} else {
					lancamento.setValor(adesao.getValor() * (contrato.getFuncionario().getComissao() / 100));
				}
				lancamento.setVencimento(Util.parseDate("25/" + mes + "/" + ano));				
				session.save(lancamento);
				
				contrato.setLancamento(lancamento);
				session.update(contrato);
				
				id = new ItensVendedorId();
				id.setContrato(contrato);
				id.setFaturaVendedor(fatura);
				
				itensVendedor = new ItensVendedor();
				itensVendedor.setId(id);
				session.save(itensVendedor);
			}
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
	
	private boolean deleteFatura(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			pipe = Util.unmountPipeline(request.getParameter("contratos"));
			for (Long pp : pipe) {
				contrato = (Contrato) session.get(Contrato.class, pp);
				session.delete(contrato);
			}
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
	
	private void printContrato(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			ArrayList<Long> contratoId = Util.unmountPipeline(request.getParameter("contratos"));
			for (Long id : contratoId) {
				contrato = (Contrato) session.load(Contrato.class, id);
				if (contrato.getStatus().equals("a")) {
					contrato.setStatus("f");
					session.update(contrato);					
				}
			}
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
		} finally {
			session.close();
		}
	}
}