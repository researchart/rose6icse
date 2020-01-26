package edu.purdue.cs.propagator.property;

import edu.purdue.cs.CodeLists;
import edu.purdue.cs.consistent.UtilVisitor;
import edu.purdue.cs.model.Class;
import edu.purdue.cs.model.Comment;
import edu.purdue.cs.model.*;
import edu.purdue.cs.propagator.ClassAndMethodTracer;
import edu.purdue.cs.propagator.StatementJudger;
import edu.purdue.cs.propagator.Util;
import edu.purdue.cs.util.WordDistanceCalculator;
import org.eclipse.jdt.core.dom.*;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * @author XiangzheXu
 * create-time: 2019-01-25
 */
public class PropertyVisitor extends UtilVisitor {

    public PropertyVisitor(CodeLists codeLists) {
        super(codeLists);
    }

    public boolean visit(MethodInvocation node) {
        if (currentMethod == null) return false;

        IMethodBinding iMethodBinding = node.resolveMethodBinding();
        Expression methodClassName = node.getExpression();
        Method methodInvoked = null;
        if (iMethodBinding == null) {
            methodInvoked = findStaticMethod(node);
            if (methodInvoked == null) {
                return false;
            }
        } else {
            methodInvoked = findMethod(iMethodBinding, methodClassName);
        }
        if (methodInvoked != null) {
            propagateConstrains(methodInvoked, node.arguments());
        }
        return super.visit(node);
    }

    @Override
    public boolean visit(ClassInstanceCreation node) {
        Type type = node.getType();
        if (type instanceof ParameterizedType) {
            type = ((ParameterizedType) type).getType();
        }
        if (type != null) {
            Class createdClass = codeLists.findClass(type.toString());
            if (createdClass != null) {
                Method constructorInvoked = findConstructor(createdClass, node.arguments());
                if (constructorInvoked != null) {
                    propagateConstrains(constructorInvoked, node.arguments());
                }
            }
        }
        return super.visit(node);
    }

    @Override
    public boolean visit(ConstructorInvocation node) {
        IMethodBinding iMethodBinding = node.resolveConstructorBinding();
        if (iMethodBinding == null) return false;
        Method methodInvoked = currentMethod.getCls().findMethod(iMethodBinding.toString());
        if (methodInvoked != null) {
            propagateConstrains(methodInvoked, node.arguments());
        }
        return super.visit(node);
    }

    @Override
    public boolean visit(SuperMethodInvocation node) {
        if (currentMethod == null) return false;
        IMethodBinding iMethodBinding = node.resolveMethodBinding();
        if (iMethodBinding == null) return false;
        Class cls = currentMethod.getCls();
        Class superClass = cls.getSuperClass();
        Method methodInvoked = null;
        if (superClass != null) {
            methodInvoked = superClass.findMethod(iMethodBinding.toString());
        }

        if (methodInvoked == null) {
            return false;
        }

        propagateConstrains(methodInvoked, node.arguments());

        return super.visit(node);
    }

    private void propagateConstrains(Method methodInvoked, List<ASTNode> argList) {
        List<Constrain> methodConstrains = methodInvoked.getMethodConstrains();
        if (methodConstrains == null) return;
        List<String> argStringList = argList.stream()
                .map(ASTNode::toString)
                .collect(Collectors.toList());
        for (Constrain methodConstrain : methodConstrains) {
            int rank = 1;
            for (String argString : argStringList) {
                if (fromParam(argString) && methodConstrain.getConstrainToRank().contains(rank)) {
                    String constrains = methodConstrain.generateConstrains(argStringList);
                    Parameter parameter = findParamFromString(argString);
                    Comment comment = new Comment();
                    comment.setOrigText(constrains);
                    String ori = "";
                    if (parameter.isHasComment()) {
                        ori = parameter.getComments().get(0).getOrigText();
                    }
                    parameter.getComments().add(comment);
                    WordDistanceCalculator.log(constrains, ori, methodInvoked.toString(), parameter + "@" + currentMethod.toString(), "pro Constrains");
                }
                rank++;
            }
        }

    }

    private Parameter findParamFromString(String argString) {
        assert currentMethod != null;
        for (Parameter parameter : currentMethod.getParamList()) {
            if (argString.contains(parameter.getId())) {
                return parameter;
            }
        }
        assert false;
        return null;
    }

    private boolean fromParam(String argString) {
        if (currentMethod == null) return false;
        return currentMethod.getParamList()
                .stream()
                .map(Subject::getId)
                .anyMatch(argString::contains);

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


}
