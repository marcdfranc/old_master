package com.marcsoftware.database;

import java.sql.DriverManager;
import java.sql.SQLException;

public class FabricaDeConexao {
	
	public static java.sql.Connection getConnection () throws SQLException {
		try {			
			/*String conectionString = "jdbc:postgresql://localhost:5433/master.com";
			String username = "postgres";
			String passWord = "postgres";*/
			
			String conectionString = "jdbc:postgresql://gruponewmed.com.br:5432/gruponewmed";
			String username = "gruponew_emp";
			String passWord = "m1st2r";
			
			Class.forName("org.postgresql.Driver");
			return DriverManager.getConnection(conectionString, username, passWord);
		} catch (ClassNotFoundException e) {
			throw new SQLException(e.getMessage());
		}
	}

}
