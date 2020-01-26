package cs.purdue.edu.propagate.util;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.jdt.core.dom.ASTVisitor;
import org.eclipse.jdt.core.dom.Expression;
import org.eclipse.jdt.core.dom.SimpleName;
import org.eclipse.jdt.core.dom.SingleVariableDeclaration;
import org.eclipse.jdt.core.dom.Statement;

import cs.purdue.edu.parser.util.Pair;

public class ArgVisitor extends ASTVisitor{
	private ArrayList<String> args;
	private List<SingleVariableDeclaration> params;
	private ArrayList<Pair<Integer, Integer>> positions;
	private Revision revision;
	
	public ArgVisitor(
			ArrayList<String> args,
			List<SingleVariableDeclaration> params,
			Revision revision) {
		this.args = args;
		this.params = params;
		this.revision = revision;
	}
	
	public boolean visitor(Statement node) {
		System.out.println("BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");
		return true;
	}

	
	public boolean visitor(SimpleName node) {
		System.out.println("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
		for (int i = 0; i < params.size(); i++) {
			String paramId = params.get(i).getName().getIdentifier();
			if (paramId.equals(node.getIdentifier()))
				revision.addChange(node.getStartPosition(), node.getLength(),
						args.get(i));
		}
		return false ;
	}
	
}
