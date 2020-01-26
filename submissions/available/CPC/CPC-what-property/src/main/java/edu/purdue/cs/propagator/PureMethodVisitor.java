package edu.purdue.cs.propagator;


import edu.purdue.cs.CodeLists;
import edu.purdue.cs.model.Class;
import edu.purdue.cs.model.Method;
import edu.purdue.cs.model.Statement;
import org.eclipse.jdt.core.dom.*;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

/**
 * @author XiangzheXu
 * create-time: 2019/1/10
 */

public class PureMethodVisitor extends ASTVisitor {
    private boolean pure;
    private CodeLists codeLists;
    private Method currentMethod;
    private ArrayList<Class> currentClz = new ArrayList<>();


    public PureMethodVisitor(CodeLists codeLists) {
        this.codeLists = codeLists;
    }


    @Override
    public boolean visit(TypeDeclaration node) {
        currentClz.add(codeLists.findClass(node.getName().toString()));
        return super.visit(node);
    }

    @Override
    public void endVisit(TypeDeclaration node) {
        if (!currentClz.isEmpty()) {
            currentClz.remove(currentClz.size() - 1);
        }
    }

    @Override
    public boolean visit(ReturnStatement node) {
        if (pure) {
            if (currentMethod == null) {
                return false;
            }
            currentMethod.setEasyToPropagate(true);
        }
        return true;
    }

    @Override
    public boolean visit(MethodInvocation node) {
        if (node.getName().toString().toLowerCase().contains("check")) {
            return false;
        }
        pure = false;
        return false;
    }

    @Override
    public boolean visit(Assignment node) {
        pure = false;
        return false;
    }

    @Override
    public boolean visit(Block node) {
//        String src = node.toString();
//        src = src.toLowerCase();
//        if (src.contains("return")) {
//            src = src.replaceFirst("return", "");
//            if (src.contains("return")) {
//                pure = false;
//                return false;
//            }
//        }
        return true;
    }

    @Override
    public boolean visit(MethodDeclaration node) {
        pure = true;
        IMethodBinding iMethodBinding = node.resolveBinding();
        if (iMethodBinding == null) {
            return false;
        }
        Class methodClass = currentClz.get(currentClz.size() - 1);
        if (methodClass != null) {
            currentMethod = methodClass.findMethod(iMethodBinding.toString());
        }
        return currentMethod != null;
    }


    @Override
    public void endVisit(MethodDeclaration node) {
        if (currentMethod == null) {
            return;
        }
        currentMethod.setPure(pure);
        boolean easyToPropagate = currentMethod.isEasyToPropagate() || pure;
        currentMethod.setEasyToPropagate(easyToPropagate);

        currentMethod = null;
    }
}


class PureReturnChecker extends ASTVisitor {
    private Set<String> modifiedSet;
    private boolean pureReturn = true;

    public PureReturnChecker(Set<String> modifiedSet) {
        this.modifiedSet = modifiedSet;
    }

    public boolean isPureReturn(ReturnStatement returnStatement) {
        returnStatement.accept(this);
        return pureReturn;
    }


    @Override
    public boolean visit(QualifiedName node) {
        String name = node.getName().getIdentifier();
        if (modifiedSet.contains(name)) {
            pureReturn = false;
        }
        return super.visit(node);
    }

    @Override
    public boolean visit(SimpleName node) {
        String name = node.getIdentifier();
        if (modifiedSet.contains(name)) {
            pureReturn = false;
        }
        return super.visit(node);
    }
}
