import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Dependente;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class ConfiguraDependente {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		List<Dependente> dependenteList;
		int counter = 0;
		double size = 0;
		String novo;
		String last = novo = "";
		try {
			query = session.createQuery("from Dependente as d where d.parentesco not in('conjuge', 'pai', 'mãe', 'outro')");
			dependenteList = (List<Dependente>) query.list();
			size = dependenteList.size();
			for (Dependente dependente : dependenteList) {
				dependente.setParentesco(dependente.getParentesco() + "(a)");
				session.update(dependente);
				
				counter++;
				novo = Util.trunc((counter / size) * 100) + "%";
				if (!novo.equals(last)) {
					System.out.println(novo);
					last = novo;
				}
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			System.exit(1);
		}
		System.out.println("Configuração efetuada com sucesso!");
		System.exit(0);
	}

}
