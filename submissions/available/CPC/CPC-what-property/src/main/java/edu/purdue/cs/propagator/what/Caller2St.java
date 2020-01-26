package edu.purdue.cs.propagator.what;

import edu.purdue.cs.CodeLists;
import edu.purdue.cs.model.Method;
import edu.purdue.cs.propagator.ClassAndMethodTracer;
import edu.purdue.cs.propagator.Util;
import org.eclipse.jdt.core.dom.ASTNode;
import org.eclipse.jdt.core.dom.MethodInvocation;
import org.eclipse.jdt.core.dom.Statement;

/**
 * Description:
 *
 * @author xxz
 * Created on 2019-07-14
 */
public class Caller2St extends ClassAndMethodTracer {
    public Caller2St(CodeLists codeLists) {
        super(codeLists);
    }


    @Override
    public boolean visit(MethodInvocation node) {
        if (!currentMethod.isPure()) {
            return false;
        }
        //find the statement node
        ASTNode toFind = node;
        while (toFind != null) {
            if (toFind instanceof Statement) {
                break;
            } else {
                toFind = toFind.getParent();
            }
        }
        edu.purdue.cs.model.Statement targetStatement = currentMethod.findStatementByNode(toFind);
        Method srcMethod = Util.findMethodInvoked(node, codeLists, currentMethod);
        //TODO to statement or to method?
        return super.visit(node);
    }
}
