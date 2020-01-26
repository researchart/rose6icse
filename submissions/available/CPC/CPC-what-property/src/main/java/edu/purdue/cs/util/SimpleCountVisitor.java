package edu.purdue.cs.util;

import org.eclipse.jdt.core.dom.ASTVisitor;
import org.eclipse.jdt.core.dom.CompilationUnit;
import org.eclipse.jdt.core.dom.TypeDeclaration;

/**
 * @author XiangzheXu
 * create-time: 2019-02-09
 */
public class SimpleCountVisitor extends ASTVisitor {
    private static long loc;
    private static long classNumber;

    public static void init() {
        loc = classNumber = 0;
    }

    public static long getLoc() {
        return loc;
    }

    public static long getClassNumber() {
        return classNumber;
    }

    @Override
    public boolean visit(TypeDeclaration node) {
        classNumber++;
        return super.visit(node);
    }

    @Override
    public boolean visit(CompilationUnit node) {
        int oriLength = node.toString().length();
        int emittedLength = node.toString().replaceAll("\n", "").length();
        int loc = oriLength - emittedLength;
        SimpleCountVisitor.loc += loc;
        return super.visit(node);
    }
}
