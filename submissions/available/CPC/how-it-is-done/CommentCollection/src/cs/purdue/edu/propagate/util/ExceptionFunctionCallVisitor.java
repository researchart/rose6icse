package cs.purdue.edu.propagate.util;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.jdt.core.dom.ASTVisitor;
import org.eclipse.jdt.core.dom.Expression;
import org.eclipse.jdt.core.dom.ExpressionStatement;
import org.eclipse.jdt.core.dom.MethodDeclaration;
import org.eclipse.jdt.core.dom.MethodInvocation;
import org.eclipse.jdt.core.dom.SimpleName;
import org.eclipse.jdt.core.dom.SingleVariableDeclaration;
import org.eclipse.jdt.core.dom.Statement;

import cs.purdue.edu.propagate.util.ArgVisitor;

/**
 * This visitor will visit all the statements that call functions throwing
 * exceptions. Statement needed to be replaced is record in a Revision.
 */
class ExceptionFunctionCallVisitor extends ASTVisitor {
	// static List<MyLineComment> lineCommentList;
	// static List<MyBlockComment> blockCommentList;
	
	private String source;
	private ArrayList<MethodDeclaration> exceptionMethods;
	private Revision revision;

	ExceptionFunctionCallVisitor(String source, Revision revision,
			ArrayList<MethodDeclaration> exceptionMethods) {
		this.source = source;
		this.revision = revision;
		this.exceptionMethods = exceptionMethods;
	}

	/**
	 * If it is call a method which only contain exception check.
	 */
	public boolean visit(ExpressionStatement node) {
		if (!(node.getExpression() instanceof MethodInvocation)) return false;
		
		MethodInvocation mi = (MethodInvocation) node.getExpression();
		MethodDeclaration md = null;
		String name = mi.getName().getIdentifier();
		for (MethodDeclaration i: exceptionMethods) {
			if(name.equals(i.getName().getIdentifier())
					&& mi.arguments().size() == i.parameters().size()) 
				md = i;
		}
		if (md == null) return false;
		
		/* Replace mi with md. */
		
		// Get the expression for each argument in the Method Invocation.
		ArrayList<String> args = new ArrayList<>();
		for (int i = 0; i < mi.arguments().size(); i++) {
			Expression e = (Expression) mi.arguments().get(i);
			int start = e.getStartPosition();
			int end = start + e.getLength();
			args.add(source.substring(start, end));
		}
		
		
		String newStatements = replaceArgs(md, args);
		
		revision.addChange(node.getStartPosition(), node.getLength(),
				newStatements);
		
		return false;
		
	}
	
	private String replaceArgs(MethodDeclaration md, ArrayList<String> args) {
		// md only contain one statement which relates to a exception.
		List<Statement> body= md.getBody().statements();
		Revision argRevision = new Revision();
		for (Statement s: body) {
			s.accept(new ArgVisitor(args, md.parameters(), argRevision));
			
		}
		
		Statement first = body.get(0);
		Statement last = body.get(body.size() - 1);
		int start = first.getStartPosition();
		int end = last.getStartPosition() + last.getLength();
						
		String bodyStr = source.substring(start, end); 
		
		return argRevision.reviseAll(bodyStr, -start);
		
		/*
		List<SingleVariableDeclaration> params = md.parameters();
		
		
		for (int i = 0; i < args.size(); i++) {
			String param = params.get(i).getName().getIdentifier();
			System.out.print("[replaceArgs] " + bodyStr);
			bodyStr = bodyStr.replaceAll(param, args.get(i));
			System.out.println(" -> " + bodyStr);
		}
		return bodyStr;*/
	}
}