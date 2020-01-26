package cs.purdue.edu;

import java.util.ArrayList;

import cs.purdue.edu.model.Class;
import cs.purdue.edu.model.Comment;
import cs.purdue.edu.model.Field;
import cs.purdue.edu.model.Method;
import cs.purdue.edu.model.Parameter;
import cs.purdue.edu.model.Statement;
import cs.purdue.edu.model.Variable;

public class CodeLists {
	public ArrayList<Class> classes = new ArrayList<Class>();
	public ArrayList<Method> methods = new ArrayList<Method>();
	public ArrayList<Field> fields = new ArrayList<Field>();
	public ArrayList<Parameter> params = new ArrayList<Parameter>();
	public ArrayList<Variable> vars = new ArrayList<Variable>();
	public ArrayList<Statement> statements = new ArrayList<Statement>();
	public ArrayList<Comment> comments = null;
	
	public Class findClass(String className) {
		for (Class cls: classes) {
			if (className.equals(cls.getId())) {
				return cls;
			}
		}
		//System.out.println("Can't find class "+ className);
		return null;
	}
	
	public Method findMethod(String methodName) {
		for (Class cls: classes) {
			for (Method method: cls.getMethods()) {
				if (methodName.equals(method.getId())) {
					return method;
				}
			}
		}
		return null;
	}
	
	public Class declaringClass(int begin, int end) {
		Class retClass = null;
		for (Class cls: classes) {
			if (cls.getLineNumBegin() <= begin && cls.getLineNumEnd() >=end) {
				if (retClass == null || 
						cls.getLineNumBegin()>=retClass.getLineNumBegin() &&
						cls.getLineNumEnd() <= retClass.getLineNumEnd()) {
					retClass = cls;
				}
			}
		}
		if (retClass == null) {
			//System.out.println("[CodeLists.declaringClass] Lines [" + begin 
			//		+ ", " + end + "] are not declared in any classes.");
			return null;
		}
		return retClass;
	}
	
	public Method declaringMethod(int begin, int end) {
		Method retMethod = null;
		for (Method method: methods) {
			if (method.getLineNumBegin() <= begin && method.getLineNumEnd() >=end) {
				if (retMethod == null || 
						method.getLineNumBegin()>=retMethod.getLineNumBegin() &&
						method.getLineNumEnd() <= retMethod.getLineNumEnd()) {
					retMethod = method;
				}
			}
		}
		if (retMethod == null) {
			//System.out.println("[CodeLists.declaringMethod] Lines [" + begin 
			//		+ ", " + end + "] are not declared in any methods.");
			return null;
		}
		return retMethod;
	}
	
	public ArrayList<Comment> getAllComments(){
		if (comments == null) {
			comments = new ArrayList<Comment>();
			for (Class cls: classes) {
				comments.addAll(cls.getAllComments());
			}
		}
		return comments;
	}
}
