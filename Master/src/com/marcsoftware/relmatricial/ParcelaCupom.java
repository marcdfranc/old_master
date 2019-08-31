package com.marcsoftware.relmatricial;

import java.util.Date;

import org.hibernate.Query;
import org.hibernate.Session;


import com.marcsoftware.database.Endereco;
import com.marcsoftware.database.Fisica;
import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.utilities.GeradorMatricial;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

public class ParcelaCupom extends Cupom {
	private ParcelaOrcamento parcela;
	private Endereco endereco;
	private String infoPrincipal, username;
	private Fisica fisica;
	private double total, vlrPago;
	private int countParcela, quitadas, countLine;	
	
	public ParcelaCupom() {
		super();
	}
	
	public void setVlrPago(double vlrPago) {
		this.vlrPago = vlrPago;
	}
	
	public void setUsername(String username) {
		this.username = username;
	}
	
	@Override
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
			
			countParcela = countLine = 0;
			matricial = new GeradorMatricial(cols);
			if (fisica.getLogin().getHeaderCupom() != null && fisica.getLogin().getHeaderCupom() != "") {
				matricial.addCenterExpression(fisica.getLogin().getHeaderCupom());
			}
			if (fisica.getLogin().getSubHeader() != null && fisica.getLogin().getSubHeader() != "") {
				matricial.addCenterExpression(fisica.getLogin().getSubHeader());
			}
			matricial.addLine();
			for (Long pp : pipe) {
				query = session.createQuery("from ParcelaOrcamento as p where p.id.lancamento.codigo = :lancamento");
				query.setLong("lancamento", pp);
				parcela = (ParcelaOrcamento) query.uniqueResult();
				
				if (endereco == null) {
					query = session.createQuery("from Endereco as e where e.pessoa = :pessoa");
					query.setEntity("pessoa", parcela.getId().getLancamento().getUnidade());
					endereco = (Endereco) query.uniqueResult();
					matricial.addCenterExpression(Util.initCap(endereco.getRuaAv()) + ", " + endereco.getNumero());
					if ((endereco.getComplemento() != null)
							&& (!endereco.getComplemento().trim().equals(""))) {
						matricial.addCenterExpression(endereco.getComplemento() + " - " + Util.initCap(endereco.getBairro()));
					}
					matricial.addExpression(0, endereco.getCidade().toUpperCase() + "/" + endereco.getUf().toUpperCase());
					if (infoPrincipal == null) {
						query = session.createQuery("select i.descricao from Informacao as i where i.principal = 's' and i.pessoa = :unidade");
						query.setEntity("unidade", parcela.getId().getLancamento().getUnidade());
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
					
					if (! isAdm) {
						matricial.addRightExpression("Caixa: " + query.uniqueResult().toString());					
					} else {
						matricial.addRightExpression("Caixa: ADM");
					}					
					matricial.addLine();
					matricial.addCenterExpression("Cupom Nao Fiscal");
					matricial.addLine();
					matricial.addExpression(0, "Parcelamento");
					matricial.addRightExpression(Util.zeroToLeft(parcela.getId().getOrcamento().getUsuario().getContrato().getCtr(), 4) + 
						"/" + parcela.getId().getOrcamento().getUsuario().getUnidade().getReferencia());
					
					matricial.addExpression(0, "Orc.");
					matricial.addExpression(18, "Guia");
					matricial.addRightExpression("Valor");
					
					if (countParcela == 0) {
						query = session.getNamedQuery("countParcela");
						query.setEntity("orcamento", parcela.getId().getOrcamento());
						countParcela = Integer.parseInt(query.uniqueResult().toString());
						
						query = session.getNamedQuery("parcelaQuitada");
						query.setEntity("orcamento", parcela.getId().getOrcamento());
						quitadas = Integer.parseInt(query.uniqueResult().toString());
					}
				}
				matricial.addExpression(0, String.valueOf(parcela.getId().getOrcamento().getCodigo()));				
				matricial.addExpression(18, String.valueOf(parcela.getId().getLancamento().getCodigo()));
				matricial.addRightExpression(Util.formatCurrency(parcela.getId().getLancamento().getValorPago()));
				
				total+= parcela.getId().getLancamento().getValorPago();
				countLine++;
			}
			matricial.addLine();
			matricial.addExpression(0, "TOTAL:");
			matricial.addRightExpression(Util.formatCurrency(total));
			matricial.addExpression(0, "DINHEIRO:");
			matricial.addRightExpression(Util.formatCurrency(vlrPago));
			matricial.addExpression(0, "TROCO:");
			matricial.addRightExpression(Util.formatCurrency(vlrPago - total));
			matricial.addLine();
			matricial.addExpression(0, "PARCELAMENTO:");
			matricial.addRightExpression(countParcela + "x");
			matricial.addExpression(0, "QUITADAS:");
			matricial.addRightExpression(String.valueOf(quitadas));				
			matricial.addLine();
			if (fisica.getLogin().getFooterCupom() != null && !fisica.getLogin().getFooterCupom().isEmpty()) {
				matricial.addCenterExpression(fisica.getLogin().getFooterCupom());				
			}
			if (fisica.getLogin().getSubFooter() != null && !fisica.getLogin().getSubFooter().isEmpty()) {
				matricial.addCenterExpression(fisica.getLogin().getSubFooter());
			}		
		} catch (Exception e) {			
			e.printStackTrace();
		} finally {
			session.close();
		}
		relatorio = matricial.getRelatorio();
	}
}
