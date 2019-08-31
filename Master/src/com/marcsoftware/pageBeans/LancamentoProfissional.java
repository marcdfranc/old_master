package com.marcsoftware.pageBeans;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.hibernate.Query;
import org.hibernate.Session;

import com.marcsoftware.database.EmpresaSaude;
import com.marcsoftware.database.ParcelaOrcamento;
import com.marcsoftware.database.Profissional;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.utilities.DataGrid;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;

public class LancamentoProfissional {	
	private List<Profissional> profissionalList;
	private List<EmpresaSaude> empresaList;
	private List<Unidade> unidadeList;
	private List<ParcelaOrcamento> parcelaList;
	private Session session;
	private Query query, queryList;
	private double totalProfissional, operacional, cliente;
	private boolean isProfissional;
	private int lines;
	private DataGrid dataGrid;
	
	
	public LancamentoProfissional(String perfil, String username, String tp, Long idAcesso, HttpServletRequest request) {
		try {			
			session = HibernateUtil.getSession();
			Util.historico(session, idAcesso, request);
			try {
				isProfissional = tp.equals("p");
				if (perfil.equals("a")) {
					queryList= session.createQuery("from Unidade as u where u.deleted =\'n\'");		
				} else if (perfil.equals("f")) {
					queryList= session.getNamedQuery("unidadeByUser");
					queryList.setString("username", username);
				} else {
					queryList = session.createQuery("select p.unidade from Pessoa as p where p.login = :username");
					queryList.setString("username", username);
				}
				unidadeList = (List<Unidade>) queryList.list();
				queryList= session.getNamedQuery("profissionalOf");
				queryList.setLong("codigo", (unidadeList.size() == 1)? unidadeList.get(0).getCodigo() : 0);
				profissionalList= (List<Profissional>) queryList.list();
				queryList = session.getNamedQuery("empresaSaudeOf");
				queryList.setLong("unidade", (unidadeList.size() == 1)? unidadeList.get(0).getCodigo() : 0);
				empresaList = (List<EmpresaSaude>) queryList.list();
				
				if (unidadeList.size() == 1) {
					queryList = session.createQuery("from ParcelaOrcamento as p " + 
							"where p.id.lancamento.status = 'f' " +
							"and p.id.lancamento.tipo = 'c' "+
							"and p.id.lancamento.unidade.codigo = :unidade order by " +
							"p.id.lancamento.dataQuitacao");
					queryList.setLong("unidade", unidadeList.get(0).getCodigo());
				} else if (perfil.equals("f") || perfil.equals("a")	|| perfil.equals("d")){
					String sql = "from ParcelaOrcamento as p " + 
						"where p.id.lancamento.status = 'f' " +
						"and p.id.lancamento.tipo = 'c' "+
						"and p.id.lancamento.unidade.codigo = -1";							
					queryList = session.createQuery(sql + ") order by p.id.lancamento.dataQuitacao");
				} else {
					queryList = session.createQuery("from ParcelaOrcamento as p where (1<>1)");
				}
				parcelaList = (List<ParcelaOrcamento>) queryList.list();
				lines = parcelaList.size();
				operacional= 0;
				cliente = 0;
				totalProfissional = 0;
				for (int i = 0; i < parcelaList.size(); i++) {
					query = session.getNamedQuery("operacionalOrcamento");
					query.setLong("orcamento", parcelaList.get(i).getId().getOrcamento().getCodigo());
					query.setLong("unidade", parcelaList.get(i).getId().getLancamento().getUnidade().getCodigo());
					operacional = Double.parseDouble(query.uniqueResult().toString());
					
					query = session.getNamedQuery("clienteOrcamento");
					query.setLong("orcamento", parcelaList.get(i).getId().getOrcamento().getCodigo());
					query.setLong("unidade", parcelaList.get(i).getId().getLancamento().getUnidade().getCodigo());
					cliente = Double.parseDouble(query.uniqueResult().toString());
					
					totalProfissional += Util.getOperacional(
							operacional, cliente, parcelaList.get(i).getId().getLancamento().getValor());
				}
				queryList.setFirstResult(0);
				queryList.setMaxResults(30);
				parcelaList= (List<ParcelaOrcamento>) queryList.list();
				dataGrid = new DataGrid("#");
				dataGrid.addColum("22", "CTR");
				dataGrid.addColum("41", "Cliente");
				dataGrid.addColum("5", "orç.");
				dataGrid.addColum("5", "Guia");
				dataGrid.addColum("5", "Emissão");
				dataGrid.addColum("5", "vencimento");
				dataGrid.addColum("5", "Prof.");
				dataGrid.addColum("10", "valor");
				dataGrid.addColum("2", "Ck");
				for(ParcelaOrcamento parcela: parcelaList) {
					dataGrid.setId(String.valueOf(parcela.getId().getLancamento().getCodigo()));
					if (parcela.getId().getOrcamento().getDependente() == null) {
						dataGrid.addData(parcela.getId().getOrcamento().getUsuario().getReferencia() +	"-0");
						dataGrid.addData(parcela.getId().getOrcamento().getUsuario().getNome());
					} else {
						dataGrid.addData(parcela.getId().getOrcamento().getUsuario().getReferencia() + 
							"-" + parcela.getId().getOrcamento().getDependente().getReferencia());
						dataGrid.addData(parcela.getId().getOrcamento().getDependente().getNome());
					}
					dataGrid.addData(String.valueOf(parcela.getId().getOrcamento().getCodigo()));
					dataGrid.addData(String.valueOf(parcela.getId().getLancamento().getCodigo()));
					dataGrid.addData((parcela.getId().getLancamento().getEmissao() == null) ? "" :
							Util.parseDate(parcela.getId().getLancamento().getEmissao() , "dd/MM/yyyy"));
					
					if (Util.getDayDate(parcela.getId().getLancamento().getDataQuitacao()) > 25) {
						if (Util.getMonthDate(parcela.getId().getLancamento().getDataQuitacao()) == 12) {
							dataGrid.addData("25/01/" + (Util.getYearDate(parcela.getId().getLancamento().getDataQuitacao()) + 1));
						} else {
							dataGrid.addData("25/" + (Util.getMonthDate(parcela.getId().getLancamento().getDataQuitacao()) + 1) +
									"/" + Util.getYearDate(parcela.getId().getLancamento().getDataQuitacao()));
						}
					} else {
						dataGrid.addData("25/" + Util.getMonthDate(parcela.getId().getLancamento().getDataQuitacao())+
								"/" + Util.getYearDate(parcela.getId().getLancamento().getDataQuitacao()));
					}
					dataGrid.addData(String.valueOf(parcela.getId().getOrcamento().getPessoa().getCodigo()));
					if (perfil.equals("a") || perfil.equals("d") || perfil.equals("f")) {
						dataGrid.addData(Util.formatCurrency(Util.getOperacional(
							operacional , 
							cliente, 
							parcela.getId().getLancamento().getValor())));
					} else {
						dataGrid.addData("--------");
					}
					dataGrid.addCheck();
					dataGrid.addRow();
				}
				if (perfil.equals("a") || perfil.equals("d") || perfil.equals("f")) {
					dataGrid.addTotalizador("Débito de Profissionais e Clínicas", 
							Util.formatCurrency(totalProfissional), false);
				} else {
					dataGrid.addTotalizador("Valor Total", "0.00", false);
				}
				dataGrid.makeTotalizador();
			} catch (Exception e) {
				e.printStackTrace();				
				session.close();
			} finally {
				if (session.isOpen()) {
					session.close();
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			session.close();			
		}
	}
	
	public boolean isProfissional() {
		return isProfissional;
	}	
	
	public List<Unidade> getUnidadeList() {
		return unidadeList;
	}
	
	public List<Profissional> getProfissionalList() {
		return profissionalList;
	}
	
	public List<EmpresaSaude> getEmpresaList() {
		return empresaList;
	}
	
	public int getLines() {
		return lines;
	}

	public DataGrid getDataGrid() {
		return dataGrid;
	}
	
	public String getPage() {
		return (isProfissional)? "profissional" : "empSaude";
	}
	
	
}
