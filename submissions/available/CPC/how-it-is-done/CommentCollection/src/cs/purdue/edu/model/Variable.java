package cs.purdue.edu.model;

public class Variable extends Subject{
	private String type;
	private Method method;
	private String value;
	
	public void setType(String type) {
		this.type = type;
	}
	public String getType() {
		return this.type;
	}
	
	public void setMethod(Method method) {
		this.method = method;
	}
	
	public Method getMethod() {
		return this.method;
	}
	
	public void setValue(String value) {
		this.value = value;
	}
	public String getValue() {
		return this.value;
	}
}
