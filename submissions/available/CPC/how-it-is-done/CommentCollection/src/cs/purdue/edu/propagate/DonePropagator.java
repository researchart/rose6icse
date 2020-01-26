package cs.purdue.edu.propagate;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

import org.eclipse.jdt.core.dom.AST;
import org.eclipse.jdt.core.dom.ASTNode;
import org.eclipse.jdt.core.dom.ASTParser;
import org.eclipse.jdt.core.dom.CompilationUnit;

import cs.purdue.edu.CodeLists;
import cs.purdue.edu.CommentCollector;
import cs.purdue.edu.model.Comment;
import cs.purdue.edu.model.JavaFile;
import cs.purdue.edu.model.Method;
import cs.purdue.edu.parser.util.Pair;
import cs.purdue.edu.parser.util.ParserUtil;
import cs.purdue.edu.propagate.util.ExceptionUtil;
import cs.purdue.edu.propagate.util.ClonedMethod;
import cs.purdue.edu.propagate.util.CodeCloneUtil;
import cs.purdue.edu.propagate.util.ExceptionMethodVisitor;

public class DonePropagator {
	private static String projectDir = "C:\\Projects\\input_guava\\";
	private static String nicadResultPath = "guava_functions-abstract-clones\\"
			+ "guava_functions-abstract-clones-0.10-classes.xml";
	private static File fout = new File("C:\\Projects\\data_how-it-is-done\\0.1\\guava.txt");
	private static BufferedWriter writer;
	
	public static void main(String[] args) throws Exception {
		ArrayList<JavaFile> javaFiles = JavaFile.getJavaFiles(projectDir);
		writer = new BufferedWriter(new FileWriter(fout));
		
		/* Seperate method into three parts. */
		/*for (JavaFile f: javaFiles) {
			System.out.println(f.getPack());
			// Exception
			ExceptionUtil.recplaceExcptionFuncCall(f);
			ArrayList<Pair<Integer, Integer>> throwStatementLines = 
					ExceptionUtil.getLineNum(f);
		}*/
		
		/* Run Code Clone tool to detect similar methods. */
		
		/* Get methods comments*/
		//int count = 0;
		for (JavaFile f: javaFiles) {
			//if (count++ % 10 == 0) System.out.println(f.getPack());
			
			CommentCollector collector = new CommentCollector(f);
			collector.parse();
			f.setCodeLists(collector.getCodeLists());
		}
		
		/* Compare similar pairs again by three parts we get.*/
		ArrayList<ArrayList<ClonedMethod>> result = CodeCloneUtil.readXML(
				nicadResultPath);
		
		propagateCommentForView(result, javaFiles);
		writer.flush();
		writer.close();
	}
	
	public static void propagateCommentForView(ArrayList<ArrayList<ClonedMethod>> result, 
			ArrayList<JavaFile> javaFiles) throws IOException {
		for (ArrayList<ClonedMethod> methods: result) {
			System.out.println("***");
			for (ClonedMethod cm: methods) {
				String outStr = "";
				int cmtCnt = 0;
				for (JavaFile f: javaFiles) {
					if (!cm.getFile().equals(f.getPack())) continue;
					for (Method m: f.getCodeLists().methods) {
						//System.out.println(cm.getFile()+" "+cm.getStartline()+" "+m.getLineNumBegin());
						if (m.getLineNumBegin() > cm.getStartline() ||
								m.getLineNumEnd() < cm.getEndline()) continue;
						//System.out.println(cm.getFile());
						outStr += cm.getFile() + " (" + cm.getStartline()
							+ ", " + cm.getEndline() + ")\n";
						for (Comment cmt: m.getComments()) {
							//System.out.println("    [cmt] "+cmt.getOrigText());
							outStr += ("    [cmt] " + cmt.getOrigText() + '\n');
							cmtCnt++;
						}
						break;
					}
					break;
				}
				if (cmtCnt > 0) writer.write(outStr);
			}
			// System.out.println();
			writer.write('\n');
		}
	}
	
	public static void propagateComment(ArrayList<ArrayList<ClonedMethod>> result, 
			ArrayList<JavaFile> javaFiles) throws IOException {
		for (ArrayList<ClonedMethod> methods: result) {
			writer.write("*\n");
			for (ClonedMethod cm: methods) {
				for (JavaFile f: javaFiles) {
					if (!cm.getFile().equals(f.getPack())) continue;
					for (Method m: f.getCodeLists().methods) {
						//System.out.println(cm.getFile()+" "+cm.getStartline()+" "+m.getLineNumBegin());
						if (m.getLineNumBegin() > cm.getStartline() ||
								m.getLineNumEnd() < cm.getEndline()) continue;
						writer.write("#\n");
						//System.out.println(cm.getFile());
						writer.write(cm.getFile() + " " + cm.getStartline() + " " 
								+ cm.getEndline() + "\n");
						for (Comment cmt: m.getComments()) {
							writer.write("" + cmt.getOrigText() + '\n');
						}
						break;
					}
					break;
				}
			}
			// System.out.println();
		}
	}
}
