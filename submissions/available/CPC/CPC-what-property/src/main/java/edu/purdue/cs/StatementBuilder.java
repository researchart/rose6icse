package edu.purdue.cs;

import edu.purdue.cs.model.Class;
import edu.purdue.cs.model.Method;
import edu.purdue.cs.model.Statement;
import org.eclipse.jdt.core.dom.*;

import java.util.List;
import java.util.Stack;

/**
 * this class will add
 * statement model to the code list
 *
 * @author XiangzheXu
 * create-time: 2019/7/7
 */
public class StatementBuilder extends ASTVisitor {
    private CodeLists codeLists;
    private Stack<Statement> statementStack = new Stack<>();

    private Stack<Method> currentMethod = new Stack<>();

    private Stack<Class> currentClass = new Stack<>();
    private Stack<Boolean> methodLevelBlock = new Stack<>();


    public StatementBuilder(CodeLists codeLists) {
        this.codeLists = codeLists;
    }

    @Override
    public boolean visit(TypeDeclaration node) {
        String clzName = node.resolveBinding().getName();
        Class clz = codeLists.findClass(clzName);
        if (clz == null) {
//            System.err.println("@StmtBuilder Current Clz not found!" + clzName);

        }
        currentClass.push(clz);
        return super.visit(node);
    }


    @Override
    public void endVisit(TypeDeclaration node) {
        currentClass.pop();
        super.endVisit(node);
    }

    @Override
    public boolean visit(MethodDeclaration node) {
        IMethodBinding iMethodBinding = node.resolveBinding();
        Method method = null;
        if (iMethodBinding != null) {
            String methodName = iMethodBinding.toString();
            Class curClz = currentClass.peek();
            if(curClz!=null) method = curClz.findMethod(methodName);
            if (method == null) {
//                System.err.println("@StmtBuilder Current Method not found!" + methodName);
            }
        }
        currentMethod.push(method);
        methodLevelBlock.push(true);
        return method != null;
    }

    @Override
    public void endVisit(MethodDeclaration node) {
        methodLevelBlock.pop();

        if (statementStack.empty()) {
            return;
        }

        if (currentMethod.peek() != null) {
            Statement blk = statementStack.pop();
            currentMethod.peek().setBlock(blk);
        }

        currentMethod.pop();
        super.endVisit(node);
    }

    @Override
    public boolean visit(AssertStatement node) {

        return super.visit(node);
    }

    @Override
    public boolean visit(Block node) {
        if (!methodLevelBlock.empty() && methodLevelBlock.peek()) {
            methodLevelBlock.pop();
            methodLevelBlock.push(false);

//            assert statementStack.empty();
            Statement statement = new Statement(node);
            statementStack.push(statement);
            return true;
        } else {
            Statement statement = new Statement(node);
            statementStack.push(statement);
            List<org.eclipse.jdt.core.dom.Statement> statements = node.statements();
            for (org.eclipse.jdt.core.dom.Statement stmt : statements) {
                stmt.accept(this);
            }
            Statement myself = statementStack.pop();
            assert myself == statement;
            if (!statementStack.empty()) {
                statementStack.peek().getStatements().add(myself);
            }

            return false;
        }
    }

    @Override
    public boolean visit(BreakStatement node) {
        Statement statement = new Statement(node);
        statementStack.peek().getStatements().add(statement);
        return super.visit(node);
    }

    @Override
    public boolean visit(ConstructorInvocation node) {
        Statement statement = new Statement(node);
        statementStack.peek().getStatements().add(statement);
        return super.visit(node);
    }

    @Override
    public boolean visit(ContinueStatement node) {
        Statement statement = new Statement(node);
        statementStack.peek().getStatements().add(statement);
        return super.visit(node);
    }

    @Override
    public boolean visit(DoStatement node) {
        Statement statement = new Statement(node);
        statementStack.push(statement);
        node.getBody().accept(this);
        Statement myself = statementStack.pop();
        assert statement == myself;
        statementStack.peek().getStatements().add(myself);
        return false;
    }

    @Override
    public boolean visit(EmptyStatement node) {
        Statement statement = new Statement(node);
        statementStack.peek().getStatements().add(statement);
        return super.visit(node);
    }

    @Override
    public boolean visit(EnhancedForStatement node) {
        Statement statement = new Statement(node);
        statementStack.push(statement);
        node.getBody().accept(this);
        Statement myself = statementStack.pop();
        assert statement == myself;
        statementStack.peek().getStatements().add(myself);
        return false;
    }

    @Override
    public boolean visit(ExpressionStatement node) {
        Statement statement = new Statement(node);
        statementStack.peek().getStatements().add(statement);
        return super.visit(node);
    }

    @Override
    public boolean visit(ForStatement node) {
        Statement statement = new Statement(node);
        statementStack.push(statement);
        node.getBody().accept(this);
        Statement myself = statementStack.pop();
        assert statement == myself;
        statementStack.peek().getStatements().add(myself);
        return false;
    }

    @Override
    public boolean visit(IfStatement node) {
        Statement statement = new Statement(node);
        statementStack.push(statement);
        node.getThenStatement().accept(this);
        if (node.getElseStatement() != null) {
            node.getElseStatement().accept(this);
        }
        Statement myself = statementStack.pop();
        assert statement == myself;
        statementStack.peek().getStatements().add(myself);
        return false;
    }

    @Override
    public boolean visit(LabeledStatement node) {
        Statement statement = new Statement(node);
        statementStack.peek().getStatements().add(statement);
        return super.visit(node);
    }

    @Override
    public boolean visit(ReturnStatement node) {
        Statement statement = new Statement(node);
        statementStack.peek().getStatements().add(statement);
        return super.visit(node);
    }

    @Override
    public boolean visit(SuperConstructorInvocation node) {
        Statement statement = new Statement(node);
        statementStack.peek().getStatements().add(statement);
        return super.visit(node);
    }

    @Override
    public boolean visit(SwitchCase node) {
        Statement statement = new Statement(node);
        statementStack.peek().getStatements().add(statement);
        return super.visit(node);
    }

    @Override
    public boolean visit(SwitchStatement node) {
        Statement statement = new Statement(node);
        statementStack.push(statement);
        List<org.eclipse.jdt.core.dom.Statement> statements = node.statements();
        statements.forEach(stmt -> stmt.accept(this));
        Statement myself = statementStack.pop();
        assert statement == myself;
        statementStack.peek().getStatements().add(myself);

        return false;
    }

    @Override
    public boolean visit(SynchronizedStatement node) {
        Statement statement = new Statement(node);
        statementStack.push(statement);
        node.getBody().accept(this);
        Statement myself = statementStack.pop();
        assert statement == myself;
        statementStack.peek().getStatements().add(myself);
        return false;
    }

    @Override
    public boolean visit(ThrowStatement node) {
        Statement statement = new Statement(node);
        statementStack.peek().getStatements().add(statement);
        return super.visit(node);
    }

    @Override
    public boolean visit(TryStatement node) {
        Statement statement = new Statement(node);
        statementStack.push(statement);
        node.getBody().accept(this);
        Statement myself = statementStack.pop();
        assert statement == myself;
        statementStack.peek().getStatements().add(myself);
        return false;
    }

    @Override
    public boolean visit(TypeDeclarationStatement node) {
//        Statement statement = new Statement(node);
//        statementStack.peek().getStatements().add(statement);
        return false;
    }

    @Override
    public boolean visit(VariableDeclarationStatement node) {
        Statement statement = new Statement(node);
        statementStack.peek().getStatements().add(statement);
        return super.visit(node);
    }

    @Override
    public boolean visit(WhileStatement node) {
        Statement statement = new Statement(node);
        statementStack.push(statement);
        node.getBody().accept(this);
        Statement myself = statementStack.pop();
        assert statement == myself;
        statementStack.peek().getStatements().add(myself);
        return super.visit(node);
    }

}
