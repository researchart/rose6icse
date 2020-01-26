package edu.purdue.cs.propagator;

import edu.purdue.cs.CodeLists;
import edu.purdue.cs.model.Class;
import edu.purdue.cs.model.*;
import org.eclipse.jdt.core.dom.*;

/**
 * Description:
 * Find the related model object
 * from the name by the original ASTNode
 *
 * @author xxz
 * Created on 2019-07-14
 */
public class NameFinder extends ASTVisitor {
    private CodeLists codeLists;
    private Class currentClass;
    private Method currentMethod;
    private Subject result;

    public NameFinder(CodeLists codeLists, Class currentClass, Method currentMethod) {
        this.codeLists = codeLists;
        this.currentClass = currentClass;
        this.currentMethod = currentMethod;
    }

    public Subject getResult() {
        return result;
    }


    @Override
    public boolean visit(SimpleName node) {
        String identifier = node.getIdentifier();
        Parameter param = currentMethod.findParam(identifier);
        if (param != null) {
            result = param;
            return false;
        }

        Variable var = currentMethod.findVar(identifier);
        if (var != null) {
            result = var;
            return false;
        }

        Field field = currentClass.findField(identifier);
        if (field != null) {
            result = field;
            return false;
        }

        return super.visit(node);
    }


    @Override
    public boolean visit(BooleanLiteral node) {
        return super.visit(node);
    }

    @Override
    public boolean visit(CharacterLiteral node) {
        return super.visit(node);
    }

    @Override
    public boolean visit(NullLiteral node) {
        return super.visit(node);
    }


    @Override
    public boolean visit(NumberLiteral node) {
        return super.visit(node);
    }


    @Override
    public boolean visit(StringLiteral node) {
        return super.visit(node);
    }


    @Override
    public boolean visit(TypeLiteral node) {
        return super.visit(node);
    }
}
