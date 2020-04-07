package org.jmodelica.common.ast.prefixes;

public enum EquationType {

    NORMAL,
    INITIAL;
    
    public boolean isInitial() {
        return this == INITIAL;
    }
    
}
