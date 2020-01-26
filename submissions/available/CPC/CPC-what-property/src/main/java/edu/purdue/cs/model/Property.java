package edu.purdue.cs.model;

import lombok.Data;

import java.io.Serializable;

/**
 * @author XiangzheXu
 * create-time: 2019-01-23
 */
@Data
public class Property implements Serializable {
    private static final long serialVersionUID = 234567852L;

    private String property;
    private Possibility possibility;

    public boolean isPositivePossibility() {
        switch (possibility) {
            case MUST:
            case MAY_NOT:
            case CAN:
            case DEFAULT:
                return true;
            default:

        }
        return false;
    }
}
