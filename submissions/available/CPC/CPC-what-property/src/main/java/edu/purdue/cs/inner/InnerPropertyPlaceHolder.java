package edu.purdue.cs.inner;

import lombok.Data;

import java.util.HashSet;
import java.util.Set;

/**
 * @author XiangzheXu
 * create-time: 2019-01-29
 */
@Data
public class InnerPropertyPlaceHolder {
    private Set<InnerProperty> innerProperties = new HashSet<>();
}
