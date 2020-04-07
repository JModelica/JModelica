package org.jmodelica.util.collections;

import java.util.Iterator;

import org.jmodelica.util.Criteria;

public class FilteredIterable<T> implements Iterable<T> {

    private final Iterable<T> parent;
    private Criteria<? super T> criteria;

    public FilteredIterable(Iterable<T> parent, Criteria<? super T> criteria) {
        this.parent = parent;
        this.criteria = criteria;
    }

    @Override
    public Iterator<T> iterator() {
        return new FilteredIterator<T>(parent.iterator(), criteria);
    }

}
