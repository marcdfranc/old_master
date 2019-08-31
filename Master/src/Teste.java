import java.util.Date;
import java.util.List;
import java.util.Locale;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Conta;
import com.marcsoftware.database.Servico;
import com.marcsoftware.utilities.CNABAdmin;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;




public class Teste {

	/**
	 * @param args
	 */
	public static void main(String[] args) {		
		/*Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		CNABAdmin admin = new CNABAdmin();		
		try {
			Conta conta = (Conta) session.get(Conta.class, Long.valueOf(8));
			admin.setConta(conta);
			admin.setDigitao(0, "0003020");
			admin.setFatorVencimento("02/10/2001");
			admin.setValor("35");
			admin.setDigitaoCodBarra();
			admin.setLinhaDigitavel();
			System.out.println(admin.getDigitao());
			System.out.println(admin.getLinhaDigitavel());
			transaction.commit();
			session.close();
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			session.close();
			System.exit(1);
		}*/	
		Date aux = Util.getLastDateOfMonth("10/02/2009");
		System.out.println(aux);
		System.exit(0);		
	}

}
