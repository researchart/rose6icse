package edu.purdue.cs.model;

import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.ArrayList;

/**
 * create at: 12/15/2018
 */


@EqualsAndHashCode(callSuper = true)
@Data
public class Statement extends Subject {
    private ArrayList<Statement> statements = new ArrayList<>();

    private org.eclipse.jdt.core.dom.Statement astNode;

    private boolean pure;

    public Statement(org.eclipse.jdt.core.dom.Statement astNode) {
        this.astNode = astNode;
    }
}
