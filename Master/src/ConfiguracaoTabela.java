import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Tabela;
import com.marcsoftware.utilities.HibernateUtil;


public class ConfiguracaoTabela {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query = session.createQuery("from Tabela");		
		try {
			List<Tabela> tabela = (List<Tabela>) query.list();
			for (int i = 0; i < tabela.size(); i++) {
				//System.out.println(tabela.get(i).getUnidade().getDescricao());
				tabela.get(i).setCodigo(new Long(i + 1));
				session.update(tabela.get(i));
			}
			session.flush();
			transaction.commit();
			//transaction.rollback();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			System.out.println("deu pau");
			System.exit(1);
		}
		System.out.println("rodou");
		System.exit(0);
	}

}
