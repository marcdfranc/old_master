import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Mensalidade;
import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.utilities.HibernateUtil;


public class ConfiguracaoLancamento {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();		
		try {
			Query query = session.createQuery("from ParcelaOrcamento as o");
			List<ParcelaOrcamento> orcamento = (List<ParcelaOrcamento>) query.list();
			for (ParcelaOrcamento orc : orcamento) {
				orc.getId().getLancamento().setDocumento("orçamento: " + 
						orc.getId().getOrcamento().getCodigo());
				session.update(orc.getId().getLancamento());
			}
			query = session.createQuery("from Mensalidade as m");
			List<Mensalidade> mens = (List<Mensalidade>) query.list();
			for (Mensalidade mensalidade : mens) {
				mensalidade.getLancamento().setDocumento("mensalidade: " + 
						mensalidade.getCodigo());
				session.update(mensalidade.getLancamento());				
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			System.out.print("Erro !");
			System.exit(-1);
		}		
		System.out.println("ok!");
		System.exit(0);
	}

}
