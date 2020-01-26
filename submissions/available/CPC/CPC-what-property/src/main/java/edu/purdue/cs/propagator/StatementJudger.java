package edu.purdue.cs.propagator;

import org.eclipse.jdt.core.dom.*;

/**
 * to judge whether the statement containing method invocation doing other things
 * except for getting the returning value of the method invoked
 */
public class StatementJudger extends ASTVisitor {
    private boolean result = true;

    public boolean judge(MethodInvocation node) {
        ASTNode toFind = node.getParent();
        while (toFind != null) {
            if (toFind instanceof Statement) {
                toFind.accept(this);
                return result;
            } else {
                toFind.accept(this);
                toFind = toFind.getParent();
            }
            if (!result) {
                return false;
            }
        }
        return result;
    }

    @Override
    public boolean visit(IfStatement node) {
        result = false;
        return false;
    }

    @Override
    public boolean visit(ConstructorInvocation node) {
        result = false;
        return false;
    }

    @Override
    public boolean visit(MethodInvocation node) {
        result = false;
        return false;
    }

    @Override
    public boolean visit(InfixExpression node) {
        result = false;
        return false;
    }

    @Override
    public boolean visit(ArrayAccess node) {
        result = false;
        return false;
    }

    @Override
    public boolean visit(ConditionalExpression node) {
        result = false;
        return false;
    }

    @Override
    public boolean visit(ReturnStatement node) {
        return false;
    }
}
