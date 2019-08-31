import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Date;
import java.util.List;

import org.apache.commons.codec.binary.Base64;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Mensalidade;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class AdesaoConfig {
	
	public static void main(String[] args) {
		//String token = Util.parseDate(new Date(), "yyyy-MM-dd HH:mm:ss");
		String token = "webweb";
		String md5 = "";
		/*try {
			
			md5 = 
		} catch (NoSuchAlgorithmException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}*/
		token = Util.parseDate(new Date(), "yyyy-MM-dd HH:mm:ss");
		String encoded = new String(Base64.encodeBase64(token.getBytes()));
		System.out.println("Md5 - " + Util.MD5("webweb"));
		System.out.println("Normal - " + token);
		System.out.println("Encoded string - " + encoded);
		System.out.println("desencoded string - " + new String(Base64.decodeBase64(encoded.getBytes())));
		System.exit(0);
	}
	
	/*
	public static void main(String[] args) {
		 Session session = HibernateUtil.getSession();	
		Transaction transaction = session.beginTransaction();
		int counter = 0;
		double size = 0;
		List<Usuario> usuarioList;
		List<Mensalidade> mensalidade;
		Query query;
		try {
			query= session.createQuery("from Usuario as u");
			usuarioList = (List<Usuario>) query.list();
			size = usuarioList.size();
			for (Usuario usuario : usuarioList) {
				if (!usuario.getReferencia().equals("2000")) {					
					query = session.createQuery("from Mensalidade as m where m.usuario = :usuario " +
					" and m.vigencia in(0, 1) order by m.lancamento.vencimento, m.lancamento.dataQuitacao");
					query.setEntity("usuario", usuario);
					mensalidade = (List<Mensalidade>) query.list();					
					counter++;
					/*if (!mensalidade.get(0).getLancamento().getDescricao().equals("adesão")) {
						mensalidade.get(0).getLancamento().setDescricao("adesão");
						session.update(mensalidade.get(0).getLancamento());
						//System.out.print(usuario.getReferencia() + " - " + mensalidade.get(0).getLancamento().getDescricao() + " - ");
						//System.out.println(mensalidade.get(0).getVigencia() + " - " + mensalidade.get(0).getLancamento().getVencimento());
						System.out.println(String.valueOf(Util.trunc((counter / size) * 100)) + "%");					
					}* /
					if (mensalidade.get(0).getVigencia() == 0) {
						mensalidade.get(0).setVigencia(new Long(1));						
						session.update(mensalidade.get(0));
					}
				}
			}
			session.flush();
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			System.out.print("ERRO!");
			System.exit(-1);
		}
		System.out.println("100%");
		System.out.print("OK");
		System.exit(0);
	}
	 */

}
