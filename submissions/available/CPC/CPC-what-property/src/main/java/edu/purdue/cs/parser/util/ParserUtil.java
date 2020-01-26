package edu.purdue.cs.parser.util;

import edu.purdue.cs.model.DomainTokenTag;
import edu.stanford.nlp.ling.HasWord;
import edu.stanford.nlp.ling.TaggedWord;

import java.util.ArrayList;
import java.util.List;

public class ParserUtil {
    public static List<HasWord> getTagAssigned(List<HasWord> origWords) {
        List<HasWord> newWords = new ArrayList<HasWord>();
        for (int i = 0; i < origWords.size(); i++) {
            HasWord word = origWords.get(i);
            String tag = DomainTokenTag.getInstance().getTag(word.toString());
            if (tag != null) {
                TaggedWord tagWord = new TaggedWord(word.toString(), tag);
                newWords.add(tagWord);
            } else
                newWords.add(word);
        }
        return newWords;
    }
}
