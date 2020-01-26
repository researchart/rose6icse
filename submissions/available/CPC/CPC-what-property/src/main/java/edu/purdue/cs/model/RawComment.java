package edu.purdue.cs.model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author XiangzheXu
 * create-time: 2019/1/6
 */
public class RawComment extends Comment {
    private static final String PLACEHOLDER = "#>#";
    private static final String NUM = ">";
    private static final String WHETHER_PATTERN = "true if (.*)";
    private static final String SPEC_PATTERN = "(the( specified)? (\\w*))(.*)";
    private static final String THIS_PATTERN = "((this|the) (\\w*))(.*)";

    /**
     * raw return comment
     * use placeholders to represent arguments/instance
     */

    private ArrayList<String> processed = new ArrayList<>();

    private Map<Integer, String> originsInPlaceHolder = new HashMap<>();

    private Method methodToParse;

    private String rawComment;

    public RawComment(Method method, String toParse) {
        rawComment = toParse;
        methodToParse = method;
        parse();
    }

    public void parse() {
        parse(rawComment);
    }

    public String buildComment(Map<Integer, String> paramList) {
        StringBuilder comment = new StringBuilder();
        final int NUM_MASK = 0xf;
        for (String cmtElement : processed) {
            if (cmtElement.charAt(0) == '#') {
                int key = cmtElement.charAt(1) & NUM_MASK;
                String param = paramList.get(key);
                if (param != null) {
                    comment.append(param);
                } else {
                    comment.append(originsInPlaceHolder.get(key));
                }
            } else {
                comment.append(cmtElement);
            }
            comment.append(" ");
        }
        return new String(comment);
    }

    private void parse(String stringToParse) {
        stringToParse = stringToParse.trim();
        boolean anyMatch = matchWhether(stringToParse) || matchSpecPattern(stringToParse) || matchThis(stringToParse);
        if (!anyMatch) {
            noMatch(stringToParse);
        }

    }

    private boolean matchWhether(String stringToParse) {
//        Matcher matcher = Pattern.compile(WHETHER_PATTERN).matcher(stringToParse);
//        if (matcher.matches()) {
//            processed.add("Whether");
//            parse(matcher.group(1));
//            return true;
//        }
        return false;
    }

    private boolean matchThis(String stringToParse) {
        Matcher matcher = Pattern.compile(THIS_PATTERN).matcher(stringToParse);
        String clsName = methodToParse.getCls().getId();
        String lowerCaseClsName = clsName.toLowerCase();
        if (matcher.matches()) {
            boolean equals = lowerCaseClsName.contains(matcher.group(3).toLowerCase());
            if (!equals) {
                return false;
            }
            processed.add(PLACEHOLDER.replace(NUM, "0"));
            originsInPlaceHolder.put(0, matcher.group(1));
            parse(matcher.group(4));
            return true;
        }
        return false;
    }

    private boolean matchSpecPattern(String stringToParse) {
        Matcher matcher = Pattern.compile(SPEC_PATTERN).matcher(stringToParse);
        if (matcher.matches()) {
            String potentialParam = matcher.group(3);
            Parameter realParam = getRealParam(potentialParam);
            if (potentialParam.equals("position")) {
                realParam = getRealParam("index");
            }
            if (realParam == null) {
                realParam = getRealParam(potentialParam);
            }

            if (realParam == null) {
                return false;
            }
            originsInPlaceHolder.put(realParam.getRank(), matcher.group(1));
            processed.add(PLACEHOLDER.replace(NUM, String.valueOf(realParam.getRank())));
            parse(matcher.group(4));
            return true;
        }
        return false;
    }

    private void noMatch(String string) {
        string = string.trim();
        int firstWordBoundary = string.indexOf(' ');
        if (firstWordBoundary > 0) {
            processed.add(string.substring(0, firstWordBoundary));
            if (string.length() > firstWordBoundary + 1) {
                parse(string.substring(firstWordBoundary + 1));
            }
        } else if (!string.isEmpty()) {
            processed.add(string);
        }
    }

    private Parameter getRealParam(String potentialParam) {
        Parameter sameNameParam = methodToParse.findParam(potentialParam);
        if (sameNameParam != null) return sameNameParam;
        for (Parameter parameter : methodToParse.getParamList()) {
            if (parameter.getNounDescribes() != null && parameter.getNounDescribes().contains(potentialParam)) {
                return parameter;
            }
        }
        return null;
    }

    @Override
    public String toString() {
        return String.join(" ", processed);
    }
}
