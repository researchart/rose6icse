package cs.purdue.edu.model;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

import org.eclipse.jdt.core.dom.CompilationUnit;

import cs.purdue.edu.CodeLists;
import cs.purdue.edu.parser.util.Pair;
import cs.purdue.edu.parser.util.ParserUtil;

public class JavaFile {
	private String src;
	private String dir;
	private String pack;
	private CompilationUnit cu;

	private CodeLists codeLists;
	private ArrayList<Pair<Integer, Integer>> throwLineNums = new ArrayList<>();
	
	public JavaFile(String directory, String packagePath) throws IOException {
		dir = directory;
		pack = packagePath;
		src = readFileToString(dir+pack);
        System.out.println(src); 
		cu = ParserUtil.getCompilationUnit(src);
	}
	
	public void addThrowStatement(int begin, int end) {
		throwLineNums.add(new Pair(begin, end));
	}

	public boolean IsThrowStatement(int lineNum) {
		for (Pair<Integer, Integer> i: throwLineNums) {
			if (lineNum >= i.first && lineNum <= i.second) 
				return true;
		}
		return false;
	}
	
	public ArrayList<Pair<Integer, Integer>> getThrowLineNums() {
		return throwLineNums;
	}
	
	// read file content into a string
	public static String readFileToString(String filePath) throws IOException {
		StringBuilder fileData = new StringBuilder(1000);
		BufferedReader reader = new BufferedReader(new FileReader(filePath));

		char[] buf = new char[10];
		int numRead = 0;
		while ((numRead = reader.read(buf)) != -1) {
			String readData = String.valueOf(buf, 0, numRead);
			fileData.append(readData);
			buf = new char[1024];
		}

		reader.close();
		return fileData.toString();
	}
	
	public static ArrayList<JavaFile> getJavaFiles(String dir)
			throws Exception {
		return getJavaFiles(dir, "");
	}
	
	public static ArrayList<JavaFile> getJavaFiles(String dir, String path)
			throws Exception {
		System.out.println(dir + " + " + path);
		ArrayList<JavaFile> ret = new ArrayList<>();
		File[] files = new File(dir+path).listFiles();
		
		for (File item: files) {
			if (item.isDirectory())
				ret.addAll(getJavaFiles(dir, path + item.getName() + "/"));
			else 
                if (item.getName().endsWith(".java"))
				    ret.add(new JavaFile(dir, path + item.getName()));
		}
		return ret;
	}
	
	public String getSrc() {
		return src;
	}

	public void setSrc(String src) {
		this.src = src;
	}

	public String getDir() {
		return dir;
	}

	public void setDir(String dir) {
		this.dir = dir;
	}

	public String getPack() {
		return pack;
	}

	public void setPack(String pack) {
		this.pack = pack;
	}

	public CompilationUnit getCu() {
		return cu;
	}

	public void resetCu() {
		this.cu = ParserUtil.getCompilationUnit(src);
	}
	
	public CodeLists getCodeLists() {
		return codeLists;
	}

	public void setCodeLists(CodeLists codeLists) {
		this.codeLists = codeLists;
	}
}
