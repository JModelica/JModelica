package org.jmodelica.util.collections;

import java.util.Iterator;

public class SubClassIterable<U, T extends U> implements Iterable<T> {

    private final Iterable<? extends U> parent;
    private final Class<T> typeOfClass;

    public SubClassIterable(Class<T> typeOfClass, Iterable<? extends U> parent) {
        this.parent = parent;
        this.typeOfClass = typeOfClass;
    }

    @Override
    public Iterator<T> iterator() {
        return new SubClassIterator<U, T>(typeOfClass, parent.iterator());
    }

}
