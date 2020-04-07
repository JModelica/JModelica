package org.jmodelica.util.collections;

import java.util.Iterator;

/**
 * Abstract convenience iterable which converts from a another iterable into
 * another. Implementations of this class must implement the transform method
 * which transforms between the two object types.
 *
 * @param <A> The type that we are converting from
 * @param <B> The type that we are converting to
 */
public abstract class TransformerIterable<A, B> implements Iterable<B> {

    private final Iterable<? extends A> iterable;

    protected TransformerIterable(Iterable<? extends A> iterable) {
        this.iterable = iterable;
    }

    /**
     * Converts from type <code>A</code> to type <code>B</code>
     * 
     * @param a the A object
     * @return the B object
     */
    protected abstract B transform(A a) throws SkipException;

    @Override
    public Iterator<B> iterator() {
        final Iterator<? extends A> it = iterable.iterator();
        return new Iterator<B>() {

            @Override
            public boolean hasNext() {
                return it.hasNext();
            }

            @Override
            public B next() {
                while (true) {
                    try {
                        return transform(it.next());
                    } catch (SkipException e) {
                        // Okay, let's skip this one!
                    }
                }
            }

            @Override
            public void remove() {
                it.remove();
            }};
    }
    
    /**
     * Thrown when the element should be skipped for various reasons.
     */
    public static class SkipException extends Exception {
        private static final long serialVersionUID = 1L;
    }

}
