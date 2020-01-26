package cs.purdue.edu;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;

import cs.purdue.edu.model.Comment;
import opennlp.tools.stemmer.PorterStemmer;

/**
 * Clean the data by Porter Stemmer.
 * @author shiyu
 */
public class DataCleaner {
	static PorterStemmer stemmer = new PorterStemmer();
	private static final ArrayList<String> stopWords = new ArrayList<String>(
			Arrays.asList("will", "the", "a", "an", "it", "its"));

	
	public static void main(String[] args) throws IOException {
		String str = "Today I am very happy.";
		System.out.println(clean(str));
	}
	
	/**
	 * Clean the words in the given string.
	 * @param txt the string need to be clean
	 * @return the cleaned string
	 */
	public static String clean(String txt) {
		String ret = "";
		String[] wordList = txt.split(" ");
		for (String word: wordList) {
			word = word.trim().toLowerCase();
			if (word.endsWith(".")) {
				word = word.substring(0, word.length()-1);
			}
			if (stopWords.contains(word) || word.isEmpty()) continue;
			ret += stemmer.stem(word) + " ";
		}
		return ret.trim();
	}
	
	/**
	 * Clean all the comments in the give list and save the cleaned sentence in
	 * itself.
	 */
	public ArrayList<String> cleanComments(ArrayList<Comment> cmtList) {
		ArrayList<String> retList = new ArrayList<String>();
		for (Comment cmt: cmtList) {
			String str = clean(cmt.getOrigText());
			cmt.setCleanText(str);
			retList.add(str);
		}
		return retList;
	}
}
