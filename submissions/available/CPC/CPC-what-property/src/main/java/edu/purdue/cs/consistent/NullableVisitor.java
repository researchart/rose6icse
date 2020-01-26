package edu.purdue.cs.consistent;

import edu.purdue.cs.CodeLists;
import edu.purdue.cs.model.Class;
import edu.purdue.cs.model.Comment;
import edu.purdue.cs.model.*;
import edu.purdue.cs.util.WordDistanceCalculator;
import org.eclipse.jdt.core.dom.*;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * @author XiangzheXu
 * create-time: 2019-01-22
 */
public class NullableVisitor extends UtilVisitor {
    public NullableVisitor(CodeLists codeLists) {
        super(codeLists);
    }

    @Override
    public boolean visit(Assignment node) {
        super.visit(node);
        Subject lhs = tryToVisitAndPop(node.getLeftHandSide());
        Subject rhs = tryToVisitAndPop(node.getRightHandSide());
        if (lhs != null) {
            if (rhs == null) {
                // a radical rule
                lhs.setNullable(false);
            } else {
                lhs.setNullable(rhs.isNullable());
            }
        }
        return false;
    }
//
//    @Override
//    public boolean visit(MethodDeclaration node) {
//        super.visit(node);
//        if (currentMethod == null) return false;
//        List<Comment> exceptions = currentMethod.getExceptions();
//        boolean hasNPE = containsNPE(exceptions);
//        ArrayList<Parameter> paramList = currentMethod.getParamList();
//        if (hasNPE) {
//            exit:
//            for (Parameter parameter : paramList) {
//                if (parameter.getProperties() != null && !parameter.getProperties().isEmpty()) {
//                    Property firstProperty = parameter.getProperties().get(0);
//                    if (firstProperty.getProperty().contains("null")) {
//                        switch (firstProperty.getPossibility()) {
//                            case CAN:
//                            case MAY_NOT:
//                            case DEFAULT:
//                                WordDistanceCalculator.log("", "", firstProperty.getProperty(), currentMethod.toString(), "Property possibility ERR");
//                                break exit;
//                            default:
//                        }
//                    }
//                }
//            }
//        } else {
//
//            List<Property> shouldNotNullProperty = paramList.stream()
//                    .map(Parameter::getProperties)
//                    .filter(Objects::nonNull)
//                    .flatMap(Collection::stream)
//                    .filter(Objects::nonNull)
//                    .filter(property -> property.getProperty().contains("null") && negativePossibility(property))
//                    .collect(Collectors.toList());
//            if (!shouldNotNullProperty.isEmpty()) {
//                WordDistanceCalculator.log("", "", shouldNotNullProperty.get(0).getProperty(), currentMethod.toString(), "Property find missing NPE");
//            }
//        }
//
//        return true;
//    }


    @Override
    public boolean visit(MethodInvocation node) {
        super.visit(node);
        if (currentMethod == null) return false;
        IMethodBinding binding = node.resolveMethodBinding();
        Expression expression = node.getExpression();
        if (binding == null) return false;
        Method methodInvoked = findMethod(binding, expression);
        if (methodInvoked == null) {
            return false;
        }
        List<Subject> paramsList = getParams(node.arguments());
        detectNullDefect(methodInvoked, paramsList);
        return false;
    }

    private void detectNullDefect(Method methodInvoked, List<Subject> paramsList) {
        boolean anyNullable = paramsList.stream().filter(Objects::nonNull).anyMatch(Subject::isNullable);
        boolean invokedHasNPE = hasNPE(methodInvoked);
        if (invokedHasNPE && anyNullable) {
            if (currentMethod != null && hasNPE(currentMethod)) {
                WordDistanceCalculator.log("", "", methodInvoked.toString(), currentMethod.toString(), "pro potential null defect");
            } else {
                WordDistanceCalculator.log("", "", methodInvoked.toString(), currentMethod == null ? "null" : currentMethod.toString(), "pro potential null defect high");
            }
        }
        List<Parameter> oriParameters = paramsList.stream()
                .filter(subject -> subject instanceof Parameter)
                .map(subject -> (Parameter) subject)
                .collect(Collectors.toList());
        if (currentMethod != null && !hasNPE(currentMethod) && invokedHasNPE && !oriParameters.isEmpty()) {
            for (Parameter parameter : oriParameters) {
                if (parameter.getProperties() != null && !parameter.getProperties().isEmpty()) {
                    Property property = parameter.getProperties().get(0);
                    if (property.getProperty().contains("null")) {
                        WordDistanceCalculator.log("", "", parameter.getId() + "@" + methodInvoked.toString(), currentMethod.toString(), "pro potential missing NPE");
                        break;
                    }
                }
            }
        }

        String returnComment = methodInvoked.getReturnComment();
        if (returnComment != null) {
            Variable retValue = new Variable();
            retValue.setNullable(returnComment.toLowerCase().contains("null"));
            retStack.add(retValue);
        }
    }

    @Override
    public boolean visit(SuperMethodInvocation node) {
        if (currentMethod == null) return false;
        Class currentCls = currentMethod.getCls();
        Class superClass = currentCls.getSuperClass();
        if (superClass == null) return false;
        IMethodBinding iMethodBinding = node.resolveMethodBinding();
        if (iMethodBinding == null) return false;
        Method methodInvoked = superClass.findMethod(iMethodBinding.toString());
        if (methodInvoked == null) return false;
        List<Subject> paramsList = getParams(node.arguments());
        detectNullDefect(methodInvoked, paramsList);
        return super.visit(node);
    }

    @Override
    public boolean visit(SuperConstructorInvocation node) {
        if (currentMethod != null && currentMethod.getCls() != null && currentMethod.getCls().getSuperClass() != null) {
            Method superConstructor = findConstructor(currentMethod.getCls().getSuperClass(), node);
            if (superConstructor == null) return false;
            detectNullDefect(superConstructor, getParams(node.arguments()));
        }
        return super.visit(node);
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
//            ArrayList<Comment> comments = param.getComments();
//            if (!comments.isEmpty()) {
//                String commentText = comments.get(0).getOrigText();
//                param.setNullable(commentText.toLowerCase().contains("null"));
//            } else {
//                param.setNullable(false);
//            }
            if (param.getProperties() != null && !param.getProperties().isEmpty()) {
                Property property = param.getProperties().get(0);
                if (property.getProperty().contains("null")) {
                    param.setNullable(property.isPositivePossibility());
                }
            } else {
                param.setNullable(false);
            }
            retStack.add(param);
        } else if (field != null) {
            field.setNullable(false);
            retStack.add(field);
        } else if (clz != null) {
            clz.setNullable(false);
            retStack.add(clz);
        }
        return false;
    }

    private boolean hasNPE(Method method) {
        List<Comment> exceptions = method.getExceptions();
        boolean npe = exceptions
                .stream()
                .filter(comment -> comment.getOrigText() != null)
                .anyMatch(comment -> comment.getOrigText().toLowerCase().contains("nullpointer"));
        return npe;
    }
}
