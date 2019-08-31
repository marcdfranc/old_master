package com.marcsoftware.database;

import java.io.Serializable;

public class ItensGrupoId implements Serializable {
	private Grupo grupo;
	private Catalogo catalogo;
	
	public ItensGrupoId() {
		
	}

	public Grupo getGrupo() {
		return grupo;
	}

	public void setGrupo(Grupo grupo) {
		this.grupo = grupo;
	}

	public Catalogo getCatalogo() {
		return catalogo;
	}

	public void setCatalogo(Catalogo catalogo) {
		this.catalogo = catalogo;
	}
}
