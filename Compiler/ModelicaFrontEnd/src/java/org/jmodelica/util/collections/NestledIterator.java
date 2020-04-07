package org.jmodelica.util.collections;

import java.util.Iterator;
import java.util.NoSuchElementException;

/**
 * Iterator that takes an iterator of T elements, and can internally produce an iterator 
 * of S elements corresponding to a T element. The result is the concatenation of all the 
 * sub-iterators.
 * 
 * @param <ChildType>  the element type of this iterator
 * @param <ParentType> the element type of the iterator passed to the constructor
 */
public abstract class NestledIterator<ChildType,ParentType> implements Iterator<ChildType> {
    private Iterator<ChildType> subIter;
    private Iterator<ParentType> mainIter = null;
    private boolean ready = false;
    
    public NestledIterator(Iterator<ParentType> mainIter) {
        this.mainIter = mainIter;
    }
    
    /**
     * Return an iterator that returns the elements of the correct type in c, or null 
     * if there can't be any.
     */
    protected abstract Iterator<ChildType> subIterator(ParentType c);
    
    @Override
    public boolean hasNext() {
        if (!ready) {
            while ((subIter == null || !subIter.hasNext()) && mainIter.hasNext()) {
                subIter = subIterator(mainIter.next());
            }
            if (subIter != null && !subIter.hasNext()) {
                subIter = null;
            }
            ready = true;
        }
        return subIter != null;
    }
    
    @Override
    public ChildType next() {
        if (!hasNext()) {
            throw new NoSuchElementException();
        }
        ready = false;
        return subIter.next();
    }
    
    @Override
    public void remove() {
        throw new UnsupportedOperationException();
    }

}
