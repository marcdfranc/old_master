import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class ConfiguraUsuario {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Query query;
		List<Usuario> usuarios;
		int counter = 0;
		double size = 0;
		try {
			query = session.createQuery("from Usuario");
			usuarios = (List<Usuario>) query.list();
			size = usuarios.size();
			for (Usuario user : usuarios) {
			//	user.setCod_contrato(user.getContrato().getCodigo());
				session.update(user);
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
			System.out.println("miou!");
			System.exit(1);
		}
		System.out.println("deu certo!!");
		System.exit(0);
	}

}
