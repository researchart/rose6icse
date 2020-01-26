package edu.purdue.cs.model;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

public class DomainTokenTag {

    private static HashMap<String, String> tokenTagMap = new HashMap<String, String>();
    private static DomainTokenTag instance;

    public static synchronized DomainTokenTag getInstance() {
        if (instance == null) {
            instance = new DomainTokenTag();
            DomainTokenTag.initialize();
        }
        return instance;
    }

    private static void initialize() {
        tokenTagMap.put("returns", "VBZ");
        tokenTagMap.put("inserts", "VBZ");
        tokenTagMap.put("adds", "VBZ");
        tokenTagMap.put("appends", "VBZ");
        tokenTagMap.put("removes", "VBZ");
        tokenTagMap.put("deletes", "VBZ");
        tokenTagMap.put("replaces", "VBZ");
        tokenTagMap.put("performs", "VBZ");
        tokenTagMap.put("shifts", "VBZ");
        tokenTagMap.put("retrieves", "VBZ");
        tokenTagMap.put("increases", "VBZ");
        tokenTagMap.put("retains", "VBZ");
        tokenTagMap.put("sorts", "VBZ");
        tokenTagMap.put("creates", "VBZ");
        tokenTagMap.put("constructs", "VBZ");
        tokenTagMap.put("sets", "VBZ");
        tokenTagMap.put("maps", "VBZ");
        tokenTagMap.put("associates", "VBZ");
        tokenTagMap.put("trims", "VBZ");

        tokenTagMap.put("specified", "VBN");
        tokenTagMap.put("mapped", "VBN");

        tokenTagMap.put("map", "NN");
        tokenTagMap.put("true", "NN");
        tokenTagMap.put("false", "NN");
        tokenTagMap.put("null", "NN");
        tokenTagMap.put("iterator", "NN");
        tokenTagMap.put("positive", "NN");
        tokenTagMap.put("negative", "NN");
        tokenTagMap.put("defaultValue", "NN");

        tokenTagMap.put("reverse", "JJ");
        tokenTagMap.put("remaining", "JJ");
        tokenTagMap.put("inclusive", "JJ");
        tokenTagMap.put("exclusive", "JJ");
        tokenTagMap.put("more", "JJ");
        tokenTagMap.put("next", "JJ");
    }

    public HashMap<String, String> getTokenTagMap() {
        return tokenTagMap;
    }

    public String getTag(String word) {
        Iterator<Entry<String, String>> iter = tokenTagMap.entrySet().iterator();
        while (iter.hasNext()) {
            Map.Entry entry = iter.next();
            String key = (String) entry.getKey();
            if (key.equalsIgnoreCase(word))
                return (String) entry.getValue();
        }
        return null;
    }
}
