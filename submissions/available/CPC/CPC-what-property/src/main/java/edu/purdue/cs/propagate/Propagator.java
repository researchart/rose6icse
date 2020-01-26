package edu.purdue.cs.propagate;

import edu.purdue.cs.CodeLists;
import edu.purdue.cs.StatementBuilder;
import edu.purdue.cs.consistent.ExceptionVisitor;
import edu.purdue.cs.consistent.NullableVisitor;
import edu.purdue.cs.inner.InnerPropertyVisitor;
import edu.purdue.cs.propagator.PureMethodVisitor;
import edu.purdue.cs.propagator.property.PropertyVisitor;
import org.eclipse.jdt.core.dom.CompilationUnit;

import java.io.File;
import java.io.IOException;

import static edu.purdue.cs.util.SourceCodeUtil.getCompilationUnit;
import static edu.purdue.cs.util.SourceCodeUtil.readFileToString;

/**
 * @author XiangzheXu
 * create-time: 2018/12/31
 */
public class Propagator {
    private String src;
    private CodeLists codeLists;

    public Propagator(File src, CodeLists codeLists) {
        try {
            this.src = readFileToString(src);
        } catch (IOException e) {
            System.err.println("Error opening file " + src);
        }
        this.codeLists = codeLists;
    }

    public void count() {
        final CompilationUnit cu = getCompilationUnit(src);

        StatsVisitor methodVisitor = new StatsVisitor();
        methodVisitor.setCodeLists(codeLists);
        cu.accept(methodVisitor);

    }

    public void parse() {
        final CompilationUnit cu = getCompilationUnit(src);

        StatementBuilder builder = new StatementBuilder(codeLists);
        cu.accept(builder);

        InnerPropertyVisitor checker = new InnerPropertyVisitor(codeLists);
        cu.accept(checker);

        pureVisit(cu);

//        Callee2St callee2St = new Callee2St(codeLists);
//        cu.accept(callee2St);


        superClzVisit(cu);

        simpleMethodVisit(cu);

        exceptionVisit(cu);

        nullableVisit(cu);

        PropertyVisitor propertyVisitor = new PropertyVisitor(codeLists);
        cu.accept(propertyVisitor);


    }


    private void nullableVisit(CompilationUnit cu) {
        NullableVisitor nullableVisitor = new NullableVisitor(codeLists);
        cu.accept(nullableVisitor);
        cu.accept(nullableVisitor);
    }

    private void exceptionVisit(CompilationUnit cu) {
        ExceptionVisitor exceptionVisitor = new ExceptionVisitor(codeLists);
        cu.accept(exceptionVisitor);
        cu.accept(exceptionVisitor);
    }

    private void simpleMethodVisit(CompilationUnit cu) {
        SimpleMethodPropagator simpleMethodPropagator = new SimpleMethodPropagator(codeLists);
//        cu.accept(simpleMethodPropagator);
//        cu.accept(simpleMethodPropagator);
        cu.accept(simpleMethodPropagator);
        cu.accept(simpleMethodPropagator);
    }

    private void superClzVisit(CompilationUnit cu) {
        SuperClassVisitor superClassVisitor = new SuperClassVisitor(codeLists);
        cu.accept(superClassVisitor);
    }

    private void pureVisit(CompilationUnit cu) {
        PureMethodVisitor pureMethodVisitor = new PureMethodVisitor(codeLists);
        cu.accept(pureMethodVisitor);
        cu.accept(pureMethodVisitor);
        cu.accept(pureMethodVisitor);
    }
}
