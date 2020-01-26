package cs.purdue.edu.propagate.util;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
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
import cs.purdue.edu.parser.util.XMLUtil;
import cs.purdue.edu.propagate.util.ExceptionUtil;
import cs.purdue.edu.propagate.util.ClonedMethod;
import cs.purdue.edu.propagate.util.CodeCloneUtil;
import cs.purdue.edu.propagate.util.ExceptionMethodVisitor;

public class DonePropagator {
	private static String projectDir = "C:\\Projects\\2019CommentPropagation\\Nicad _input\\input_apachedb\\";
	private static String fin = "C:\\Projects\\2019CommentPropagation\\data_how-it-is-done\\0.1\\apachedb.txt";
	private static String fout = "C:\\Projects\\2019CommentPropagation\\data_how-it-is-done\\0.1\\apachedb.xlsx";
	private static BufferedReader reader;
	
	public static void main(String[] args) throws Exception {
        System.out.println("Receiving " + args.length + " arguments.");
        if (args.length == 3) {
            projectDir = args[0];
            fin = args[1];
            fout = args[2];
        }
		ArrayList<JavaFile> javaFiles = JavaFile.getJavaFiles(projectDir);
		reader = new BufferedReader(new FileReader(fin));
		
		XSSFWorkbook workbook = new XSSFWorkbook();
		XSSFSheet sheet = workbook.createSheet();
		int rowNum = 0;
		XSSFRow row = sheet.createRow(rowNum++);
		row.createCell(0).setCellValue("Comment"); // Comment
		row.createCell(1).setCellValue("File_From"); // File From
		row.createCell(2).setCellValue("Method_From"); // method From
		row.createCell(3).setCellValue("File_To"); // File To
		row.createCell(4).setCellValue("Method_To"); // method to
		
		/* Get methods comments*/
		//int count = 0;
		for (JavaFile f: javaFiles) {
			//if (count++ % 10 == 0) System.out.println(f.getPack());
			
			CommentCollector collector = new CommentCollector(f);
			collector.parse();
			f.setCodeLists(collector.getCodeLists());
		}
		
		ArrayList<String> temp = new ArrayList<>();
		ArrayList<ArrayList<String>> mlist = new ArrayList<>();
		String str = "";
		while (!str.equals("-")) {
			str = reader.readLine();
			
			if (str.equals("*") || str.equals("-")) {
				if (!temp.isEmpty()) {
					mlist.add(temp);
					temp = new ArrayList<>();
				}
				
				ArrayList<String> filenames = new ArrayList<>();
				ArrayList<String> methodnames = new ArrayList<>();
				for (ArrayList<String> cm: mlist) {
					String[] tokens = cm.get(0).split(" ");
					String filename = tokens[0];
					int start = Integer.valueOf(tokens[1]);
					int end = Integer.valueOf(tokens[2]);
					String methodName = "";
					
					// Find Method Name
					for (JavaFile f: javaFiles) {
						if (!filename.equals(f.getPack())) continue;
						for (Method m: f.getCodeLists().methods) {
							if (m.getLineNumBegin() > start ||
									m.getLineNumEnd() < end) continue;
							methodName = m.getId();
							break;
						}
						break;
					}
					
					System.out.println(filename+methodName);
					filenames.add(filename);
					methodnames.add(methodName);
				}
				System.out.println();
				for (int i = 0; i < mlist.size(); i++) {
					for (int j = 0; j < mlist.size(); j++) {
						if (i == j) continue;
						ArrayList<String> m = mlist.get(i);
						for (int k = 1; k < m.size(); k++) {
							row = sheet.createRow(rowNum++);
							int col = 0;
							row.createCell(col++).setCellValue(m.get(k)); // Comment
							row.createCell(col++).setCellValue(filenames.get(i)); // File From
							row.createCell(col++).setCellValue(methodnames.get(i)); // method From
							row.createCell(col++).setCellValue(filenames.get(j)); // File To
							row.createCell(col++).setCellValue(methodnames.get(j)); // method to
						}
					}
				}
				mlist = new ArrayList<>();
			}
			else if (str.equals("#")) {
				if (!temp.isEmpty()) {
					mlist.add(temp);
					temp = new ArrayList<>();
				}
			}
			else {
				temp.add(str);
			}
		}
		
		FileOutputStream out = new FileOutputStream(new File(fout));
		// write operation workbook using file out object
		workbook.write(out);
		out.close();
		workbook.close();
	}
}
