package edu.purdue.cs.consistent;

import edu.purdue.cs.CodeLists;
import edu.purdue.cs.model.Class;
import edu.purdue.cs.model.Comment;
import edu.purdue.cs.model.*;
import edu.purdue.cs.util.WordDistanceCalculator;
import org.eclipse.jdt.core.dom.*;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author XiangzheXu
 * create-time: 2019-01-16
 */
public class ExceptionVisitor extends UtilVisitor {

    public ExceptionVisitor(CodeLists codeLists) {
        super(codeLists);
    }


    @Override
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
            boolean hasOriParam = ((List<ASTNode>) node.arguments()).stream()
                    .map(this::tryToVisitAndPop)
                    .anyMatch(this::fromParam);
            if (hasOriParam) {
                propagateExceptions(currentMethod, methodInvoked);
            }
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
                if (currentMethod != null) {
                    propagateExceptions(currentMethod, constructorInvoked);
                }
            }
        }
        return super.visit(node);
    }


    private boolean fromParam(Subject subject) {
        if (subject instanceof Parameter) {
            return true;
        }
        if (subject instanceof Variable) {
            return ((Variable) subject).isFromParam();
        }
        return false;
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

        propagateExceptions(currentMethod, methodInvoked);

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
            retStack.add(param);
        } else if (field != null) {
            retStack.add(field);
        } else if (clz != null) {
            retStack.add(clz);
        }
        return false;
    }


    private void propagateExceptions(Method caller, Method callee) {
        if (caller == null || callee == null) return;
        //TODO this method can be optimized
        List<Comment> aExceptions = caller.getExceptions();
        List<Comment> bExceptions = callee.getExceptions();
        //both a and b do not throw anything
        if (aExceptions.size() + bExceptions.size() == 0) return;

        for (Comment commentInA : aExceptions) {
            boolean match = false;
            for (Comment commentInB : bExceptions) {
                if (equal(commentInA, commentInB)) {
                    refineBound(commentInA, commentInB, caller, callee);
                    WordDistanceCalculator.log(commentInA.getOrigText(), commentInB.getOrigText(), caller.toString(), callee.toString(), "pro Excpt similarity");
                    match = true;
                    break;
                }
            }//end of inner for loop

            if (!match) {
                WordDistanceCalculator.log(commentInA.getOrigText(), "", caller.toString(), callee.toString(), "pro Excpt caller->callee");
            }
        }


        for (Comment commentInB : bExceptions) {
            boolean match = false;
            for (Comment commentInA : aExceptions) {
                if (equal(commentInB, commentInA)) {
                    WordDistanceCalculator.log(commentInA.getOrigText(), commentInB.getOrigText(), caller.toString(), callee.toString(), "pro Excpt similarity");
                    match = true;
                    break;
                }
            }//end of inner for loop

            if (!match) {
                caller.getExceptions().add(commentInB);
                WordDistanceCalculator.log(commentInB.getOrigText(), "", callee.toString(), caller.toString(), "pro Excpt callee->caller");
            }
        }


    }

    private void refineBound(Comment a, Comment b, Method aMethod, Method bMethod) {
        final String SEP = "::";
        String textA = a.getOrigText();
        String textB = b.getOrigText();
        if (textA == null || textB == null) return;
        String exceptionA = getException(textA);
        String exceptionB = getException(textB);
        if (exceptionA.toLowerCase().contains("outofbound") && exceptionB.contains("outofbound")) {
            if (!checkRange(textA, textB)) {
                WordDistanceCalculator.log(textA, textB, bMethod.toString(), aMethod.toString(), "pro Excpt range");
            }
            if (textA.contains("invalid") && !textB.contains("invalid") && !textA.contains(SEP)) {
                WordDistanceCalculator.log(textA, textB, bMethod.toString(), aMethod.toString(), "pro Excpt refine bound");
                a.setOrigText(a.getOrigText() + SEP + b.getOrigText());
            } else if (!textA.contains("invalid") && textB.contains("invalid") && !textB.contains(SEP)) {
                WordDistanceCalculator.log(textB, textA, aMethod.toString(), bMethod.toString(), "pro Excpt refine bound");
                b.setOrigText(b.getOrigText() + SEP + a.getOrigText());
            }
        }
    }

    /**
     * check the range of two exceptions
     *
     * @param a description of a
     * @param b description of b
     */
    private boolean checkRange(String a, String b) {
        String[] range = {
                "&gt;", "&gt;=", "&lt;", "&lt;=", "==", "!=",
                ">", ">=", "<", "<=", "==", "!="
        };
        int aContains = 0, bContains = 0;
        for (int i = 0; i < range.length; i++) {
            if (a.contains(range[i])) {
                aContains |= 1 << i;
            }
            if (b.contains(range[i])) {
                bContains |= 1 << i;
            }
        }
        return aContains * bContains == 0 || ((aContains ^ bContains) == 0);

    }

    private boolean equal(Comment a, Comment b) {
        String origTextA = a.getOrigText();
        String exceptionA = getException(origTextA);
        String origTextB = b.getOrigText();
        String exceptionB = getException(origTextB);
        return a.getTag().equals(b.getTag()) && exceptionA.equals(exceptionB);
    }

    private String getException(String origText) {
        String oriTextWithLeadingSpace = " " + origText;
        Matcher exceptionMatcher = Pattern.compile(".* ([a-zA-Z]+Exception).*").matcher(oriTextWithLeadingSpace);
        if (exceptionMatcher.matches()) {
            String exception = exceptionMatcher.group(1);
            return exception.trim().toLowerCase();
        }
        int firstWordBoundary = origText.trim().indexOf(" ");
        return origText.substring(0, firstWordBoundary >= 0 ? firstWordBoundary : origText.length());
    }

}
