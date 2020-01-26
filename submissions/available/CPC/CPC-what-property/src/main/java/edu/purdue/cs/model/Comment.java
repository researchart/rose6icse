package edu.purdue.cs.model;

import lombok.Data;

import java.io.Serializable;


@Data
public class Comment implements Serializable {
    private static final long serialVersionUID = 2345689L;
    private int propagateLevel = 0;
    private String pack;
    private String tag; // @param, @throws, ......
    private String codeEntityId;

    private String category1;
    private String category2;
    private String subCategory1;
    private String subCategory2;
    private String subject1;
    private String subject2;

    private String origText; //the original comment text
    private String cleanText; //after cleaning like removing stop words etc. may not be used. currently we can just use the python script
    private String cleanA;
    private String cleanB;

//    private GrammaticalStructure gs;


}
