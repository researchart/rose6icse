package cs.purdue.edu;

import cs.purdue.edu.model.Comment;
import cs.purdue.edu.model.JavaFile;
import cs.purdue.edu.model.Method;
import cs.purdue.edu.model.Parameter;
import cs.purdue.edu.model.Variable;

import java.io.IOException;

import cs.purdue.edu.model.Class;

public class MethodPrinter {
	static CommentCollector collector = null;

	public static void main(String[] args) throws IOException {
		// TODO Auto-generated method stub
		String dir = "C:\\Projects\\packages\\jdk\\src\\";
		String file = "java\\util\\ArrayList.java";
		collector = new CommentCollector(new JavaFile(dir, file));
		collector.parse();
		
		for (Method method: collector.getCodeLists().methods) {
			if (method.getRetType() != "") {
				System.out.print(method.getRetType() + " ");
			}
			System.out.println(method.getId() + ":");
			for (Parameter param: method.getParams()) {
				System.out.println(
						"    PARAM: " + param.getType() + " " + param.getId());
			}
			for (Variable var: method.getVariables()) {
				System.out.println(
						"    VAR: " + var.getType() + " " + var.getId());
			}
			for (Comment cmt: method.getAllComments()) {
				if (cmt.getTag() != null) {
					System.out.print("    (" + cmt.getTag() + ") ");
				}
				else {
					System.out.print("    ");
				}
				System.out.println(cmt.getOrigText());
			}
		}
	}

}
