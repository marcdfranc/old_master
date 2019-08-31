import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.BoletoMensalidade;
import com.marcsoftware.database.Mensalidade;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class ConfiguraBoleto {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Mensalidade mensalidade;
		BoletoMensalidade boleto;		
		Query query;
		int counter = 0;
		double size = 0;
		try {
			query = session.createQuery("from Usuario as u where u.pagamento.codigo = 1");
			List<Usuario> usuarioList = (List<Usuario>) query.list();
			size = usuarioList.size();
			for (Usuario usuario : usuarioList) {
				query = session.createQuery("from Mensalidade as m " +
						" where m.usuario = :usuario " +
						" and m.lancamento.status in('a', 'e', 'n') " +
						" order by m.lancamento.vencimento");
				query.setEntity("usuario", usuario);				
				query.setMaxResults(1);
				mensalidade = (Mensalidade)query.uniqueResult();
				boleto = new BoletoMensalidade();
				if (query.list().size() == 0) {
					boleto.setData(usuario.getCadastro());					
				} else {
					boleto.setData(mensalidade.getLancamento().getVencimento());
				}
				boleto.setUsuario(usuario);				
				
				session.save(boleto);
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
			System.out.println("erro");
			System.exit(1);
		}		
		System.out.println("tudo OK");
		System.exit(0);
	}

}
