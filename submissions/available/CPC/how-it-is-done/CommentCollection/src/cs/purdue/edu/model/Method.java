package cs.purdue.edu.model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class Method extends Subject{
	private ArrayList<Parameter> paramList = new ArrayList<Parameter>();
	private ArrayList<Variable> varList = new ArrayList<Variable>();
	private Class cls;
	private String retType;
	
	
	public void addParam(Parameter param) {
		//System.out.println("Param.add: "+ getId() + " " + param.getId());
		paramList.add(param);
	}
	
	public ArrayList<Parameter> getParams() {
		return paramList;
	}
	
	public Parameter findParam(String paramName) {
		for (Parameter param: paramList) {
			if (param.getId() == paramName) {
				return param;
			}
		}
		return null;
	}
	
	public void addVar(Variable var) {
		varList.add(var);
	}
	
	public ArrayList<Variable> getVariables(){
		return varList;
	}
	
	public Variable findVar(String varName) {
		for (Variable var: varList) {
			if (var.getId() == varName) {
				return var;
			}
		}
		return null;
	}
	
	public void setClass(Class cls) {
		this.cls = cls;
	}
	
	public Class getCls() {
		return this.cls;
	}
	
	public void setRetType(String retType) {
		this.retType = retType;
	}
	
	public String getRetType(){
		return this.retType;
	}
	
	public ArrayList<Comment> getAllComments() {
		// TODO: Traverse comments in the body of methods.
		return getComments();
	}
}
