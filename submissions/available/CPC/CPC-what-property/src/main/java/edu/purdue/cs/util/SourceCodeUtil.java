package edu.purdue.cs.util;

import org.eclipse.jdt.core.dom.AST;
import org.eclipse.jdt.core.dom.ASTParser;
import org.eclipse.jdt.core.dom.CompilationUnit;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

/**
 * @author XiangzheXu
 * create-time: 2018/12/31
 */
public class SourceCodeUtil {
    public static String readFileToString(String filePath) throws IOException {
        BufferedReader reader = new BufferedReader(new FileReader(filePath));

        return read(reader);
    }

    private static String read(BufferedReader reader) throws IOException {
        StringBuilder fileData = new StringBuilder(16384);
        char[] buf = new char[1024];
        int numRead;
        while ((numRead = reader.read(buf)) != -1) {
            fileData.append(buf, 0, numRead);
        }

        reader.close();
        return fileData.toString();
    }


    public static String readFileToString(File file) throws IOException {
        BufferedReader reader = new BufferedReader(new FileReader(file));

        return read(reader);
    }

    public static CompilationUnit getCompilationUnit(String source) {
        ASTParser parser = ASTParser.newParser(AST.JLS10);

        parser.setResolveBindings(true);
        parser.setBindingsRecovery(true);
        parser.setSource(source.toCharArray());
        parser.setKind(ASTParser.K_COMPILATION_UNIT);
//		parser.setEnvironment( // apply classpath
//	            new String[] { "C:\\Projects\\git\\repository\\CommentCollection\\bin" }, //
//	            null, null, true);
        parser.setEnvironment( // apply classpath
                new String[]{""}, //
                null, null, true);

        parser.setUnitName("any_name");

        return (CompilationUnit) parser.createAST(null);
    }

}
