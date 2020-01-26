package cs.purdue.edu.propagate.util;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.jdt.core.dom.ASTVisitor;
import org.eclipse.jdt.core.dom.Block;
import org.eclipse.jdt.core.dom.IfStatement;
import org.eclipse.jdt.core.dom.MethodDeclaration;
import org.eclipse.jdt.core.dom.Statement;
import org.eclipse.jdt.core.dom.ThrowStatement;

/**
 * The class provide a visitor traversing all the Method in order to find
 * methods that only contain ThrowStatement. 
 */
public class ExceptionMethodVisitor extends ASTVisitor{
	private ArrayList<MethodDeclaration> exceptionMethods;
	
	public ExceptionMethodVisitor(ArrayList<MethodDeclaration> exceptionMethods) {
		this.exceptionMethods = exceptionMethods;
	}
	
	public boolean visit(MethodDeclaration node) {
		Block b = node.getBody();
		if (b == null || b.statements() == null) return false;
		List<Statement> list = b.statements();
		if (list.size() == 1 && list.get(0) instanceof IfStatement) {
			IfStatement is = (IfStatement) list.get(0);
			if (ExceptionUtil.isThrowStatementContained(is)) {
				exceptionMethods.add(node);
			}
		}
		else if (list.size() == 1 && list.get(0) instanceof ThrowStatement){
			exceptionMethods.add(node);
		}
		return false;
	}
}
