package edu.purdue.cs.propagate;

import edu.purdue.cs.CodeLists;
import edu.purdue.cs.model.Class;
import org.eclipse.jdt.core.dom.*;

/**
 * @author XiangzheXu
 * create-time: 2019-01-11
 */
public class SuperClassVisitor extends ASTVisitor {
    private CodeLists codeLists;

    public SuperClassVisitor(CodeLists codeLists) {
        this.codeLists = codeLists;
    }

    @Override
    public boolean visit(TypeDeclaration node) {
        Type superclassType = node.getSuperclassType();
        if (superclassType == null) {
            return true;
        }
        String superClzName;
        if (superclassType instanceof ParameterizedType) {
            superClzName = ((ParameterizedType) superclassType).getType().toString();
        } else if (superclassType instanceof SimpleType) {
            superClzName = superclassType.toString();
        } else {
            return true;
        }

        Class superClass = codeLists.findClass(superClzName);
        Class curClass = codeLists.findClass(node.getName().toString());
        if (curClass != null && superClass != null) {
            curClass.setSuperClass(superClass);
        }
        return true;
    }


}
