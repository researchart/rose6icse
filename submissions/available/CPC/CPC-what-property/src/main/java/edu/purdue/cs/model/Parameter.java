package edu.purdue.cs.model;

import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.List;
import java.util.Set;

@EqualsAndHashCode(callSuper = true)
@Data
public class Parameter extends Subject {
    private String type;
    private Method method;
    private String value;
    private Integer rank;
    private List<Constrain> paramConstrains;
    private Set<String> tokens;
    private List<Property> properties;

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
        return super.getId();
    }
}
