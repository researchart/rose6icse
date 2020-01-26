package edu.purdue.cs.model;

import lombok.Data;

@Data
public class Variable extends Subject {
    private String type;
    private Method method;
    private String value;
    private boolean fromParam;


    public String getType() {
        return this.type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Method getMethod() {
        return this.method;
    }

    public void setMethod(Method method) {
        this.method = method;
    }

    public String getValue() {
        return this.value;
    }

    public void setValue(String value) {
        this.value = value;
    }


    @Override
    public String toString() {
        return getId();
    }
}
