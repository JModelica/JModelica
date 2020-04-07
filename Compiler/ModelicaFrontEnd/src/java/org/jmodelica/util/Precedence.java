package org.jmodelica.util;

public enum Precedence {
    LOWEST,
    CONDITIONAL,
    ARRAY_RANGE,
    LOGICAL_OR,
    LOGICAL_AND,
    UNARY,
    RELATIONAL,
    ADDITIVE,
    MULTIPLICATIVE,
    EXPONENTIATION,
    HIGHEST;

    /**
     * Computes whether an expression with this precedence needs parenthesis
     * given that it is surrounded by an expression with supplied precedence.
     * 
     * @param parentPrecedence Precedence of surrounding expression
     * @return true if parenthesis should be printed around this expression.
     */
    public boolean needParenthesis(Precedence parentPrecedence, boolean forceIfEqual) {
        return ordinal() < parentPrecedence.ordinal() || this == parentPrecedence && forceIfEqual;
    }

}
