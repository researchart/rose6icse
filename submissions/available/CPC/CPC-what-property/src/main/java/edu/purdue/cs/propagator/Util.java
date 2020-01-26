package edu.purdue.cs.propagator;

import edu.purdue.cs.CodeLists;
import edu.purdue.cs.model.Class;
import edu.purdue.cs.model.Method;
import org.eclipse.jdt.core.dom.Expression;
import org.eclipse.jdt.core.dom.IMethodBinding;
import org.eclipse.jdt.core.dom.MethodInvocation;

/**
 * Description:
 *
 * @author xxz
 * Created on 2019-07-14
 */
public class Util {
    public static Method findMethodInvoked(MethodInvocation node, CodeLists codeLists, Method currentMethod) {
        Expression methodClassName = node.getExpression();
        IMethodBinding iMethodBinding = node.resolveMethodBinding();
        if (iMethodBinding != null) {

            Method methodInvoked = null;
            if (methodClassName == null) {
                methodInvoked = currentMethod.getCls().findMethod(iMethodBinding.getMethodDeclaration().toString());
            } else {
                Class methodClass = codeLists.findClass(methodClassName.toString());
                if (methodClass == null) {
                    String clzName = methodClassName.resolveTypeBinding().getTypeDeclaration().getName();
                    methodClass = codeLists.findClass(clzName);
                }
                if (methodClass != null) {
                    methodInvoked = methodClass
                            .findMethod(iMethodBinding.getMethodDeclaration().toString());
                }
            }
            return methodInvoked;
        }
        System.out.println("Method binding is null! " + node);
        return null;
    }
}
