package cs.purdue.edu.model;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

public class DomainTokenTag {

	private static HashMap<String, String> tokenTagMap = new HashMap<String, String>();
	private static DomainTokenTag instance;
	
	public static synchronized DomainTokenTag getInstance(){
		if(instance == null){
			instance = new DomainTokenTag();
			DomainTokenTag.initialize();
		}
		return instance;
	}

	private static void initialize(){
		tokenTagMap.put("adds", "VBZ");
		tokenTagMap.put("appends", "VBZ");
		tokenTagMap.put("associates", "VBZ");
		tokenTagMap.put("constructs", "VBZ");
		tokenTagMap.put("creates", "VBZ");
		tokenTagMap.put("deletes", "VBZ");
		tokenTagMap.put("increases", "VBZ");
		tokenTagMap.put("inserts", "VBZ");
		tokenTagMap.put("maps", "VBZ");
		tokenTagMap.put("performs", "VBZ");
		tokenTagMap.put("removes", "VBZ");
		tokenTagMap.put("replaces", "VBZ");
		tokenTagMap.put("retains", "VBZ");
		tokenTagMap.put("retrieves", "VBZ");
		tokenTagMap.put("returns", "VBZ");
		tokenTagMap.put("sets", "VBZ");
		tokenTagMap.put("shifts", "VBZ");
		tokenTagMap.put("sorts", "VBZ");
		tokenTagMap.put("throws", "VBZ");
		tokenTagMap.put("trims", "VBZ");

		tokenTagMap.put("mapped", "VBN");
		tokenTagMap.put("specified", "VBN");
		
		tokenTagMap.put("defaultValue", "NN");
		tokenTagMap.put("false", "NN");
		tokenTagMap.put("iterator", "NN");
		// tokenTagMap.put("map", "NN");
		tokenTagMap.put("negative", "NN");
		tokenTagMap.put("null", "NN");
		tokenTagMap.put("positive", "NN");
		tokenTagMap.put("true", "NN");
		
		tokenTagMap.put("reverse", "JJ");
		tokenTagMap.put("remaining", "JJ");
		tokenTagMap.put("inclusive", "JJ");
		tokenTagMap.put("exclusive", "JJ");
		tokenTagMap.put("more", "JJ");
		tokenTagMap.put("next", "JJ");
		
		tokenTagMap.put("whether", "IN");
	}
	
	public HashMap<String, String> getTokenTagMap(){
		return tokenTagMap;
	}
	
	public String getTag(String word){
		return tokenTagMap.get(word.toLowerCase());
		/*
		Iterator<Entry<String, String>> iter = tokenTagMap.entrySet().iterator(); 
		while (iter.hasNext()) { 
		    Map.Entry entry = (Map.Entry) iter.next(); 
		    String key = (String) entry.getKey(); 
		    if(key.equalsIgnoreCase(word))
		    	return (String) entry.getValue(); 
		}
		return null;
		*/
	}
}
