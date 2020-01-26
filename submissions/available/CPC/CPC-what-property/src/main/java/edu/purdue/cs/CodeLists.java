package edu.purdue.cs;

import edu.purdue.cs.model.Class;
import edu.purdue.cs.model.Comment;
import edu.purdue.cs.model.Method;
import lombok.Data;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * This object is an abstract for a snap of code.
 */
@Data
public class CodeLists implements Serializable {
    private static final long serialVersionUID = 23456L;
    private ArrayList<Class> classes = new ArrayList<Class>();
    //    public ArrayList<Method> methods = new ArrayList<Method>();
//    public ArrayList<Field> fields = new ArrayList<Field>();
    private ArrayList<Comment> comments = null;


    /**
     * find a class exists in this code snap by classname
     *
     * @return null if not found
     */
    public Class findClass(String className) {
        for (Class cls : classes) {
            if (className != null && (className.equals(cls.getId()) || className.replaceAll("<.*>", "").equals(cls.getId()))) {
                return cls;
            }
        }
//        System.out.println("Can't find class " + className);
        return null;
    }

    /**
     * find by method name
     * iterate on every class
     *
     * @return null if not found
     */
    public Method findMethod(String methodName) {
        for (Class cls : classes) {
            for (Method method : cls.getMethods()) {
                if (methodName.equals(method.getId())) {
                    return method;
                }
            }
        }
//        System.out.println("Can't find method " + methodName);
        return null;
    }

    public Class declaringClass(int begin, int end) {
//        Class retClass = null;
        //search from back
        List<Class> candidates = classes.stream()
                .filter(cls -> cls.getLineNumBegin() <= begin && cls.getLineNumEnd() >= end)
                .collect(Collectors.toList());
        if (!candidates.isEmpty()) {
            return candidates.get(candidates.size() - 1);
        } else {
            return null;
        }
//        }
//        for (Class cls : classes) {
//            if (cls.getLineNumBegin() <= begin && cls.getLineNumEnd() >= end) {
//                if (retClass == null ||
//                        cls.getLineNumBegin() >= retClass.getLineNumBegin() &&
//                                cls.getLineNumEnd() <= retClass.getLineNumEnd()) {
//                    retClass = cls;
//                }
//            }
//        }
//        if (retClass == null) {
//            //System.out.println("[CodeLists.declaringClass] Lines [" + begin
//            //		+ ", " + end + "] are not declared in any classes.");
//            return null;
//        }
//        return retClass;
    }

//    public Method declaringMethod(int begin, int end) {
//        Method retMethod = null;
//        for (Method method : methods) {
//            if (method.getLineNumBegin() <= begin && method.getLineNumEnd() >= end) {
//                if (retMethod == null ||
//                        method.getLineNumBegin() >= retMethod.getLineNumBegin() &&
//                                method.getLineNumEnd() <= retMethod.getLineNumEnd()) {
//                    retMethod = method;
//                }
//            }
//        }
//        if (retMethod == null) {
//			//System.out.println("[CodeLists.declaringMethod] Lines [" + begin
//			//		+ ", " + end + "] are not declared in any methods.");
//            return null;
//        }
//        return retMethod;
//    }

    public List<Comment> getAllComments() {
        if (comments == null) {
            comments = new ArrayList<Comment>();
            for (Class cls : classes) {
                comments.addAll(cls.getAllComments());
            }
        }
        return comments;
    }
}
