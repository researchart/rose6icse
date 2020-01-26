package edu.purdue.cs.parser.util;

import edu.purdue.cs.model.Parameter;

import java.util.ArrayList;
import java.util.Arrays;

public class ParamIdentifier {
    private static ArrayList<ArrayList<String>> synonym =
            new ArrayList<ArrayList<String>>(Arrays.asList(
                    new ArrayList<String>(Arrays.asList("element", "component",
                            "object", "obj", "e", "o", "attribute")),
                    new ArrayList<String>(Arrays.asList("index", "position")),
                    new ArrayList<String>(Arrays.asList("collection", "c")),
                    new ArrayList<String>(Arrays.asList("capacity", "initialcapacity")),
                    new ArrayList<String>(Arrays.asList("index", "position")),
                    new ArrayList<String>(Arrays.asList("map", "m")),
                    new ArrayList<String>(Arrays.asList("string", "str", "substring")),
                    new ArrayList<String>(Arrays.asList("role", "roleList"))
            ));

    private static ArrayList<String> getSynonyms(String str) {
        for (ArrayList<String> list : synonym) {
            if (list.contains(str.toLowerCase())) {
                return list;
            }
        }
        ArrayList<String> ret = new ArrayList<String>();
        ret.add(str);
        return ret;
    }

    public static ArrayList<String> getpatternsForParm(Parameter param) {
        ArrayList<String> patterns = new ArrayList<String>();
        ArrayList<String> words = getWordsInId(param.getId());

        // Case 1;
        ArrayList<String> temp1 = new ArrayList<String>();
        temp1.add("the");
        temp1.add("The");
        for (String word : words) {
            for (String syn : getSynonyms(word)) {
                ArrayList<String> temp2 = new ArrayList<String>();
                for (String t : temp1) {
                    temp2.add(t + " " + syn);
                }
                temp1 = temp2;
            }
        }
        patterns.addAll(temp1);

        // Case 2 && 3 && 7
        if (words.size() == 1) {
            for (String syn : getSynonyms(words.get(0))) {
                patterns.add("the specified " + syn); // Case 2
                patterns.add("the " + syn + " specified"); // Case 3
                patterns.add("the " + syn); // Case 8
            }
        }

        patterns.add("the specified " + param.getType()); // Case 4
        patterns.add("the " + param.getType() + " specified"); // Case 5
        patterns.add("the " + param.getType() + " argument"); // Case 6
        patterns.add("the argument"); // Case 8

        return patterns;
    }

    private static ArrayList<String> getWordsInId(String str) {
        int i = 0;
        ArrayList<String> ret = new ArrayList<String>();
        while (i < str.length()) {
            int j = i + 1;
            while (j < str.length() && str.charAt(j) >= 'a' &&
                    str.charAt(j) <= 'z') j++;
            ret.add(str.substring(i, j).toLowerCase());
            i = j;
        }
        return ret;
    }

}
