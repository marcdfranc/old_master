import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Orcamento;
import com.marcsoftware.utilities.HibernateUtil;


public class ParcelaConfig {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		List<Orcamento> orcList;
		int qtde = 0;
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();		
		try {
			Query query= session.createQuery("from Orcamento as o");
			orcList = (List<Orcamento>) query.list();
			for (Orcamento orcamento : orcList) {
				query = session.createQuery("select count(p.id.orcamento.codigo) " +
						"from ParcelaOrcamento as p " + 
						"where p.id.orcamento = :orcamento");
				query.setEntity("orcamento", orcamento);
				qtde = Integer.parseInt(query.uniqueResult().toString());				
				orcamento.setParcelas(qtde);
				session.update(orcamento);
			}
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			System.exit(-1);
		}
		System.out.print("tudo OK");
		System.exit(0);
	}

}
