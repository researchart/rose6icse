package cs.purdue.edu;

import java.io.File;
import java.util.ArrayList;

import cs.purdue.edu.model.Comment;
import cs.purdue.edu.model.JavaFile;
import cs.purdue.edu.parser.util.CorpusUtil;
import cs.purdue.edu.parser.util.XMLUtil;

public class Invoker {
	private static ArrayList<CodeLists> dataList = new ArrayList<CodeLists>();
	private static ArrayList<String> corpusA = new ArrayList<String>();
	private static ArrayList<String> corpusB = new ArrayList<String>();
	private static ArrayList<String> corpusOrg = new ArrayList<String>();
	private static ArrayList<JavaFile> javaFiles = new ArrayList<>();
	
	public static void main(String[] args) throws Exception{
		// 1. parse the whole project to extract all the comments and determine its subject
		String directory = "C:\\Projects\\input_0111\\";
		getJavaFiles(directory);
		
		int count = 0;
		for (JavaFile f: javaFiles) {
			if (count++ % 10 == 0) System.out.println(f.getPack());
			// Use CommentCollector to analyze file f. Save comments and other
			// data in its codeLists.
			CommentCollector collector = new CommentCollector(f);
			collector.parse();
			CodeLists codeLists = collector.getCodeLists();
			dataList.add(codeLists);
			f.setCodeLists(codeLists);
			
			// Clean origin texts into two corpus for training.
			// corpusA.addAll(CorpusUtil.commentToCorpusA(codeLists));
			// corpusB.addAll(CorpusUtil.commentToCorpusB(codeLists));
			for (Comment cmt: codeLists.getAllComments()) {
				corpusOrg.add(cmt.getOrigText());
			}
		}
		//XMLUtil.printComments(dataList, "output\\temp.xlsx");
		 //XMLEditor.getCorpusFromSheet("total.xls", corpusA, corpusB);
		 //CorpusUtil.print(corpusA, "output\\corpusA.txt");
		 //CorpusUtil.print(corpusB, "output\\corpusB.txt");
		 CorpusUtil.print(corpusOrg, "output\\coutpusOrigin_joda.txt");
		
		//2. use the classifier to classify each comment
		//3. propagate each comment
	}
	

	private static void getJavaFiles(String dir) throws Exception {
		javaFiles = JavaFile.getJavaFiles(dir, "");
	}
}
