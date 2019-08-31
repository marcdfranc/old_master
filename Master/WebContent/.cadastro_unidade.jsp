<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
	
	<link rel="StyleSheet" href="css/estilo.css" type="text/css" />	
	<script type="text/javascript" src="js/jquery/jquery.js"></script>
	<script type="text/javascript" src="js/validation.js" ></script>
		
	<!--[if IE]><link rel="StyleSheet" href="css/ieStyle.css" type="text/css" /><![endif]-->
	
	<title>Master Cadastro de Unidade</title>
</head>
<body onload="startValidation(36)" >	
	<%@ include file="inc/header.jsp" %>	
	<div id="centerAll">
		<%@ include file="inc/menu.jsp" %>	
		 
		<div id="formStyle">
			<form id="unit" method="post" action="Authentic" >
				<div id="geralDate" class="alignHeader" >
					<div id="razaoSocial" class="textBox">
						<label>Razão Social</label><br/>
						<input id="razaoSocialIn" name="razaoSocial" type="text" style="width: 312px; z-index:4;" class="required" onblur="genericValid(this);" />						
					</div>
					<div id="fantasia" class="textBox">
						<label>Fantasia</label><br/>					
						<input id="fantasiaIn" name="fantasia" type="text" style="width: 312px" value="Master Odontologia & Saúde" class="required" onblur="genericValid(this);" />
					</div>
					<div id="cnpj" class="textBox">
						<label>Cnpj</label><br/>					
						<input id="cnpjIn" name="cnpj" type="text" style="width: 115px" class="required" onblur="cnpjValidation(this)" />
					</div>					
					<div id="franquia" class="textBox">
						<label >Tipo</label><br />
						<div class="checkRadio">
							<label>Franquia</label>
							<input id="franquiaChecked" name="ie" type="radio" style="width: 95px" checked="checked" vaule="f" />
							<label>Unidade</label>
							<input id="unidadeChecked" name="ie" type="radio" style="width: 95px" vaule="u" />
						</div>
						<input id="tipo" name="tipo" type="hidden" />
					</div>
					<div id="status" class="textBox">
						<label >Status</label><br />
						<div class="checkRadio">
							<label class="labelCheck" >Ativar</label>
							<input id="ativoChecked" name="ie" type="radio" style="width: 95px" checked="checked" vaule="f" />
							<label class="labelCheck" >Bloquear</label>
							<input id="notAtivoChecked" name="ie" type="radio" style="width: 95px" vaule="u" />
						</div>
						<input id="ativo" name="ativo" type="hidden" />
					</div>
					<div id="taxa" class="textBox">
						<label>Taxa de Serv.</label><br/>					
						<input id="taxaIn" name="taxa" type="text" style="width: 107px" class="required" onblur="genericValid(this)" />
						<label></label>
					</div>
					<div id="tabela2" class="textBox">
						<label>Tabela 2</label><br/>					
						<input id="tabela2In" name="tabela2" type="text" style="width: 115px" class="required" onblur="genericValid(this)" />
					</div>
				</div>				
				<div id="endereco" class="bigBox" >
					<div class="indexTitle">
						<h4>Endereço</h4>
						<div class="alignLine">
							<hr>
						</div>
					</div>		
					<div id="cep" class="textBox">
						<label>CEP</label><br/>					
						<input id="cepIn" name="cep" type="text" style="width: 63px" />						
					</div>
					<div id="rua" class="textBox">
						<label>Rua/Av</label><br/>					
						<input id="ruaIn" name="rua" type="text" style="width: 200px" class="required" onblur="genericValid(this)" />						
					</div>
					<div id="numero" class="textBox">
						<label>Numero</label><br/>					
						<input id="numeroIn" name="numero" type="text" style="width: 45px" />
					</div>
					<div id="bairro" class="textBox">
						<label>Bairro</label><br/>					
						<input id="BairroIn" name="bairro" type="text" style="width: 200px" />
					</div>
					<div id="uf" class="textBox">
						<label>Uf</label><br/>
						<select id="ufIn">
							<option>SP</option>
							<option>RJ</option>
						</select>			
					</div>
					<div id="complemento" class="textBox">
						<label>Complemento</label><br/>					
						<input id="complementoIn" name="complemento" type="text" style="width: 220px" />
					</div>
					<div id="cidade" class="textBox">
						<label>Cidade</label><br/>					
						<input id="cidadeIn" name="cidade" type="text" style="width: 240px" class="required" onblur="genericValid(this)" />
					</div>
					
					<div id="unidadeEndereco" class="dataGrid">
						<table id="dg" cellpadding="3" cellspacing="0" class="lstGrid">
							<thead>
								<tr>
									<th style="width: 10px"></th>
									<th style="width: 10%">
										<div class="headerColum" >
											<p>CEP</p>
										</div>
									</th>
									<th style="width: 20%">
										<div class="headerColum"><p>Rua/Av</p></div>
									</th>
									<th style="width: 10%">
										<div class="headerColum"><p>Numero</p></div>
									</th>									
								</tr>
							</thead>
							<tbody>
								<tr>
									<td style="width: 20px;">
										<div><input id="check1" type="checkbox" /></div>
									</td>
									<td class="headerRow">00000-000</td>
									<td class="gridRow" >merda</td>
									<td class="gridRow">000</td> 
								</tr>
								<tr>
									<td style="width: 10px;">
										<input id="check2" type="checkbox" />
									</td>
									<td class="headerRow">00000-000</td>
									<td class="gridRow" >bosta</td>
									<td class="gridRow">000</td> 
								</tr>
								<tr>
									<td style="width: 10px;">
										<input id="check3" type="checkbox" />
									</td>
									<td class="headerRow">00000-000</td>
									<td class="gridRow" >bosta</td>
									<td class="gridRow">000</td> 
								</tr>														
							</tbody>
						</table>					
					</div>
					
					
					
									
				</div>
				<div id="responsavel" class="bigBox" >
					<div class="indexTitle">
						<h4>Responsável</h4>
						<div class="alignLine">
							<hr>
						</div>
					</div>
					<div id="nome" class="textBox">
						<label>Nome</label><br/>					
						<input id="nomeIn" name="nome" type="text" style="width: 378px" class="required" onblur="genericValid(this)" />
					</div>
					<div class="textBox">
						<label >Sexo</label><br />
						<div class="checkRadio">
							<label>Masculino</label>
							<input id="masculinoChecked" name="ie" type="radio" style="width: 95px" checked="checked" vaule="m" />
							<label>Feminino</label>
							<input id="femininoChecked" name="ie" type="radio" style="width: 95px" vaule="f" />
						</div>
						<input id="sexo" name="sexo" type="hidden" />
					</div>
					<div id="cpf" class="textBox">
						<label>Cpf</label><br/>					
						<input id="cpfIn" name="cpf" type="text" style="width: 89px" class="required" onblur="cpfValidation(this)" />						
					</div>
					<div id="rg" class="textBox">
						<label>Rg</label><br/>					
						<input id="rgIn" name="rg" type="text" style="width:68px" />
					</div>
					<div id="nascimento" class="textBox">
						<label>Nascimento</label><br/>					
						<input id="nascimentoIn" name="nascimento" type="text" style="width:70px" class="required" onblur="genericValid(this)" />
					</div>
					<div id="nacionalidade" class="textBox">
						<label>Nacionalidade</label><br/>
						<input id="nacionalidadeIn" name="nacionalidade" type="text" style="width:200px" class="required" onblur="genericValid(this)"/>
					</div>
					<div id="naturalidade" class="textBox">
						<label>Naturalidade</label><br/>
						<input id="naturalidadeIn" name="naturalidade" type="text" style="width:200px" class="required" onblur="genericValid(this)" />
					</div>
					<div class="textBox">
						<label>Estado Cívil</label><br/>
						<select id="estadoCivilIn" name="estadoCivil" >
							<option>Casado(a)</option>
							<option>Solteiro(a)</option>
							<option>Disquitado(a)</option>
						</select>	
					</div>
				</div>
				<div id="EnderecoResponsavel" class="bigBox" >
					<div class="indexTitle">
						<h4>Endereço Responsável</h4>
						<div class="alignLine">
							<hr>
						</div>
					</div>		
					<div id="cepResponsavel" class="textBox">
						<label>CEP</label><br/>					
						<input id="cepResponsavelIn" name="cepResponsavel" type="text" style="width: 63px" />
					</div>
					<div id="ruaResponsavel" class="textBox">
						<label>Rua/Av</label><br/>					
						<input id="ruaResponsavelIn" name="ruaResponsavel" type="text" style="width: 200px" class="required" onblur="genericValid(this)" />
					</div>
					<div id="numeroResponsavel" class="textBox">
						<label>Numero</label><br/>					
						<input id="numeroResponsavelIn" name="numeroResponsavel" type="text" style="width: 45px" />
					</div>
					<div id="bairroResponsavel" class="textBox">
						<label>Bairro</label><br/>					
						<input id="bairroResponsavelIn" name="bairroResponsavel" type="text" style="width: 200px"  />
					</div>
					<div class="textBox">
						<label>Uf</label><br/>
						<select id="ufResponsavel" name="ufResponsavel">
							<option>SP</option>
							<option>RJ</option>
						</select>			
					</div>
					<div id="complementoResponsavel" class="textBox">
						<label>Complemento</label><br/>					
						<input id="complementoResponsavelIn" name="complementoResponsavel" type="text" style="width:220px" />
					</div>
					<div id="cidadeResponsavel" class="textBox">
						<label>Cidade</label><br/>					
						<input id="cidadeResponsavelIn" name="cidadeResponsavel" type="text" style="width: 240px" class="required" onblur="genericValid(this)" />
					</div>					
				</div>
				<div id="conta" class="bigBox" >
					<div class="indexTitle">
						<h4>Conta Corrente</h4>
						<div class="alignLine">
							<hr>
						</div>
					</div>
					<div class="textBox">
						<label>Banco</label><br/>
						<select id="banco">
							<option>Selecione</option>
							<option>Banco do Brasil</option>
							<option>Santander</option>
							<option>Itaú</option>
							<option>HSBC</option>
							<option>Bradesco</option>
							<option>Banco Real</option>
							<option>Caixa Econômica Federal</option>
							<option>Nossa Caixa</option>
							<option>Unibanco</option>
							<option>Sudameris</option>
							<option>Outro</option>
						</select>	
					</div>	
					<div id="agencia" class="textBox">
						<label>Agencia</label><br/>					
						<input id="agenciaIn" name="agenciaIn" type="text" style="width: 50px" />
					</div>
					<div id="numeroConta" class="textBox">
						<label>Numero</label><br/>					
						<input id="numeroContaIn" name="numero" type="text" style="width: 100px" class="required" onblur="genericValid(this)" />
					</div>
					<div id="insertConta" class="textBox">
						<div class="formGreenButton" >
							<input id="insertContaIn" name="insertConta" class="greenButtonStyle" style="left: 444px;" type="button" value="Inserir" />
						</div>					
					</div>
				</div>
				<div id="contato" class="bigBox" >
					<div class="indexTitle">
						<h4>Informações de Contato</h4>
						<div class="alignLine">
							<hr>
						</div>
					</div>
					<div id="fone" class="textBox">
						<label>Telefone</label><br/>					
						<input id="foneIn" name="fone" type="text" style="width:85px" class="required" onblur="genericValid(this)" />
					</div>
					<div id="celular" class="textBox">
						<label>Celular</label><br/>					
						<input id="celularIn" name="celular" type="text" style="width:85px" class="required" onblur="genericValid(this)" />
						<label style="margin-left: 20px;" >Outros</label>
					</div>
					<div class="textBox">
						<label>Tipo</label><br/>
						<select id="estadoCivil" name="estadoCivil" >
							<option>Selecione</option>
							<option>Telefone</option>
							<option>Fax</option>
							<option>celular</option>
							<option>email</option>
							<option>msn</option>
							<option>Skype</option>
							<option>G Talk</option>
							<option>ICQ</option>
							<option>Pagina Web</option>
							<option>Outro</option>							
						</select>	
					</div>
					<div id="descricao" class="textBox">
						<label>Descrição</label><br/>					
						<input id="descricaoIn" name="descricao" type="text" style="width:300px;" />						
					</div>
					<div class="textBox">
						<div class="formGreenButton" >
							<input id="insertInfo" name="insertInfo" class="greenButtonStyle" style="left: 124px;" type="button" value="Inserir" />
						</div>					
					</div>
				</div>			
				<div id="contato" class="bigBox" >
					<div class="indexTitle">
						<h4>&nbsp;</h4>
					</div>
					<div class="textBox">
						<div class="formGreenButton" >
							<input id="save" name="save" class="greenButtonStyle" style="margin-top: 10px; left: 822px" type="button" value="Salvar" onmousedown="pageValidation(\"login.jsp\")" />
						</div>					
					</div>
				</div>
			</form>
		</div>
	</div>
	<%@ include file="inc/footer.html" %>	
</body>
</html>