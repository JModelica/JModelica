package org.jmodelica.util.values;

public interface Evaluator<T extends Evaluable> {
    public ConstValue evaluate(T t);
}
