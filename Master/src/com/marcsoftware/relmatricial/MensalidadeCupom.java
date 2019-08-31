package com.marcsoftware.relmatricial;

import java.util.Date;

import org.hibernate.Query;
import org.hibernate.Session;

import com.marcsoftware.database.Endereco;
import com.marcsoftware.database.Fisica;
import com.marcsoftware.database.Mensalidade;
import com.marcsoftware.utilities.GeradorMatricial;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

public class MensalidadeCupom extends Cupom {	
	private Mensalidade mensalidade;
	private Endereco endereco;
	private String infoPrincipal, username;
	private Fisica fisica;
	private double total, vlrPago;
	
	public MensalidadeCupom() {
		super();
	}

	public void setVlrPago(double vlrPago) {
		this.vlrPago = vlrPago;
	}
	
	public void setUsername(String username) {
		this.username = username;
	}	
	
	public void mountRel() {
		Session session = HibernateUtil.getSession();
		Date now = new Date();		
		total = 0;
		try {
			Query query= session.createQuery("from Fisica as f where f.login.username = :login"); 
			query.setString("login", username);
			fisica = (Fisica) query.uniqueResult();
			
			boolean isAdm = ((fisica.getLogin().getPerfil().equals("a"))
					|| (fisica.getLogin().getPerfil().equals("f"))
					|| (fisica.getLogin().getPerfil().equals("d")));  
			
			matricial = new GeradorMatricial(cols);
			if (fisica.getLogin().getHeaderCupom() != null && fisica.getLogin().getHeaderCupom() != "") {
				matricial.addCenterExpression(fisica.getLogin().getHeaderCupom());
			}
			if (fisica.getLogin().getSubHeader() != null && fisica.getLogin().getSubHeader() != "") {
				matricial.addCenterExpression(fisica.getLogin().getSubHeader());
			}
			matricial.addLine();
			for (Long pp : pipe) {
				query = session.createQuery("from Mensalidade as m where m.lancamento.codigo = :lancamento");
				query.setLong("lancamento", pp);
				mensalidade = (Mensalidade) query.uniqueResult();
				
				if (endereco == null) {
					query = session.createQuery("from Endereco as e where e.pessoa = :pessoa");
					query.setEntity("pessoa", mensalidade.getLancamento().getUnidade());
					endereco = (Endereco) query.uniqueResult();
					matricial.addCenterExpression(Util.initCap(endereco.getRuaAv()) + ", " + endereco.getNumero());
					if ((endereco.getComplemento() != null)
							&& (!endereco.getComplemento().trim().equals(""))) {
						matricial.addCenterExpression(endereco.getComplemento() + " - " + Util.initCap(endereco.getBairro()));
					}
					matricial.addExpression(0, endereco.getCidade().toUpperCase() + "/" + endereco.getUf().toUpperCase());
					if (infoPrincipal == null) {
						query = session.createQuery("select i.descricao from Informacao as i where i.principal = 's' and i.pessoa = :unidade");
						query.setEntity("unidade", mensalidade.getLancamento().getUnidade());
						infoPrincipal = query.uniqueResult().toString();
						if (infoPrincipal != null
								&& !infoPrincipal.trim().equals("")) {
							matricial.addRightExpression(infoPrincipal);
						} else {
							infoPrincipal = " ";
						}
					}
					matricial.nextLine();
					matricial.addExpression(0, Util.parseDate(now, "dd/MM/yyyy"));
					matricial.addRightExpression(Util.getTime(now));					
					
					if (! isAdm) {
						query = session.createQuery("select c.codigo from Caixa as c where c.status = 'a' and c.login = :login");
						query.setEntity("login", fisica.getLogin());
					}
					
					matricial.addExpression(0, "Atendente: " + Util.initCap(Util.getFirstName(fisica.getNome())));
					
					if (isAdm) {
						matricial.addRightExpression("Caixa: ADM");
					} else {
						matricial.addRightExpression("Caixa: " + query.uniqueResult().toString());
					}
					matricial.addLine();
					matricial.addCenterExpression("Cupom Nao Fiscal");
					matricial.addLine();
					matricial.addExpression(0, "Mensalidades");
					matricial.addRightExpression(Util.zeroToLeft(mensalidade.getUsuario().getContrato().getCtr(), 4) + 
						"/" + mensalidade.getUsuario().getUnidade().getReferencia());
				}
				matricial.addExpression(0, Util.getMonthLiteral(mensalidade.getLancamento().getVencimento()));
				matricial.addExpression(18, String.valueOf(Util.getYearDate(mensalidade.getLancamento().getVencimento())));
				matricial.addRightExpression(Util.formatCurrency(mensalidade.getLancamento().getValorPago()));
				total+= mensalidade.getLancamento().getValorPago();
			}
			matricial.addLine();
			matricial.addExpression(0, "TOTAL:");
			matricial.addRightExpression(Util.formatCurrency(total));
			matricial.addExpression(0, "DINHEIRO:");
			matricial.addRightExpression(Util.formatCurrency(vlrPago));
			matricial.addExpression(0, "TROCO:");
			matricial.addRightExpression(Util.formatCurrency(vlrPago - total));
			matricial.addLine();
			if (fisica.getLogin().getFooterCupom() != null && !fisica.getLogin().getFooterCupom().isEmpty()) {
				matricial.addCenterExpression(fisica.getLogin().getFooterCupom());				
			}
			if (fisica.getLogin().getSubFooter() != null && !fisica.getLogin().getSubFooter().isEmpty()) {
				matricial.addCenterExpression(fisica.getLogin().getSubFooter());
			}
		} catch (Exception e) {
			e.printStackTrace();
			relatorio = "0";
		} finally {
			session.close();
		}
		relatorio = matricial.getRelatorio();
	}
}
