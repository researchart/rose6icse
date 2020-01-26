package edu.purdue.cs;

import edu.purdue.cs.model.Class;
import edu.purdue.cs.model.Comment;
import lombok.Data;
import org.eclipse.jdt.core.dom.CompilationUnit;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import static edu.purdue.cs.util.SourceCodeUtil.getCompilationUnit;
import static edu.purdue.cs.util.SourceCodeUtil.readFileToString;

/**
 * This class provide a way to collect comments sentence by sentence using AST.
 *
 * @author shiyu
 * <p>
 * add support to multi-file analysis
 * <p>
 * updatedAt: Dec 31, 2018
 * modifiedBy: xxz
 */
@Data
public class CommentCollector {
    private String source;
    private String pack;
    private CodeLists lists;


    /**
     * collect the comment of certain file
     *
     * @param packPath the relative path of the package of this file
     * @param fileName the name of this file
     * @param lists    the code list to collect
     * @throws IOException if the file fail to open
     */
    public CommentCollector(String packPath, String fileName, CodeLists lists) {
        try {
            this.source = readFileToString(packPath + File.separator + fileName);
        } catch (IOException e) {
            System.err.println("Fail to read file " + fileName);
            e.printStackTrace();
        }
        this.pack = packPath;
        this.lists = lists;
    }

    /**
     * This is a test for ASTView. aflkjd This is a test for ASTView. This is a test for
     * ASTView. This is a test for ASTView.
     *
     * @param a the input integer the input integer. the input integerthe input in
     *          tegerthe input integer.
     */
    public static int test(int a) {
        int ret = a + 1;
        return ret;
    }

    public ArrayList<Comment> getComments() {
        ArrayList<Comment> comments = new ArrayList<Comment>();
        for (Class cls : lists.getClasses()) {
            comments.addAll(cls.getAllComments());
        }
        return comments;
    }

    public void parse() {
        final CompilationUnit cu = getCompilationUnit(source);
//
//        CommentPrinter visitor = new CommentPrinter(source, pack, lists);
//        cu.accept(visitor);
////

        CommentVisitor visitor = new CommentVisitor(source, pack, lists);
        cu.accept(visitor);
        for (org.eclipse.jdt.core.dom.Comment comment :
                (List<org.eclipse.jdt.core.dom.Comment>) cu.getCommentList()) {
            comment.accept(visitor);
        }



		/*for (Comment cmt: getComments()) {
			if (cmt.getSubject1() == Subject.subject.filed)
				System.out.println(cmt.getCodeEntityId()+": "+cmt.getOrigText());
		}*/
    }


    /**
     * For Test.
     */
    public CodeLists getCodeLists() {
        return lists;
    }
}


