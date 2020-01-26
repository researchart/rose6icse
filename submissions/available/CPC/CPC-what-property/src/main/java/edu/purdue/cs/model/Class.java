package edu.purdue.cs.model;

import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@EqualsAndHashCode(callSuper = true)
@Data
public class Class extends Subject {
    private ArrayList<Method> methodList = new ArrayList<Method>();
    private ArrayList<Field> fieldList = new ArrayList<Field>();
    private Class superClass;

    public void addMethod(Method m) {
        methodList.add(m);
    }

    public ArrayList<Method> getMethods() {
        return methodList;
    }

    public Method findMethod(String name) {
        //System.out.print(name+": ");
        nextMethod:
        for (Method m : methodList) {
//            System.out.println(m.getId()+" ");
            if (m.getId().equals(name)) {
                return m;
            }
            String targetId = m.getId();
            //(public|private) (static|native) (returnType) methodName
            Pattern methodPattern = Pattern.compile("(.*) (\\w+)\\((.*)\\).*( throws (.*))?");
            Matcher targetMethodName = methodPattern.matcher(targetId.trim());
            Matcher toFindMethodName = methodPattern.matcher(name.trim());
            if (targetMethodName.matches() && toFindMethodName.matches()) {
                if (!targetMethodName.group(2).equals(toFindMethodName.group(2))) {
                    continue;
                }
                String targetParamList = targetMethodName.group(3);
                String toFindParamList = toFindMethodName.group(3);
                String cleanedTargetParamList = targetParamList.replaceAll("<.*>", "");
                String[] targetParams = cleanedTargetParamList.contains(",") ? cleanedTargetParamList.split(",") : new String[]{cleanedTargetParamList};
                String[] toFindParams = toFindParamList.contains(",") ? toFindParamList.split(",") : new String[]{toFindParamList};
                if (targetParams.length != toFindParams.length) {
                    continue nextMethod;
                } else {
                    for (int i = 0; i < targetParams.length; i++) {
                        if (targetParams[i].isEmpty() || toFindParams[i].isEmpty()) {
                            continue nextMethod;
                        }
                        if (!targetParams[i].contains(toFindParams[i]) && !toFindParams[i].contains(targetParams[i])) {
                            continue nextMethod;
                        }
                    }
                    return m;
                }
            }

        }
        //System.out.println("");
        return null;
    }

    public void addField(Field f) {
        fieldList.add(f);
        //System.out.println("[addField] "+this.getId()+": "+f.getId());
    }

    public Field findField(String fieldName) {
        return fieldList.stream()
                .filter(field -> field.getId().equals(fieldName))
                .findAny()
                .orElse(null);
    }

    public ArrayList<Field> getFields() {
        return fieldList;
    }

    public ArrayList<Comment> getAllComments() {
        ArrayList<Comment> comments = this.getComments();
        for (int i = 0; i < fieldList.size(); i++) {
            comments.addAll(fieldList.get(i).getComments());
        }
        for (int i = 0; i < methodList.size(); i++) {
            comments.addAll(methodList.get(i).getAllComments());
        }
        return comments;
    }

    @Override
    public String toString() {
        return getId();
    }
}
