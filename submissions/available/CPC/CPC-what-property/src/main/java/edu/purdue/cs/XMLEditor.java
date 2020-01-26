//package edu.purdue.cs;
//
//import edu.purdue.cs.model.Comment;
//import edu.purdue.cs.parser.CommentParser;
//import edu.purdue.cs.parser.util.XMLUtil;
//import edu.purdue.cs.util.DataCleaner;
//import edu.stanford.nlp.trees.GrammaticalStructure;
//import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
//import org.apache.poi.ss.usermodel.CellType;
//import org.apache.poi.xssf.usermodel.XSSFCell;
//import org.apache.poi.xssf.usermodel.XSSFRow;
//import org.apache.poi.xssf.usermodel.XSSFSheet;
//import org.apache.poi.xssf.usermodel.XSSFWorkbook;
//
//import java.io.IOException;
//import java.util.ArrayList;
//import java.util.HashMap;
//
//public class XMLEditor {
//
//    public static void main(String[] args) throws IOException, InvalidFormatException {
//        int op = 2;
//        if (op == 0) {
//            XSSFSheet sheet1 = XMLUtil.loadSheet("output\\total_temp.xlsx");
//            XSSFSheet sheet2 = XMLUtil.loadSheet("output\\temp.xlsx");
//            combineLabel(sheet1, sheet2);
//            XMLUtil.printSheet(sheet1, "output\\1220_commons_io_2.xlsx");
//        } else if (op == 1) {
//            XSSFSheet sheet = XMLUtil.loadSheet("output\\new_apache_temp.xlsx");
//            addStanfordTree(sheet);
//            XMLUtil.printSheet(sheet, "output\\new_apache.xlsx");
//        } else if (op == 2) {
//            XSSFSheet sheet = XMLUtil.loadSheet("output\\new_apache_temp.xlsx");
//            XSSFSheet sheet1 = getLabledCmt(sheet);
//            XMLUtil.printSheet(sheet1, "output\\new_apache.xlsx");
//            sheet1.getWorkbook().close();
//        } else if (op == 3) {
//            XSSFSheet sheet = XMLUtil.loadSheet(
//                    "C:\\Users\\shiyu\\Documents\\Tencent Files\\397381595\\FileRecv\\apache.xlsx");
//            ArrayList<Comment> cmt = reformat(sheet);
//            XMLUtil.printComments2(cmt, "output\\new_apache_temp.xlsx");
//        }
//
//    }
//
//
//    public static void addStanfordTree(XSSFSheet sheet) {
//        for (int i = 1; i <= sheet.getLastRowNum(); i++) {
//            if (i % 100 == 0) System.out.println("[addStandformTree] " + i);
//            // Get original text of the comment.
//            String cmt = XMLUtil.getCell(sheet, i, 3);
//            String clean = XMLUtil.getCell(sheet, i, 25);
//
//            // Count #token1 and #token2.
//            XMLUtil.setNumericCell(sheet, i, 14, cmt.split(" ").length);
//            XMLUtil.setNumericCell(sheet, i, 15, clean.split(" ").length);
//
//
//            // Run Standford Parser to get the structure of the sentence.
//            GrammaticalStructure gs = CommentParser.parseString(cmt);
//
//            // Count #NP, #VP, #PP in the tree.
//            HashMap<String, Integer> count = CommentParser.nodeCount(gs.root());
//            XMLUtil.setNumericCell(sheet, i, 16, count.get("NP"));
//            XMLUtil.setNumericCell(sheet, i, 17, count.get("VP"));
//            XMLUtil.setNumericCell(sheet, i, 18, count.get("PP"));
//
//            // BFS order of the tree.
//            XMLUtil.setStringCell(sheet, i, 19, CommentParser.getBfsString(gs.root()));
//
//            // Add type dependencies.
//            count = CommentParser.getDependencies(gs);
//            int col = 20;
//            for (Entry<String, Integer> entry : count.entrySet()) {
//
//            }
//            XMLUtil.setNumericCell(sheet, i, 20, count.get("auxpass"));
//            XMLUtil.setNumericCell(sheet, i, 21, count.get("case"));
//            XMLUtil.setNumericCell(sheet, i, 22, count.get("tmod"));
//            XMLUtil.setNumericCell(sheet, i, 23, count.get("advmod"));
//            XMLUtil.setNumericCell(sheet, i, 24, count.get("preconj"));
//        }
//
//    }
//
//    /**
//     * Get manual lables from sheet2 to sheet1.
//     */
//    public static void combineLabel(XSSFSheet sheet1, XSSFSheet sheet2) {
//        HashMap<String, Integer> cmt = new HashMap<String, Integer>();
//        for (int i = 1; i <= sheet2.getLastRowNum(); i++) {
//            XSSFRow row = sheet2.getRow(i);
//            if (row == null) continue;
//            String temp = row.getCell(0).getStringCellValue()
//                    + row.getCell(1).getStringCellValue()
//                    + row.getCell(3).getStringCellValue();
//            if (temp.endsWith(".")) {
//                temp = temp.substring(0, temp.length() - 1).trim();
//            }
//            cmt.put(temp, i);
//
//            //System.out.println(temp);
//        }
//
//        for (int i = 1; i <= sheet1.getLastRowNum(); i++) {
//            XSSFRow row1 = sheet1.getRow(i);
//            if (row1 == null) continue;
//            String temp = row1.getCell(0).getStringCellValue()
//                    + row1.getCell(1).getStringCellValue()
//                    + row1.getCell(3).getStringCellValue();
//
//            //System.out.println(temp);
//            if (cmt.containsKey(temp)) {
//                //System.out.println(temp);
//                int j = cmt.get(temp);
//
//                XSSFRow row2 = sheet2.getRow(j);
//                for (int k = 6; k <= 10; k++) {
//                    if (row2.getCell(k) == null) continue;
//                    XMLUtil.setStringCell(sheet1, i, k,
//                            row2.getCell(k).getStringCellValue());
//                }
//
//                for (int k = 11; k <= 13; k++) {
//                    if (row2.getCell(k) == null) continue;
//                    XMLUtil.setNumericCell(sheet1, i, k,
//                            (int) row2.getCell(k).getNumericCellValue());
//                }
//            }
//        }
//    }
//
//    public static XSSFSheet getLabledCmt(XSSFSheet sheet) {
//        XSSFSheet ret = new XSSFWorkbook().createSheet();
//        int rownum = 0;
//        for (int i = 0; i <= sheet.getLastRowNum(); i++) {
//            XSSFRow row = sheet.getRow(i);
//            if (row != null && row.getCell(11) != null && row.getCell(6) != null
//                    && (i == 0 ||
//                    row.getCell(26).getStringCellValue().split(" ").length > 3
//                            && row.getCell(27).getStringCellValue().split(" ").length > 3)) {
//                for (int j = 0; j <= row.getLastCellNum(); j++) {
//                    XSSFCell cell = row.getCell(j);
//                    if (cell == null) continue;
//                    if (cell.getCellType() == CellType.NUMERIC) {
//                        XMLUtil.setNumericCell(ret, rownum, j, (int) cell.getNumericCellValue());
//                    } else {
//                        XMLUtil.setStringCell(ret, rownum, j, cell.getStringCellValue());
//                    }
//                }
//                rownum++;
//            }
//        }
//        return ret;
//    }
//
//    public static ArrayList<Comment> reformat(XSSFSheet sheet) {
//        ArrayList<Comment> ret = new ArrayList<Comment>();
//        for (int k = 0; k <= sheet.getLastRowNum(); k++) {
//            XSSFRow row = sheet.getRow(k);
//            if (row == null || row.getCell(0) == null) continue;
//            Comment cmt = new Comment();
//            if (row.getCell(1) != null) cmt.setPack(row.getCell(1).getStringCellValue());
//            if (row.getCell(0) != null) cmt.setOrigText(row.getCell(0).getStringCellValue());
//            if (row.getCell(3) != null) cmt.setSubject1(row.getCell(3).getStringCellValue());
//            if ("parameter".equals(cmt.getSubject1())) cmt.setSubject2("method");
//            if (row.getCell(4) != null) cmt.setCategory1(row.getCell(4).getStringCellValue());
//            if (row.getCell(5) != null) cmt.setSubCategory1(row.getCell(5).getStringCellValue());
//            if (row.getCell(7) != null) cmt.setCategory2(row.getCell(7).getStringCellValue());
//            if (row.getCell(8) != null) cmt.setSubCategory2(row.getCell(8).getStringCellValue());
//            // get className
//            String className = null;
//            if (cmt.getPack() != null) {
//                String[] tokens = cmt.getPack().split("\\/");
//                className = tokens[tokens.length - 1];
//            }
//            // get methodName
//            String str = row.getCell(0).getStringCellValue();
//            str = DataCleaner.clean(str);
//            cmt.setCleanText(str);
//            if (row.getCell(2) == null) {
//                cmt.setCleanA(str);
//                cmt.setCleanB(str);
//                ret.add(cmt);
//                continue;
//            }
//            str = row.getCell(2).getStringCellValue();
//            String methodName;
//            int i = str.length() - 1;
//            while (i >= 0 && str.charAt(i) != '(') i--;
//            if (i <= 0) methodName = null;
//            else {
//                int j = i - 1;
//                while (j >= 0 && str.charAt(j) != ' ') j--;
//                if (j < 0) methodName = null;
//                else methodName = str.substring(j + 1, i);
//            }
//            // get fieldName
//            str = "";
//            if (row.getCell(2) != null) str = row.getCell(2).getStringCellValue();
//            str = str.split("=")[0].split(";")[0].trim();
//            String[] tokens = str.split(" ");
//            String fieldName = tokens[tokens.length - 1];
//            // cleanA
//            str = "";
//            tokens = cmt.getOrigText().split("\\(\\)");
//            for (String item : tokens) str += " " + item;
//            str = str.trim();
//            cmt.setCleanA(DataCleaner.clean(str));
//            // cleanB
//            if (className != null) str = str.replace(className, "class");
//            if (fieldName != null) str = str.replace(fieldName, "field");
//            if (methodName != null) str = str.replace(methodName, "method");
//            cmt.setCleanB(DataCleaner.clean(str));
//
//            ret.add(cmt);
//        }
//        return ret;
//    }
//
//    public static void getCorpusFromSheet(String fin,
//                                          ArrayList<String> corpusA,
//                                          ArrayList<String> corpusB
//    ) throws InvalidFormatException, IOException {
//        XSSFSheet sheet = XMLUtil.loadSheet("output\\total.xlsx");
//        for (int k = 0; k <= sheet.getLastRowNum(); k++) {
//            XSSFRow row = sheet.getRow(k);
//            if (row == null) continue;
//            XSSFCell cell = row.getCell(26);
//            if (cell != null) corpusA.add(cell.getStringCellValue());
//            cell = row.getCell(27);
//            if (cell != null) corpusB.add(cell.getStringCellValue());
//        }
//    }
//
//}
