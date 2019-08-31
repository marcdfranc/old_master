package com.marcsoftware.database;

import java.io.Serializable;

public class ItensMenuId implements Serializable {
	private Pagina pagina;
	private Menu menu;

	public Pagina getPagina() {
		return pagina;
	}

	public void setPagina(Pagina pagina) {
		this.pagina = pagina;
	}

	public Menu getMenu() {
		return menu;
	}

	public void setMenu(Menu menu) {
		this.menu = menu;
	}
	
	@Override
	public boolean equals(Object object) {
		if ((object == null) || !(object instanceof ItensMenuId)) {
			return false;		
		} 
		ItensMenuId novo= (ItensMenuId) object;
		
		if ((!novo.getMenu().equals(this.menu)) || 
				(!novo.getPagina().equals(this.pagina))) {
			return false;
		}
		return true;
	}
	
	
	@Override
	public int hashCode() {
		return this.menu.hashCode();
	}
}
