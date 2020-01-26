package cs.purdue.edu.parser.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.eclipse.jdt.core.dom.AST;
import org.eclipse.jdt.core.dom.ASTParser;
import org.eclipse.jdt.core.dom.CompilationUnit;

import cs.purdue.edu.model.DomainTokenTag;
import edu.stanford.nlp.ling.HasWord;
import edu.stanford.nlp.ling.TaggedWord;

public class ParserUtil {
	private static DomainTokenTag domainTokenTag = DomainTokenTag.getInstance();
	
	public static CompilationUnit getCompilationUnit(String source) {
		ASTParser parser = ASTParser.newParser(AST.JLS10);
		parser.setSource(source.toCharArray());
		parser.setKind(ASTParser.K_COMPILATION_UNIT);
		//parser.setEnvironment(
	        //    new String[] {"/home/sy/icse20/how-it-is-done/Nicad_input/bin"}, //
	        //    null, null, true);
		parser.setEnvironment(
                    new String[] {""}, //
                    null, null, true);
	    parser.setUnitName("any_name");
		parser.setResolveBindings(true);
		
		return (CompilationUnit) parser.createAST(null);
	}
	
	public static List<HasWord> getTagAssigned(List<HasWord> origWords){
		List<HasWord> newWords = new ArrayList<HasWord>();
		for(HasWord word: origWords){
			String tag = domainTokenTag.getTag(word.toString());
			if(tag != null){
				TaggedWord tagWord = new TaggedWord(word.toString(), tag);
				newWords.add(tagWord);
			}
			else
				newWords.add(word);
		}	
		return newWords;
	}

}
