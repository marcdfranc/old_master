import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class SequencialParcelaAdjust {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		List<ParcelaOrcamento> parcelaList;
		int counter = 0;
		double size = 0;
		Long orcamento;
		int sequencial = 0;
		try {
			query = session.createQuery("from ParcelaOrcamento as p order by p.id.orcamento, p.id.lancamento");
			parcelaList = (List<ParcelaOrcamento>) query.list();
			size = parcelaList.size();
			orcamento = parcelaList.get(0).getId().getOrcamento().getCodigo();
			for (ParcelaOrcamento parcela : parcelaList) {
				if (orcamento.equals(parcela.getId().getOrcamento().getCodigo())) {
					//parcela.setSequencial(++sequencial);
				} else {
					sequencial = 0;
					orcamento = parcela.getId().getOrcamento().getCodigo();
					//parcela.setSequencial(++sequencial);
				}
				session.update(parcela);
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
			System.out.print("Erro");
			System.exit(1);
		}
		System.out.print("Sucesso");
		System.exit(0);
	}

}
