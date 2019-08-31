package com.marcsoftware.relmatricial;

import java.util.Date;
import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;

import com.marcsoftware.database.Empresa;
import com.marcsoftware.database.Endereco;
import com.marcsoftware.database.FaturaEmpresa;
import com.marcsoftware.database.Fisica;
import com.marcsoftware.database.LancamentoFaturaEmp;
import com.marcsoftware.utilities.GeradorMatricial;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

public class FaturaEmpresaCupom extends Cupom {
	private String username;
	private double dinheiro, total, valorAuxiliar;
	
	@Override
	public void mountRel() {
		Session session = HibernateUtil.getSession();
		try {
			Query query= session.createQuery("from Fisica as f where f.login.username = :login");
			query.setString("login", username);
			Fisica fisica = (Fisica) query.uniqueResult();
			
			boolean isAdm = ((fisica.getLogin().getPerfil().equals("a"))
					|| (fisica.getLogin().getPerfil().equals("f"))
					|| (fisica.getLogin().getPerfil().equals("d")));
			
			FaturaEmpresa fatura = (FaturaEmpresa) session.load(FaturaEmpresa.class, pipe.get(0));
			
			query = session.createQuery("from Endereco as e where e.pessoa.codigo = :empresa");
			query.setLong("empresa", fatura.getEmpresa().getUnidade().getCodigo());
			Endereco endereco = (Endereco) query.uniqueResult();
			
			Date now = new Date();
			String infoPrincipal = null;
			
						
			matricial = new GeradorMatricial(cols);
			
			if (fisica.getLogin().getHeaderCupom() != null && fisica.getLogin().getHeaderCupom() != "") {
				matricial.addCenterExpression(fisica.getLogin().getHeaderCupom());
			}
			if (fisica.getLogin().getSubHeader() != null && fisica.getLogin().getSubHeader() != "") {
				matricial.addCenterExpression(fisica.getLogin().getSubHeader());
			}
			matricial.addLine();
			matricial.addCenterExpression(Util.initCap(endereco.getRuaAv()) + ", " + endereco.getNumero());
			if ((endereco.getComplemento() != null)
					&& (!endereco.getComplemento().trim().equals(""))) {
				matricial.addCenterExpression(endereco.getComplemento() + " - " + Util.initCap(endereco.getBairro()));
			}
			matricial.addExpression(0, endereco.getCidade().toUpperCase() + "/" + endereco.getUf().toUpperCase());
			
			if (infoPrincipal == null) {
				query = session.createQuery("select i.descricao from Informacao as i where i.principal = 's' and i.pessoa.codigo = :unidade");
				query.setLong("unidade", fatura.getEmpresa().getUnidade().getCodigo());
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
			matricial.addExpression(0, "EMPRESA: " + 
					fatura.getEmpresa().getCodigo() + "/" + 
					fatura.getEmpresa().getUnidade().getReferencia());
			matricial.addRow();
			matricial.addExpression(0,
					Util.initCap(fatura.getEmpresa().getFantasia()));
			matricial.nextLine();
			matricial.addExpression(0, "Fatura");
			matricial.addExpression(18, "Mes");
			matricial.addRightExpression("Valor");
			List<LancamentoFaturaEmp> faturaList;
			total = 0;
			for (Long fat : pipe) {
				fatura = (FaturaEmpresa) session.load(FaturaEmpresa.class, fat);				
				
				query = session.createQuery(
						"from LancamentoFaturaEmp as l where l.id.faturaEmpresa = :fatura");
				query.setEntity("fatura", fatura);
				
				faturaList = (List<LancamentoFaturaEmp>) query.list();
				valorAuxiliar = 0;
				for (LancamentoFaturaEmp iten : faturaList) {
					valorAuxiliar+= iten.getId().getLancamento().getValor();
				}
				matricial.addExpression(0, String.valueOf(fatura.getCodigo()));				
				matricial.addExpression(18, Util.getMonthDate(fatura.getVencimento()) + "/" + 
						Util.getYearDate(fatura.getVencimento()));				
				matricial.addRightExpression(Util.formatCurrency(valorAuxiliar));				
				total+= valorAuxiliar;				
				
			}	
			
			matricial.addLine();
			matricial.addExpression(0, "TOTAL:");
			matricial.addRightExpression(Util.formatCurrency(total));
			matricial.addExpression(0, "DINHEIRO:");
			matricial.addRightExpression(Util.formatCurrency(dinheiro));
			matricial.addExpression(0, "TROCO:");
			matricial.addRightExpression(Util.formatCurrency(dinheiro - total));
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

	public void setUsername(String username) {
		this.username = username;
	}

	public void setDinheiro(double dinheiro) {
		this.dinheiro = dinheiro;
	}
}
