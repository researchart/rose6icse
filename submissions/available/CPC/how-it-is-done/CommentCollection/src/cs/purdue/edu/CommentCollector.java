package cs.purdue.edu;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.jdt.core.dom.AST;
import org.eclipse.jdt.core.dom.ASTParser;
import org.eclipse.jdt.core.dom.ASTVisitor;
import org.eclipse.jdt.core.dom.BlockComment;
import org.eclipse.jdt.core.dom.CompilationUnit;
import org.eclipse.jdt.core.dom.LineComment;

import cs.purdue.edu.model.Variable;
import cs.purdue.edu.parser.util.ParserUtil;
import cs.purdue.edu.model.Class;
import cs.purdue.edu.model.Comment;
import cs.purdue.edu.model.JavaFile;
import cs.purdue.edu.model.Subject;

/**
 * This class provide a way to collect comments sentence by sentence using AST.
 *
 * @author shiyu
 */
public class CommentCollector {
	private JavaFile source;
	private CodeLists lists = new CodeLists();
	
	public CommentCollector(JavaFile file) {
		source = file;
	}
	
	public void parse() {
		CompilationUnit cu = source.getCu();
		CommentVisitor visitor = new CommentVisitor(
				source.getSrc(),
				source.getPack(),
				lists);
		cu.accept(visitor);
		
		/*for (org.eclipse.jdt.core.dom.Comment comment :
			(List<org.eclipse.jdt.core.dom.Comment>) cu.getCommentList()) {
			comment.accept(visitor);
		}*/
	}

	
	public ArrayList<Comment> getComments() {
		ArrayList<Comment> comments = new ArrayList<Comment>();
		for (Class cls: lists.classes) {
			comments.addAll(cls.getAllComments());
		}
		return comments;
	}
	
	public CodeLists getCodeLists() {
		return lists;
	}
	
}


