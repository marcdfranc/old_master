package com.marcsoftware.pageBeans;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.hibernate.Query;
import org.hibernate.Session;

import com.marcsoftware.database.Conciliacao;
import com.marcsoftware.database.FormaPagamento;
import com.marcsoftware.database.ItensConciliacao;
import com.marcsoftware.utilities.Util;

public class ConciliacaoBean {
	private Session session;
	private List<FormaPagamento> pagamento;
	private List<ItensConciliacao> itensList;
	private Conciliacao conciliacao;
	private Date today;
	private String perfil;
	private Long id;
	private double valTotal;
	private ArrayList<String> listHidden;
	
	public ConciliacaoBean() {
		
	}
	
	public void bind() {
		try {
			Query query = session.createQuery("from FormaPagamento as f");
			pagamento= (List<FormaPagamento>) query.list();
			query = session .createQuery("from ItensConciliacao as i where i.id.conciliacao.codigo = :conciliacao");
			query.setLong("conciliacao", id);
			itensList = (List<ItensConciliacao>) query.list();
			valTotal = 0;
			String windowsUpload= "";
			today = new Date();
			listHidden = new ArrayList<String>();
			for (ItensConciliacao iten : this.itensList) {
				windowsUpload = iten.getId().getLancamento().getCodigo() + "@" + iten.getDocDigital() + "@";
				if ((iten.getId().getConciliacao().getEmissao().after(Util.getZeroDate(today)) 
						|| perfil.equals("f") || perfil.equals("a"))) {
					windowsUpload+= "i";
				} else {
					windowsUpload+= "e";
				}
				listHidden.add(windowsUpload);
			}
			
			
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public void setSessionPage(Long id, HttpServletRequest request, Session session) {
		this.session = session;
		this.perfil = request.getSession().getAttribute("perfil").toString();
		Util.historico(session, id, request);
	}

	public Date getToday() {
		return today;
	}

	public void setToday(Date today) {
		this.today = today;
	}
	
	public List<FormaPagamento> getPagamento() {
		return pagamento;
	}

	public List<ItensConciliacao> getItensList() {
		return itensList;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public double getValTotal() {
		return valTotal;
	}

	public void setValTotal(double valTotal) {
		this.valTotal = valTotal;
	}

	public String getPerfil() {
		return perfil;
	}

	public void setPerfil(String perfil) {
		this.perfil = perfil;
	}

	public ArrayList<String> getListHidden() {
		return listHidden;
	}

	public void setListHidden(ArrayList<String> listHidden) {
		this.listHidden = listHidden;
	}
}

