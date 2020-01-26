package edu.purdue.cs.util;

import java.io.File;
import java.util.Objects;
import java.util.concurrent.RecursiveAction;
import java.util.function.Consumer;

/**
 * @author XiangzheXu
 * create-time: 2019-02-01
 */
public class ConcurrentFileTraverser extends RecursiveAction {
    private static final int THRESHOLD = 3;
    private File dir;
    private Consumer<File> function;

    public ConcurrentFileTraverser(File dir, Consumer<File> function) {
        this.dir = dir;
        this.function = function;
    }

    @Override
    protected void compute() {
        traverseFiles(dir, function);
    }


    private void traverseFiles(File fileToTraverse, Consumer<File> function) {
        if (!fileToTraverse.isDirectory()) {
            if (fileToTraverse.getName().matches(".*\\.java")) {
                function.accept(fileToTraverse);
            }
        } else {
//            if (fileToTraverse.listFiles() != null && fileToTraverse.listFiles().length > 8) {
//                for (File file : Objects.requireNonNull(fileToTraverse.listFiles())) {
//                    ConcurrentFileTraverser concurrentFileTraverser = new ConcurrentFileTraverser(file, function);
//                    concurrentFileTraverser.fork();
//                }

//            }else {
//            List<ConcurrentFileTraverser> tasks = Collections.synchronizedList(new LinkedList<>());
            for (File file : Objects.requireNonNull(fileToTraverse.listFiles())) {
                if (file.isDirectory()) {
                    ConcurrentFileTraverser concurrentFileTraverser = new ConcurrentFileTraverser(file, function);
                    concurrentFileTraverser.fork();
                } else if (Objects.requireNonNull(fileToTraverse.listFiles()).length > THRESHOLD) {
                    ConcurrentFileTraverser concurrentFileTraverser = new ConcurrentFileTraverser(file, function);
                    concurrentFileTraverser.fork();
                } else {
                    traverseFiles(file, function);
                }
//                tasks.add(concurrentFileTraverser);
//                concurrentFileTraverser.join();
            }
//            tasks.parallelStream().forEach(ForkJoinTask::join);
//            }
        }

    }


}
