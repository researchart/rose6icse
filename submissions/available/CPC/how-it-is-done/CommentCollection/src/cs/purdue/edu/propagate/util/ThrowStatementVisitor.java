package cs.purdue.edu.propagate.util;
import java.util.ArrayList;

import org.eclipse.jdt.core.dom.ASTVisitor;
import org.eclipse.jdt.core.dom.IfStatement;
import org.eclipse.jdt.core.dom.ThrowStatement;

import cs.purdue.edu.model.JavaFile;
import cs.purdue.edu.parser.util.Pair;

class ThrowStatementVisitor extends ASTVisitor {
	// static List<MyLineComment> lineCommentList;
	// static List<MyBlockComment> blockCommentList;
	
	private JavaFile file;
	private ArrayList<Pair<Integer, Integer>> throwStatementLines;

	ThrowStatementVisitor(JavaFile file,
			ArrayList<Pair<Integer, Integer>> throwStatementLines) {
		this.file = file;
		this.throwStatementLines = throwStatementLines;
	}

	
	/**
	 * If it is a ThrowStatement. Get its line numbers directly.
	 */
	public boolean visit(ThrowStatement node) {
		int begin = positionToLineNumber(node.getStartPosition());
		int end = positionToLineNumber(node.getStartPosition() + node.getLength() - 1);
		throwStatementLines.add(new Pair(begin, end));
		return false;
	}
	
	public boolean visit(IfStatement node) {
		if (ExceptionUtil.isThrowStatementContained(node)) {
			int begin = positionToLineNumber(node.getStartPosition());
			int end = positionToLineNumber(node.getStartPosition() + node.getLength() - 1);
			throwStatementLines.add(new Pair(begin, end));
			return false;
		}
		return true;
	}
	
	private int positionToLineNumber(int pos) {
		int i = 0;
		int count = 1;
		while (i < pos) {
			if (file.getSrc().charAt(i) == '\n') count++;
			i++;
		}
		return count;
	}
	


}