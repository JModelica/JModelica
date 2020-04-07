package org.jmodelica.util.collections;

import java.util.Iterator;
import java.util.NoSuchElementException;

/**
 * Similar to {@link ChainedIterable} but uses iterables instead of arrays.
 */
public class ChainedIterableIterable<T> implements Iterable<T> {
    
    private final Iterable<? extends Iterable<T>> iterables;

    public ChainedIterableIterable(Iterable<? extends Iterable<T>> iterables) {
        this.iterables = iterables;
    }

    @Override
    public Iterator<T> iterator() {
        return new Iterator<T>() {

            private Iterator<? extends Iterable<T>> it;
            private Iterator<T> current;

            @Override
            public boolean hasNext() {
                if (it == null) { // Not initialized
                    it = iterables.iterator();
                    if (!it.hasNext()) {
                        return false;
                    }
                    current = it.next().iterator();
                }
                while (!current.hasNext() && it.hasNext()) {
                    current = it.next().iterator();
                }
                boolean hasNext = current.hasNext() || it.hasNext();
                return hasNext;
            }

            @Override
            public T next() {
                if (!hasNext()) {
                    throw new NoSuchElementException();
                }
                return current.next();
            }

            @Override
            public void remove() {
                throw new UnsupportedOperationException();
            }
            
        };
    }

}
