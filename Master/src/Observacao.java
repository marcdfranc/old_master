import java.util.Date;
import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Mensalidade;
import com.marcsoftware.database.Orcamento;
import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class Observacao {
	
	public static void main(String[] args) {
		Date date = new Date();
		System.out.print(Util.removeYears(date, 2));
		System.exit(0);
		/*Session session= HibernateUtil.getSession();
		Transaction transaction= session.beginTransaction();
		try {
			Query query= session.createQuery("from Orcamento");
			List<Orcamento> orcamento = (List<Orcamento>) query.list();
			query = session.createQuery("from Usuario");			
			List<Usuario> usuario = (List<Usuario>) query.list();
			List<ParcelaOrcamento> parcela;
			List<Mensalidade> mensalidade;
			int total = (Integer) (usuario.size() + orcamento.size()) / 10;
			if (total == 0) {
				total= 1;
			}
			int counter= 0; 
			int percent= 0;
			String obs= "";
			for (Orcamento orc : orcamento) {
				System.out.println(percent + "%");
				query = session.createQuery("from ParcelaOrcamento as p where p.id.orcamento.codigo = :codigo");
				query.setLong("codigo", orc.getCodigo());
				parcela = (List<ParcelaOrcamento>) query.list();
				for (ParcelaOrcamento parc : parcela) {
					if (parc.getId().getLancamento().getObs() != null) {
						obs+= " " + parc.getId().getLancamento().getObs();						
					}
				}
				orc.setObservacao(obs);
				obs = "";
				session.update(orc);
				if (++counter >= total) {
					counter= 0;
					percent+= 10;
					System.out.println(percent + "%");
					session.flush();
					transaction.commit();
					session = HibernateUtil.getSession();
					transaction= session.beginTransaction();
				}
			}
			for (Usuario us : usuario) {
				query = session.createQuery("from Mensalidade as m where m.usuario.codigo = :codigo");
				query.setLong("codigo", us.getCodigo());
				mensalidade= (List<Mensalidade>) query.list();
				for (Mensalidade mens : mensalidade) {
					if (mens.getLancamento().getObs() != null) {
						obs += " " + mens.getLancamento().getObs();						
					}
				}
				us.setObservacao(obs);
				obs= "";
				session.update(us);
				if (++counter >= total) {
					counter = 0;
					percent+= 10;
					System.out.println(percent + "%");
					session.flush();
					transaction.commit();
					session = HibernateUtil.getSession();
					transaction= session.beginTransaction();
				}
			}
			session.flush();
			transaction.commit();
			percent = 100;
			System.out.println(percent + "%");
		} catch (Exception e) {
			e.printStackTrace();
			System.out.print("Falha");
			System.exit(-1);
		}
		System.exit(0);*/
	}

}
