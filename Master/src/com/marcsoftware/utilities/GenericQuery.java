package com.marcsoftware.utilities;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.Servlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.ConnectionFactory;
import com.marcsoftware.database.Parametro;

public class GenericQuery extends HttpServlet implements Servlet {
	static final long serialVersionUID = 1L;
	private Session session;
	private Transaction transaction;
	private Query query;
	private PreparedStatement statement;
	private ResultSet resultSet;
	private Connection connection;
	private PrintWriter out;	
	private List<Parametro> parametro;
	private String sql;
	private ArrayList<Long> pipe;
	
	public GenericQuery() {
		super();
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		response.setContentType("text/plain");
		response.setCharacterEncoding("ISO-8859-1");
		out = response.getWriter();
		out.print(loadResults(request));
		out.close();
	}
	
	private String loadResults(HttpServletRequest request) {
		String aux = "";
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();
		sql = "from  Parametro as p where p.codigo in(";
		try {
			pipe = Util.unmountPipeline(request.getParameter("parametro"));
			for (Long pp : pipe) {
				if (aux == "") {
					aux =  "?";
				} else {
					aux+= ", ?";
				}
			}
			sql+= aux + ")";
			query  = session.createQuery(sql);
			for (int i = 0; i < pipe.size(); i++) {
				query.setLong(i, pipe.get(i));
			}			
			parametro = (List<Parametro>) query.list();
			transaction.commit();
			session.close();
			aux = "";
			connection = ConnectionFactory.getConnection();				
			for (Parametro param : parametro) {
				statement = connection.prepareStatement(param.getDados());
				resultSet = statement.executeQuery();
				aux+= (aux == "")? "" : "|"; 
				while (resultSet.next()) {
					if (aux.trim().equals("") || aux.charAt(aux.length() - 1) =='|') {
						aux+= param.getCodigo()+ "@" + resultSet.getString(1) + "," + resultSet.getString(2);
					} else {
						aux+= ";" + resultSet.getString(1) + "," + resultSet.getString(2);
					}
				}
			}
			statement.close();				
			connection.close();
		} catch (SQLException e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			aux= "0";
		}
		return aux;
	}

}
