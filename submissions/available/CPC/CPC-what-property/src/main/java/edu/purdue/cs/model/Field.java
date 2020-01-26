package edu.purdue.cs.model;

public class Field extends Subject {
    private String type;
    private Class cls;
    private String value;

    public String getType() {
        return this.type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public void setClass(Class cls) {
        this.cls = cls;
    }

    // "getClass" is a method of Object<> in java, so use "getCls" here.
    public Class getCls() {
        return this.cls;
    }

    public String getValue() {
        return this.value;
    }

    public void setValue(String value) {
        this.value = value;
    }

}
