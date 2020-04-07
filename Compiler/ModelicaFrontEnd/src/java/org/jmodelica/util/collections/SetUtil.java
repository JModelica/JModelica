package org.jmodelica.util.collections;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * Utility methods for {@link java.util.Set Set}s.
 */
public final class SetUtil {

    /**
     * Hidden default constructor to prevent instantiation.
     */
    private SetUtil() {}

    /**
     * Creates a new set with initial set elements.
     * 
     * @param <T>       the type of elements the set contains.
     * @param elements  the elements.
     * @return          a {@link java.util.Set Set} containing {@code elements}.
     */
    @SafeVarargs
    public static <T> java.util.Set<T> create(T... elements) {
        java.util.Set<T> set = new HashSet<T>();
        for (T element : elements) {
            set.add(element);
        }
        return set;
    }

    /**
     * Creates a set of strings from the string representation of elements.
     * 
     * @param <T>       the type of elements the set contains.
     * @param elements  the elements.
     * @return          a {@link java.util.Set Set} containing the string representation of {@code elements}.
     */
    @SafeVarargs
    public static <T> java.util.Set<String> stringSet(T... elements) {
        java.util.Set<String> strings = new HashSet<String>();
        for (T element : elements) {
            strings.add(element.toString());
        }
        return strings;
    }
    
    /**
     * Converts an {@link Iterable} to a {@link Set}.
     * 
     * @param <T>
     *            The type of element in the iterable.
     * @param iterable
     *            The iterable which elements to put in the set.
     * @return
     *         a set containing all the elements in {@code iterable}.
     */
    public static <T> Set<T> set(Iterable<T> iterable) {
        Set<T> set = new HashSet<T>();
        for (T element : iterable) {
            set.add(element);
        }
        return set;
    }
    
    /**
     * Short-hand method for creating a set with predefined contents.
     * 
     * @param <T>
     *            The type of elements in the set.
     * @param ts
     *            The elements to put in the set.
     * @return
     *         a {@link Set} containing the {@code T}-type elements {@code ts}.
     */
    @SafeVarargs
    public final static <T> Set<T> set(T... ts) {
        return new HashSet<T>(Arrays.asList(ts));
    }

}
