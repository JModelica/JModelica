package org.jmodelica.util.collections;

/**
 * Contains the required parts of java.util.Iterator, but for int instead of Object.
 * 
 * The benefit compared to Iterator<Integer> is that there is no autoboxing involved.
 */
public interface IntIterator {
    /**
     * Check if the next method is expected to succeed.
     */
    public boolean hasNext();
    
    /**
     * Return the next value. 
     * 
     * If there are no next value, the result is unspecified (and hasNext() must return false).
     */
    public int next();

}
