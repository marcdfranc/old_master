import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Cep2005;
import com.marcsoftware.database.ConnectionFactory;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class Executor2 {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		long verifique = 6334;
		long counter = 0;
		int percent = 0;
		Session session = HibernateUtil. getSession();
		Transaction transaction = session.beginTransaction();
		Cep2005 cep;
		try {
			System.out.println(percent + "%");
			Connection connection = ConnectionFactory.getConnection();
			String sql = " select log_logradouro.cep,log_logradouro.log_tipo_logradouro, " + 
				"	log_logradouro.log_no, log_logradouro.ufe_sg, log_bairro.bai_no, " +
				"	log_localidade.loc_no " +
				" from log_logradouro " +
				" 	inner join log_bairro on " +
				"		(log_logradouro.bai_nu_sequencial_ini = log_bairro.bai_nu_sequencial) " +
				"	inner join log_localidade on " +
				"		(log_logradouro.loc_nu_sequencial = log_localidade.loc_nu_sequencial)";
			
			PreparedStatement statement = connection.prepareStatement(sql);			
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				cep = new Cep2005();
				cep.setCep(Integer.parseInt(resultSet.getString("cep")));
				if (resultSet.getString("log_no").length() > 6) {
					if (resultSet.getString("log_no").trim().toLowerCase().substring(0, 6).equals("quadra")) {
						cep.setRuaAv(resultSet.getString("log_no").toLowerCase());					
					} else {
						cep.setRuaAv(resultSet.getString("log_tipo_logradouro").toLowerCase() + " " + 
								resultSet.getString("log_no").toLowerCase());
					}
				} else {
					cep.setRuaAv(resultSet.getString("log_tipo_logradouro").toLowerCase() + " " + 
							resultSet.getString("log_no").toLowerCase());
				}				
				cep.setBairro(resultSet.getString("bai_no").toLowerCase());
				cep.setCidade(resultSet.getString("loc_no").toLowerCase());
				cep.setUf(resultSet.getString("ufe_sg"));
				session.save(cep);
				if (counter++ == verifique) {
					verifique+= 6334;
					session.flush();
					transaction.commit();
					session.close();
					session = HibernateUtil.getSession();
					transaction = session.beginTransaction();
					System.out.println(++percent + "%");
				}
			}
			statement.close();			
			connection.close();
			session.flush();
			transaction.commit();
			session.close();
			System.out.println("100%");
		} catch (SQLException e) {			
			e.printStackTrace();
			transaction.rollback();
			session.close();
			System.out.println("falha de conexão!!!");
			System.exit(-1);
		}
		System.exit(0);
	}
}
