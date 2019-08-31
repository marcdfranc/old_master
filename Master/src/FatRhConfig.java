import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.ItensVendedor;
import com.marcsoftware.database.Lancamento;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class FatRhConfig {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		int counter = 0;
		double size = 0;
		try {
			query = session.createQuery("from ItensVendedor as i");
			List<ItensVendedor> itensVendedor = (List<ItensVendedor>) query.list();
			size = itensVendedor.size();
			for (ItensVendedor iten : itensVendedor) {
	//			iten.getId().getContrato().getLancamento().setDocumento("fatura: " + 
		//				iten.getId().getFaturaVendedor().getCodigo() + " rh: " +
		//				iten.getId().getContrato().getFuncionario().getCodigo());
				
			//	session.update(iten.getId().getContrato().getLancamento());
				
				counter++;
				System.out.println(String.valueOf(Util.trunc((counter / size) * 100)) + "%");
			}
			session.flush();
			transaction.commit();
			//transaction.rollback();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			System.out.print("erro");
			session.close();
			System.exit(-1);
		}		
		System.out.println("ocorreu tudo bem.");
		System.exit(0);
		
	}

}
