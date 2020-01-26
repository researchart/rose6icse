package edu.purdue.cs.consistent;

import edu.purdue.cs.CodeLists;
import edu.purdue.cs.model.Class;
import edu.purdue.cs.model.*;
import org.eclipse.jdt.core.dom.*;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * @author XiangzheXu
 * create-time: 2019-01-16
 */
public class UtilVisitor extends ASTVisitor {

    /**
     * use this stack to return values from visit method
     * if there is no value to return, the size of this stack must not change
     */
    protected ArrayList<Subject> retStack = new ArrayList<>();

    protected ArrayList<Class> currentClz = new ArrayList<>();

    protected CodeLists codeLists;

    protected Method currentMethod;


    public UtilVisitor(CodeLists codeLists) {
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
    public boolean visit(VariableDeclarationFragment node) {
        SimpleName variableName = node.getName();
        Expression initializer = node.getInitializer();
        if (initializer != null) {
            Subject variable = tryToVisitAndPop(variableName);
            Subject init = tryToVisitAndPop(initializer);
            if (variable instanceof Variable && init instanceof Parameter) {
                ((Variable) variable).setFromParam(true);
            } else if (variable instanceof Variable && init instanceof Variable) {
                ((Variable) variable).setFromParam(((Variable) init).isFromParam());
            }
        }
        return super.visit(node);
    }


    @Override
    public boolean visit(MethodDeclaration node) {
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
        currentMethod = null;
    }

    protected Method findStaticMethod(MethodInvocation node) {
        Expression expression = node.getExpression();
        if (expression == null) return null;
        Class methodClass = codeLists.findClass(expression.toString());
        if (methodClass != null) {
            ArrayList<Method> candidatesMethod = methodClass.getMethods();
            for (Method method : candidatesMethod) {
                if (method.getId().contains(node.getName().toString()) && method.getParamList().size() == node.arguments().size()) {
                    return method;
                }
            }
        }
        return null;
    }

    protected Method findConstructor(Class clz, List argList) {
        ArrayList<Method> methods = clz.getMethods();
        List<Method> constructors = methods.stream()
                .filter(method -> method.getId().contains("<init>"))
                .collect(Collectors.toList());
        int argSize = argList.size();
        for (Method constructor : constructors) {
            if (constructor.getParamList().size() == argSize) {
                return constructor;
            }
        }

        return null;
    }

    @Override
    public boolean visit(SimpleName node) {
        if (currentMethod == null) {
            return true;
        }
        Variable var = currentMethod.findVar(node.getIdentifier());
        Parameter param = currentMethod.findParam(node.getIdentifier());
        Field field = currentMethod.getCls().findField(node.getIdentifier());
        Class clz = codeLists.findClass(node.getIdentifier());
        if (var != null) {
            retStack.add(var);
        } else if (param != null) {
            retStack.add(param);
        } else if (field != null) {
            retStack.add(field);
        } else if (clz != null) {
            retStack.add(clz);
        }
        return false;
    }

    protected List<Subject> getParams(List<ASTNode> arguments) {
        return arguments
                .stream()
                .map(this::tryToVisitAndPop)
                .collect(Collectors.toList());
    }

    protected Method findConstructor(Class parentClass, SuperConstructorInvocation node) {
        List argList = node.arguments();
        return findConstructor(parentClass, argList);
    }

    protected Subject tryToVisitAndPop(ASTNode node) {
        int beforeStackSize = retStack.size();
        node.accept(this);
        int afterStackSize = retStack.size();
        Subject lhsSubject = null;
        if (beforeStackSize < afterStackSize) {
            lhsSubject = retStack.get(afterStackSize - 1);
            retStack.remove(lhsSubject);

        }
        return lhsSubject;
    }

    protected Method findMethod(IMethodBinding iMethodBinding, Expression methodClassName) {
        if (iMethodBinding == null) {
            return null;
        }
        Method methodInvoked = null;
        if (methodClassName == null) {
            methodInvoked = parseMethod(iMethodBinding.toString());
        } else {
            methodInvoked = parseInstanceMethod(iMethodBinding, methodClassName);
        }
        return methodInvoked;
    }

    protected Method parseInstanceMethod(IMethodBinding iMethodBinding, Expression methodClassName) {
        if (iMethodBinding == null) {
            return null;
        }
        Method methodInvoked = null;
        Class methodClass = codeLists.findClass(methodClassName.toString());
        if (methodClass == null) {
            ITypeBinding declaringClass = iMethodBinding.getDeclaringClass();
            if (declaringClass != null) {
                String declaringClassName = declaringClass.getName();
                methodClass = codeLists.findClass(declaringClassName);
            }
        }
        if (methodClass != null && iMethodBinding != null) {
            methodInvoked = methodClass
                    .findMethod(iMethodBinding.toString());
        }
        return methodInvoked;
    }

    protected Method parseMethod(String methodBinding) {
        if (currentMethod == null) return null;
        Class currentMethodCls = currentMethod.getCls();
        if (currentMethodCls != null) {
            return currentMethodCls.findMethod(methodBinding);
        }
        return null;
    }
}
