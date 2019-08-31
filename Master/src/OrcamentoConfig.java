import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Orcamento;
import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.utilities.HibernateUtil;


public class OrcamentoConfig {
	
	public static void main(String[] args) {
		List<ParcelaOrcamento> list;
		List<Orcamento> orcamento; 
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		int status = 0;
		String statusToPrint;
		int count = 0;
		double compare;
		int abertas = 0;
		int canceladas = 0;
		int negociadas = 0;
		int quitadas = 0;
		boolean isAberto = false;
		try {
			query = session.createQuery("from Orcamento");
			orcamento = (List<Orcamento>) query.list();
			compare = orcamento.size() / 10;			
			statusToPrint = "";
			for (Orcamento orc : orcamento) {
				System.out.println((status == 100)? 100: status + "%");				
				query = session.createQuery("from ParcelaOrcamento as p where p.id.orcamento = :orcamento and p.id.lancamento.tipo ='c'");
				query.setEntity("orcamento", orc);
				list= (List<ParcelaOrcamento>) query.list();
				for (ParcelaOrcamento parcela : list) {
					if (parcela.getId().getLancamento().getStatus().trim().equals("a")) {
						abertas++;
					} else if (parcela.getId().getLancamento().getStatus().trim().equals("n")){
						negociadas++;
					} else if (parcela.getId().getLancamento().getStatus().trim().equals("c")) {
						canceladas++;
					} else {
						quitadas++;
					}
				}
				
				if (negociadas > 0) {
					statusToPrint = "n";
				} else if (abertas > 0){
					statusToPrint = "a";
				} else if (list.size() == canceladas) {
					statusToPrint = "c";
				} else {
					statusToPrint = "q";					
				}				
				abertas = 0;
				canceladas = 0;
				negociadas = 0;
				quitadas = 0;
				
				orc.setStatus(statusToPrint);
				session.update(orc);
				
				if (++count >= compare) {
					status+= 10;
				}
			}
			session.flush();
			transaction.commit();			
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			System.exit(-1);
		}
		session.close();
		System.exit(0);
	}
}
