import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Contrato;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class ConfiguraContrato {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		List<Contrato> contratoList;
		int counter = 0;
		double size = 0;
		try {
			query = session.createQuery("from Contrato");
			contratoList = (List<Contrato>) query.list();
			size = contratoList.size();
			for (int i = 0; i < contratoList.size(); i++) {				
				contratoList.get(i).setCtr(Long.valueOf(String.valueOf(++counter)));
				session.update(contratoList.get(i)); 
				System.out.println(String.valueOf(Util.trunc((counter / size) * 100)) + "%");
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			System.out.println("miou!");
			System.exit(1);
		}
		System.out.println("deu certo!!");
		System.exit(0);
	}

}
