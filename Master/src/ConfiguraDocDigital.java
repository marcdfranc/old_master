import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Unidade;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class ConfiguraDocDigital {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		int counter = 0;
		double size = 0;
		String novo;
		String last = novo = "";
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		try {
			Query query = session.createQuery("from Unidade");
			List<Unidade> unidades = (List<Unidade>) query.list();
			size = unidades.size();
			for (Unidade unidade : unidades) {
				//unidade.setDocDigita(unidade.getDocDigital());
				
				session.update(unidade);				
				counter++;
				novo = Util.trunc((counter / size) * 100) + "%";
				if (!novo.equals(last)) {
					System.out.println(novo);
					last = novo;
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
