package edu.purdue.cs.propagator;

import edu.purdue.cs.CodeLists;
import edu.purdue.cs.model.Class;
import edu.purdue.cs.model.Method;
import org.eclipse.jdt.core.dom.*;

/**
 * Description:
 *
 * @author xxz
 * Created on 2019-07-14
 */
public class ClassAndMethodTracer extends ASTVisitor {
    protected CodeLists codeLists;
    protected Method currentMethod;
    protected Class currentClz;

    public ClassAndMethodTracer(CodeLists codeLists) {
        this.codeLists = codeLists;
    }

    @Override
    public boolean visit(TypeDeclaration node) {
        ITypeBinding iTypeBinding = node.resolveBinding();
        if (iTypeBinding == null) {
            return false;
        }
        Class current = codeLists.findClass(iTypeBinding.getName());
        if (current != null) {
            currentClz = current;
            return true;
        } else {
            System.err.println("Class name not found @ Tracer");
            return false;
        }
    }


    @Override
    public boolean visit(MethodDeclaration node) {
        IMethodBinding iMethodBinding = node.resolveBinding();
        if (iMethodBinding == null) {
            return false;
        }
        Method method = currentClz.findMethod(iMethodBinding.toString());
        if (method != null) {
            currentMethod = method;
            return true;
        } else {
            System.err.println("Method name not found @ Tracer");
            return false;
        }
    }
}
