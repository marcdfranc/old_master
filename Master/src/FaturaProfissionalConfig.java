import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.ItensBordero;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class FaturaProfissionalConfig {
	
	public static void main(String[] args) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		
		int counter = 0;
		double size = 0;
		try {
			query = session.createQuery("from ItensBordero as p");
			List<ItensBordero> itensList = (List<ItensBordero>) query.list();
			size = itensList.size();
			for (ItensBordero itens : itensList) {
				itens.getOperacional().setDocumento("fatura: " + 
						itens.getId().getBorderoProfissional().getCodigo() + " profiss: " +
						itens.getId().getBorderoProfissional().getPessoa().getCodigo());
				session.update(itens.getOperacional());
				
				counter++;				
				System.out.println(String.valueOf(Util.trunc((counter / size) * 100)) + "%");
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			System.out.print("erro");
			transaction.rollback();
			session.close();
			System.exit(1);
		}
		System.out.println("correu tudo bem.");
		System.exit(0);
	}

}
