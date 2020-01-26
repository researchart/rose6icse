package edu.purdue.cs;

import java.io.File;

import static edu.purdue.cs.ProjectPropagator.SRC_DIR;

/**
 * @author XiangzheXu
 * create-time: 2019-01-30
 */
public class CommentPrinterInvoker {
    private static CodeLists codeLists = new CodeLists();

    private static void print() {
        File printDir = new File(SRC_DIR);
        ProjectPropagator.traverseFiles(printDir, file -> {
            System.out.println("print " + file.toString());
            CommentPrinterCollector collector = new CommentPrinterCollector(file.getParent(), file.getName(), codeLists);
            collector.parse();
        });
    }

    public static void main(String[] args) {


        print();

    }


}
