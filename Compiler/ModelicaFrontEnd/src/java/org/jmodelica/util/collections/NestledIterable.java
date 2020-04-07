package org.jmodelica.util.collections;

import java.util.Iterator;

/**
 * Iterable that takes an iterable of T elements, and can internally produce an iterable 
 * of S elements corresponding to a T element. The result is the concatenation of all the 
 * sub-iterables.
 * 
 * @param <ChildType>  the element type of this iterable
 * @param <ParentType> the element type of the iterable passed to the constructor
 */
public abstract class NestledIterable<ChildType,ParentType> implements Iterable<ChildType> {
    private Iterable<ParentType> mainIter = null;

    public NestledIterable(Iterable<ParentType> mainIter) {
        this.mainIter = mainIter;
    }

    @Override
    public Iterator<ChildType> iterator() {
        return new NestledIterator<ChildType,ParentType>(mainIter.iterator()) {
            @Override
            protected Iterator<ChildType> subIterator(ParentType c) {
                Iterable<ChildType> ch = subIterable(c);
                return (ch == null) ? null : ch.iterator();
            }
        };
    }

    /**
     * Return an iterable that returns the elements of the correct type in c, or null 
     * if there can't be any.
     */
    protected abstract Iterable<ChildType> subIterable(ParentType c);

}
