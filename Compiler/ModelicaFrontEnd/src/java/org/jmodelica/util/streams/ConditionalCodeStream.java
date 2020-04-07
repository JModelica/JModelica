package org.jmodelica.util.streams;

import java.util.ArrayList;

public class ConditionalCodeStream extends CodeStream {
    
    private interface Op {
        abstract public void doit();
    }
    
    private class Print implements Op {
        protected String str;
        
        public Print(String s) {
            str = s;
        }

        @Override
        public void doit() {
            parent.print(str);
        }
    }
    
    private class Format implements Op {
        private String fmt;
        private Object[] args;

        public Format(String f, Object... a) {
            fmt = f;
            args = a;
        }

        @Override
        public void doit() {
            parent.format(fmt, args);
        }
    }
    
    private class NL implements Op {
        @Override
        public void doit() {
            parent.println();
        }
    }

    private boolean hasPrinted = false;
    private boolean bufferMode = false;
    private ArrayList<Op> buf = new ArrayList<>();
    
    public ConditionalCodeStream(CodeStream str) {
        super(str);
    }
    
    @Override
    public void close() {
        clear();
        buf = null;
    }
    
    @Override
    public void print(String s) {
        addOp(new Print(s));
    }
    
    @Override
    public void format(String fmt, Object... args) {
        addOp(new Format(fmt, args));
    }
    
    @Override
    public void println() {
        addOp(new NL());
    }

    private void addOp(Op op) {
        if (bufferMode) {
            buf.add(op);
        } else {
            hasPrinted = true;
            clear();
            op.doit();
        }
    }
    
    public void setBufferMode(boolean bufferMode) {
        this.bufferMode = bufferMode;
    }
    
    public void reset() {
        hasPrinted = false;
    }
    
    public void clear() {
        if (hasPrinted) {
            for (Op op : buf) {
                op.doit();
            }
            buf.clear();
        }
    }
}
