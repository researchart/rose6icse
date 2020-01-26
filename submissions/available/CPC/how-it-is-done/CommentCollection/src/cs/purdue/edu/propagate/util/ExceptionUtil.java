package cs.purdue.edu.propagate.util;

import java.util.ArrayList;

import org.eclipse.jdt.core.dom.CompilationUnit;
import org.eclipse.jdt.core.dom.IfStatement;
import org.eclipse.jdt.core.dom.MethodDeclaration;
import org.eclipse.jdt.core.dom.ThrowStatement;

import cs.purdue.edu.model.JavaFile;
import cs.purdue.edu.parser.util.Pair;
import cs.purdue.edu.parser.util.ParserUtil;

public class ExceptionUtil {
	private static ExceptionFunctionCallVisitor functionCallVisitor;

	public static void recplaceExcptionFuncCall(JavaFile f) {
		CompilationUnit cu = f.getCu();
		String source = f.getSrc();
		ArrayList<MethodDeclaration> exceptionMethods = new ArrayList<>();
		cu.accept(new ExceptionMethodVisitor(exceptionMethods));
		
		if (!exceptionMethods.isEmpty()) {
			Revision revision = new Revision();
			functionCallVisitor = new ExceptionFunctionCallVisitor(
					source, revision, exceptionMethods);
			cu.accept(functionCallVisitor);
			f.setSrc(revision.reviseAll(source, 0));
			f.resetCu();
		}
	}
	
	public static ArrayList<Pair<Integer, Integer>> getLineNum(JavaFile f) {
		ArrayList<Pair<Integer, Integer>> ret = new ArrayList<>();
		f.getCu().accept(new ThrowStatementVisitor(f, ret));
		return ret;
	}

	public static boolean isThrowStatementContained(IfStatement is) {
		if (is.getThenStatement() instanceof ThrowStatement) return true;
		if (is.getElseStatement() instanceof ThrowStatement) return true;
		return false;
	}
	
}
