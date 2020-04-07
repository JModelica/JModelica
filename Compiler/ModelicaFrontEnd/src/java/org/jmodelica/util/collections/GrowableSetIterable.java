package org.jmodelica.util.collections;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

/**
 * Allows iterating over a Set while it grows.
 * 
 * The returned iterator will first pass though the contents of the set as it was when it 
 * was created, and then any new contents, repeating until there was no new additions during 
 * the last pass.
 * 
 * Removing items is not supported, and will result in undefined behavior.
 */
public class GrowableSetIterable<T> implements Iterable<T> {

    private Set<T> set;

    public GrowableSetIterable(Set<T> set) {
        this.set = set;
    }

    @Override
    public Iterator<T> iterator() {
        return new Iterator<T>() {

            private Iterator<T> copy = new ArrayList<T>(set).iterator();
            private Set<T> visited = new HashSet<T>();
            private T next = update();

            @Override
            public boolean hasNext() {
                return next != null;
            }

            @Override
            public T next() {
                T res = next;
                next = update();
                return res;
            }

            private T update() {
                T res = null;
                while (res == null && set.size() > visited.size()) {
                    if (!copy.hasNext()) {
                        copy = new ArrayList<T>(set).iterator();
                    }
                    T val = copy.next();
                    if (visited.add(val)) {
                        res = val;
                    }
                }
                return res;
            }

            @Override
            public void remove() {
                throw new UnsupportedOperationException();
            }};
    }

}
