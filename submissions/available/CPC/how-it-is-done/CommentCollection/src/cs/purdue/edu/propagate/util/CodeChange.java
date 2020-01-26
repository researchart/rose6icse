package cs.purdue.edu.propagate.util;

public class CodeChange {
	public int begin;
	public int len;
	public String newStr;
	
	CodeChange(int begin, int len, String newStr) {
		this.begin = begin;
		this.len = len;
		this.newStr = newStr;
	}
}
