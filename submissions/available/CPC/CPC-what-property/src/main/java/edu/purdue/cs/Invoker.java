package edu.purdue.cs;

import edu.purdue.cs.util.WordDistanceCalculator;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Objects;

public class Invoker {
    public static final String SEP = " ============================ ";
    private static ArrayList<String> fileList = new ArrayList<String>();
    private static int i = 0;

    public static void main(String[] args) {
        WordDistanceCalculator.isMultiData = true;
        try {
            WordDistanceCalculator.init();
        } catch (Exception throwable) {
            System.out.println("No log class is found, but it's OK");
        }
        File propagateDir = new File("data/aim/");
        assert propagateDir.listFiles() != null;
        int length = propagateDir.listFiles().length;
        Arrays.stream(propagateDir.listFiles())
                .filter(Objects::nonNull)
                .forEach(file -> {
                    System.out.println(SEP + i++ + "/" + length + SEP);
                    ProjectPropagator.init(file.getName());
                    ProjectPropagator.main(args);
                });
    }


}
