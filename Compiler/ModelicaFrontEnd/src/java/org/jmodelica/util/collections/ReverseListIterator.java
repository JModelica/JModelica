package org.jmodelica.util.collections;

import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;

public class ReverseListIterator<T> implements Iterator<T> {
    private final ListIterator<T> it;

    public ReverseListIterator(List<T> list) {
        it = list.listIterator(list.size());
    }

    @Override
    public boolean hasNext() {
        return it.hasPrevious();
    }

    @Override
    public T next() {
        return it.previous();
    }

    @Override
    public void remove() {
        it.remove();
    }

}
