package com.marcsoftware.gateway;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Mensalidade;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

public class Renovacao extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet{
	private List<Usuario> usuarioList;
	private List<String> pipeList;
	private ArrayList<Long> userToRenove;
	private Usuario usuario;
	private Mensalidade mensalidade;
	private Lancamento lancamento;
	private Session session;
	private Transaction transaction;
	private Query query;
	private String pipe, dtInicio, dtFim, sql;
	private int dia, mes, ano;
	private PrintWriter out;
	private Date now;

	public Renovacao() {
		super();
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		boolean isOk = true;
		response.setContentType("text/plain");
		response.setCharacterEncoding("ISO-8859-1");
		out= response.getWriter();
		switch (Integer.parseInt(request.getParameter("from").trim())) {
		case 0:
			isOk = getContrato(request);				
			break;

		case 1:
			isOk = getFinishRecord(request);	
			break;
			
		case 2:
			isOk = makeRenovacao(request);
			break;
			
		case 3:
			isOk = makeOneRenovacao(request);
			break;
		}
		if (isOk && (!request.getParameter("from").trim().equals("3"))) {
			out.print(pipe);			
		} else if (isOk){
			out.print("1");
		} else {
			out.print("0");
		}
		out.close();
	}
	
	private boolean getContrato(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			now = new Date();
			if (request.getParameter("database").trim().equals("")) {
				query = session.createQuery("from Usuario as u where u.renovacao < :dtRenovacao");
				query.setDate("dtRenovacao", now);
			} else {				
				dtInicio = Util.getPart(request.getParameter("database"), 1) + Util.getYearDate(now);
				if (Util.getMonthDate(dtInicio) == 12) {
					dtFim = dtFim = Util.getPart(request.getParameter("database"), 2) + (Util.getYearDate(now) + 1);
				} else {
					dtFim = Util.getPart(request.getParameter("database"), 2) + Util.getYearDate(now);					
				}
				query = session.createQuery("from Usuario as u where u.renovacao between :dtInicio and :dtFim");
				query.setDate("dtInicio", Util.parseDate(dtInicio));
				query.setDate("dtFim", Util.parseDate(dtFim));
			}
			usuarioList = (List<Usuario>) query.list();
			pipe = "";
			for (Usuario user : usuarioList) {
				if (pipe == "") {
					pipe+= user.getCodigo() + "@" + user.getReferencia() + "  " + user.getNome();					
				} else {
					pipe+= "|" + user.getCodigo() + "@" + user.getReferencia() + "  " + user.getNome();
				}
			}
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
	
	private boolean getFinishRecord(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction= session.beginTransaction();
		boolean isFirst = true;
		try {
			userToRenove = Util.unmountPipeline(request.getParameter("users"));
			pipe= "";
			sql = "from Usuario as u where u.codigo in (";
			for (Long us : userToRenove) {				
				if (isFirst) {
					sql+= us;
					isFirst = false;
				} else {
					sql+= ", " + us;
				}
			}
			sql+= ")";
			isFirst = true;
			query = session.createQuery(sql);
			usuarioList = (List<Usuario>) query.list();
			for (Usuario user : usuarioList) {				
				if (isFirst) {
					pipe+= user.getReferencia() + "  " + user.getNome() + "@" + 
						Util.parseDate(user.getRenovacao(), "dd/MM/yyyy") + "@" +
						Util.zeroToLeft(user.getVencimento(), 2) + "@" +
						Util.zeroToLeft(String.valueOf(user.getQtdeParcela()), 2) + "@" + "10.00";
					isFirst = false;
				} else {
					pipe+= "|" + user.getReferencia() + "  " + user.getNome() + "@" + 
					Util.parseDate(user.getRenovacao(), "dd/MM/yyyy") + "@" +
					Util.zeroToLeft(user.getVencimento(), 2) + "@" +
					Util.zeroToLeft(String.valueOf(user.getQtdeParcela()), 2) + "@" + "10.00";
				}
			}
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
	
	private boolean makeRenovacao(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			pipeList = Util.unmountRealPipe(request.getParameter("pipe"));
			TipoConta conta = (TipoConta) session.get(TipoConta.class, Long.valueOf("64"));
			for (String pp : pipeList) {
				query = session.createQuery("from Usuario as u where u.codigo = :codigo");
				query.setLong("codigo", Long.valueOf(Util.getPipeById(pp, 0)));
				usuario = (Usuario) query.uniqueResult();
				usuario.setAtivo("a");
				usuario.setRenovacao(Util.addMonths(Util.getPipeById(pp, 1), 
						Integer.parseInt(Util.getPipeById(pp, 3))));
				usuario.setVencimento(Util.getPipeById(pp, 2));
				usuario.setQtdeParcela(Integer.parseInt(Util.getPipeById(pp, 3)));
				session.update(usuario);
				
				dia = Integer.parseInt(Util.getPipeById(pp, 2));
				mes = Util.getMonthDate(Util.getPipeById(pp, 1));
				ano = Util.getYearDate(Util.getPipeById(pp, 1));
				for (int i = 0; i < Integer.parseInt(Util.getPipeById(pp, 3)); i++) {
					lancamento = new Lancamento();
					//lancamento.setDescricao("mensalidade");
					lancamento.setEmissao(Util.parseDate(Util.getPipeById(pp, 1)));
					lancamento.setStatus("a");
					lancamento.setTaxa(1);
					lancamento.setTipo("c");
					lancamento.setUnidade(usuario.getUnidade());
					lancamento.setConta(conta);
					lancamento.setValor((i == 1 && !request.getParameter("vlrRenovacao").trim().equals(""))?
							Double.parseDouble(request.getParameter("vlrRenovacao")) 
							: Double.parseDouble(Util.getPipeById(pp, 4)));
					if (i == 0) {
						lancamento.setVencimento(Util.parseDate(Util.getPipeById(pp, 1)));
					} else {
						lancamento.setVencimento(Util.parseDate(dia + "/" + mes + "/" + ano));
					}
					session.save(lancamento);
					
					mensalidade = new Mensalidade();
					mensalidade.setLancamento(lancamento);
					mensalidade.setUsuario(usuario);
					mensalidade.setVigencia(Long.valueOf(request.getParameter("vigencia")) + 1);
					session.save(mensalidade);
					
					if (mes == 12) {
						mes = 1;
						ano++;
					} else {
						mes++;
					}
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
	
	private boolean makeOneRenovacao(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		try {
			TipoConta renovacao = (TipoConta) session.get(TipoConta.class, Long.valueOf("64"));
			TipoConta mensal = (TipoConta) session.get(TipoConta.class, Long.valueOf("61"));
			query = session.createQuery("from Usuario as u where u.codigo = :codigo");
			query.setLong("codigo", Long.valueOf(request.getParameter("userId")));
			usuario = (Usuario) query.uniqueResult();
			usuario.setAtivo("a");
			usuario.setRenovacao(Util.addMonths(Util.parseDate(request.getParameter("renovacao")), 
					Integer.parseInt(request.getParameter("vigencia"))));
			usuario.setVencimento(request.getParameter("vencimento"));
			usuario.setQtdeParcela(Integer.parseInt(request.getParameter("qtde")));
			session.update(usuario);
			
			dia = Integer.parseInt(request.getParameter("vencimento"));
			mes = Util.getMonthDate(request.getParameter("renovacao"));
			ano = Util.getYearDate(request.getParameter("renovacao"));
			for (int i = 0; i < Integer.parseInt(request.getParameter("qtde")) + 1; i++) {
				lancamento = new Lancamento();
				lancamento.setEmissao(Util.parseDate(request.getParameter("renovacao")));
				lancamento.setStatus("a");
				lancamento.setTaxa(1);
				lancamento.setTipo("c");
				lancamento.setUnidade(usuario.getUnidade());
				lancamento.setValor((i == 1 && !request.getParameter("vlrRenovacao").trim().equals(""))?
						Double.parseDouble(request.getParameter("vlrRenovacao")) 
						: Double.parseDouble(request.getParameter("valor")));				
				if (i == 0) {
					//lancamento.setDescricao("renovação");
					lancamento.setVencimento(Util.parseDate(request.getParameter("renovacao")));
					lancamento.setConta(renovacao);
				} else {
					//lancamento.setDescricao("mensalidade");
					lancamento.setVencimento(Util.parseDate(dia + "/" + mes + "/" + ano));
					lancamento.setConta(mensal);
				}
				session.save(lancamento);
				
				mensalidade = new Mensalidade();
				mensalidade.setVigencia(Long.valueOf(request.getParameter("vigAtual")) + 1);
				mensalidade.setLancamento(lancamento);
				mensalidade.setUsuario(usuario);
				session.save(mensalidade);
				
				if (mes == 12) {
					mes = 1;
					ano++;
				} else {
					mes++;
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
	
}
