import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Mensalidade;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class MensalidadeConfig {
	
	public static void main(String[] args) {
		long lastCodigo;
		List<Usuario> usuario;
		List<Mensalidade> mensalidade;
		Session session = HibernateUtil.getSession();
		Query query;
		Transaction transaction = session.beginTransaction();
		int counter = 0;
		double size = 0;
		try {
			query = session.createQuery("from Usuario as u");
			usuario = (List<Usuario>) query.list();
			size = usuario.size();
			for (Usuario user : usuario) {
				query = session.createQuery("from Mensalidade as m where m.usuario = :usuario order by m.lancamento.codigo");
				query.setEntity("usuario", user);
				mensalidade = (List<Mensalidade>) query.list();				
				for (Mensalidade mens : mensalidade) {
					mens.getLancamento().setDocumento("ctr: " + user.getReferencia() + " mens: " + mens.getCodigo());
					session.update(mens.getLancamento());
				}
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
