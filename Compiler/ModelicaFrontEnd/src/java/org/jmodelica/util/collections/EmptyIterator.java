package org.jmodelica.util.collections;

import java.util.Iterator;
import java.util.NoSuchElementException;

/**
 * \brief Generic empty iterator.
 */
public class EmptyIterator<E> implements Iterator<E> {

    @Override
    public boolean hasNext() {
        return false;
    }

    @Override
    public E next() {
        throw new NoSuchElementException();
    }

    @Override
    public void remove() {
        throw new UnsupportedOperationException();
    }
}
