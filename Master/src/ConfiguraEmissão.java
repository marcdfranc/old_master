import java.util.Date;
import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.utilities.HibernateUtil;


public class ConfiguraEmissão {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		List<ParcelaOrcamento> parcela;
		Date aux;
		Session session= HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		try {
			Query query = session.createQuery("from ParcelaOrcamento as p where p.id.lancamento.status = 'q'");
			parcela = (List<ParcelaOrcamento>) query.list();
			for (ParcelaOrcamento parc : parcela) {
				aux = parc.getId().getLancamento().getDataQuitacao();
				parc.getId().getLancamento().setEmissao(aux);
				session.update(parc.getId().getLancamento());
			}
			session.flush();
			transaction.commit();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			System.exit(-1);
		}
		session.close();
		System.out.print("tudo ok");
		System.exit(0);
	}

}
