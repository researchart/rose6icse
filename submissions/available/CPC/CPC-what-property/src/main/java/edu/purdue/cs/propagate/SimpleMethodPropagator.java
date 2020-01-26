package edu.purdue.cs.propagate;

import edu.purdue.cs.CodeLists;
import edu.purdue.cs.model.Class;
import edu.purdue.cs.model.Comment;
import edu.purdue.cs.model.*;
import edu.purdue.cs.util.AllFalseVisitor;
import edu.purdue.cs.util.WordDistanceCalculator;
import org.eclipse.jdt.core.dom.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * @author XiangzheXu
 * create-time: 2019-01-11
 */
public class SimpleMethodPropagator extends AllFalseVisitor {
    private CodeLists codeLists;
    private Method currentMethod;
    private boolean analyzeReturn;
    private ArrayList<Subject> retStack = new ArrayList<>();
    //to solve cases like return A(B())
    private boolean firstMethodInvoke;

    public SimpleMethodPropagator(CodeLists codeLists) {
        this.codeLists = codeLists;
    }


    @Override
    public boolean visit(ArrayAccess node) {
        if (analyzeReturn) {
            Subject arrayExpression = tryToVisitAndPop(node.getArray());
            if (arrayExpression != null && currentMethod.getReturnComment() != null) {
                addNewCommentFromReturn(arrayExpression);
            }
        }
        return false;
    }

    /**
     * add the return comment of current method to the
     * subject to return
     *
     * @param subject subject to return
     */
    private void addNewCommentFromReturn(Subject subject) {
        assert subject != null;
        Comment comment = new Comment();
        comment.setOrigText(currentMethod.getReturnComment());
        if (subject.isHasComment()) {
            Comment oriComment = subject.getComments().get(0);
//            WordDistanceCalculator.calDistance(oriComment.getOrigText(), comment.getOrigText());
            WordDistanceCalculator.log(comment.getOrigText(), oriComment.getOrigText(), nameUtil(currentMethod), subject.toString(), "what method->return subject");
        }
        subject.getComments().add(comment);
    }

    private String nameUtil(Method method) {
        Class clz = method.getCls();
        return clz.getId() + "." + method.getId();
    }

    @Override
    public boolean visit(FieldAccess node) {
        Subject clz = tryToVisitAndPop(node.getName());
        if (clz instanceof Class) {
            Field field = ((Class) clz).findField(node.resolveFieldBinding().getName());
            if (field != null) {
                addNewCommentFromReturn(field);
            }
        }

        return false;
    }


    @Override
    public boolean visit(Block node) {
        return true;
    }

    @Override
    public boolean visit(CompilationUnit node) {
        return true;
    }

    @Override
    public boolean visit(ParenthesizedExpression node) {
        return true;
    }


    @Override
    public boolean visit(MethodInvocation node) {
        Expression methodClassName = node.getExpression();
        IMethodBinding iMethodBinding = node.resolveMethodBinding();
        if (analyzeReturn) {
            if (iMethodBinding != null) {

                Method methodInvoked = null;
                if (methodClassName == null) {
                    methodInvoked = parseMethod(iMethodBinding.toString());
                } else {
                    Class methodClass = codeLists.findClass(methodClassName.toString());
                    if (methodClass != null) {
                        methodInvoked = methodClass
                                .findMethod(iMethodBinding.toString());
                    }
                }
                if (methodInvoked != null) {
                    boolean tmp = firstMethodInvoke;
                    firstMethodInvoke = false;
                    List<Subject> paramsList = ((List<ASTNode>) node.arguments())
                            .stream()
                            .map(this::tryToVisitAndPop)
                            .collect(Collectors.toList());
                    instantiateReturnComment(methodInvoked, paramsList);
                    firstMethodInvoke = tmp;
                    if (firstMethodInvoke) {
                        propagate(methodInvoked);
                        firstMethodInvoke = false;
                    }
                }
            }
        }
        return false;
    }

    @Override
    public boolean visit(SuperMethodInvocation node) {
        IMethodBinding iMethodBinding = node.resolveMethodBinding();
        if (analyzeReturn) {
            if (iMethodBinding != null) {
                Class cls = currentMethod.getCls();
                Class superClass = cls.getSuperClass();
                Method methodInvoked = null;
                if (superClass != null) {
                    methodInvoked = superClass.findMethod(iMethodBinding.toString());
                }

                if (methodInvoked == null) {
                    return false;
                }
                boolean tmp = firstMethodInvoke;
                firstMethodInvoke = false;
                List<Subject> paramsList = ((List<ASTNode>) node.arguments())
                        .stream()
                        .map(this::tryToVisitAndPop)
                        .collect(Collectors.toList());

                instantiateReturnComment(methodInvoked, paramsList);
                firstMethodInvoke = tmp;
                if (firstMethodInvoke) {
                    propagate(methodInvoked);
                    firstMethodInvoke = false;
                }
            }
        }

        return super.visit(node);
    }

    private void instantiateReturnComment(Method methodInvoked, List<Subject> paramsList) {
        Map<Integer, String> paramMap = new HashMap<>();

        for (int i = 0; i < paramsList.size(); i++) {
            if (paramsList.get(i) != null) {
                ArrayList<Comment> comments = paramsList.get(i).getComments();
                if (!comments.isEmpty()) {
                    paramMap.put(i + 1, comments.get(0).getOrigText());
                    continue;
                }
            }
            paramMap.put(i, null);
        }
        RawComment returnCommentToMatch = methodInvoked.getReturnCommentToMatch();
        if (returnCommentToMatch != null) {
            String commentInstance = returnCommentToMatch.buildComment(paramMap);
            methodInvoked.setRetCommentInstance(commentInstance);
        }
    }

    private void propagate(Method methodInvoked) {
        if (methodInvoked == null) {
            return;
        }

        //propagate the describe comment
        //TODO: whether propagate the acquired comment ?
        if (methodInvoked.isHasComment()) {
            Comment invokedComment = methodInvoked.getComments().get(0);
            String invokedCommentOrigText = invokedComment.getOrigText();
            String currentMethodCommentText;
            if (currentMethod.isHasComment()) {
                currentMethodCommentText = currentMethod.getComments().get(0).getOrigText();
                WordDistanceCalculator.log(invokedCommentOrigText, currentMethodCommentText, nameUtil(methodInvoked), nameUtil(currentMethod), "what desc callee->caller");
            } else {
                currentMethod.getComments().add(invokedComment);
                WordDistanceCalculator.log(invokedCommentOrigText, "", nameUtil(methodInvoked), nameUtil(currentMethod), "what desc callee->caller(null)");
            }
        }

        //
        if (paramsEqual(methodInvoked, currentMethod) && currentMethod.isHasComment()) {
            Comment oriComments = currentMethod.getComments().get(0);
            String origText = oriComments.getOrigText();
            if (methodInvoked.isHasComment()) {
                String invoked = methodInvoked.getComments().get(0).getOrigText();
                WordDistanceCalculator.log(origText, invoked, nameUtil(currentMethod), nameUtil(methodInvoked), "what desc caller->callee");
            } else {
                WordDistanceCalculator.log(origText, "", nameUtil(currentMethod), nameUtil(methodInvoked), "what desc caller->callee(null)");
            }
        }
        propagateReturnComments(methodInvoked);

    }

    private void propagateReturnComments(Method methodInvoked) {
        //propagate of the return comments
        if ((methodInvoked.getReturnComment() == null || methodInvoked.getReturnComment().isEmpty())
                && currentMethod.getReturnComment() != null) {
            //if the method invoked do not have comments
            methodInvoked.setReturnComment(currentMethod.getReturnComment());
            methodInvoked.setReturnCommentToMatch(currentMethod.getReturnCommentToMatch());
            WordDistanceCalculator.log(currentMethod.getReturnComment(), "", nameUtil(currentMethod), nameUtil(methodInvoked), "what ret simpleMethod(null)");
        } else if ((currentMethod.getReturnComment() == null || currentMethod.getReturnComment().isEmpty())
                && methodInvoked.getReturnComment() != null) {
            //if the current method do not have comments
            currentMethod.setReturnComment(methodInvoked.getReturnComment());
            currentMethod.setReturnCommentToMatch(methodInvoked.getReturnCommentToMatch());
            WordDistanceCalculator.log(methodInvoked.getReturnComment(), "", nameUtil(methodInvoked), nameUtil(currentMethod), "what ret simpleMethod(null)");
        } else {
            //if both sides have return comments

            //from caller to callee
            if (paramsEqual(currentMethod, methodInvoked)) {
                WordDistanceCalculator.log(currentMethod.getReturnComment(), methodInvoked.getReturnComment(), nameUtil(currentMethod), nameUtil(methodInvoked), "what ret caller->callee");
            }
            //from callee to caller
            if (currentMethod.getRetCommentInstance() != null) {
                WordDistanceCalculator.log(methodInvoked.getRetCommentInstance(), currentMethod.getReturnComment(), nameUtil(methodInvoked), nameUtil(currentMethod), "what ret callee->caller");
                WordDistanceCalculator.calDistance(methodInvoked.getRetCommentInstance(), currentMethod.getReturnComment());
            } else {
                WordDistanceCalculator.log(methodInvoked.getReturnComment(), currentMethod.getReturnComment(), nameUtil(methodInvoked), nameUtil(currentMethod), "what ret callee->caller");
                WordDistanceCalculator.calDistance(methodInvoked.getReturnComment(), currentMethod.getReturnComment());
            }
        }
    }

    private boolean paramsEqual(Method a, Method b) {
        ArrayList<Parameter> callerParamList = a.getParamList();
        ArrayList<Parameter> calleeParamList = b.getParamList();
        return calleeParamList.size() == callerParamList.size();
    }

    private Method parseMethod(String methodBinding) {
        Class currentMethodCls = currentMethod.getCls();
        return currentMethodCls.findMethod(methodBinding);
    }

    @Override
    public boolean visit(InfixExpression node) {
        return false;
    }

    @Override
    public boolean visit(MethodDeclaration node) {
        IMethodBinding binding = node.resolveBinding();
        if (binding == null) {
            return false;
        }
        TypeDeclaration parent = ((TypeDeclaration) node.getParent());
        Class methodClass = codeLists.findClass(parent.getName().toString());
        if (methodClass == null) return false;
        currentMethod = methodClass.findMethod(binding.toString());
        return currentMethod != null && currentMethod.isEasyToPropagate();
    }

    @Override
    public void endVisit(MethodDeclaration node) {
        currentMethod = null;
    }

    @Override
    public boolean visit(ReturnStatement node) {
        if (currentMethod == null) return false;
        analyzeReturn = currentMethod.isEasyToPropagate();
        firstMethodInvoke = true;
        return true;
    }

    @Override
    public void endVisit(ReturnStatement node) {
        analyzeReturn = false;
        firstMethodInvoke = true;
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

    private Subject tryToVisitAndPop(ASTNode node) {
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


}
