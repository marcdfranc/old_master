package com.marcsoftware.database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConnectionFactory {
	/*
	 * public static java.sql.Connection getConnection () throws SQLException {
	 * try { String conexao = "jdbc:sqlserver://localhost:1332;" +
	 * "databaseName=tec2005;user=sa;password=misterio;";
	 * Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver"); return
	 * DriverManager.getConnection(conexao); } catch (ClassNotFoundException e)
	 * { throw new SQLException(e.getMessage()); } }
	 */

	public static java.sql.Connection getConnection() throws SQLException {
		try {
			/*
			 * String conectionString =
			 * "jdbc:postgresql://localhost:5433/master.com"; String username =
			 * "postgres"; String passWord = "postgres";
			 */
			
			// minas
			/*String conectionString = "jdbc:postgresql://gruponewmed.com.br:5432/gruponew_minas";
			String username = "gruponew_sos";*/
			
			// Araraquara
			String conectionString = "jdbc:postgresql://localhost:5432/postgres";
			String username = "postgres";
			String passWord = "postgres";

			Class.forName("org.postgresql.Driver");
			return DriverManager.getConnection(conectionString, username,
					passWord);
		} catch (ClassNotFoundException e) {
			throw new SQLException(e.getMessage());
		}
	}

}
