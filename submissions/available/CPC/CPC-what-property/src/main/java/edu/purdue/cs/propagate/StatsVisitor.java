package edu.purdue.cs.propagate;

import edu.purdue.cs.CodeLists;
import edu.purdue.cs.model.Class;
import edu.purdue.cs.model.Comment;
import edu.purdue.cs.model.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.eclipse.jdt.core.dom.*;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;

import static edu.purdue.cs.ProjectPropagator.PROJECT_NAME;


/**
 * @author XiangzheXu
 * create-time: 2018/12/20
 */

@EqualsAndHashCode(callSuper = true)
@Data
public class StatsVisitor extends ASTVisitor {
    public static int cnt;
    //    private static File statLog = new File("statsLog_" + PROJECT_NAME + ".csv");
    private static File statLog = new File("statsLog_" + "all" + ".csv");
    private static PrintWriter writer;

    static {
        try {
            if (!statLog.exists()) {
                statLog.createNewFile();
            }
            writer = new PrintWriter(new FileOutputStream(statLog));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * use this stack to return values from visit method
     * if there is no value to return, the size of this stack must not change
     */
    private ArrayList<Subject> retStack = new ArrayList<>();

    private CodeLists codeLists;

    private Method currentMethod;

    /**
     * whether or not we're visiting a branch node
     */
    private boolean branch;

    private BranchInfo branchInfo;

    private boolean analysisReturn;


    @Override
    public boolean visit(MethodDeclaration node) {
        IMethodBinding binding = node.resolveBinding();
        if (binding == null) {
            return false;
        }
        if (node.getParent() instanceof TypeDeclaration) {
            TypeDeclaration parent = ((TypeDeclaration) node.getParent());
            Class methodClass = codeLists.findClass(parent.getName().toString());
            if (methodClass != null) {
                currentMethod = methodClass.findMethod(binding.toString());
                if (currentMethod != null) {
                    if (!currentMethod.getExceptions().isEmpty() && !currentMethod.getExceptions().get(0).getOrigText().isEmpty()) {
                        String[] toWrite = {
                                PROJECT_NAME, "method with excpt", String.valueOf(currentMethod.getExceptions().size()), currentMethod.getCls().toString(), currentMethod.getId().replace(",", ";")
                        };
                        writer.println(String.join(",", toWrite));
                    }
                    if (!currentMethod.getParamList().isEmpty()) {
                        long paramHasComment = currentMethod.getParamList().stream().filter(Subject::isHasComment).count();
                        String[] toWrite = {
                                PROJECT_NAME, "method with param", String.valueOf(paramHasComment), currentMethod.getCls().toString(), currentMethod.getId().replace(",", ";")
                        };
                        writer.println(String.join(",", toWrite));

                    }
                    String[] toWrite = {
                            PROJECT_NAME, "method record", String.valueOf(calculateMethodComment(currentMethod)), currentMethod.getCls().toString(), currentMethod.getId().replace(",", ";")
                    };
                    writer.println(String.join(",", toWrite));
                    writer.flush();
                }
//                return currentMethod != null;
                return false;
            }
        }
        return false;
    }

    private int calculateMethodComment(Method method) {
        int ret = 0;
        if (method.getReturnComment() != null) {
            ret++;
        }
        if (method.isHasComment()) {
            ret++;
        }
        return ret;
    }

    @Override
    public void endVisit(MethodDeclaration node) {
        super.endVisit(node);
        currentMethod = null;
    }

    @Override
    public boolean visit(Block node) {
        return true;
    }

    @Override
    public boolean visit(Assignment node) {
//        Expression LHS = node.getLeftHandSide();
//        Expression RHS = node.getRightHandSide();
//        //pop the return value
//        Subject rhsSubject = tryToVisitAndPop(RHS);
//
//        Subject lhsSubject = tryToVisitAndPop(LHS);
//
//        if (rhsSubject == null || lhsSubject == null) {
//            return false;
//        }
//        propagateBetweenVars(lhsSubject, rhsSubject);
//        retStack.add(rhsSubject);
        return true;
    }


    @Override
    public void endVisit(ReturnStatement node) {
        analysisReturn = false;
    }

    @Override
    public boolean visit(NullLiteral node) {
//        Comment comment = new Comment();
//        comment.setOrigText("NULL");
//        SysComment sysComment = new SysComment();
//        sysComment.setComments(new ArrayList<>(Collections.singletonList(comment)));
//        retStack.add(sysComment);
        return true;
    }

    @Override
    public boolean visit(ArrayAccess node) {
//        Expression array = node.getArray();
//        Subject arraySubject = tryToVisitAndPop(array);
//        retStack.add(arraySubject);
        return true;
    }

    @Override
    public boolean visit(BooleanLiteral node) {
//        Variable variable = new Variable();
//        edu.purdue.cs.model.Comment comment = new edu.purdue.cs.model.Comment();
//        comment.setOrigText(node.booleanValue() ? "True" : "False");
//        variable.setComments(new ArrayList<>(Collections.singletonList(comment)));
//        retStack.add(variable);
        return true;
    }

    @Override
    public boolean visit(ReturnStatement node) {
//        analysisReturn = true;
//        Expression retExpression = node.getExpression();

//        currentMethod.getComments()
        return true;
    }


    @Override
    public boolean visit(IfStatement node) {
//        branch = true;
//        BranchInfo info = new BranchInfo();
//        info.setCondition(node.getExpression().toString());
//        info.setThen(true);
//        this.branchInfo = info;
//        tryToVisitAndPop(node.getThenStatement());
//
//        //to deal with nested branch
//        branch = true;
//        BranchInfo updateInfo = new BranchInfo();
//        updateInfo.setCondition(node.getExpression().toString());
//        updateInfo.setThen(false);
//        Statement elseStatement = node.getElseStatement();
//
//        if (elseStatement != null) {
//            tryToVisitAndPop(elseStatement);
//        }
//
//        this.branchInfo = null;
//        branch = false;
        return true;
    }


    @Override
    public boolean visit(FieldAccess node) {
//        Subject clz = tryToVisitAndPop(node.getExpression());
//
//        if (clz instanceof Class) {
//            String fieldName = node.resolveFieldBinding().getName();
//            Field field = ((Class) clz).findField(fieldName);
//            if (field != null) {
//                retStack.add(field);
//            }
//            return false;
//        }
//        return false;
        return true;
    }

    @Override
    public boolean visit(ThisExpression thisExpression) {
//        Name optionalQualifier = thisExpression.getQualifier();
//        if (optionalQualifier != null) {
//            Class qualifierClass = codeLists.findClass(optionalQualifier.toString());
//            if (qualifierClass != null) {
//                retStack.add(qualifierClass);
//                return false;
//            }
//        }
//        retStack.add(currentMethod.getCls());
        return true;
    }


    @Override
    public boolean visit(ArrayCreation node) {
//        edu.purdue.cs.model.Comment comment = new edu.purdue.cs.model.Comment();
//        comment.setOrigText("a new array of type " + node.getType().toString());
//        SysComment generatedComment = new SysComment();
//        generatedComment.setComments(new ArrayList<>(Collections.singletonList(comment)));
//        retStack.add(generatedComment);
        return false;
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

    @Override
    public boolean visit(SuperMethodInvocation node) {
        if (currentMethod == null || node.resolveMethodBinding() == null) return true;
        Class cls = currentMethod.getCls();
        if (cls == null) return true;
        Class superClass = cls.getSuperClass();
        Method method = findMethod(node.resolveMethodBinding().toString(), superClass);
        if (canPropagate(method)) {
            cnt++;
        }

        return true;
    }

    private boolean canPropagate(Method method) {
        return (method != null) && (method.isHasComment() || (method.getReturnComment() != null && !method.getReturnComment().isEmpty()));
    }

    private Method findMethod(String methodId, Class clz) {
        if (clz == null) return null;

        return clz.findMethod(methodId);
    }

    @Override
    public boolean visit(MethodInvocation node) {
        Expression expression = node.getExpression();
        Method method = null;
        if (expression != null && expression.resolveTypeBinding() != null) {
            String clzName = expression.resolveTypeBinding().getName();
            Class methodClass = codeLists.findClass(clzName);
            if (node.resolveMethodBinding() != null) {
                method = findMethod(node.resolveMethodBinding().toString(), methodClass);
            }
        } else if (currentMethod != null && node.resolveMethodBinding() != null) {
            method = findMethod(node.resolveMethodBinding().toString(), currentMethod.getCls());
        }
        if (method == null) return true;

        if (canPropagate(method)) {
            cnt++;
        }


//        Subject classSubject = null;
//        Expression methodClass = node.getExpression();
//        if (methodClass != null) {
//            classSubject = tryToVisitAndPop(methodClass);
//        } else {
//            //that means this method is a private method of this class
//            classSubject = currentMethod.getCls();
//        }
//
//        if (classSubject instanceof Class) {
//            SimpleName methodName = node.getName();
//            IBinding methodBinding = methodName.resolveBinding();
//            if (methodBinding == null) {
//                return false;
//            }
//            Method methodInvoked = ((Class) classSubject).findMethod(methodBinding.toString());
//            if (methodInvoked != null && methodInvoked.getReturnCommentToMatch() != null) {
//                SysComment sysComment = new SysComment();
//                Comment comment = new Comment();
//
//
//                sysComment.setComments(new ArrayList<>(Collections.singletonList(comment)));
//                retStack.add(sysComment);
//                System.out.println("Method invocation success parsed!");
//                return false;
//            }
//        }
//        //TODO: propagate method return statement
        return true;
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

    /**
     * propagate from var src to var target
     */
    private void propagateBetweenVars(Subject target, Subject src) {
//        if (!branch) {
        ArrayList<Comment> oriComments = target.getComments();
        if (target.isHasComment()) {
            Comment firstComment = oriComments.get(0);
            for (Comment generatedComment : src.getComments()) {
//                double distance = WordDistanceCalculator.calDistance(firstComment.getOrigText(), generatedComment.getOrigText(), "assignment");
            }

        }
        oriComments.addAll(src.getComments());
//        } else {
//            if (branchInfo.isThen()) {
//                ArrayList<edu.purdue.cs.model.Comment> comments = new ArrayList<>();
//                for (edu.purdue.cs.model.Comment srcComment : src.getComments()) {
//                    edu.purdue.cs.model.Comment targetComment = new edu.purdue.cs.model.Comment();
//                    BeanUtils.copyProperties(srcComment, targetComment);
//                    targetComment.setOrigText(branchInfo.getCondition() + srcComment.getOrigText());
//
//                    comments.add(targetComment);
//                }
//                target.getComments().addAll(comments);
//            } else {
//                ArrayList<edu.purdue.cs.model.Comment> comments = new ArrayList<>();
//                for (edu.purdue.cs.model.Comment srcComment : src.getComments()) {
//                    edu.purdue.cs.model.Comment targetComment = new Comment();
//                    BeanUtils.copyProperties(srcComment, targetComment);
//                    targetComment.setOrigText("Not " + branchInfo.getCondition() + srcComment.getOrigText());
//
//                    comments.add(targetComment);
//                }
//                target.getComments().addAll(comments);
//            }
//        }
        System.out.println("I propagateBetweenVars the comment of [" + src + "] to [" + target + "]");
    }
}

