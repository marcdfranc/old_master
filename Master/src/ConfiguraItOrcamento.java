import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.ItensOrcamento;
import com.marcsoftware.database.Tabela;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class ConfiguraItOrcamento {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		double valor;
		int counter = 0;
		double size = 0;
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query = session.createQuery("from ItensOrcamento as i");
		Tabela tabela;
		try {
			List<ItensOrcamento> itenList = (List<ItensOrcamento>) query.list();
			size = itenList.size();
			for (ItensOrcamento iten : itenList) {
				query = session.createQuery("from Tabela as t where t.servico = :servico " +
						" and t.unidade = :unidade and t.aprovacao = 's'");
		//		query.setEntity("servico", iten.getServico());
			//	query.setEntity("unidade", iten.getUnidade());
				tabela = (Tabela) query.uniqueResult();
				
				iten.setTabela(tabela);
				
				session.update(iten);
				
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
			session.close();			
			System.out.println("deu pau!");
			System.exit(1);
		}
		System.out.println("Tudo Ok!");
		System.exit(0);
	}

}
