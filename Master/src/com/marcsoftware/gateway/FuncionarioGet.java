package com.marcsoftware.gateway;

import java.io.IOException;

import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.hibernate.Query;
import org.hibernate.Session;
import com.marcsoftware.database.Cep2005;
import com.marcsoftware.database.Dependente;
import com.marcsoftware.database.Empresa;
import com.marcsoftware.database.EmpresaSaude;
import com.marcsoftware.database.Endereco;
import com.marcsoftware.database.Especialidade;
import com.marcsoftware.database.Fisica;
import com.marcsoftware.database.Funcionario;
import com.marcsoftware.database.PlanoServico;
import com.marcsoftware.database.Profissional;
import com.marcsoftware.database.Tabela;
import com.marcsoftware.database.Unidade;
import com.marcsoftware.database.Usuario;
import com.marcsoftware.database.Vigencia;
import com.marcsoftware.utilities.HibernateUtil;
import com.marcsoftware.utilities.Util;


/**
 * Servlet implementation class for Servlet: FuncionarioGet
 *
 */
 public class FuncionarioGet extends javax.servlet.http.HttpServlet implements javax.servlet.Servlet {
   static final long serialVersionUID = 1L;
   
	public FuncionarioGet() {
		super();
	}
	
	@SuppressWarnings("unchecked")
	protected void doGet(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {	
		PrintWriter out = null;
		Session session;
		String aux;
		Query query;
		List<Usuario> usuario;
		List<Tabela> tabela;
		switch (Integer.parseInt(request.getParameter("from"))) {
		case 0: //pega unidade mediante codigo
			response.setContentType("text/plain");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			session = HibernateUtil.getSession();
			try {
				Unidade unidade= (Unidade) session.load(Unidade.class, 
						Long.valueOf(request.getParameter("unidadeId")));			
				out.print(unidade.getDescricao());
			} catch (Exception e) {
				e.printStackTrace();
				out.print("0");
			} finally {
				session.close();
			}
			break;

		case 1: //pega a empresa mediante codigo
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			session = HibernateUtil.getSession();
			try {				
				Empresa empresa= (Empresa) session.load(Empresa.class, 
						Long.valueOf(request.getParameter("idEmpresa")));
				out.print(empresa.getFantasia());
			} catch (Exception e) {
				e.printStackTrace();
				out.print("0");
			} finally {
				session.close();
			}
			break;
			
		case 3: // pega o Funcionario mediante codigo
			response.setContentType("text/plain");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			session = HibernateUtil.getSession();
			try {
				Funcionario funcionario= (Funcionario) session.load(Funcionario.class, 
						Long.valueOf(request.getParameter("idFuncionario")));
				out.print(funcionario.getNome());				
			} catch (Exception e) {
				e.printStackTrace();
				out.print("0");
			} finally {
				session.close();
			}
			break;
			
		case 4: // pega a especialidade mediante setor
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			session = HibernateUtil.getSession();
			try {
				query = session.createQuery("from Especialidade as e where e.setor= :setor");
				query.setString("setor", request.getParameter("setorIn"));
				List<Especialidade> especialidade= (List<Especialidade>) query.list();
				aux= "<option value=\"\">Selecione</option>";
				for (Especialidade esp : especialidade) {
					aux+= "<option value=\"" + esp.getCodigo() + "\">" + esp.getDescricao() +
					"</option>";
				}
				out.print(aux);				
			} catch (Exception e) {
				e.printStackTrace();
				out.print("0");
			} finally {
				session.close();
			}
			break;
		
		case 5: //xml de fisica mediante codigo		
			response.setContentType("text/xml");
			response.setHeader("Cache-Control", "no-cache");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			session = HibernateUtil.getSession();
			try {			
				Fisica fisica= (Fisica) session.load(Fisica.class, 
						Long.valueOf(request.getParameter("codAdm")));
				query= session.getNamedQuery("enderecoOf").setEntity("pessoa", fisica);			
				Endereco endereco= (Endereco) query.uniqueResult();
				aux= "<adm>";
				aux+= "<codigo>" + fisica.getReferencia() + "</codigo>";
				aux+= "<nome>" + fisica.getNome() + "</nome>";
				aux+= "<sexo>" + fisica.getSexo() + "</sexo>";
				aux+= "<cpf>" + Util.mountCpf(fisica.getCpf()) + "</cpf>";
				aux+= "<rg>" + fisica.getRg() + "</rg>";
				aux+= "<nascimento>" + Util.parseDate(fisica.getNascimento(), "dd/MM/yyyy") + "</nascimento>";
				aux+= "<nacionalidade>" + fisica.getNacionalidade() + "</nacionalidade>";
				aux+= "<naturalidade>" + fisica.getNaturalidade() + "</naturalidade>";
				aux+= "<naturalidadeUf>" + fisica.getCodigo() + "</naturalidadeUf>";
				aux+= "<estadoCivil>" + fisica.getNome() + "</estadoCivil>";
				aux+= "<login>" + fisica.getLogin().getUsername() + "</login>";
				aux+= "<senha>" + fisica.getLogin().getSenha() + "</senha>";
				aux+= "<cep>" + Util.mountCep(endereco.getCep()) + "</cep>";
				aux+= "<rua>" + endereco.getRuaAv() + "</rua>";
				aux+= "<numero>" + endereco.getNumero() + "</numero>";
				aux+= "<complemento>" + endereco.getComplemento() + "</complemento>";
				aux+= "<bairro>" + endereco.getBairro() + "</bairro>";
				aux+= "<cidade>" + endereco.getCidade() + "</cidade>";
				aux+= "<uf>" + endereco.getUf() + "</uf></adm>";			
				out.write(aux);
				out.flush();
			} catch (Exception e) {
				e.printStackTrace();
				out.print("0");
			}  finally {
				session.close();
			}
			break;
			
		case 6: // verifica a validade do username
			response.setContentType("text/plain");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			session = HibernateUtil.getSession();
			try {
				query= session.createQuery("select count(l.username) from Login as l where l.username= :username");
				query.setString("username", request.getParameter("name"));
				if (((Long) query.uniqueResult()) == 0) {
					out.print("1");
				} else {
					out.print("0");
				}
			} catch (Exception e) {
				e.printStackTrace();
				out.print("0");
			} finally {
				session.close();
			}
			break;
		
		case 7: //pega o serviço mediante a especialidade
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			session = HibernateUtil.getSession();
			try {
				query = session.createQuery("from Servico as s where e.especialidade.codigo= :especialidadeIn");
				query.setString("especialidadeIn", request.getParameter("especialidadeIn"));
				List<Especialidade> especialidade= (List<Especialidade>) query.list();
				aux= "<option value=\"\">Selecione</option>";
				for (Especialidade esp : especialidade) {
					aux+= "<option value=\"" + esp.getCodigo() + "\">" + esp.getDescricao() +
					"</option>";
				}
				out.print(aux);
			} catch (Exception e) {
				e.printStackTrace();
				out.print("0");
			} finally {
				session.close();
			}
			break;
			
		case 8://pega o profissional e vigencias mediante a unidade e setor
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			boolean isFirst = true;
			session = HibernateUtil.getSession();
			try {
				Long unidadeId = Long.valueOf(request.getParameter("unidadeId"));
				query = session.createQuery("from Profissional as p where " +
						" p.unidade.codigo= :codigo " +
						" and p.especialidade.setor = :setor");
				query.setLong("codigo", unidadeId);
				query.setString("setor", request.getParameter("setor"));
				List<Profissional> profissional = (List<Profissional>) query.list();
				aux = "";
				for (Profissional prof : profissional) {
					if (isFirst) {
						isFirst = false;
						aux+= prof.getReferencia() + "@" + prof.getCodigo() + "@" +
						prof.getNome() + "@" + prof.getConselho();
					} else {
						aux+= ";" + prof.getReferencia() + "@" + prof.getCodigo() + "@" +
						prof.getNome() + "@" + prof.getConselho();
					}
				}
				isFirst = true;
				aux+= "|";
				query = session.createQuery("from Vigencia as v " +
						" where v.unidade.codigo = :unidade " +
						" and v.aprovacao = 's'");
				query.setLong("unidade", unidadeId);
				List<Vigencia> vegenciaList = (List<Vigencia>) query.list();
				for (Vigencia vigencia : vegenciaList) {
					if (isFirst) {
						aux+= vigencia.getCodigo() + "@" + vigencia.getDescricao();
						isFirst = false;
					} else {
						aux+= ";" + vigencia.getCodigo() + "@" + vigencia.getDescricao();
					}
				}				
				out.print(aux);
			} catch (Exception e) {
				e.printStackTrace();
				out.print("0");
			} finally {
				session.close();
			}
			break;
			
		case 9:// pega o usuário mediante sua unidade
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			session = HibernateUtil.getSession();
			try {
				query = session.createQuery("from Usuario as u where u.unidade.codigo= :codigo");
				query.setLong("codigo", Long.valueOf(request.getParameter("unidadeId")));
				usuario = (List<Usuario>) query.list();
				aux= "<option value=\"\">Selecione</option>";
				for (Usuario us : usuario) {
					aux+= "<option value=\"" + us.getCodigo() +  "@" +
					us.getNome() + "\">" + us.getReferencia() +
					"</option>";
				}
				out.print(aux);
			} catch (Exception e) {
				e.printStackTrace();
				out.print("0");
			} finally {
				session.close();
			}
			break;
			
		case 10: //pega a tabela pertinente a uma unidade
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			boolean isRef= (request.getParameter("isRef").equals("1"));
			session = HibernateUtil.getSession();
			try {
				query = session.getNamedQuery("tabelaOdontoByCode");
				query.setLong("codigo", Long.valueOf(request.getParameter("unidadeId")));
				tabela = (List<Tabela>) query.list();
				aux= "<option value=\"\">Selecione</option>";
				for (Tabela tab : tabela) {				
					aux+= "<option value=\"";
					if (isRef) {
						aux+= tab.getServico().getCodigo() + "@" + 
						tab.getServico().getReferencia() + "\">"; 
					} else {
						aux+= tab.getServico().getCodigo() + "@" +
						tab.getValorCliente() + "\">";
					}				
					aux+= (isRef)? tab.getServico().getReferencia():
						tab.getServico().getDescricao();				 
					aux+= "</option>";
				}
				out.print(aux);
			} catch (Exception e) {
				e.printStackTrace();
				out.print("0");
			} finally {
				session.close();
			}
			break;
			
		case 11: // pega o número do conselho e nome do profissional conforme seu código
			response.setContentType("text/xml");
			response.setHeader("Cache-Control", "no-cache");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			session = HibernateUtil.getSession();
			try {				
				Profissional oneProfissional= (Profissional) 
					session.load(Profissional.class, Long.valueOf(request.getParameter("codProf")));		
				aux= "<serv>";
				aux+= "<conselho>" + oneProfissional.getConselho() + "</conselho>";
				aux+= "<nome>" + oneProfissional.getNome() + "</nome></serv>";						
				out.write(aux);
				out.flush();
			} catch (Exception e) {
				e.printStackTrace();
				out.print("0");
			} finally {
				session.close();
			}
			break;
			
		case 12: //pega os dependentes pertinentes a um usuário
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			session = HibernateUtil.getSession();
			try {
				query = session.createQuery("from Usuario as u " +
						" where u.contrato.ctr = :referencia" +
				" and u.unidade = :unidade");
				query.setLong("referencia", Long.valueOf(Util.removeZeroLeft(request.getParameter("ctr"))));
				query.setLong("unidade", Long.valueOf(Util.getPart(request.getParameter("unidade"), 2)));
				usuario= (List<Usuario>) query.list();
				if (usuario.size() > 0) {
					aux = usuario.get(0).getCodigo() + "@" + usuario.get(0).getNome() + "@" + 
					usuario.get(0).getPlano();
					query = session.createQuery("from Dependente as d where d.usuario= :usuario order by d.referencia");
					query.setEntity("usuario", usuario.get(0));
					List<Dependente> dependente = (List<Dependente>) query.list();
					for (Dependente dep : dependente) {
						aux+= "|" + dep.getCodigo() + "@" + dep.getNome();
					}
				} else {
					aux = "";
				}
				out.print(aux);				
			} catch (Exception e) {
				e.printStackTrace();
				out.print("0");
			} finally {
				session.close();
			}
			break;
			
		case 13:
			response.setContentType("text/plain");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			session = HibernateUtil.getSession();
			try {
				String result = "";
				@SuppressWarnings("unused")
				int qtdeScore = 0;
				@SuppressWarnings("unused")
				PlanoServico planoServico = null;
				query = session.getNamedQuery("tabelaOrcamento");
				query.setString("referencia", request.getParameter("referencia"));
				query.setString("setor", request.getParameter("setor"));
				query.setLong("unidade", Long.valueOf(request.getParameter("unidade")));
				query.setLong("vigencia", Long.valueOf(request.getParameter("tabela")));
				if (query.list().size() > 0) {
					Tabela tabelaOne = (Tabela) query.list().get(0);
					
					result = tabelaOne.getServico().getCodigo() + "@" + 
						tabelaOne.getServico().getDescricao() + "@" +
						tabelaOne.getValorCliente() + "@" + 
						tabelaOne.getServico().getEspecialidade().getDescricao();
					out.print(result);
				}
			} catch (Exception e) {
				e.printStackTrace();
				out.print("0");
			} finally {
				session.close();
			}
			break;
			
		case 14:
			response.setContentType("text/xml");
			response.setHeader("Cache-Control", "no-cache");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			session = HibernateUtil.getSession();
			try {
				query= session.getNamedQuery("tabelaBySetorUnCode");
				query.setLong("unidade", Long.valueOf(request.getParameter("unidadeId")));
				query.setString("setor", request.getParameter("setor"));			
				tabela= (List<Tabela>) query.list();
				aux= "<ajax-response><tabela>";
				for (Tabela tab : tabela) {
					aux+= "<iten>";
					aux+= "<codigo>" + tab.getServico().getCodigo() + "</codigo>";
					aux+= "<referencia>" + tab.getServico().getReferencia() + "</referencia>";
					aux+= "<descricao>" + tab.getServico().getDescricao() + "</descricao>";
					aux+= "<vlr_cliente>" + tab.getValorCliente() + "</vlr_cliente>";
					aux+= "</iten>";
				}
				aux+= "</tabela></ajax-response>";
				out.write(aux);
				out.flush();
			} catch (Exception e) {
				e.printStackTrace();
				out.print("0");
			} finally {
				session.close();
			}
			break;
			
		case 15:
			response.setContentType("text/xml");
			response.setHeader("Cache-Control", "no-cache");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();
			session = HibernateUtil.getSession();
			try {
				query= session.createQuery("from Cep2005 as c where c.cep = :cep");
				query.setLong("cep", Long.valueOf(Util.unMountDocument(request.getParameter("cep"))));			
				if (query.list().size() > 0) {
					Cep2005 end = (Cep2005) query.list().get(0);
					aux= "<endereco>";
					aux+= "<rua>" + end.getRuaAv() + "</rua>";
					aux+= "<bairro>" + end.getBairro() + "</bairro>";
					aux+= "<cidade>" + end.getCidade() + "</cidade>";		
					aux+= "<uf>" + end.getUf().toLowerCase() + "</uf></endereco>";			
					out.write(aux);
					out.flush();
				} else {
					aux= "<endereco>";
					aux+= "<rua>0</rua>";
					aux+= "<bairro>0</bairro>";
					aux+= "<cidade>0</cidade>";		
					aux+= "<uf>0</uf></endereco>";			
					out.write(aux);
					out.flush();
				}
			} catch (Exception e) {
				e.printStackTrace();
				out.print("0");
			} finally {
				session.close();
			}
			break;
			
		case 16://pega a empresa de saúde e as vigencias mediante a unidade e o setor
			response.setContentType("text/html");
			response.setCharacterEncoding("ISO-8859-1");
			out= response.getWriter();			
			boolean isFirstEmp = true;
			session = HibernateUtil.getSession();
			try {
				Long unidadeId = Long.valueOf(request.getParameter("unidadeId"));
				query = session.createQuery("from EmpresaSaude as e " +
						" where e.unidade.codigo= :codigo " +
						" and e.especialidade.setor = :setor");
				query.setLong("codigo", unidadeId);
				query.setString("setor", request.getParameter("setor"));
				List<EmpresaSaude> empresaSaude = (List<EmpresaSaude>) query.list();
				aux = "";
				for (EmpresaSaude emp: empresaSaude) {
					if (isFirstEmp) {
						isFirst = false;
						aux+= emp.getCodigo() + "@" + emp.getFantasia() + 
						"@" + emp.getConselhoResponsavel();
					} else {
						aux+= ";" + emp.getCodigo() + "@" +	emp.getFantasia() + 
						"@" + emp.getConselhoResponsavel();
					}
				}
				isFirst = true;
				aux+= "|";
				query = session.createQuery("from Vigencia as v " +
						" where v.unidade.codigo = :unidade " +
						" and v.aprovacao = 's'");
				query.setLong("unidade", unidadeId);
				List<Vigencia> vegenciaList = (List<Vigencia>) query.list();
				for (Vigencia vigencia : vegenciaList) {
					if (isFirst) {
						aux+= vigencia.getCodigo() + "@" + vigencia.getDescricao();
						isFirst = false;
					} else {
						aux+= ";" + vigencia.getCodigo() + "@" + vigencia.getDescricao();
					}
				}
				out.print(aux);
			} catch (Exception e) {
				e.printStackTrace();
				out.print("0");
			} finally {
				session.close();
			}
			break;
		}
		out.close();
	}
}
 
 /*
 95
  if (idVendedor != null) {
 	funcionario = (Funcionario) session.get(Funcionario.class, idVendedor);
 	if (funcionario != null && funcionario.getUnidade() != null && funcionario.getNome() != null) {
 		aux+= funcionario.getUnidade().getCodigo() + "@" + Util.initCap(funcionario.getNome());
 	}
 }

 */