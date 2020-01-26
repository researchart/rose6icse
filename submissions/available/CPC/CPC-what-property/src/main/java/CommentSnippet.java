import org.eclipse.jdt.core.dom.BodyDeclaration;
import org.eclipse.jdt.core.dom.Comment;
import org.eclipse.jdt.core.dom.FieldDeclaration;
import org.eclipse.jdt.core.dom.MethodDeclaration;

import java.util.List;

public class CommentSnippet {
    public int start;
    public int end;
    public int length;
    public String rawText = "";
    public String entity;
    public MethodDeclaration method;
    public FieldDeclaration field;
    public BodyDeclaration className;
    public List<String> sentences;

    CommentSnippet(Comment node) {
        start = node.getStartPosition();
        length = node.getLength();
        end = start + length;
    }
}
