package edu.purdue.cs.parser;

import edu.purdue.cs.parser.util.Pair;
import edu.purdue.cs.parser.util.ParserUtil;
import edu.stanford.nlp.ling.CoreLabel;
import edu.stanford.nlp.ling.HasWord;
import edu.stanford.nlp.ling.SentenceUtils;
import edu.stanford.nlp.parser.lexparser.LexicalizedParser;
import edu.stanford.nlp.pipeline.CoreDocument;
import edu.stanford.nlp.pipeline.StanfordCoreNLP;
import edu.stanford.nlp.trees.*;

import java.util.*;
import java.util.stream.Collectors;

public class CommentParser {

    public static GrammaticalStructure parseString(String sentence) {
        String[] words = sentence.split("\\s");
        return parseSentence(words);
    }

    public static GrammaticalStructure parseWords(String[] words) {
        return parseSentence(words);
    }


    /**
     * Return a GrammaticalStructure.
     * To get the root of tree use gs.root()
     * To get the dependencies usege.typedDependenciesCCprocessed()
     */
    public static GrammaticalStructure parseSentence(String[] origWords) {
        LexicalizedParser parser = ParserSingleton.getInstance()
                .getLexicalizedParser();
        TreebankLanguagePack tlp = new PennTreebankLanguagePack();
        GrammaticalStructureFactory gsf = tlp.grammaticalStructureFactory();

        List<HasWord> words = SentenceUtils.toWordList(origWords);
        List<HasWord> taggedWords = ParserUtil.getTagAssigned(words);

        Tree parse = parser.apply(taggedWords);
        //String s = parse.pennString();
        GrammaticalStructure gs = gsf.newGrammaticalStructure(parse);

        return gs;

    }

    public static String getBfsString(TreeGraphNode root) {
        Queue<Pair<TreeGraphNode, Integer>> queue = new LinkedList<Pair<TreeGraphNode, Integer>>();
        queue.offer(new Pair<TreeGraphNode, Integer>(root, 1));
        int depth = 1;
        String ret = "1: ";
        while (!queue.isEmpty()) {
            Pair<TreeGraphNode, Integer> p = queue.poll();
            if (p.second > depth) {
                depth++;
                ret += "; " + depth + ":";
            }
            ret += " " + p.first.nodeString();
            for (TreeGraphNode ch : p.first.children()) {
                if (!ch.isLeaf())
                    queue.offer(new Pair<TreeGraphNode, Integer>(ch, p.second + 1));

            }
        }
        return ret;
    }

    public static HashMap<String, Integer> nodeCount(TreeGraphNode root) {
        HashMap<String, Integer> map = new HashMap<String, Integer>();
        map.put("NP", 0);
        map.put("PP", 0);
        map.put("VP", 0);
        Queue<TreeGraphNode> queue = new LinkedList<TreeGraphNode>();
        queue.offer(root);
        while (!queue.isEmpty()) {
            TreeGraphNode p = queue.poll();
            String temp = p.nodeString();
            if (!map.containsKey(temp)) map.put(temp, 1);
            else map.put(temp, map.get(temp) + 1);

            for (TreeGraphNode ch : p.children()) {
                if (!ch.isLeaf()) queue.offer(ch);
            }
        }
        return map;
    }

    public static HashMap<String, Integer> getDependencies(GrammaticalStructure gs) {
        HashMap<String, Integer> map = new HashMap<String, Integer>();
        map.put("auxpass", 0);
        map.put("case", 0);
        map.put("tmod", 0);
        map.put("advmod", 0);
        map.put("preconj", 0);
        for (TypedDependency t : gs.typedDependencies()) {
            String temp = t.reln().toString();
            if (!map.containsKey(temp)) map.put(temp, 1);
            else map.put(temp, map.get(temp) + 1);
        }
        return map;
    }

    public static void main(String[] args) {
        String text = "Replaces the element at the specified position in this list with the specified element.";
        // set up pipeline properties
        Properties props = new Properties();
        // set the list of annotators to run
        props.setProperty("annotators", "tokenize,ssplit,pos,lemma");
        // set a property for an annotator, in this case the coref annotator is being set to use the neural algorithm
        props.setProperty("coref.algorithm", "neural");
        // build pipeline
        StanfordCoreNLP pipeline = new StanfordCoreNLP(props);
        // create a document object
        CoreDocument document = new CoreDocument(text);
        // annnotate the document
        pipeline.annotate(document);
        // examples
        Set<CoreLabel> nn = document.tokens().stream().filter(t -> t.tag().contains("NN")).collect(Collectors.toSet());
        document.tokens();
        document.sentences();


        GrammaticalStructure gs = parseString("The name is used by other components to identify this appender");
        //gs.root().pennPrint();
        System.out.println(gs.typedDependencies());
        //System.out.println(getBfsString(gs.root()));
        //HashMap<String, Integer> map = nodeCount(gs.root());
        //System.out.println(map.get("NN"));
        //System.out.println(map.get("VP"));
        //System.out.println(map.get("PP"));
        System.out.println(getDependencies(gs));


    }
}
