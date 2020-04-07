package org.jmodelica.util;

import beaver.Symbol;

public abstract class AbstractAdjustableSymbol extends Symbol implements AdjustableSymbol {

    private AdjustableSymbol[] children = null;

    public AbstractAdjustableSymbol() {}

    public AbstractAdjustableSymbol(AdjustableSymbol... children) {
        this.children = children;
    }

    public AbstractAdjustableSymbol(short id, int line, int column, int length, Object value) {
        super(id, line, column, length, value);
    }
    
    public AbstractAdjustableSymbol(short id, int start, int end, Object value) {
        super(id, start, end, value);
    }

    /* NB: This method is (mostly) duplicated in:
     * ModelicaFrontEnd/src/jastadd/source/Parser.jrag, ASTNode */
    @Override
    public int adjustStartOfEmptySymbols(AdjustableSymbol[] syms, int i, int last) {
        int value = last;
        if (i < syms.length) {
            value = syms[i].adjustStartOfEmptySymbols(syms, i + 1, last);
        }
        if (children != null) {
            value = children[0].adjustStartOfEmptySymbols(children, 1, value);
        }
        if (start == end && value != 0) {
            start = end = value;
        }
        return start;
    }

}
