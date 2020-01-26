package cs.purdue.edu.propagate.util;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import cs.purdue.edu.CommentCollector;
import cs.purdue.edu.model.JavaFile;
import cs.purdue.edu.model.Method;

public class CommentCmpTool2 {
	private static String projectName = "guava";
	private static boolean hasDistance = false;

	private static String projectDir = "C:\\Projects\\2019CommentPropagation\\Nicad _input\\input_" + projectName + "\\";
	private static String dir = "C:\\Projects\\2019CommentPropagation\\data_how-it-is-done\\0.1\\";
	private static String finName = dir + projectName + ".txt";
	private static String foutName = dir + projectName + "_" + String.valueOf(hasDistance) + ".xlsx";

	private static ArrayList<JavaFile> javaFiles = null;
	
	
	public static void main(String[] args) throws Exception {
		// TODO Auto-generated method stub
		BufferedReader reader = new BufferedReader(new FileReader(finName));
		
		XSSFWorkbook workbook = new XSSFWorkbook();
		XSSFSheet sheet = workbook.createSheet();
		int rowNum = 0;
		XSSFRow row = sheet.createRow(rowNum++);
		int col = 0;
		row.createCell(col++).setCellValue("Project");
		row.createCell(col++).setCellValue("New_Comment"); // Comment
		row.createCell(col++).setCellValue("Existing_Comment"); // Comment
		row.createCell(col++).setCellValue("File_From"); // File From
		row.createCell(col++).setCellValue("Method_From"); // method From
		row.createCell(col++).setCellValue("File_To"); // File To
		row.createCell(col++).setCellValue("Method_To"); // method to
		
		
		/* Get methods comments*/
		javaFiles = JavaFile.getJavaFiles(projectDir);
		for (JavaFile f: javaFiles) {
			CommentCollector collector = new CommentCollector(f);
			collector.parse();
			f.setCodeLists(collector.getCodeLists());
		}
		
		
		int mtdNum = 0; // method number
		int[] cmtNum = new int[100];   // comment number
		String[][] cmt = new String[100][100];
		String[] fileNames = new String[100];
		String[] methodNames = new String[100];
		
		Set<String> mtdName  = new HashSet<String>();
		mtdName.clear();
		
		String str = reader.readLine();
		while (true) {
			//System.out.println("str = " + str);
			if ("*".equals(str) || "-".equals(str)) {
				// Compare comments
				
				// New 
				//for (int i = 1; i <= mtdNum; i++) propCmtNum += cmtNum[i] * (mtdNum - 1);
				
				// Compare inside pairs
				for (int i = 1; i < mtdNum; i++) {	// method_i
					for (int j = 1; j <= mtdNum; j++) {	//method_j
						if (i == j) continue;
						
						for (int k = 1; k <= cmtNum[i]; k++) {
							if (cmtNum[j] == 0) {
								if (!hasDistance) {
									row = sheet.createRow(rowNum++);
									col = 0;
									row.createCell(col++).setCellValue(projectName);
									row.createCell(col++).setCellValue(cmt[i][k]); // Comment
									row.createCell(col++).setCellValue(""); // Comment
									row.createCell(col++).setCellValue(fileNames[i]); // File From
									row.createCell(col++).setCellValue(methodNames[i]); // method From
									row.createCell(col++).setCellValue(fileNames[j]); // File To
									row.createCell(col++).setCellValue(methodNames[j]); // method to
									row.createCell(col++).setCellValue("NEW"); // dis
									row.createCell(col++).setCellValue("NEW"); // modified dis
								}
								continue;
							}
							
							int sameInd = -1;					
							for (int l = 1; l <= cmtNum[j]; l++) {
								if (cmt[i][k].equals(cmt[j][l])) {
									sameInd = l; break;
								}
							}
							if (sameInd > 0) {				// dist = 0, no need to compute distance. // Same!
								if (!hasDistance) {
									row = sheet.createRow(rowNum++);
									col = 0;
									row.createCell(col++).setCellValue(projectName);
									row.createCell(col++).setCellValue(cmt[i][k]); // Comment
									row.createCell(col++).setCellValue(cmt[j][sameInd]); // Comment
									row.createCell(col++).setCellValue(fileNames[i]); // File From
									row.createCell(col++).setCellValue(methodNames[i]); // method From
									row.createCell(col++).setCellValue(fileNames[j]); // File To
									row.createCell(col++).setCellValue(methodNames[j]); // method to
									row.createCell(col++).setCellValue("0"); // dis
									row.createCell(col++).setCellValue("0"); // modified dis
								}
								continue;
							}
							// otherwise, find the most similar one.
							int min = findMinDist(cmt[i][k], cmt[j], cmtNum[j]);
							if (hasDistance) {
								row = sheet.createRow(rowNum++);
								col = 0;
								row.createCell(col++).setCellValue(projectName);
								row.createCell(col++).setCellValue(cmt[i][k]); // Comment
								row.createCell(col++).setCellValue(cmt[j][min]); // Comment
								row.createCell(col++).setCellValue(fileNames[i]); // File From
								row.createCell(col++).setCellValue(methodNames[i]); // method From
								row.createCell(col++).setCellValue(fileNames[j]); // File To
								row.createCell(col++).setCellValue(methodNames[j]); // method to
							}
						}
						
						
						
					}
				}
				// initialization for a new pair
				mtdNum = 0;
				if ("-".equals(str)) break;
			}
			else if ("#".equals(str)) {		// str == "#"
				mtdNum++;
				cmtNum[mtdNum] = 0;
				str = reader.readLine();    // Method's name & line.
				mtdName.add(str);   // Count the number of related methods.
				fileNames[mtdNum] = str.split(" ")[0];
				methodNames[mtdNum] = getMethodName(str);
			}
			else {			// comment
				// System.out.println(cmtNum[mtdNum] + ", " + mtdNum);
				cmt[mtdNum][++cmtNum[mtdNum]] = str;
			}
			str = reader.readLine();
		}
				
		
		reader.close();
		
		FileOutputStream out = new FileOutputStream(new File(foutName));
		// write operation workbook using file out object
		workbook.write(out);
		out.close();
		workbook.close();
	}
	
	static private int findMinDist(String str, String[] cmt, int n) {
		int ret = 1;
		int min = distance(str.split(" "), cmt[1].split(" "));
		for (int i = 2; i <= n; i++) {
			int temp = distance(str.split(" "), cmt[i].split(" "));
			if (temp < min) {
				min = temp;
				ret = i;
			}
		}
		return ret;
	}
	
	static private String getMethodName(String lineStr) {
		String[] tokens = lineStr.split(" ");
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
		return methodName;
	}
	
	static private int distance(String[] s1, String[] s2) {
		int l1 = s1.length;
		int l2 = s2.length;
		int[][] f = new int[100][100];
		int ret = 0;
		for (int i = 0; i < l1; i++) {
			for (int j = 0; j < l2; j++) {
				f[i][j] = 0;
				if (i-1 >= 0) f[i][j] = max(f[i-1][j], f[i][j]);
				if (j-1 >= 0) f[i][j] = max(f[i][j-1], f[i][j]);
				
				if (s1[i].equals(s2[j])) {
					if (i == 0 || j == 0) f[i][j] = max(1, f[i][j]);
					else f[i][j] = max(f[i-1][j-1], f[i][j]);
				}
				
				ret = max(ret, f[i][j]);
			}
		}
		return ret;
	}
	
	static private int max(int a, int b) {
		if (a > b) return a;
		return b;
	}

}
