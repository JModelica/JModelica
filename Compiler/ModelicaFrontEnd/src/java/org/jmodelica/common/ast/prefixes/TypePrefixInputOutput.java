package org.jmodelica.common.ast.prefixes;

// TODO Rename class
public enum TypePrefixInputOutput {

    NONE(""),
    INPUT("input"),
    OUTPUT("output"),
    POTENTIAL("potential"),
    FLOW("flow"),
    STREAM("stream"),
    INSTREAM("inStream");
    
    private String toString;
    
    private TypePrefixInputOutput(String toString) {
        this.toString = toString;
    }
    
    public boolean isNone() {
        return this == NONE;
    }
    
    public boolean inputCausality() {
        return this == INPUT || this == FLOW || this == INSTREAM;
    }
    
    public boolean outputCausality() {
        return this == OUTPUT || this == POTENTIAL || this == STREAM;
    }
    
    public boolean isConnectorPrefix() {
        return this == POTENTIAL || this == FLOW || this == STREAM || this == INSTREAM;
    }
    
    @Override
    public String toString() {
        return toString;
    }
    
    public VisibilityType functionVisibility() {
        return isNone() ? VisibilityType.PROTECTED : VisibilityType.PUBLIC;
    }
    
}
