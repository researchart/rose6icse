import java.util.List;

import org.eclipse.jdt.core.dom.FieldDeclaration;
import org.eclipse.jdt.core.dom.LineComment;
import org.eclipse.jdt.core.dom.MethodDeclaration;
import org.eclipse.jdt.core.dom.Statement;
import org.eclipse.jdt.core.dom.VariableDeclaration;

import cs.purdue.edu.model.CodeEntity;

public class MyLineComment {
	private static LineComment node;
	private static String source;
	public CommentSnippet cmt = null;

	MyLineComment(LineComment cmtNode, String codeSourse) {
		node = cmtNode;
		source = codeSourse;

		cmt = new CommentSnippet(node);
				
		int i = cmt.start;
		while (source.charAt(i) == ' ') i++;
		cmt.rawText += source.substring(i, cmt.end);
	}

	public String codeEntity(
			List<MethodDeclaration> methodList, 
			List<FieldDeclaration> fieldList, 
			List<VariableDeclaration> variableList,
			List<Statement> statementList) {
		int temp_start = 0;
		int temp_end = source.length();
		MethodDeclaration temp_method = null;
		for (MethodDeclaration m : methodList) {
			int start = m.getStartPosition();
			int end = start + m.getLength();
			if (cmt.start >= start && cmt.end <= end && cmt.start >= temp_start && cmt.end <= temp_end) {
				temp_start = start;
				temp_end = end;
				temp_method = m;
			}
		}

		if (temp_method != null) {
			// This comment is contained in a method. Check if it is a comment for
			// VariableDeclaration.
			boolean isVariable = true;
			temp_start = source.length();
			for (VariableDeclaration v : variableList) {
				int start = v.getStartPosition();
				if (start >= cmt.end && start < temp_start) {
					temp_start = start;
				}
			}
			if (temp_start == source.length()) {
				isVariable = false;
			} else {
				for (Statement s : statementList) {
					int start = s.getStartPosition();
					if (start >= cmt.end && start < temp_start) {
						isVariable = false;
						break;
					}
				}
			}
			if (isVariable)
				return CodeEntity.variable;
			else
				return CodeEntity.statement;
		}

		boolean isField = true;
		temp_start = source.length();
		for (FieldDeclaration f : fieldList) {
			int start = f.getStartPosition();
			if (start >= cmt.end && start < temp_start) {
				temp_start = start;
			}
		}
		if (temp_start == source.length()) {
			isField = false;
		} else {
			for (MethodDeclaration m : methodList) {
				int start = m.getStartPosition();
				if (start >= cmt.end && start < temp_start) {
					isField = false;
					break;
				}
			}
		}
		if (isField) return CodeEntity.field;
		
		return CodeEntity.method;
	}
}
