import java.sql.Date;
import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Lancamento;
import com.marcsoftware.database.Mensalidade;
import com.marcsoftware.database.TipoConta;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class GeradorMensalidade {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Session session = HibernateUtil.getSession();
		Transaction transaction = session.beginTransaction();
		Lancamento lancamento;
		Mensalidade mensalidade;
		int mes = 0;
		int ano = 0;
		try {
			TipoConta adesao = (TipoConta) session.get(TipoConta.class, Long.valueOf("63"));
			TipoConta mensal = (TipoConta) session.get(TipoConta.class, Long.valueOf("61"));
			
			Query query = session.createQuery("from Usuario as u");
			List<Usuario> usuario = (List<Usuario>) query.list();
			for (Usuario user : usuario) {
				mes = Util.getMonthDate(user.getCadastro());
				ano = Util.getYearDate(user.getCadastro());				
				for (int i = 0; i < 18; i++) {					
					lancamento = new Lancamento();
					if (i == 0) {
						lancamento.setDataQuitacao(user.getCadastro());
						//lancamento.setDescricao("adesão");
						lancamento.setEmissao(user.getCadastro());
						lancamento.setRecebimento("juventino.leo");
						lancamento.setStatus("q");
						lancamento.setTaxa(1);
						lancamento.setTipo("c");
						lancamento.setUnidade(user.getUnidade());
						lancamento.setValor(10);
						lancamento.setValorPago(10);
						lancamento.setVencimento(user.getCadastro());
						lancamento.setConta(adesao);
					} else {						
						//lancamento.setDescricao("mensalidade");
						lancamento.setEmissao(user.getCadastro());						
						lancamento.setStatus("a");
						lancamento.setTaxa(1);
						lancamento.setTipo("c");
						lancamento.setUnidade(user.getUnidade());
						lancamento.setValor(10);						
						lancamento.setVencimento(Util.parseDate(user.getVencimento() +
								"/" + mes + "/" + ano));
						lancamento.setConta(mensal);
					}
					session.save(lancamento);
					
					mensalidade = new Mensalidade();
					mensalidade.setLancamento(lancamento);
					mensalidade.setUsuario(user);					
					session.save(mensalidade);
					
					if (mes == 12) {
						mes = 1;
						ano++;
					} else {
						mes++;
					}
				}
			}
			session.flush();
			transaction.commit();
			System.out.println("tuso ok!");
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			System.out.println("erro!");
		}
	}

}
