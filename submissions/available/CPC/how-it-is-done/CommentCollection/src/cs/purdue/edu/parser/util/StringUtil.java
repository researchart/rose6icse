package cs.purdue.edu.parser.util;

public class StringUtil {
	/**
	 * Replace s1 with s2 in String str.
	 */
	public static String replaceSubstring(String str, String s1, String s2) {
		String[] tokens = str.split(s1);
		String ret = tokens[0];
		for (int i = 1; i < tokens.length; i++) {
			ret += s2 + tokens[i];
		}
		return ret;
	}
	
	public static boolean isLetter(String str, int i) {
		return (str.charAt(i) >= 'a' && str.charAt(i) <= 'z' || 
				str.charAt(i) >= 'A' && str.charAt(i) <= 'Z');
	}
	
	/**
	 * Count how many char ch are contained in str.
	 */
	public static int countChar(String str, char ch) {
		int count = 0;
		for (int i = 0; i < str.length(); i++) {
			if (str.charAt(i) == ch) count++;
		}
		return count;
	}
}
