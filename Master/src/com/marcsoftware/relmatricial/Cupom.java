package com.marcsoftware.relmatricial;

import java.util.ArrayList;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;

import com.marcsoftware.utilities.GeradorMatricial;
import com.marcsoftware.utilities.Util;

public abstract class Cupom {
	protected GeradorMatricial matricial;	
	protected ArrayList<Long> pipe;
	protected int cols;
	protected String relatorio;
	
	public Cupom() {
		
	}
	
	public void setPipe(String pipe) {		
		this.pipe = Util.unmountPipeline(pipe);
	}
	
	public void setCols(int cols) {
		this.cols = cols;
	}
	
	public String getRelatorio() {
		return this.relatorio;
	}
	
	public abstract void mountRel();
}
