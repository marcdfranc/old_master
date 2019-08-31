package com.marcsoftware.utilities;

import java.util.ArrayList;

public class GenericObject {
	private ArrayList<String> field;	
	private ArrayList<String> value;
	
	public GenericObject() {		
		field= new ArrayList<String>();		
		value= new ArrayList<String>();
	}
	
	public void addField(String value) {
		field.add(value);
	}	
	
	public void addValue(String value) {
		this.value.add(value);
	}
	
	public ArrayList<String> getField() {
		return field;
	}
	
	public ArrayList<String> getValue() {
		return value;
	}
	
	
	public String getField(int position) {
		return field.get(position);
	}
	
	public String getValue(int position) {
		return value.get(position);
	}
	
	public int getSize() {		
		if (field.size()== value.size()) {
			return field.size();
		} else {
			return -1;
		}
	}
}
