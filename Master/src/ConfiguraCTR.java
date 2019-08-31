import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Contrato;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class ConfiguraCTR {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		double valor;
		int counter = 0;
		double size = 0;
		Query query;
		Contrato contrato;
		List<Usuario> usuarioList;
		try {
			query = session.createQuery("from Usuario as u where u.referencia <> '2000'");
			usuarioList = (List<Usuario>) query.list();
			size = usuarioList.size();
			System.out.println(size);
			for (Usuario usuario : usuarioList) {
				/*if (usuario.getReferencia().equals("0063")) {
					counter = counter;
				}*/
				//System.out.println(usuario.getReferencia());
				contrato = new Contrato();
				contrato.setCodigo(Long.valueOf(Util.removeZeroLeft(usuario.getReferencia())));				
				//contrato.setFuncionario(usuario.getFuncionario());
				contrato.setRequisicao(usuario.getCadastro());
				contrato.setStatus("a");
				session.save(contrato);
				
				usuario.setContrato(contrato);
				session.update(usuario);
				
				counter++;
				System.out.println(String.valueOf(Util.trunc((counter / size) * 100)) + "%");
			}			
			transaction.commit();
			session.close();
			System.out.print("OK");
			System.exit(0);			
		} catch (Exception e) {
			System.out.println("erro");
			e.printStackTrace();
			transaction.rollback();
			session.close();
			System.exit(1);
		}
	}
}
