package edu.purdue.cs.model;

import lombok.Data;
import org.eclipse.jdt.core.dom.ASTNode;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Data
public class Method extends Subject {
    private ArrayList<Parameter> paramList = new ArrayList<Parameter>();
    private ArrayList<Variable> varList = new ArrayList<Variable>();
    private Class cls;
    private String retType;
    private String returnComment;
    private List<Constrain> methodConstrains = new ArrayList<>();
    private Statement block;
    private List<Comment> exceptions = new ArrayList<>();
    private RawComment returnCommentToMatch;
    /**
     * whether the method doesn't have side effect
     */
    private boolean pure;

    /**
     * whether it can be propagated directly
     */
    private boolean easyToPropagate;

    private String retCommentInstance;


    public void addParam(Parameter param) {
        //System.out.println("Param.add: "+ getId() + " " + param.getId());
        paramList.add(param);
    }

    public ArrayList<Parameter> getParams() {
        return paramList;
    }

    public Parameter findParam(String paramName) {
        for (Parameter param : paramList) {
            if (Objects.equals(param.getId(), paramName)) {
                return param;
            }
        }
        return null;
    }

    public void addVar(Variable var) {
        varList.add(var);
    }

    public ArrayList<Variable> getVariables() {
        return varList;
    }

    public Variable findVar(String varName) {
        for (Variable var : varList) {
            if (Objects.equals(var.getId(), varName)) {
                return var;
            }
        }
        return null;
    }

    public void setClass(Class cls) {
        this.cls = cls;
    }

    public Class getCls(Class cls) {
        return this.cls;
    }

    public String getRetType() {
        return this.retType;
    }

    public void setRetType(String retType) {
        this.retType = retType;
    }

    public ArrayList<Comment> getAllComments() {
        // TODO: Traverse comments in the body of methods.
        return getComments();
    }

    @Override
    public String toString() {
        return cls.toString() + "." + getId();
    }


    @Override
    public boolean equals(Object o) {
        return super.equals(o);
    }

    @Override
    public int hashCode() {
        return super.hashCode();
    }


    public Statement findStatementByNode(ASTNode node) {
        return findByNode(block, node);
    }

    private Statement findByNode(Statement stmt, ASTNode node) {
        if (stmt == null || node.equals(stmt.getAstNode())) {
            return stmt;
        } else {
            //find for each child node
            for (Statement childStatement : stmt.getStatements()) {
                if (node.equals(childStatement.getAstNode())) {
                    //if the child node matches, return
                    return childStatement;
                } else {
                    //if not, find the child node's children nodes
                    Statement childResult = findByNode(childStatement, node);
                    if (childResult != null) {
                        //if found, return
                        return childResult;
                    } else {
                        //else, search the next child node
                        continue;
                    }
                }
            }
        }

        return null;
    }
}
