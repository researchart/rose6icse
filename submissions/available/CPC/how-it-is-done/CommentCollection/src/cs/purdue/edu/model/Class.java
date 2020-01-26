package cs.purdue.edu.model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class Class extends Subject{
	private ArrayList<Method> methodList = new ArrayList<Method>();
	private ArrayList<Field> fieldList = new ArrayList<Field>();

	public void addMethod(Method m) {
		methodList.add(m);
	}
	
	public ArrayList<Method> getMethods() {
		return methodList;
	}
	
	public Method findMethod(String name) {
		//System.out.print(name+": ");
		for (Method m: methodList) {
			//System.out.print(m.getId()+" ");
			if (m.getId() == name) return m;
		}
		//System.out.println("");
		return null;
	}
	
	public void addField(Field f) {
		fieldList.add(f);
		//System.out.println("[addField] "+this.getId()+": "+f.getId());
	}
	
	public ArrayList<Field> getFields() {
		return fieldList;
	}
	
	public ArrayList<Comment> getAllComments() {
		ArrayList<Comment> comments = this.getComments();
		for (int i = 0; i < fieldList.size(); i++) {
			comments.addAll(fieldList.get(i).getComments());
		}
		for (int i = 0; i < methodList.size(); i++) {
			comments.addAll(methodList.get(i).getAllComments());
		}
		return comments;
	}
}
