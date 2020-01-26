package edu.purdue.cs;

import edu.purdue.cs.model.Class;
import edu.purdue.cs.model.Comment;
import edu.purdue.cs.model.Constrain;
import edu.purdue.cs.model.Method;
import edu.purdue.cs.propagate.Propagator;
import edu.purdue.cs.util.SimpleCountVisitor;
import edu.purdue.cs.util.SourceCodeUtil;
import org.eclipse.jdt.core.dom.CompilationUnit;

import java.io.*;
import java.util.*;
import java.util.function.Consumer;
import java.util.stream.Collectors;

public class ProjectPropagator {
    // do not analyze the projects
    // whose names are listed as follows
    public static final String[] ignoredString = {
//            "apacheDB-trunk",
//            "collections",
//            "guava",
//            "jdk",
//            "joda",
            "test",
    };
    // the source projects of propagation
    public static final String SRC_DIR = "data/source/";
    // the target projects of propagation
    public static final String TARGET_DIR = "data/aim/";
    public static Set<String> ignored = new HashSet<>();
    // project name to propagate
    public static String PROJECT_NAME = "jdk";

    //
    private static CommentCollector collector = null;
    private static CodeLists jdkCodeLists = null;
    private static Double allProgress = 0.0;
    private static Double nowProgress = 0.0;
    private static CodeLists codeLists = new CodeLists();

    static {
        ignored.addAll(Arrays.asList(ignoredString));
    }

    public static void init(String dataSrc) {
        PROJECT_NAME = dataSrc;
        collector = null;
        codeLists = new CodeLists();
    }

    private static synchronized double increaseProgressAndGet() {
        return ++nowProgress;
    }

    private static void propagate() {
        File propagateDir = new File(TARGET_DIR + PROJECT_NAME);
        traverseFiles(propagateDir, file -> {
            System.out.println(increaseProgressAndGet() + "/" + allProgress + "  pro " + file.toString());

            new Propagator(file, codeLists).parse();
        });
    }

    public static void main(String[] args) {

        if (ignored.contains(PROJECT_NAME)) {
            return;
        }

        loadSourceAndJDK();

        prePropagate();

        propagate();


    }

    private static void loadSourceAndJDK() {
        File jdkFile = new File("jdk_tmp_data_serial");

        //add jdk
        if (!PROJECT_NAME.contains("jdk")) {
            loadJDK(jdkFile);
            allProgress = 0.0;
            nowProgress = 0.0;
            scanData();
        } else {
            scanData();
//            loadJDK(jdkFile);
        }
    }

    private static void prePropagate() {
        generateMethodConstrains(codeLists);

        stats();
    }

    private static void loadJDK(File jdkFile) {
        System.out.println("Loading JDK . . . ");
        if (jdkCodeLists == null) {
            jdkCodeLists = new CodeLists();
            if (!jdkFile.exists()) {
                traverseFiles(new File(SRC_DIR + "jdk"), file -> {
                    System.out.println(file.toString());
                    collector = new CommentCollector(file.getParent(), file.getName(), jdkCodeLists);
                    collector.parse();

                });
                try {
                    jdkFile.createNewFile();
                    ObjectOutputStream os = new ObjectOutputStream(new FileOutputStream(jdkFile));
                    os.writeObject(jdkCodeLists);
                    os.flush();
                    os.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            } else {
                try {
                    ObjectInputStream in = new ObjectInputStream(new FileInputStream(jdkFile));
                    jdkCodeLists = ((CodeLists) in.readObject());
                } catch (IOException | ClassNotFoundException e) {
                    e.printStackTrace();
                }
            }
            generateMethodConstrains(jdkCodeLists);
        }//end-if jdk==null
    }

    private static void generateMethodConstrains(CodeLists codeLists) {
        List<Method> methods = codeLists.getClasses()
                .stream()
                .map(Class::getMethods)
                .flatMap(Collection::stream)
                .collect(Collectors.toList());

        for (Method method : methods) {
            for (Comment exception : method.getExceptions()) {
                Constrain constrain = new Constrain(exception, method.getParamList());
                method.getMethodConstrains().add(constrain);
            }
        }


    }

    private static void scanData() {
        File scanDir = new File(SRC_DIR + PROJECT_NAME);
//        SimpleCountVisitor.init();
        traverseFiles(scanDir, file -> {
            allProgress++;
            System.out.println(allProgress + "  " + file.toString());
            collector = new CommentCollector(file.getParent(), file.getName(), codeLists);
            collector.parse();

//            simpleCount(file);

        });
        codeLists.getClasses().addAll(jdkCodeLists.getClasses());
//        System.out.println(PROJECT_NAME + "  loc: " + SimpleCountVisitor.getLoc() + "  clzNumber:" + SimpleCountVisitor.getClassNumber());
    }

    private static void simpleCount(File file) {
        SimpleCountVisitor simpleCountVisitor = new SimpleCountVisitor();
        try {
            String source = SourceCodeUtil.readFileToString(file);
            CompilationUnit cu = SourceCodeUtil.getCompilationUnit(source);
            cu.accept(simpleCountVisitor);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    public static void traverseFiles(File fileToTraverse, Consumer<File> function) {
        if (!fileToTraverse.isDirectory()) {
            if (fileToTraverse.getName().matches(".*\\.java")) {
                function.accept(fileToTraverse);
            }
        } else {
            for (File file : Objects.requireNonNull(fileToTraverse.listFiles())) {
                traverseFiles(file, function);
            }
        }

    }


    public static void stats() {
        File statsDir = new File("target/" + PROJECT_NAME);
        traverseFiles(statsDir, file -> {
            new Propagator(file, codeLists).count();
            System.out.println("cnt " + file.toString());
        });
    }

}
