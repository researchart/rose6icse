package edu.purdue.cs.propagator.what;

import edu.purdue.cs.CodeLists;
import edu.purdue.cs.model.Method;
import edu.purdue.cs.model.RawComment;
import edu.purdue.cs.propagator.ClassAndMethodTracer;
import edu.purdue.cs.propagator.StatementJudger;
import edu.purdue.cs.propagator.Util;
import edu.purdue.cs.util.WordDistanceCalculator;
import org.eclipse.jdt.core.dom.ASTNode;
import org.eclipse.jdt.core.dom.MethodInvocation;
import org.eclipse.jdt.core.dom.ReturnStatement;
import org.eclipse.jdt.core.dom.Statement;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Description:
 * Callee2St propagator
 * what-comment is propagated from callee m to statement s
 * with formal parameters fp in c substituted with actual parameters ap.
 *
 * @author xxz
 * Created on 2019-07-12
 */
public class Callee2St extends ClassAndMethodTracer {


    public Callee2St(CodeLists codeLists) {
        super(codeLists);
    }

    @Override
    public boolean visit(MethodInvocation node) {
        //find the statement node
        ASTNode toFind = node;
        while (toFind != null) {
            if (toFind instanceof Statement) {
                break;
            } else {
                toFind = toFind.getParent();
            }
        }
        edu.purdue.cs.model.Statement targetStatement = currentMethod.findStatementByNode(toFind);
        Method srcMethod = Util.findMethodInvoked(node, codeLists, currentMethod);
        if (srcMethod != null) {
            List<ASTNode> args = node.arguments();
            Map<Integer, String> argList = new HashMap<>();
            if (node.getExpression() != null) {
                argList.put(0, node.getExpression().toString());
            }
            int idx = 1;
            for (ASTNode arg : args) {
                argList.put(idx++, arg.toString());
            }
            String toPropagate = srcMethod.getAllComments().stream()
                    .map(c -> new RawComment(srcMethod, c.getOrigText()))
                    .map(rc -> rc.buildComment(argList))
                    .findFirst()
                    .orElse(null);
            if (!srcMethod.getAllComments().isEmpty()) {
                //TODO: specified condition
                StatementJudger judger = new StatementJudger();
                if (targetStatement.getAstNode() instanceof ReturnStatement && judger.judge(node) && targetStatement.isPure()) {
                    ArrayList<edu.purdue.cs.model.Comment> targetComments = targetStatement.getComments();
                    edu.purdue.cs.model.Comment generatedComment = new edu.purdue.cs.model.Comment();
                    generatedComment.setPropagateLevel(srcMethod.getAllComments().get(0).getPropagateLevel() + 1);
                    generatedComment.setOrigText(toPropagate);
                    targetComments.add(generatedComment);
                    String ori = currentMethod.getAllComments().isEmpty() ? ""
                            : currentMethod.getAllComments().get(0).getOrigText();
                    WordDistanceCalculator.log(generatedComment.getOrigText(), ori, srcMethod.toString(),
                            currentMethod.toString() + " ///// " + targetStatement.getAstNode().toString(),
                            "What Callee2St");
                }
            }
        }


        return super.visit(node);
    }


}

