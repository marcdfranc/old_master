import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;


import com.marcsoftware.database.ItensVendedor;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class ConfiguraItenVendedor {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		List<ItensVendedor> itensVendedor;
		int counter = 0;
		double size = 0;
		try {
			query = session.createQuery("from ItensVendedor");
			itensVendedor = (List<ItensVendedor>) query.list();
			size = itensVendedor.size();
			for (ItensVendedor iten : itensVendedor) {
				iten.setNewCodigo(iten.getId().getContrato().getCodigo());
				session.update(iten);
				counter++;
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
