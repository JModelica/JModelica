package org.jmodelica.util.collections;

import java.util.Iterator;

public class SingleIterable<T> implements Iterable<T> {

    protected T elem;

    public SingleIterable(T e) {
        elem = e;
    }

    @Override
    public Iterator<T> iterator() {
        return new SingleIterator<T>(elem);
    }

}
