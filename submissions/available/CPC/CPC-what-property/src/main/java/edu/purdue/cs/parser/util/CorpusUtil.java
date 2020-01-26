package edu.purdue.cs.parser.util;

import edu.purdue.cs.CodeLists;
import edu.purdue.cs.model.Class;
import edu.purdue.cs.model.*;
import edu.purdue.cs.util.DataCleaner;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;

public class CorpusUtil {
    public static void main(String[] args) {
        //DeleteParenthesesForMethod("I want to change add() to method.");
        //UseGeneralMethodName("I want to change add() to method.");
        //System.out.println(UseGeneralClassName("This list is a sublist of List.", "ArrayList"));
        //UseGeneralFieldName("Update myField.", "myField");
        //UseGeneralExceptionName("This method will throw NullPointerException.");
        //UseGeneralExceptionName("NullPointerException.");
    }

    public static ArrayList<String> commentToCorpusA(CodeLists codeLists) {
        ArrayList<String> ret = new ArrayList<String>();
        for (Comment cmt : codeLists.getAllComments()) {
            // System.out.println("Org: " + cmt.getOrigText());
            String str = cmt.getOrigText();
            // System.out.println("Cln: " + DeleteParenthesesForMethod(str) +"\n");
            String temp = DeleteParenthesesForMethod(str);
            cmt.setCleanA(DataCleaner.clean(temp));
            ret.add(cmt.getCleanA());

        }
        return ret;
    }

    public static ArrayList<String> commentToCorpusB(CodeLists codeLists) {
        ArrayList<String> ret = new ArrayList<String>();
        for (Class cls : codeLists.getClasses()) {
            for (Comment cmt : cls.getComments()) {
                String str = cmt.getOrigText();
                str = UseGeneralMethodName(str);
                str = UseGeneralClassName(str, cls.getId());
                if (str == "") str = cmt.getOrigText();
                cmt.setCleanB(DataCleaner.clean(str));
                ret.add(cmt.getCleanB());
            }


            for (Field field : cls.getFields()) {
                for (Comment cmt : field.getComments()) {
                    //System.out.println("Org: " + cmt.getOrigText());
                    String str = cmt.getOrigText();
                    str = UseGeneralMethodName(str);
                    str = UseGeneralClassName(str, cls.getId());
                    str = UseGeneralFieldName(str, cls);
                    if (str == "") str = cmt.getOrigText();
                    cmt.setCleanB(DataCleaner.clean(str));
                    ret.add(cmt.getCleanB());
                    //System.out.println("Cln: " + str);
                }
            }
            for (Method method : cls.getMethods()) {
                for (Comment cmt : method.getComments()) {
                    //System.out.println("Org: " + cmt.getOrigText());
                    String str = cmt.getOrigText();
                    str = UseGeneralMethodName(str);
                    str = UseGeneralClassName(str, cls.getId());
                    str = UseGeneralPrameterName(str, method);
                    str = UseGeneralFieldName(str, cls);
                    str = UseGeneralExceptionName(str);
                    if (str == "") str = cmt.getOrigText();
                    cmt.setCleanB(DataCleaner.clean(str));
                    ret.add(cmt.getCleanB());
                    //if (str.trim() != cmt.getOrigText()) System.out.println("Cln: " + str + "\n");
                }
            }

        }
        return ret;
    }

    /**
     * For corpus A. Example:
     * Input:  I want to change add() to method.
     * Output: I want to change add to method.
     */
    public static String DeleteParenthesesForMethod(String str) {
        String ret = "";
        for (String token : str.split("\\(\\)")) {
            ret += token;
        }
        // System.out.println("STR: " + str);
        // System.out.println("RET: " + ret);
        return ret;
    }

    /**
     * For corpus B. Example:
     * Input:  I want to change add() to method.
     * Output: I want to change method to method.
     */
    public static String UseGeneralMethodName(String str) {
        String ret = "";
        int count = 0;
        boolean flag = false;
        for (String token : str.split(" ")) {
            count += StringUtil.countChar(token, '(') - StringUtil.countChar(token, ')');
            if (token.contains("()") || flag || count != 0 && token.endsWith(",") ||
                    token.contains("(") && token.contains(")") && token.contains(".")) {
                if (!flag) ret += " method";
                if (token.endsWith(",") && count != 0) {
                    flag = true;
                } else if (token.endsWith(".")) ret += ".";
                if (count == 0) flag = false;
            } else {
                ret += " " + token;
            }

        }
        ret = ret.trim();
        if (StringUtil.countChar(ret, '(') != StringUtil.countChar(ret, ')')) {
            return str;
        }
        return ret;
    }

    /**
     * For corpus B. Example:
     * Input:   "This list is a sublist of List.", "ArrayList"
     * Output:  "This class is a sublist of List."
     */
    public static String UseGeneralClassName(String str, String clsName) {
        clsName = clsName.toLowerCase();
        String ret = "";
        int start = 0;
        for (int i = 0; i < str.length() - 6; i++) {
            int j = 0;
            if (i == 0 && str.substring(i, i + 5).equalsIgnoreCase("This ")) {
                j = i + 5;
            } else if (str.substring(i, i + 6).equalsIgnoreCase(" this ")) {
                j = i + 6;
            }
            if (j == 0) continue;
            int k = j;
            while (k < str.length() && StringUtil.isLetter(str, k)) k++;
            String objectName = str.substring(j, k).toLowerCase();
            //System.out.println(start + " " + j + " " + k);

            ret = ret + str.substring(start, j);
            if (clsName.length() >= objectName.length() &&
                    clsName.substring(clsName.length() - objectName.length())
                            .toLowerCase().endsWith(objectName)) {
                ret += "class";
            } else {
                ret += objectName;
            }
            start = k;
        }
        ret += str.substring(start);
        //System.out.println("STR: " + str);
        //System.out.println("RET: " + ret);

        return ret;
    }

    /**
     * Use "field" instead of fieldName.
     */
    public static String UseGeneralFieldName(String str, Class cls) {
        String ret = str;
        for (Field field : cls.getFields())
            if (field.getId() != field.getId().toLowerCase())
                ret = ret.replace(field.getId(), "field");
        return ret;
    }

    /**
     * Use "exception" instead of "**Exception".
     */
    public static String UseGeneralExceptionName(String str) {
        String[] tokens = str.split("Exception");
        String ret = "";
        for (int i = 0; i < tokens.length - 1; i++) {
            int j = tokens[i].length() - 1;
            while (j >= 0 && StringUtil.isLetter(tokens[i], j)) j--;
            //System.out.println("[" + tokens[i] + "]"  + "-> " + tokens[i].substring(0, j+1));
            ret += tokens[i].substring(0, j + 1) + "exception";
        }
        ret += tokens[tokens.length - 1];
        //System.out.println("STR: " + str);
        //System.out.println("RET: " + ret);
        return ret;
    }

    /**
     * Use "parameter" instead of its words in 8 cases.
     */
    public static String UseGeneralPrameterName(String str, Method method) {
        String ret = str;
        for (Parameter param : method.getParams()) {
            ArrayList<String> patterns = ParamIdentifier.getpatternsForParm(
                    param);
            // System.out.println(patterns);
            for (String p : patterns) {
                ret = ret.replace(p, "the param");
            }
        }
        return ret;
    }
	
	/*public static String UseGeneralExceptionName(String str) {
		String ret = new String(str);
		int i = ret.indexOf("Expection");
		while (i != -1) {
			int j = i-1;
			while (j > 0 && StringUtil.isLetter(ret, j)) j--;
			if (j+1 < i) {
				ret = ret.substring(0, j+1) + "exception" +
						ret.substring(i+9, ret.length());
				System.out.println(ret);
			}
		}
		return ret;
	}*/

    public static void print(ArrayList<String> corpus, String fileName)
            throws FileNotFoundException, UnsupportedEncodingException {
        PrintWriter writer = new PrintWriter(fileName, "UTF-8");
        for (String str : corpus) {
            if (str == "" || str.split(" ").length <= 3) continue;
            writer.println(str);
        }
        writer.close();
    }
}
