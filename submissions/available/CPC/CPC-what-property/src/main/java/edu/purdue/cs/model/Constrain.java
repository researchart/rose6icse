package edu.purdue.cs.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import org.springframework.beans.BeanUtils;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author XiangzheXu
 * create-time: 2019-01-25
 */
@EqualsAndHashCode(callSuper = true)
@Data
public class Constrain extends Comment {
    private static final String PLACEHOLDER = "#>#";
    private static final String PLACEHOLDER_PARSER = "#(\\d+)#";
    private static final String NUM = ">";
    private String specifiedConstrain = "";
    private Map<Integer, String> originalParamName = new HashMap<>();
    private Set<Integer> constrainToRank = new HashSet<>();

    public Constrain(Comment exception, List<Parameter> parameterList) {
        BeanUtils.copyProperties(exception, this);
        String constrainText = exception.getOrigText().toLowerCase();
        Pattern constrainPattern = Pattern.compile("(.*exception)\\s+if\\s+(?:the|the specified)?\\s+(.*)\\s+is(.*)");
        Matcher constrainMatcher = constrainPattern.matcher(constrainText);
        if (constrainMatcher.matches()) {
            String exceptionName = constrainMatcher.group(1);
            String paramName = constrainMatcher.group(2);
            String constrain = constrainMatcher.group(3);
            for (Parameter parameter : parameterList) {
                if (paramMatches(paramName, parameter)) {
                    constrainToRank.add(parameter.getRank());
                    originalParamName.put(parameter.getRank(), parameter.getId());
                    specifiedConstrain = PLACEHOLDER.replace(NUM, parameter.getRank() + "") + " is not " + constrain;
                    break;
                }
            }
        }

    }

    private boolean paramMatches(String paramName, Parameter parameter) {
        boolean idMatches = parameter.getId().toLowerCase().contains(paramName);
        if (idMatches) return true;
        boolean descMatches = parameter.getNounDescribes() != null && parameter.getNounDescribes().contains(paramName);
        if (descMatches) return true;
        if (paramName.equals("position")) return paramMatches("index", parameter);

        return false;
    }

    public String generateConstrains(List<String> parameterList) {
        String ret = specifiedConstrain;
        Matcher matcher = Pattern.compile(PLACEHOLDER_PARSER).matcher(specifiedConstrain);
        while (matcher.find()) {
            int placeHolderRank = Integer.parseInt(matcher.group(1));
            assert parameterList.size() > placeHolderRank - 1;
            String placeHolderExpression = parameterList.get(placeHolderRank - 1);
            ret = ret.replace(matcher.group(0), placeHolderExpression);
        }
        return ret;
    }

    public boolean relatedToRank(int rank) {
        return constrainToRank.contains(rank);
    }
}
