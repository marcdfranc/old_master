package com.marcsoftware.database;
import java.util.ArrayList;
import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.hibernate.Query;
import org.hibernate.Session;


public class Filter {
	private ArrayList<String> arguments, parameter;
	private ArrayList<Object> values;
	private ArrayList<Object> type;
	private ArrayList<Integer> typeSwitch;
	private int size;
	private String query, order;
	private boolean haveWere, haveOrder;
	
	public void setOrder(String order) {
		this.order= order;
	}
	
	public void setHaveOrder(boolean value) {
		this.haveOrder = value;
	}
	
	public Filter(String query) {
		this.query= query;		
		haveWere= whereDtect(query);
		arguments = new ArrayList<String>();
		type= new ArrayList<Object>();
		parameter= new ArrayList<String>();
		values= new ArrayList<Object>();
		typeSwitch= new ArrayList<Integer>();
		size= 0;
		haveOrder= true;
	}
	
	public Filter(String query, String args, Object typeParameter, 
			String parameterName, Object parameterValue) {
		this.query= query;		
		haveWere= whereDtect(query);
		arguments = new ArrayList<String>();
		type= new ArrayList<Object>();
		parameter= new ArrayList<String>();
		values= new ArrayList<Object>();
		typeSwitch= new ArrayList<Integer>();
		arguments.add(args);
		type.add(typeParameter);
		typeSwitch.add(parseType(typeParameter));
		parameter.add(parameterName);
		values.add(parameterValue);		
		size= 1;
		haveOrder= true;
	}	
	
	private boolean whereDtect(String text) {
		Pattern pattern= Pattern.compile("(.*)( where )(.*)");
		Matcher matcher= pattern.matcher(text);
		return matcher.find();
	}

	public void addFilter(String args, Object typeParameter, String parameterName, Object parameterValue) {
		size++;
		arguments.add(args);
		type.add(typeParameter);
		typeSwitch.add(parseType(parameterValue));
		parameter.add(parameterName);
		values.add(parameterValue);
	}
	
	
	private int parseType(Object type) {
		if (type instanceof String) {
			return 1;
		} else if ((type instanceof Integer) || (type instanceof Long)){
			return 2;
		} else if (type instanceof Double){
			return 3;
		} else if (type instanceof Date){
			return 4;
		} else {
			return 5;
		}
	}
	
	/**
	 * 1 = String
	 * 2 = Long
	 * 3 = Double
	 * 4 = Date
	 * default = Entity
	 */
	public Query mountQuery(Session session) {
		Query query= session.createQuery(mountQuery());		
		for (int i = 0; i < parameter.size(); i++) {
			switch (typeSwitch.get(i)) {
			case 1:
				query.setString(parameter.get(i), (String) values.get(i));
				break;
				
			case 2:
				query.setLong(parameter.get(i), Long.valueOf(values.get(i).toString()));
				break;
				
			case 3:
				query.setDouble(parameter.get(i), Double.valueOf(values.get(i).toString()));
				break;
				
			case 4:
				query.setDate(parameter.get(i), (Date) values.get(i));
				break;	
				
			default:
				query.setEntity(parameter.get(i), values.get(i));
				break;
			}
		}		
		return query;		
	}
	
	/**
	 * 1 = String
	 * 2 = Long
	 * 3 = Double
	 * 4 = Date
	 * default = Entity
	 */
	public Query mountQuery(Query query, Session session) {
		query= session.createQuery(mountQuery());		
		for (int i = 0; i < parameter.size(); i++) {
			switch (typeSwitch.get(i)) {
			case 1:
				query.setString(parameter.get(i), (String) values.get(i));
				break;
				
			case 2:
				query.setLong(parameter.get(i), Long.valueOf(values.get(i).toString()));
				break;
				
			case 3:
				query.setDouble(parameter.get(i), Double.valueOf(values.get(i).toString()));
				break;
				
			case 4:
				query.setDate(parameter.get(i), (Date) values.get(i));
				break;	

			default:
				query.setEntity(parameter.get(i), values.get(i));
				break;
			}
		}		
		return query;		
	}
	
	private String mountQuery() {
		for (String arg : arguments) {
			if (! haveWere) {
				query+= " where " + arg;
				haveWere= true;
			} else {
				query+= " and " + arg;		
			}
		}
		if (haveOrder) {
			query+= " order by " + order;			
		}
		return query;
	}	
	
	private void clearFilter() {
		arguments.clear();
		values.clear();
		parameter.clear();
		type.clear();
		typeSwitch.clear();
	}
	
	public int getSize() {
		return this.size;
	}	
	
}
