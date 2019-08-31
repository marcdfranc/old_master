import java.io.File;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.util.List;

import jbarcodebean.Code128;
import jbarcodebean.JBarcodeBean;

import org.apache.commons.codec.digest.DigestUtils;
import org.eclipse.birt.report.engine.api.script.IReportContext;
import org.eclipse.birt.report.engine.api.script.eventadapter.ImageEventAdapter;
import org.eclipse.birt.report.engine.api.script.instance.IImageInstance;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.database.Dependente;
import com.marcsoftware.database.Endereco;
import com.marcsoftware.database.Informacao;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


public class Teste2 {
	
	
	public static void main(String[] args) {
		String xml= "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
			"<Carteira xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" " +
			"xsi:noNamespaceSchemaLocation=\"carteirinha.xsd\">";
		List<Usuario> usuario;
		List<Dependente> dependente;		
		Session session;
		Transaction transaction;
		Query query;
		File file, folder;
		String cidade, informacao;		
		
		session = HibernateUtil.getSession();
		transaction = session.beginTransaction();	
		try {
			query = session.createQuery("from Usuario as u");
			usuario = query.list();			
			for (Usuario user : usuario) {
				query = session.createQuery("from Endereco as e where e.pessoa.codigo = :codigo");
				query.setLong("codigo", user.getUnidade().getCodigo());
				cidade = ((Endereco) query.list().get(0)).getCidade();
				
				query = session.createQuery("from Informacao as i where i.principal = 's' and i.pessoa.codigo = :codigo");
				query.setLong("codigo", user.getUnidade().getCodigo());
				if (query.list().size() > 0) {
					informacao = ((Informacao) query.list().get(0)).getDescricao();					
				} else {
					informacao = "";
				}			  			
				xml += "<carteirinha><codigo>" + user.getCodigo() + "</codigo>";
				xml += "<dependente_ref>0</dependente_ref>";
				xml += "<nome>" + Util.encodeString(user.getNome(), "ISO-8859-1", "UTF8") + "</nome>";
				xml += "<ctr>" + user.getReferencia() + "</ctr>";
				xml += "<plano>" + Util.encodeString(user.getPlano().getDescricao(), "ISO-8859-1", "UTF8") + "</plano>";
				xml += "<unidade>" + user.getUnidade().getReferencia() + "</unidade>";
				xml += "<cidade>" + Util.encodeString(cidade , "ISO-8859-1", "UTF8") + "</cidade>";
				xml += "<telefone>" + informacao + "</telefone></carteirinha>";
				
				query = session.createQuery("from Dependente as d where d.usuario.codigo = :codigo");
				query.setLong("codigo", user.getCodigo());
				dependente = (List<Dependente>) query.list();
				if (dependente.size() > 0) {
					for (Dependente dep : dependente) {
						xml += "<carteirinha><codigo>" + user.getCodigo() + "</codigo>";
						xml += "<dependente_ref>" + dep.getReferencia() + "</dependente_ref>";
						xml += "<nome>" + Util.encodeString(dep.getNome(), "ISO-8859-1", "UTF8") + "</nome>";
						xml += "<ctr>" + user.getReferencia() + "</ctr>";
						xml += "<plano>" + Util.encodeString(user.getPlano().getDescricao(), "ISO-8859-1", "UTF8") + "</plano>";
						xml += "<unidade>" + user.getUnidade().getReferencia() + "</unidade>";
						xml += "<cidade>" + Util.encodeString(cidade, "ISO-8859-1", "UTF8") + "</cidade>";
						xml += "<telefone>" + informacao + "</telefone></carteirinha>";
					}
				}
			}
			xml += "<id_path>";
		    xml += "<path>" + Util.TEMP_BARCODE_PATH + "</path>";
		    xml += "<id_user>marcdfranc</id_user>";		
			xml += "</id_path></Carteira>";
			transaction.commit();
			session.close();
			folder = new File(Util.TEMP_BARCODE_PATH);
			file = new  File(folder, "carteirinha.xml");
			PrintWriter out = new PrintWriter(file);
			out.print(xml);
			out.close();
			System.out.print("sucesso");
		} catch (Exception e) {
			e.printStackTrace();
			transaction.rollback();
			System.out.print("Falha");
			System.exit(-1);
		}
		System.exit(0);
	}

}
