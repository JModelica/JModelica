package org.jmodelica.util.formatting;

import beaver.Symbol;

public abstract class FormattingRecorder<T> {
    public abstract void addItem(FormattingType type, String data, int startLine, int startColumn, int endLine,
            int endColumn);
    public final void addItem(FormattingType type, String data, Symbol symbol) {
        addItem(type, data, Symbol.getLine(symbol.getStart()), Symbol.getColumn(symbol.getStart()),
                Symbol.getLine(symbol.getEnd()), Symbol.getColumn(symbol.getEnd()));
    }
    public abstract void reset();
    public abstract void postParsing(T t);
}
