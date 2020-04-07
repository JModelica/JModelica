package org.jmodelica.junit;

import java.util.HashMap;
import java.util.Map;

public class UniqueNameCreator {

    private Map<String,Integer> nameIndex = new HashMap<>();

    public String makeUnique(String name) {
        if (nameIndex.containsKey(name)) {
            int i = nameIndex.get(name);
            nameIndex.put(name, i + 1);
            return name + "$" + i + "";
        } else {
            nameIndex.put(name, 0);
            return name;
        }
    }

}
