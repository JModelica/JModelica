package org.jmodelica.util.collections;

import java.util.Iterator;

public class EmptyIterable<T> implements Iterable<T> {

    @Override
    public Iterator<T> iterator() {
        return new EmptyIterator<T>();
    }

}
