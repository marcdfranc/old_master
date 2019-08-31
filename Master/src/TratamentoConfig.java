import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class TratamentoConfig {
	
	public static void main(String[] args) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query = session.createQuery("from ParcelaOrcamento as p");
		int counter = 0;
		double size = 0;
		try {
			List<ParcelaOrcamento> parcelList = query.list();
			size = parcelList.size();
			for (ParcelaOrcamento parcela : parcelList) {
				parcela.getId().getLancamento().setDocumento("orç.: " + 
						parcela.getId().getOrcamento().getCodigo() + " guia: " + 
						parcela.getId().getLancamento().getCodigo());
				if (parcela.getId().getLancamento().getEmissao() == null) {
					parcela.getId().getLancamento().setEmissao(parcela.getId().getLancamento().getVencimento());
				}
				session.update(parcela.getId().getLancamento());
				counter++;
				System.out.println(String.valueOf(Util.trunc((counter / size) * 100)) + "%");
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			System.out.println("Erro!!!");
			transaction.rollback();
			session.close();
			System.exit(-1);
		}
		System.out.println("ocorreu tudo bem.");
		System.exit(0);
	}

}
