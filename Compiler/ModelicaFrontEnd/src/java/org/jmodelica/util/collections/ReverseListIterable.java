package org.jmodelica.util.collections;

import java.util.Iterator;
import java.util.List;

public class ReverseListIterable<T> implements Iterable<T> {

    private final List<T> list;

    public ReverseListIterable(List<T> list) {
        this.list = list;
    }

    @Override
    public Iterator<T> iterator() {
        return new ReverseListIterator<T>(list);
    }

}
