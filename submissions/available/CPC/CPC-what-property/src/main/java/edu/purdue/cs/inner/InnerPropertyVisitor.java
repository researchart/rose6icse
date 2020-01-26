package edu.purdue.cs.inner;

import edu.purdue.cs.CodeLists;
import edu.purdue.cs.consistent.UtilVisitor;
import edu.purdue.cs.model.Method;
import edu.purdue.cs.model.Subject;
import edu.purdue.cs.propagate.BranchInfo;
import edu.purdue.cs.util.WordDistanceCalculator;
import org.eclipse.jdt.core.dom.*;
import org.springframework.beans.BeanUtils;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * @author XiangzheXu
 * create-time: 2019-01-28
 */
public class InnerPropertyVisitor extends UtilVisitor {

    private List<BranchInfo> branchConditions = new ArrayList<>();
    private List<InnerPropertyPlaceHolder> innerPropertyList = new ArrayList<>();


    public InnerPropertyVisitor(CodeLists codeLists) {
        super(codeLists);
    }


    @Override
    public boolean visit(VariableDeclarationFragment node) {
        SimpleName variableName = node.getName();
        Expression initializer = node.getInitializer();
        if (initializer != null) {
            Subject variable = tryToVisitAndPop(variableName);
            InnerPropertyPlaceHolder initializerPlaceHolder = tryToGetInnerProperty(initializer);
            if (variable != null && initializerPlaceHolder != null) {
                variable.getInnerProperties().addAll(initializerPlaceHolder.getInnerProperties());
            }
        }
        return false;
    }


    @Override
    public boolean visit(ArrayAccess node) {
        InnerPropertyPlaceHolder arrayProperty = tryToGetInnerProperty(node.getArray());
        InnerPropertyPlaceHolder indexProperty = tryToGetInnerProperty(node.getIndex());
        if (arrayProperty != null && arrayProperty.getInnerProperties().contains(InnerProperty.NULL)) {
            WordDistanceCalculator.log("", "", node + "", currentMethod != null ? currentMethod + "" : "", "what danger nullable invocation");
        }
        if (indexProperty != null && indexProperty.getInnerProperties().contains(InnerProperty.NEGATIVE)) {
            WordDistanceCalculator.log("", "", node + "", currentMethod != null ? currentMethod + "" : "", "what danger range invocation");
        }
        return super.visit(node);
    }

    @Override
    public boolean visit(EnhancedForStatement node) {
        InnerPropertyPlaceHolder iterableProperty = tryToGetInnerProperty(node.getExpression());
        Subject subject = tryToVisitAndPop(node.getParameter().getName());
        if (iterableProperty != null && iterableProperty.getInnerProperties().contains(InnerProperty.NULL)) {
            WordDistanceCalculator.log("", "", node + "", currentMethod != null ? currentMethod + "" : "", "what danger nullable invocation");
        }
        if (subject != null && iterableProperty != null) {
            subject.getInnerProperties().addAll(iterableProperty.getInnerProperties());
        }
        return super.visit(node);
    }

    @Override
    public boolean visit(Assignment node) {
        Expression leftHandSide = node.getLeftHandSide();
        Expression rightHandSide = node.getRightHandSide();
        InnerPropertyPlaceHolder rhsProperty = tryToGetInnerProperty(rightHandSide);
        Subject lhs = tryToVisitAndPop(leftHandSide);
        if (rhsProperty != null && lhs != null) {
            lhs.getInnerProperties().addAll(rhsProperty.getInnerProperties());
            InnerPropertyPlaceHolder placeHolder = new InnerPropertyPlaceHolder();
            placeHolder.setInnerProperties(lhs.getInnerProperties());
            innerPropertyList.add(placeHolder);
        }
        return super.visit(node);
    }



    @Override
    public boolean visit(MethodInvocation node) {
        Subject instance = null;
        if (node.getExpression() != null) {
            instance = tryToVisitAndPop(node.getExpression());
            if (instance != null && renewalSubjectAccordToConditions(instance).getInnerProperties().contains(InnerProperty.NULL)) {
                WordDistanceCalculator.log("", "", node + "", currentMethod != null ? currentMethod + "" : "", "what danger nullable invocation");

            }
        }
        if (instance != null && node.getExpression() != null && node.getExpression().resolveTypeBinding() != null) {
            String typeName = node.getExpression().resolveTypeBinding().getName();
            if (typeName.toLowerCase().replaceAll("\\s", "").contains("iterator")) {
                if (node.getName().toString().toLowerCase().contains("hasnext")) {
                    instance.getInnerProperties().add(InnerProperty.HAS_NEXT);
                } else if (node.getName().toString().toLowerCase().contains("next")) {
                    if (!instance.getInnerProperties().contains(InnerProperty.HAS_NEXT)) {
                        WordDistanceCalculator.log("", "", node + "", currentMethod != null ? currentMethod + "" : "", "what danger iterator invocation");
                    }
                }
            }
        }
        Method methodInvoked = findMethod(node.resolveMethodBinding(), node.getExpression());
        if (methodInvoked == null) return false;

        List<Subject> params = getParams(node.arguments());

        List<Subject> renewedParams = params.stream()
                .filter(Objects::nonNull)
                .map(this::renewalSubjectAccordToConditions)
                .collect(Collectors.toList());

        //if any property, should be has next
        boolean safe = renewedParams.stream()
                .map(Subject::getInnerProperties)
                .flatMap(Collection::stream)
                .noneMatch(innerProperty -> innerProperty.equals(InnerProperty.NEGATIVE));

        if (!safe) {
            WordDistanceCalculator.log("", "", methodInvoked + "", currentMethod != null ? currentMethod + "" : "", "what danger range invocation");
        }


        String methodComment = methodInvoked.getReturnComment();
        if (methodComment == null && !methodInvoked.getComments().isEmpty()) {
            methodComment = methodInvoked.getComments().get(0).getOrigText();
        }
        if (methodComment == null) return false;
        InnerPropertyPlaceHolder placeHolder = new InnerPropertyPlaceHolder();
        boolean negative = methodComment.contains("-1");
        boolean nullable = (methodComment.contains(" null ") && !methodComment.contains(" not "));
//                || methodInvoked.getId().toLowerCase().matches(".*toarray\\(.*\\S+.*\\).*");

        if (negative) {
            placeHolder.getInnerProperties().add(InnerProperty.NEGATIVE);
        }
        if (nullable) {
            placeHolder.getInnerProperties().add(InnerProperty.NULL);
        }
        innerPropertyList.add(placeHolder);
        return false;
    }

    private Subject renewalSubjectAccordToConditions(Subject subject) {
        if (subject == null) return null;
//        Class<? extends Subject> subjectClass = subject.getClass();
//        Subject instance = null;
//        try {
//            instance = subjectClass.newInstance();
//        } catch (InstantiationException e) {
//            e.printStackTrace();
//        } catch (IllegalAccessException e) {
//            e.printStackTrace();
//        }
//        if (instance == null) return subject;
//
//        BeanUtils.copyProperties(subject, instance);
        String subjectId = subject.getId();
        List<String> conditions = branchConditions.stream()
//                .filter(BranchInfo::isThen)
                .map(BranchInfo::getCondition)
                .map(con -> con.replaceAll("\\s", ""))
                .filter(con -> con.contains(subjectId))
                .collect(Collectors.toList());

        for (String condition : conditions) {
            if (condition.contains(">=0") || condition.contains("!=-1") || condition.contains(">-1")) {
                subject.getInnerProperties().remove(InnerProperty.NEGATIVE);
            }
            if (condition.contains("!=null")||condition.contains("==null")||condition.contains("instanceof")) {
                subject.getInnerProperties().remove(InnerProperty.NULL);
            }
        }

        return subject;
    }

    @Override
    public boolean visit(FieldDeclaration node) {

        return super.visit(node);
    }



    @Override
    public boolean visit(SimpleName node) {
        int oriSize = retStack.size();
        super.visit(node);
        Subject subject = null;
        if (oriSize < retStack.size()) {
            subject = retStack.get(retStack.size() - 1);
        }
        if (subject != null) {
            Subject renewalSubject = renewalSubjectAccordToConditions(subject);
            InnerPropertyPlaceHolder placeHolder = new InnerPropertyPlaceHolder();
            placeHolder.setInnerProperties(renewalSubject.getInnerProperties());
            innerPropertyList.add(placeHolder);
        }
        return false;
    }

    @Override
    public boolean visit(InfixExpression node) {
        InfixExpression.Operator operator = node.getOperator();
        boolean relOp = operator.equals(InfixExpression.Operator.CONDITIONAL_AND) || operator.equals(InfixExpression.Operator.CONDITIONAL_OR) || operator.equals(InfixExpression.Operator.NOT_EQUALS)
                || operator.equals(InfixExpression.Operator.EQUALS);
        if (relOp) {
            BranchInfo branchInfo = new BranchInfo();
            branchInfo.setCondition(node.toString());
            branchConditions.add(branchInfo);
        }
        return super.visit(node);
    }

    @Override
    public boolean visit(IfStatement node) {
        Expression condition = node.getExpression();
        BranchInfo branchInfo = new BranchInfo();
        if (condition != null) {
            branchInfo.setCondition(condition.toString());
            branchConditions.add(branchInfo);
            condition.accept(this);
        }

        branchInfo.setThen(true);
        Statement thenStatement = node.getThenStatement();
        if (thenStatement != null) {
            thenStatement.accept(this);
        }
        branchInfo.setThen(false);
        Statement elseStatement = node.getElseStatement();
        if (elseStatement != null) {
            elseStatement.accept(this);
        }
        return false;
    }

    @Override
    public boolean visit(ConditionalExpression node) {
        Expression condition = node.getExpression();
        BranchInfo branchInfo = new BranchInfo();
        if (condition != null) {
            branchInfo.setCondition(condition.toString());
            condition.accept(this);
        }
        branchInfo.setThen(true);
        Expression thenExpression = node.getThenExpression();
        branchConditions.add(branchInfo);
        if (thenExpression != null) {
            thenExpression.accept(this);
        }
        branchInfo.setThen(false);
        Expression elseExpression = node.getElseExpression();
        if (elseExpression != null) {
            elseExpression.accept(this);
        }
        return false;
    }

//    @Override
//    public boolean visit(NullLiteral node) {
//        InnerPropertyPlaceHolder placeHolder = new InnerPropertyPlaceHolder();
//        placeHolder.setInnerProperties(new HashSet<>());
//        placeHolder.getInnerProperties().add(InnerProperty.NULL);
//        innerPropertyList.add(placeHolder);
//        return super.visit(node);
//    }

    private InnerPropertyPlaceHolder tryToGetInnerProperty(ASTNode node) {
        int oriSize = innerPropertyList.size();
        node.accept(this);
        if (oriSize < innerPropertyList.size()) {
            return innerPropertyList.get(innerPropertyList.size() - 1);
        }
        return null;
    }



    @Override
    public boolean visit(WhileStatement node) {
        Expression expression = node.getExpression();
        if (expression != null) {

            BranchInfo branchInfo = new BranchInfo();
            branchInfo.setCondition(expression.toString());
            branchConditions.add(branchInfo);
            expression.accept(this);
            branchInfo.setThen(true);

            Statement body = node.getBody();
            if (body != null) {
                body.accept(this);
            }

            branchConditions.remove(branchInfo);
        }

        return false;
    }

    @Override
    protected Subject tryToVisitAndPop(ASTNode node) {
        int oriSize = innerPropertyList.size();
        Subject subject = super.tryToVisitAndPop(node);
        if (oriSize != 0) {
            innerPropertyList = new ArrayList<>(innerPropertyList.subList(0, oriSize));
        }
        return subject;
    }

    @Override
    public void endVisit(IfStatement node) {
        if (!branchConditions.isEmpty()) {
            branchConditions.remove(branchConditions.size() - 1);
        }
        super.endVisit(node);
    }
}
