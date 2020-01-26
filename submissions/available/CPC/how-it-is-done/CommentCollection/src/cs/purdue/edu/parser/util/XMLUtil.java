package cs.purdue.edu.parser.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;

import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbookFactory;

import cs.purdue.edu.CodeLists;
import cs.purdue.edu.model.Comment;

public class XMLUtil {
	public static void printComments(ArrayList<CodeLists> dataLists, String fout) throws IOException {
		XSSFWorkbook workbook = new XSSFWorkbook();
		XSSFSheet sheet = workbook.createSheet();
		int rowNum = 0;
		XSSFRow row = sheet.createRow(rowNum++);
		writeFirstLine(row);
		for (CodeLists Lists : dataLists) {
			for (Comment cmt : Lists.getAllComments()) {
				// System.out.println(cmt.getOrigText());
				printCommentToRow(sheet.createRow(rowNum++), cmt);
			}
		}
		printSheet(sheet, fout);
		workbook.close();
	}
	
	public static void printComments2(ArrayList<Comment> comments, String fout) throws IOException {
		XSSFWorkbook workbook = new XSSFWorkbook();
		XSSFSheet sheet = workbook.createSheet();
		int rowNum = 0;
		XSSFRow row = sheet.createRow(rowNum++);
		writeFirstLine(row);
		for (Comment cmt : comments) {
			printCommentToRow(sheet.createRow(rowNum++), cmt);
		}
		printSheet(sheet, fout);
		workbook.close();
	}

	public static void printCommentToRow(XSSFRow row, Comment cmt) {
		int i = 0;
		row.createCell(i++).setCellValue(cmt.getPack());
		row.createCell(i++).setCellValue(cmt.getCodeEntityId());
		row.createCell(i++).setCellValue(cmt.getTag());
		row.createCell(i++).setCellValue(cmt.getOrigText());
		row.createCell(i++).setCellValue(cmt.getSubject1());
		row.createCell(i++).setCellValue(cmt.getSubject2());
		row.createCell(i++).setCellValue(cmt.getCategory1());
		row.createCell(i++).setCellValue(cmt.getSubCategory1());
		row.createCell(i++).setCellValue(cmt.getCategory2());
		row.createCell(i++).setCellValue(cmt.getSubCategory2());
		i = 25;
		row.createCell(i++).setCellValue(cmt.getCleanText());
		row.createCell(i++).setCellValue(cmt.getCleanA());
		row.createCell(i++).setCellValue(cmt.getCleanB());
	}
	
	public static void writeFirstLine(XSSFRow row) {
		int i = 0;
		row.createCell(i++).setCellValue("pack"); // 0
		row.createCell(i++).setCellValue("CodeEntityId"); 
		row.createCell(i++).setCellValue("tag"); 
		row.createCell(i++).setCellValue("origText");
		row.createCell(i++).setCellValue("subject1");
		row.createCell(i++).setCellValue("subject2"); //5
		row.createCell(i++).setCellValue("category1"); 
		row.createCell(i++).setCellValue("subCategory1");
		row.createCell(i++).setCellValue("category2");
		row.createCell(i++).setCellValue("subCategory2");
		row.createCell(i++).setCellValue("verb_type"); // 10
		row.createCell(i++).setCellValue("#local_variable"); 
		row.createCell(i++).setCellValue("#classes");
		row.createCell(i++).setCellValue("#methods");
		row.createCell(i++).setCellValue("#token1");
		row.createCell(i++).setCellValue("#token2"); // 15
		row.createCell(i++).setCellValue("#NP"); 
		row.createCell(i++).setCellValue("#PP");
		row.createCell(i++).setCellValue("#VP");
		row.createCell(i++).setCellValue("tree");
		row.createCell(i++).setCellValue("#auxpass"); // 20
		row.createCell(i++).setCellValue("#case"); 
		row.createCell(i++).setCellValue("#tmod"); 
		row.createCell(i++).setCellValue("#advmod");
		row.createCell(i++).setCellValue("#preconj");
		row.createCell(i++).setCellValue("cleanText"); //25
		row.createCell(i++).setCellValue("cleanA"); 
		row.createCell(i++).setCellValue("cleanB"); 
	}
	
	public static XSSFSheet loadSheet(String fin) 
			throws IOException, InvalidFormatException {
		XSSFWorkbook workbook = XSSFWorkbookFactory.createWorkbook(new FileInputStream(fin));
		XSSFSheet sheet = workbook.getSheetAt(0);
		return sheet;
	}

	public static void setStringCell(XSSFSheet sheet, int rowNum, int colNum, String str) {
		// System.out.println("[setCell] "+rowNum+", "+colNum+", "+str);
		XSSFRow row = sheet.getRow(rowNum);
		if (row == null)
			sheet.createRow(rowNum).createCell(colNum).setCellValue(str);
		else {
			XSSFCell cell = row.getCell(colNum);
			if (cell == null) row.createCell(colNum).setCellValue(str);
			else cell.setCellValue(str);
		}
	}
	
	public static void setNumericCell(XSSFSheet sheet, int rowNum, int colNum, int num) {
		// System.out.println("[setCell] "+rowNum+", "+colNum+", "+str);
		XSSFRow row = sheet.getRow(rowNum);
		if (row == null)
			sheet.createRow(rowNum).createCell(colNum).setCellValue(num);
		else {
			XSSFCell cell = row.getCell(colNum);
			if (cell == null) row.createCell(colNum).setCellValue(num);
			else cell.setCellValue(num);
		}
	}
	
	public static String getCell(XSSFSheet sheet, int rowNum, int colNum) {
		return sheet.getRow(rowNum).getCell(colNum).getStringCellValue();
	}

	public static void printSheet(XSSFSheet sheet, String fout) throws IOException {
		// Create file system using specific name
		FileOutputStream out = new FileOutputStream(new File(fout));

		// write operation workbook using file out object
		XSSFWorkbook workbook = sheet.getWorkbook();
		workbook.write(out);
		out.close();
		workbook.close();
		System.out.println("XLSX is written successfully");
	}
}
