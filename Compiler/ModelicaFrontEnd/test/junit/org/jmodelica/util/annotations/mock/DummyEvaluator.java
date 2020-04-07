package org.jmodelica.util.annotations.mock;

import org.jmodelica.util.values.ConstValue;
import org.jmodelica.util.values.Evaluable;
import org.jmodelica.util.values.Evaluator;

public class DummyEvaluator implements Evaluator<DummyEvaluator>, Cloneable, Evaluable {

    ConstValue myValue;

    public DummyEvaluator(int value) {
        myValue = new DummyCValueInteger(value);
    }

    public DummyEvaluator(String value) {
        myValue = new DummyCValueString(value);
    }

    @Override
    public ConstValue evaluateValue() {
        return null;
    }

    @Override
    public ConstValue evaluate(DummyEvaluator t) {
        if (t == null) {
            return null; 
        }
        return new DummyCValueInteger(1);
    }

    public class DummyCValueInteger extends ConstValue {
        int value;

        public DummyCValueInteger(int i) {
            value = i;
        }

        @Override
        public int intValue() {
            return value;
        }

        @Override
        public String stringValue() {
            return String.valueOf(value);
        }

        @Override
        public boolean isInteger() {
            return true;
        }
    }

    public class DummyCValueString extends ConstValue {
        String value;

        public DummyCValueString(String s) {
            this.value = s;
        }

        @Override
        public int intValue() {
            return Integer.parseInt(value);
        }

        @Override
        public String stringValue() {
            return value;
        }

        @Override
        public boolean isString() {
            return true;
        }
    }

    @Override
    public String toString() {
        return myValue.stringValue();
    }

}
