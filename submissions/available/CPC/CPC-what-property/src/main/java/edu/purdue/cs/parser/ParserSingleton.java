package edu.purdue.cs.parser;

import edu.stanford.nlp.parser.lexparser.LexicalizedParser;

public class ParserSingleton {

    private static LexicalizedParser myParser;
    private static ParserSingleton instance;

    public static synchronized ParserSingleton getInstance() {
        if (instance == null) {
            instance = new ParserSingleton();
            ParserSingleton.initialize();
        }
        return instance;
    }

    private static void initialize() {
        if (myParser == null)
			/*myParser = LexicalizedParser.loadModel(
				"edu/stanford/nlp/models/lexparser/englishFactored.ser.gz",
				"-maxLength", "80", "-retainTmpSubcategories");*/
            myParser = LexicalizedParser.loadModel(
                    "edu/stanford/nlp/models/lexparser/englishPCFG.ser.gz",
                    "-maxLength", "80", "-retainTmpSubcategories");
    }

    public LexicalizedParser getLexicalizedParser() {
        return myParser;
    }

}
