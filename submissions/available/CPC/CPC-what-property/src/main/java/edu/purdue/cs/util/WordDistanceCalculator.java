package edu.purdue.cs.util;

import com.crtomirmajer.wmd4j.WordMovers;
import org.deeplearning4j.models.embeddings.loader.WordVectorSerializer;
import org.deeplearning4j.models.embeddings.wordvectors.WordVectors;

import java.io.*;
import java.util.HashSet;
import java.util.Objects;
import java.util.Scanner;
import java.util.function.Consumer;

import static edu.purdue.cs.ProjectPropagator.PROJECT_NAME;

/**
 * @author XiangzheXu
 * create-time: 2019-01-12
 */
public class WordDistanceCalculator {
    private static final String SEP = ",";
    //    private static File model = new File("corpusOrigin_vec.txt");
    public static boolean isMultiData = false;
    private static boolean isInit = false;
    private static File model = new File("data/embedding.txt");
    private static WordVectors vectors;
    private static WordMovers wm;
    private static PrintWriter writer;
    private static String ALL_IN_ONE = "all";
    //    private static File tmpLog = new File("n_distanceLog_" + PROJECT_NAME + ".csv");
    private static File tmpLog = new File("how_distance_log" + ".csv");
    private static File tmpLogMulti = new File("n_distanceLog_" + ALL_IN_ONE + ".csv");

    private WordDistanceCalculator() {

    }

    public synchronized static void init() {
        try {
            isInit = true;
            vectors = WordVectorSerializer.loadGoogleModel(model, false);
            HashSet<String> stopwords = new HashSet<>(DataCleaner.stopWords);
            wm = WordMovers.Builder().wordVectors(vectors).stopwords(stopwords).build();
            if (isMultiData) {
                if (!tmpLogMulti.exists()) {
                    tmpLogMulti.createNewFile();
                }
                writer = new PrintWriter(new FileOutputStream(tmpLogMulti));
            } else {
                if (!tmpLog.exists()) {
                    tmpLog.createNewFile();
                }
                writer = new PrintWriter(new FileOutputStream(tmpLog));
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        init();
        traverseFiles(new File("how/"), file -> {
            String fileName = file.getName();
            try {
                Scanner scanner = new Scanner(new FileInputStream(file));
                while (scanner.hasNextLine()) {
                    String s1 = scanner.nextLine().replaceAll(",", " ").trim();
                    String s2 = scanner.nextLine().replaceAll(",", " ").trim();
//                    System.out.println(DataCleaner.clean(cleanToPrint(s1)));
//                    System.out.println(DataCleaner.clean(cleanToPrint(s2)));
                    log(fileName.replace(".csv", ""), DataCleaner.clean(cleanToPrint(s1)), DataCleaner.clean(cleanToPrint(s2)), "from", "to", "how");
                }
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            }
        });

    }

    public static void traverseFiles(File fileToTraverse, Consumer<File> function) {
        if (!fileToTraverse.isDirectory()) {
            if (fileToTraverse.getName().matches(".*\\.csv")) {
                function.accept(fileToTraverse);
            }
        } else {
            for (File file : Objects.requireNonNull(fileToTraverse.listFiles())) {
                traverseFiles(file, function);
            }
        }

    }


    private synchronized static void log(String projectName, String s1, String s2, String from, String to, String others) {
        cleanAndLog(projectName, s1, s2, from, to, others);
    }

    private static void cleanAndLog(String projectName, String s1, String s2, String from, String to, String others) {
        if (!isInit) {
            init();
        }
        if (s1 == null || s2 == null) {
            return;
        }

        double distance;
        if (s1.isEmpty() || s2.isEmpty()) {
            distance = 0;
        } else {
            distance = calDistance(s1, s2);
        }
        String clean1 = cleanToPrint(s1);
        String clean2 = cleanToPrint(s2);
        String cleanFrom = cleanToPrint(from);
        String cleanTo = cleanToPrint(to);
        int lengthDistance = Math.abs(s1.length() - s2.length());
        double modifiedDistance = lengthDistance != 0 ? distance / lengthDistance : distance;
        String[] str = {
                cleanToPrint(projectName), others, String.valueOf(distance), String.valueOf(modifiedDistance), clean1, clean2, cleanFrom, cleanTo
        };
        writer.println(String.join(SEP, str));
        writer.flush();
    }

    public synchronized static void log(String s1, String s2, String from, String to, String others) {
        cleanAndLog(PROJECT_NAME, s1, s2, from, to, others);
    }

    private static String cleanToPrint(String s1) {
        return s1.replace(',', ';').replace('\'', ' ').replace('\"', ' ').replace("\n", " ");
    }

    public static double calDistance(String s1, String s2) {
        if (s1 == null || s2 == null || s1.isEmpty() || s2.isEmpty()) {
            return Double.MAX_VALUE;
        }
        String clean1 = DataCleaner.clean(s1).toLowerCase();
        String clean2 = DataCleaner.clean(s2).toLowerCase();

        return wm.distance(clean1, clean2);
    }

}
