package com.marcsoftware.system;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.ConnectionFactory;
import com.marcsoftware.database.Servico;
import com.marcsoftware.database.Tabela;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.database.Vigencia;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

/**
 * Servlet implementation class CadastroTabelaVigente
 */
public class CadastroTabelaVigente extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Session session;
	private Transaction transaction;
	private Query query;
	private Tabela tabela;
	private PrintWriter out;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CadastroTabelaVigente() {
        super();        
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		switch (Integer.parseInt(request.getParameter("from"))) {
		case 0:
			response.setContentType("text/plain");
			response.setCharacterEncoding("ISO-8859-1");
			out = response.getWriter();
			out.print(createTabela(request));
			out.close();
			break;
			
		case 1:
			response.setContentType("text/plain");
			response.setCharacterEncoding("ISO-8859-1");
			out = response.getWriter();
			out.print(duplicacao(request));
			out.close();
			break;

		case 2:
			response.setContentType("text/plain");
			response.setCharacterEncoding("ISO-8859-1");
			out = response.getWriter();
			out.print(aprovar(request));
			out.close();
			break;
			
		case 3:
			response.setContentType("text/plain");
			response.setCharacterEncoding("ISO-8859-1");
			out = response.getWriter();
			out.print(getNewTable(request));
			out.close();
			break;
			
		case 4:
			response.setContentType("text/plain");
			response.setCharacterEncoding("ISO-8859-1");
			out = response.getWriter();
			out.print(editarVigencia(request));
			out.close();
			break;
		}
	}
	
	private String createTabela(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		Vigencia vigencia;
		try {
			query = session.createQuery("from Servico as s where s.ref = :referencia");			
			query.setDouble("referencia", 1.01);
			Servico servico = (Servico) query.uniqueResult();			
			Unidade unidade = (Unidade) session.get(Unidade.class, Long.valueOf(request.getParameter("unidadeId")));
			vigencia = new Vigencia();
			vigencia.setAprovacao("n");
			vigencia.setDescricao(request.getParameter("descricao"));
			vigencia.setUnidade(unidade);
			session.save(vigencia);
			
			tabela = new Tabela();
			//tabela.setAprovacao("n");
			//tabela.setVigencia(request.getParameter("descricao"));
			tabela.setOperacional(0);
			tabela.setServico(servico);
			tabela.setUnidade(unidade);
			tabela.setValorCliente(0);
			tabela.setVigencia(vigencia);
			session.save(tabela);
			
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "A tabela não pode ser criada devido a um erro interno!";
		}
		return "Tabela criada com sucesso!";
	}
	
	private String duplicacao(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		List<Tabela> tabelaList;
		Vigencia vigencia;
		try {
			Unidade unidade = (Unidade) session.load(Unidade.class, 
					Long.valueOf(request.getParameter("unidadeId")));
			vigencia = new Vigencia();
			vigencia.setAprovacao("n");
			vigencia.setDescricao(request.getParameter("descricao"));
			vigencia.setUnidade(unidade);
			session.save(vigencia);
			
			query = session.createQuery("from Tabela as t where t.vigencia.codigo = :vigencia");
			query.setLong("vigencia", Long.valueOf(request.getParameter("vigencia")));
			tabelaList = (List<Tabela>) query.list();
			for (Tabela tabelaEspelho : tabelaList) {
				tabela = new Tabela();
				//tabela.setAprovacao("n");
				//tabela.setVigencia(request.getParameter("descricao"));
				tabela.setOperacional(tabelaEspelho.getOperacional());
				tabela.setServico(tabelaEspelho.getServico());
				tabela.setUnidade(tabelaEspelho.getUnidade());
				tabela.setValorCliente(tabelaEspelho.getValorCliente());
				tabela.setVigencia(vigencia);
				session.save(tabela);
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			return "Ocorreu um erro durante a geração da tabela!";
		}
		
		return "Tabela gerada com sucesso!";
	}
	
	private String aprovar(HttpServletRequest request) {
		String sql = "";
		Connection connection;
		try {
			sql = "UPDATE vigencia SET aprovacao = 'n' WHERE cod_unidade = ? " +
					" and codigo NOT IN(";
			sql += request.getParameter("aprovadas") + ")";
			connection = ConnectionFactory.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);			
			statement.setLong(1, Long.valueOf(request.getParameter("unidadeId")));
			statement.execute();
			
			Statement st = connection.createStatement();
			sql = "UPDATE vigencia SET aprovacao = 's' WHERE codigo IN(";
			sql += request.getParameter("aprovadas") + ")";
			st.execute(sql);
			statement.close();
			st.close();
			connection.close();
		} catch (Exception e) {
			e.printStackTrace();						
			session.close();
			return "Não foi possível aprovar as tabelas devido a um erro interno!";
		}
		return "Tabela(s) aprovada(s) com sucesso!";
	}
	
	private String getNewTable(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		Query query;
		List<Vigencia> vigenciaList;
		String result = "0";
		boolean isFirst = true; 
		try {
			query = session.createQuery("from Vigencia as v " +
					" where v.unidade = :unidade and v.aprovacao not in('s')");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidadeId")));
			vigenciaList = (List<Vigencia>) query.list();
			for (Vigencia vigencia : vigenciaList) {
				result += "@" + vigencia.getCodigo() + "," + vigencia.getDescricao();
			}
			query = session.createQuery("from Vigencia as v " +
				" where v.unidade = :unidade and v.aprovacao ='s'");
			query.setLong("unidade", Long.valueOf(request.getParameter("unidadeId")));
			vigenciaList = (List<Vigencia>) query.list();
			result+= "|";
			for (Vigencia vigencia : vigenciaList) {
				if (isFirst) {
					result+= vigencia.getCodigo() + "," + vigencia.getDescricao();
					isFirst = false;
				} else {
					result+= "@" + vigencia.getCodigo() + "," + vigencia.getDescricao();
				}
			}
			session.close();			
		} catch (Exception e) {
			e.printStackTrace();
			session.close();
			return "1@Não foi possível recuperar as tabelas devido a um erro interno!";
		}
		return result;
	}
	
	private String editarVigencia(HttpServletRequest request) {
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		String result = "Tabela editada com sucesso!";
		try {
			Vigencia vigencia = (Vigencia) session.load(Vigencia.class, Long.valueOf(request.getParameter("vigenciaId")));
			vigencia.setDescricao(Util.encodeString(request.getParameter("descricao"), "ISO-8859-1","UTF8"));
			session.update(vigencia);
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			transaction.rollback();
			result = "Ocorreu um erro durante a edição da tabela!";
		} finally {
			session.close();
		}
		return result;
	}
}
